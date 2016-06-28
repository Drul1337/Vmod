////////////////////////////////////////////////////////////////////////////////
// vmodGameInfoBaseTeams
////////////////////////////////////////////////////////////////////////////////
class vmodGameInfoBaseTeams extends vmodGameInfoBase abstract;

////////////////////////////////////////////////////////////////////////////////
//  Player or Admin invoked functions
////////////////////////////////////////////////////////////////////////////////
function PlayerTeamChange(Pawn P, byte Team)
{
    if(!GameIsTeamGame())           return;
    if(Team > 3)                    return;
    if(GetPlayerTeam(P) == Team)    return;
    
    P.PlayerReplicationInfo.Team = Team;
    P.DesiredColorAdjust = GetTeamColorVector(Team);
    DispatchPlayerChangedTeam(P, Team);
}


////////////////////////////////////////////////////////////////////////////////
//  Event Dispatchers
////////////////////////////////////////////////////////////////////////////////
function DispatchPlayerChangedTeam(Pawn P, byte Team)
{
    // TODO: Implement a real team change message
    local Pawn PCurr;
    for(PCurr = Level.PawnList; PCurr != None; PCurr = PCurr.NextPawn)
        PCurr.ClientMessage(
            P.PlayerReplicationInfo.PlayerName $ " changed to team " $ Team,
            GetMessageTypeNameDefault(),
            false);
}

////////////////////////////////////////////////////////////////////////////////
//  GameIsTeamGame
//
//  Return whether or not this is a team game.
////////////////////////////////////////////////////////////////////////////////
function bool GameIsTeamGame()
{
    return bTeamGame;
}

////////////////////////////////////////////////////////////////////////////////
//  GetPlayerTeam
//
//  Return a player's current team. If this is not a team game, return default
//  team.
////////////////////////////////////////////////////////////////////////////////
function byte GetPlayerTeam(Pawn P)
{
    if(!GameIsTeamGame())
        return 255;
    
    // TODO: Maybe calling a safer function in Pawn is a better idea
    return vmodRunePlayer(P).PlayerReplicationInfo.Team; 
}

////////////////////////////////////////////////////////////////////////////////
//  GetTeamColor
////////////////////////////////////////////////////////////////////////////////
function Vector GetTeamColorVector(byte Team)
{
    local Vector V;
    local float brightness;
    brightness = 102.0;
    ColorsTeamsClass.Static.GetTeamColorVector(
        Team,
        V.X,
        V.Y,
        V.Z);
    V *= brightness;
    return V;
}