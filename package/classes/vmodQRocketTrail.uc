class vmodQRocketTrail extends ParticleSystem;

defaultproperties
{
	bSystemOneShot=True
    ParticleCount=10
    ParticleTexture(0)=FireTexture'RuneFX.Smoke'
    ScaleMin=0.25
    ScaleMax=0.5
    ScaleDeltaX=3.0
    ScaleDeltaY=3.0
    LifeSpanMin=0.200000
    LifeSpanMax=0.400000
    AlphaStart=30.0
    AlphaEnd=0.0
    PercentOffset=1
    bAlphaFade=True
    bApplyGravity=False
    SpawnOverTime=1.000000
    bDirectional=True
    Style=STY_Translucent
}