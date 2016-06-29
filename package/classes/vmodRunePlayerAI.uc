///////////////////////////////////////////////////////////////////////////////
//  vmodRunePlayerAI
//
//  A vmodRunePlayer that can talk back and forth with an AI controller.
///////////////////////////////////////////////////////////////////////////////
class vmodRunePlayerAI extends vmodRunePlayer;

var private vmodRunePlayerAIController AIController;

///////////////////////////////////////////////////////////////////////////////
function InitializeAIController()
{
    if(AIController == None)
        AIController = Spawn(Class'Vmod.vmodRunePlayerAIController');
    AIController.InitializeConnection(Self);
    log("Bot AI initialized");
}

function DestroyAIController()
{
    if(AIController != None)
        AIController.Destroy();
    AIController.DestroyConnection(Self);
    log("Bot AI destroyed");
}


///////////////////////////////////////////////////////////////////////////////
//  Overrides
///////////////////////////////////////////////////////////////////////////////
event ClientMessage(
    coerce string   S,
    optional name   Type, 
    optional bool   bBeep)
{}

event TeamMessage(
    PlayerReplicationInfo   PRI,
    coerce string           S,
    name                    Type,
    optional bool           bBeep)
{}

event ReceiveLocalizedMessage(
    class<LocalMessage>             Message,
    optional int                    Switch,
    optional PlayerReplicationInfo  RelatedPRI_1,
    optional PlayerReplicationInfo  RelatedPRI_2,
    optional Object                 OptionalObject)
{}

//exec function Say(string Msg)
//{}

//exec function TeamSay(string Msg)
//{}