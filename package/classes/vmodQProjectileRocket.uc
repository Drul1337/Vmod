class vmodQProjectileRocket extends vmodQProjectileBase;

#EXEC SKELETAL IMPORT NAME=qrocket FILE=..\Vmod\Models\qrocket.scm
#exec SKELETAL ORIGIN NAME=qrocket X=0 Y=0 Z=0 Pitch=0 Yaw=0 Roll=-64
#EXEC TEXTURE IMPORT NAME=qrockettex FILE=..\Vmod\Textures\rocket.bmp

var float m_splashRadius;
var float m_splashDamage;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	Velocity = Vector(Rotation) * speed;
	RandSpin(50000);
	PlaySound(SpawnSound);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	local Pawn P;
	local float splashDamage;
	local vector offset;
	local float distance;
	local float falloff;
	
	// Splash damage
	foreach RadiusActors(Class'Pawn', P, m_splashRadius)
	{
		offset = P.Location - HitLocation;
		distance = VSize(offset);
		falloff = 1.0 - (distance / m_splashRadius);
		falloff = falloff * falloff; // damage falloff by inverse square
		splashDamage = m_splashDamage * falloff;
		
		P.JointDamaged(
			splashDamage, // damage
			None, // Instigator
			HitLocation,
			HitNormal, // Force vector
			'None', // Damage type
			0);
	}
	
	Super.Explode(HitLocation, HitNormal);
}

defaultproperties
{
	m_splashRadius=192.0
	m_splashDamage=25.0
	bFixedRotationDir=true
	RotationRate=(Yaw=0,Pitch=0,Roll=240000)
	
	Speed=1000.0
	DrawType=DT_SkeletalMesh
	Skeletal=SkelModel'Vmod.qrocket'
    SkelGroupSkins(0)=Texture'Vmod.qrockettex'
    SkelGroupSkins(1)=Texture'Vmod.qrockettex'
	
	m_spawnParticlesClass=Class'Vmod.vmodQRocketEffect'
	m_trailParticlesClass=Class'Vmod.vmodQRocketTrail'
	m_explodeParticlesClass=Class'RuneI.MechRocketExplosion'
	
	// Physical impact damage
	Damage=0
}