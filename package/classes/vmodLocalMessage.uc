////////////////////////////////////////////////////////////////////////////////
//  vmodLocalMessage
////////////////////////////////////////////////////////////////////////////////
class vmodLocalMessage extends LocalMessage;

////////////////////////////////////////////////////////////////////////////////
//  ClientReceive
//
//  Called by PlayerPawn when it receives a ClientMessage.
////////////////////////////////////////////////////////////////////////////////
static function ClientReceive( 
	PlayerPawn P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject)
{
    // Write message to player's console
	if ( Default.bIsConsoleMessage )
		if ((P.Player != None) && (P.Player.Console != None))
			P.Player.Console.AddString(Static.GetString( Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject ));
    
    // Pass message to player's HUD
    if ( P.myHUD != None )
		P.myHUD.LocalizedMessage( Default.Class, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

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
    bIsUnique=True
    bIsConsoleMessage=True
    bFadeMessage=False
    LifeTime=5
    bFromBottom=True
    YPos=65.000000
    bCenter=True
}