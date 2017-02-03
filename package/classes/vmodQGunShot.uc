class vmodQGunShot extends vmodQGunBaseTracer;

#EXEC SKELETAL IMPORT NAME=shotgun FILE=..\Vmod\Models\qshotgun.scm
#EXEC SKELETAL ORIGIN NAME=shotgun X=0 Y=0 Z=0 Pitch=0 Yaw=64 Roll=-64
#EXEC TEXTURE IMPORT NAME=shotguntex FILE=..\Vmod\Textures\shotgun.bmp
#EXEC AUDIO IMPORT NAME=shotgunsound FILE=..\Vmod\sounds\shotgun.wav

var float Spread;
var int NumShots;
var int ShotDamage;

function WeaponFire(int SwingCount)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local actor Other;
	local Pawn PawnOwner;
	local int i;
	
	PawnOwner = Pawn(Owner);
	
	GetAxes(PawnOwner.ViewRotation, X, Y, Z);
	StartTrace = Owner.Location;
	
	for(i = 0; i < NumShots; i++)
	{
		EndTrace = vector(Pawn(Owner).ViewRotation);
		EndTrace = EndTrace + (Y * ((FRand() * Spread) - (Spread * 0.5)));
		EndTrace = EndTrace + (Z * ((FRand() * Spread) - (Spread * 0.5)));
		EndTrace = Normal(EndTrace) * 4000;
		EndTrace = StartTrace + EndTrace;
		
		Other = PawnOwner.Trace(HitLocation, HitNormal, EndTrace, StartTrace);
		Spawn(class'HitMetal',,,HitLocation, Rotator(HitNormal));
		
		if(Pawn(Other) != None)
		{
			Pawn(Other).DamageBodyPart(
				ShotDamage,
				Pawn(Owner),
				HitLocation,
				Normal(EndTrace - StartTrace) * 4000,
				'None',
				0);
		}
	}
	
	PlaySound(Sound'Vmod.shotgunsound');
}

defaultproperties
{
	//ThroughAir(0)=Sound'Vmod.shotgunsound'
	Spread=0.25
	NumShots=30
	ShotDamage=5
	Skeletal=SkelModel'Vmod.shotgun'
    SkelGroupSkins(0)=Texture'Vmod.shotguntex'
    SkelGroupSkins(1)=Texture'Vmod.shotguntex'
}