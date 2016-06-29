///////////////////////////////////////////////////////////////////////////////
//  vmodRunePlayerAIController
//
//  An AI controller for a vmodRunePlayerAI. This class handles all decision
//  making and state handling to control the Pawn. This is implemented outside
//  of the pawn class primarily for the separation of states.
///////////////////////////////////////////////////////////////////////////////
class vmodRunePlayerAIController extends Info;

var private vmodRunePlayerAI AIPlayer;
var private float LogicTimeStamp;
var private float LogicFrequency;

function InitializeConnection(vmodRunePlayerAI P)
{
    if(AIPlayer != P)
        AIPlayer = P;
}

function DestroyConnection(vmodRunePlayerAI P)
{
    if(AIPlayer == P)
        AIPlayer = None;
}

///////////////////////////////////////////////////////////////////////////////
//  PreBeginPlay
///////////////////////////////////////////////////////////////////////////////
function PreBeginPlay()
{
    Super.PreBeginPlay();
    Enable('Tick');
}

///////////////////////////////////////////////////////////////////////////////
//  Tick
///////////////////////////////////////////////////////////////////////////////
event Tick(float DT)
{
    LogicTimeStamp += DT;
    if(LogicTimeStamp > (1.0 / LogicFrequency))
    {
        LogicTimeStamp = 0.0; // This is not correct, but it will work
        TickLogic();
    }
}

///////////////////////////////////////////////////////////////////////////////
//  TickLogic
//
//  Primary decision-making function, called by Tick every 1 / Frequency secs.
///////////////////////////////////////////////////////////////////////////////
function TickLogic()
{
    // Insult some noobs
    local String Insults[16];
    
    Insults[ 0] = "Imma fuk u kids up lol";
    Insults[ 1] = "they told me u wer good";
    Insults[ 2] = "rofl";
    Insults[ 3] = "say ur dooms fucko";
    Insults[ 4] = "roflmao";
    Insults[ 5] = "RIP";
    Insults[ 6] = "RIP AGAIN";
    Insults[ 7] = "and i wasnt even tryin right there. imagine what i woulda did if i was tryin";
    Insults[ 8] = "u shit";
    Insults[ 9] = "womabatat";
    Insults[10] = "yesterday";
    Insults[11] = "i used to be a professional counter strike player";
    Insults[12] = "but then i took an arrow to the knee";
    Insults[13] = "i think the mets are probably the best basketball team";
    Insults[14] = "halo is a pretty cool guy";
    Insults[15] = "[hehe]";
    
    // Insult some noobs
    AIPlayer.Say(Insults[Rand(15)]);
    
    // If player is dead, try to respawn
    if(AIPlayer.CheckIsDead())
        AIPlayer.Fire();
}

///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
    LogicTimeStamp=0.0
    LogicFrequency=0.1
}