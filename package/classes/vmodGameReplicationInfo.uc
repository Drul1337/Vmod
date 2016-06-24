////////////////////////////////////////////////////////////////////////////////
// vmodGameReplicationInfo
////////////////////////////////////////////////////////////////////////////////
class vmodGameReplicationInfo extends GameReplicationInfo;

// TODO: Could probably set it so GameTimer only needs 1 update and then
// counts down within here
var int GameTimer;

replication
{
    reliable if ( Role == ROLE_Authority)
        GameTimer;
}

defaultproperties
{
    GameTimer=0
}