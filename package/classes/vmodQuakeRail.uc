class vmodQuakeRail extends VampireTrail;

function ServerReachedDest()
{}

function ServerBegin()
{}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	//ToDestVelocity = 800 + 200 * FRand(); // velocity to the player

	Swipe = Spawn(SwipeClass, self,, Location,);
	if(Swipe != None)
	{
		Swipe.RemoteRole=ROLE_None;		// Spawn on clients, don't replicate
		Swipe.BaseJointIndex = JointNamed('one');
		Swipe.OffsetJointIndex = JointNamed('two');
		Swipe.SystemLifeSpan = -1;
		Swipe.SwipeSpeed = 2;
		AttachActorToJoint(Swipe, JointNamed('one'));
	}
}

simulated function Tick(float DeltaTime)
{
	local vector toDest;
	local float dist;
	local vector v;

	if(VampireDest == None)
	{
//		Destroy();
		return;
	}

	alpha += DeltaTime * 0.8;
	if(alpha > 1.0)
		alpha = 1.0;

	toDest = VampireDest.Location - Location;
	if(VSize(toDest) < 20)
	{
		ServerReachedDest();
		Destroy();
		return;
	}

	v = Velocity * (1.0 - alpha) + (ToDestVelocity * Normal(toDest)) * alpha + VRand() * 40;
	Velocity += Acceleration * DeltaTime;
	
	if(VSize(v) > 1000)
		v = 1000 * Normal(v);

	SetLocation(Location + v * DeltaTime);
}