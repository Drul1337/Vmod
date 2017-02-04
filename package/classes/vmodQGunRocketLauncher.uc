class vmodQGunRocketLauncher extends vmodQGunBaseProjectile;

#EXEC SKELETAL IMPORT NAME=rocketl FILE=..\Vmod\Models\qrocketlauncher.scm
#exec SKELETAL ORIGIN NAME=rocketl X=0 Y=0 Z=0 Pitch=0 Yaw=64 Roll=-64
#EXEC TEXTURE IMPORT NAME=rocketltex FILE=..\Vmod\Textures\rocketl.bmp
#EXEC AUDIO IMPORT NAME=rocketlsound FILE=..\Vmod\sounds\rocketl.wav

function WeaponFire(int SwingCount)
{
	local Projectile P;
	local vmodEffect Eff;
	local int BarrelJoint;
	local vector X, Y, Z;
	
	if(ProjectileClass != None)
	{
		P = Spawn(
			ProjectileClass,
			self,,
			Location + X * 40.0,
			Pawn(Owner).ViewRotation);
	}
	
	Eff = Spawn(class'vmod.vmodQRocketShootEffect');
	BarrelJoint = JointNamed('Barrel');
	Eff.SetLocation(GetJointPos(BarrelJoint));
	//AttachActorToJoint(Eff, BarrelJoint);
	
	PlaySound(FireSound);
}

defaultproperties
{
	ProjectileClass=Class'Vmod.vmodQProjectileRocket'
	FireSound=Sound'Vmod.rocketlsound'
	Skeletal=SkelModel'Vmod.rocketl'
    SkelGroupSkins(0)=Texture'Vmod.rocketltex'
    SkelGroupSkins(1)=Texture'Vmod.rocketltex'
}