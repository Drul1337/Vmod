class vmodQProjectileBase extends Projectile;

var class<ParticleSystem> m_spawnParticlesClass;
var class<ParticleSystem> m_trailParticlesClass;
var class<ParticleSystem> m_explodeParticlesClass;

var ParticleSystem m_spawnParticles;
var ParticleSystem m_trailParticles;

function PreBeginPlay()
{
	local vector X, Y, Z;
	
	if(Owner != None)
	{
		DrawScale = Owner.DrawScale;
	}
	
	if(m_spawnParticlesClass != None)
	{
		m_spawnParticles = Spawn(m_spawnParticlesClass,,,,Rotation);
		m_spawnParticles.SetBase(self);
	}
	
	if(m_trailParticlesClass != None)
	{
		m_trailParticles = Spawn(m_trailParticlesClass,,,,Rotation);
		m_trailParticles.SetBase(self);
	}
	
	if(Pawn(Owner) != None)
	{
		GetAxes(Pawn(Owner).ViewRotation, X, Y, Z);
		Velocity = X * Speed;
	}
}

simulated function Destroyed()
{
	// TODO: Particle systems should destroy themselves
	if(m_spawnParticles != None)
	{
		m_spawnParticles.Destroy();
	}
	
	if(m_trailParticles != None)
	{
		m_trailParticles.Destroy();
	}
}

simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	// Do not allow this projectile to hit its owner
	if(Owner != None)
	{
		if(Other == Owner || Other == Owner.Owner)
		{
			return;
		}
	}
	
	// Apply direct projectile hit damage
	if(Pawn(Other) != None)
	{
		Other.JointDamaged(
			Damage,
			Instigator,
			HitLocation,
			MomentumTransfer*Normal(Velocity),
			MyDamageType,
			0);
	}
	
	Explode(HitLocation, -Normal(Velocity));
}

simulated function Landed(vector HitNormal, actor HitActor)
{
	Explode(Location, HitNormal);
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
	if(m_explodeParticlesClass != None)
	{
		Spawn(m_explodeParticlesClass,,,,Rotation);
	}
	
	Destroy();
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	m_spawnParticlesClass=None
	m_trailParticlesClass=None
	m_explodeParticlesClass=None
	m_spawnParticles=None
	m_trailParticles=None
}