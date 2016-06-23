////////////////////////////////////////////////////////////////////////////////
// vmodGameInfo
////////////////////////////////////////////////////////////////////////////////
class vmodGameInfo extends GameInfo abstract;

var() globalconfig int  StartDuration;
var() globalconfig int	ScoreLimit;
var() globalconfig int	TimeLimit;

var int TimerBroad; // Time since the server switched to this game
var int TimerLocal; // Local time used between states

var localized string GenericDiedMessage;

var string EndGameReason;
var bool bMarkNativeActors;

////////////////////////////////////////////////////////////////////////////////
//  State utility functions
////////////////////////////////////////////////////////////////////////////////
final function GotoStatePreGame()     { GotoState('PreGame'); }
final function GotoStateStarting()    { GotoState('Starting'); }
final function GotoStateLive()        { GotoState('Live'); }
final function GotoStatePostGame()    { GotoState('PostGame'); }

////////////////////////////////////////////////////////////////////////////////
//  IsRelevant
////////////////////////////////////////////////////////////////////////////////
function bool IsRelevant(Actor A)
{
    if(bMarkNativeActors)
        MarkLevelNativeActor(A);
    else
        MarkLevelNonNativeActor(A);
    
    return Super.IsRelevant(A);
}

////////////////////////////////////////////////////////////////////////////////
//  LevelNativeActor
//
//  These functions mark Actors which are native to the current level. Used for
//  clean up in between rounds.
////////////////////////////////////////////////////////////////////////////////
function MarkLevelNativeActor(Actor A)
{ A.bDifficulty3 = true; }

function MarkLevelNonNativeActor(Actor A)
{ A.bDifficulty3 = false; }

function bool CheckLevelNativeActor(Actor A)
{ return A.bDifficulty3; }

////////////////////////////////////////////////////////////////////////////////
//  PreBeginPlay
////////////////////////////////////////////////////////////////////////////////
function PreBeginPlay()
{
    StartTime = 0;
    SetGameSpeed(GameSpeed);
    Level.bNoCheating = bNoCheating;
	Level.bAllowFOV = bAllowFOV;
    
    if(GameReplicationInfoClass == None)
        GameReplicationInfoClass = class'Vmod.vmodGameReplicationInfo';
    GameReplicationInfo = Spawn(GameReplicationInfoClass);
    
    InitGameReplicationInfo();
    
    bMarkNativeActors = false;
}

////////////////////////////////////////////////////////////////////////////////
//  PostBeginPlay
////////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
    Spawn(Class'vmodSpawnNotify');
    
    TimerBroad = 0;
    TimerLocal = 0;
    
    Super.PostBeginPlay();
}

////////////////////////////////////////////////////////////////////////////////
//  InitGame
////////////////////////////////////////////////////////////////////////////////
event InitGame( string Options, out string Error )
{
	local String InOpt;

	Super.InitGame(Options, Error);

    // TODO: These options are not working
    //ScoreLimit = GetIntOption( Options, "FragLimit", ScoreLimit );
	//TimeLimit = GetIntOption( Options, "TimeLimit", TimeLimit );
    ScoreLimit = 20;
    TimeLimit = 1200;
}

////////////////////////////////////////////////////////////////////////////////
//  GetRules
////////////////////////////////////////////////////////////////////////////////
function String GetRules()
{
    local String ResultSet;
    
    ResultSet = Super.GetRules();
    
    ResultSet = ResultSet $ "\\timelimit\\" $ TimeLimit;
    ResultSet = ResultSet $ "\\scorelimit\\" $ ScoreLimit;
    
    return ResultSet;
}

//////////////////////////////////////////////////////////////////////////////////
////  InitGameReplicationInfo
//////////////////////////////////////////////////////////////////////////////////
//function InitGameReplicationInfo()
//{
//	GameReplicationInfo.bTeamGame = bTeamGame;
//	GameReplicationInfo.GameName = GameName;
//	GameReplicationInfo.GameClass = string(Class);
//	GameReplicationInfo.bClassicDeathmessages = bClassicDeathmessages;
//    GameReplicationInfo.TimeRemaining = 0;
//}

////////////////////////////////////////////////////////////////////////////////
//  PlayerReady notifications
//  Implement in states.
////////////////////////////////////////////////////////////////////////////////
function PlayerReadied(Pawn ReadyPawn)      { }
function PlayerUnreadied(Pawn UnreadyPawn)  { }

