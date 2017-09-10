////////////////////////////////////////////////////////////////////////////////
//	vmodMountSnowBeast.uc
//

class vmodMountSnowBeast extends vmodMountBase;

defaultproperties
{
	RiderOffset=(X=12.0,Y=0.0,Z=25.0)
	Skeletal=SkelModel'creatures.SnowBeast'
	AnimIdle=idl_sbeast_breathe1_an0n
	AnimRun=run
	AnimWalk=walk
	AnimJump=jump
	AnimHitFront=cower
	AnimDeathFront=deathf
	AnimDeathLeft=death
	AnimDeathRight=deathl
	AnimDeathBack=deathf
	AnimDeathDrown=drown_death
	CollisionRadius=40.000000
    CollisionHeight=47.000000
}