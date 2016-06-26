//=============================================================================
// VikingBroadSword.
//=============================================================================
class vmodVikingBroadSword expands sword;

var WeaponSwipe MyNewSwipe;

replication
{
    //// Server --> Client
	//reliable if (Role == ROLE_Authority)
	//	MyNewSwipe;
	
    // Server --> Client
	reliable if (Role == ROLE_Authority)
		NewEnableSwipeTrail, NewDisableSwipeTrail;
}

simulated function SpawnPowerupEffect()
{
	local EffectSkeleton ES;

	// Spawn an EffectSkeleton that will display all powered up effects
	ES = Spawn(class'EffectSkelVampire', self);
	if (ES != None)
	{
		AttachActorToJoint(ES, 0);
	}
}

simulated function RemovePowerupEffect()
{
	local actor A;
	// Remove Effect skeleton
	A = DetachActorFromJoint(0);
	A.Destroy();
}

//=============================================================================
//
// Powerup: Vampiric
//
//=============================================================================

function int CalculateDamage(actor Victim)
{
	local int i;
	local VampireTrail vamp;
	local rotator r;
	local int dam;
	local int actualDam;

	dam = Super.CalculateDamage(Victim);

	if(Pawn(Victim)!=None && Pawn(Victim).Health < dam)
		actualDam = Pawn(Victim).Health;
	else
		actualDam = dam;

	if (ScriptPawn(Victim)!=None && ScriptPawn(Victim).bIsBoss)
		return dam;

	if(bPoweredUp && Victim.IsA('Pawn') && actualDam > 0)
	{
		for(i = 0; i < 5; i++)
		{
			vamp = Spawn(Class'VampireTrail',owner,, Victim.Location, Owner.Rotation);
			r = rotator(Victim.Location - Owner.Location);
			r.Yaw += -12000 + 4800 * i + (FRand() - 0.5) * 1000;
			vamp.Velocity = (350 + 100 * FRand()) * vector(r);
			vamp.Velocity.Z += 150 + 100 * FRand();

			r = rotator(vamp.Velocity);				
			
			// Compute acceleration for a smooth arch
			if(i < 2)
			{
				r.Yaw -= 8000 + FRand() * 2000;
			}
			else if(i > 2)
			{
				r.Yaw += 8000 + FRand() * 2000;
			}
			
			vamp.Acceleration = vector(r) * 1000;
			vamp.VampireDest = Pawn(Owner);
			vamp.HealthBoost = dam / 5;
			SetRotation(rotator(vamp.Velocity));
		}
	}

	return(dam);
}

function EnableSwipeTrail()
{
	//SwipeClass = class'vmod.vmodWeaponSwipeVamp';
	//if(SwipeClass != None)
	//if(MyNewSwipe == None)
	//	MyNewSwipe = Spawn(SwipeClass, self,, Location);
	//
	//if(MyNewSwipe != None)
	//{
	//	//MyNewSwipe.RemoteRole=ROLE_None;
	//	MyNewSwipe.BaseJointIndex = SweepJoint1;
	//	MyNewSwipe.OffsetJointIndex = SweepJoint2;
	//	MyNewSwipe.SystemLifeSpan = -1;	
	//	MyNewSwipe.SetBase(self.Owner);
	//}
	NewEnableSwipeTrail();
}

simulated function NewEnableSwipeTrail()
{
	if(MyNewSwipe == None)
		MyNewSwipe = Spawn(SwipeClass, self,, Location);
	
	if(MyNewSwipe != None)
	{
		//MyNewSwipe.RemoteRole=ROLE_None;
		MyNewSwipe.BaseJointIndex = SweepJoint1;
		MyNewSwipe.OffsetJointIndex = SweepJoint2;
		MyNewSwipe.SystemLifeSpan = -1;	
		MyNewSwipe.SetBase(self.Owner);
	}
}

function DisableSwipeTrail()
{
	NewDisableSwipeTrail();
}

simulated function NewDisableSwipeTrail()
{
	if(Swipe != None)
	{
		Swipe.SystemLifeSpan = 3.0;
		Swipe.SetBase(None);
		Swipe = None;
	}
}

