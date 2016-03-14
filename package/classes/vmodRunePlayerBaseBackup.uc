///////////////////////////////////////////////////////////////////////////////
// vmodRunePlayerBase.uc
//
//		|---Object
//			|---Actor
//				|---Pawn
//					|---PlayerPawn
//						|---vmodPlayerPawnBase
//							|---vmodPlayerPawnInterface
//								|---vmodRunePlayerBase
//
class vmodRunePlayerBaseBackup extends vmodPlayerPawnInterface config(user) abstract;


// Constants
const ZTARGET_DIST = 600;

// RUNE vars
var() float CrouchHeight;		// RUNE: Crouching

var pawn ZTarget;
var ZTargetDecal ZTargetDecal;

// Debug!
var vector DropZFloor;
var vector DropZRag;
var vector DropZResult;
var vector DropZRoll;

var rotator velRot;
var rotator ragnarRot;
var rotator pelvisRot;
var rotator baseRot;

// Scripting support
var actor	NextPoint;		// For queueing OrderObject (NextState, NextLabel)
var int		SpeechPos;		// Position within controls for speech
var int		DispatchAction;	// Index of current action of ScriptDispatcher
var actor	OrderObject;	// Object containing current script orders
var bool	bScriptMoving;	// Call PlayMoving() to update move anim

// Sounds
var(Sounds) sound breathagain;
var(Sounds) sound Die4;
var(Sounds) sound GaspSound;
var(Sounds) sound UnderWaterHitSound[3];
var(Sounds) sound PowerupFail;
var(Sounds) sound WeaponPickupSound;
var(Sounds) sound WeaponThrowSound;
var(Sounds) sound WeaponDropSound;
var(Sounds) sound JumpGruntSound[3];
var(Sounds) sound FallingDeathSound;
var(Sounds) sound FallingScreamSound;
var(Sounds) sound UnderWaterDeathSound;
var(Sounds) sound EdgeGrabSound;
var(Sounds) sound StepupSound;
var(Sounds) sound KickSound;
var(Sounds) sound HitSoundLow[3];
var(Sounds) sound HitSoundMed[3];
var(Sounds) sound HitSoundHigh[3];
var(Sounds) sound UnderwaterAmbient[6];
var(Sounds) sound BerserkSoundStart;
var(Sounds) sound BerserkSoundEnd;
var(Sounds) sound BerserkSoundLoop;
var(Sounds) sound BerserkYellSound[6];
var(Sounds)	sound CrouchSound;

var Weapon LastHeldWeapon;

var bool bSurfaceSwimming;
var float GrabLocationDist; // RUNE:  Used in edge grab code 


///////////////////////////////////////////////////////////////////////////////
//
//	REPLICATION BLOCK
//
///////////////////////////////////////////////////////////////////////////////
replication
{
	// Server --> Client
	unreliable if(bNetOwner && Role == ROLE_Authority)
		ZTarget,
		CrouchHeight;
}






///////////////////////////////////////////////////////////////////////////////
//
//	ACTOR OVERRIDES
//
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// (Actor) PreBeginPlay
///////////////////////////////////////////////////////////////////////////////
event PreBeginPlay()
{
	Super(vmodPlayerPawnBase).PreBeginPlay();

	// Adjust CrouchHeight to new DrawScale
	CrouchHeight = CrouchHeight * DrawScale;		
}

///////////////////////////////////////////////////////////////////////////////
// (Actor) FrameNotify
///////////////////////////////////////////////////////////////////////////////
event FrameNotify(int framepassed)
{
	// TODO: This is how the weapon receives frame notify events
	// Right now the animation proxy calls this, and this calls the weapon
	// When we get rid of anim proxy stuff, we need to turn on bFrameNotifies
	if(Weapon != None)
		Weapon.FrameNotify(framepassed);
}


//=============================================================================
// (Actor) BodyPartForJoint
//
// Returns the body part a joint is associated with
//=============================================================================
function int BodyPartForJoint(int joint)
{
	switch(joint)
	{
		case 24:			return BODYPART_LARM1;
		case 31:			return BODYPART_RARM1;
		case 6:  case 7:	return BODYPART_RLEG1;
		case 2:  case 3:	return BODYPART_LLEG1;
		case 17:			return BODYPART_HEAD;
		case 11:			return BODYPART_TORSO;
		default:			return BODYPART_BODY;
	}
}




//=============================================================================
//
// OVERRIDDEN PAWN FUNCTIONS
//
//=============================================================================


//=============================================================================
// (Pawn) BodyPartForPolyGroup
//=============================================================================
function int BodyPartForPolyGroup(int polygroup)
{
	return BODYPART_BODY;
}

//=============================================================================
// (Pawn) BodyPartSeverable
//=============================================================================
function bool BodyPartSeverable(int BodyPart)
{
	switch(BodyPart)
	{
		case BODYPART_HEAD:
			return true;
		case BODYPART_LARM1:
		case BODYPART_RARM1:
			if(Level.Game != None)
				return (Level.NetMode != NM_StandAlone && Level.Game.bAllowLimbSever);
			else
				return (Level.NetMode != NM_StandAlone);
	}
	return false;
}

//=============================================================================
// (Pawn) SeveredLimbClass
//=============================================================================
function class<Actor> SeveredLimbClass(int BodyPart)
{
	return None;
}

//=============================================================================
// (Pawn) LimbSevered
//=============================================================================
function LimbSevered(int BodyPart, vector Momentum)
{
	local int joint;
	local actor part;
	local vector X,Y,Z,pos;
	local class<actor> partclass;

	partclass = SeveredLimbClass(BodyPart);

	switch(BodyPart)
	{
		case BODYPART_LARM1:
			DropShield();
			joint = JointNamed('lshouldb');
			pos = GetJointPos(joint);
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, pos, Rotation);
			if(part != None)
			{
				part.DrawScale = 1.0; // Necessary to scale down SarkArms
				part.Velocity = -Y * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			part = Spawn(class'BloodSpurt', self,, pos, Rotation);
			if(part != None)
			{
				AttachActorToJoint(part, joint);
			}
			break;
	
		case BODYPART_RARM1:
			LastHeldWeapon = None; // No retrieving
			DropWeapon();
			joint = JointNamed('rshouldb');
			pos = GetJointPos(joint);
			GetAxes(Rotation, X, Y, Z);
			part = Spawn(partclass,,, pos, Rotation);
			if(part != None)
			{
				part.DrawScale = 1.0; // Necessary to scale down SarkArms
				part.Velocity = Y * 100 + vect(0, 0, 175);
				part.GotoState('Drop');
			}
			part = Spawn(class'BloodSpurt', self,, pos, Rotation);
			if(part != None)
			{
				AttachActorToJoint(part, joint);
			}
			break;
		case BODYPART_HEAD:
			joint = JointNamed('head');
			pos = GetJointPos(joint);
			part = Spawn(partclass,,, pos, Rotation);
			if(part != None)
			{
				part.Velocity = 0.75 * (momentum / Mass) + vect(0, 0, 300);
				part.GotoState('Drop');
			}
			part = Spawn(class'BloodSpurt', self,, pos, Rotation);
			if(part != None)
			{
				AttachActorToJoint(part, joint);
			}
			break;
	}
}

//=============================================================================
// (Pawn) DamageBodyPart
//=============================================================================
function bool DamageBodyPart(
	int Damage,
	Pawn EventInstigator,
	vector HitLocation,
	vector Momentum,
	name DamageType,
	int bodypart)
{
	return(Super.DamageBodyPart(
					Damage,
					EventInstigator,
					HitLocation,
					Momentum,
					DamageType,
					bodyPart));
}




//=============================================================================
//
// VMODRUNEPLAYER
//
//=============================================================================





//=============================================================================
//
// Animation Functions
//
//=============================================================================

//=============================================================================
// (Pawn) PlayJumping
//=============================================================================
function PlayJumping(optional float tween)
{
	PlayAnim('MOV_ALL_jump1_AA0S', 1.0, 0.1);
    
	// Play Jump Grunt Sound
	PlaySound(
		JumpGruntSound[Rand(3)],
		SLOT_Talk,
		1.0,
		false,
		1200,
		FRand() * 0.08 + 0.96);
}

//=============================================================================
// (Pawn) PlayTakeHit
//=============================================================================
function PlayTakeHit(
	float tweentime,
	int damage,
	vector HitLoc,
	name damageType,
	vector Momentum,
	int BodyPart)
{
	local float time;

	time = 0.15 + 0.005 * Damage;
	ShakeView(time, Damage * 10, time * 0.5);

	Super.PlayTakeHit(tweentime, damage, HitLoc, damageType, Momentum, BodyPart);
}

//=============================================================================
// (Pawn) PlayFrontHit
//=============================================================================
function PlayFrontHit(optional float tweentime)
{
	PlayAnim('n_painFront', 1.0, 0.1);
}

//=============================================================================
// (Pawn) PlayBackHit
//=============================================================================
function PlayBackHit(float tweentime)
{
	PlayAnim('n_painBack', 1.0, 0.1);
}

//=============================================================================
// PlayGutHit
//=============================================================================
function PlayGutHit(float tweentime)
{
	PlayBackHit(tweentime);
}

//=============================================================================
// (Pawn) PlayHeadHit
//=============================================================================
function PlayHeadHit(float tweentime)
{
	PlayFrontHit(tweentime);
}

//=============================================================================
// (Pawn) PlayLeftHit
//=============================================================================
function PlayLeftHit(float tweentime)
{
	PlayAnim('s1_painLeft', 1.0, 0.08);
}

//=============================================================================
// (Pawn) PlayRightHit
//=============================================================================
function PlayRightHit(float tweentime)
{
	PlayAnim('s1_painRight', 1.0, 0.08);
}

//=============================================================================
// (Pawn) PlayDrowning
//=============================================================================
function PlayDrowning(float tweentime)
{
	local int joint;
	local vector l;
	local name anim;

	if(HeadRegion.Zone.bWaterZone)
	{
		// Spawn Bubbles
		joint = JointNamed('jaw');
		l = GetJointPos(joint);
		if(FRand() < 0.75)
		{
			Spawn(class'BubbleSystemOneShot',,, l,);
		}
	}

	if(AnimSequence == 'SwimUnderWaterDown')
	{ // This anim sequence doesn't have a pain animation
		return;
	}

	if(	AnimSequence == 'Treadwateridle' ||
		AnimSequence == 'Swimbackwards' ||
		AnimSequence == 'Swimbackwards45Left' ||
		AnimSequence == 'Swimbackwards45Right' ||
		AnimSequence == 'SwimUnderWaterUp')
	{
		anim = 'treadpain'; // Treading in water pain
	}
	else
		anim = 'swimpain'; // normal swimming pain

	//if(AnimProxy != None)
	//	AnimProxy.PlayAnim(anim, 1.0, 0.1);
	PlayAnim(anim, 1.0, 0.1);
}

