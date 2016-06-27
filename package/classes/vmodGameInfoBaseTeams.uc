////////////////////////////////////////////////////////////////////////////////
// vmodGameInfoBaseTeams
////////////////////////////////////////////////////////////////////////////////
class vmodGameInfoBaseTeams extends vmodGameInfoBase abstract;

// Vector based team colors
const COLORVECT_RED     = Vect(1.000, 0.234, 0.234);
const COLORVECT_GREEN   = Vect(0.234, 1.000, 0.234);
const COLORVECT_BLUE    = Vect(0.234, 0.234, 1.000);
const COLORVECT_GOLD    = Vect(1.000, 1.000, 0.234);
const COLORVECT_WHITE   = Vect(1.000, 1.000, 1.000);


////////////////////////////////////////////////////////////////////////////////
//  Player or Admin invoked functions
////////////////////////////////////////////////////////////////////////////////
function PlayerTeamChange(Pawn P, byte Team)
{
    if(!GameIsTeamGame())           return;
    if(Team > 3)                    return;
    if(GetPlayerTeam(P) == Team)    return;
    
    P.PlayerReplicationInfo.Team = Team;
    P.DesiredColorAdjust = GetTeamColor(Team);
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
//
//  Get the vector based team color for a given team.
////////////////////////////////////////////////////////////////////////////////
function Vector GetTeamColor(byte team)
{
    // TODO: Unify these colors with vmodHUD
    local float b;
    
    // Invalid in non-team games
    if(!GameIsTeamGame())
        return Vect(1, 1, 1);
    
    b = 100;
    switch(team)
    {
        case 0:     return b * COLORVECT_RED;
        case 1:     return b * COLORVECT_BLUE;
        case 2:     return b * COLORVECT_GREEN;
        case 3:     return b * COLORVECT_GOLD;
        default:    return b * COLORVECT_WHITE;
    }
}