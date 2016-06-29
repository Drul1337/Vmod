///////////////////////////////////////////////////////////////////////////////
//  vmodRunePlayerAI
//
//  A vmodRunePlayer that can talk back and forth with an AI controller.
///////////////////////////////////////////////////////////////////////////////
class vmodRunePlayerAI extends vmodRunePlayer;

var private vmodRunePlayerAIController AIController;

///////////////////////////////////////////////////////////////////////////////
//  Static interface
///////////////////////////////////////////////////////////////////////////////
static function String GetRandomAIName()
{
    local String Names[16];
    Names[ 0] = "William_Wallace_III";
    Names[ 1] = "Steve";
    Names[ 2] = "chunk";
    Names[ 3] = "Wombat";
    Names[ 4] = "Mother!";
    Names[ 5] = "Mr.Deeds";
    Names[ 6] = "DoolittlY";
    Names[ 7] = "PISTOL_MAN";
    Names[ 8] = "PretendHuman";
    Names[ 9] = "Best_Friend";
    Names[10] = "PhYzIcJKs";
    Names[11] = "BOT";
    Names[12] = "Q\_O";
    Names[13] = "GoOfY";
    Names[14] = "NetRadio";
    Names[15] = "PowerOverwhelming";
    return Names[Rand(15)];
}

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

exec function Taunt()
{
	local name Sequence;

	if (Physics != PHYS_Walking)	// Disallow while falling
		return;

	//if( bShowMenu || (Level.Pauser!=""))
	//	return;

	// Don't allow the player to taunt if they are doing something like weapon switching or attacking
	if(AnimProxy != None && AnimProxy.GetStateName() != 'Idle')
		return;

	if (Weapon != None)
		Sequence = Weapon.A_Taunt;
	else
		Sequence = 'S3_Taunt';

	//if(Role < ROLE_Authority)
	//	ServerTaunt(Sequence);
    PlayUninterruptedAnim(Sequence);
}

//exec function Say(string Msg)
//{}

//exec function TeamSay(string Msg)
//{}


///////////////////////////////////////////////////////////////////////////////
defaultproperties
{
    bIsHuman=false
}