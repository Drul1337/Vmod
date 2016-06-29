////////////////////////////////////////////////////////////////////////////////
// vmodGameInfoRoundBased
////////////////////////////////////////////////////////////////////////////////
class vmodGameInfoRoundBased extends vmodGameInfo abstract;

// Game states
const STATE_PREROUND        = 'PreRound';
const STATE_STARTINGROUND   = 'StartingRound';
const STATE_POSTROUND       = 'PostRound';

// Command line game options
const OPTION_TIME_LIMIT_ROUND = "timelimitround";

var() globalconfig int StartingRoundDuration;
var() globalconfig int StartingRoundCountdownBegin;
var() globalconfig int PreRoundDuration;
var() globalconfig int PostRoundDuration;
var() globalconfig int TimeLimitRound;
var() globalconfig int RoundLimit;

var() globalconfig String MessagePreRound;
var() globalconfig String MessageStartingRound;
var() globalconfig String MessageStartingRoundCountdown;
var() globalconfig String MessageLiveRound;
var() globalconfig String MessagePostRound;

// TODO: Should mark these as private
var int TimerLocalRound;
var int RoundNumber;

////////////////////////////////////////////////////////////////////////////////
//  State utility functions
////////////////////////////////////////////////////////////////////////////////
final function GotoStatePreRound()          { GotoState(STATE_PREROUND); }
final function GotoStateStartingRound()     { GotoState(STATE_STARTINGROUND); }
final function GotoStatePostRound()         { GotoState(STATE_POSTROUND); }

////////////////////////////////////////////////////////////////////////////////
//  InitGame
////////////////////////////////////////////////////////////////////////////////
event InitGame( string Options, out string Error )
{
	Super.InitGame(Options, Error);
    
    TimeLimitRound = 60 * GetIntOption( Options, OPTION_TIME_LIMIT_ROUND, TimeLimitRound );
}

////////////////////////////////////////////////////////////////////////////////
//  Timer Functions
////////////////////////////////////////////////////////////////////////////////
function ResetTimerLocalRound()
{
    TimerLocalRound = 0;
}

////////////////////////////////////////////////////////////////////////////////
//  GameReplicationInfo update functions
////////////////////////////////////////////////////////////////////////////////
function GRISetRoundNumber(int n)
{
    // TODO: Need to implement this in GRI
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
        
        // Reset state timer
        ResetTimerLocal();
        
        // Apply state options
        GameDisableScoreTracking();
        GameDisablePawnDamage();
        
        // Update game replication info
        GRISetGameTimer(0);
        
        // Perform actions on all players
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            PlayerGameStateNotification(P);
        }
    }
    
    function EndState()
    {
        local Pawn P;
        
        // Reset state timer before round play begins
        ResetTimerLocal();
        
        // Perform actions on all players
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            vmodRunePlayer(P).ResetPlayerStatistics();
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  PreGame: Timer
    //
    //  Count down to go Live
    ////////////////////////////////////////////////////////////////////////////
    function Timer()
    {
        local Pawn P;
        local int TimeRemaining;
        
        Global.Timer();
        
        TimeRemaining = StartingDuration - TimerLocal;
        
        if(TimeRemaining <= StartingCountdownBegin)
            for(P = Level.PawnList; P != None; P = P.NextPawn)
                PlayerMessageStartingCountdown(P, TimeRemaining);
        
        // Start the game by entering pre round
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
        
        // Reset round timer
        ResetTimerLocalRound();
        RoundNumber++;
        
        // Apply state options
        GameDisableScoreTracking();
        GameDisablePawnDamage();
        
        // Update game replication info
        GRISetGameTimer(0);
        GRISetRoundNumber(RoundNumber);
        
        // Notify all players about PreRound
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            PlayerGameStateNotification(P);
        }
    }
    
    function PlayerGameStateNotification(Pawn P)
    {
        // Send PreRound event to player
        vmodRunePlayer(P).NotifyGamePreRound();
        
        // Send PreRound message to player
        if(MessagePreRound != "")
            P.ClientMessage(
                MessagePreRound,
                LocalMessagesClass.Static.GetMessageTypeNamePreRound(),
                false);
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  PreRound: Timer
    ////////////////////////////////////////////////////////////////////////////
    function Timer()
    {
        local int TimeRemaining;
        
        Global.Timer();
        TimerLocalRound++;
        
        TimeRemaining = PreRoundDuration - TimerLocalRound;

        if(TimeRemaining <= 0)
            GotoStateStartingRound();
    }
}

