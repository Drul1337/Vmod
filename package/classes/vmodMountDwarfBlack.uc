////////////////////////////////////////////////////////////////////////////////
//	vmodMountDwarfBlack.uc
//

class vmodMountDwarfBlack extends vmodMountBase;

defaultproperties
{
	RiderOffset=(X=-10.0,Y=0.0,Z=84.0)
	Skeletal=SkelModel'creatures.Dwarf'
	SkelMesh=9
	AnimIdle=dd_idlea
	AnimRun=runA
	AnimWalk=walk
	AnimJump=jump
	AnimHitFront=cower
	AnimDeathFront=deathf
	AnimDeathLeft=death
	AnimDeathRight=deathl
	AnimDeathBack=deathf
	AnimDeathDrown=drown_death
	CollisionRadius=105.000000
    CollisionHeight=99.000000
	MaxBodyAngle=(Yaw=22768)
    MaxHeadAngle=(Pitch=2048,Yaw=2048)
    DrawScale=3.000000
}