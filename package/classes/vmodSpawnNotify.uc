//=============================================================================
// vmodSpawnNotify
//=============================================================================
class vmodSpawnNotify extends SpawnNotify;

simulated event Actor SpawnNotification(Actor A)
{
	local vmodRunePlayer P;

	if(!A.IsA('RunePlayer'))
		return A;
	
	A.bHidden = true;
	Pawn(A).bIsPlayer = false;
	A.SetCollision(false, false, false);
	P = Spawn(Class'vmodPlayerRagnar', A.Owner, A.Tag, A.Location, A.Rotation);
	A.Destroy();
	return P;
}

defaultproperties
{
	ActorClass=Class'RuneI.RunePlayer'
}