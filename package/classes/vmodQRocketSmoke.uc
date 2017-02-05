class vmodQRocketSmoke extends vmodEffect;

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	SetLocation(Location + Velocity * DeltaTime);
}

simulated function TickEffect()
{
	local float r;
	local float tscale;

	r = m_timeElapsed / m_timeSpan;
	tscale = ((1.0 - r) * 1.25) + (r * 2.0);
	DrawScale = tscale;
	
	r = r * r;
	ScaleGlow = (1.0 - r) * 0.6;
	//ScaleGlow = 1.0 - r;
}

defaultproperties
{
	m_timeSpan=2.2
    DrawType=DT_Sprite
    Style=STY_Translucent
    Texture=Texture'RuneFX.smoke'
}