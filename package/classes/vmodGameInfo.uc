////////////////////////////////////////////////////////////////////////////////
// vmodGameInfo
////////////////////////////////////////////////////////////////////////////////
class vmodGameInfo extends GameInfo abstract;

var() globalconfig int  StartingDuration;
var() globalconfig int  StartingCountdownBegin;
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
//
//  All Actors pass through this function. At level start up, mark every actor
//  as "native" to the level, so that the level can be reset later.
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
function MarkLevelNativeActor(Actor A)          { A.bDifficulty3 = true; }
function MarkLevelNonNativeActor(Actor A)       { A.bDifficulty3 = false; }
function bool CheckLevelNativeActor(Actor A)    { return A.bDifficulty3; }

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
    Spawn(Class'vmodSpawnNotify'); // Replaces actors with vmod actors
    
    TimerBroad = 0;
    
    Super.PostBeginPlay();
}

////////////////////////////////////////////////////////////////////////////////
//  InitGame
////////////////////////////////////////////////////////////////////////////////
event InitGame( string Options, out string Error )
{
	Super.InitGame(Options, Error);

    // TODO: These options are not working
    ScoreLimit = GetIntOption( Options, "scorelimit", ScoreLimit );
	TimeLimit = 60 * GetIntOption( Options, "timelimit", TimeLimit );
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

////////////////////////////////////////////////////////////////////////////////
//  ReadyToGoLive
//
//  These functions are used for handling readying and unreadying players.
//  Override EnoughPlayersToGoLive for custom ready conditions.
////////////////////////////////////////////////////////////////////////////////

// These functions are called by the player, and implemented in states only
function PlayerReadyToGoLive(Pawn ReadyPawn)        { }
function PlayerNotReadyToGoLive(Pawn UnreadyPawn)   { }

// Return true to switch game state to Starting, which counts into Live
function bool EnoughPlayersReadyToGoLive()
{
    local int ReadyCount;
    local int UnreadyCount;
    local Pawn P;
    
    // Get ready counts
    ReadyCount = 0;
    UnreadyCount = 0;
    
    for(P = Level.PawnList; P != None; P = P.NextPawn)
    {
        if(vmodRunePlayer(P) != None && P.bIsPlayer)
        {
            if(vmodRunePlayer(P).ReadyToGoLive())
                ReadyCount++;
            else
                UnreadyCount++;
        }
    }
    
    // Ready count conditions - majority of players are ready
    if(ReadyCount >= UnreadyCount)
        return true;
    return false;
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
//
//  Completely reset a player, including score, trophies, health, power, etc.
////////////////////////////////////////////////////////////////////////////////
function bool RestartPlayer( pawn aPlayer )	
{
    local bool retval;
    local vmodRunePlayer rPlayer;
    local PlayerReplicationInfo PRI;
    
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
    for(P = Level.PawnList; P != None; P = P.nextPawn)
        RestartPlayer(P);
}

////////////////////////////////////////////////////////////////////////////////
//  SetPlayerReadyToGoLive
////////////////////////////////////////////////////////////////////////////////
function SetPlayerReadyToGoLive(Pawn P, bool Ready)
{
    if(vmodRunePlayer(P) == None)
        return;
    vmodRunePlayer(P).SetReadyToGoLive(Ready);
}

function SetAllPlayersReadyToGoLive(bool Ready)
{
    local Pawn P;
    for(P = Level.PawnList; P != None; P = P.nextPawn)
        SetPlayerReadyToGoLive(P, Ready);
}

////////////////////////////////////////////////////////////////////////////////
//  ClearPlayerInventory
//
//  Strip a player of their entire inventory.
////////////////////////////////////////////////////////////////////////////////
function ClearPlayerInventory(Pawn P)
{
    local Inventory Curr;
    local Inventory Next;
    
    // TODO: This looks like a weird iteration, is this right?
    for(Curr = P.Inventory; Curr != None; Curr = Next)
    {
        Next = Curr.Inventory;
        Curr.Destroy();
    }
    
    P.Weapon = None;
    P.SelectedItem = None;
    P.Shield = None;
}

////////////////////////////////////////////////////////////////////////////////
//  GivePlayerWeapon
//
//  Give a weapon to a player.
////////////////////////////////////////////////////////////////////////////////
function GivePlayerWeapon(Pawn P, class<Weapon> WeaponClass)
{
    local Weapon W;
    local Inventory Inv;
    
    for(Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
        if(Inv.Class == WeaponClass)
            return;
    
    W = Spawn(WeaponClass);
    if(W == None)
        return;
    
    if(P.Weapon != None)
        if(vmodRunePlayer(P) != None)
            vmodRunePlayer(P).StowWeapon(P.Weapon);
    
    W.bTossedOut = true;
    W.Instigator = P;
    W.BecomeItem();
    W.GotoState('Active');
    P.AddInventory(W);
    P.AcquireInventory(W);
    P.Weapon = W;
}

////////////////////////////////////////////////////////////////////////////////
//  FindPlayerStart
//
//  Find the best player start for a new player spawn. This is copied directly
//  from RuneMultiplayer.
//  TODO: Might be able to do something about spawn frags in here
////////////////////////////////////////////////////////////////////////////////
function NavigationPoint FindPlayerStart(
    Pawn Player,
    optional byte InTeam,
    optional string incomingName )
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
			if (num<4)
				Candidate[num] = PlayerStart(N);
			else if (Rand(num) < 4)
				Candidate[Rand(4)] = PlayerStart(N);
			num++;
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
//  Killed
//
//  PKiller has just killed PDead.
////////////////////////////////////////////////////////////////////////////////
function Killed(Pawn PKiller, Pawn PDead, Name DamageType)
{
    Super.Killed(PKiller, PDead, DamageType);
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
//  Timer Functions
////////////////////////////////////////////////////////////////////////////////
event Timer()
{
	Super.Timer();
    
    // Update local and broad timers
    TimerBroad++;
    TimerLocal++;
    
    GameReplicationInfo.ElapsedTime = TimerBroad;
}

function ResetTimerLocal()
{
    TimerLocal = 0;
}

////////////////////////////////////////////////////////////////////////////////
//  Broadcast Functions
//
//  TODO: Implement these all as localized messages and incorporate some sounds
////////////////////////////////////////////////////////////////////////////////
final function BroadcastAnnouncement(coerce String Message)
{
    BroadcastMessage(Message,,'vmodGameAnnouncement');
}

function BroadcastPreGame()
{
    BroadcastAnnouncement("PreGame");
}

function BroadcastPlayerReadyToGoLive(Pawn P)
{
    BroadcastAnnouncement(P.PlayerReplicationInfo.PlayerName $ " is ready");
}

function BroadcastPlayerNotReadyToGoLive(Pawn P)
{
    BroadcastAnnouncement(P.PlayerReplicationInfo.PlayerName $ " is not ready");
}

function BroadcastGameIsStarting()
{
    BroadcastAnnouncement("Game is starting!");
}

function BroadcastStartingCountdown(int T)
{
    BroadcastAnnouncement("Starting in " $ T);
}

function BroadcastGameIsLive()
{
    BroadcastAnnouncement("Game is live!");
}

function BroadcastPostGame()
{
    BroadcastAnnouncement("Game has ended");
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
        
        // Notify all players about PreGame
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            if(vmodRunePlayer(P) != None)
            {
                vmodRunePlayer(P).NotifyGamePreGame();
                SetPlayerReadyToGoLive(P, false);
            }
        }
        
        ResetTimerLocal();
        BroadcastPreGame();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  PreGame: PlayerReadyToGoLive
    //
    //  A player has switched to ready. Check if enough players in the game are
    //  ready to start.
    ////////////////////////////////////////////////////////////////////////////
    function PlayerReadyToGoLive(Pawn ReadyPawn)
    {
        local Pawn P;
        
        BroadcastPlayerReadyToGoLive(ReadyPawn);
        
        if(EnoughPlayersReadyToGoLive())
            GotoStateStarting();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  PreGame: PlayerNotReadyToGoLive
    //
    //  A player has switched to not ready.
    ////////////////////////////////////////////////////////////////////////////
    function PlayerNotReadyToGoLive(Pawn UnreadyPawn)
    {
        BroadcastPlayerNotReadyToGoLive(UnreadyPawn);
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
        
        // Notify all players about Starting
        for(P = Level.PawnList; P != None; P = P.NextPawn)
            if(vmodRunePlayer(P) != None)
                vmodRunePlayer(P).NotifyGameStarting();
        
        ResetTimerLocal();
        BroadcastGameIsStarting();
    }
    
    function EndState()
    {
        ResetTimerLocal();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  PreGame: Timer
    //
    //  Count down to go Live
    ////////////////////////////////////////////////////////////////////////////
    function Timer()
    {
        local int TimeRemaining;
        
        Global.Timer();
        
        TimeRemaining = StartingDuration - TimerLocal;
        
        if(TimeRemaining <= StartingCountdownBegin)
            BroadcastStartingCountdown(TimeRemaining);
        
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
        
        // Notify all players that the game is Live
        for(P = Level.PawnList; P != None; P = P.NextPawn)
            if(vmodRunePlayer(P) != None)
                vmodRunePlayer(P).NotifyGameLive();
        
        //TimeLimit = 20; // TODO: Temporary
        
        NativeLevelCleanup();
        RestartAllPlayers();
        BroadcastGameIsLive();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  Live: Timer
    //
    //  Calculate remaining time and check for game time out condition.
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
        
        // Tell all players that the game ended
        for(P = Level.PawnList; P != None; P = P.NextPawn)
            if(vmodRunePlayer(P) != None)
                vmodRunePlayer(P).NotifyGamePostGame();
        
        // Trigger all end game actors
        foreach AllActors(class'Actor', A, 'EndGame')
            A.trigger(self, none);
        
        ResetTimerLocal();
        BroadcastPostGame();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  PostGame: Timer
    //
    //  Calculate post game time.
    ////////////////////////////////////////////////////////////////////////////
    function Timer()
    {
        Global.Timer();
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
    StartingDuration=5
    StartingCountdownBegin=5
    TimeLimit=1200
    ScoreLimit=20
	GenericDiedMessage=" died."
    HUDType=Class'Vmod.vmodHUD'
    GameReplicationInfoClass=Class'Vmod.vmodGameReplicationInfo'
}