////////////////////////////////////////////////////////////////////////////////
//  StartGameCondition
//
//  Checked during PreGame to see if it's time to start.
////////////////////////////////////////////////////////////////////////////////
function bool StartGameCondition()
{
    local int Ready;
    local int Unready;
    
    // The majority of players are ready
    GetPlayerReadyCounts(Ready, Unready);
    if(Ready >= Unready)
        return true;
    
    return false;
}

////////////////////////////////////////////////////////////////////////////////
//  GetPlayerReadyCounts
//
//  Check how many players are ready or not ready.
////////////////////////////////////////////////////////////////////////////////
function GetPlayerReadyCounts(out int Ready, out int Unready)
{
    local Pawn P;
    
    Ready = 0;
    Unready = 0;
    
    for(P = Level.PawnList; P != None; P = P.nextPawn)
    {
        if(PlayerPawn(P) != None && P.bIsPlayer)
        {
            if(PlayerPawn(P).bReadyToPlay)
                Ready++;
            else
                Unready++;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
//  Timer
////////////////////////////////////////////////////////////////////////////////
event Timer()
{
	Super.Timer();
    
    TimerBroad++;
    TimerLocal++;
    GameReplicationInfo.ElapsedTime = TimerBroad;
}

////////////////////////////////////////////////////////////////////////////////
//  GameReset
//
//  Reset the current game without reloading.
////////////////////////////////////////////////////////////////////////////////
function GameReset()
{
    BroadcastMessage("Game Reset");
    RestartAllPlayers();
    GotoStatePreGame();
}

////////////////////////////////////////////////////////////////////////////////
//  RestartPlayer
////////////////////////////////////////////////////////////////////////////////
function bool RestartPlayer( pawn aPlayer )	
{
    local bool retval;
    local vmodRunePlayer rPlayer;
    local PlayerReplicationInfo PRI;
    
    BroadcastMessage("RestartPlayer");
    retval = Super.RestartPlayer(aPlayer);
    
    rPlayer = vmodRunePlayer(aPlayer);
	if (rPlayer!=None)
	{
		rPlayer.OldCameraStart = rPlayer.Location;
		rPlayer.OldCameraStart.Z += rPlayer.CameraHeight;
		rPlayer.CurrentDist = rPlayer.CameraDist;
		rPlayer.LastTime = 0;
		rPlayer.CurrentTime = 0;
		rPlayer.CurrentRotation = rPlayer.Rotation;
	}
    
    PRI = PlayerPawn(aPlayer).PlayerReplicationInfo;
    PRI.Score = 0;
    PRI.Deaths = 0;
    PRI.bReadyToPlay = false;
    PRI.bFirstBlood = false;
    PRI.MaxSpree = 0;
    PRI.HeadKills = 0;

	return retval;
}

function bool RestartAllPlayers()
{
    local Pawn P;
    BroadcastMessage("RestartAllPlayers");
    for(P = Level.PawnList; P != None; P = P.nextPawn)
        RestartPlayer(P);
}

////////////////////////////////////////////////////////////////////////////////
//  FindPlayerStart
//
//  Find the best player start for a new player spawn.
////////////////////////////////////////////////////////////////////////////////
function NavigationPoint FindPlayerStart( Pawn Player, optional byte InTeam, optional string incomingName )
{
	local PlayerStart Dest, Candidate[4], Best;
	local float Score[4], BestScore, NextDist;
	local pawn OtherPlayer;
	local int i, num;
	local Teleporter Tel;
	local NavigationPoint N;

	if( incomingName!="" )
		foreach AllActors( class 'Teleporter', Tel )
			if( string(Tel.Tag)~=incomingName )
				return Tel;

	num = 0;
	//choose candidates	
	N = Level.NavigationPointList;
	While ( N != None )
	{
		if ( N.IsA('PlayerStart') && !N.Region.Zone.bWaterZone )
		{
			//if(bLevelHasTeamOnly)
			//{
			//	if((PlayerStart(N).bTeamOnly && bTeamGame) || (!PlayerStart(N).bTeamOnly && !bTeamGame))
			//	{
			//		if(num < 4)
			//			Candidate[num] = PlayerStart(N);
			//		else if(Rand(num) < 4)
			//			Candidate[Rand(4)] = PlayerStart(N);
			//		num++;
			//	}
			//}
			//else
			//{
				if (num<4)
					Candidate[num] = PlayerStart(N);
				else if (Rand(num) < 4)
					Candidate[Rand(4)] = PlayerStart(N);
				num++;
			//}
		}
		N = N.nextNavigationPoint;
	}

	if (num == 0 )
		foreach AllActors( class 'PlayerStart', Dest )
		{
			if (num<4)
				Candidate[num] = Dest;
			else if (Rand(num) < 4)
				Candidate[Rand(4)] = Dest;
			num++;
		}

	if (num>4) num = 4;
	else if (num == 0)
		return None;
		
	//assess candidates
	for (i=0;i<num;i++)
		Score[i] = 4000 * FRand(); //randomize
		
	for ( OtherPlayer=Level.PawnList; OtherPlayer!=None; OtherPlayer=OtherPlayer.NextPawn)	
		if ( OtherPlayer.bIsPlayer && (OtherPlayer.Health > 0) )
			for (i=0;i<num;i++)
				if ( OtherPlayer.Region.Zone == Candidate[i].Region.Zone )
				{
					NextDist = VSize(OtherPlayer.Location - Candidate[i].Location);
					if (NextDist < OtherPlayer.CollisionRadius + OtherPlayer.CollisionHeight)
						Score[i] -= 1000000.0;
					else if ( (NextDist < 2000) && OtherPlayer.LineOfSightTo(Candidate[i]) )
						Score[i] -= 10000.0;
				}
	
	BestScore = Score[0];
	Best = Candidate[0];
	for (i=1;i<num;i++)
		if (Score[i] > BestScore)
		{
			BestScore = Score[i];
			Best = Candidate[i];
		}

	return Best;
}

////////////////////////////////////////////////////////////////////////////////
//  NativeLevelCleanup
//
//  Reset the level to its original state when loaded.
////////////////////////////////////////////////////////////////////////////////
function NativeLevelCleanup()
{
    local Actor A;
    
    foreach AllActors(class'Actor', A)
    {
        // Destroy non-native actors
        if(!CheckLevelNativeActor(A))
        {
            if(Inventory(A) != None)
                A.Destroy();
        }
        // Reset native actors
        else
        {
            if(Inventory(A) != None)
            {
                // TODO: Implement reset code here
            }
        }
        
    }
}

////////////////////////////////////////////////////////////////////////////////
//  STATE: PreGame
//
//  Waiting for players to ready themselves before the game begins.
////////////////////////////////////////////////////////////////////////////////
auto state PreGame
{
    function BeginState()
    {
        local Pawn P;
        
        TimerLocal = 0;
        BroadcastMessage("PreGame");
        
        // Notify all players about PreGame
        for(P = Level.PawnList; P != None; P = P.NextPawn)
            if(vmodRunePlayer(P) != None)
                vmodRunePlayer(P).NotifyGamePreGame();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  PreGame: PlayerReadied
    //
    //  A player has switched to ready. Check if enough players in the game are
    //  ready to start.
    ////////////////////////////////////////////////////////////////////////////
    function PlayerReadied(Pawn ReadyPawn)
    {
        local Pawn P;
        
        BroadcastMessage(ReadyPawn.PlayerReplicationInfo.PlayerName $ " is ready");
        
        if(StartGameCondition())
            GotoStateStarting();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  PreGame: PlayerUnreadied
    //
    //  A player has switched to not ready.
    ////////////////////////////////////////////////////////////////////////////
    function PlayerUnreadied(Pawn UnreadyPawn)
    {
        BroadcastMessage(UnreadyPawn.PlayerReplicationInfo.PlayerName $ " is not ready");
    }
}

////////////////////////////////////////////////////////////////////////////////
//  STATE: Starting
//
//  PreGame has ended, the game is starting.
////////////////////////////////////////////////////////////////////////////////
state Starting
{
    function BeginState()
    {
        local Pawn P;
        
        TimerLocal = 0;
        BroadcastMessage("Game is starting!");
        
        // Notify all players about Starting
        for(P = Level.PawnList; P != None; P = P.NextPawn)
            if(vmodRunePlayer(P) != None)
                vmodRunePlayer(P).NotifyGameStarting();
    }
    
    function Timer()
    {
        local int TimeRemaining;
        
        Global.Timer();
        
        TimeRemaining = StartDuration - TimerLocal;
        if(TimeRemaining <= 5)
            BroadcastMessage("Starting in " $ TimeRemaining);
        if(TimeRemaining <= 0)
            GotoStateLive();
    }
}

////////////////////////////////////////////////////////////////////////////////
//  STATE: Live
//
//  Gameplay is in live action.
////////////////////////////////////////////////////////////////////////////////
state Live
{
    function BeginState()
    {
        local Pawn P;
        Local PlayerPawn Player;
        
        TimerLocal = 0;
        TimeLimit = 20;
        NativeLevelCleanup();
        RestartAllPlayers();
        
        BroadcastLocalizedMessage(class'vmodMessageGameLive');
        // TODO: Play a cool Live sound here like in headball
        
        // Notify all players about Starting
        for(P = Level.PawnList; P != None; P = P.NextPawn)
            if(vmodRunePlayer(P) != None)
                vmodRunePlayer(P).NotifyGameLive();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  Live: Timer
    ////////////////////////////////////////////////////////////////////////////
    function Timer()
    {
        local int TimeRemaining;
        
        Global.Timer();
        
        // Check if time limit has been reached
        if(TimeLimit > 0)
        {
            TimeRemaining = TimeLimit - TimerLocal;
            GameReplicationInfo.RemainingTime = TimeRemaining;
            if(TimeRemaining <= 0)
            {
                EndGameReason = "timelimit";
                GotoStatePostGame();
                return;
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
//  STATE: PostGame
//
//  Game has ended. Let players vote on a new map, reset the current, etc.
////////////////////////////////////////////////////////////////////////////////
state PostGame
{
    function BeginState()
    {
        local Pawn P;
        local Actor A;
        
        TimerLocal = 0;
        
        // Tell all players that the game ended
        for(P = Level.PawnList; P != None; P = P.NextPawn)
            if(vmodRunePlayer(P) != None)
                vmodRunePlayer(P).NotifyGamePostGame();
        
        // Trigger all end game actors
        foreach AllActors(class'Actor', A, 'EndGame')
            A.trigger(self, none);
        
        // Logging
        if (LocalLog != None)
        {
            LocalLog.LogGameEnd(EndGameReason);
            LocalLog.StopLog();
            if (bBatchLocal)
                LocalLog.ExecuteSilentLogBatcher();
            LocalLog.Destroy();
            LocalLog = None;
        }
        
        if (WorldLog != None)
        {
            WorldLog.LogGameEnd(EndGameReason);
            WorldLog.StopLog();
            WorldLog.ExecuteWorldLogBatcher();
            WorldLog.Destroy();
            WorldLog = None;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
defaultproperties
{
    // Actor
    InitialState=PreGame
    
    // GameInfo
    Difficulty=1
    bRestartLevel=True
    bPauseable=True
    bCanChangeSkin=True
    bNoCheating=True
    bCanViewOthers=True
    bAllowWeaponDrop=True
    bAllowShieldDrop=True
    AutoAim=0.930000
    GameSpeed=1.100000
    MaxSpectators=2
    AdminPassword="a"
    SwitchLevelMessage="Switching Levels"
    DefaultPlayerName="Player"
    LeftMessage=" left the game."
    FailedSpawnMessage="Failed to spawn player actor"
    FailedPlaceMessage="Could not find starting spot (level might need a 'PlayerStart' actor)"
    FailedTeamMessage="Could not find team for player"
    NameChangedMessage="Name changed to "
    EnteredMessage=" entered the game."
    GameName="Game"
    MaxedOutMessage="Server is already at capacity."
    WrongPassword="The password you entered is incorrect."
    NeedPassword="You need to enter a password to join this game."
    IPBanned="Your IP address has been banned on this server."
    MaxPlayers=16
    IPPolicies(0)="ACCEPT,*"
    DeathMessageClass=Class'Engine.LocalMessage'
    MutatorClass=Class'Engine.Mutator'
    DefaultPlayerState=PlayerWalking
    ServerLogName="server.log"
    bLocalLog=True
    bWorldLog=True
    bSubtitles=True
    StatLogClass=Class'Engine.StatLogFile'
    DebrisPercentage=0.900000
    ParticlePercentage=1.000000
    bAllowLimbSever=True
    
    TimerBroad=0
    TimerLocal=0
    TimeRemaining=0
    bMarkNativeActors=true
    StartDuration=5
    TimeLimit=1200
    ScoreLimit=20
	GenericDiedMessage=" died."
    HUDType=Class'Vmod.vmodHUD'
    GameReplicationInfoClass=Class'Vmod.vmodGameReplicationInfo'
}
