////////////////////////////////////////////////////////////////////////////////
// vmodGameGladiator
////////////////////////////////////////////////////////////////////////////////
class vmodGameGladiator extends vmodGameInfoRoundBased;

////////////////////////////////////////////////////////////////////////////////
//  RandomizePlayerInventory
////////////////////////////////////////////////////////////////////////////////
function RandomizePlayerInventory(Pawn P)
{
    local Class<Weapon> WeaponClasses[15];
    
    // Tier 1 weapons
    WeaponClasses[0] = Class'RuneI.DwarfBattleAxe';
    WeaponClasses[1] = Class'RuneI.DwarfBattleSword';
    WeaponClasses[2] = Class'RuneI.DwarfBattleHammer';
    WeaponClasses[3] = Class'RuneI.VikingBroadSword';
    WeaponClasses[4] = Class'RuneI.DwarfWorkSword';
    
    // Tier 2 weapons
    WeaponClasses[5] = Class'RuneI.DwarfWorkHammer';
    WeaponClasses[6] = Class'RuneI.SigurdAxe';
    WeaponClasses[7] = Class'RuneI.VikingAxe';
    WeaponClasses[8] = Class'RuneI.GoblinAxe';
    WeaponClasses[9] = Class'RuneI.TrialPitMace';
    
    // Tier 3 weapons
    WeaponClasses[10] = Class'RuneI.RomanSword';
    WeaponClasses[11] = Class'RuneI.VikingShortSword';
    WeaponClasses[12] = Class'RuneI.BoneClub';
    WeaponClasses[13] = Class'RuneI.RustyMace';
    WeaponClasses[14] = Class'RuneI.Handaxe';
    
    ClearPlayerInventory(P);
    GivePlayerWeapon(P, WeaponClasses[(0 + Rand(4))]); // Random tier 1
    GivePlayerWeapon(P, WeaponClasses[(5 + Rand(4))]); // Random tier 2
    GivePlayerWeapon(P, WeaponClasses[(10 + Rand(4))]); // Random tier 3
}

////////////////////////////////////////////////////////////////////////////////
//  STATE: PreGame
////////////////////////////////////////////////////////////////////////////////
state PreGame
{
    function BeginState()
    {
        Super.BeginState();
        ClearLevelItems();
    }
}

////////////////////////////////////////////////////////////////////////////////
//  STATE: PreRound
////////////////////////////////////////////////////////////////////////////////
state PreRound
{
    // TODO: This is a hack to disable player respawning
    function bool RestartPlayer( pawn aPlayer )	{}
}

////////////////////////////////////////////////////////////////////////////////
//  STATE: StartingRound
////////////////////////////////////////////////////////////////////////////////
state StartingRound
{
    // Cannot restart players while starting round
    function bool RestartPlayer( pawn aPlayer )	{}
    
    function BeginState()
    {
        local Pawn P;
        
        // Reset round timer
        ResetTimerLocalRound();
        
        // Apply state options
        GameDisableScoreTracking();
        GameDisablePawnDamage();
        
        // Return level to its original state
        NativeLevelCleanup();
        
        // Update game replication info
        GRISetGameTimer(0);
        
        // Notify all players about StartingRound
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            Global.RestartPlayer(P);
            RandomizePlayerInventory(P);
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
    // Cannot restart players while live
    function bool RestartPlayer( pawn aPlayer )	{}
    
    function BeginState()
    {
        local Pawn P;
        local int PlayersAliveCount;
        
        GameEnableScoreTracking();
        GameEnablePawnDamage();
        
        // Notify all players that the round is Live
        PlayersAliveCount = 0;
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            if(vmodRunePlayer(P) != None)
            {
                PlayerGameStateNotification(P);
                if(vmodRunePlayer(P).Health > 0)
                    PlayersAliveCount++;
            }
        }
        
        // Something silly may have happened in the preround, like players
        // suiciding.
        if(PlayersAliveCount <= 1)
            GotoStatePostRound();
        
        GRISetGameTimer(0);
    }
    
    ////////////////////////////////////////////////////////////////////////////
    //  Killed
    //
    //  PKiller has just killed PDead.
    ////////////////////////////////////////////////////////////////////////////
    function Killed(Pawn PKiller, Pawn PDead, Name DamageType)
    {
        local Pawn P;
        local int PlayersAliveCount;
        
        Super.Killed(PKiller, PDead, DamageType);
        
        // Round end condition
        PlayersAliveCount = 0;
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
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

////////////////////////////////////////////////////////////////////////////////
//  STATE: PostRound
////////////////////////////////////////////////////////////////////////////////
state PostRound
{
    // Cannot restart players while postround
    function bool RestartPlayer( pawn aPlayer )	{}
    
    function BeginState()
    {
        local Pawn P;
        local Pawn PWinner;
        
        GameDisableScoreTracking();
        GameDisablePawnDamage();
        ResetTimerLocalRound();
        
        // Notify all players about PostRound and determine winner
        for(P = Level.PawnList; P != None; P = P.NextPawn)
        {
            if(vmodRunePlayer(P) != None)
            {
                PlayerGameStateNotification(P);
                if(vmodRunePlayer(P).Health > 0)
                    PWinner = P;
            }
        }
        
        // Round limit reached?
        if(RoundLimit > 0)
        {
            if(RoundNumber >= RoundLimit)
            {
                EndGameReason="Round Limit Reached";
                GotoStatePostGame();
                return;
            }
        }
        
        GRISetGameTimer(0);
    }
}

////////////////////////////////////////////////////////////////////////////////
defaultproperties
{
     GameName="[Vmod] Gladiator"
}