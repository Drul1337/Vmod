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
        if(vmodRunePlayer(P).CheckIsAlive())
        {
            if(TeamAlive == -1)
                TeamAlive = vmodRunePlayer(P).GetTeam();
            else
                if(vmodRunePlayer(P).GetTeam() != TeamAlive)
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