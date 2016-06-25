////////////////////////////////////////////////////////////////////////////////
//  vmodSpawnNotify.uc
//
//  Performs all necessary Actor replacement

class vmodSpawnNotify extends SpawnNotify;

////////////////////////////////////////////////////////////////////////////////
//  SpawnNotification
////////////////////////////////////////////////////////////////////////////////
simulated event Actor SpawnNotification(Actor A)
{
	if(!A.IsA('RunePlayer'))
		return A;
    
    if((A.IsA('RunePlayer') && !A.IsA('VmodRunePlayer')))
        return HandleSpawnedRunePlayer(A);
    
	return A;
}

////////////////////////////////////////////////////////////////////////////////
//  HandleSpawnedRunePlayer
//
//  Replace all RunePlayers with vmodRunePlayers
////////////////////////////////////////////////////////////////////////////////
simulated function Actor HandleSpawnedRunePlayer(Actor A)
{
    local vmodRunePlayer vrp;
    local RunePlayer rp;
    
    // This prevents the original RunePlayer from exploding before copy
    rp = RunePlayer(A);
    rp.bHidden = true;
	rp.bIsPlayer = false;
	rp.SetCollision(false, false, false);
    
    vrp = Spawn(
        Class'vmodPlayerRagnar',
        rp.Owner,
        rp.Tag,
        rp.Location,
        rp.Rotation);
    rp.Destroy();
    
    return vrp;
}

////////////////////////////////////////////////////////////////////////////////
//  Defaults
////////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ActorClass=Class'RuneI.RunePlayer'
}