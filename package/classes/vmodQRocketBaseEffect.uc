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
	DrawScale=0.75
	ScaleGlow=0.9
	ColorAdjust=(X=1.0,Y=0.0,Z=0.0)
}