//=============================================================================
// vmodPlayerRagnar
//=============================================================================
class vmodPlayerRagnar extends vmodRunePlayer;

#EXEC SKELETAL IMPORT NAME=VmodRagnarSkel FILE=..\Vmod\Models\vmod_ragnar_full.scm
#EXEC TEXTURE IMPORT NAME=VmodRagnarTextureBody FILE=..\Vmod\Textures\vmod_ragnar_body.bmp

defaultproperties
{
    SubstituteMesh=SkelModel'VmodRagnarSkel'
	SkelGroupSkins(0)=Texture'Vmod.VmodRagnarTextureHead'
	SkelGroupSkins(1)=Texture'Vmod.VmodRagnarTextureArm'
	SkelGroupSkins(2)=Texture'Vmod.VmodRagnarTextureArm'
	SkelGroupSkins(3)=Texture'Vmod.VmodRagnarTextureBody'
	//RemoteRole=ROLE_SimulatedProxy
	//Skeletal=SkelModel'creatures.SnowBeast'
	//GroundSpeed=500.0
}