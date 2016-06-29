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
        if(vmodRunePlayer(PCurr).CheckIsPlaying())
            PlayerTeamChange(PCurr, i % 4);
        i++;
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

function DispatchTeamsShuffled()
{
    local Pawn PCurr;
    for(PCurr = Level.PawnList; PCurr != None; PCurr = PCurr.NextPawn)
        PCurr.ClientMessage(
            "Team shuffle",
            GetMessageTypeNameDefault(),
            false);
}