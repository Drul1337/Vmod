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
    BroadcastMessage("Entered PreRound");
}

function BroadcastStartingRound()
{
    BroadcastMessage("The round is about to begin!");
}

function BroadcastGameIsLive()
{
    BroadcastMessage("The round has started");
}

function BroadcastPostRound()
{
    BroadcastMessage("The round has ended");
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
        
        RoundLimit = 5;
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
        
        // Notify all players about PreRound
        for(P = Level.PawnList; P != None; P = P.NextPawn)
            if(vmodRunePlayer(P) != None)
                vmodRunePlayer(P).NotifyGamePreRound();
        
        ResetTimerLocalRound();
        NativeLevelCleanup();
        RestartAllPlayers();
        BroadcastPreRound();
        RoundNumber++;
        
        // TODO: For now, just go right into starting round
        GotoStateStartingRound();
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
        
        // Notify all players about StartingRound
        for(P = Level.PawnList; P != None; P = P.NextPawn)
            if(vmodRunePlayer(P) != None)
                vmodRunePlayer(P).NotifyGameStartingRound();
        
        ResetTimerLocalRound();
        BroadcastStartingRound();
    }
    
    function EndState()
    {
        ResetTimerLocalRound();
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  PreGame: Timer
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
            BroadcastStartingCountdown(TimeRemaining);
        
        if(TimeRemaining <= 0)
            GotoStateLive();
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
        
        TimeLimitRound = 10; // TODO: Temporary
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
        if(TimeLimit > 0)
        {
            TimeRemaining = TimeLimitRound - TimerLocalRound;
            GameReplicationInfo.RemainingTime = TimeRemaining;
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
}

////////////////////////////////////////////////////////////////////////////////
defaultproperties
{
    StartingRoundDuration=10
    StartingRoundCountdownBegin=5
    TimerLocalRound=0
    RoundNumber=0
}