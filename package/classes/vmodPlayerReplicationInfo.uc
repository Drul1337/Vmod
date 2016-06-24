////////////////////////////////////////////////////////////////////////////////
// vmodPlayerReplicationInfo
////////////////////////////////////////////////////////////////////////////////
class vmodPlayerReplicationInfo expands PlayerReplicationInfo;

var bool bReadyToGoLive;

replication
{
    reliable if ( Role == ROLE_Authority )
        bReadyToGoLive;
}

defaultproperties
{
    bReadyToGoLive=false
}