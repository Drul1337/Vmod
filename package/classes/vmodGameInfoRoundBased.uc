////////////////////////////////////////////////////////////////////////////////
// vmodGameInfoRoundBased
////////////////////////////////////////////////////////////////////////////////
//class vmodGameInfoRoundBased extends vmodGameInfo abstract;
class vmodGameInfoRoundBased extends vmodGameInfo;

var() globalconfig int StartingRoundDuration;
var() globalconfig int StartingRoundCountdownBegin;
var() globalconfig int TimeLimitRound;
var() globalconfig int RoundLimit;

var() globalconfig String MessagePreRound;
var() globalconfig String MessageStartingRound;
var() globalconfig String MessageStartingRoundCountdown;
var() globalconfig String MessageLiveRound;
var() globalconfig String MessagePostRound;

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
//  MessageTypeNames
////////////////////////////////////////////////////////////////////////////////
function Name GetMessageTypeName(class<LocalMessage> MessageClass)
{
    switch(MessageClass)
    {
        case Class'Vmod.vmodLocalMessagePreRound':      return 'PreRound';
        case Class'Vmod.vmodLocalMessageStartingRound': return 'StartingRound';
        case Class'Vmod.vmodLocalMessagePostRound':     return 'PostRound';
    }
    return Super.GetMessageTypeName(MessageClass);
}

function Name GetMessageTypeNamePreRound()
{ return GetMessageTypeName(Class'Vmod.vmodLocalMessagePreRound'); }

function Name GetMessageTypeNameStartingRound()
{ return GetMessageTypeName(Class'Vmod.vmodLocalMessageStartingRound'); }

function Name GetMessageTypeNamePostRound()
{ return GetMessageTypeName(Class'Vmod.vmodLocalMessagePostRound'); }

////////////////////////////////////////////////////////////////////////////////
//  MessageTypeClasses
////////////////////////////////////////////////////////////////////////////////
function Class<LocalMessage> GetMessageTypeClass(Name MessageName)
{
    switch(MessageName)
    {
        case 'PreRound':        return Class'Vmod.vmodLocalMessagePreRound';
        case 'StartingRound':   return Class'Vmod.vmodLocalMessageStartingRound';
        case 'PostRound':       return Class'Vmod.vmodLocalMessagePostRound';
    }
    return Super.GetMessageTypeClass(MessageName);
}

function Class<LocalMessage> GetMessageTypeClassPreRound()
{ return GetMessageTypeClass('PreRound'); }

function Class<LocalMessage> GetMessageTypeClassStartingRound()
{ return GetMessageTypeClass('StartingRound'); }

function Class<LocalMessage> GetMessageTypeClassPostRound()
{ return GetMessageTypeClass('PostRound'); }

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
        
        GameDisablePawnDamage();
        ResetTimerLocal();
        
        // Perform actions on all players
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            PlayerGameStateNotification(P);
        }
    }
    
    function EndState()
    {
        local Pawn P;
        
        ResetTimerLocal();
        
        // Perform actions on all players
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            PlayerResetStatistics(P);
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
        
        GameDisablePawnDamage();
        ResetTimerLocalRound();
        
        // Notify all players about PreRound
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            PlayerGameStateNotification(P);
        }
        
        RoundNumber++;
        
        GotoStateStartingRound();
    }
    
    function PlayerGameStateNotification(Pawn P)
    {
        // Send PreRound event to player
        vmodRunePlayer(P).NotifyGamePreRound();
        
        // Send PreRound message to player
        if(MessagePreRound != "")
            P.ClientMessage(
                MessagePreRound,
                GetMessageTypeNamePreRound(),
                false);
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
        
        GameDisablePawnDamage();
        ResetTimerLocalRound();
        NativeLevelCleanup();
        
        // Notify all players about StartingRound
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            RestartPlayer(P);
            PlayerGameStateNotification(P);
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
                GetMessageTypeNameStartingRound(),
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
                GetMessageTypeNameStartingRound(),
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
        
        GameEnablePawnDamage();
        
        // Notify all players that the round is Live
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
                GetMessageTypeNameLiveGame(),
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
        
        GameDisablePawnDamage();
        
        // Notify all players about PostRound
        for(P = Level.PawnList; P != None; P = P.NextPawn)
            if(vmodRunePlayer(P) != None)
                PlayerGameStateNotification(P);
        
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
    
    function PlayerGameStateNotification(Pawn P)
    {
        vmodRunePlayer(P).NotifyGamePostRound();
    }
}

////////////////////////////////////////////////////////////////////////////////
defaultproperties
{
    StartingRoundDuration=10
    StartingRoundCountdownBegin=5
    TimerLocalRound=0
    RoundNumber=0
    MessageLiveRound="Round"
    MessagePreRound="Prepare for the next round"
    MessageStartingRound="The round is starting"
    MessageStartingRoundCountdown="Round begins in"
    MessagePostRound="The round has ended"
}