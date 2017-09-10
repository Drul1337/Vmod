////////////////////////////////////////////////////////////////////////////////
//	vmodMountBase.uc
//

class vmodMountBase extends Pawn abstract;

// Movement flags
var byte InputFlags;
const MD_NEUTRAL        = 0x00;
const MD_FORWARD        = 0x01;
const MD_BACKWARD       = 0x02;
const MD_LEFT           = 0x04;
const MD_RIGHT          = 0x08;
const MD_FORWARDLEFT    = 0x05;
const MD_FORWARDRIGHT   = 0x09;
const MD_BACKWARDLEFT   = 0x06;
const MD_BACKWARDRIGHT  = 0x0A;
const MD_DIRECTIONMASK	= 0x0F;
const MD_UP				= 0x10;
const MD_DOWN			= 0x20;

// Positioning
var Vector RiderOffset;

// Animation
var name AnimIdle;
var name AnimRun;
var name AnimWalk;
var name AnimJump;
var name AnimHitFront;
var name AnimDeathFront;
var name AnimDeathLeft;
var name AnimDeathRight;
var name AnimDeathBack;
var name AnimDeathDrown;

simulated event Tick(float dt)
{
	local Vector MountX, MountY, MountZ;
	local Vector MoveDirection2D;
	local Vector RiderLocation;
	local float AccelMagnitude;
	local byte TempInputFlags;
	local Vector JointPos;
	
	if(Owner == None)
		return;
	
	GetAxes(Rotation, MountX, MountY, MountZ);
	
	MoveDirection2D.X = 0.0;
	MoveDirection2D.Y = 0.0;
	MoveDirection2D.Z = 0.0;
	
	TempInputFlags = InputFlags & MD_DIRECTIONMASK;
	
	switch(TempInputFlags)
	{
		case MD_FORWARD:		MoveDirection2D = MountX;			break;
		case MD_LEFT:			MoveDirection2D = -MountY;			break;
		case MD_RIGHT:			MoveDirection2D = MountY;			break;
		case MD_BACKWARD:		MoveDirection2D = -MountX;			break;
		case MD_FORWARDLEFT:	MoveDirection2D = MountX - MountY;	break;
		case MD_FORWARDRIGHT:	MoveDirection2D = MountX + MountY;	break;
		case MD_BACKWARDLEFT:	MoveDirection2D = -MountX - MountY;	break;
		case MD_BACKWARDRIGHT:	MoveDirection2D = -MountX + MountY;	break;
	}
	
	MoveDirection2D = Normal(MoveDirection2D);
	
	Acceleration = MoveDirection2D * GroundSpeed;
	SetRotation(Owner.Rotation);
	
	// Glue the owner to the mount
	JointPos = GetJointPos(1);
	RiderLocation = Location;
	RiderLocation += (MountX * RiderOffset.X);
	RiderLocation += (MountY * RiderOffset.Y);
	RiderLocation += (MountZ * RiderOffset.Z);
	RiderLocation.X += (JointPos.X - Location.X);
	RiderLocation.Y += (JointPos.Y - Location.Y);
	RiderLocation.Z += (JointPos.Z - Location.Z);
	Owner.SetLocation(RiderLocation);
	
	// Play mount animation
	AccelMagnitude = VSize2D(Acceleration);
	if(AccelMagnitude < 20.0)
	{
		LoopAnim(AnimIdle, 1.0, 0.1);
	}
	else
	{
		if(AccelMagnitude < 300.0)
			LoopAnim(AnimWalk, 1.0, 0.1);
		else
			LoopAnim(AnimRun, 1.0, 0.1);
	}
	
	// Play owner animation
	Owner.LoopAnim('crouch_idle', 1.0, 0.1);
	
	// Handle jump or dismount
	TempInputFlags = InputFlags & ~MD_DIRECTIONMASK;
	if(TempInputFlags == MD_UP)
	{
		Jump();
	}
	else if(TempInputFlags == MD_DOWN)
	{
		HandlePlayerDismount();
	}
}

