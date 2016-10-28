////////////////////////////////////////////////////////////////////////////////
//  vmodPlayerPawnBase.uc
//
//      |---Object
//          |---Actor
//              |---Pawn
//                  |---PlayerPawn
//                      |---vmodPlayerPawnBase
//
//  This class is responsible for providing base PlayerPawn modifications for
//  all PlayerPawn classes in vmod. The original RunePlayer class has been
//  broken up into several inherited classes. Much of the base PlayerPawn
//  functionality from the original RunePlayer class has been moved to this
//  class.
//
//  The vmodPlayerPawn class should NOT be extended directly. Extend the
//  vmodPlayerPawnInterface class instead, which provides a command interface
//  into this class.
//

//  Commands
//
//  TODO: This is not yet implemented
//
//  All incoming commands go through the following process:
//  Command
//      --> Can I perform the command?
//          --> Do I need to set any flags before I execute the command?
//              --> Apply the command
//                  --> Play an animation if there is one associated
//
//  Example: Jump --> Can jump? --> Set jump flags --> Apply jump force --> Play jump animation

class vmodPlayerPawnBase extends PlayerPawn config(user) abstract;


// TODO: Implement playerpawn as a state machine
// TODO: Fix the cameradist so it always zooms in / out in constant time
// TODO: Enable weapon swipe trails
// TODO: Finish implementing PlayerPawn independent of AnimationProxy
// TODO: Get rid of these weapon stow meshes - just unnecessary


// Note: If any states are added / removed, Debug() needs to be updated
////////////////////////////////////////////////////////////////////////////////
// Move direction flags         Bits 1-4 (4 bits)
const MD_BITS                   = 0x000F;   // All direction bits enabled
const MD_NEUTRAL                = 0x0000;   // No direction
const MD_FORWARD                = 0x0001;   // Forward
const MD_BACKWARD               = 0x0002;   // Backward
const MD_LEFT                   = 0x0004;   // Left
const MD_RIGHT                  = 0x0008;   // Right
const MD_FORWARDLEFT            = 0x0005;   // Forward left 45 degrees
const MD_FORWARDRIGHT           = 0x0009;   // Forward right 45 degrees
const MD_BACKWARDLEFT           = 0x0006;   // Backward left 45 degrees
const MD_BACKWARDRIGHT          = 0x000A;   // Backward right 45 degrees

////////////////////////////////////////////////////////////////////////////////
// Move type flags              Bits 5-9 (5 bits)
const MT_BITS                   = 0x01F0;   // All move type bits enabled
const MT_NEUTRAL                = 0x0000;   // Neutral, standing idle
const MT_DODGE                  = 0x0010;   // Just went into a dodge
const MT_EDGEHANG               = 0x0020;   // Hanging from an edge
const MT_EDGEPULLUP             = 0x0030;   // Pulling self up from edge
const MT_JUMP                   = 0x0040;   // Just went into a jump
const MT_LAND                   = 0x0050;   // Just landed

////////////////////////////////////////////////////////////////////////////////
// Variation flags              Bits 15-16 (2 bits)
const VR_BITS                   = 0xC000;   // All variation bits enabled
const VR_0                      = 0x0000;   // Default animation
const VR_1                      = 0x4000;   // Variation #1
const VR_2                      = 0x8000;   // Variation #2
const VR_3                      = 0xC000;   // Variation #3

////////////////////////////////////////////////////////////////////////////////
//  Movement flags
const MV_FIRE       = 0x01;
const MV_ALTFIRE    = 0x02;
const MV_JUMP       = 0x04;
const MV_NEWRUN     = 0x08;
const MV_NEWDUCK    = 0x10;
const MV_NEWJUMP    = 0x20;
    

////////////////////////////////////////////////////////////////////////////////
//  MovementMask
//  Upper 16 bits:  Saved movement mask
//  Lower 16 bits:  Current movement mask
var int MovementMask;
var name AttackAnimation;
var int MovementKeys[32];
var name MovementValues[32];


////////////////////////////////////////////////////////////////////////////////
// PlayerPawn variables
var class<AnimationProxy> AnimationProxyClass;

// TODO: Create a vmodPlayerCamera class to encapsulate these
var vector OldCameraStart;
var(Camera) float CameraDist;
var(Camera) float CameraAccel;
var(Camera) float CameraHeight;
var(Camera) float CameraPitch;
var(Camera) rotator CameraRotSpeed;
var(Camera) float TranslucentDist;
var rotator CurrentRotation;
var float LastTime;
var float CurrentTime;
var float CurrentDist;

var rotator SavedCameraRot;
var vector  SavedCameraLoc;
var bool bCameraOverhead;

var rotator ShakeDelta;



////////////////////////////////////////////////////////////////////////////////
//
//  REPLICATION BLOCK
//
////////////////////////////////////////////////////////////////////////////////
replication
{
    // Server --> Client Variables
    unreliable if(bNetOwner && Role == ROLE_Authority)
        CameraAccel,
        CameraDist,
        CameraPitch,
        CameraHeight,
        CameraRotSpeed;
    
    // Client --> Server Functions
    reliable if(Role < ROLE_Authority)
        VServerMove;
}


////////////////////////////////////////////////////////////////////////////////
//
//  ACTOR OVERRIDES
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//  PreBeginPlay
////////////////////////////////////////////////////////////////////////////////
event PreBeginPlay()
{
    Super(PlayerPawn).PreBeginPlay();
    
    Enable('Tick');
    
    OldCameraStart = Location;
    OldCameraStart.Z += CameraHeight;
    
    // Attempt to spawn animation proxy
    // TODO: Enable this again once we have animation proxy decoupled
    SpawnAnimationProxy();
}

event PostBeginPlay()
{
    local int i;
    //myDebugHud = spawn(class'Engine.DebugHUD', self);
    Super.PostBeginPlay();
}

////////////////////////////////////////////////////////////////////////////////
//  SpawnAnimationProxy
////////////////////////////////////////////////////////////////////////////////
function SpawnAnimationProxy()
{
    if (Skeletal == None)
    {
        // TODO: What's SLog? Maybe we can give a more helpful message
        SLog("Only skeletal actors can spawn Animation Proxies");
        return;
    }

    AnimProxy = spawn(AnimationProxyClass, self);
}


////////////////////////////////////////////////////////////////////////////////
//  PostRender
////////////////////////////////////////////////////////////////////////////////
event PostRender( canvas Canvas )
{
    Super.PostRender(Canvas);
    myDebugHud.PostRender(Canvas);
    Debug(Canvas, HUD_ACTOR);
}







////////////////////////////////////////////////////////////////////////////////
//
//  PAWN OVERRIDES
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//  ClientReStart
////////////////////////////////////////////////////////////////////////////////
function ClientReStart()
{
    // TODO: More camera stuff that needs to be moved
    // TODO: When does clientrestart get called?
    // Reset client-side camera
    OldCameraStart = Location;
    OldCameraStart.Z += CameraHeight;
    CurrentDist = CameraDist;
    LastTime = 0;
    CurrentTime = 0;
    CurrentRotation = Rotation;

    Super.ClientRestart();
}





////////////////////////////////////////////////////////////////////////////////
//
//  vmodPlayerPawnBase
//
////////////////////////////////////////////////////////////////////////////////





////////////////////////////////////////////////////////////////////////////////
//  Movement mask utility functions
//
//  These functions should be used exclusively to set / get information from
//  the animation mask. Do not directly manipulate the animation mask.
////////////////////////////////////////////////////////////////////////////////
function int GetMoveDirectionFlags(){ return MovementMask & MD_BITS; }
function int GetMoveTypeFlags()     { return MovementMask & MT_BITS; }
function int GetVariationFlags()    { return MovementMask & VR_BITS; }

function SetMoveDirectionFlags(int mdFlags)
{
    MovementMask = MovementMask & ~MD_BITS;
    MovementMask = MovementMask | mdFlags;
}

function SetMoveTypeFlags(int mtFlags)
{
    MovementMask = MovementMask & ~MT_BITS;
    MovementMask = MovementMask | mtFlags;
}

function SetVariationFlags(int vrFlags)
{
    MovementMask = MovementMask & ~VR_BITS;
    MovementMask = MovementMask | vrFlags;
}

////////////////////////////////////////////////////////////////////////////////
//  PLAYER INPUT
//
//  Input variables
//
//  [Pawn] - Input buttons
//  bZoom
//  bRun            Alias Walking = Command="Button bRun"
//  bLook
//  bDuck           Alias Duck = Command="Button bDuck | Axis aUp Speed=-300.0"
//  bSnapLevel
//  bStrafe         Alias Strafe = Command="Button bStrafe"
//  bFire           Alias Fire = Command="Button bFire | Fire"
//  bAltFire        Alias AltFire = Command="Button bAltFire | AltFire"
//  bFreeLook       Alias FreeLook = Command="Button bFreeLook"
//  bExtra0         Unused
//  bExtra1         Unused
//  bExtra2         Unused
//  bExtra3         Unused
//
//  [PlayerPawn] - Input axes
//  aBaseX          + TurnRight     - TurnLeft
//  aBaseY          + MoveForward   - MoveBackward
//  aBaseZ          Unused
//  aMouseX
//  aMouseY
//  aForward
//  aTurn
//  aStrafe         + StrafeRight   - StrafeLeft
//  aUp             + Jump          - Crouch
//  aLookUp         + LookUp        - LookDown
//  aExtra0         Unused
//  aExtra1         Unused
//  aExtra2         Unused
//  aExtra3         Unused
//  aExtra4         Unused



////////////////////////////////////////////////////////////////////////////////
//  PlayerInput
//
//  There are two primary mechanisms that allow a user to interact with a
//  PlayerPawn. The first is through a set of input variables which may be
//  mapped to in-game aliases, and the second is through functions declared
//  with the 'exec' specifier. This function deals with the former.
////////////////////////////////////////////////////////////////////////////////
event PlayerInput(float DeltaTime)
{
    // Update movement flags according to user input
    PlayerInputUpdateMoveDirectionFlags(aBaseY, aStrafe);
    
    Super.PlayerInput(DeltaTime);
}