//=============================================================================
// (Pawn) PlayDeath
//=============================================================================
function PlayDeath(name DamageType)
{
	local name anim;
	local float tween;

	tween = 0.1;

	if(DamageType == 'fire')
		anim = 'DeathF';
	else if(DamageType == 'fell')
	{
		anim = 'DeathImpact';
	}
	else
	{ // Normal death, randomly choose one
		anim = 'DTH_ALL_death1_AN0N';

		switch(RandRange(0, 5))
		{
		case 0:
			anim = 'DTH_ALL_death1_AN0N';
			break;
		case 1:
			anim = 'DeathH';
			break;
		case 2:
			anim = 'DeathL';
			break;
		case 3:
			anim = 'DeathB';
			break;
		case 4:
			anim = 'DeathKnockback';
			break;
		default:
			anim = 'DTH_ALL_death1_AN0N';
			break;
		}
	}

	PlayAnim(anim, 1.0, tween);
	//if(AnimProxy != None)
	//	AnimProxy.PlayAnim(anim, 1.0, tween);
}

function PlayBackDeath(name DamageType)		{ PlayDeath(DamageType); }
function PlayLeftDeath(name DamageType)		{ PlayDeath(DamageType); }
function PlayRightDeath(name DamageType)	{ PlayDeath(DamageType); }
function PlayHeadDeath(name DamageType)		{ PlayDeath(DamageType); }
function PlayDrownDeath(name DamageType)	{ PlayDeath(DamageType); }

//=============================================================================
// (Pawn) PlayGibDeath
//=============================================================================
function PlayGibDeath(name DamageType)
{
	if (bIsPlayer)
		bHidden=true;
	else
		Destroy();
	SpawnBodyGibs(Velocity);
}

//=============================================================================
// (Pawn) PlaySkewerDeath
//=============================================================================
function PlaySkewerDeath(name DamageType)	  
{
	PlayAnim('deathb', 1.0, 0.1);	
	//if(AnimProxy != None)
	//	AnimProxy.PlayAnim('deathb', 1.0, 0.1);	
}

//=============================================================================
// (PlayerPawn) PlayFiring
//=============================================================================
function PlayFiring()
{
	GotoState('Attacking');
	//if(AnimProxy != None)
	//	AnimProxy.Attack();
	// TODO: This is where we get the weapon's attack animation
	//f(Weapon != None)
	//
	//	WeaponActivate();
	//	Weapon.PlaySwipeSound();
	//	PlayAnim(Weapon.A_AttackA, 1.0, 0.1);
	//	Weapon.WeaponFire(0);
	//	FinishAnim();
	//	WeaponDeactivate();
	//	
	//	//gotostate('Attacking');
	//

	//if(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y >= 1000)
	//	PlayMoving();
}

//=============================================================================
// (PlayerPawn) PlayAltFiring 
//=============================================================================
function PlayAltFiring()
{
	//if(GetStateName() == 'PlayerSwimming')
	//	return;
	// TODO: This is where we get the weapon's alt attack animation (defend)
	
	//if(AnimProxy != None)
	//	AnimProxy.Defend();
}

//=============================================================================
// (Pawn) PlayMoving
//=============================================================================
function PlayMoving(optional float tween)
{
	// TODO: This function is a mess, we can clean it up big time
	local name LowerName;
	local int dir;

	// Get the movement direction
	//UpdateMoveDirectionFlags(0.0, 0.0);
	dir = GetMoveDirectionFlags();

	// Set the proper animation based upon the motion
	LowerName = 'MOV_ALL_run1_AA0N';

	if(Weapon == None)
	{
		if(!bIsCrouching)
		{
			switch(dir)
			{
			case MD_FORWARD:		LowerName = 'MOV_ALL_run1_AA0N';		break;
			case MD_FORWARDRIGHT:	LowerName = 'MOV_ALL_rstrafe1_AA0S';	break;
			case MD_FORWARDLEFT:	LowerName = 'MOV_ALL_lstrafe1_AA0S';	break;
			case MD_BACKWARD:		LowerName = 'MOV_ALL_runback1_AA0S';	break;
			case MD_BACKWARDRIGHT:	LowerName = 'MOV_ALL_lstrafe1_AA0S';	break;
			case MD_BACKWARDLEFT:	LowerName = 'MOV_ALL_rstrafe1_AA0S';	break;
			case MD_RIGHT:			LowerName = 'MOV_ALL_rstrafe1_AN0N';	break;
			case MD_LEFT:			LowerName = 'MOV_ALL_lstrafe1_AN0N';	break;
			default: break;
			}
		}
		else
		{
			switch(dir)
			{
			case MD_FORWARD:		LowerName = 'crouch_walkforward';		break;
			case MD_FORWARDRIGHT:	LowerName = 'crouch_walkforward45Right';break;
			case MD_FORWARDLEFT:	LowerName = 'crouch_walkforward45Left';	break;
			case MD_BACKWARD:		LowerName = 'crouch_walkbackward';		break;
			case MD_BACKWARDRIGHT:	LowerName = 'crouch_walkbackward45Right';break;
			case MD_BACKWARDLEFT:	LowerName = 'crouch_walkbackward45Left';break;
			case MD_RIGHT:			LowerName = 'crouch_straferight';		break;
			case MD_LEFT:			LowerName = 'crouch_strafeleft';		break;
			default: break;
			}
		}
	}
	else
	{
		if(!bIsCrouching)
		{
			switch(dir)
			{
			case MD_FORWARD:		LowerName = Weapon.A_Forward;			break;
			case MD_FORWARDRIGHT:	LowerName = Weapon.A_Forward45Right;	break;
			case MD_FORWARDLEFT:	LowerName = Weapon.A_Forward45Left;		break;
			case MD_BACKWARD:		LowerName = Weapon.A_Backward;			break;
			case MD_BACKWARDRIGHT:	LowerName = Weapon.A_Backward45Right;	break;
			case MD_BACKWARDLEFT:	LowerName = Weapon.A_Backward45Left;	break;
			case MD_RIGHT:			LowerName = Weapon.A_StrafeRight;		break;
			case MD_LEFT:			LowerName = Weapon.A_StrafeLeft;		break;
			default: break;
			}
		}
		else
		{
			switch(dir)
			{
			case MD_FORWARD:
				if(Weapon.bCrouchTwoHands)	LowerName = 'crouch_walkforward2hands';
				else						LowerName = 'crouch_walkforward';
				break;
			case MD_FORWARDRIGHT:
				if(Weapon.bCrouchTwoHands)	LowerName = 'crouch_walkforward45Right2hands';
				else						LowerName = 'crouch_walkforward45Right';
				break;
			case MD_FORWARDLEFT:
				if(Weapon.bCrouchTwoHands)	LowerName = 'crouch_walkforward45Left2hands';
				else						LowerName = 'crouch_walkforward45Left';
				break;
			case MD_BACKWARD:
				if(Weapon.bCrouchTwoHands)	LowerName = 'crouch_walkbackward2hands';
				else						LowerName = 'crouch_walkbackward';
				break;
			case MD_BACKWARDRIGHT:
				if(Weapon.bCrouchTwoHands)	LowerName = 'crouch_walkbackward45Right2hands';
				else						LowerName = 'crouch_walkbackward45Right';
				break;
			case MD_BACKWARDLEFT:
				if(Weapon.bCrouchTwoHands)	LowerName = 'crouch_walkbackward45Left2hands';
				else						LowerName = 'crouch_walkbackward45Left';
				break;
			case MD_RIGHT:
				if(Weapon.bCrouchTwoHands)	LowerName = 'crouch_straferight2hands';
				else						LowerName = 'crouch_straferight';
				break;
			case MD_LEFT:
				if(Weapon.bCrouchTwoHands)	LowerName = 'crouch_strafeleft2hands';
				else						LowerName = 'crouch_strafeleft';
				break;
			default:
				break;
			}
		}
	}

	LoopAnim(LowerName, 1.0, 0.1);
}

//=============================================================================
// (Pawn) PlayInAir
//=============================================================================
function PlayInAir(optional float tween)
{
	local name anim;
    
	if(Weapon != None && Weapon.A_Jump != '')	anim = Weapon.A_Jump;
	else										anim = 'MOV_ALL_jump1_AA0S';
	
	PlayAnim(anim, 1.0, 0.1);
}

//=============================================================================
// (Pawn) PlayPullUp
//=============================================================================
function PlayPullUp(optional float tween)
{
	PlaySound(EdgeGrabSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.4 + 0.8);
	PlayAnim('intropullupA', 1.0, tween); // No tween
}

//=============================================================================
// (Pawn) PlayStepUp
//=============================================================================
function PlayStepUp(optional float tween)
{
	PlaySound(StepupSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.4 + 0.8);
	PlayAnim('pullupTest', 1.0, tween);
}

//=============================================================================
// (Pawn) PlayDuck
//=============================================================================
function PlayDuck(optional float tween)
{
	local name n;

	if(Weapon == None || !Weapon.bCrouchTwoHands)	n = 'crouch_idle';
	else											n = 'crouch_idle2hands';

	LoopAnim(n, 1.0, 0.1);
}

//=============================================================================
// (Pawn) PlayCrawling
//=============================================================================
function PlayCrawling(optional float tween)
{
	PlayMoving(tween);
}

//=============================================================================
// (Pawn) PlayWaiting
//=============================================================================
function PlayWaiting(optional float tween)
{
	local Name n;

	if(Weapon != None)	n = Weapon.A_Idle;
	else				n = 'neutral_idle';

	LoopAnim(n, 1.0, tween);
}

function TweenToWaiting(float tweentime)	{ PlayWaiting(0.1); }
function TweenToMoving(float tweentime)		{ PlayMoving(); }

//=============================================================================
// (Pawn) PlayLanded
//=============================================================================
function PlayLanded(float impactVel)
{		
	local EMatterType matter;
	local vector end;
	local sound snd;

	impactVel = impactVel/JumpZ;
	impactVel = 0.1 * impactVel * impactVel;
	BaseEyeHeight = Default.BaseEyeHeight;

	if ( Role == ROLE_Authority )
	{
		if(impactVel > 0.15)
			PlaySound(
				LandGrunt,
				SLOT_Talk,
				FMin(5, 5 * impactVel),
				false,
				1200,
				FRand() * 0.08 + 0.96);

		if(impactVel > 0.01)
		{ // Play Land Sound			
			if(FootRegion.Zone.bPainZone)
				matter = MATTER_LAVA;
			else if(FootRegion.Zone.bWaterZone)
				matter = MATTER_WATER;
			else
			{
				end = Location;
				end.Z -= CollisionHeight;
				matter = MatterTrace(end, Location, 10);
			}

			PlayLandSound(matter, impactVel);
		}
	}
	
	if(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y < 1000)
		PlayWaiting(0.2);
	else
		PlayMoving();
}