// Input recieved from owner
simulated function RecievePlayerInput(
	float iForward,
	float iStrafe,
	float iUp)
{
	local float iEpsilon;
	
	InputFlags = 0;
	iEpsilon = 0.001;
	
	if(iForward > iEpsilon)			InputFlags = InputFlags | MD_FORWARD;
	else if(iForward < -iEpsilon)	InputFlags = InputFlags | MD_BACKWARD;
	
	if(iStrafe > iEpsilon)			InputFlags = InputFlags | MD_RIGHT;
	else if(iStrafe < -iEpsilon)	InputFlags = InputFlags | MD_LEFT;
	
	if(iUp > iEpsilon)				InputFlags = InputFlags | MD_UP;
	else if(iUp < -iEpsilon)		InputFlags = InputFlags | MD_DOWN;
}

// Owner is mounting
function HandlePlayerMount(actor Other)
{
	if(vmodRunePlayer(Other) == None)
		return;
	
	SetOwner(Other);
	vmodRunePlayer(Other).Mount = self;
	vmodRunePlayer(Other).SetCollision(false, false, false);
	vmodRunePlayer(Other).bCollideWorld = false;
}

// Owner is dismounting
function HandlePlayerDismount()
{
	local Vector MountX, MountY, MountZ;
	local Actor OldOwner;
	
	GetAxes(Rotation, MountX, MountY, MountZ);
	Owner.Acceleration.X = 0.0;
	Owner.Acceleration.Y = 0.0;
	Owner.Acceleration.Z = 0.0;
	Owner.Velocity.X = 0.0;
	Owner.Velocity.Y = 0.0;
	Owner.Velocity.Z = 0.0;
	Owner.SetLocation(Location + MountZ * 40.0);
	Owner.SetCollision(true, true, true);
	Owner.bCollideWorld = true;
	Owner.SetPhysics(PHYS_Falling);
	
	vmodRunePlayer(Owner).Mount = None;
	SetOwner(None);
	
	Acceleration.X = 0.0;
	Acceleration.Y = 0.0;
	Acceleration.Z = 0.0;
	InputFlags = 0;
	
	GoToState('Idle');
	LoopAnim(AnimIdle, 1.0, 0.1);
}

// Apply jump impulse velocity
function Jump()
{
	if(Physics != PHYS_Walking)
		return;
	
	Velocity.Z = Velocity.Z + 500.0;
	SetPhysics(PHYS_Falling);
}

////////////////////////////////////////////////////////////////////////////////
//	State Startup
//	Mount was just spawned
auto state Startup
{
Begin:
	SetPhysics(PHYS_Falling);
	GoToState('Idle');
}

////////////////////////////////////////////////////////////////////////////////
//	State Idle
//	Mount does not have an owner, standing idle
state Idle
{
	function name GetUseAnim()
	{
		return 'Neutral_Kick';
	}
	
	function bool CanBeUsed(actor Other)
	{
		if(vmodRunePlayer(Other) != None)
			return true;
		return false;
	}
	
	function int GetUsePriority()
	{
		return 1;
	}
	
	function bool UseTrigger(actor Other)
	{
		HandlePlayerMount(Other);
		return true;
	}
}

////////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	DrawType=DT_SkeletalMesh
    Skeletal=None
	AnimIdle=None
    AnimRun=None
    AnimWalk=None
    AnimJump=None
    AnimHitFront=None
    AnimDeathFront=None
    AnimDeathLeft=None
    AnimDeathRight=None
    AnimDeathBack=None
    AnimDeathDrown=None
	RiderOffset=(X=0.0,Y=0.0,Z=0.0)
	DesiredSpeed=1.0
	MaxDesiredSpeed=1.0
	GroundSpeed=600.0
	bCanLook=true
}