class vmodQRocketExplosion extends vmodEffect;

simulated function TickEffect()
{
	local float r;
	local float tscale;

	r = m_timeElapsed / m_timeSpan;
	tscale = ((1.0 - r) * 0.1) + (r * 1.0);
	DrawScale = tscale;
	ScaleGlow = 1.0 - r;
}

defaultproperties
{
	m_timeSpan=0.5
    DrawType=DT_Sprite
    Style=STY_Translucent
    Texture=Texture'RuneFX.explosion1'
}