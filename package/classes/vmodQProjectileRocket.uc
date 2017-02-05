class vmodQProjectileRocket extends vmodQProjectileBase;

#EXEC SKELETAL IMPORT NAME=qrocket FILE=..\Vmod\Models\qrocket.scm
#exec SKELETAL ORIGIN NAME=qrocket X=0 Y=0 Z=0 Pitch=0 Yaw=0 Roll=-64
#EXEC TEXTURE IMPORT NAME=qrockettex FILE=..\Vmod\Textures\rocket.bmp

var float m_splashRadius;
var float m_splashDamage;
var float m_timer;
var float m_lastSmoke;

simulated function Tick(float DeltaTime)
{
	local vector X, Y, Z;
	local Actor smoke;

	Super.Tick(DeltaTime);
	
	m_timer += DeltaTime;
	if((m_timer - m_lastSmoke) > 0.05)
	{
		m_lastSmoke = m_timer;
		smoke = Spawn(
			class'vmod.vmodQRocketSmoke'
			,,,
			GetJointPos(JointNamed('base')));
		
		GetAxes(Rotation, X, Y, Z);
		smoke.Velocity = Normal(Y) * 20.0;
	}		
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
	
	Spawn(class'RuneFX.EmpathyFlash',,,Location);
	
	Super.Explode(HitLocation, HitNormal);
}

defaultproperties
{
	m_lastSmoke=0.0
	m_timer=0.0
	DrawScale=2.5
	m_splashRadius=192.0
	m_splashDamage=25.0
	bFixedRotationDir=true
	RotationRate=(Yaw=0,Pitch=0,Roll=360000)
	
	Speed=1200.0
	DrawType=DT_SkeletalMesh
	Skeletal=SkelModel'Vmod.qrocket'
    SkelGroupSkins(0)=Texture'Vmod.qrockettex'
    SkelGroupSkins(1)=Texture'Vmod.qrockettex'
	
	m_spawnParticlesClass=Class'Vmod.vmodQRocketEffect'
	//m_trailParticlesClass=Class'Vmod.vmodQRocketTrail'
	m_explodeParticlesClass=Class'vmod.vmodQRocketExplosion'
	m_baseEffectClass=Class'vmod.vmodQRocketBaseEffect'
	
	// Physical impact damage
	Damage=50.0
}