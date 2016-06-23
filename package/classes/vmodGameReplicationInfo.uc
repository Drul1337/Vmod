////////////////////////////////////////////////////////////////////////////////
// vmodGameReplicationInfo
////////////////////////////////////////////////////////////////////////////////
class vmodGameReplicationInfo extends GameReplicationInfo;

var string GameStateMessage;

replication
{
    reliable if ( Role == ROLE_Authority)
        GameStateMessage;
}

defaultproperties
{
    GameStateMessage="NoMessage"
}