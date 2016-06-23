////////////////////////////////////////////////////////////////////////////////
// vmodTeamGladiator
////////////////////////////////////////////////////////////////////////////////
class vmodTeamGladiator extends vmodGameInfoRoundBased;

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

defaultproperties
{
     bChangeLevels=True
     bHardCoreMode=True
     GlobalNameChange=" changed name to "
     NoNameChange=" is already in use"
     TimeMessage(0)="5 minutes left in the game!"
     TimeMessage(1)="4 minutes left in the game!"
     TimeMessage(2)="3 minutes left in the game!"
     TimeMessage(3)="2 minutes left in the game!"
     TimeMessage(4)="1 minute left in the game!"
     TimeMessage(5)="30 seconds left!"
     TimeMessage(6)="10 seconds left!"
     TimeMessage(7)="5 seconds and counting..."
     TimeMessage(8)="4..."
     TimeMessage(9)="3..."
     TimeMessage(10)="2..."
     TimeMessage(11)="1..."
     TimeMessage(12)="Time Up!"
     FirstBloodMsg="drew FIRST BLOOD"
     SpreeMsg="in a row for"
     SpreeEndMsg="stopped"
     SpreeEndTrailer="'s killing spree."
     HeadKillMsg=" took a trophy."
     CrushedMessage=" was crushed."
     DrownedMessage="%o got a mouthful."
     FellMessage=" suffered deceleration trauma."
     ThrownMessage="%o got skewered by %k."
     NormalMessage="%o was whacked up by %k."
     FireMessage="%o got smoked by %k."
     HeadMessage="%o died by %k's blade."
     SuicidedMessage=" died."
     bRestartLevel=False
     bPauseable=False
     bDeathMatch=True
     DefaultWeapon=Class'RuneI.Handaxe'
     ScoreBoardType=Class'RuneI.RuneScoreboard'
     RulesMenuType="RMenu.RuneMenuRulesScrollClient"
     SettingsMenuType="RMenu.RuneMenuSettingsScrollClient"
     MutatorMenuType="RMenu.RuneMenuMutatorScrollClient"
     MaplistMenuType="RMenu.RuneMenuMaplistScrollClient"
     GameUMenuType="RMenu.RuneMenu"
     MultiplayerUMenuType="RMenu.RuneMenuMultiplayerTop"
     GameOptionsMenuType="RMenu.RuneMenuOptionsTop"
     MapListType=Class'RuneI.DMmaplist'
     MapPrefix="DM"
     BeaconName="DM"
     GameName="[Vmod] Team Gladiator"
}