//=============================================================================
// (PlayerPawn) PlaySwimming
//=============================================================================
function PlaySwimming()
{
	// TODO: Here's another mess, we can clean this up
	local name Anim;
	local float dp;
	local vector dir,X,Y,Z;

	// Recalculate these since they aren't known on clients
	GetAxes(Rotation,X,Y,Z);
	dir = Normal(Acceleration);
	dp = dir dot X;
	bWasForward	= dp >  0.5;
	bWasBack	= dp < -0.5;
	dp = dir dot Y;
	bWasLeft	= dp >  0.3 ;
	bWasRight	= dp < -0.3;

	if(bSurfaceSwimming)	Anim = 'TreadOnWaterIdle';
	else					Anim = 'Treadwateridle';
	
	if(bWasForward)
	{
		if(!bWasLeft && !bWasRight)
		{ // Normal running forwards
			if(bSurfaceSwimming)	Anim = 'SwimOnWater';
			else					Anim = 'SwimUnderWater';
		}
		else if(bWasLeft)
		{ // Strafe right 45
			if(bSurfaceSwimming)
			{
				if (!bMirrored)		Anim = 'Swim45RightOnWater';
				else				Anim = 'Swim45LeftOnWater';
			}
			else
			{
				if (!bMirrored)		Anim = 'SwimUnderWater45Right';
				else				Anim = 'SwimUnderWater45Left';
			}
		}
		else if(bWasRight)
		{ // Strafe left 45
			if(bSurfaceSwimming)
			{
				if (!bMirrored)		Anim = 'Swim45LeftOnWater';
				else				Anim = 'Swim45RightOnWater';
			}
			else
			{
				if (!bMirrored)		Anim = 'SwimUnderWater45Left';
				else				Anim = 'SwimUnderWater45Right';
			}
		}
	}
	else if(bWasBack)
	{
		if(!bWasLeft && !bWasRight)
		{ // Normal running backwards
			if(bSurfaceSwimming)	Anim = 'SwimbackwardsOnWater';
			else					Anim = 'Swimbackwards';
		}
		else if(bWasRight)
		{ // Strafe Left 45
			if(bSurfaceSwimming)
			{
				if (!bMirrored)		Anim = 'TreadOnWaterIdle';
				else				Anim = 'SwimbackwardsRightOnWater';
			}
			else
			{
				if (!bMirrored)		Anim = 'Swimbackwards45Left';
				else				Anim = 'Swimbackwards45Right';
			}
		}
		else if(bWasLeft)
		{ // Strafe right 45
			if(bSurfaceSwimming)
			{
				if (!bMirrored)		Anim = 'SwimbackwardsRightOnWater';
				else				Anim = 'TreadOnWaterIdle';
			}
			else
			{
				if (!bMirrored)		Anim = 'Swimbackwards45Right';
				else				Anim = 'Swimbackwards45Left';
			}
		}
	}
	else if(bWasLeft)
	{ // Strafe right
		if(bSurfaceSwimming)
		{
			if (!bMirrored)			Anim = 'SwimRightOnWater';
			else					Anim = 'SwimLeftOnWater';
		}
		else
		{
			if (!bMirrored)			Anim = 'SwimRight';
			else					Anim = 'SwimLeft';
		}
	}
	else if(bWasRight)
	{ // Strafe left
		if(bSurfaceSwimming)
		{
			if (!bMirrored)			Anim = 'SwimLeftOnWater';
			else					Anim = 'SwimRightOnWater';
		}
		else
		{
			if (!bMirrored)			Anim = 'SwimLeft';
			else					Anim = 'SwimRight';
		}
	}
	else if(Acceleration.Z > 50 && !bSurfaceSwimming)
		Anim = 'SwimUnderWaterUp';
	else if(Acceleration.Z < -50 && !bSurfaceSwimming)
		Anim = 'SwimUnderWaterDown';

	LoopAnim(Anim, 1.0, 0.3);
}

//=============================================================================
// (PlayerPawn) TweenToSwimming
//=============================================================================
function TweenToSwimming(float tweentime)
{
	PlaySwimming();
}


//=============================================================================
//
// Look Functions
//
//=============================================================================

//=============================================================================
// ScoreLookActor
//=============================================================================
simulated function float ScoreLookActor(Actor A)
{
	local float score;
	local rotator r;
	local vector vectA, vectR;
	local float angle;
	
	vectA = A.Location - Location;
	r.Pitch = 0;
	r.Yaw = Rotation.Yaw;
	r.Roll = 0;
	vectR = vector(r);	
	
	angle = (Normal(vectA) dot vectR);
	
	if(angle < PeripheralVision)
	{
		return(9999999.0);
	}
	
	score = VSize(vectA) * (2.0 - angle);

	if(A.IsA('Pawn'))
	{
		score *= 0.5;
	}
	else if(A.IsA('LookTarget'))
	{
		score *= 0.25;
	}
			
	return(score);
}



//=============================================================================
//
// Utility functions
//
//=============================================================================

//=============================================================================
// SetCrouchHeight
//=============================================================================
function SetCrouchHeight()
{
	// TODO: This looks like another area to improve
	// Ideally this shouldnt even be how crouching works
	local vector newloc;
	local float offset;

	SetCollisionSize(CollisionRadius, CrouchHeight);

	// Adjust so player is standing on ground
	offset = default.CollisionHeight - CrouchHeight;
	newloc = Location;
	newloc.Z -= offset;
	SetLocation(newloc);
	PrePivot.Z += offset;
	BaseEyeHeight = (CrouchHeight/Default.CollisionHeight) * Default.BaseEyeHeight;
}

//=============================================================================
// SetNormalHeight
//=============================================================================
function SetNormalHeight()
{
	// TODO: This too, like above
	local vector newloc;
	local float offset;

	SetCollisionSize(CollisionRadius, default.CollisionHeight);

	// Adjust so player is standing on ground
	offset = default.CollisionHeight - CrouchHeight;
	newloc = Location;
	newloc.Z += offset;
	SetLocation(newloc);
	PrePivot.Z += offset;
	BaseEyeHeight = Default.BaseEyeHeight;
}

//=============================================================================
// CanStandUp
//=============================================================================
function bool CanStandUp()
{
	local vector end, extent;
	local vector HitLocation, HitNormal;

	end = Location;
	end.Z += CollisionHeight + CrouchHeight; // Generous fudge factor

	extent.X = CollisionRadius;
	extent.Y = CollisionRadius;
	extent.Z = 8;

	if(Trace(HitLocation, HitNormal, end, Location, true, extent) == None)
	{
		return(true);
	}
	
	return(false);
}

//=============================================================================
// SetCrouch
//=============================================================================
function SetCrouch(bool crouch)
{
	if(crouch)
	{ // Set to explore mode all the time while crouching (with the exception of not rotating the torso)	
		SetCrouchHeight();
		bIsCrouching = true;

		// Play CrouchSound
		PlaySound(CrouchSound, SLOT_Interact, 1.0, false, 1200, FRand() * 0.08 + 0.96);
	}
	else if(bIsCrouching)
	{
		if(CanStandUp())
		{ // Check if standing up is acceptable
			SetNormalHeight();
			bIsCrouching = false;
		}
		else
		{
			bIsCrouching = true;
		}
	}
}



//=============================================================================
// (PlayerPawn) DoJump
//=============================================================================
function DoJump( optional float F )
{	
	if(!bIsCrouching && (Physics == PHYS_Walking))
	{
		if ( Role == ROLE_Authority )
			PlaySound(JumpSound, SLOT_Talk, 1.5, true, 1200, 1.0 );
		if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
			MakeNoise(0.1 * Level.Game.Difficulty);

		PlayJumping();

		Velocity.Z = JumpZ;

		if(Base != None && Base != Level)
		{
			Velocity.Z += Base.Velocity.Z; 
		}

		SetPhysics(PHYS_Falling);

		if(bCountJumps && (Role == ROLE_Authority) && Inventory != None)
		{
			Inventory.OwnerJumped();
		}
	}
}

//=============================================================================
// (Pawn) PawnDamageModifier
//
// Returns the modification of the damage amount 
// Used to increase damage for special attacks, or reduce damage
// for simple attack types
//=============================================================================
function float PawnDamageModifier(Weapon w)
{
	// TODO: Perform a damage modify factor here
	return 1.0;
}




//=============================================================================
//
// Sound Functions
// TODO: Rename these to be a bit more descriptive
//
//=============================================================================

//=============================================================================
// (PlayerPawn) PlayBeepSound
//=============================================================================
simulated function PlayBeepSound()
{
	PlaySound(Sound'MessageBeep',SLOT_Interface, 1.4);
}

//=============================================================================
// (Pawn) PlayDyingSound
//=============================================================================
function PlayDyingSound(name DamageType)
{
	local float rnd;

	if ( HeadRegion.Zone.bWaterZone )
	{
		PlaySound(UnderWaterDeathSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);
		return;
	}

	if(DamageType == 'fell')
	{
		PlaySound(FallingDeathSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);
		return;
	}

	rnd = FRand();
	if (rnd < 0.25)			PlaySound(Die, SLOT_Talk);
	else if (rnd < 0.5)		PlaySound(Die2, SLOT_Talk);
	else if (rnd < 0.75)	PlaySound(Die3, SLOT_Talk);
	else 					PlaySound(Die4, SLOT_Talk);

}

//=============================================================================
// (Pawn) PlayTakeHitSound
//=============================================================================
function PlayTakeHitSound(int damage, name damageType, int Mult)
{
	if ( Level.TimeSeconds - LastPainSound < 0.3 )
		return;
	LastPainSound = Level.TimeSeconds;

	if ( HeadRegion.Zone.bWaterZone )
	{
		if ( damageType == 'Drowned' )
			PlaySound(UnderWaterDeathSound, SLOT_Pain,2.0,,,FRand() * 0.08 + 0.96);
		else
			PlaySound(UnderWaterHitSound[Rand(3)], SLOT_Pain,2.0,,,FRand() * 0.08 + 0.96);
		return;
	}

	if(DamageType == 'fell')
	{
		PlaySound(FallingDeathSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);
		return;
	}

	damage *= FRand();

	if(damage < 8)
		PlaySound(HitSoundLow[Rand(3)], SLOT_Pain, 2.0,,, Frand() * 0.1 + 0.95);
	else if(damage < 25)
		PlaySound(HitSoundMed[Rand(3)], SLOT_Pain, 2.0,,, Frand() * 0.1 + 0.95);
	else
		PlaySound(HitSoundHigh[Rand(3)], SLOT_Pain, 2.0,,, Frand() * 0.1 + 0.95);
}

//=============================================================================
// (Pawn) Gasp
//=============================================================================
function Gasp()
{
	if ( Role != ROLE_Authority )	return;
	if ( PainTime < 2 )				PlaySound(GaspSound, SLOT_Talk, 2.0);
	else							PlaySound(BreathAgain, SLOT_Talk, 2.0);
}



///////////////////////////////////////////////////////////////////////////////
//
//	Inventory functions
//
///////////////////////////////////////////////////////////////////////////////

// TODO: Implement these for the new ragnar skeletal
///////////////////////////////////////////////////////////////////////////////
//	GetJointIndex for attachable joints
///////////////////////////////////////////////////////////////////////////////
// TODO: We can probably reimplement these with constants once the ragnar skeletal is done
// TODO: There is no invalid joint check going on here, could be a source of bugs
function int GetJointIndexAttachHandLeft()
{ return JointNamed('attach_hand'); }

function int GetJointIndexAttachHandRight()
{ return JointNamed('attach_hand'); }

