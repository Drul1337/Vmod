////////////////////////////////////////////////////////////////////////////////
// vmodRunePlayerBase.uc
//
//      |---Object
//          |---Actor
//              |---Pawn
//                  |---PlayerPawn
//                      |---vmodPlayerPawnBase
//                          |---vmodPlayerPawnInterface
//                              |---vmodRunePlayerBase
//
class vmodRunePlayerBase extends vmodPlayerPawnInterface config(user) abstract;

// Attach joint names
const JOINT_ATTACH_HAND_RIGHT   = 'attach_hand';
const JOINT_ATTACH_HAND_LEFT    = 'lhand';
const JOINT_ATTACH_ARM_LEFT     = 'attach_shielda';
const JOINT_ATTACH_BACK_LEFT    = 'attach_axe';
const JOINT_ATTACH_BACK_RIGHT   = 'attach_axe';
const JOINT_ATTACH_HIP_LEFT     = 'attach_hammer';
const JOINT_ATTACH_HIP_RIGHT    = 'attach_sword';

// Weapon classifications for RunePlayer
const WC_UNCLASSIFIED   = -1;   // Unknown / unclassified weapon
const WC_PRIMARY_TWOH   = 0;    // Two handed primary weapon
const WC_PRIMARY_ONEH   = 1;    // One handed primary (shield / dual wield capable)
const WC_SECONDARY      = 2;    // Secondary weapon
const WC_THROWER        = 3;    // Small scale throwing weapon

////////////////////////////////////////////////////////////////////////////////
//
//  ACTOR OVERRIDES
//
////////////////////////////////////////////////////////////////////////////////
event PreBeginPlay()
{
    Super(vmodPlayerPawnBase).PreBeginPlay();
}

event FrameNotify(int framepassed)
{
    // TODO: This is how the weapon receives frame notify events
    // Could be a source of errors
    if(Weapon != None)
        Weapon.FrameNotify(framepassed);
}

function int BodyPartForJoint(int joint)
{
    switch(joint)
    {
        case 24:            return BODYPART_LARM1;
        case 31:            return BODYPART_RARM1;
        case 6:  case 7:    return BODYPART_RLEG1;
        case 2:  case 3:    return BODYPART_LLEG1;
        case 17:            return BODYPART_HEAD;
        case 11:            return BODYPART_TORSO;
        default:            return BODYPART_BODY;
    }
}




////////////////////////////////////////////////////////////////////////////////
//
//  PAWN OVERRIDES
//
////////////////////////////////////////////////////////////////////////////////
function int BodyPartForPolyGroup(int polygroup)
{
    return BODYPART_BODY;
}

function bool BodyPartSeverable(int BodyPart)
{
    return false;
}

function class<Actor> SeveredLimbClass(int BodyPart)
{
    return None;
}

function LimbSevered(int BodyPart, vector Momentum)
{
}




////////////////////////////////////////////////////////////////////////////////
//
//  vmodRunePlayerBase
//
////////////////////////////////////////////////////////////////////////////////





////////////////////////////////////////////////////////////////////////////////
// Animation functions
//
function PlayJumping(optional float tweenTime)
{
    
}

function PlayTakeHit(
    float tweenTime,
    int damage,
    vector hitLoc,
    name damageType,
    vector momentum,
    int bodyPart)
{
    
}

//function PlayFrontHit(optional float tweenTime) {}
//function PlayBackHit(optional float tweenTime) {}
//function PlayGutHit(optional float tweenTime) {}
//function PlayHeadHit(optional float tweenTime) {}
//function PlayLeftHit(optional float tweenTime) {}
//function PlayRightHit(optional float tweenTime) {}
//function PlayDrowning(optional float tweenTime) {}
//
//function PlayDeath(name damageType) {}
//function PlayBackDeath(name damageType) {}
//function PlayLeftDeath(name damageType) {}
//function PlayRightDeath(name damageType) {}
//function PlayHeadDeath(name damageType) {}
//function PlayDrownDeath(name damageType) {}
//function PlayGibDeath(name damageType) {}
//function PlaySkewerDeath(name damageType) {}
//
//function PlayFiring() {}
//function PlayAltFiring() {}
//function PlayMoving(optional float tweenTime) {}
//function PlayInAir(optional float tweenTime) {}
//function PlayPullUp(optional float tweenTime) {}
//function PlayStepUp(optional float tweenTime) {}
//function PlayDuck(optional float tweenTime) {}
//function PlayCrawling(optional float tweenTime) {}
//function PlayWaiting(optional float tweenTime) {}
//function PlayLanded(float impactVelocity) {}
//function PlaySwimming() {}



