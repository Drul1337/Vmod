////////////////////////////////////////////////////////////////////////////////
// vmodGameInfoRoundBased
////////////////////////////////////////////////////////////////////////////////
class vmodGameInfoRoundBased extends vmodGameInfo abstract;

var() globalconfig int StartingRoundDuration;
var() globalconfig int StartingRoundCountdownBegin;
var() globalconfig int TimeLimitRound;
var() globalconfig int RoundLimit;

var int TimerLocalRound;

var int RoundNumber;

////////////////////////////////////////////////////////////////////////////////
//  State utility functions
////////////////////////////////////////////////////////////////////////////////
final function GotoStatePreRound()          { GotoState('PreRound'); }
final function GotoStateStartingRound()     { GotoState('StartingRound'); }
final function GotoStatePostRound()         { GotoState('PostRound'); }

////////////////////////////////////////////////////////////////////////////////
//  InitGame
////////////////////////////////////////////////////////////////////////////////
event InitGame( string Options, out string Error )
{
	Super.InitGame(Options, Error);
    
    TimeLimitRound = 60 * GetIntOption( Options, "timelimitround", TimeLimitRound );
}

////////////////////////////////////////////////////////////////////////////////
//  Timer Functions
////////////////////////////////////////////////////////////////////////////////
function ResetTimerLocalRound()
{
    TimerLocalRound = 0;
}

////////////////////////////////////////////////////////////////////////////////
//  Broadcast Functions
//
//  TODO: Implement these all as localized messages and incorporate some sounds
////////////////////////////////////////////////////////////////////////////////
function BroadcastPreRound()
{
    BroadcastAnnouncement("Prepare for the next round");
}

function BroadcastStartingRound()
{
    //BroadcastAnnouncement("Prepare for the next round");
}

function BroadcastGameIsLive()
{
    BroadcastAnnouncement("Round " $ RoundNumber);
}

function BroadcastStartingRoundCountdown(int T)
{
    BroadcastAnnouncement("Next round in " $ T);
}

function BroadcastPostRound()
{
    //BroadcastAnnouncement("The round has ended");
}

////////////////////////////////////////////////////////////////////////////////
//  STATE: PreGame
//
//  Waiting for players to ready themselves before the game begins.
////////////////////////////////////////////////////////////////////////////////
state PreGame
{
    function BeginState()
    {
        Super.BeginState();
        RoundNumber = 0;
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
        
        // Perform actions on all players
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            if(vmodRunePlayer(P) == None)
                continue;
            
            vmodRunePlayer(P).NotifyGameStarting();
        }
        
        BroadcastGameIsStarting();
    }
    
    function EndState()
    {
        local Pawn P;
        
        ResetTimerLocal();
        
        // Perform actions on all players
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            if(vmodRunePlayer(P) == None)
                continue;
            
            ResetPlayerStatistics(P);
        }
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
            GotoStatePreRound();
    }
}

////////////////////////////////////////////////////////////////////////////////
//  STATE: PreRound
//
//  The game already begun, waiting for the next round to start.
////////////////////////////////////////////////////////////////////////////////
state PreRound
{
    function BeginState()
    {
        local Pawn P;
        
        ResetTimerLocalRound();
        
        // Notify all players about PreRound
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            if(vmodRunePlayer(P) == None)
                continue;
            
            vmodRunePlayer(P).NotifyGamePreRound();
        }
        
        BroadcastPreRound();
        RoundNumber++;
        
        GotoStateStartingRound();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  PreRound: ReduceDamage
    //
    //  Pawns are invulnerable during PreRound
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
//  STATE: StartingRound
//
//  The game already begun, and the next round is about to begin.
////////////////////////////////////////////////////////////////////////////////
state StartingRound
{
    function BeginState()
    {
        local Pawn P;
        
        ResetTimerLocalRound();
        NativeLevelCleanup();
        
        // Notify all players about StartingRound
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            if(vmodRunePlayer(P) == None)
                continue;
            
            RestartPlayer(P);
            vmodRunePlayer(P).NotifyGameStartingRound();
        }
        
        BroadcastStartingRound();
    }
    
    function EndState()
    {
        ResetTimerLocalRound();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  StartingRound: Timer
    //
    //  Count down to the next Live Round
    ////////////////////////////////////////////////////////////////////////////
    function Timer()
    {
        local int TimeRemaining;
        
        Global.Timer();
        TimerLocalRound++;
        
        TimeRemaining = StartingRoundDuration - TimerLocalRound;
        
        if(TimeRemaining <= StartingCountdownBegin)
            BroadcastStartingRoundCountdown(TimeRemaining);
        
        if(TimeRemaining <= 0)
            GotoStateLive();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  StartingRound: ReduceDamage
    //
    //  Pawns are invulnerable during StartingRound
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
//  In round-based play, "Live" means that the current round is in live action.
////////////////////////////////////////////////////////////////////////////////
state Live
{
    function BeginState()
    {
        local Pawn P;
        
        // Notify all players that the round is Live
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
        TimerLocalRound++;
        
        // Check if time limit has been reached
        if(TimeLimitRound > 0)
        {
            TimeRemaining = TimeLimitRound - TimerLocalRound;
            vmodGameReplicationInfo(GameReplicationInfo).GameTimer = TimeRemaining;
            if(TimeRemaining <= 0)
            {
                GotoStatePostRound();
                return;
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  Killed
    //
    //  PKiller has just killed PDead.
    ////////////////////////////////////////////////////////////////////////////
    function Killed(Pawn PKiller, Pawn PDead, Name DamageType)
    {
        if(vmodRunePlayer(PDead) != None)
            vmodRunePlayer(PDead).bCanRestart = false;
        
        Super.Killed(PKiller, PDead, DamageType);
    }
}

////////////////////////////////////////////////////////////////////////////////
//  STATE: PostRound
//
//  The game already begun, the round has just ended.
////////////////////////////////////////////////////////////////////////////////
state PostRound
{
    function BeginState()
    {
        local Pawn P;
        
        // Notify all players about PostRound
        for(P = Level.PawnList; P != None; P = P.NextPawn)
            if(vmodRunePlayer(P) != None)
                vmodRunePlayer(P).NotifyGamePostRound();
        
        if(RoundLimit > 0)
        {
            if(RoundNumber >= RoundLimit)
            {
                EndGameReason="Round Limit Reached";
                GotoStatePostGame();
                return;
            }
        }
        GotoStatePreRound();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  StartingRound: PostRound
    //
    //  Pawns are invulnerable during PostRound
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
defaultproperties
{
    StartingRoundDuration=10
    StartingRoundCountdownBegin=5
    TimerLocalRound=0
    RoundNumber=0
}