function int GetJointIndexAttachArmLeft()
{ return JointNamed('attach_shielda'); }

function int GetJointIndexAttachBackLeft()
{ return JointNamed('attach_hand'); }

function int GetJointIndexAttachBackRight()
{ return JointNamed('attach_axe'); }

function int GetJointIndexAttachHipLeft()
{ return JointNamed('attach_hammer'); }

function int GetJointIndexAttachHipRight()
{ return JointNamed('attach_sword'); }


///////////////////////////////////////////////////////////////////////////////
//	Attach an actor to an attach joint
///////////////////////////////////////////////////////////////////////////////
function AttachActorToAttachHandLeft(actor A)
{ AttachActorToJoint(A, GetJointIndexAttachHandLeft()); }

function AttachActorToAttachHandRight(actor A)
{ AttachActorToJoint(A, GetJointIndexAttachHandRight()); }

function AttachActorToAttachArmLeft(actor A)
{ AttachActorToJoint(A, GetJointIndexAttachArmLeft()); }

function AttachActorToAttachBackLeft(actor A)
{ AttachActorToJoint(A, GetJointIndexAttachBackLeft()); }

function AttachActorToAttachBackRight(actor A)
{ AttachActorToJoint(A, GetJointIndexAttachBackRight()); }

function AttachActorToAttachHipLeft(actor A)
{ AttachActorToJoint(A, GetJointIndexAttachHipLeft()); }

function AttachActorToAttachHipRight(actor A)
{ AttachActorToJoint(A, GetJointIndexAttachHipRight()); }


///////////////////////////////////////////////////////////////////////////////
//	Detach an actor from an attach joint
///////////////////////////////////////////////////////////////////////////////
function bool DetachActorFromAttachHandLeft(out actor A)
{
	A = ActorAttachedTo(GetJointIndexAttachHandLeft());
	if(A == None) return false; return true;
}

function bool DetachActorFromAttachHandRight(out actor A)
{
	A = ActorAttachedTo(GetJointIndexAttachHandRight());
	if(A == None) return false; return true;
}

function bool DetachActorFromAttachArmLeft(out actor A)
{
	A = ActorAttachedTo(GetJointIndexAttachArmLeft());
	if(A == None) return false; return true;
}

function bool DetachActorFromAttachBackLeft(out actor A)
{
	A = ActorAttachedTo(GetJointIndexAttachBackLeft());
	if(A == None) return false; return true;
}

function bool DetachActorFromAttachBackRight(out actor A)
{
	A = ActorAttachedTo(GetJointIndexAttachBackRight());
	if(A == None) return false; return true;
}

function bool DetachActorFromAttachHipLeft(out actor A)
{
	A = ActorAttachedTo(GetJointIndexAttachHipLeft());
	if(A == None) return false; return true;
}

function bool DetachActorFromAttachHipRight(out actor A)
{
	A = ActorAttachedTo(GetJointIndexAttachHipRight());
	if(A == None) return false; return true;
}


///////////////////////////////////////////////////////////////////////////////
//	Check to see if an attach joint has an actor already attached
///////////////////////////////////////////////////////////////////////////////
function bool IsJointOccupiedAttachHandLeft()
{
	if(ActorAttachedTo(GetJointIndexAttachHandLeft()) == None)
		return false;
	return true;
}

function bool IsJointOccupiedAttachHandRight()
{
	if(ActorAttachedTo(GetJointIndexAttachHandRight()) == None)
		return false;
	return true;
}

function bool IsJointOccupiedAttachArmLeft()
{
	if(ActorAttachedTo(GetJointIndexAttachArmLeft()) == None)
		return false;
	return true;
}

function bool IsJointOccupiedAttachBackLeft()
{
	if(ActorAttachedTo(GetJointIndexAttachBackLeft()) == None)
		return false;
	return true;
}

function bool IsJointOccupiedAttachBackRight()
{
	if(ActorAttachedTo(GetJointIndexAttachBackRight()) == None)
		return false;
	return true;
}

function bool IsJointOccupiedAttachHipLeft()
{
	if(ActorAttachedTo(GetJointIndexAttachHipLeft()) == None)
		return false;
	return true;
}

function bool IsJointOccupiedAttachHipRight()
{
	if(ActorAttachedTo(GetJointIndexAttachHipRight()) == None)
		return false;
	return true;
}



///////////////////////////////////////////////////////////////////////////////
//	SelectWeapon DONT NEED
///////////////////////////////////////////////////////////////////////////////
function SelectWeapon(Weapon newWeapon)
{
	AttachActorToAttachHandRight(newWeapon);
}

///////////////////////////////////////////////////////////////////////////////
//	GetStowedWeapon DONT NEED
///////////////////////////////////////////////////////////////////////////////
function Weapon GetStowedWeapon(int stowindex)
{
	if (stowindex>=0 && stowindex<=4)
	{
		return StowSpot[stowindex];
	}
	return None;
}

///////////////////////////////////////////////////////////////////////////////
//	SetStowedWeapon DONT NEED
///////////////////////////////////////////////////////////////////////////////
function SetStowedWeapon(int stowindex, Weapon w)
{
	if (stowindex>=0 && stowindex<=2)
	{
		StowSpot[stowindex] = w;
	}
}

///////////////////////////////////////////////////////////////////////////////
//	StowWeapon DONT NEED
///////////////////////////////////////////////////////////////////////////////
function StowWeapon(Weapon oldWeapon)
{
	local int joint;
	local int handJoint;
	local int stowIndex;
	
	if(Weapon == None)
		return;

	switch(Weapon.MeleeType)
	{
	case MELEE_SWORD:	joint = GetJointIndexAttachHipLeft();	break;
	case MELEE_AXE:		joint = GetJointIndexAttachBackRight();	break;
	case MELEE_HAMMER:	joint = GetJointIndexAttachHipLeft();	break;
	default:			joint = 0;								break;
	}

	handJoint = GetJointIndexAttachHandRight();
		
	if(joint != 0 && handJoint != 0)
	{
		DetachActorFromJoint(handJoint);
		AttachActorToJoint(Weapon, joint);

		stowIndex = Weapon.MeleeType;
		SetStowedWeapon(stowIndex, Weapon);
		Weapon.GotoState('Stow');
		Weapon = None;		
	}
}