////////////////////////////////////////////////////////////////////////////////
//  CanPickUp inventory handlers
////////////////////////////////////////////////////////////////////////////////
function bool CanPickUpWeapon(Weapon weaponItem)
{
    local Actor link;
    local int c;
    
    c = GetWeaponClassification(weaponItem);
    if(c == WC_UNCLASSIFIED)
        return false;
    
    // If we already have a weapon of this size, then we cannot pick up
    for(link = Self; link != None; link = link.Inventory)
        if(link.Inventory.IsA('Weapon'))
            if(GetWeaponClassification(Weapon(link.Inventory)) == c)
                return false;
    
    return true;
}

function bool CanPickUpShield(Shield shieldItem)
{ return true; }

function bool CanPickUpRune(Runes runeItem)
{ return true; }

function bool CanPickUpPickup(Pickup pickupItem)
{ return true; }

////////////////////////////////////////////////////////////////////////////////
//  WantsToPickUp inventory handlers
////////////////////////////////////////////////////////////////////////////////
function bool WantsToPickUpWeapon(Weapon weaponItem)
{ return true; }

function bool WantsToPickUpShield(Shield shieldItem)
{ return true; }

function bool WantsToPickUpRune(Runes runeItem)
{ return true; }

function bool WantsToPickUpPickup(Pickup pickupItem)
{ return true; }

////////////////////////////////////////////////////////////////////////////////
//  Joint utility functions
//
//  These are the bare joint utility functions, directly referencing attach
//  joints on RunePlayer's skeleton.
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Get the index for an attachment joint
////////////////////////////////////////////////////////////////////////////////
final function int GetJntIndxAttachHandLeft()
{ return JointNamed( JOINT_ATTACH_HAND_LEFT ); }

final function int GetJntIndxAttachHandRight()
{ return JointNamed( JOINT_ATTACH_HAND_RIGHT ); }

final function int GetJntIndxAttachArmLeft() 
{ return JointNamed( JOINT_ATTACH_ARM_LEFT ); }

final function int GetJntIndxAttachBackLeft()
{ return JointNamed( JOINT_ATTACH_BACK_LEFT ); }

final function int GetJntIndxAttachBackRight()
{ return JointNamed( JOINT_ATTACH_BACK_RIGHT ); }

final function int GetJntIndxAttachHipLeft()
{ return JointNamed( JOINT_ATTACH_HIP_LEFT ); }

final function int GetJntIndxAttachHipRight()
{ return JointNamed( JOINT_ATTACH_HIP_RIGHT ); }

////////////////////////////////////////////////////////////////////////////////
// Attach an actor to an attachment joint
////////////////////////////////////////////////////////////////////////////////
final function AttachToHandLeft(actor a)
{ AttachActorToJoint( a, GetJntIndxAttachHandLeft() ); }

final function AttachToHandRight(actor a)
{ AttachActorToJoint( a, GetJntIndxAttachHandRight() ); }

final function AttachToArmLeft(actor a)
{ AttachActorToJoint( a, GetJntIndxAttachArmLeft() ); }

final function AttachToBackLeft(actor a)
{ AttachActorToJoint( a, GetJntIndxAttachBackLeft() ); }

final function AttachToBackRight(actor a)
{ AttachActorToJoint( a, GetJntIndxAttachBackRight() ); }

final function AttachToHipLeft(actor a)
{ AttachActorToJoint( a, GetJntIndxAttachHipLeft() ); }

final function AttachToHipRight(actor a)
{ AttachActorToJoint( a, GetJntIndxAttachHipRight() ); }

////////////////////////////////////////////////////////////////////////////////
// Detach an actor from an attachment joint and return it
////////////////////////////////////////////////////////////////////////////////
final function Actor DetachFromHandLeft()
{ return DetachActorFromJoint( GetJntIndxAttachHandLeft() ); }

final function Actor DetachFromHandRight()
{ return DetachActorFromJoint( GetJntIndxAttachHandRight() ); }

