class vmodQRocketEffect extends ParticleSystem;

defaultproperties
{
	ParticleCount=5
     ParticleTexture(0)=FireTexture'RuneFX.Flame'
     ScaleMin=0.700000
     ScaleMax=1.200000
     ScaleDeltaX=0.600000
     ScaleDeltaY=0.600000
     LifeSpanMin=0.050000
     LifeSpanMax=0.100000
     AlphaStart=175
     AlphaEnd=25
     bAlphaFade=True
     SpawnOverTime=1.000000
     bDirectional=True
     Style=STY_Translucent
	
	// Trail effect
	//bSystemOneShot=True
    //ParticleCount=10
    //ParticleTexture(0)=FireTexture'RuneFX.Smoke'
    //ScaleMin=0.25
    //ScaleMax=0.5
    //ScaleDeltaX=3.0
    //ScaleDeltaY=3.0
    //LifeSpanMin=0.200000
    //LifeSpanMax=0.400000
    //AlphaStart=30.0
    //AlphaEnd=0.0
    //PercentOffset=1
    //bAlphaFade=True
    //bApplyGravity=False
    //SpawnOverTime=1.000000
    //bDirectional=True
    //Style=STY_Translucent
}