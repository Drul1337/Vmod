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
	local vmodRunePlayer P;

	if(!A.IsA('RunePlayer'))
		return A;
    
    if(A.IsA('RunePlayer'))     return HandleSpawnedRunePlayer(RunePlayer(A));
    else if(A.IsA('Weapon'))    return HandleSpawnedWeapon(Weapon(A));
    
	return A;
}

////////////////////////////////////////////////////////////////////////////////
//  HandleSpawnedRunePlayer
//
//  Replace all RunePlayers with vmodRunePlayers
////////////////////////////////////////////////////////////////////////////////
function Actor HandleSpawnedRunePlayer(RunePlayer rp)
{
    local vmodRunePlayer vrp;
    
    // This prevents the original RunePlayer from exploding before copy
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
//  HandleSpawnedWeapon
//
//  Replace Weapons appropriately
////////////////////////////////////////////////////////////////////////////////
function Actor HandleSpawnedWeapon(Weapon w)
{
    // Maces
    if(w.IsA('RustyMace'))              return WeaponDestroy(w);
    else if(w.IsA('BoneClub'))          return WeaponDestroy(w);
    else if(w.IsA('TrialPitMace'))      return WeaponDestroy(w);
    else if(w.IsA('DwarfWorkHammer'))   return WeaponDestroy(w);
    else if(w.IsA('DwarfBattleHamer'))  return WeaponDestroy(w);
    // Axes
    else if(w.IsA('Handaxe'))           return WeaponDestroy(w);
    else if(w.IsA('GoblinAxe'))         return WeaponDestroy(w);
    else if(w.IsA('VikingAxe'))         return WeaponDestroy(w);
    else if(w.IsA('SigurdAxe'))         return WeaponDestroy(w);
    else if(w.IsA('DwarfBattleAxe'))    return WeaponDestroy(w);
    // Swords
    else if(w.IsA('VikingShortSword'))  return WeaponDestroy(w);
    else if(w.IsA('RomanSword'))        return WeaponDestroy(w);
    else if(w.IsA('VikingBroadSword'))  return WeaponDestroy(w);
    else if(w.IsA('DwarfWorkSword'))    return WeaponDestroy(w);
    else if(w.IsA('DwarfBattleSword'))  return WeaponDestroy(w);
    
    // Unhandled
    return w;
}

function Actor WeaponReplace(Weapon w, class<Weapon> wReplace)
{
    return w;
}

function Actor WeaponDestroy(Weapon w)
{
    w.Destroy();
    return w;
}

function Actor WeaponPass(Weapon w)
{
    return w;
}

////////////////////////////////////////////////////////////////////////////////
//  Defaults
////////////////////////////////////////////////////////////////////////////////
defaultproperties
{
	ActorClass=Class'RuneI.RunePlayer'
}