final function Actor DetachFromArmLeft()
{ return DetachActorFromJoint( GetJntIndxAttachArmLeft() ); }

final function Actor DetachFromBackLeft()
{ return DetachActorFromJoint( GetJntIndxAttachBackLeft() ); }

final function Actor DetachFromBackRight()
{ return DetachActorFromJoint( GetJntIndxAttachBackRight() ); }

final function Actor DetachFromHipLeft()
{ return DetachActorFromJoint( GetJntIndxAttachHipLeft() ); }

final function Actor DetachFromHipRight()
{ return DetachActorFromJoint( GetJntIndxAttachHipRight() ); }

////////////////////////////////////////////////////////////////////////////////
//  Inventory-related joint utility functions
//
//  These functions are used to access the inventory item specific joint
//  functionality.
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//  Weapon attachment
////////////////////////////////////////////////////////////////////////////////
final function AttachToWeaponPrimaryJoint(actor a)
{ AttachToHandRight(a); }

final function AttachToWeaponSecondaryJoint(actor a)
{ AttachToHandLeft(a); }

final function AttachToWeaponStowPrimaryJoint(actor a)
{ AttachToBackRight(a); }

final function AttachToWeaponStowSecondaryJoint(actor a)
{ AttachToHipLeft(a); }

////////////////////////////////////////////////////////////////////////////////
//  Weapon detachment
////////////////////////////////////////////////////////////////////////////////
final function Actor DetachFromWeaponPrimaryJoint()
{ return DetachFromHandRight(); }

final function Actor DetachFromWeaponSecondaryJoint()
{ return DetachFromHandLeft(); }

final function Actor DetachFromWeaponStowPrimaryJoint()
{ return DetachFromBackRight(); }

final function Actor DetachFromWeaponStowSecondaryJoint()
{ return DetachFromHipLeft(); }

////////////////////////////////////////////////////////////////////////////////
//  Shield attachment
////////////////////////////////////////////////////////////////////////////////
final function AttachToShieldJoint(actor a)
{ AttachToArmLeft(a); }

final function AttachToShieldStowJoint(actor a)
{ AttachToHipRight(a); }

////////////////////////////////////////////////////////////////////////////////
//  Shield detachment
////////////////////////////////////////////////////////////////////////////////
final function Actor DetachFromShieldJoint()
{ return DetachFromArmLeft(); }

final function Actor DetachFromShieldStowJoint()
{ return DetachFromHipRight(); }




////////////////////////////////////////////////////////////////////////////////
//  AttachWeaponToWeaponJoint
////////////////////////////////////////////////////////////////////////////////
function AttachWeaponToWeaponJoint(Weapon weaponItem)
{
    AttachToWeaponPrimaryJoint(weaponItem);
}

////////////////////////////////////////////////////////////////////////////////
//  DetachWeaponFromWeaponJoint
////////////////////////////////////////////////////////////////////////////////
function Weapon DetachWeaponFromWeaponJoint()
{
    return Weapon(DetachFromWeaponPrimaryJoint());
}

////////////////////////////////////////////////////////////////////////////////
//  AttachWeaponToStowJoint
////////////////////////////////////////////////////////////////////////////////
function AttachWeaponToStowJoint(Weapon weaponItem, optional byte slot)
{
    // Explicitly handle optional case
    if(slot == 0)
        slot = 0;
    
    // TODO: Implement actual stowing slots
    AttachToWeaponStowPrimaryJoint(weaponItem);
}

////////////////////////////////////////////////////////////////////////////////
//  DetachWeaponFromStowJoint
////////////////////////////////////////////////////////////////////////////////
function Weapon DetachWeaponFromStowJoint(optional byte slot)
{
    // Explicitly handle optional case
    if(slot == 0)
        slot = 0;
    
    // TODO: Implement actual stowing slots
    return Weapon(DetachFromWeaponStowPrimaryJoint());
}

exec function PleaseDrop()
{
    DropWeapon();
}

exec function PleaseStowWeapon()
{
    StowWeapon();
}


////////////////////////////////////////////////////////////////////////////////
//  AttachWeaponToWeaponJoint
////////////////////////////////////////////////////////////////////////////////
function AttachShieldToShieldJoint(Shield shieldItem)
{
    AttachToShieldJoint(shieldItem);
}

