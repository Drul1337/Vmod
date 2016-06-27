////////////////////////////////////////////////////////////////////////////////
// vmodGameInfoBaseTeams
////////////////////////////////////////////////////////////////////////////////
class vmodGameInfoBaseTeams extends vmodGameInfoBase abstract;

////////////////////////////////////////////////////////////////////////////////
//  Team related functions
////////////////////////////////////////////////////////////////////////////////
function PlayerRequestingTeamChange(Pawn P, byte team)
{
    // Invalid in non-team games
    if(!GameIsTeamGame())
        return;

    // TODO: Perform team size checks before accepting the requested
    PlayerTeamChange(P, team);
}

function PlayerTeamChange(Pawn PChanged, byte team)
{
    local Pawn P;
    
    // Invalid in non-team games
    if(!GameIsTeamGame())
        return;
    
    // Check if the team is valid
    if(team < 0 || team > 3)
        return;
    
    vmodRunePlayer(PChanged).NotifyTeamChange(team);
    PChanged.DesiredColorAdjust = GetTeamColor(team);
    
    // TODO: Update this message
    for(P = Level.PawnList; P != None; P = P.NextPawn)
        P.ClientMessage(
            PChanged.PlayerReplicationInfo.PlayerName $ " joined team " $ team,
            GetMessageTypeNameDefault(),
            false);
}

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
        case 0:     return Vect(1, 0.234, 0.234) * b;
        case 1:     return Vect(0.234, 0.234, 1) * b;
        case 2:     return Vect(0.234, 1, 0.234) * b;
        case 3:     return Vect(1, 1, 0.234) * b;
        default:    return Vect(1, 1, 1) * b;
    }
}

function byte PlayerGetTeam(Pawn P)
{
    // Invalid in non-team games
    if(!GameIsTeamGame())
        return 255;
    
    // TODO: Maybe calling a pawn function is a better idea
    return vmodRunePlayer(P).PlayerReplicationInfo.Team;
}

function int GetTeamScore(byte team)
{
    // Invalid in non-team games
    if(!GameIsTeamGame())
        return 0;
    // TODO: Implement this according to game types
}

function bool GameIsTeamGame()
{
    return bTeamGame;
}