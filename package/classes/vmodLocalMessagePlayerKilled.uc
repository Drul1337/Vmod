////////////////////////////////////////////////////////////////////////////////
//  vmodLocalMessagePlayerKilled
////////////////////////////////////////////////////////////////////////////////
class vmodLocalMessagePlayerKilled extends vmodLocalMessage;

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	return "Kill Message";
}