function Shield DetachShieldFromShieldJoint()
{
    return Shield(DetachFromShieldJoint());
}

function AttachShieldToStowJoint(Shield shieldItem, optional byte slot)
{
    // Explicitly handle optional case
    if(slot == 0)
        slot = 0;
    
    // TODO: Implement actual stowing slots
    AttachToShieldStowJoint(shieldItem);
}

function Shield DetachShieldFromStowJoint(optional byte slot)
{
    // Explicitly handle optional case
    if(slot == 0)
        slot = 0;
    
    // TODO: Implement actual stowing slots
    return Shield(DetachFromShieldStowJoint());
}

exec function PleaseDropShield()
{
    DropShield();
}


////////////////////////////////////////////////////////////////////////////////
//  GetWeaponClassification
////////////////////////////////////////////////////////////////////////////////
function int GetWeaponClassification(Weapon weaponItem)
{
    // Axes
    if      (weaponItem.IsA('Handaxe'))             return WC_THROWER;
    else if (weaponItem.IsA('GoblinAxe'))           return WC_SECONDARY;
    else if (weaponItem.IsA('VikingAxe'))           return WC_PRIMARY_ONEH;
    else if (weaponItem.IsA('SigurdAxe'))           return WC_PRIMARY_TWOH;
    else if (weaponItem.IsA('DwarfBattleAxe'))      return WC_PRIMARY_TWOH;
    // Swords
    else if (weaponItem.IsA('VikingShortSword'))    return WC_THROWER;
    else if (weaponItem.IsA('RomanSword'))          return WC_SECONDARY;
    else if (weaponItem.IsA('VikingBroadSword'))    return WC_PRIMARY_ONEH;
    else if (weaponItem.IsA('DwarfWorkSword'))      return WC_PRIMARY_TWOH;
    else if (weaponItem.IsA('DwarfBattleSword'))    return WC_PRIMARY_TWOH;
    // Maces
    else if (weaponItem.IsA('RustyMace'))           return WC_THROWER;
    else if (weaponItem.IsA('BoneClub'))            return WC_SECONDARY;
    else if (weaponItem.IsA('TrialPitMace'))        return WC_PRIMARY_ONEH;
    else if (weaponItem.IsA('DwarfWorkHammer'))     return WC_PRIMARY_TWOH;
    else if (weaponItem.IsA('DwarfBattleHammer'))   return WC_PRIMARY_TWOH;
    
    return WC_UNCLASSIFIED;
}



////////////////////////////////////////////////////////////////////////////////
//
//  COMMAND HANDLERS
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// HandleCmdCameraIn
////////////////////////////////////////////////////////////////////////////////
function HandleCmdCameraIn()
{
    CameraDist -= 10;
}

////////////////////////////////////////////////////////////////////////////////
// HandleCmdCameraOut()
////////////////////////////////////////////////////////////////////////////////
function HandleCmdCameraOut()
{
    CameraDist += 10;
}

////////////////////////////////////////////////////////////////////////////////
// HandleCmdZTargetToggle
////////////////////////////////////////////////////////////////////////////////
function HandleCmdZTargetToggle()
{}

////////////////////////////////////////////////////////////////////////////////
// HandleCmdDumpWeaponInfo
////////////////////////////////////////////////////////////////////////////////
function HandleCmdDumpWeaponInfo()
{}

////////////////////////////////////////////////////////////////////////////////
// HandleCmdDropZ
////////////////////////////////////////////////////////////////////////////////
function HandleCmdDropZ()
{}

////////////////////////////////////////////////////////////////////////////////
// HandleCmdTraceTex
////////////////////////////////////////////////////////////////////////////////
function HandleCmdTraceTex()
{}


////////////////////////////////////////////////////////////////////////////////
// Debug
////////////////////////////////////////////////////////////////////////////////
function Debug(Canvas canvas, int mode)
{
    Super.Debug(canvas, mode);
    
    Canvas.DrawText("vmodRunePlayerBase");
    Canvas.CurY -= 8;
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
    
    CameraDist=180.000000
    CameraAccel=7.000000
    CameraHeight=35.000000
    CameraPitch=450.000000
    CameraRotSpeed=(Pitch=20,Yaw=20,Roll=20)
}