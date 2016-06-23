////////////////////////////////////////////////////////////////////////////////
// vmodHUD
////////////////////////////////////////////////////////////////////////////////
// class vmodHUD extends HUD;
class vmodHUD extends RuneHUD;

simulated function Tick(float DT)
{
    Super.Tick(DT);
}

////////////////////////////////////////////////////////////////////////////////
//  PostRender
//
//  Draw the HUD
////////////////////////////////////////////////////////////////////////////////
simulated function PostRender(Canvas C)
{
    Super.PostRender(C);
}

////////////////////////////////////////////////////////////////////////////////
//  LocalizedMessage
////////////////////////////////////////////////////////////////////////////////
simulated function LocalizedMessage(
    class<LocalMessage> MessageClass,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject,
    optional String CriticalString )
{
	local int i;
    
	if ( MessageClass.Static.KillMessage() )
		return;

	if ( CriticalString == "" )
		CriticalString = MessageClass.Static.GetString(Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	MessageClass.Static.MangleString(CriticalString, RelatedPRI_1, RelatedPRI_2, OptionalObject);

	if ( MessageClass.Default.bIsUnique )
	{	// If unique, stomp any identical existing message
		for (i=0; i<QueueSize; i++)
		{
			if (MessageQueue[i].Message != None)
			{
				if (MessageQueue[i].Message == MessageClass)
				{
					MessageQueue[i].Message = MessageClass;
					MessageQueue[i].Switch = Switch;
					MessageQueue[i].RelatedPRI = RelatedPRI_1;
					MessageQueue[i].OptionalObject = OptionalObject;
					MessageQueue[i].LifeTime = MessageClass.Static.GetLifeTime(CriticalString);
					MessageQueue[i].EndOfLife = MessageQueue[i].LifeTime + Level.TimeSeconds;
					MessageQueue[i].StringMessage = CriticalString;
					MessageQueue[i].DrawColor = MessageClass.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);
					MessageQueue[i].XL = 0;
					return;
				}
			}
		}
	}
	for (i=0; i<QueueSize; i++)
	{
		if (MessageQueue[i].Message == None)
		{
			MessageQueue[i].Message = MessageClass;
			MessageQueue[i].Switch = Switch;
			MessageQueue[i].RelatedPRI = RelatedPRI_1;
			MessageQueue[i].OptionalObject = OptionalObject;
			MessageQueue[i].LifeTime = MessageClass.Static.GetLifeTime(CriticalString);
			MessageQueue[i].EndOfLife = MessageQueue[i].LifeTime + Level.TimeSeconds;
			MessageQueue[i].StringMessage = CriticalString;
			MessageQueue[i].DrawColor = MessageClass.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);
			MessageQueue[i].XL = 0;
			return;
		}
	}

	// No empty slots.  Force a message out.
	for (i=0; i<QueueSize-1; i++)
		CopyMessage(MessageQueue[i],MessageQueue[i+1]);

	MessageQueue[QueueSize-1].Message = MessageClass;
	MessageQueue[QueueSize-1].Switch = Switch;
	MessageQueue[QueueSize-1].RelatedPRI = RelatedPRI_1;
	MessageQueue[QueueSize-1].OptionalObject = OptionalObject;
	MessageQueue[QueueSize-1].LifeTime = MessageClass.Static.GetLifeTime(CriticalString);
	MessageQueue[QueueSize-1].EndOfLife = MessageQueue[QueueSize-1].LifeTime + Level.TimeSeconds;
	MessageQueue[QueueSize-1].StringMessage = CriticalString;
	MessageQueue[QueueSize-1].DrawColor = MessageClass.Static.GetColor(Switch, RelatedPRI_1, RelatedPRI_2);				
	MessageQueue[QueueSize-1].XL = 0;
}


////////////////////////////////////////////////////////////////////////////////
//  DetermineClass
////////////////////////////////////////////////////////////////////////////////
simulated function Class<LocalMessage> DetermineClass(name MsgType)
{
	local Class<LocalMessage> MessageClass;

	switch (MsgType)
	{
        case 'vmodGameAnnouncement':
            MessageClass=class'vmodLocalGameAnnouncement';
            break;
		case 'Subtitle':
			MessageClass=class'SubtitleMessage';
			break;
		case 'RedSubtitle':
			MessageClass=class'SubtitleRed';
			break;
		case 'Pickup':
			MessageClass=class'PickupMessage';
			break;
		case 'Say':
		case 'TeamSay':
			MessageClass=class'SayMessage';
			break;
		case 'NoRunePower':
			MessageClass=class'NoRunePowerMessage';
			break;
		case 'CriticalEvent':
		case 'DeathMessage':
		case 'Event':
		default:
			MessageClass=class'GenericMessage';
			break;
	}
	return MessageClass;
}