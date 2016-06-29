////////////////////////////////////////////////////////////////////////////////
// vmodGameInfoBaseTeams
////////////////////////////////////////////////////////////////////////////////
class vmodGameInfoBaseTeams extends vmodGameInfoBase abstract;

function byte FindBestTeamForPlayer(Pawn P)
{
    local byte Team;
    
    Team = vmodRunePlayer(P).PlayerReplicationInfo.Team;
    if(Team >= 0 && Team <= 3)
        return Team;
    else
        return 0;
}

function bool CheckTeamIsValid(byte Team)
{
    if(Team >= 0 && Team <= 3)      return true;
    if(Team == GetInactiveTeam())   return true;
    return false;
}

////////////////////////////////////////////////////////////////////////////////
//  Player or Admin invoked functions
////////////////////////////////////////////////////////////////////////////////
function PlayerTeamChange(Pawn P, byte Team)
{
    if(!GameIsTeamGame())                       return; // Not a team game
    if(!CheckTeamIsValid(Team))                 return; // Invalid team request
    if(vmodRunePlayer(P).CheckIsGameInactive()) return; // Player is not playing
    if(vmodRunePlayer(P).GetTeam() == Team)     return; // Already on this team
    
    // TODO: Should probably handle this in the pawn class
    P.PlayerReplicationInfo.Team = Team;
    P.DesiredColorAdjust = GetTeamColorVector(Team);
    DispatchPlayerChangedTeam(P, Team);
}

////////////////////////////////////////////////////////////////////////////////
//  ShuffleTeams
//
//  Attempt to balance teams.
////////////////////////////////////////////////////////////////////////////////
function ShuffleTeams()
{
    // TODO: Implement a good balancing algorithm
    local Pawn PCurr;
    local byte i;
    i = 0;
    for(PCurr = Level.PawnList; PCurr != None; PCurr = PCurr.NextPawn)
    {
        if(vmodRunePlayer(PCurr) != None)
        {
            PlayerTeamChange(PCurr, i % 4);
            i++;
        }
    }
    DispatchTeamsShuffled();
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
function byte GetInactiveTeam()
{
    return 255;
}

////////////////////////////////////////////////////////////////////////////////
//  GetTeamColor
////////////////////////////////////////////////////////////////////////////////
function Vector GetTeamColorVector(byte Team)
{
    local Vector V;
    local float brightness;
    brightness = 200.0;
    ColorsTeamsClass.Static.GetTeamColorVector(
        Team,
        V.X,
        V.Y,
        V.Z);
    V *= brightness;
    return V;
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
            LocalMessagesClass.Static.GetMessageTypeNameDefault(),
            false);
}

function DispatchTeamsShuffled()
{
    local Pawn PCurr;
    for(PCurr = Level.PawnList; PCurr != None; PCurr = PCurr.NextPawn)
        PCurr.ClientMessage(
            "Team shuffle",
            LocalMessagesClass.Static.GetMessageTypeNameDefault(),
            false);
}