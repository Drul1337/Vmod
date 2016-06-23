////////////////////////////////////////////////////////////////////////////////
//  vmodLocalMessage
////////////////////////////////////////////////////////////////////////////////
class vmodLocalMessage extends LocalMessage;

////////////////////////////////////////////////////////////////////////////////
//  ClientReceiveMessage
//
//  Called by PlayerPawn when it receives a ClientMessage.
////////////////////////////////////////////////////////////////////////////////
static function ClientReceiveMessage(
	PlayerPawn P,
	String Msg,
	optional PlayerReplicationInfo PRI)
{
    // Write message to player's console
	if ( Default.bIsConsoleMessage )
		if ((P.Player != None) && (P.Player.Console != None))
			P.Player.Console.AddString(Msg);

    // Pass message to player's HUD
	if ( P.myHUD != None )
		P.myHUD.LocalizedMessage( Default.Class, 0, PRI, None, None, Msg );
}

////////////////////////////////////////////////////////////////////////////////
//  GetString
////////////////////////////////////////////////////////////////////////////////
static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return "";
}

////////////////////////////////////////////////////////////////////////////////
defaultproperties
{
    CharactersPerSecond=5.000000
    bIsUnique=True
    bIsConsoleMessage=True
    bFadeMessage=False
    LifeTime=5
    bFromBottom=True
    YPos=65.000000
    bCenter=True
}