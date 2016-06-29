////////////////////////////////////////////////////////////////////////////////
// vmodGameTeamGladiator
////////////////////////////////////////////////////////////////////////////////
class vmodGameTeamGladiator extends vmodGameGladiator;

function bool CheckRoundEndConditionKilled(Pawn PKiller, Pawn PDead)
{
    local Pawn P;
    local int TeamAlive;
    
    TeamAlive = -1;
    for(P = Level.PawnList; P != None; P = P.NextPawn)
    {
        // TODO: Replace all of these checks with a function in runeplayer
        if(vmodRunePlayer(P).Health > 0)
        {
            if(TeamAlive == -1)
                TeamAlive = GetPlayerTeam(P);
            else
                if(GetPlayerTeam(P) != TeamAlive)
                    return false;
        }
    }
    
    // TODO: Winning team = TeamAlive
    
    return true;
}

////////////////////////////////////////////////////////////////////////////////
defaultproperties
{
    bTeamGame=true
    GameName="[Vmod] Team Gladiator"
    ScoreBoardType=Class'Vmod.vmodScoreBoardTeams'
}