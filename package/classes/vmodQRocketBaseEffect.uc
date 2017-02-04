class vmodQRocketBaseEffect extends vmodEffect;

simulated function TickEffect()
{
	// Maybe a sin wave scale?
}

defaultproperties
{
	m_timeSpan=0.0
    DrawType=DT_Sprite
    Style=STY_Translucent
    Texture=Texture'RuneFX.deely1'
	DrawScale=0.6
	ScaleGlow=0.75
}