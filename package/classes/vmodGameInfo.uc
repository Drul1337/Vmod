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

    // Parse game options from command line
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
//  Login
//
//  Log a player in.
//  Fails login if you set the Error string.
//  PreLogin is called before Login, but significant game time may pass before
//  Login is called, especially if content is downloaded.
////////////////////////////////////////////////////////////////////////////////
function bool GameAtCapacity()
{
    if(MaxPlayers <= 0)
        return false;
    if(NumPlayers < MaxPlayers)
        return false;
    return true;
}

event playerpawn Login
(
	string Portal,
	string Options,
	out string Error,
	class<playerpawn> SpawnClass
)
{
	local NavigationPoint StartSpot;
	local PlayerPawn      NewPlayer, TestPlayer;
	local Pawn            PawnLink;
	local string          InName, InPassword, InSkin, InFace, InChecksum;
	local byte            InTeam;

    // Check capacity (may have changed since PreLogin)
    // Note: No longer distinguishing between players and spectators
    if(Level.NetMode != NM_Standalone)
    {
        if(GameAtCapacity())
        {
            Error = MaxedOutMessage;
            return None;
        }
    }

	// Get URL options.
	InName     = Left(ParseOption ( Options, "Name"), 20);
	InTeam     = GetIntOption( Options, "Team", 255 ); // default to "no team"
	InPassword = ParseOption ( Options, "Password" );
	InSkin	   = ParseOption ( Options, "Skin"    );
	InFace     = ParseOption ( Options, "Face"    );
	InChecksum = ParseOption ( Options, "Checksum" );

	log( "Login:" @ InName );
	if( InPassword != "" )
		log( "Password"@InPassword );
	 
	// Find a start spot.
	StartSpot = FindPlayerStart( None, InTeam, Portal );

	if( StartSpot == None )
	{
		Error = FailedPlaceMessage;
		return None;
	}

	// Try to match up to existing unoccupied player in level,
	// for savegames and coop level switching.
	for( PawnLink=Level.PawnList; PawnLink!=None; PawnLink=PawnLink.NextPawn )
	{
		TestPlayer = PlayerPawn(PawnLink);
		if
		(	TestPlayer!=None
		&&	TestPlayer.Player==None 
		&&  TestPlayer.PlayerReplicationInfo != None
		&&  TestPlayer.bIsPlayer
		&&	TestPlayer.PlayerReplicationInfo.PlayerName != class'PlayerReplicationInfo'.default.PlayerName
		)
		{
			if
			(	(Level.NetMode==NM_Standalone)
			||	(TestPlayer.PlayerReplicationInfo.PlayerName~=InName && TestPlayer.Password~=InPassword) )
			{
				// Found matching unoccupied player, so use this one.
				NewPlayer = TestPlayer;
				NewPlayer.Tag = 'Player';
				break;
			}
		}
	}

	// In not found, spawn a new player.
	if( NewPlayer==None )
	{
		// Make sure this kind of player is allowed.
		if ( (bHumansOnly || Level.bHumansOnly) && !SpawnClass.Default.bIsHuman
			&& !ClassIsChildOf(SpawnClass, class'Spectator') )
			SpawnClass = DefaultPlayerClass;

		NewPlayer = Spawn(SpawnClass,,'Player',StartSpot.Location,StartSpot.Rotation);
		if( NewPlayer!=None )
		{
			NewPlayer.ViewRotation = StartSpot.Rotation;

			// Save the playerstart event for later firing
			NewPlayer.StartEvent = StartSpot.Event;

			NewPlayer.bJustSpawned = true;
		}
	}
	else
	{
		NewPlayer.bJustSpawned = false;
	}

	// Handle spawn failure.
	if( NewPlayer == None )
	{
		log("Couldn't spawn player at "$StartSpot);
		Error = FailedSpawnMessage;
		return None;
	}

	NewPlayer.CurrentSkin = int(InSkin);
	NewPlayer.static.SetSkinActor(NewPlayer, int(InSkin));

	// Set the player's ID.
	NewPlayer.PlayerReplicationInfo.PlayerID = CurrentID++;

	// Init player's information.
	NewPlayer.ClientSetRotation(NewPlayer.Rotation);
	if( InName=="" )
		InName=DefaultPlayerName;
	if( Level.NetMode!=NM_Standalone || NewPlayer.PlayerReplicationInfo.PlayerName==DefaultPlayerName )
		ChangeName( NewPlayer, InName, false );

	// Change player's team.
	if ( !ChangeTeam(newPlayer, InTeam) )
	{
		Error = FailedTeamMessage;
		return None;
	}

	if( NewPlayer.IsA('Spectator') && (Level.NetMode == NM_DedicatedServer) )
		NumSpectators++;

	// Init player's administrative privileges
	//NewPlayer.Password = InPassword;
	//NewPlayer.bAdmin = AdminPassword!="" && caps(InPassword)==caps(AdminPassword);
	//NewPlayer.PlayerReplicationInfo.bAdmin = NewPlayer.bAdmin;
	//if( NewPlayer.bAdmin )
	//	log( "Administrator logged in!" );

	// Init player's replication info
	NewPlayer.GameReplicationInfo = GameReplicationInfo;

	// If we are a server, broadcast a welcome message.
	if( Level.NetMode==NM_DedicatedServer || Level.NetMode==NM_ListenServer )
		BroadcastMessage( NewPlayer.PlayerReplicationInfo.PlayerName$EnteredMessage, false );

	// Log it.
	if ( LocalLog != None )
		LocalLog.LogPlayerConnect(NewPlayer);
	if ( WorldLog != None )
		WorldLog.LogPlayerConnect(NewPlayer, InChecksum);

	if ( !NewPlayer.IsA('Spectator') )
		NumPlayers++;
		
	return newPlayer;
}

