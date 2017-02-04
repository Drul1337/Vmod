class vmodQuakeRail extends BeamSystem;

var vector OriginLocation;
var vector HitLocation;

function PreBeginPlay()
{
	local actor A;
	local int i;

	Super(ParticleSystem).PreBeginPlay();

	ParticleCount = NumConPts * 3;

	for(i = 0; i < NumConPts; i++)
		ConnectionPoint[i] = Location;

	SetTimer(5 + FRand()*2, false);
}

event SystemInit()
{
	Super.SystemInit();
	RemoteRole = ROLE_None;
}

event SystemTick(float DeltaSeconds)
{
	local int i;
	local float alpha;
	
	ConnectionPoint[0].X = OriginLocation.X;
	ConnectionPoint[0].Y = OriginLocation.Y;
	ConnectionPoint[0].Z = OriginLocation.Z;
	ConnectionOffset[0].X = 0;
	ConnectionOffset[0].Y = 0;
	ConnectionOffset[0].Z = 0;
	
	for(i = 1; i < NumConPts; i++)
	{
		ConnectionPoint[i].X = HitLocation.X;
		ConnectionPoint[i].Y = HitLocation.Y;
		ConnectionPoint[i].Z = HitLocation.Z;
		ConnectionOffset[i].X = 0;
		ConnectionOffset[i].Y = 0;
		ConnectionOffset[i].Z = 0;
	}
	
	CurrentTime += DeltaSeconds;
	if(CurrentTime >= SystemLifeSpan)
	{
		Destroy();
	}
	
	// Fade particles
	for(i = 0; i < ParticleCount; i++)
	{
		ParticleArray[i].Style = Style;
		alpha = CurrentTime / SystemLifeSpan; // Linear alpha fade
		alpha = 1.0 - alpha;
		ParticleArray[i].Alpha.X = alpha;
		ParticleArray[i].Alpha.Y = alpha;
		ParticleArray[i].Alpha.Z = alpha;
	}
}

event ParticleTick(float DeltaSeconds)
{ // ParticleTick ticks ALL particles in a given ParticleSystem
}

function Timer()
{
	//// Hack - Beams must go through render code once before going to stasis
	// Don't know what this means
	bStasis=true;
}

function SpawnBeamDebris()
{}

defaultproperties
{
	bSystemTicks=false
	bEventSystemTick=true
	AlphaScale=1.0
	
	LastTime=0.0
	CurrentTime=0.0
	SystemLifeSpan=3.0
	AlphaStart=255
	AlphaEnd=0
	Style=STY_AlphaBlend
	
    ParticleCount=1
    ParticleTexture(0)=Texture'RuneFX.beam'
    NumConPts=20
    BeamThickness=1.500000
}
