////////////////////////////////////////////////////////////////////////////////
// vmodGameTeamGladiator
////////////////////////////////////////////////////////////////////////////////
class vmodGameTeamGladiator extends vmodGameInfoRoundBased;

////////////////////////////////////////////////////////////////////////////////
//  PostBeginPlay
////////////////////////////////////////////////////////////////////////////////
function PostBeginPlay()
{
    Super.PostBeginPlay();
}

////////////////////////////////////////////////////////////////////////////////
//  ClearLevelItems
////////////////////////////////////////////////////////////////////////////////
function ClearLevelItems()
{
    local Inventory A;
    local Carcass C;
    
    foreach AllActors(class 'Inventory', A)
    {
        if(A.Owner == None)
            A.Destroy();
    }
    
    foreach AllActors(class 'Carcass', C)
    {
        C.Destroy();
    }
}

////////////////////////////////////////////////////////////////////////////////
//  STATE: StartingRound
//
//  The game already begun, and the next round is about to begin.
////////////////////////////////////////////////////////////////////////////////
state StartingRound
{
    function BeginState()
    {
        local Pawn P;
        
        GameDisableScoreTracking();
        GameDisablePawnDamage();
        ResetTimerLocalRound();
        NativeLevelCleanup();
        
        // Notify all players about StartingRound
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            RestartPlayer(P);
            ClearPlayerInventory(P);
            GivePlayerWeapon(P, class'RuneI.VikingShortSword');
            GivePlayerWeapon(P, class'RuneI.VikingAxe');
            GivePlayerWeapon(P, class'RuneI.DwarfBattleSword');
            PlayerGameStateNotification(P);
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
//  STATE: Live
//
//  In round-based play, "Live" means that the current round is in live action.
////////////////////////////////////////////////////////////////////////////////
state Live
{
    ////////////////////////////////////////////////////////////////////////////
    //  Killed
    //
    //  PKiller has just killed PDead.
    ////////////////////////////////////////////////////////////////////////////
    function Killed(Pawn PKiller, Pawn PDead, Name DamageType)
    {
        local Pawn P;
        local int PlayersAliveCount;
        
        if(vmodRunePlayer(PDead) != None)
        {
            Super.Killed(PKiller, PDead, DamageType);
            
            //vmodRunePlayer(PDead).bCanRestart = false;
            // TODO: Go spectator mode here
            
            // Round end condition
            PlayersAliveCount = 0;
            for(P = Level.PawnList; P != None; P = P.NextPawn)
            {
                if(vmodRunePlayer(P) == None)
                    continue;
                
                if(vmodRunePlayer(P).Health > 0)
                {
                    PlayersAliveCount++;
                    if(PlayersAliveCount >= 2)
                        break;
                }
            }
            if(PlayersAliveCount == 1)
                GotoStatePostRound();
            
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
defaultproperties
{
     GameName="[Vmod] Team Gladiator"
}