////////////////////////////////////////////////////////////////////////////////
//  ReadyToGoLive
//
//  These functions are used for handling readying and unreadying players.
//  Override EnoughPlayersToGoLive for custom ready conditions.
////////////////////////////////////////////////////////////////////////////////

// These functions are called by the player, and implemented in states only
function bool PlayerReadyToGoLive(Pawn ReadyPawn)        { return false; }
function bool PlayerNotReadyToGoLive(Pawn UnreadyPawn)   { return false; }

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
    GotoStatePreGame();
}

////////////////////////////////////////////////////////////////////////////////
//  ResetPlayerStatistics
////////////////////////////////////////////////////////////////////////////////
function ResetPlayerStatistics(Pawn P)
{
    local vmodPlayerReplicationInfo PRI;
    
    PRI = vmodPlayerReplicationInfo(P.PlayerReplicationInfo);
    if(PRI == None)
        return;
    
    PRI.Score = 0;
    PRI.Deaths = 0;
    PRI.bReadyToPlay = false;
    PRI.bFirstBlood = false;
    PRI.MaxSpree = 0;
    PRI.HeadKills = 0;
}

////////////////////////////////////////////////////////////////////////////////
//  RestartPlayer
//
//  Completely reset a player, including score, trophies, health, power, etc.
////////////////////////////////////////////////////////////////////////////////
function bool RestartPlayer( pawn aPlayer )	
{
	local NavigationPoint startSpot;
	local bool foundStart;
	local int i;
	local actor A;
    local vmodRunePlayer rPlayer;

	if( bRestartLevel && Level.NetMode!=NM_DedicatedServer && Level.NetMode!=NM_ListenServer )
		return true;

	startSpot = FindPlayerStart(aPlayer, 255);
	if( startSpot == None )
	{
		log(" Player start not found!!!");
		return false;
	}
		
	foundStart = aPlayer.SetLocation(startSpot.Location);
	if( foundStart )
	{
		startSpot.PlayTeleportEffect(aPlayer, true);
		aPlayer.SetRotation(startSpot.Rotation);
		aPlayer.ViewRotation = aPlayer.Rotation;
		aPlayer.Acceleration = vect(0,0,0);
		aPlayer.Velocity = vect(0,0,0);
		aPlayer.Health = aPlayer.Default.Health;
		aPlayer.SetCollision( true, true, true );
		aPlayer.bCollideWorld = true;
		aPlayer.SetCollisionSize(aPlayer.Default.CollisionRadius, aPlayer.Default.CollisionHeight);
		aPlayer.ClientSetLocation( startSpot.Location, startSpot.Rotation );
		aPlayer.bHidden = false;
		aPlayer.DamageScaling = aPlayer.Default.DamageScaling;
		aPlayer.SoundDampening = aPlayer.Default.SoundDampening;

		// Team games require this
		if (bTeamGame)
			aPlayer.DesiredColorAdjust = GetTeamVectorColor(aPlayer.PlayerReplicationInfo.Team);
		else
			aPlayer.DesiredColorAdjust = aPlayer.Default.DesiredColorAdjust;

		if (PlayerPawn(aPlayer)!=None)
		{
			PlayerPawn(aPlayer).DesiredPolyColorAdjust = PlayerPawn(aPlayer).Default.DesiredPolyColorAdjust;
			PlayerPawn(aPlayer).PolyColorAdjust = PlayerPawn(aPlayer).Default.PolyColorAdjust;
		}

		aPlayer.ReducedDamageType = aPlayer.Default.ReducedDamageType;
		aPlayer.ReducedDamagePct = aPlayer.Default.ReducedDamagePct;
		aPlayer.Style = aPlayer.Default.Style;
		aPlayer.bInvisible = aPlayer.Default.bInvisible;
		aPlayer.SpeedScale = SS_Circular;
		aPlayer.bLookFocusPlayer = aPlayer.Default.bLookFocusPlayer;
		aPlayer.bAlignToFloor = aPlayer.Default.bAlignToFloor;
		aPlayer.ColorAdjust = aPlayer.Default.ColorAdjust;
		aPlayer.ScaleGlow = aPlayer.Default.ScaleGlow;
		aPlayer.Fatness = aPlayer.Default.Fatness;
		aPlayer.BlendAnimSequence = aPlayer.Default.BlendAnimSequence;
		aPlayer.DesiredFatness = aPlayer.Default.DesiredFatness;
		aPlayer.MaxHealth = aPlayer.Default.MaxHealth;
		aPlayer.Strength = aPlayer.Default.Strength;
		aPlayer.MaxStrength = aPlayer.Default.MaxStrength;
		aPlayer.RunePower = aPlayer.Default.RunePower;
		aPlayer.MaxPower = aPlayer.Default.MaxPower;
		aPlayer.GroundSpeed = aPlayer.Default.GroundSpeed;
		aPlayer.SetDefaultPolyGroups();
		aPlayer.SetDefaultJointFlags();
        
        ClearPlayerAttachments(aPlayer);
        
		for (i=0; i<NUM_BODYPARTS; i++)
		{	// Restore body part health
			aPlayer.BodyPartHealth[i] = aPlayer.Default.BodyPartHealth[i];
		}
		// Restore joint flags
		aPlayer.SetDefaultJointFlags();
		for (i=0; i<16; i++)
		{	// Restore polygroup skins/properties
			aPlayer.SkelGroupSkins[i] = aPlayer.Default.SkelGroupSkins[i];
			aPlayer.SkelGroupFlags[i] = aPlayer.Default.SkelGroupFlags[i];
		}
		aPlayer.SetSkinActor(aPlayer, aPlayer.CurrentSkin);

		// Reset anim proxy vars
		if(PlayerPawn(aPlayer) != None && PlayerPawn(aPlayer).AnimProxy != None)
		{
			PlayerPawn(aPlayer).AnimProxy.GotoState('Idle');
		}
	}
	else
		log(startspot$" Player start not useable!!!");
    
    
    
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

	return foundStart;
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
//  ClearPlayerAttachments
//
//  Strip a player of anything attached to it.
////////////////////////////////////////////////////////////////////////////////
function ClearPlayerAttachments(Pawn P)
{
    local Actor A;
    local int i;
    
    for (i = 0; i < P.NumJoints(); i++)
	{
		A = P.DetachActorFromJoint(i);
		if (A!=None)
			A.Destroy();
	}
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
        
        ResetTimerLocal();
        
        // Perform actions on all players
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            if(vmodRunePlayer(P) == None)
                continue;
            
            ResetPlayerStatistics(P);
            vmodRunePlayer(P).NotifyGamePreGame();
            vmodGameReplicationInfo(GameReplicationInfo).GameTimer = 0;
        }
        
        BroadcastPreGame();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  PreGame: PostLogin
    //
    //  A new player just entered the game, handle how this effects the game's
    //  ready state.
    ////////////////////////////////////////////////////////////////////////////
    event PostLogin(PlayerPawn P)
    {
        Global.PostLogin(P);
        
        BroadcastMessage("" $ NumPlayers $ " current players");
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  PreGame: PlayerReadyToGoLive
    //
    //  A player has switched to ready. Check if enough players in the game are
    //  ready to start. This is only valid in PreGame.
    ////////////////////////////////////////////////////////////////////////////
    function bool PlayerReadyToGoLive(Pawn ReadyPawn)
    {
        local Pawn P;
        
        if(NumPlayers < 1)
        {
            // TODO: Send "waiting for more players" message to pawn
            ReadyPawn.ClientMessage("Waiting for more players to joing");
            return false;
        }
        
        BroadcastPlayerReadyToGoLive(ReadyPawn);
        vmodPlayerReplicationInfo(ReadyPawn.PlayerReplicationInfo).bReadyToGoLive = true;
        
        if(EnoughPlayersReadyToGoLive())
            GotoStateStarting();
        return true;
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  PreGame: PlayerNotReadyToGoLive
    //
    //  A player has switched to not ready. This is only valid in PreGame.
    ////////////////////////////////////////////////////////////////////////////
    function bool PlayerNotReadyToGoLive(Pawn UnreadyPawn)
    {
        BroadcastPlayerNotReadyToGoLive(UnreadyPawn);
        return false;
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
        
        ResetTimerLocal();
        NativeLevelCleanup();
        
        // Perform actions on all players
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            if(vmodRunePlayer(P) == None)
                continue;
            
            ResetPlayerStatistics(P);
            vmodRunePlayer(P).NotifyGameStarting();
            RestartPlayer(P);
        }
        
        BroadcastGameIsStarting();
    }
    
    function EndState()
    {
        ResetTimerLocal();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  Starting: Timer
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
    
    ////////////////////////////////////////////////////////////////////////////
    //  Starting: ReduceDamage
    //
    //  Pawns are invulnerable during Starting
    ////////////////////////////////////////////////////////////////////////////
    function ReduceDamage(
        out int BluntDamage,
        out int SeverDamage,
        name DamageType,
        pawn injured,
        pawn instigatedBy)
    {
        BluntDamage = 0;
        SeverDamage = 0;
        DamageType = 'None';
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
            vmodGameReplicationInfo(GameReplicationInfo).GameTimer = TimeRemaining;
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
    ScoreBoardType=Class'Vmod.vmodScoreBoard'
    
    TimerBroad=0
    TimerLocal=0
    bMarkNativeActors=true
    StartingDuration=5
    StartingCountdownBegin=5
    TimeLimit=1200
    ScoreLimit=20
	GenericDiedMessage=" died."
    HUDType=Class'Vmod.vmodHUD'
    GameReplicationInfoClass=Class'Vmod.vmodGameReplicationInfo'
}
