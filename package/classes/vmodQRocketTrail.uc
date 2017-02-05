class vmodQRocketTrail extends ParticleSystem;

simulated function Tick(float DeltaTime)
{
	
}

defaultproperties
{
	bSystemOneShot=True
    ParticleCount=25
    ParticleTexture(0)=FireTexture'RuneFX.Smoke'
    ScaleMin=0.65
    ScaleMax=0.75
    ScaleDeltaX=3.0
    ScaleDeltaY=3.0
    LifeSpanMin=0.500000
    LifeSpanMax=0.700000
    AlphaStart=30.0
    AlphaEnd=0.0
    PercentOffset=1
    bAlphaFade=True
    bApplyGravity=False
    SpawnOverTime=1.000000
    bDirectional=True
    Style=STY_Translucent
}