///////////////////////////////////////////////////////////////////////////////
//	RetrieveWeapon DONT NEED
///////////////////////////////////////////////////////////////////////////////
function RetrieveWeapon(int stowIndex)
{
	local int joint;
	local weapon cur;
	local weapon next;
		
	switch(stowIndex)
	{
	case 0: 	joint = GetJointIndexAttachHipLeft();		break;
	case 1: 	joint = GetJointIndexAttachBackRight();		break;
	case 2: 	joint = GetJointIndexAttachHipLeft();		break;
	default:	joint = 0;									break;
	}

	cur = GetStowedWeapon(stowIndex);
	if(joint != 0 && cur != None)
	{
		DetachActorFromJoint(joint);
		SelectWeapon(cur);

		// Set the next available weapon to this stow spot
		SetStowedWeapon(stowIndex, None);
		next = GetNextWeapon(cur);
		if(next != None && next != cur)
		{
			AttachActorToJoint(next, joint);
			next.bHidden = false; // Reveal the next weapon
			SetStowedWeapon(stowIndex, next);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
//	SwapStowToNext DONT NEED
///////////////////////////////////////////////////////////////////////////////
function SwapStowToNext(int stowIndex)
{
	// TODO: Not really sure when this gets called, lets find that
	local weapon w;
	local weapon next;
	local int joint;

	w = GetStowedWeapon(stowIndex);
	if(w != None)
	{		
		next = GetNextWeapon(w);
		if(next != None && next != w)
		{
			switch(stowIndex)
			{
			case 0:		joint = JointNamed('attatch_sword');	break;
			case 1:		joint = JointNamed('attach_hammer');	break;
			case 2:		joint = JointNamed('attach_axe');		break;
			default:	joint = 0;								break;
			}
				
			if(joint != 0)
			{
				DetachActorFromJoint(joint);
				AttachActorToJoint(next, joint);
				SetStowedWeapon(stowIndex, next);
			}
		}
	}		
}

///////////////////////////////////////////////////////////////////////////////
//	GetNextWeapon DONT NEED
//	
//	Returns the next sequential weapon of a certain type in the inventory.
//	This function is circular, so it will wrap around to the first weapon in the
//	inventory
///////////////////////////////////////////////////////////////////////////////
function Weapon GetNextWeapon(Weapon current)
{
	local Inventory inv;
	local Weapon w;
	local Weapon higherWeapon, lowestWeapon;
	local int lowestRating, higherRating;

	if(current == None || Inventory == None)
		return(None);

	higherWeapon = None;
	lowestWeapon = None;
	lowestRating = 999;
	higherRating = 999; 

	// Iterate through inventory, finding the two weapons that match the following criteria:
	//	- The weapon of type current with the next higher rating than the current weapon
	//	- The weapon of type current with the lowest rating
	for(inv = Inventory; inv != None; inv = inv.Inventory)
	{
		if(inv.IsA('Weapon'))
		{
			w = Weapon(inv);
			if(w != None && w.MeleeType == current.MeleeType)
			{ // Same weapon type
				if(w.Rating < lowestRating)
				{
					lowestWeapon = w;
					lowestRating = w.Rating;
				}
				if(w.Rating > current.Rating && w.Rating < higherRating)
				{
					higherWeapon = w;
					higherRating = w.Rating;
				}
			}
		}
	}

	// Return the next higher weapon, otherwise, wrap around the list
	// NOTE: If only one weapon of type is in the inventory, then this will return the current weapon
	if(higherWeapon != None)
		return(higherWeapon);
	else
		return(lowestWeapon);
}

///////////////////////////////////////////////////////////////////////////////
//	InstantStow DONT NEED
//	
//	Instantly stows the current weapon, and properly updates LastHeldWeapon
//	for later retrieval
///////////////////////////////////////////////////////////////////////////////
function InstantStow()
{
	LastHeldWeapon = None;
	if(Weapon != None)
	{ // Handle the current weapon (drop it, do nothing, or stow it)		
		if(Weapon.IsA('NonStow'))
			DropWeapon();
		else
		{
			LastHeldWeapon = Weapon;
			WeaponDeactivate();
			Weapon.DisableSwipeTrail();
			StowWeapon(None);
		}
	}
}

///////////////////////////////////////////////////////////////////////////////
// (Pawn) ThrowWeapon
///////////////////////////////////////////////////////////////////////////////
function ThrowWeapon()
{
	if(Weapon != None)
	{
		// Play Weapon Throw Sound
		PlaySound(WeaponThrowSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);
	
		Super.ThrowWeapon();
	}
}




// TODO: Bugtest these functions, probably need to rethink the item pickup logic
///////////////////////////////////////////////////////////////////////////////
//	(vmodPlayerPawnBase) AcquireWeapon
///////////////////////////////////////////////////////////////////////////////
function AcquireWeapon(Weapon weaponItem)
{
	InstantStow();
	SelectWeapon(weaponItem);
	Weapon = weaponItem;
}

///////////////////////////////////////////////////////////////////////////////
//	(vmodPlayerPawnBase) AcquireShield
///////////////////////////////////////////////////////////////////////////////
function AcquireShield(Shield shieldItem)
{
	DropShield();
	AttachActorToAttachArmLeft(shieldItem);
}

///////////////////////////////////////////////////////////////////////////////
//	(vmodPlayerPawnBase) AcquireRune
///////////////////////////////////////////////////////////////////////////////
function AcquireRune(Runes runeItem)
{
	runeItem.GotoState('Activated'); // TODO:  Finish Pickup functionality
}

///////////////////////////////////////////////////////////////////////////////
//	(vmodPlayerPawnBase) AcquirePickup
///////////////////////////////////////////////////////////////////////////////
function AcquirePickup(Pickup pickupItem)
{
	pickupItem.PickupFunction(Pawn(Owner));
}




//=============================================================================
// (Pawn) CanPickUp
//=============================================================================
function bool CanPickup(Inventory item)
{
	return true;
}

//=============================================================================
// (Pawn) WantsToPickup
// Returns whether the item is desired
//=============================================================================
function bool WantsToPickUp(Inventory item)
{
	return true;
}

//=============================================================================
// (Pawn) StopAttack
//=============================================================================
function StopAttack()
{
}

//=============================================================================
// (Pawn) ShadowUpdate
//=============================================================================
event ShadowUpdate(int ShadowType)
{
	if(ShadowType == 1)
	{ // Blob
		if(shadow == None)
			shadow = Spawn(class'PlayerShadow', self,, Location, Rotation);

		shadow.DrawScale = 1.5 * DrawScale;
		if(shadow != None)
			shadow.Update(None);
	}
}



///////////////////////////////////////////////////////////////////////////////
//
//	COMMAND HANDLERS
//
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// HandleCmdCameraIn
///////////////////////////////////////////////////////////////////////////////
function HandleCmdCameraIn()
{
	CameraDist -= 10;
}

///////////////////////////////////////////////////////////////////////////////
// HandleCmdCameraOut()
///////////////////////////////////////////////////////////////////////////////
function HandleCmdCameraOut()
{
	CameraDist += 10;
}

///////////////////////////////////////////////////////////////////////////////
// HandleCmdZTargetToggle
///////////////////////////////////////////////////////////////////////////////
function HandleCmdZTargetToggle()
{}

///////////////////////////////////////////////////////////////////////////////
// HandleCmdDumpWeaponInfo
///////////////////////////////////////////////////////////////////////////////
function HandleCmdDumpWeaponInfo()
{}

///////////////////////////////////////////////////////////////////////////////
// HandleCmdDropZ
///////////////////////////////////////////////////////////////////////////////
function HandleCmdDropZ()
{}

///////////////////////////////////////////////////////////////////////////////
// HandleCmdTraceTex
///////////////////////////////////////////////////////////////////////////////
function HandleCmdTraceTex()
{}



//=============================================================================
// ReleaseFromCinematic
//=============================================================================
function ReleaseFromCinematic();


//=============================================================================
//
// STATE: PlayerWalking
//
//=============================================================================
state PlayerWalking
{
	//=========================================================================
	// STATE: PlayerWalking		BeginState
	//=========================================================================
	function BeginState()
	{
		WalkBob = vect(0,0,0);
		DodgeDir = DODGE_None;
		SetCrouch(false);
		bIsTurning = false;
		bPressedJump = false;
		if (Physics != PHYS_Falling)	SetPhysics(PHYS_Walking);
		if ( !IsAnimating() )			PlayWaiting(0.2);
		Enable('Tick');	
	}
	
	//=========================================================================
	// STATE: PlayerWalking		EndState
	//=========================================================================
	function EndState()
	{
		WalkBob = vect(0,0,0);
		SetCrouch(false);
	}
	
	//=========================================================================
	// STATE: PlayerWalking		AnimEnd
	//=========================================================================
	function AnimEnd()
	{
		if(Physics == PHYS_Walking)
		{
			if((Velocity.X * Velocity.X + Velocity.Y * Velocity.Y) < 1000)
				PlayWaiting(0.2);
			else	
				PlayMoving();
		}
	}

	//=========================================================================
	// STATE: PlayerWalking		Landed
	//=========================================================================
	function Landed(vector HitNormal, actor HitActor)
	{
		Super.Landed(HitNormal, HitActor);
		if (Velocity.Z < -1.4 * JumpZ)
			ShakeView(0.175 - 0.00007 * Velocity.Z, -0.85 * Velocity.Z, -0.002 * Velocity.Z);
	}

	//=========================================================================
	// STATE: PlayerWalking		GrabEdge
	//=========================================================================
	function bool GrabEdge(float grabDistance, vector grabNormal)
	{ // RUNE
		if(AnimProxy != None && AnimProxy.GetStateName() == 'Idle')
		{ // Only grab edges if in the idle state
			GrabLocationUp.X = Location.X;
			GrabLocationUp.Y = Location.Y;
			GrabLocationUp.Z = Location.Z + grabDistance + 8;
		
			GrabLocationIn.X = Location.X + grabNormal.X * (CollisionRadius + 4);
			GrabLocationIn.Y = Location.Y + grabNormal.Y * (CollisionRadius + 4);
			GrabLocationIn.Z = GrabLocationUp.Z + CollisionHeight;
		
			SetRotation(rotator(grabNormal));
			ViewRotation.Yaw = Rotation.Yaw; // Align View with Player position while grabbing edge
        
			// Save the final distance (used for choosing the correct anim)
			GrabLocationDist = GrabLocationUp.Z - Location.Z;
        
			// Final, absolute check if the player can fit in the new location.
			// if the player fits, then it is a valid edge grab
			if(SetLocation(GrabLocationIn))
			{
				return(true);
			}
		}
		
		return(false);
	}

	//=========================================================================
	// STATE: PlayerWalking
	// Dodge
	//=========================================================================
	function Dodge(eDodgeDir DodgeMove)
	{
		// TODO: We have the main dodge code right here, fix this shit
		local vector X,Y,Z;

		if ( bIsCrouching || (Physics != PHYS_Walking) || Weapon==None)
			return;

		GetAxes(Rotation,X,Y,Z);
		if (DodgeMove == DODGE_Forward)
			Velocity = 1.3 * GroundSpeed*X + (Velocity Dot Y)*Y;
		else if (DodgeMove == DODGE_Back)
			Velocity = -1.3 * GroundSpeed*X + (Velocity Dot Y)*Y; 
		else if (DodgeMove == DODGE_Left)
			Velocity = 1.3 * GroundSpeed*Y + (Velocity Dot X)*X; 
		else if (DodgeMove == DODGE_Right)
			Velocity = -1.3 * GroundSpeed*Y + (Velocity Dot X)*X; 

		Velocity.Z = 180;
		if ( Role == ROLE_Authority )
			PlaySound(JumpSound, SLOT_Talk, 1.0, true, 800, 1.0 );
		PlayDodge(DodgeMove);
		DodgeDir = DODGE_Active;
		SetPhysics(PHYS_Falling);
	}
	
	//=========================================================================
	// STATE: PlayerWalking
	// ProcessMove
	//=========================================================================
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		local vector OldAccel;

		OldAccel = Acceleration;
		Acceleration = NewAccel;
		bIsTurning = ( Abs(DeltaRot.Yaw/DeltaTime) > 10000 ); // RUNE:  was 5000

		if ( (DodgeMove == DODGE_Active) && (Physics == PHYS_Falling) )
			DodgeDir = DODGE_Active;	
		else if ( (DodgeMove != DODGE_None) && (DodgeMove < DODGE_Active) )
			Dodge(DodgeMove);

		if(bPressedJump)
			DoJump();

		if((Physics == PHYS_Walking))
		{
			if(!bIsCrouching)
			{
				if(bDuck != 0)
				{
					SetCrouch(true);
					PlayDuck();
				}
			}
			else if(bDuck == 0)
			{
				OldAccel = vect(0,0,0);
				SetCrouch(false);
			}

			if ( !bIsCrouching )
			{
				if(VSize(Acceleration) >= 1)
				{
					PlayMoving();
				}
			 	else if(Velocity.X * Velocity.X + Velocity.Y * Velocity.Y < 1000)
			 	{
					PlayWaiting(0.2);
					// TODO: We should make some turning animations
					// Could probably scale the turn anim rate by the turn speed
					//if(bIsTurning)
					//{
					//	PlayTurning();
					//}
			 		//else
					//{
					//	PlayWaiting(0.2);
					//}
				}
			}
			else
			{
				if(VSize(Acceleration) >= 1)
					PlayCrawling();
				else
					PlayDuck();
			}
		}
	}

	//=========================================================================
	// STATE: PlayerWalking
	// UpdateRotation
	//=========================================================================
	function UpdateRotation(float DeltaTime, float maxPitch)
	{
		// TODO: This seems to be getting called every single tick?
		local rotator newRotation;
		local vector ToZTarget;
		
		if(ZTarget == None)
		{ // No ZTarget, so use the normal UpdateRotation
			Super.UpdateRotation(DeltaTime, maxPitch);
			return;
		}
		else
		{ // ZTarget			
			DesiredRotation = ViewRotation; //save old rotation
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0) 
					ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}

			ToZTarget = ZTarget.Location - Location;
			ViewRotation.Yaw = rotator(ToZTarget).Yaw;
			ViewFlash(deltaTime);
				
			newRotation = Rotation;
			newRotation.Yaw = ViewRotation.Yaw;
			newRotation.Pitch = ViewRotation.Pitch;
			If ( (newRotation.Pitch > maxPitch * RotationRate.Pitch) && (newRotation.Pitch < 65536 - maxPitch * RotationRate.Pitch) )
			{
				If (ViewRotation.Pitch < 32768) 
					newRotation.Pitch = maxPitch * RotationRate.Pitch;
				else
					newRotation.Pitch = 65536 - maxPitch * RotationRate.Pitch;
			}
			setRotation(newRotation);			
		}
	}

	//=========================================================================
	// STATE: PlayerWalking
	// PlayerTick
	//=========================================================================
	event PlayerTick( float DeltaTime )
	{
		local float ZDist;

		if ( bUpdatePosition )
			ClientUpdatePosition();

		PlayerMove(DeltaTime);
	}

	//=========================================================================
	// STATE: PlayerWalking
	// ZoneChange
	//=========================================================================
	function ZoneChange(ZoneInfo NewZone)
	{
		if(NewZone.bWaterZone && Physics == PHYS_Falling && Velocity.Z < -1300)
		{ // Player is falling and screaming, cut out the scream when he hits the water
			PlaySound(UnderwaterHitSound[0], SLOT_Talk,, false);			
		}

		Super.ZoneChange(NewZone);
	}
}

