////////////////////////////////////////////////////////////////////////////////
// vmodGameTeamDeathmatch
////////////////////////////////////////////////////////////////////////////////
class vmodGameTeamDeathmatch extends vmodGameInfo;

defaultproperties
{
    bTeamGame=true
    MapListType=Class'RuneI.DMmaplist'
    MapPrefix="DM"
    BeaconName="DM"
    GameName="[Vmod] Team Death Match"
    ScoreBoardType=Class'Vmod.vmodScoreBoardTeams'
}