////////////////////////////////////////////////////////////////////////////////
//  PlayerInputUpdateMoveDirectionFlags
////////////////////////////////////////////////////////////////////////////////
function PlayerInputUpdateMoveDirectionFlags(
    float inputAxisForward,
    float inputAxisStrafe)
{
    local int mdFlags;
    local float inputEpsilon;
    
    mdFlags = MD_NEUTRAL;
    inputEpsilon = 0.001;
    
    if(inputAxisForward > inputEpsilon)         mdFlags = mdFlags | MD_FORWARD;
    else if(inputAxisForward < -inputEpsilon)   mdFlags = mdFlags | MD_BACKWARD;
    if(inputAxisStrafe > inputEpsilon)          mdFlags = mdFlags | MD_RIGHT;
    else if(inputAxisStrafe < -inputEpsilon)    mdFlags = mdFlags | MD_LEFT;
    
    SetMoveDirectionFlags(mdFlags);
}



function DoDodge(eDodgeDir dodgeMove)
{
    // TODO: This is the main dodge code, could use some reworking
    local vector X,Y,Z;
    
    // Verify the pawn can dodge
    if(Physics != PHYS_Walking)
        return;
    
    SetMoveTypeFlags(MT_DODGE);

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

function DoJump(optional float F)
{
    if(Physics != PHYS_Walking)
        return;
    
    // Verify the pawn can jump
    if(Physics != PHYS_Walking)
        return;
    
    SetMoveTypeFlags(MT_JUMP);

    if ( !bUpdating )
        PlayOwnedSound(JumpSound, SLOT_Talk, 1.5, true, 1200, 1.0 );
    if ( (Level.Game != None) && (Level.Game.Difficulty > 0) )
        MakeNoise(0.1 * Level.Game.Difficulty);
    PlayInAir(0.1);
    if ( bCountJumps && (Role == ROLE_Authority) && (Inventory != None) )
        Inventory.OwnerJumped();
    Velocity.Z = JumpZ;
    if ( (Base != Level) && (Base != None) )
        Velocity.Z += Base.Velocity.Z; 
    SetPhysics(PHYS_Falling);
}

function Landed(vector HitNormal, actor HitActor)
{
    SetMoveTypeFlags(MT_LAND);
    
    Super.Landed(HitNormal, HitActor);
}

function PlayStateAnimation() {}


////////////////////////////////////////////////////////////////////////////////
//  Tick
////////////////////////////////////////////////////////////////////////////////
simulated event Tick(float DeltaTime)
{
    // Update Camera Timer
    CurrentTime += DeltaTime / Level.TimeDilation;
    
    // Handle level fade in
    if (LevelFadeAlpha > 0)
    {
        LevelFadeAlpha -= DeltaTime * Level.FadeRate;
        if (LevelFadeAlpha < 0)
            LevelFadeAlpha = 0;
    }
    
    Super.Tick(DeltaTime);
}

////////////////////////////////////////////////////////////////////////////////
//  PlayerTick
////////////////////////////////////////////////////////////////////////////////
event PlayerTick( float DeltaTime )
{
    if ( bUpdatePosition )
        ClientUpdatePosition();

    PlayerMove(DeltaTime);
}

////////////////////////////////////////////////////////////////////////////////
//  ClientUpdatePosition
////////////////////////////////////////////////////////////////////////////////
function ClientUpdatePosition()
{
	local SavedMove CurrentMove;
	local int realbRun, realbDuck;
	local bool bRealJump;

	local float AdjPCol, SavedRadius, TotalTime;
	local pawn SavedPawn, P;
	local vector Dist;

	bUpdatePosition = false;
	realbRun= bRun;
	realbDuck = bDuck;
	bRealJump = bPressedJump;
	CurrentMove = SavedMoves;
	bUpdating = true;
	while ( CurrentMove != None )
	{
		if ( CurrentMove.TimeStamp <= CurrentTimeStamp )
		{
			SavedMoves = CurrentMove.NextMove;
			CurrentMove.NextMove = FreeMoves;
			FreeMoves = CurrentMove;
			FreeMoves.Clear();
			CurrentMove = SavedMoves;
		}
		else
		{
			// adjust radius of nearby players with uncertain location
			if ( TotalTime > 0 )
				ForEach AllActors(class'Pawn', P)
					if ( (P != self) && (P.Velocity != vect(0,0,0)) && P.bBlockPlayers )
					{
						Dist = P.Location - Location;
						AdjPCol = 0.0004 * PlayerReplicationInfo.Ping * ((P.Velocity - Velocity) Dot Normal(Dist));
						if ( VSize(Dist) < AdjPCol + P.CollisionRadius + CollisionRadius + CurrentMove.Delta * GroundSpeed * (Normal(Velocity) Dot Normal(Dist)) )
						{
							SavedPawn = P;
							SavedRadius = P.CollisionRadius;
							Dist.Z = 0;
							P.SetCollisionSize(FClamp(AdjPCol + P.CollisionRadius, 0.5 * P.CollisionRadius, VSize(Dist) - CollisionRadius - P.CollisionRadius), P.CollisionHeight);
							break;
						}
					} 
			TotalTime += CurrentMove.Delta;
			MoveAutonomous(CurrentMove.Delta, CurrentMove.bRun, CurrentMove.bDuck, CurrentMove.bPressedJump, 
				CurrentMove.DodgeMove, CurrentMove.Acceleration, rot(0,0,0));
			CurrentMove = CurrentMove.NextMove;
			if ( SavedPawn != None )
			{
				SavedPawn.SetCollisionSize(SavedRadius, P.CollisionHeight);
				SavedPawn = None;
			}
		}
	}
	bUpdating = false;
	bDuck = realbDuck;
	bRun = realbRun;
	bPressedJump = bRealJump;
	//log("Client adjusted "$self$" stamp "$CurrentTimeStamp$" location "$Location$" dodge "$DodgeDir);
}

////////////////////////////////////////////////////////////////////////////////
//  PlayerMove
////////////////////////////////////////////////////////////////////////////////
function PlayerMove( float DeltaTime )
{
    local Vector        X,Y,Z;
    local Vector        NewAccel;
    local EDodgeDir     OldDodge;
    local eDodgeDir     DodgeMove;
    local Rotator       DeltaRotation;

    GetAxes(ViewRotation,X,Y,Z);

    aForward    *= 0.4;
    aStrafe     *= 0.4;
    aLookup     *= 0.24;
    aTurn       *= 0.24;
    aUp         *= 0.0;

    // Update acceleration.
    NewAccel = aForward*X + aStrafe*Y;
    NewAccel.Z = 0;

    // Update rotation.
    DeltaRotation = Rotation;
    UpdateRotation(DeltaTime, 1);
    DeltaRotation = DeltaRotation - Rotation;
    
    if ( Role < ROLE_Authority )    // Client simulates local movement and
        ReplicateMove(              // replicates to server
            DeltaTime,
            NewAccel,
            DodgeMove,
            DeltaRotation);
    else                            // Server processes move
        ProcessMove(
            DeltaTime,
            NewAccel,
            DodgeMove,
            DeltaRotation);
}

////////////////////////////////////////////////////////////////////////////////
//  UpdateRotation
////////////////////////////////////////////////////////////////////////////////
function UpdateRotation(float DeltaTime, float maxPitch)
{
	local rotator newRotation;
	
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

////////////////////////////////////////////////////////////////////////////////
//  ReplicateMove
////////////////////////////////////////////////////////////////////////////////
function ReplicateMove
(
	float       DeltaTime,
	Vector      NewAccel,
	EDodgeDir   DodgeMove,
	Rotator     DeltaRot
)
{
	local SavedMove NewMove, OldMove, LastMove;
	local byte ClientRoll;
	local int i;
	local float OldTimeDelta, TotalTime, NetMoveDelta;
	local int OldAccel;
	local vector BuildAccel, AccelNorm;

	local float AdjPCol, SavedRadius;
	local pawn SavedPawn, P;
	local vector Dist;
    local byte MoveFlags;

	// Get a SavedMove actor to store the movement in.
	if ( PendingMove != None )
	{
		//add this move to the pending move
		PendingMove.TimeStamp = Level.TimeSeconds; 
		if ( VSize(NewAccel) > 3072 )
			NewAccel = 3072 * Normal(NewAccel);
		TotalTime = PendingMove.Delta + DeltaTime;
		PendingMove.Acceleration = (DeltaTime * NewAccel + PendingMove.Delta * PendingMove.Acceleration)/TotalTime;

		// Set this move's data.
		if ( PendingMove.DodgeMove == DODGE_None )
			PendingMove.DodgeMove = DodgeMove;
        
		PendingMove.bRun            = (bRun > 0);
		PendingMove.bDuck           = (bDuck > 0);
		PendingMove.bPressedJump    = bPressedJump || PendingMove.bPressedJump;
		PendingMove.bFire           = PendingMove.bFire || bJustFired || (bFire != 0);
		PendingMove.bForceFire      = PendingMove.bForceFire || bJustFired;
		PendingMove.bAltFire        = PendingMove.bAltFire || bJustAltFired || (bAltFire != 0);
		PendingMove.bForceAltFire   = PendingMove.bForceAltFire || bJustFired;
		PendingMove.Delta           = TotalTime;
	}
	if ( SavedMoves != None )
	{
		NewMove = SavedMoves;
		AccelNorm = Normal(NewAccel);
		while ( NewMove.NextMove != None )
		{
			// find most recent interesting move to send redundantly
			if ( NewMove.bPressedJump || ((NewMove.DodgeMove != Dodge_NONE) && (NewMove.DodgeMove < 5))
				|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
				OldMove = NewMove;
			NewMove = NewMove.NextMove;
		}
		if ( NewMove.bPressedJump || ((NewMove.DodgeMove != Dodge_NONE) && (NewMove.DodgeMove < 5))
			|| ((NewMove.Acceleration != NewAccel) && ((normal(NewMove.Acceleration) Dot AccelNorm) < 0.95)) )
			OldMove = NewMove;
	}

	LastMove = NewMove;
	NewMove = GetFreeMove();
	NewMove.Delta = DeltaTime;
	if ( VSize(NewAccel) > 3072 )
		NewAccel = 3072 * Normal(NewAccel);
	NewMove.Acceleration = NewAccel;

	// Set this move's data.
	NewMove.DodgeMove       = DodgeMove;
	NewMove.TimeStamp       = Level.TimeSeconds;
	NewMove.bRun            = (bRun > 0);
	NewMove.bDuck           = (bDuck > 0);
	NewMove.bPressedJump    = bPressedJump;
	NewMove.bFire           = (bJustFired || (bFire != 0));
	NewMove.bForceFire      = bJustFired;
	NewMove.bAltFire        = (bJustAltFired || (bAltFire != 0));
	NewMove.bForceAltFire   = bJustAltFired;

	bJustFired = false;
	bJustAltFired = false;
	
	// adjust radius of nearby players with uncertain location
	ForEach AllActors(class'Pawn', P)
    {
		if ( (P != self) && (P.Velocity != vect(0,0,0)) && P.bBlockPlayers )
		{
			Dist = P.Location - Location;
			AdjPCol = 0.0004 * PlayerReplicationInfo.Ping * ((P.Velocity - Velocity) Dot Normal(Dist));
			if ( VSize(Dist) < AdjPCol + P.CollisionRadius + CollisionRadius + NewMove.Delta * GroundSpeed * (Normal(Velocity) Dot Normal(Dist)) )
			{
				SavedPawn = P;
				SavedRadius = P.CollisionRadius;
				Dist.Z = 0;
				P.SetCollisionSize(FClamp(
                                    AdjPCol + P.CollisionRadius,
                                    0.5 * P.CollisionRadius,
                                    VSize(Dist) - CollisionRadius - P.CollisionRadius),
                                    P.CollisionHeight);
				break;
			}
		}
    }
    
	// Simulate the movement locally.
	ProcessMove(NewMove.Delta, NewMove.Acceleration, NewMove.DodgeMove, DeltaRot);
	AutonomousPhysics(NewMove.Delta);
    
	if ( SavedPawn != None )
		SavedPawn.SetCollisionSize(SavedRadius, P.CollisionHeight);

	// Decide whether to hold off on move
	// send if dodge, jump, or fire unless really too soon, or if newmove.delta big enough
	// on client side, save extra buffered time in LastUpdateTime
	if ( PendingMove == None )
		PendingMove = NewMove;
	else
	{
		NewMove.NextMove = FreeMoves;
		FreeMoves = NewMove;
		FreeMoves.Clear();
		NewMove = PendingMove;
	}
	NetMoveDelta = FMax(64.0/Player.CurrentNetSpeed, 0.011);
	
	if ( !PendingMove.bForceFire && !PendingMove.bForceAltFire && !PendingMove.bPressedJump
		&& (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
	{
		// save as pending move
		return;
	}
	else if ( (ClientUpdateTime < 0) && (PendingMove.Delta < NetMoveDelta - ClientUpdateTime) )
		return;
	else
	{
		ClientUpdateTime = PendingMove.Delta - NetMoveDelta;
		if ( SavedMoves == None )
			SavedMoves = PendingMove;
		else
			LastMove.NextMove = PendingMove;
		PendingMove = None;
	}

	// check if need to redundantly send previous move
	if ( OldMove != None )
	{
        // old move important to replicate redundantly
		OldTimeDelta    = FMin(255, (Level.TimeSeconds - OldMove.TimeStamp) * 500);
		BuildAccel      = 0.05 * OldMove.Acceleration + vect(0.5, 0.5, 0.5);
		OldAccel        = (CompressAccel(BuildAccel.X) << 23) +
                          (CompressAccel(BuildAccel.Y) << 15) +
                          (CompressAccel(BuildAccel.Z) << 7);
                    
		if ( OldMove.bRun )         OldAccel += 64;
		if ( OldMove.bDuck )        OldAccel += 32;
		if ( OldMove.bPressedJump ) OldAccel += 16;
        
		OldAccel += OldMove.DodgeMove;
	}
    
	// Send to the server
	ClientRoll = (Rotation.Roll >> 8) & 255;
	if ( NewMove.bPressedJump )
		bJumpStatus = !bJumpStatus;
    
    MoveFlags = 0;
    if(NewMove.bRun)        MoveFlags = MoveFlags | MV_NEWRUN;
    if(NewMove.bDuck)       MoveFlags = MoveFlags | MV_NEWDUCK;
    if(bJumpStatus)         MoveFlags = MoveFlags | MV_JUMP;
    if(NewMove.bFire)       MoveFlags = MoveFlags | MV_FIRE;
    if(NewMove.bAltFire)    MoveFlags = MoveFlags | MV_ALTFIRE;
    
    VServerMove(
        NewMove.TimeStamp,
        NewMove.Acceleration,
        Location,
        MoveFlags,
        NewMove.DodgeMove,
        ClientRoll,
        (32767 & (ViewRotation.Pitch/2)) * 32768 + (32767 & (ViewRotation.Yaw/2)),
        OldTimeDelta,
        OldAccel);
}

////////////////////////////////////////////////////////////////////////////////
//  ServerMove
////////////////////////////////////////////////////////////////////////////////
function ServerMove
(
	float TimeStamp, 
	Vector InAccel,
	Vector ClientLoc,
    
	bool NewbRun,
	bool NewbDuck,
	bool NewbJumpStatus,
	bool bFired,
	bool bAltFired,
	bool bForceFire,
	bool bForceAltFire,
    
	eDodgeDir DodgeMove, 
	byte ClientRoll, 
	int View,
	optional byte OldTimeDelta,
	optional int OldAccel
)
{
	local float DeltaTime, clientErr, OldTimeStamp;
	local rotator DeltaRot, Rot;
	local vector Accel, LocDiff;
	local int maxPitch, ViewPitch, ViewYaw;
	local actor OldBase;

	local bool NewbPressedJump, OldbRun, OldbDuck;
	local eDodgeDir OldDodgeMove;
    
	// If this move is outdated, discard it.
	if ( CurrentTimeStamp >= TimeStamp )
		return;

	// Update bReadyToPlay for clients
	if ( PlayerReplicationInfo != None )
		PlayerReplicationInfo.bReadyToPlay = bReadyToPlay;

	//// if OldTimeDelta corresponds to a lost packet, process it first
	//if (  OldTimeDelta != 0 )
	//{
	//	OldTimeStamp = TimeStamp - float(OldTimeDelta)/500 - 0.001;
	//	if ( CurrentTimeStamp < OldTimeStamp - 0.001 )
	//	{
	//		// split out components of lost move (approx)
	//		Accel.X = OldAccel >>> 23;
	//		if ( Accel.X > 127 )
	//			Accel.X = -1 * (Accel.X - 128);
	//		Accel.Y = (OldAccel >>> 15) & 255;
	//		if ( Accel.Y > 127 )
	//			Accel.Y = -1 * (Accel.Y - 128);
	//		Accel.Z = (OldAccel >>> 7) & 255;
	//		if ( Accel.Z > 127 )
	//			Accel.Z = -1 * (Accel.Z - 128);
	//		Accel *= 20;
	//		
	//		OldbRun = ( (OldAccel & 64) != 0 );
	//		OldbDuck = ( (OldAccel & 32) != 0 );
	//		NewbPressedJump = ( (OldAccel & 16) != 0 );
	//		if ( NewbPressedJump )
	//			bJumpStatus = NewbJumpStatus;
    //
	//		switch (OldAccel & 7)
	//		{
	//			case 0:
	//				OldDodgeMove = DODGE_None;
	//				break;
	//			case 1:
	//				OldDodgeMove = DODGE_Left;
	//				break;
	//			case 2:
	//				OldDodgeMove = DODGE_Right;
	//				break;
	//			case 3:
	//				OldDodgeMove = DODGE_Forward;
	//				break;
	//			case 4:
	//				OldDodgeMove = DODGE_Back;
	//				break;
	//		}
	//		MoveAutonomous(
    //            OldTimeStamp - CurrentTimeStamp,
    //            OldbRun, OldbDuck,
    //            NewbPressedJump,
    //            OldDodgeMove,
    //            Accel,
    //            rot(0,0,0));
	//		CurrentTimeStamp = OldTimeStamp;
	//	}
	//}

	//// View components
	//ViewPitch = View/32768;
	//ViewYaw = 2 * (View - 32768 * ViewPitch);
	//ViewPitch *= 2;
    
	//// Make acceleration.
	//Accel = InAccel/10;
    Accel = InAccel;

	//NewbPressedJump = (bJumpStatus != NewbJumpStatus);
	//bJumpStatus = NewbJumpStatus;

	//// handle firing and alt-firing
	//if(bFired)
	//{
	//	if(bForceFire && (Weapon != None) )
	//	{
	//		Fire(0);
	//	}
	//	else if(bFire == 0)
	//	{
	//		Fire(0);
	//	}
	//	bFire = 1;
	//}
	//else
	//	bFire = 0;


	//if(bAltFired)
	//{
	//	if(bForceAltFire && (Shield != None))
	//		AltFire(0);
	//	else if(bAltFire == 0)
	//		AltFire(0);
	//	bAltFire = 1;
	//}
	//else
	//	bAltFire = 0;

	// Save move parameters.
	DeltaTime = TimeStamp - CurrentTimeStamp;
	if ( ServerTimeStamp > 0 )
	{
		// allow 1% error
		TimeMargin += DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp);
		if ( TimeMargin > MaxTimeMargin )
		{
			// player is too far ahead
			TimeMargin -= DeltaTime;
			if ( TimeMargin < 0.5 )
				MaxTimeMargin = Default.MaxTimeMargin;
			else
				MaxTimeMargin = 0.5;
			DeltaTime = 0;
		}
	}

	CurrentTimeStamp = TimeStamp;
	ServerTimeStamp = Level.TimeSeconds;
	Rot.Roll = 256 * ClientRoll;
	Rot.Yaw = ViewYaw;
	if ( (Physics == PHYS_Swimming) || (Physics == PHYS_Flying) )
		maxPitch = 2;
	else
		maxPitch = 1;
	If ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
	{
		If (ViewPitch < 32768) 
			Rot.Pitch = maxPitch * RotationRate.Pitch;
		else
			Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
	}
	else
		Rot.Pitch = ViewPitch;
	DeltaRot = (Rotation - Rot);
	ViewRotation.Pitch = ViewPitch;
	ViewRotation.Yaw = ViewYaw;
	ViewRotation.Roll = 0;
	SetRotation(Rot);

	OldBase = Base;

	// Perform actual movement.
	if ( (Level.Pauser == "") && (DeltaTime > 0) )
		MoveAutonomous(
            DeltaTime,
            NewbRun,
            NewbDuck,
            NewbPressedJump,
            DodgeMove,
            Accel,
            DeltaRot);

	// Accumulate movement error.
	if ( Level.TimeSeconds - LastUpdateTime > 500.0/Player.CurrentNetSpeed )
		ClientErr = 10000;
	else if ( Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed )
	{
		LocDiff = Location - ClientLoc;
		ClientErr = LocDiff Dot LocDiff;
	}

	// If client has accumulated a noticeable positional error, correct him.
	if ( ClientErr > 3 )
	{
		if ( Mover(Base) != None )
			ClientLoc = Location - Base.Location;
		else
			ClientLoc = Location;
        
		LastUpdateTime = Level.TimeSeconds;
		ClientAdjustPosition(
			TimeStamp, 
			GetStateName(), 
			Physics, 
			ClientLoc.X, 
			ClientLoc.Y, 
			ClientLoc.Z, 
			Velocity.X, 
			Velocity.Y, 
			Velocity.Z,
			Base);
	}
}

////////////////////////////////////////////////////////////////////////////////
//  VServerMove
////////////////////////////////////////////////////////////////////////////////
function VServerMove(
    float           ClientTimeStamp,
    Vector          ClientAccel,
    Vector          ClientLocation,
    byte            ClientMoveFlags,
    EDodgeDir       ClientDodgeMove,
    byte            ClientRoll,
    int             ClientView,
    optional byte   ClientOldTimeDelta,
    optional int    ClientOldAccel)
{
    local float     DeltaTime;
    local float     ClientError;
	local Rotator   Rot;
	local Vector    LocDiff;
    local int       MaxPitch;
    local int       ViewPitch;
    local int       ViewYaw;
    
	// If this move is outdated, discard it.
	if ( CurrentTimeStamp >= ClientTimeStamp )
		return;

	// Update bReadyToPlay for clients
	if ( PlayerReplicationInfo != None )
		PlayerReplicationInfo.bReadyToPlay = bReadyToPlay;

	// Save move parameters.
	DeltaTime = ClientTimeStamp - CurrentTimeStamp;
    CurrentTimeStamp = ClientTimeStamp;
    
	if ( ServerTimeStamp > 0 )
	{
		// allow 1% error
		TimeMargin += DeltaTime - 1.01 * (Level.TimeSeconds - ServerTimeStamp);
		if ( TimeMargin > MaxTimeMargin )
		{
			// player is too far ahead
			TimeMargin -= DeltaTime;
			if ( TimeMargin < 0.5 )
				MaxTimeMargin = Default.MaxTimeMargin;
			else
				MaxTimeMargin = 0.5;
			DeltaTime = 0;
		}
	}
	ServerTimeStamp = Level.TimeSeconds;
	Rot.Roll = 256 * ClientRoll;
	Rot.Yaw = ViewYaw;
    
    maxPitch = 1;
    
	if ( (ViewPitch > maxPitch * RotationRate.Pitch) && (ViewPitch < 65536 - maxPitch * RotationRate.Pitch) )
	{
		if (ViewPitch < 32768) 
			Rot.Pitch = maxPitch * RotationRate.Pitch;
		else
			Rot.Pitch = 65536 - maxPitch * RotationRate.Pitch;
	}
	else
		Rot.Pitch = ViewPitch;
    
	ViewRotation.Pitch = ViewPitch;
	ViewRotation.Yaw = ViewYaw;
	ViewRotation.Roll = 0;
	SetRotation(Rot);
    
	if ( (Level.Pauser == "") && (DeltaTime > 0) )
		MoveAutonomous(
            DeltaTime,
            (ClientMoveFlags & MV_NEWRUN) != 0,
            (ClientMoveFlags & MV_NEWDUCK) != 0,
            (ClientMoveFlags & MV_NEWJUMP) != 0,
            ClientDodgeMove,
            ClientAccel,
            (Rotation - Rot));

    // Check for a client position update
	if ( Level.TimeSeconds - LastUpdateTime > 500.0/Player.CurrentNetSpeed )
    {
		ClientError = 10000.0;
    }
	else if ( Level.TimeSeconds - LastUpdateTime > 180.0/Player.CurrentNetSpeed )
	{
		LocDiff = Location - ClientLocation;
		ClientError = LocDiff Dot LocDiff;
	}

	if ( ClientError > 3.0 )
	{
		if ( Mover(Base) != None )
			ClientLocation = Location - Base.Location;
		else
			ClientLocation = Location;
        
		LastUpdateTime = Level.TimeSeconds;
		ClientAdjustPosition(
			ClientTimeStamp,
			GetStateName(),
			Physics,
			ClientLocation.X,
			ClientLocation.Y,
			ClientLocation.Z,
			Velocity.X,
			Velocity.Y,
			Velocity.Z,
			Base);
	}
}

////////////////////////////////////////////////////////////////////////////////
//  ClientAdjustPosition
////////////////////////////////////////////////////////////////////////////////
function ClientAdjustPosition(
	float TimeStamp, 
	Name newState, 
	EPhysics newPhysics,
	float NewLocX, 
	float NewLocY, 
	float NewLocZ, 
	float NewVelX, 
	float NewVelY, 
	float NewVelZ,
	Actor NewBase)
{
	local Vector OldLocation;
    local Vector NewLocation;

	if ( CurrentTimeStamp > TimeStamp )
		return;
	CurrentTimeStamp = TimeStamp;

	NewLocation.X = NewLocX;
	NewLocation.Y = NewLocY;
	NewLocation.Z = NewLocZ;
	Velocity.X = NewVelX;
	Velocity.Y = NewVelY;
	Velocity.Z = NewVelZ;

	SetBase(NewBase);
	if ( Mover(NewBase) != None )
		NewLocation += NewBase.Location;

	OldLocation = Location;
	bCanTeleport = false;
	SetLocation(NewLocation);
	bCanTeleport = true;

	SetPhysics(newPhysics);
	if ( !IsInState(newState) )
	{
		GotoState(newState);
	}

	bUpdatePosition = true;
}

////////////////////////////////////////////////////////////////////////////////
//  ProcessMove
////////////////////////////////////////////////////////////////////////////////
function ProcessMove(
    float       DeltaTime,
    Vector      NewAccel,
    EDodgeDir   DodgeMove,
    Rotator     DeltaRot)
{
    Acceleration = NewAccel;
    bIsTurning = ( Abs(DeltaRot.Yaw/DeltaTime) > 10000 ); // RUNE:  was 5000
    
    //if(bPressedJump)
    //    DoJump();
	//
	//if(bJustFired)
	//	GotoStateAttack();
}
















////////////////////////////////////////////////////////////////////////////////
//  PlayerCalcView
//
//  Primary player view function.
//  TODO: We should create a vmodPlayerCamera object and offload most of this
//  functionality there.
////////////////////////////////////////////////////////////////////////////////
event PlayerCalcView(
    out actor ViewActor,
    out vector CameraLocation,
    out rotator CameraRotation)
{
    local vector View,HitLocation,HitNormal;
    local float ViewDist, WallOutDist;

    local vector PlayerLocation;
    local vector loc;
    local rotator rot;
    local vector desiredLoc;
    local vector currentLoc;
    local vector cameraVect, newVect;
    local float accel;
    local float deltaTime;
    local vector startPt;
    local vector endPt;
    local bool done;
    local float desiredDist;
    local float diff;
    local rotator targetangle;
    
    local vector extent; // trace extent
    
    // Calculate time change
    deltaTime = CurrentTime - LastTime;

    // View rotation.
    ViewActor = Self;

    // Handle view shaking
    ViewShake(deltaTime);
    targetAngle = ViewRotation + ShakeDelta;
    
    PlayerLocation = Location + PrePivot;

    
    
    
    
    // ROTATION //////////////////////////////////////////////////////////
    // Local Player Only (deltaTime == 0.0 for remote players on the server)
    if(RemoteRole != ROLE_AutonomousProxy && (deltaTime < 0.1 && deltaTime > 0))
    {
        // TODO: Here's where camera rotation interpolation begins
        // We can clean this up
        
        
        
        // Interpolate Yaw
        targetAngle.Yaw     = targetAngle.Yaw & 0xFFFF;
        CurrentRotation.Yaw = CurrentRotation.Yaw & 0xFFFF;
        diff                = targetAngle.Yaw - CurrentRotation.Yaw;
        if(abs(diff) > 0x8000)
        {
            // Handle wrap around
            if(targetAngle.Yaw > 0x8000)    targetAngle.Yaw -= 0xFFFF;
            else                            targetAngle.Yaw += 0xFFFF;
            
            diff = targetAngle.Yaw - CurrentRotation.Yaw;
        }
        
        CurrentRotation.Yaw += deltaTime * diff * CameraRotSpeed.Yaw;
        
        // Guard against overshooting targetangle
        if((diff < 0 && CurrentRotation.Yaw < targetAngle.Yaw)
        || (diff > 0 && CurrentRotation.Yaw > targetAngle.Yaw))
            CurrentRotation.Yaw = targetAngle.Yaw;



        // Interpolate Pitch
        targetAngle.Pitch       = targetAngle.Pitch & 0xFFFF;
        CurrentRotation.Pitch   = CurrentRotation.Pitch & 0xFFFF;
        diff                    = targetAngle.Pitch - CurrentRotation.Pitch;
        if(abs(diff) > 0x8000)
        {
            // Handle wrap around case
            if(targetAngle.Pitch > 0x8000)  targetAngle.Pitch -= 0xFFFF;
            else                            targetAngle.Pitch += 0xFFFF;
            
            diff = targetAngle.Pitch - CurrentRotation.Pitch;
        }   
        CurrentRotation.Pitch += deltaTime * diff * CameraRotSpeed.Pitch;
        
        // Guard against overshooting targetangle
        if((diff < 0 && CurrentRotation.Pitch < targetAngle.Pitch)
        || (diff > 0 && CurrentRotation.Pitch > targetAngle.Pitch))
            CurrentRotation.Pitch = targetAngle.Pitch;
        
        
        
        // Interpolate Roll
        targetAngle.Roll        = targetAngle.Roll & 0xFFFF;
        CurrentRotation.Roll    = CurrentRotation.Roll & 0xFFFF;
        diff                    = targetAngle.Roll - CurrentRotation.Roll;
        if(abs(diff) > 0x8000)
        { // Handle wrap around case
            if(targetAngle.Roll > 0x8000)
            {
                targetAngle.Roll -= 0xFFFF;;
            }
            else
            {
                targetAngle.Roll += 0xFFFF;
            }
            
            diff = targetAngle.Roll - CurrentRotation.Roll;
        }   
        CurrentRotation.Roll += deltaTime * diff * CameraRotSpeed.Roll;
        
        // Guard against overshooting targetangle
        if((diff < 0 && CurrentRotation.Roll < targetAngle.Roll)
        || (diff > 0 && CurrentRotation.Roll > targetAngle.Roll))
            CurrentRotation.Roll = targetAngle.Roll;
    }
    else
    { // No interpolation
        targetAngle.Yaw = targetAngle.Yaw & 0xFFFF;
        targetAngle.Pitch = targetAngle.Pitch & 0xFFFF;
        targetAngle.Roll = targetAngle.Roll & 0xFFFF;

        CurrentRotation = targetAngle;
    }

    CameraRotation = CurrentRotation;

    
    
    
    
    
    
    // POSITION //////////////////////////////////////////////////////////
    if(bBehindView && !bCameraOverhead)
    {
        WallOutDist = 15;
        rot = CameraRotation;
        endPt = PlayerLocation;

        ViewDist = CameraDist;
        //if(Region.Zone.MaxCameraDist >= CollisionRadius)
        //{ // Zone-based camera distance
        //  ViewDist = Region.Zone.MaxCameraDist;
        //}

        //rot.Pitch -= CameraPitch; // Not sure what this was doing
        endPt.Z += CameraHeight;

        View = vect(1,0,0) >> rot;

        startPt = PlayerLocation;
        if(Trace(HitLocation, HitNormal, endPt, startPt) != None)
            loc = HitLocation;
        else
            loc = endPt;

        if(RemoteRole != ROLE_AutonomousProxy && (deltaTime < 0.1 && deltaTime > 0))
        { // Do interpolation of CurrentDist.  
            // Local Player Only (deltaTime == 0.0 for remote players on the server)
            diff = abs(CurrentDist - ViewDist);
            if(diff < 0.25)
            { // Close enough, force the camera to the desired position
                CurrentDist = ViewDist;
            }
            
            if(CurrentDist < ViewDist)
            {
                CurrentDist += deltaTime * diff * 10;
                if(CurrentDist > ViewDist)
                    CurrentDist = ViewDist;
            }
            else if(CurrentDist > ViewDist)
            {
                CurrentDist -= deltaTime * diff * 10;
                if(CurrentDist < ViewDist)
                    CurrentDist = ViewDist;
            }
        }
        else
        {
            CurrentDist = ViewDist;
        }

        cameraVect = (loc - OldCameraStart);
        accel = (ViewDist / CurrentDist) * CameraAccel;
        if(RemoteRole != ROLE_AutonomousProxy && (deltaTime < 0.1 && deltaTime > 0))
        { // Local Player Only (deltaTime == 0.0 for remote players on the server)
            newVect = cameraVect * deltaTime * accel;
            if(VSize(newVect) < VSize(cameraVect))
                cameraVect = newVect;

            loc = OldCameraStart + cameraVect;
        }
        // Otherwise, loc is not interpolated

        endPt = loc - (CurrentDist + WallOutDist) * vector(rot);
        startPt = loc;

        if(Trace(HitLocation, HitNormal, endPt, startPt) != None)
        {
            CurrentDist = FMin((loc - HitLocation) dot View, CurrentDist);
        }

        if(CurrentDist < WallOutDist)
        { // Camera pulled in so close that the view should just go first person
            CurrentDist = WallOutDist;

            //if(bGotoFP)
            bBehindView = false;
        }

        CameraLocation = loc - (CurrentDist - WallOutDist) * View;
        
        OldCameraStart = loc;

        // Set Tranlucency on local player if too close to a wall
        if (CurrentDist > TranslucentDist)
            SetClientAlpha(1.0);
        else
            SetClientAlpha(CurrentDist/TranslucentDist);
    }
    else if(bBehindView)
    {
        loc = PlayerLocation;
        loc.Z += EyeHeight;
        CameraLocation = SavedCameraLoc;
        CameraRotation = rotator(loc - CameraLocation) + ShakeDelta;
    }
    else if(bBehindView && bCameraOverhead)
    {
        CameraLocation = PlayerLocation;
        CameraLocation.Z += (CameraDist - 50) * 10;
        
        CameraRotation.Pitch = -16384;
        CameraRotation.Yaw = Rotation.Yaw;
        CameraRotation.Roll = 0;        
    }
    else
    {
        bBehindView = true;
    }
    
    
    
    
    
    
    
    
    SavedCameraRot = CameraRotation;
    SavedCameraLoc = CameraLocation;
    
    // Handle view target.  Done AFTER other code, so that SavedLoc/Rot are updated
    if(ViewTarget != None)
    {
        SetClientAlpha(1.0);
        ViewActor = ViewTarget;
        CameraLocation = ViewTarget.Location;
        CameraRotation = ViewTarget.Rotation + ShakeDelta; // Add in effect of earthquakes
        if(Pawn(ViewTarget) != None)
        {
            if((Level.NetMode == NM_StandAlone) && (ViewTarget.IsA('PlayerPawn')))
            {
                CameraRotation = Pawn(ViewTarget).ViewRotation;
            }

            CameraLocation.Z += Pawn(ViewTarget).EyeHeight;
        }
    }

    ViewLocation = CameraLocation;

    LastTime = CurrentTime;
}

////////////////////////////////////////////////////////////////////////////////
//  ViewShake
////////////////////////////////////////////////////////////////////////////////
function ViewShake(float DeltaTime)
{
    if(shaketimer > 0.0)
    {   
        shaketimer -= DeltaTime;
        
        if(shaketimer <= 0)
        {
            ShakeDelta = rot(0, 0, 0);
            return;
        }

        if(shaketimer <= maxshake)
        {       
            verttimer -= DeltaTime * (float(shakemag) / maxshake);
            if(verttimer <= 0)
                verttimer = 0;
        }
        else
        {
            verttimer = shakemag;
        }
            
        ShakeDelta.Pitch = (100 * verttimer * (FRand() - 0.5)) * DeltaTime;
        ShakeDelta.Yaw = (100 * verttimer * (FRand() - 0.5)) * DeltaTime;
        ShakeDelta.Roll = (100 * verttimer * (FRand() - 0.5)) * DeltaTime;
    }
}




////////////////////////////////////////////////////////////////////////////////
//  UpdateUseActor
//
//  Update the UseActor variable to the best Actor candidate to interact with
//  the pawn. If no UseActor is found, UseActor is set to none.
////////////////////////////////////////////////////////////////////////////////
function UpdateUseActor()
{
    local Actor A;
    local float dist;
    local float bestDist;
    local int priority;
    local int bestPriority;
    
    bestDist = 999999.0;
    bestPriority = 999;
    
    UseActor = None;
    
    foreach RadiusActors(class'actor', A, 100, Location)
    {
        if(A.CanBeUsed(self))
        {
            priority = A.GetUsePriority();
            dist = VSize(A.Location - Location);
        
            if((priority < bestPriority) 
            || (priority == bestPriority && dist < bestDist))
            {
                bestPriority = priority;
                bestDist = dist;
                UseActor = A;
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
//  (Pawn) CanPickUp
//
//  Check if this PlayerPawn can pick up an inventory item
//  Sub-handler functions should be implemented in derived classes
////////////////////////////////////////////////////////////////////////////////
function bool CanPickUp(Inventory item)
{
    if(item.IsA('Weapon'))      return CanPickUpWeapon(Weapon(item));
    else if(item.IsA('Shield')) return CanPickUpShield(Shield(item));
    else if(item.IsA('Runes'))  return CanPickUpRune(Runes(item));
    else if(item.IsA('Pickup')) return CanPickUpPickup(Pickup(item));
    return false;
}
function bool CanPickUpWeapon(Weapon weaponItem)    { return false; }
function bool CanPickUpShield(Shield shieldItem)    { return false; }
function bool CanPickUpRune(Runes runeItem)         { return false; }
function bool CanPickUpPickup(Pickup pickupItem)    { return false; }

////////////////////////////////////////////////////////////////////////////////
//  (Pawn) WantsToPickUp
//
//  Check if this PlayerPawn wants to pick up an inventory item
//  Sub-handler functions should be implemented in derived classes
////////////////////////////////////////////////////////////////////////////////
function bool WantsToPickUp(Inventory item)
{
    if(item.IsA('Weapon'))      return WantsToPickUpWeapon(Weapon(item));
    else if(item.IsA('Shield')) return WantsToPickUpShield(Shield(item));
    else if(item.IsA('Runes'))  return WantsToPickUpRune(Runes(item));
    else if(item.IsA('Pickup')) return WantsToPickUpPickup(Pickup(item));
    return false;
}
function bool WantsToPickUpWeapon(Weapon weaponItem)    { return false; }
function bool WantsToPickUpShield(Shield shieldItem)    { return false; }
function bool WantsToPickUpRune(Runes runeItem)         { return false; }
function bool WantsToPickUpPickup(Pickup pickupItem)    { return false; }

////////////////////////////////////////////////////////////////////////////////
//  Weapon joint functions
//
//  These functions handle attaching / detaching weapons from their skeleton.
//  Implement in derived classes for each specific skeleton.
////////////////////////////////////////////////////////////////////////////////
function AttachWeaponToWeaponJoint(Weapon weaponItem)           { }
function Weapon DetachWeaponFromWeaponJoint()                   { return None; }
function AttachWeaponToStowJoint(Weapon weaponItem, optional byte slot) { }
function Weapon DetachWeaponFromStowJoint(optional byte slot)   { return None; }

////////////////////////////////////////////////////////////////////////////////
//  EquipWeapon
//
//  PlayerPawn has just equipped a new weapon. Perform all "enabling" here.
////////////////////////////////////////////////////////////////////////////////
final function EquipWeapon(Weapon weaponItem)
{
    DropWeapon();   // Caller's responsibility to stow first
    AttachWeaponToWeaponJoint(weaponItem);
    weaponItem.GotoState('Active');
    Weapon = weaponItem;
}

////////////////////////////////////////////////////////////////////////////////
//  UnequipWeapon
//
//  Unequip whatever weapon the Pawn is currently using but do not remove it
//  from inventory. If the Pawn is not using a weapon, this does nothing.
////////////////////////////////////////////////////////////////////////////////
final function Weapon UnequipWeapon()
{
    local Weapon w;
    
    w = DetachWeaponFromWeaponJoint();
    if(w == None)
        return None;
    
    Weapon = None;
    return w;
}

////////////////////////////////////////////////////////////////////////////////
//  StowWeapon
//
//  Stow the Pawn's current weapon.
////////////////////////////////////////////////////////////////////////////////
function StowWeapon()
{
    local Weapon w;
    
    w = UnequipWeapon();
    if(w == None)
        return;
    
    AttachWeaponToStowJoint(w);
}

////////////////////////////////////////////////////////////////////////////////
//  DropWeapon
//
//  Drops whatever weapon the Pawn is currently holding and removes it from
//  inventory. If the Pawn is not holding a weapon, this does nothing.
////////////////////////////////////////////////////////////////////////////////
function DropWeapon()
{
    local Vector vx, vy, vz;
    local Weapon w;
    
    w = UnequipWeapon();
    if(w == None)
        return;
    
    GetAxes(Rotation, vx, vy, vz);
    w.DropFrom(Location);
    w.SetPhysics(PHYS_Falling);
    w.Velocity = vy * 100 + vx * 75;
    w.Velocity.Z = 50;
    w.GotoState('Drop');
    w.DisableSwipeTrail();
    
    DeleteInventory(w);
}

////////////////////////////////////////////////////////////////////////////////
//  Shield joint functions
//
//  These functions handle attaching / detaching shields from their skeleton.
//  Implement in derived classes for each specific skeleton.
////////////////////////////////////////////////////////////////////////////////
function AttachShieldToShieldJoint(Shield shieldItem)           { }
function Shield DetachShieldFromShieldJoint()                   { return None; }
function AttachShieldToStowJoint(Shield shieldItem, optional byte slot) { }
function Shield DetachShieldFromStowJoint(optional byte slot)   { return None; }

////////////////////////////////////////////////////////////////////////////////
//  DropShield
//
//  Drops whatever shield the Pawn is currently holding and removes it from
//  inventory. If the Pawn is not holding a shield, this does nothing.
////////////////////////////////////////////////////////////////////////////////
function DropShield()
{
    local Vector vx, vy, vz;
    local Shield s;
    
    s = DetachShieldFromShieldJoint();
    if(s == None)
        return;
    
    Shield = None;
    
    GetAxes(Rotation, vx, vy, vz);
    s.DropFrom(Location);
    
    s.SetPhysics(PHYS_Falling);
    s.Velocity = vy * 100 + vx * 75;
    s.Velocity.Z = 50;
    s.GotoState('Drop');
    
    DeleteInventory(s);
}

////////////////////////////////////////////////////////////////////////////////
//  EquipShield
//
//  PlayerPawn has just equipped a new weapon. Perform all "enabling" here.
////////////////////////////////////////////////////////////////////////////////
final function EquipShield(Shield shieldItem)
{
    DropShield();   // Caller's responsibility to stow first
    AttachShieldToShieldJoint(shieldItem);
    shieldItem.GotoState('Active');
    Shield = shieldItem;
}

////////////////////////////////////////////////////////////////////////////////
//  (Pawn) AcquireInventory
//
//  This function is called the exact moment a pawn acquires an inventory item.
//  In Use animations, this function is called the moment the item actually
//  enters the pawn's hand.
////////////////////////////////////////////////////////////////////////////////
function AcquireInventory(Inventory item)
{
    if(Skeletal == None)
        return;
    
    item.FireEvent(item.Event);
    item.Event = '';
    
    if(item.IsA('Weapon'))          AcquireWeapon(Weapon(item));
    else if(item.IsA('Shield'))     AcquireShield(Shield(item));
    else if(item.IsA('Runes'))      AcquireRune(Runes(item));
    else if(item.IsA('Pickup'))     AcquirePickup(Pickup(item));
}

////////////////////////////////////////////////////////////////////////////////
//  AcquireWeapon
//
//  AcquireInventory sub-handler
////////////////////////////////////////////////////////////////////////////////
function AcquireWeapon(Weapon weaponItem)
{
    EquipWeapon(weaponItem);
}

////////////////////////////////////////////////////////////////////////////////
//  AcquireShield
//
//  AcquireInventory sub-handler
////////////////////////////////////////////////////////////////////////////////
function AcquireShield(Shield shieldItem)
{
    EquipShield(shieldItem);
}

////////////////////////////////////////////////////////////////////////////////
//  AcquireRune
//
//  AcquireInventory sub-handler
////////////////////////////////////////////////////////////////////////////////
function AcquireRune(Runes runeItem)
{}

////////////////////////////////////////////////////////////////////////////////
//  AcquirePickup
//
//  AcquireInventory sub-handler
////////////////////////////////////////////////////////////////////////////////
function AcquirePickup(Pickup pickupItem)
{}





// Overridden animation functions
function PlayFrontHit(optional float tweenTime) { }
function PlayBackHit(optional float tweenTime)  { }
function PlayGutHit(optional float tweenTime)   { }
function PlayHeadHit(optional float tweenTime)  { }
function PlayLeftHit(optional float tweenTime)  { }
function PlayRightHit(optional float tweenTime) { }
function PlayDrowning(optional float tweenTime) { }

function PlayDeath(name damageType)             { }
function PlayBackDeath(name damageType)         { }
function PlayLeftDeath(name damageType)         { }
function PlayRightDeath(name damageType)        { }
function PlayHeadDeath(name damageType)         { }
function PlayDrownDeath(name damageType)        { }
function PlayGibDeath(name damageType)          { }
function PlaySkewerDeath(name damageType)       { }

function PlayFiring()                           { }
function PlayAltFiring()                        { }
function PlayMoving(optional float tweenTime)   { }
function PlayInAir(optional float tweenTime)    { }
function PlayPullUp(optional float tweenTime)   { }
function PlayStepUp(optional float tweenTime)   { }
function PlayDuck(optional float tweenTime)     { }
function PlayCrawling(optional float tweenTime) { }
function PlayWaiting(optional float tweenTime)  { }
function PlayLanded(float impactVelocity)       { }
function PlaySwimming()                         { }






////////////////////////////////////////////////////////////////////////////////
//
//  BASE COMMAND INTERFACE
//
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
//  General player commands
//
//  Basic vmodPlayerPawn interface functions.
////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleAdminLogin
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleAdminLogin(string password)
{
    Level.Game.AdminLogin( Self, Password );
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleAdminLogout
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleAdminLogout()
{
    Level.Game.AdminLogout( Self );
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleAlwaysMouseLook
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleAlwaysMouseLook(bool b)
{
    ChangeAlwaysMouseLook(b);
    SaveConfig();
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleAttack
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleAttack()
{
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleDefend
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleDefend()
{
    bJustAltFired = true;
    if( bShowMenu || (Level.Pauser!="") || (Role < ROLE_Authority) )
        return;

    if(Shield != None)
        PlayAltFiring();
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleFunctionKey
////////////////////////////////////////////////////////////////////////////////
final function VcmdHandleFunctionKey(byte f)
{
    switch(f)
    {
        case 1: VcmdHandleF1();     break;
        case 2: VcmdHandleF2();     break;
        case 3: VcmdHandleF3();     break;
        case 4: VcmdHandleF4();     break;
        case 5: VcmdHandleF5();     break;
        case 6: VcmdHandleF6();     break;
        case 7: VcmdHandleF7();     break;
        case 8: VcmdHandleF8();     break;
        case 9: VcmdHandleF9();     break;
        case 10: VcmdHandleF10();   break;
        case 11: VcmdHandleF11();   break;
        case 12: VcmdHandleF12();   break;
    }
}
function VcmdHandleF1() { }
function VcmdHandleF2() { }
function VcmdHandleF3() { }
function VcmdHandleF4() { }
function VcmdHandleF5() { }
function VcmdHandleF6() { }
function VcmdHandleF7() { }
function VcmdHandleF8() { }
function VcmdHandleF9() { }
function VcmdHandleF10() { }
function VcmdHandleF11() { }
function VcmdHandleF12() { }

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleJump
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleJump()
{
    if ( !bShowMenu && (Level.Pauser == PlayerReplicationInfo.PlayerName) )
        SetPause(False);
    else
        bPressedJump = true;
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleMutate
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleMutate(string s)
{
    if( Level.NetMode == NM_Client )
        return;
    Level.Game.BaseMutator.Mutate(s, Self);
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandlePing
////////////////////////////////////////////////////////////////////////////////
function VcmdHandlePing()
{
    ClientMessage("Current ping is"@PlayerReplicationInfo.Ping);
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandlePlayerList
////////////////////////////////////////////////////////////////////////////////
function VcmdHandlePlayerList()
{
    local PlayerReplicationInfo PRI;

    log("Player List:");
    ForEach AllActors(class'PlayerReplicationInfo', PRI)
        log(PRI.PlayerName@"( ping"@PRI.Ping$")"@"Team="$PRI.Team);
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleSay
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleSay(string s)
{
    local Pawn P;

    if ( Level.Game.AllowsBroadcast(self, Len(s)) )
        for( P=Level.PawnList; P!=None; P=P.nextPawn )
            if( P.bIsPlayer || P.IsA('MessagingSpectator') )
                P.TeamMessage( PlayerReplicationInfo, s, 'Say', true );
    return;
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleSayTeam
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleSayTeam( string Msg )
{
    local Pawn P;

    if ( !Level.Game.bTeamGame )
    {
        Say(Msg);
        return;
    }

    if ( Msg ~= "Help" )
    {
        CallForHelp();
        return;
    }
            
    if ( Level.Game.AllowsBroadcast(self, Len(Msg)) )
        for( P=Level.PawnList; P!=None; P=P.nextPawn )
            if( P.bIsPlayer && (P.PlayerReplicationInfo.Team == PlayerReplicationInfo.Team) )
            {
                if ( P.IsA('PlayerPawn') )
                    P.TeamMessage( PlayerReplicationInfo, Msg, 'TeamSay', true );
            }
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleShowMenu
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleShowMenu()
{
    WalkBob = vect(0,0,0);
    bShowMenu = true; // menu is responsible for turning this off
    Player.Console.GotoState('Menuing');
        
    if( Level.Netmode == NM_Standalone )
        SetPause(true);
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleSShot
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleSShot()
{
    local float b;
    b = float(ConsoleCommand("get ini:Engine.Engine.ViewportManager Brightness"));
    ConsoleCommand("set ini:Engine.Engine.ViewportManager Brightness 1");
    ConsoleCommand("flush");
    ConsoleCommand("shot");
    ConsoleCommand("set ini:Engine.Engine.ViewportManager Brightness "$string(B));
    ConsoleCommand("flush");
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleStow
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleStow()
{
    // Do this for now to support deprecated SwitchWeapon
    VcmdHandleSwitchInventory(1);
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleSuicide
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleSuicide()
{
    KilledBy( None );
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleSwitchInventory
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleSwitchInventory(byte F)
{
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleTaunt
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleTaunt()
{
    local name Sequence;

    if (Physics != PHYS_Walking)    // Disallow while falling
        return;

    if( bShowMenu || (Level.Pauser!=""))
        return;

    // Don't allow the player to taunt if they are doing something like weapon switching or attacking
    if(AnimProxy != None && AnimProxy.GetStateName() != 'Idle')
        return;

    if (Weapon != None)
        Sequence = Weapon.A_Taunt;
    else
        Sequence = 'S3_Taunt';

    if(Role < ROLE_Authority)
        ServerTaunt(Sequence);
    //  PlayUninterruptedAnim(Sequence);
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleThrow
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleThrow()
{
    if(Weapon == None)
        return;

    // TODO: Should restructure so we never make it into this function in this scenario
    if( bShowMenu || (Level.Pauser!="")) // || (Role < ROLE_Authority) )
        return;
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleToggleHUD
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleToggleHUD()
{
    if (myHud != None)
        myHUD.ChangeHud(1);
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleToggleScoreboard
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleToggleScoreboard()
{
    bShowScores = !bShowScores;
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleUse
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleUse()
{
    local vector v;
    local name useAnim;
    
    if( bShowMenu || (Level.Pauser!="") || (Role < ROLE_Authority) || Health<=0)
        return;

    if(Physics != PHYS_Walking || (Velocity.X * Velocity.X + Velocity.Y * Velocity.Y >= 1500))
    { // Test:  Only allow Ragnar to pick things up if he's standing still and on the ground
        return;
    }

    // Scan the world for the best use actor
    UpdateUseActor();

    // TODO: This is where we check for relations
    if(UseActor != None)
    {
        if(UseActor.IsA('Inventory'))
        { // Inventory item pickup is handled by the animation proxy
            //if(AnimProxy != None)
            //  AnimProxy.Use();
        }
        else if(UseActor.IsA('Fire'))
        { // Relight torch, pass the use to the weapon
            if(Weapon != None)
                Weapon.UseTrigger(self);
        }
        else
        { // Otherwise, play the animation returned by GetUseAnim   
            useAnim = UseActor.GetUseAnim();

            if(useAnim != '')
            {
                if(useAnim == 'neutral_kick')
                    //PlaySound(KickSound, SLOT_Talk, 1.0, false, 1200, FRand() * 0.08 + 0.96);

                if(useAnim == 'PumpTrigger' && Weapon != None && Weapon.A_PumpTrigger != '')
                { // Weapon-specific pump trigger anims
                    useAnim = Weapon.A_PumpTrigger;
                }

                if(useAnim == 'LeverTrigger' && Weapon != None && Weapon.A_LeverTrigger != '')
                { // Weapon-specific pump trigger anims
                    useAnim = Weapon.A_LeverTrigger;
                }

                PlayUninterruptedAnim(useAnim);
            }
        }
    }
}




////////////////////////////////////////////////////////////////////////////////
//  Configuration commands
//
//  These commands set and save vmodPlayerPawn configuration variables.
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleSetDodgeClickTime
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleSetDodgeClickTime(float t)
{
    ChangeDodgeClickTime(t);
    SaveConfig();
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleSetFov
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleSetFov(float fov)
{
    if( (fov >= 80.0) || Level.bAllowFOV || bAdmin || (Level.Netmode==NM_Standalone) )
    {
        DefaultFOV = FClamp(fov, 1, 170);
        DesiredFOV = DefaultFOV;
        SaveConfig();
    }
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleSetInvertMouse
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleSetInvertMouse(bool b)
{
    bInvertMouse = b;
    SaveConfig();
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleSetName
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleSetName(coerce string s)
{
    if ( Len(s) > 28 )
        s = left(s,28);
    ReplaceText(s, " ", "_");
    ChangeName(s);
    UpdateURL("Name", s, true);
    SaveConfig();
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleSetSensitivity
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleSetSensitivity(float f)
{
    UpdateSensitivity(f);
    SaveConfig();
}




////////////////////////////////////////////////////////////////////////////////
//  Cheat-enabled commands
//
//  These commands are only available when the vmodPlayerPawn has cheats on.
//  TODO: Implement a cheat check function for all of these functions to check
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleAmphibious
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleAmphibious()
{
    if( !bCheatsEnabled )
        return;
    if ( !bAdmin && (Level.Netmode != NM_Standalone) )
        return;
    if (HeadRegion.Zone.bWaterZone)
        PainTime=0;
    UnderwaterTime = +999999.0;
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleCauseEvent
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleCauseEvent(name n)
{
    local actor A;
    local int triggerCount;

    if( !bCheatsEnabled )
        return;

    if( (bAdmin || (Level.Netmode == NM_Standalone)) && (N != '') )
    {
        triggerCount = 0;
        foreach AllActors( class 'Actor', A, N )
        {
            A.Trigger( Self, Self );
            triggerCount++;
        }
        slog(triggerCount $ " actor(s) triggered");
    }
}




////////////////////////////////////////////////////////////////////////////////
//  Administrator commands
//
//  These commands are only available when the vmodPlayerPawn is an admin.
//  TODO: Implement an admin check function which all of these call
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleBanPlayerName
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleBanPlayerName(string n)
{
    local Pawn aPawn;
    local string IP;
    local int j;
    if( !bAdmin )
        return;
    for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
        if
        (   aPawn.bIsPlayer
            &&  aPawn.PlayerReplicationInfo.PlayerName~=n
            &&  (PlayerPawn(aPawn)==None || NetConnection(PlayerPawn(aPawn).Player)!=None ) )
        {
            IP = PlayerPawn(aPawn).GetPlayerNetworkAddress();
            if(Level.Game.CheckIPPolicy(IP))
            {
                IP = Left(IP, InStr(IP, ":"));
                Log("Adding IP Ban for: "$IP);
                for(j=0;j<50;j++)
                    if(Level.Game.IPPolicies[j] == "")
                        break;
                if(j < 50)
                    Level.Game.IPPolicies[j] = "DENY,"$IP;
                Level.Game.SaveConfig();
            }
            aPawn.Destroy();
            return;
        }
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleEnableCheats
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleEnableCheats(optional float id)
{
    // TODO: Implement player ID cheat setting
    if(bAdmin || (Level.Netmode == NM_Standalone))
    {
        bCheatsEnabled = !bCheatsEnabled;
        if(bCheatsEnabled)
            ClientMessage("Cheats Enabled");
        else
            ClientMessage("Cheats Disabled");
    }
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleKickPlayerName
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleKickPlayerName(string name)
{
    local Pawn aPawn;
    if( !bAdmin )
        return;
    for( aPawn=Level.PawnList; aPawn!=None; aPawn=aPawn.NextPawn )
        if
        (   aPawn.bIsPlayer
            &&  aPawn.PlayerReplicationInfo.PlayerName~=name
            &&  (PlayerPawn(aPawn)==None || NetConnection(PlayerPawn(aPawn).Player)!=None ) )
        {
            aPawn.Destroy();
            return;
        }
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleResetLevel
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleResetGame()
{
    //if( bAdmin || Level.NetMode==NM_Standalone || Level.netMode==NM_ListenServer )
    //    if(Level.Game.IsA('vmodGameInfo'))
    //        vmodGameInfo(Level.Game).GameReset();
}

////////////////////////////////////////////////////////////////////////////////
//  VcmdHandleSwitchLevel
////////////////////////////////////////////////////////////////////////////////
function VcmdHandleSwitchLevel(string url)
{
    if( bAdmin || Level.NetMode==NM_Standalone || Level.netMode==NM_ListenServer )
        Level.ServerTravel( URL, false );
}


////////////////////////////////////////////////////////////////////////////////
//  State utility functions
//
//  For safer coding purposes, do not use GotoState(), use these instead.
////////////////////////////////////////////////////////////////////////////////
final function GotoStateNeutral()         { GotoState('Neutral'); }
final function GotoStateAttack()          { GotoState('Attack'); }
final function GotoStateAttackRecover()   { GotoState('AttackRecover'); }
final function GotoStateCheatFlying()     { GotoState('CheatFlying'); }
final function GotoStateDead()            { GotoState('Dead'); }
final function GotoStateDefend()          { GotoState('Defend'); }
final function GotoStateDying()           { GotoState('Dying'); }
final function GotoStateEdgeHanging()     { GotoState('EdgeHanging'); }
final function GotoStateFeigningDeath()   { GotoState('FeigningDeath'); }
final function GotoStateGameEnded()       { GotoState('GameEnded'); }
final function GotoStateGrabbing()        { GotoState('Grabbing'); }
final function GotoStatePain()            { GotoState('Pain'); }
final function GotoStatePainConcuss()     { GotoState('PainConcuss'); }
final function GotoStatePlayerFlying()    { GotoState('PlayerFlying'); }
final function GotoStatePlayerSpectating(){ GotoState('PlayerSpectating'); }
final function GotoStatePlayerSwimming()  { GotoState('PlayerSwimming'); }
final function GotoStatePlayerWaiting()   { GotoState('PlayerWaiting'); }
final function GotoStatePlayerWalking()   { GotoState('PlayerWalking'); }
final function GotoStateSelect()          { GotoState('Select'); }
final function GotoStateStow()            { GotoState('Stow'); }
final function GotoStateUninterrupted()   { GotoState('Uninterrupted'); }


////////////////////////////////////////////////////////////////////////////////
//  Obsolete inherited states
//
//  These states were valid for base classes, but we are overriding all of them
//  here and sending them right back to the neutral state. All the of the
//  original functionality is handled elsewhere now.
////////////////////////////////////////////////////////////////////////////////
auto state InvalidState {   function BeginState() { GotoStateNeutral(); }   }
state CheatFlying       {   function BeginState() { GotoStateNeutral(); }   }
state EdgeHanging       {   function BeginState() { GotoStateNeutral(); }   }
state FeigningDeath     {   function BeginState() { GotoStateNeutral(); }   }
state GameEnded         {   function BeginState() { GotoStateNeutral(); }   }
state PlayerFlying      {   function BeginState() { GotoStateNeutral(); }   }
state PlayerSwimming    {   function BeginState() { GotoStateNeutral(); }   }
state PlayerWaiting     {   function BeginState() { GotoStateNeutral(); }   }
state PlayerWalking     {   function BeginState() { GotoStateNeutral(); }   }
state Uninterrupted     {   function BeginState() { GotoStateNeutral(); }   }


////////////////////////////////////////////////////////////////////////////////
//  State: Neutral
//
//  Default player state when no major actions are being performed. All states
//  will eventually lead back to the neutral state.
////////////////////////////////////////////////////////////////////////////////
state Neutral
{
    function BeginState() // [Neutral]
    {
    }
    
    function PlayStateAnimation() // [Neutral]
    {
        local name animName;
        
        animName = 'None';
        
        switch(GetMoveDirectionFlags())
        {
            case MD_FORWARD:        animName = 'MOV_ALL_run1_AA0N';         break;
            case MD_BACKWARD:       animName = 'MOV_ALL_runback1_AA0S';     break;
            case MD_LEFT:           animName = 'MOV_ALL_lstrafe1_AN0N';     break;
            case MD_RIGHT:          animName = 'MOV_ALL_rstrafe1_AN0N';     break;
            case MD_FORWARDLEFT:    animName = 'MOV_ALL_lstrafe1_AA0S';     break;
            case MD_FORWARDRIGHT:   animName = 'MOV_ALL_rstrafe1_AA0S';     break;
            case MD_BACKWARDLEFT:   animName = 'MOV_ALL_rstrafe1_AA0S';     break;
            case MD_BACKWARDRIGHT:  animName = 'MOV_ALL_lstrafe1_AA0S';     break;
            case MD_NEUTRAL:        animName = 'neutral_idle';              break;
        }
        
        //if(animName != 'None')
        //    LoopAnim(animName, 1.0, 0.0);
    }
}


////////////////////////////////////////////////////////////////////////////////
//  State: Attack
////////////////////////////////////////////////////////////////////////////////
state Attack
{
    Begin: // [Attack]
        bJustFired = false;
        WeaponActivate();
        PlayAnim('X3_attackA', 1.0, 0.0);
        AttackAnimation = 'None';
        FinishAnim();
        WeaponDeactivate();
    
    End: // [Attack]
        GotoStateAttackRecover();
}


////////////////////////////////////////////////////////////////////////////////
//  State: Attack Recover
////////////////////////////////////////////////////////////////////////////////
state AttackRecover
{
    Begin: // [AttackRecover]
        PlayAnim('X3_attackAreturn', 1.0, 0.0);
        FinishAnim();
    
    End: // [AttackRecover]
        GotoStateNeutral();
}


////////////////////////////////////////////////////////////////////////////////
//  State: Dead
////////////////////////////////////////////////////////////////////////////////
state Dead
{
    function BeginState() // [Dead]
    {
    }
}


////////////////////////////////////////////////////////////////////////////////
//  State: Defend
////////////////////////////////////////////////////////////////////////////////
state Defend
{
    function BeginState() // [Defend]
    {
    }
}


////////////////////////////////////////////////////////////////////////////////
//  State: Dying
////////////////////////////////////////////////////////////////////////////////
state Dying
{
    function BeginState() // [Dying]
    {
    }
}


////////////////////////////////////////////////////////////////////////////////
//  State: Grabbing
////////////////////////////////////////////////////////////////////////////////
state Grabbing
{
    function BeginState() // [Grabbing]
    {
    }
}


////////////////////////////////////////////////////////////////////////////////
//  State: Pain
////////////////////////////////////////////////////////////////////////////////
state Pain
{
    function BeginState() // [Pain]
    {
    }
}


////////////////////////////////////////////////////////////////////////////////
//  State: PainConcuss
////////////////////////////////////////////////////////////////////////////////
state PainConcuss
{
    function BeginState() // [PainConcuss]
    {
    }
}


////////////////////////////////////////////////////////////////////////////////
//  State: PainConcuss
////////////////////////////////////////////////////////////////////////////////
state PlayerSpectating
{
    function BeginState() // [PlayerSpectating]
	{
		PlayerReplicationInfo.bIsSpectator = true;
        bHidden = true;
        Visibility = 0;
        PlayerReplicationInfo.bWaitingPlayer = true;
        Mesh = None;
        SetCollision(false,false,false);
        bCollideWorld = false;
		EyeHeight = Default.BaseEyeHeight;
		SetPhysics(PHYS_None);
	}
    
    function EndState() // [PlayerSpectating]
    {
        PlayerReplicationInfo.bIsSpectator = false;
        bHidden = false;
        Visibility = 1;
        PlayerReplicationInfo.bWaitingPlayer = false;
        SetMesh();
        SetCollision(true, true, true);
        bCollideWorld = true;
        SetPhysics(PHYS_Falling);
    }
}


////////////////////////////////////////////////////////////////////////////////
//  State: Select
////////////////////////////////////////////////////////////////////////////////
state Select
{
    function BeginState() // [Select]
    {
    }
}


////////////////////////////////////////////////////////////////////////////////
//  State: Stow
////////////////////////////////////////////////////////////////////////////////
state Stow
{
    function BeginState() // [Stow]
    {
    }
}


////////////////////////////////////////////////////////////////////////////////
//  Obsolete inherited functions
//
//  These functions were valid for base classes, but this functionality is
//  either handled elsewhere now, or completely removed.
////////////////////////////////////////////////////////////////////////////////
function BoostStrength(int amount)                  { }     // (Pawn)
function bool FollowOrders(name order, name tag)    { return false; } // (Pawn)
function StrengthDecay(float Time)                  { }     // (Pawn)
function PowerupFire(Pawn EventInstigator)          { }     // (Pawn)
function PowerupBlaze(Pawn EventInstigator)         { }     // (Pawn)
function PowerupFriend(Pawn EventInstigator)        { }     // (Pawn)
function PowerupElectricity(Pawn EventInstigator)   { }     // (Pawn)
function PlayTurning(optional float tween)          { }     // (Pawn)
function PlayWeaponSwitch(Weapon NewWeapon)         { }     // (Pawn)
function PlayRising()                               { }     // (PlayerPawn)
function PlayFeignDeath()                           { }     // (PlayerPawn)


////////////////////////////////////////////////////////////////////////////////
// Debug
////////////////////////////////////////////////////////////////////////////////
function Debug(Canvas canvas, int mode)
{
    local int mdFlags;
    local int mtFlags;
    local int stFlags;
    local int vrFlags;
    
    Super.Debug(canvas, mode);
    
    Canvas.DrawText("vmodPlayerPawnBase");
    Canvas.CurY -= 8;
    
    // Move direction flags
    mdFlags = GetMoveDirectionFlags();
    Canvas.DrawText("  MoveDirection Flags:");
    Canvas.CurY -= 16;
    Canvas.CurX += 160;
    if(mdFlags == MD_FORWARD)           Canvas.DrawText("MD_FORWARD");
    else if(mdFlags == MD_BACKWARD)     Canvas.DrawText("MD_BACKWARD");
    else if(mdFlags == MD_LEFT)         Canvas.DrawText("MD_LEFT");
    else if(mdFlags == MD_RIGHT)        Canvas.DrawText("MD_RIGHT");
    else if(mdFlags == MD_FORWARDLEFT)  Canvas.DrawText("MD_FORWARDLEFT");
    else if(mdFlags == MD_FORWARDRIGHT) Canvas.DrawText("MD_FORWARDRIGHT");
    else if(mdFlags == MD_BACKWARDLEFT) Canvas.DrawText("MD_BACKWARDLEFT");
    else if(mdFlags == MD_BACKWARDRIGHT)Canvas.DrawText("MD_BACKWARDRIGHT");
    else if(mdFlags == MD_NEUTRAL)      Canvas.DrawText("MD_NEUTRAL");
    else
    {
        Canvas.SetColor(255.0, 0.0, 0.0);
        Canvas.DrawText("ERROR - INVALID MD FLAGS");
        Canvas.SetColor(255.0, 255.0, 255.0);
    }
    Canvas.CurY -= 8;
    
    // Move type flags
    mtFlags = GetMoveTypeFlags();
    Canvas.DrawText("  MoveType Flags:");
    Canvas.CurY -= 16;
    Canvas.CurX += 160;
    if(mtFlags == MT_DODGE)             Canvas.DrawText("MT_DODGE");
    else if(mtFlags == MT_EDGEHANG)     Canvas.DrawText("MT_EDGEHANG");
    else if(mtFlags == MT_EDGEPULLUP)   Canvas.DrawText("MT_EDGEPULLUP");
    else if(mtFlags == MT_JUMP)         Canvas.DrawText("MT_JUMP");
    else if(mtFlags == MT_LAND)         Canvas.DrawText("MT_LAND");
    else if(mtFlags == MT_NEUTRAL)      Canvas.DrawText("MT_NEUTRAL");
    else
    {
        Canvas.SetColor(255.0, 0.0, 0.0);
        Canvas.DrawText("ERROR - INVALID MT FLAGS");
        Canvas.SetColor(255.0, 255.0, 255.0);
    }   
    Canvas.CurY -= 8;

    // Variation flags
    vrFlags = GetVariationFlags();
    Canvas.DrawText("  Variation Flags:");
    Canvas.CurY -= 16;
    Canvas.CurX += 160;
    if(vrFlags == VR_0)                 Canvas.DrawText("VR_0");
    else if(vrFlags == VR_1)            Canvas.DrawText("VR_1");
    else if(vrFlags == VR_2)            Canvas.DrawText("VR_2");
    else if(vrFlags == VR_3)            Canvas.DrawText("VR_3");
    else
    {
        Canvas.SetColor(255.0, 0.0, 0.0);
        Canvas.DrawText("ERROR - INVALID VR FLAGS");
        Canvas.SetColor(255.0, 255.0, 255.0);
    }
    Canvas.CurY -= 8;
}


////////////////////////////////////////////////////////////////////////////////
//  Defaults
////////////////////////////////////////////////////////////////////////////////
defaultproperties
{
    MovementMask=0
    AnimationProxyClass=None
    bStatic=False
    bFrameNotifies=True
    NetPriority=3.000000
    Weapon=None
    AttackAnimation='None'
}