/*
//=============================================================================
//
// STATE: EdgeHanging
//
//=============================================================================
state EdgeHanging
{
	//=========================================================================
	// STATE: EdgeHanging
	// Ignore
	//=========================================================================
	ignores	SeePlayer,
			HearNoise,
			Bump,
			Fire,
			AltFire,
			GrabEdge,
			Jump,
			SwitchWeapon,
			Taunt,
			Fly,
			Walk,
			Ghost,
			Powerup,
			Throw;

	//=========================================================================
	// STATE: EdgeHanging
	// BeginState
	//=========================================================================
	function BeginState()
	{
		//if(AnimProxy != None)
		//	AnimProxy.GotoState('EdgeHanging');		
		
		if (Level.NetMode == NM_Client)
		{
			if(GrabLocationDist <= 5)
			{	// Nothing, possibly re-entered state
				GotoState('PlayerWalking');
				return;
			}
			else if(GrabLocationDist < 20)
			{	// Step up
				//PlayStepUp(0.0); // No tween
			}
			else
			{	// Pull up
				//PlayPullUp(0.0); // No tween
			}
		}
		else
		{
			// Play Grab Animation
			if(GrabLocationDist > 20)
			{
				//PlayPullUp(0.0); // No tween
			}
			else
			{
				//PlayStepUp(0.0); // No tween
			}
		}

		// Set up variables on the player
		SetPhysics(PHYS_Flying);
		Velocity = vect(0, 0, 0);
		Acceleration = vect(0, 0, 0);

		SetCrouch(false);
		bPressedJump = false;
		CameraAccel = 1;
	}
	
	//=========================================================================
	// STATE: EdgeHanging
	// EndState
	//=========================================================================
	function EndState()
	{
		CameraAccel = Default.CameraAccel;

		//if(AnimProxy != None)
		//	AnimProxy.GotoState('Idle');
	}
	
	//=========================================================================
	// STATE: EdgeHanging
	// AnimEnd
	//=========================================================================
	function AnimEnd()
	{
		if(AnimSequence == 'intropullupA')
		{ // Finished initial pullup, so step up
			//PlayStepUp(0.1);
		}
		else if(AnimSequence == 'pullupTest')
		{ // Finished step up, so done with edge grab
			//PlayWaiting(0.2);

			//if(AnimProxy != None)
			//	AnimProxy.GotoState('Idle');

			GotoState('PlayerWalking');
		}
	}
}


//=============================================================================
//
// STATE: PlayerSwimming
//
//=============================================================================
state PlayerSwimming
{
	//=========================================================================
	// STATE: PlayerSwimming
	// Ignore
	//=========================================================================
	ignores PlayFiring,
			PlayAltFiring;
	
	//=========================================================================
	// STATE: PlayerSwimming
	// PlayMoving
	//=========================================================================
	function PlayMoving(optional float tween)
	{
		PlaySwimming();
	}

	//=========================================================================
	// STATE: PlayerSwimming
	// PlayUnderwaterSound
	//=========================================================================
	function PlayUnderwaterSound()
	{
		AmbientSound = UnderwaterAmbient[Rand(5)];
	}

	//=========================================================================
	// STATE: PlayerSwimming
	// SetSurfaceSwim
	//=========================================================================
	function SetSurfaceSwim(bool surface)
	{
		bSurfaceSwimming = surface;
	}

	//=========================================================================
	// STATE: PlayerSwimming
	// StopUnderwaterSound
	//=========================================================================
	function StopUnderwaterSound()
	{
		AmbientSound = None;
	}

	//=========================================================================
	// STATE: PlayerSwimming
	// CanGotoPainState
	//=========================================================================
	function bool CanGotoPainState()
	{
		return(!bSurfaceSwimming);
	}

	//=========================================================================
	// STATE: PlayerSwimming
	// AnimEnd
	//=========================================================================
	function AnimEnd()
	{
		PlaySwimming();
	}

	//=========================================================================
	// STATE: PlayerSwimming
	// BeginState
	//=========================================================================
	function BeginState()
	{
		Super.BeginState();
		RotationRate.Pitch = 16000;
		PlayUnderwaterSound();

		InstantStow();		
		// Sheath current weapon when underwater
	}

	//=========================================================================
	// STATE: PlayerSwimming
	// EndState
	//=========================================================================
	function EndState()
	{
		Super.EndState();
		RotationRate.Pitch = 0;
		SetSurfaceSwim(false);

		WaterSpeed = 300;
		StopUnderwaterSound();
	}

	//=========================================================================
	// STATE: PlayerSwimming
	// HeadZoneChange
	//=========================================================================
	function HeadZoneChange(ZoneInfo NewZone)
	{
		local vector HitLocation, HitNormal;
		local vector Extent;
		
		Super.HeadZoneChange(NewZone);

		if(!NewZone.bWaterZone && !bSurfaceSwimming)
		{ // Surfaced
			SetSurfaceSwim(true);

			// Align the player directy to the surface
			GrabLocationUp = FindWaterLine(Location + vect(0, 0, 40), Location + vect(0, 0, -40));
			Extent.X = CollisionRadius;
			Extent.Y = CollisionRadius;
			Extent.Z = CollisionHeight;
			if(Trace(HitLocation, HitNormal, GrabLocationUp, Location, true, Extent) == None)
			{
				SetLocation(GrabLocationUp);
				Buoyancy = Mass; // Don't bob in the water!
				bNoSurfaceBob = true;
				Acceleration = vect(0, 0, 0);
				Velocity = vect(0, 0, 0);
				RotationRate.Pitch = 0;
				WaterSpeed = 200;
			}
			else
			{
				SetSurfaceSwim(false);
				RotationRate.Pitch = 16000;
				WaterSpeed = 300;
			}
		}
		else if(NewZone.bWaterZone && bSurfaceSwimming)
		{
			SetSurfaceSwim(false);
			RotationRate.Pitch = 16000;
			WaterSpeed = 300;
		}

		if(NewZone.bWaterZone)
			PlayUnderwaterSound();
		else
			StopUnderwaterSound();
	}

	//=========================================================================
	// STATE: PlayerSwimming
	// PlayerMove
	//=========================================================================
	function PlayerMove(float DeltaTime)
	{
		local rotator oldRotation;
		local vector X,Y,Z, NewAccel;
		local float Speed2D;

		if(bSurfaceSwimming)
		{
			GetAxes(ViewRotation,X,Y,Z);

			aForward *= 0.2;
			aStrafe  *= 0.1;
			aLookup  *= 0.24;
			aTurn    *= 0.24;
			aUp		 *= 0.1;

			if (aUp >= 0)
				aUp = 0;
			else
			{
				aForward = 0;
				aStrafe = 0;
			}
			NewAccel = aForward*X + aStrafe*Y + aUp*vect(0,0,1);
//			NewAccel = aForward*X + aStrafe*Y;

			// Update rotation.
			oldRotation = Rotation;
			UpdateRotation(DeltaTime, 2);

			if ( Role < ROLE_Authority ) // then save this move and replicate it
				ReplicateMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
			else
				ProcessMove(DeltaTime, NewAccel, DODGE_None, OldRotation - Rotation);
			bPressedJump = false;
		}
		else
		{
			Super.PlayerMove(DeltaTime);
		}
	}

	//=========================================================================
	// STATE: PlayerSwimming
	// CheckWaterJump
	//=========================================================================
	function bool CheckWaterJump(out vector WallNormal)
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, checkpoint, start, checkNorm, Extent;

		checkpoint = vector(Rotation);
		checkpoint.Z = 0.0;
		checkNorm = Normal(checkpoint);
		checkPoint = Location + CollisionRadius * checkNorm;
		Extent = CollisionRadius * vect(1,1,0);
		Extent.Z = CollisionHeight;
		HitActor = Trace(HitLocation, HitNormal, checkpoint, Location, true, Extent);
		if ( (HitActor != None) && (Pawn(HitActor) == None) )
		{
			WallNormal = -1 * HitNormal;
			start = Location;
			start.Z += 1.1 * MaxStepHeight;
			checkPoint = start + 2 * CollisionRadius * checkNorm;
			HitActor = Trace(HitLocation, HitNormal, checkpoint, start, true);
			if (HitActor == None)
				return true;
		}

		return false;
	}

	//=========================================================================
	// STATE: PlayerSwimming
	// CheckForSubmerge
	//=========================================================================
	function CheckForSubmerge()
	{
		local float dp;

//		if((aUp < 0) || (ViewRotation.Pitch > 32768 && ViewRotation.Pitch < 55000 && aForward > 0))
		dp = Normal(Acceleration) dot vect(0,0,-1);
		if(Acceleration.Z<0 && dp>0.85)
		{
			SetSurfaceSwim(false);

			WaterSpeed = 300;
			Buoyancy = Default.Buoyancy;
			bNoSurfaceBob = false;
			Velocity = vect(0, 0, -50);
			RotationRate.Pitch = 16000;
		}
	}

	//=========================================================================
	// STATE: PlayerSwimming
	// ProcessMove
	//=========================================================================
	function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
	{
		local vector X,Y,Z, Temp;
	
		GetAxes(ViewRotation,X,Y,Z);
		Acceleration = NewAccel;

		PlaySwimming();

		if(bSurfaceSwimming)
			CheckForSubmerge();

		if(bSurfaceSwimming)
		{
			Acceleration.Z = 0;
		}
	}

	//=========================================================================
	// STATE: PlayerSwimming
	// UpdateRotation
	//=========================================================================
	function UpdateRotation(float DeltaTime, float maxPitch)
	{
		local rotator newRotation;

		// UpdateRotation to properly rotate Ragnar while swimming (does NOT rotate while surfaceswimming, though)
		if(!bSurfaceSwimming)
		{
			DesiredRotation = ViewRotation; //save old rotation
			ViewRotation.Pitch += 32.0 * DeltaTime * aLookUp;
			ViewRotation.Pitch = ViewRotation.Pitch & 65535;
			If ((ViewRotation.Pitch > 18000) && (ViewRotation.Pitch < 49152))
			{
				If (aLookUp > 0) 
					ViewRotation.Pitch = 18000;
				else
					ViewRotation.Pitch = 49152;
			}
			ViewRotation.Yaw += 32.0 * DeltaTime * aTurn;
	//		ViewShake(deltaTime); // RUNE:  ViewShake is handled in the Camera code
			ViewFlash(deltaTime);
				
			newRotation = ViewRotation;
			If ( (newRotation.Pitch > maxPitch * RotationRate.Pitch) && (newRotation.Pitch < 65536 - maxPitch * RotationRate.Pitch) )
			{
				If (ViewRotation.Pitch < 32768) 
					newRotation.Pitch = maxPitch * RotationRate.Pitch;
				else
					newRotation.Pitch = 65536 - maxPitch * RotationRate.Pitch;
			}
			setRotation(newRotation);
		}
		else
		{
			Super.UpdateRotation(DeltaTime, maxPitch);
		}
	}

	//=========================================================================
	// STATE: PlayerSwimming
	// GrabEdge
	//=========================================================================
	function bool GrabEdge(float grabDistance, vector grabNormal)
	{ // RUNE	
		//if(AnimProxy != None && AnimProxy.GetStateName() == 'Idle'
		//	&& !HeadRegion.Zone.bWaterZone)
		//{ // Only grab edges if in the idle state and head is above water
		//	GrabLocationUp.X = Location.X;
		//	GrabLocationUp.Y = Location.Y;
		//	GrabLocationUp.Z = Location.Z + grabDistance + 8;
		//
		//	GrabLocationIn.X = Location.X + grabNormal.X * (CollisionRadius + 4);
		//	GrabLocationIn.Y = Location.Y + grabNormal.Y * (CollisionRadius + 4);
		//	GrabLocationIn.Z = GrabLocationUp.Z + CollisionHeight;
		//
		//	SetRotation(rotator(grabNormal));
		//	ViewRotation.Yaw = Rotation.Yaw; // Align View with Player position while grabbing edge
        //
		//	// Save the final distance (used for choosing the correct anim)
		//	GrabLocationDist = GrabLocationUp.Z - Location.Z;
        //
		//	// Final, absolute check if the player can fit in the new location.
		//	// if the player fits, then it is a valid edge grab
		//	if(SetLocation(GrabLocationIn))
		//	{
		//		if(AnimProxy != None)
		//			AnimProxy.GotoState('EdgeHanging');			
		//		GotoState('EdgeHanging');
        //
		//		return(true);
		//	}
		//}
		
		return(false);
	}
}


//=============================================================================
//
// STATE: Dying
//
//=============================================================================
state Dying
{
	//=========================================================================
	// STATE: Dying
	// Ignore
	//=========================================================================
	ignores	SeePlayer,
			EnemyNotVisible,
			HearNoise,
			KilledBy,
			Trigger,
			Bump,
			HitWall,
			HeadZoneChange,
			FootZoneChange,
			ZoneChange,
			Falling,
			WarnTarget,
			Died,
			LongFall,
			PainTimer,
			//Landed,
			SwitchWeapon;

	//=========================================================================
	// STATE: Dying
	// ServerReStartPlayer
	//=========================================================================
	function ServerReStartPlayer()
	{
		Super.ServerReStartPlayer();

		//PlayerRestart();
	}

	//=========================================================================
	// STATE: Dying
	// BeginState
	//=========================================================================
	function BeginState()
	{
		local int i;
		local int joint;
		local vector X, Y, Z;

		Super.BeginState();

		// Drop any stowed weapons
		for(i = 0; i < 3; i++)
		{
			if(StowSpot[i] != None)
			{		
				switch(StowSpot[i].MeleeType)
				{
				case MELEE_SWORD:
					joint = JointNamed('attatch_sword');
					break;
				case MELEE_AXE:
					joint = JointNamed('attach_axe');
					break;
				case MELEE_HAMMER:
					joint = JointNamed('attach_hammer');
					break;
				default:
					// Unknown or non-stow item
					joint = 0;
					break;
				}

				if(joint != 0)
				{
					DetachActorFromJoint(joint);
						
					GetAxes(Rotation, X, Y, Z);
					StowSpot[i].DropFrom(GetJointPos(joint));
				
					StowSpot[i].SetPhysics(PHYS_Falling);
					StowSpot[i].Velocity = Y * 100 + X * 75;
					StowSpot[i].Velocity.Z = 50;
					
					StowSpot[i].GotoState('Drop');
					StowSpot[i].DisableSwipeTrail();

					StowSpot[i] = None; // Remove the StowWeapon from the actor
				}
			}		
		}

		Buoyancy = Mass + 5;
		LookTarget=None;
		LookSpot=vect(0,0,0);
		SetCollision(true, false, false);
		SetPhysics(PHYS_Falling);
	}

	//=========================================================================
	// STATE: Dying
	// EndState
	//=========================================================================
	function EndState()
	{
		Buoyancy=Default.Buoyancy;
		Super.EndState();
	}

	//=========================================================================
	// STATE: Dying
	// Landed
	//=========================================================================
	function Landed(vector HitNormal, actor HitActor)
	{
		SetPhysics(PHYS_None);
		SetCollision(false, false, false);
		bCollideWorld = true;
	}

	//=========================================================================
	// STATE: Dying
	// AnimEnd
	//=========================================================================
	function AnimEnd()
	{
		ReplaceWithCarcass();
	}
}


//=============================================================================
//
// STATE: Pain
//
// Apply pain to the torso
//
//=============================================================================
state Pain
{
	//=========================================================================
	// STATE: Pain
	// CanGotoPainState
	//=========================================================================
	function bool CanGotoPainState()
	{ // Do not allow the actor to enter the painstate when already in pain
		return(false);
	}

	//=========================================================================
	// STATE: Pain
	// Begin
	//=========================================================================
	begin:
		//if(AnimProxy != None)
		//{
		//	if(AnimProxy.CanGotoPainState())
		//	{
		//		AnimProxy.GotoState('Pain');
		//	}
		//}
		PlayFrontHit();

		GotoState(NextStateAfterPain);
}


//=============================================================================
//
// STATE: Unresponsive
//
// Ignore player input
//
//=============================================================================
state Unresponsive
{
	//=========================================================================
	// STATE: Unresponsive
	// Ignore
	//=========================================================================
	ignores	SeePlayer,
			EnemyNotVisible,
			HearNoise,
			Trigger,
			Bump,
			HitWall,
			HeadZoneChange,
			FootZoneChange,
			ZoneChange,
			Falling,
			WarnTarget,
			LongFall,
			Landed,
			Taunt,
			Powerup,
			Throw,
			Fire,
			AltFire,
			Use,
			SwitchWeapon,
			Fly,
			Walk,
			Ghost,
			Suicide,
			PlayTakeHit;
			
	//=========================================================================
	// STATE: Unresponsive
	// CanBeStatued
	// TODO: Might just get rid of this
	//=========================================================================
	function bool CanBeStatued() { return false; }
	
	//=========================================================================
	// STATE: Unresponsive
	// CanGotoPainState
	//=========================================================================
	function bool CanGotoPainState() { return(false); }
	
	//=========================================================================
	// STATE: Unresponsive
	// JointDamaged
	//=========================================================================
	function bool JointDamaged(
		int Damage,
		Pawn EventInstigator,
		vector HitLoc,
		vector Momentum,
		name DamageType,
		int joint)
	{
		return false;
	}
	
	//=========================================================================
	// STATE: Unresponsive
	// ProcessMove
	//=========================================================================
	function ProcessMove(
		float DeltaTime,
		vector NewAccel,
		eDodgeDir DodgeMove,
		rotator DeltaRot)	
	{
		Acceleration = vect(0,0,0);
	}

	//=========================================================================
	// STATE: Unresponsive
	// PlayerTick
	//=========================================================================
	event PlayerTick( float DeltaTime )
	{
		if ( bUpdatePosition )
			ClientUpdatePosition();
		
		PlayerMove(DeltaTime);
	}

	//=========================================================================
	// STATE: Unresponsive
	// PlayerMove
	//=========================================================================
	function PlayerMove( float DeltaTime )
	{
		if ( Role < ROLE_Authority ) // then save this move and replicate it
			ReplicateMove(DeltaTime, vect(0,0,0), Dodge_None, rot(0,0,0));
	}
	
	//=========================================================================
	// STATE: Unresponsive
	// EndState
	//=========================================================================
	function EndState()
	{
		if(AnimProxy != None)
			AnimProxy.GotoState('Idle');
	}

	//=========================================================================
	// STATE: Unresponsive
	// BeginState
	//=========================================================================
	function BeginState()
	{
		Acceleration = vect(0,0,0);
		Velocity = vect(0,0,0);
		SetPhysics(PHYS_Falling);

		if (Weapon != None)
			Weapon.FinishAttack();

	//	if(AnimProxy != None)
	//		AnimProx.GotoState('Idle');
	}

	//=========================================================================
	// STATE: Unresponsive
	// AnimEnd
	//=========================================================================
	function AnimEnd()
	{
		PlayWaiting(0.2);
	}
}


//=============================================================================
//
// STATE: Attacking
//
//=============================================================================
state Attacking
{
	Begin:
		WeaponActivate();
		Weapon.PlaySwipeSound();
		PlayAnim(Weapon.A_AttackA, 1.0, 0.1);
		Weapon.WeaponFire(0);
		FinishAnim();
		WeaponDeactivate();
		GotoState('PlayerWalking');
	
	End:
		GotoState('PlayerWalking');
}
*/

