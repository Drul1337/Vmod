class vmodQGunBase extends DwarfBattleAxe;

defaultproperties
{
	A_Idle=H5_Idle
    A_Forward=walkforwardTwohands
    A_Backward=H5_Backup
    A_Forward45Right=H5_Walk45Right
    A_Forward45Left=H5_Walk45Left
    A_Backward45Right=H5_BackupRight
    A_Backward45Left=H5_BackupLeft
    A_StrafeRight=H5_StrafeRight
    A_StrafeLeft=H5_StrafeLeft
    A_Jump=H5_Jump
	
	A_AttackA=T_Standingattack
    A_AttackAReturn=None
    A_AttackB=None
    A_AttackBReturn=None
	A_AttackC=None
    A_AttackCReturn=None
    A_AttackStandA=T_Standingattack
    A_AttackStandAReturn=None
	A_AttackStandB=None
    A_AttackStandBReturn=None
    A_AttackBackupA=T_Standingattack
    A_AttackBackupAReturn=None
    A_AttackStrafeRight=T_Standingattack
    A_AttackStrafeLeft=T_Standingattack
	A_JumpAttack=T_Standingattack
	 
    A_Throw=H5_Throw
    A_Powerup=H5_Powerup
    A_Defend=None
    A_DefendIdle=None
    A_PainFront=H5_painFront
    A_PainBack=H5_painFront
    A_PainLeft=H5_painFront
    A_PainRight=H5_painFront
    A_PickupGroundLeft=H5_PickupLeft
    A_PickupHighLeft=H5_PickupLeftHigh
    A_Taunt=x5_taunt
    A_PumpTrigger=H5_PumpTrigger
    A_LeverTrigger=H5_LeverTrigger
}