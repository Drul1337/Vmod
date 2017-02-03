class vmodQGunLightning extends vmodQGunBaseTracer;

#EXEC SKELETAL IMPORT NAME=lightninggun FILE=..\Vmod\Models\qlightninggun.scm
#exec SKELETAL ORIGIN NAME=lightninggun X=0 Y=0 Z=0 Pitch=0 Yaw=64 Roll=-64
#EXEC TEXTURE IMPORT NAME=lightningguntex FILE=..\Vmod\Textures\lightning.bmp

defaultproperties
{
	Skeletal=SkelModel'Vmod.lightninggun'
    SkelGroupSkins(0)=Texture'Vmod.lightningguntex'
    SkelGroupSkins(1)=Texture'Vmod.lightningguntex'
}