//=============================================================================
// Debug
// TODO: Do we need this?
//=============================================================================
simulated function Debug(Canvas canvas, int mode)
{
	local vector pos1, pos2;	// testing sweep
	local vector offset;
	local actor A,BestActor;
	local float score,BestScore;
	local int X,Y;

	Super.Debug(canvas, mode);

	Canvas.DrawText("RunePlayer:");
	Canvas.CurY -= 8;
	Canvas.CurY -= 8;
	Canvas.DrawText("  GroundSpeed: "$GroundSpeed);

	Canvas.CurY -= 8;
	Canvas.DrawText("  OrderObject: " $ OrderObject);
	Canvas.CurY -= 8;
	Canvas.DrawText("  LastHeldWeapon:  " $ LastHeldWeapon);
	Canvas.CurY -= 8;
	if(Weapon != None)
	{
		Canvas.DrawText("  NextWeapon:  " $ GetNextWeapon(Weapon));
		Canvas.CurY -= 8;
	}
	Canvas.DrawText("  PrePivot:  " $ PrePivot);
	Canvas.CurY -= 8;
	Canvas.DrawText("  SubstituteMesh: " $ SubstituteMesh);
	Canvas.CurY -= 8;
	Canvas.DrawText("  UninterruptedAnim: " $ UninterruptedAnim);
	Canvas.CurY -= 8;

	// Draw grab location
	offset = GrabLocationIn;
//	offset.Z += CollisionHeight * 0.5;
	Canvas.DrawLine3D(offset + vect(10, 0, 0), offset + vect(-10, 0, 0), 0, 255, 0);
	Canvas.DrawLine3D(offset + vect(0, 10, 0), offset + vect(0, -10, 0), 0, 255, 0);	
	Canvas.DrawLine3D(offset + vect(0, 0, 10), offset+ vect(0, 0, -10), 0, 255, 0);

	// Test:  Draw Light position
	offset = Location - ShadowVector;
	Canvas.DrawLine3D(offset + vect(10, 0, 0), offset + vect(-10, 0, 0), 0, 0, 255);
	Canvas.DrawLine3D(offset + vect(0, 10, 0), offset + vect(0, -10, 0), 0, 0, 255);	
	Canvas.DrawLine3D(offset + vect(0, 0, 10), offset+ vect(0, 0, -10), 0, 0, 255);

	// Draw sweep positions
	if (Weapon != None)
	{
		pos1 = Weapon.GetJointPos(0);
		pos2 = Weapon.GetJointPos(1);
		
		Canvas.DrawLine3D(pos1, pos2, 0,   0, 255);
		Canvas.DrawBox3D(pos1, vect(5,5,5), 0, 30, 255);
		Canvas.DrawBox3D(pos2, vect(5,5,5), 0, 30, 255);
	}

	// Draw look focus scores
	bestScore = 9999999.0;
	bestActor = None;
	foreach VisibleActors(class'actor', A, 1000, Location)
	{
		if(A == self || A.Owner == self)
			continue;
		
		if(A.bLookFocusPlayer)
		{
			score = ScoreLookActor(A);
			if(score < bestScore)
			{
				bestScore = score;
				bestActor = A;
			}

			Canvas.SetColor(255,255,0);
			Canvas.TransformPoint(A.Location, X, Y);
			Canvas.SetPos(X,Y);
			Canvas.DrawText(score, false);
		}
	}
	if (BestActor != None)
	{
		Canvas.SetColor(255,255,255);
		Canvas.TransformPoint(BestActor.Location, X, Y);
		Canvas.SetPos(X,Y);
		Canvas.DrawText(BestScore@"*", false);
	}


	// Test:  Draw DropZ stuff
	offset = Location + vect(0, 0, 60);
	Canvas.DrawLine3D(offset, offset + DropZFloor * 10, 0, 0, 255);
	Canvas.DrawLine3D(offset, offset + DropZRag * 10, 255, 0, 0);
	Canvas.DrawLine3D(offset, offset + DropZResult * 10, 0, 255, 0);
	Canvas.DrawLine3D(offset, offset + DropZRoll * 10, 255, 255, 255);
}


