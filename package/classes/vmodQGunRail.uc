class vmodQGunRail extends vmodQGunBaseTracer;

#EXEC SKELETAL IMPORT NAME=railgun FILE=..\Vmod\Models\railgun.scm
#exec SKELETAL ORIGIN NAME=railgun X=0 Y=0 Z=0 Pitch=0 Yaw=64 Roll=-64
#EXEC TEXTURE IMPORT NAME=railguntex FILE=..\Vmod\Textures\railgun.bmp
#EXEC AUDIO IMPORT NAME=railgunsound FILE=..\Vmod\sounds\railgun.wav

function WeaponFire(int SwingCount)
{
	local vector HitLocation, HitNormal, StartTrace, EndTrace, X, Y, Z;
	local actor Other;
	local Pawn PawnOwner;
	local vmodQuakeRail Rail;
	
	PawnOwner = Pawn(Owner);
	
	GetAxes(PawnOwner.ViewRotation, X, Y, Z);
	StartTrace = Owner.Location;
	EndTrace = StartTrace + vector(Pawn(Owner).ViewRotation) * 4000;
	
	Other = PawnOwner.Trace(HitLocation, HitNormal, EndTrace, StartTrace);
	
	Spawn(class'HitMetal',,,HitLocation,Rotator(HitNormal));
	
	if(Pawn(Other) != None)
	{
		Pawn(Other).DamageBodyPart(
			1000,
			Pawn(Owner),
			HitLocation,
			Normal(EndTrace - StartTrace) * 4000,
			'None',
			0);
	}
	
	Rail = Spawn(Class'vmodQuakeRail',owner,, HitLocation, Owner.Rotation);
	Rail.VampireDest = Pawn(Owner);
	
	PlaySound(Sound'Vmod.railgunsound');
}

defaultproperties
{
	Skeletal=SkelModel'Vmod.railgun'
    SkelGroupSkins(0)=Texture'Vmod.railguntex'
    SkelGroupSkins(1)=Texture'Vmod.railguntex'
}