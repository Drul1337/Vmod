////////////////////////////////////////////////////////////////////////////////
//  vmodMessageGameLive
////////////////////////////////////////////////////////////////////////////////
class vmodMessageGameLive extends vmodLocalMessage;

var localized String LiveMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return Default.LiveMessage;
}

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.DrawColor;
}

defaultproperties
{
    LiveMessage="Live!"
    bIsConsoleMessage=True
    bFadeMessage=True
    LifeTime=5
    bCenter=True
}