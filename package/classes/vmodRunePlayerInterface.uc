///////////////////////////////////////////////////////////////////////////////
// vmodRunePlayerInterface.uc
//
//		|---Object
//			|---Actor
//				|---Pawn
//					|---PlayerPawn
//						|---vmodPlayerPawnBase
//							|---vmodPlayerPawnInterface
//								|---vmodRunePlayerBase
//									|---vmodRunePlayerInterface
//

class vmodRunePlayerInterface extends vmodRunePlayerBase config(user) abstract;




///////////////////////////////////////////////////////////////////////////////
//
// REPLICATION BLOCK
//
///////////////////////////////////////////////////////////////////////////////
replication
{
	// Client can call
	reliable if(Role < ROLE_Authority)
		CameraIn,
		CameraOut,
		ZTargetToggle;
}




///////////////////////////////////////////////////////////////////////////////
//
// EXEC FUNCTIONS
//
///////////////////////////////////////////////////////////////////////////////
exec function CameraIn()		{ HandleCmdCameraIn(); }
exec function CameraOut()		{ HandleCmdCameraOut(); }
exec function ZTargetToggle()	{ HandleCmdZTargetToggle(); }
exec function DumpWeaponInfo()	{ HandleCmdDumpWeaponInfo(); }
exec function DropZ()			{ HandleCmdDropZ(); }
exec function TraceTex()		{ HandleCmdTraceTex(); }





///////////////////////////////////////////////////////////////////////////////
//
//	STATES
//
//	Guarantee that only the global exec function is ever called. Override the
//	command handler function for state-specific functionality.
//
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// STATE: PlayerWalking
state PlayerWalking
{
	exec function CameraIn()		{ Global.CameraIn(); }
	exec function CameraOut()		{ Global.CameraOut(); }
	exec function ZTargetToggle() 	{ Global.ZTargetToggle(); }
	exec function DumpWeaponInfo()	{ Global.DumpWeaponInfo(); }
	exec function DropZ()			{ Global.DropZ(); }
	exec function TraceTex()		{ Global.TraceTex(); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: EdgeHanging
state EdgeHanging
{
	exec function CameraIn()		{ Global.CameraIn(); }
	exec function CameraOut()		{ Global.CameraOut(); }
	exec function ZTargetToggle() 	{ Global.ZTargetToggle(); }
	exec function DumpWeaponInfo()	{ Global.DumpWeaponInfo(); }
	exec function DropZ()			{ Global.DropZ(); }
	exec function TraceTex()		{ Global.TraceTex(); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: FeigningDeath
state FeigningDeath
{
	exec function CameraIn()		{ Global.CameraIn(); }
	exec function CameraOut()		{ Global.CameraOut(); }
	exec function ZTargetToggle() 	{ Global.ZTargetToggle(); }
	exec function DumpWeaponInfo()	{ Global.DumpWeaponInfo(); }
	exec function DropZ()			{ Global.DropZ(); }
	exec function TraceTex()		{ Global.TraceTex(); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: PlayerSwimming
state PlayerSwimming
{
	exec function CameraIn()		{ Global.CameraIn(); }
	exec function CameraOut()		{ Global.CameraOut(); }
	exec function ZTargetToggle() 	{ Global.ZTargetToggle(); }
	exec function DumpWeaponInfo()	{ Global.DumpWeaponInfo(); }
	exec function DropZ()			{ Global.DropZ(); }
	exec function TraceTex()		{ Global.TraceTex(); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: PlayerFlying
state PlayerFlying
{
	exec function CameraIn()		{ Global.CameraIn(); }
	exec function CameraOut()		{ Global.CameraOut(); }
	exec function ZTargetToggle() 	{ Global.ZTargetToggle(); }
	exec function DumpWeaponInfo()	{ Global.DumpWeaponInfo(); }
	exec function DropZ()			{ Global.DropZ(); }
	exec function TraceTex()		{ Global.TraceTex(); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: CheatFlying
state CheatFlying
{
	exec function CameraIn()		{ Global.CameraIn(); }
	exec function CameraOut()		{ Global.CameraOut(); }
	exec function ZTargetToggle() 	{ Global.ZTargetToggle(); }
	exec function DumpWeaponInfo()	{ Global.DumpWeaponInfo(); }
	exec function DropZ()			{ Global.DropZ(); }
	exec function TraceTex()		{ Global.TraceTex(); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: PlayerWaiting
state PlayerWaiting
{
	exec function CameraIn()		{ Global.CameraIn(); }
	exec function CameraOut()		{ Global.CameraOut(); }
	exec function ZTargetToggle() 	{ Global.ZTargetToggle(); }
	exec function DumpWeaponInfo()	{ Global.DumpWeaponInfo(); }
	exec function DropZ()			{ Global.DropZ(); }
	exec function TraceTex()		{ Global.TraceTex(); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: PlayerSpectating
state PlayerSpectating
{
	exec function CameraIn()		{ Global.CameraIn(); }
	exec function CameraOut()		{ Global.CameraOut(); }
	exec function ZTargetToggle() 	{ Global.ZTargetToggle(); }
	exec function DumpWeaponInfo()	{ Global.DumpWeaponInfo(); }
	exec function DropZ()			{ Global.DropZ(); }
	exec function TraceTex()		{ Global.TraceTex(); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: Pain
state Pain
{
	exec function CameraIn()		{ Global.CameraIn(); }
	exec function CameraOut()		{ Global.CameraOut(); }
	exec function ZTargetToggle() 	{ Global.ZTargetToggle(); }
	exec function DumpWeaponInfo()	{ Global.DumpWeaponInfo(); }
	exec function DropZ()			{ Global.DropZ(); }
	exec function TraceTex()		{ Global.TraceTex(); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: Uninterrupted
state Uninterrupted
{
	exec function CameraIn()		{ Global.CameraIn(); }
	exec function CameraOut()		{ Global.CameraOut(); }
	exec function ZTargetToggle() 	{ Global.ZTargetToggle(); }
	exec function DumpWeaponInfo()	{ Global.DumpWeaponInfo(); }
	exec function DropZ()			{ Global.DropZ(); }
	exec function TraceTex()		{ Global.TraceTex(); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: Dying
state Dying
{
	exec function CameraIn()		{ Global.CameraIn(); }
	exec function CameraOut()		{ Global.CameraOut(); }
	exec function ZTargetToggle() 	{ Global.ZTargetToggle(); }
	exec function DumpWeaponInfo()	{ Global.DumpWeaponInfo(); }
	exec function DropZ()			{ Global.DropZ(); }
	exec function TraceTex()		{ Global.TraceTex(); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: GameEnded
state GameEnded
{
	exec function CameraIn()		{ Global.CameraIn(); }
	exec function CameraOut()		{ Global.CameraOut(); }
	exec function ZTargetToggle() 	{ Global.ZTargetToggle(); }
	exec function DumpWeaponInfo()	{ Global.DumpWeaponInfo(); }
	exec function DropZ()			{ Global.DropZ(); }
	exec function TraceTex()		{ Global.TraceTex(); }
}