state Swinging
{
	event FrameSwept(vector B1, vector E1, vector B2, vector E2)
	{
		local int LowMask,HighMask;
		local vector HitLoc, HitNorm, NewPos1, NewPos2;
		local vector Momentum;
		local actor A;
		
		// Update the weapon swipes here
		//if(MyNewSwipe != None)
		//{
		//	MyNewSwipe.CreateSwipeParticle(0.0, B1, E1, B2, E2);
		//}
		
		// Now sweep these frame-rate independent coordinates
		Momentum = (E2 - E1) * Mass;
		foreach SweepActors(class'actor', A,
			B1, E1, B2, E2, WeaponSweepExtent, HitLoc, HitNorm, LowMask, HighMask)
		{
			if(SwipeArrayCheck(A, LowMask, HighMask))
			{ // First time hitting this actor and/or joint
				if(!DoWeaponSwipe(A, LowMask, HighMask, HitLoc, HitNorm, Momentum))
				{ // Hit something that should stop the attack
				}
				SpawnHitEffect(HitLoc, HitNorm, LowMask, HighMask, A);
			}
		}

		gB1 = B1;
		gE1 = E1;
		gB2 = B2;
		gE2 = E2;
	}
}

defaultproperties
{
	SwipeClass=Class'vmod.vmodWeaponSwipeVamp'
	
     StowMesh=1
     Damage=20
     BloodTexture=Texture'weapons.broadswordv_broadblood'
     rating=2
     SweepJoint2=6
     RunePowerRequired=50
     RunePowerDuration=15.000000
     PowerupMessage="Vampiric Attack!"
     StabMesh=2
     ThroughAir(0)=Sound'WeaponsSnd.Swings.swing15'
     ThroughAirBerserk(0)=Sound'WeaponsSnd.Swings.bswing03'
     HitFlesh(0)=Sound'WeaponsSnd.ImpFlesh.impfleshsword07'
     HitWood(0)=Sound'WeaponsSnd.ImpWood.impactwood15'
     HitStone(0)=Sound'WeaponsSnd.ImpStone.impactstone07'
     HitMetal(0)=Sound'WeaponsSnd.ImpMetal.impactmetal17'
     HitDirt(0)=Sound'WeaponsSnd.ImpEarth.impactearth03'
     HitShield=Sound'WeaponsSnd.Shields.shield03'
     HitWeapon=Sound'WeaponsSnd.Swords.sword03'
     HitBreakableWood=Sound'WeaponsSnd.ImpWood.impactwood12'
     HitBreakableStone=Sound'WeaponsSnd.ImpStone.impactstone11'
     SheathSound=Sound'WeaponsSnd.Stows.xstow03'
     UnsheathSound=Sound'WeaponsSnd.Stows.xunstow03'
     PowerUpSound=Sound'WeaponsSnd.PowerUps.powerstart41'
     PoweredUpSoundLOOP=Sound'WeaponsSnd.PowerUps.power33L'
     PitchDeviation=0.080000
     PowerupIcon=Texture'RuneFX2.bsword'
     PowerupIconAnim=Texture'RuneFX2.bsword1a'
     PoweredUpSwipeClass=Class'RuneI.WeaponSwipeVamp'
     A_Idle=S3_idle
     A_Forward=S3_Walk
     A_Backward=S3_Backup
     A_Forward45Right=S3_Walk45Right
     A_Forward45Left=S3_Walk45Left
     A_Backward45Right=S3_Backup45Right
     A_Backward45Left=S3_Backup45Left
     A_StrafeRight=S3_StrafeRight
     A_StrafeLeft=S3_StrafeLeft
     A_Jump=S3_Jump
     A_Idle=X1_Idle
     A_AttackA=H2_attackA
     A_AttackAReturn=H2_attackAreturn
     A_AttackB=H2_attackB
     A_AttackBReturn=H2_attackBreturn
     A_AttackC=H2_attackC
     A_AttackCReturn=H2_attackCreturn
     A_AttackStandA=H2_StandingAttackA
     A_AttackStandAReturn=H2_StandingAttackAReturn
     A_AttackStandB=H2_StandingAttackB
     A_AttackStandBReturn=H2_StandingAttackBReturn
     A_AttackBackupA=H2_BackupAttackA
     A_AttackBackupAReturn=H2_BackupAttackAreturn
     A_AttackBackupB=H2_BackupAttackB
     A_Powerup=S3_Powerup
     A_Defend=S3_DefendTO
     A_DefendIdle=S3_Defendidle
     A_PainFront=S3_painFront
     A_PainBack=S3_painBack
     A_PainLeft=S3_painLeft
     A_PainRight=S3_painRight
     A_PickupGroundLeft=S3_PickupLeft
     A_PickupHighLeft=S3_PickupLeftHigh
     A_PumpTrigger=S3_PumpTrigger
     A_LeverTrigger=S3_LeverTrigger
     PickupMessage="You are armed with a Viking BroadSword"
     PickupSound=Sound'OtherSnd.Pickups.grab03'
     DropSound=Sound'WeaponsSnd.Drops.sworddrop03'
     Mass=14.000000
     Skeletal=SkelModel'weapons.broadsword'
     SkelGroupSkins(0)=Texture'weapons.broadswordv_broad'
     SkelGroupSkins(1)=Texture'weapons.broadswordv_broad'
}
