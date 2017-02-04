class vmodEffect extends Actor;

var float m_timeSpan;
var float m_timeElapsed;

simulated function Spawned()
{
	m_timeElapsed = 0.0;
}

simulated function Tick(float DeltaTime)
{
	m_timeElapsed += DeltaTime;
	if(m_timeSpan != 0.0 && m_timeElapsed >= m_timeSpan)
	{
		Destroy();
		return;
	}
	TickEffect();
}

simulated function TickEffect() {}

defaultproperties
{
	m_timeSpan=0.0
	RemoteRole=ROLE_SimulatedProxy
	bNetTemporary=true
	DrawType=DT_None
	bGameRelevant=true
	bCollideActors=false
}