//=============================================================================
//
// Defaults
//
//=============================================================================
defaultproperties
{
	// Actor
	AnimSequence=WalkSm
	AnimationProxyClass=class'vmodRunePlayerProxy'
	bSinglePlayer=True
	DrawType=DT_SkeletalMesh
	Sprite=Texture'RuneFX.shadow'
	Texture=Texture'Engine.S_Corpse'
	CollisionRadius=18.000000
	CollisionHeight=42.000000
	Buoyancy=99.000000
	Skeletal=SkelModel'Players.Ragnar'
	
	// Pawn
	bRotateTorso=True
	DeathRadius=40.000000
	DeathHeight=8.000000
	MaxBodyAngle=(Yaw=5000)
	MaxHeadAngle=(Yaw=7000)
	bHeadLookUpDouble=True
	LookDegPerSec=360.000000
	FootprintClass=Class'RuneI.footprint'
	WetFootprintClass=Class'RuneI.FootprintWet'
	BloodyFootprintClass=Class'RuneI.FootprintBloody'
	LFootJoint=5
	RFootJoint=9
	bFootsteps=True
	PeripheralVision=-0.500000
	BaseEyeHeight=25.000000
	EyeHeight=25.000000
	BodyPartHealth(1)=75
	BodyPartHealth(3)=75
	BodyPartHealth(5)=75
	GibCount=10
	GibClass=Class'RuneI.DebrisFlesh'
	UnderWaterTime=60.000000
	Intelligence=BRAINS_HUMAN
	WeaponJoint=attach_hand
	ShieldJoint=attach_shielda
	StabJoint=spineb
	bCanLook=True
	bCanStrafe=True
	bIsHuman=True
	bCanGrabEdges=True
	MeleeRange=50.000000
	GroundSpeed=315.000000
	WaterSpeed=300.000000
	AirSpeed=400.000000
	AccelRate=2048.000000
	JumpZ=425.000000
	AirControl=0.250000
	bBehindView=True
	CarcassType=Class'RuneI.PlayerCarcass'
	Die=Sound'CreaturesSnd.Ragnar.ragdeath01'
	Die2=Sound'CreaturesSnd.Ragnar.ragdeath02'
	Die3=Sound'CreaturesSnd.Ragnar.ragdeath03'
	LandGrunt=Sound'CreaturesSnd.Ragnar.ragland01'
	FootStepWood(0)=Sound'FootstepsSnd.Wood.footwood02'
	FootStepWood(1)=Sound'FootstepsSnd.Wood.footlandwood02'
	FootStepWood(2)=Sound'FootstepsSnd.Wood.footwood05'
	FootStepMetal(0)=Sound'FootstepsSnd.Metal.footmetal01'
	FootStepMetal(1)=Sound'FootstepsSnd.Metal.footmetal02'
	FootStepMetal(2)=Sound'FootstepsSnd.Metal.footmetal05'
	FootStepStone(0)=Sound'FootstepsSnd.Earth.footgravel09'
	FootStepStone(1)=Sound'FootstepsSnd.Earth.footgravel10'
	FootStepStone(2)=Sound'FootstepsSnd.Earth.footgravel09'
	FootStepFlesh(0)=Sound'FootstepsSnd.Earth.footsquish02'
	FootStepFlesh(1)=Sound'FootstepsSnd.Earth.footsquish07'
	FootStepFlesh(2)=Sound'FootstepsSnd.Earth.footsquish09'
	FootStepIce(0)=Sound'FootstepsSnd.Ice.footice01'
	FootStepIce(1)=Sound'FootstepsSnd.Ice.footice02'
	FootStepIce(2)=Sound'FootstepsSnd.Ice.footice03'
	FootStepEarth(0)=Sound'FootstepsSnd.Earth.footgravel01'
	FootStepEarth(1)=Sound'FootstepsSnd.Earth.footgravel02'
	FootStepEarth(2)=Sound'FootstepsSnd.Earth.footgravel04'
	FootStepSnow(0)=Sound'FootstepsSnd.Snow.footsnow01'
	FootStepSnow(1)=Sound'FootstepsSnd.Snow.footsnow02'
	FootStepSnow(2)=Sound'FootstepsSnd.Snow.footsnow04'
	FootStepWater(0)=Sound'FootstepsSnd.Water.footwaterwaist01'
	FootStepWater(1)=Sound'FootstepsSnd.Water.footwaterwaist02'
	FootStepWater(2)=Sound'FootstepsSnd.Water.footwaterwaist03'
	FootStepMud(0)=Sound'FootstepsSnd.Mud.footmud01'
	FootStepMud(1)=Sound'FootstepsSnd.Mud.footmud02'
	FootStepMud(2)=Sound'FootstepsSnd.Mud.footmud03'
	FootStepLava(0)=Sound'FootstepsSnd.Lava.footlava02'
	FootStepLava(1)=Sound'FootstepsSnd.Lava.footlava03'
	FootStepLava(2)=Sound'FootstepsSnd.Lava.footlava07'
	LandSoundWood=Sound'FootstepsSnd.Earth.footlandearth01'
	LandSoundMetal=Sound'FootstepsSnd.Metal.footmetal04'
	LandSoundStone=Sound'FootstepsSnd.Earth.footlandearth04'
	LandSoundFlesh=Sound'FootstepsSnd.Earth.footsquish06'
	LandSoundIce=Sound'FootstepsSnd.Earth.footlandearth02'
	LandSoundSnow=Sound'FootstepsSnd.Snow.footlandsnow05'
	LandSoundEarth=Sound'FootstepsSnd.Earth.footlandearth05'
	LandSoundWater=Sound'FootstepsSnd.Water.footlandwater02'
	LandSoundMud=Sound'FootstepsSnd.Mud.footlandmud01'
	LandSoundLava=Sound'FootstepsSnd.Lava.footlava01'
	
	// PlayerPawn
	
	// vmodRunePlayer
	CrouchHeight=25.000000
	CameraDist=180.000000
	CameraAccel=7.000000
	CameraHeight=35.000000
	CameraPitch=450.000000
	CameraRotSpeed=(Pitch=20,Yaw=20,Roll=20)
	TranslucentDist=115.000000
	CurrentDist=200.000000
	Die4=Sound'CreaturesSnd.Ragnar.ragdeath04'
	PowerupFail=Sound'OtherSnd.Menu.menu01'
	FallingDeathSound=Sound'CreaturesSnd.Ragnar.ragland02'
	FallingScreamSound=Sound'CreaturesSnd.Ragnar.ragfall01'
	UnderWaterDeathSound=Sound'CreaturesSnd.Ragnar.drowned'
	EdgeGrabSound=Sound'CreaturesSnd.Ragnar.raggrab02'
	KickSound=Sound'CreaturesSnd.Ragnar.ragkick01'
	CrouchSound=Sound'CreaturesSnd.Ragnar.ragpickup02'
	BerserkSoundEnd=Sound'WeaponsSnd.PowerUps.powerend19'
	BerserkSoundLoop=Sound'CreaturesSnd.Ragnar.ragberzerkL'
	BerserkSoundStart=Sound'WeaponsSnd.PowerUps.powerstart44'
	BerserkYellSound(0)=Sound'CreaturesSnd.Ragnar.ragattack01'
	BerserkYellSound(1)=Sound'CreaturesSnd.Ragnar.ragattack02'
	BerserkYellSound(2)=Sound'CreaturesSnd.Ragnar.ragattack03'
	BerserkYellSound(3)=Sound'CreaturesSnd.Ragnar.ragattack04'
	BerserkYellSound(4)=Sound'CreaturesSnd.Ragnar.ragattack05'
	BerserkYellSound(5)=Sound'CreaturesSnd.Ragnar.ragattack06'
	HitSoundHigh(0)=Sound'CreaturesSnd.Ragnar.raghit07'
	HitSoundHigh(1)=Sound'CreaturesSnd.Ragnar.raghit08'
	HitSoundHigh(2)=Sound'CreaturesSnd.Ragnar.raghit09'
	HitSoundLow(0)=Sound'CreaturesSnd.Ragnar.raghit01'
	HitSoundLow(1)=Sound'CreaturesSnd.Ragnar.raghit02'
	HitSoundLow(2)=Sound'CreaturesSnd.Ragnar.raghit03'
	HitSoundMed(0)=Sound'CreaturesSnd.Ragnar.raghit04'
	HitSoundMed(1)=Sound'CreaturesSnd.Ragnar.raghit05'
	HitSoundMed(2)=Sound'CreaturesSnd.Ragnar.raghit06'
	JumpGruntSound(0)=Sound'CreaturesSnd.Ragnar.ragjump01'
	JumpGruntSound(1)=Sound'CreaturesSnd.Ragnar.ragjump02'
	JumpGruntSound(2)=Sound'CreaturesSnd.Ragnar.ragjump03'
	UnderwaterAmbient(0)=Sound'EnvironmentalSnd.Water.underwater01L'
	UnderwaterAmbient(1)=Sound'EnvironmentalSnd.Water.underwater02L'
	UnderwaterAmbient(2)=Sound'EnvironmentalSnd.Water.underwater03L'
	UnderwaterAmbient(3)=Sound'EnvironmentalSnd.Water.underwater04L'
	UnderwaterAmbient(4)=Sound'EnvironmentalSnd.Water.underwater06L'
	UnderwaterAmbient(5)=Sound'EnvironmentalSnd.Water.underwater08L'
	UnderWaterHitSound(0)=Sound'CreaturesSnd.Ragnar.gasp01'
	UnderWaterHitSound(1)=Sound'CreaturesSnd.Ragnar.gasp01'
	UnderWaterHitSound(2)=Sound'CreaturesSnd.Ragnar.gasp01'
	WeaponPickupSound=Sound'CreaturesSnd.Ragnar.ragpickup02'
	WeaponThrowSound=Sound'CreaturesSnd.Ragnar.ragthrow03'
	WeaponDropSound=Sound'CreaturesSnd.Ragnar.ragdrop02'
}