////////////////////////////////////////////////////////////////////////////////
//  STATE: StartingRound
//
//  The game has already begun, and the next round is about to begin.
////////////////////////////////////////////////////////////////////////////////
state StartingRound
{
    function BeginState()
    {
        local Pawn P;
        
        // Reset state timer
        ResetTimerLocalRound();
        
        // Apply state option
        GameDisableScoreTracking();
        GameDisablePawnDamage();
        
        // Return level to its original state
        NativeLevelCleanup();
        
        // Update game replication info
        GRISetGameTimer(0);
        
        // Perform actions on all players
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            PlayerGameStateNotification(P);
            RestartPlayer(P);
        }
    }
    
    function EndState()
    {
        ResetTimerLocalRound();
    }
    
    function PlayerGameStateNotification(Pawn P)
    {
        // Send StartingRound event to player
        vmodRunePlayer(P).NotifyGameStartingRound();
        
        // Send StartingRound message to player
        if(MessageStartingRound != "")
            P.ClientMessage(
                MessageStartingRound,
                LocalMessagesClass.Static.GetMessageTypeNameStartingRound(),
                false);
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  StartingRound: Timer
    //
    //  Count down to the next Live Round
    ////////////////////////////////////////////////////////////////////////////
    function Timer()
    {
        local Pawn P;
        local int TimeRemaining;
        
        Global.Timer();
        TimerLocalRound++;
        
        TimeRemaining = StartingRoundDuration - TimerLocalRound;
        
        if(TimeRemaining <= StartingCountdownBegin)
            for(P = Level.PawnList; P != None; P = P.NextPawn)
                PlayerMessageStartingRoundCountdown(P, TimeRemaining);
        
        if(TimeRemaining <= 0)
            GotoStateLive();
    }
    
    function PlayerMessageStartingRoundCountdown(Pawn P, int TimeRemaining)
    {
        // Send StartingRoundCountdown message to player
        if(MessageStartingRoundCountDown != "")
            P.ClientMessage(
                MessageStartingRoundCountDown $ " " $ TimeRemaining,
                LocalMessagesClass.Static.GetMessageTypeNameStartingRound(),
                false);
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
        
        // Apply state options
        GameEnableScoreTracking();
        GameEnablePawnDamage();
        
        // Update game replication info
        GRISetGameTimer(0);
        
        // Perform actions on all players
        for(P = Level.PawnList; P != None; P = P.NextPawn)
            if(vmodRunePlayer(P) != None)
                PlayerGameStateNotification(P);
    }
    
    function PlayerGameStateNotification(Pawn P)
    {
        // Send Live event to player
        vmodRunePlayer(P).NotifyGameLive();
        
        // Send Live message to player
        if(MessageLiveRound != "")
            P.ClientMessage(
                MessageLiveRound,
                LocalMessagesClass.Static.GetMessageTypeNameLiveGame(),
                false);
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
            GRISetGameTimer(TimeRemaining);
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
        
        // Reset state timer
        ResetTimerLocalRound();
        
        // Apply state options
        GameDisableScoreTracking();
        GameDisablePawnDamage();
        
        // Update game replication info
         GRISetGameTimer(0);
        
        // Notify all players about PostRound
        for(P = Level.PawnList; P != None; P = P.NextPawn)
            if(vmodRunePlayer(P) != None)
                PlayerGameStateNotification(P);
        
        // Round limit reached?
        if(RoundLimit > 0)
        {
            if(RoundNumber >= RoundLimit)
            {
                EndGameReason="Round Limit Reached";
                GotoStatePostGame();
                return;
            }
        }
    }
    
    function PlayerGameStateNotification(Pawn P)
    {
        vmodRunePlayer(P).NotifyGamePostRound();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  PostRound: Timer
    ////////////////////////////////////////////////////////////////////////////
    function Timer()
    {
        local int TimeRemaining;
        
        Global.Timer();
        TimerLocalRound++;
        
        TimeRemaining = PostRoundDuration - TimerLocalRound;

        if(TimeRemaining <= 0)
            GotoStatePreRound();
    }
}

////////////////////////////////////////////////////////////////////////////////
defaultproperties
{
    StartingRoundDuration=10
    StartingRoundCountdownBegin=5
    TimerLocalRound=0
    RoundNumber=0
    PreRoundDuration=3
    PostRoundDuration=3
    MessageLiveRound="Round"
    MessagePreRound="Prepare for the next round"
    MessageStartingRound="The round is starting"
    MessageStartingRoundCountdown="Round begins in"
    MessagePostRound="The round has ended"
}