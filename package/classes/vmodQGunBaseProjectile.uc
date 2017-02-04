class vmodQGunBaseProjectile extends vmodQGunBase;

var class<Projectile> ProjectileClass;
var Sound FireSound;

function WeaponFire(int SwingCount)
{
	local Projectile P;
	local vector X, Y, Z;
	
	if(ProjectileClass != None)
	{
		P = Spawn(
			ProjectileClass,
			self,,
			Location + X * 40.0,
			Pawn(Owner).ViewRotation);
	}
	PlaySound(FireSound);
}

defaultproperties
{
	ProjectileClass=Class'None'
	FireSound='None'
}