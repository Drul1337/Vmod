class vmodQRocketShootEffect extends vmodEffect;

simulated function TickEffect()
{
	local float r;
	local float tscale;

	r = m_timeElapsed / m_timeSpan;
	tscale = ((1.0 - r) * 0.75) + (r * 1.0);
	DrawScale = tscale;
	ScaleGlow = (1.0 - r) * 0.75;
}

defaultproperties
{
	m_timeSpan=1.0
    DrawType=DT_Sprite
    Style=STY_Translucent
    Texture=Texture'RuneFX.smoke'
}