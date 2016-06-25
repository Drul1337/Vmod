////////////////////////////////////////////////////////////////////////////////
// vmodHUD
////////////////////////////////////////////////////////////////////////////////
// class vmodHUD extends HUD;
class vmodHUD extends RuneHUD;

var color RedColor;
var color BlueColor;
var color GreenColor;
var color GoldColor;

struct vmodHUDLocalizedMessage_s
{
    var Class<LocalMessage>     MessageClass;
    var String                  MessageString;
    var String                  MessageStringAdditional;
	var PlayerReplicationInfo   PRI1;
    var PlayerReplicationInfo   PRI2;
    var float                   LifeStart;
    var float                   LifeEnd;
    var Color                   MessageColor;
};

var vmodHUDLocalizedMessage_s MessageGameNotification;
var vmodHUDLocalizedMessage_s MessageGameNotificationPersistent;

const MESSAGE_QUEUE_SIZE = 64;
var vmodHUDLocalizedMessage_s MessageQueue[64];
var private int MessageQueueFront;

var float MessageLifeTime;
var float MessageQueueLifeTime;
var float MessageGlowRate;

////////////////////////////////////////////////////////////////////////////////
//  Tick
////////////////////////////////////////////////////////////////////////////////
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
    
    DrawRemainingTime(C, 0, 0);
}

////////////////////////////////////////////////////////////////////////////////
//  Interpolation functions
////////////////////////////////////////////////////////////////////////////////
simulated function float GetMessageFadeInterpolation(vmodHUDLocalizedMessage_s M)
{
    local float t, b, c, d;
    
    // Quadratic tween
    t = Level.TimeSeconds - M.LifeStart;
    b = 0.0;
    c = 1.0;
    d = M.LifeEnd - M.LifeStart;
    
    t = t / d;
    return 1.0 - (c * t * t + b);
}

simulated function float GetMessageGlowInterpolation()
{
    local float t;
    
    // Sin wave glow
    t = 2.0 * Pi * Level.TimeSeconds * MessageGlowRate;
    t = Sin(t);
    
    return t * 0.4 + (1.0 - 0.4);
}

////////////////////////////////////////////////////////////////////////////////
//  DrawMessageGameNotifications
////////////////////////////////////////////////////////////////////////////////
simulated function DrawMessageGameNotifications(Canvas C)
{
    local float T;
    
    // Draw primary game notification
    if( MessageGameNotification.LifeEnd > Level.TimeSeconds &&
        MessageGameNotification.MessageString != "")
    {
        if(MyFonts != None)
            C.Font = MyFonts.GetStaticBigFont();
        else
            C.Font = C.BigFont;
        
        T = GetMessageFadeInterpolation(MessageGameNotification);
        
        C.Style = ERenderStyle.STY_Translucent;
        C.bCenter = true;
        C.SetPos(0, C.ClipY * 0.4);
        C.DrawColor = MessageGameNotification.MessageColor * T;
        C.DrawText(MessageGameNotification.MessageString, false);
    }
    
    // Draw persistent game notification
    if(MessageGameNotificationPersistent.MessageString != "")
    {
        if(MyFonts != None)
            C.Font = MyFonts.GetStaticBigFont();
        else
            C.Font = C.BigFont;
        
        T = GetMessageGlowInterpolation();
        
        C.Style = ERenderStyle.STY_Translucent;
        C.bCenter = true;
        C.SetPos(0, C.ClipY * 0.9);
        C.DrawColor = MessageGameNotificationPersistent.MessageColor * T;
        C.DrawText(MessageGameNotificationPersistent.MessageString, false);
    }
}

////////////////////////////////////////////////////////////////////////////////
//  DrawMessageQueue
////////////////////////////////////////////////////////////////////////////////
simulated function DrawMessageQueue(Canvas C)
{
    local float lenX, lenY;
    local int i, j;
    local float T;
    local int MessageCount;
    
    if(MessageQueue[MessageQueueFront].LifeEnd <= Level.TimeSeconds)
        return;
    
    // Set font
    if(MyFonts != None)
		C.Font = MyFonts.GetStaticBigFont();
	else
		C.Font = C.BigFont;
    
    C.Style = ERenderStyle.STY_Translucent;
    C.bCenter = false;
    
    // TODO: Clean this up
    // Determine how many messages will be drawn
    MessageCount = 0;
    while(MessageCount < 12)
    {
        i = (MessageQueueFront - MessageCount);
        if(i < 0)
            i += MESSAGE_QUEUE_SIZE;
        if(Level.TimeSeconds >= MessageQueue[i].LifeEnd)
            break;
        MessageCount++;
    }
    
    for(i = 0; i < MessageCount; i++)
    {
        j = MessageQueueFront - i;
        if(j < 0)
            j += MESSAGE_QUEUE_SIZE;
        
        T = GetMessageFadeInterpolation(MessageQueue[j]);
        //C.DrawColor = WhiteColor * T;
        
        //C.SetPos(C.ClipX * 0.075, C.ClipY * 0.985 - 32 - (i * 16));
        //C.SetPos(C.ClipX * 0.01, C.ClipY * 0.01 + ((MessageCount - i) * 16));
        
        switch(MessageQueue[j].MessageClass)
        {
            case Class'RuneI.SayMessage':
                if(MessageQueue[j].PRI1 != None)
                {
                    // Player Name
                    //C.SetPos(C.ClipX * 0.075, C.ClipY * 0.985 - 32 - (i * 16));
                    C.DrawColor = MessageQueue[j].MessageColor * T;
                    C.SetPos(C.ClipX * 0.01, C.ClipY * 0.01 + ((MessageCount - i) * 16));
                    C.DrawText(MessageQueue[j].MessageStringAdditional);
                    
                    // Player Message
                    //C.SetPos(C.ClipX * 0.075 + 128, C.ClipY * 0.985 - 32 - (i * 16));
                    C.DrawColor = WhiteColor * T;
                    C.SetPos(C.ClipX * 0.01 + 128, C.ClipY * 0.01 + ((MessageCount - i) * 16));
                    C.DrawText(MessageQueue[j].MessageString, false);
                }
                else
                {
                    C.DrawText(MessageQueue[j].MessageString, false);
                }
                break;
                
            default:
                C.DrawText(MessageQueue[j].MessageString, false);
                break;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
//  DrawMessages
////////////////////////////////////////////////////////////////////////////////
simulated function DrawMessages(canvas C)
{
    DrawMessageGameNotifications(C);
    DrawMessageQueue(C);
}

////////////////////////////////////////////////////////////////////////////////
//  DrawRemainingTime
////////////////////////////////////////////////////////////////////////////////
simulated function DrawRemainingTime(canvas Canvas, int x, int y)
{
	local int timeleft;
	local int Hours, Minutes, Seconds;

	if (PlayerPawn(Owner)==None || PlayerPawn(Owner).GameReplicationInfo==None)
		return;

	timeleft = vmodGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo).GameTimer;
    
    if(timeleft <= 0)
        return;
    
    Canvas.bCenter = true;
    
	Hours   = timeleft / 3600;
	Minutes = timeleft / 60;
	Seconds = timeleft % 60;
	//FONT ALTER
	//Canvas.Font = Canvas.LargeFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticLargeFont();
	else
		Canvas.Font = Canvas.LargeFont;

	Canvas.SetPos(x, y);
	if (timeleft <= 30)
		Canvas.SetColor(255,0,0);
	Canvas.DrawText(TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);
	Canvas.SetColor(255,255,255);
    
    Canvas.bCenter = false;
}

////////////////////////////////////////////////////////////////////////////////
//  DrawFragCount
////////////////////////////////////////////////////////////////////////////////
simulated function DrawFragCount(canvas Canvas, int x, int y)
{
    // Do nothing for now
    return;
}

////////////////////////////////////////////////////////////////////////////////
//  QueuePushMessage
//
//  Push a message onto the general message queue.
////////////////////////////////////////////////////////////////////////////////
simulated function QueuePushMessage(vmodHUDLocalizedMessage_s M)
{
    MessageQueueFront = (MessageQueueFront + 1) % MESSAGE_QUEUE_SIZE;
    MessageQueue[MessageQueueFront] = M;
    MessageQueue[MessageQueueFront].LifeStart = Level.TimeSeconds;
    MessageQueue[MessageQueueFront].LifeEnd =
        MessageQueue[MessageQueueFront].LifeStart + MessageQueueLifeTime;
}

////////////////////////////////////////////////////////////////////////////////
//  MangleMessage
//
//  After a message has been received by LocalizedMessage, it is constructed
//  based on message defaults. Then it is passed through a mangler function
//  corresponding to its class for further modification.
////////////////////////////////////////////////////////////////////////////////
simulated function MangleMessagePreGame(out vmodHUDLocalizedMessage_s M)
{
    M.MessageColor.G = 0;
}

simulated function MangleMessageStartingGame(out vmodHUDLocalizedMessage_s M)
{}

simulated function MangleMessageLiveGame(out vmodHUDLocalizedMessage_s M)
{}

simulated function MangleMessagePostGame(out vmodHUDLocalizedMessage_s M)
{}

simulated function MangleMessagePreRound(out vmodHUDLocalizedMessage_s M)
{}

simulated function MangleMessageStartingRound(out vmodHUDLocalizedMessage_s M)
{}

simulated function MangleMessagePostRound(out vmodHUDLocalizedMessage_s M)
{}

simulated function MangleMessageGameNotification(out vmodHUDLocalizedMessage_s M)
{}

simulated function MangleMessagePlayerReady(out vmodHUDLocalizedMessage_s M)
{}

simulated function MangleMessageSay(out vmodHUDLocalizedMessage_s M)
{
    // TODO: Clean up
    M.MessageStringAdditional = M.PRI1.PlayerName;
    switch(M.PRI1.Team)
    {
        case 0: M.MessageColor = RedColor; return;
        case 1: M.MessageColor = BlueColor; return;
        case 2: M.MessageColor = GreenColor; return;
        case 3: M.MessageColor = GoldColor; return;
    }
    M.MessageColor = WhiteColor;
}

simulated function MangleMessageGameNotificationPersistent(out vmodHUDLocalizedMessage_s M)
{
    M.MessageColor.R = 0;
    M.MessageColor.G = 255;
    M.MessageColor.B = 255;
}

////////////////////////////////////////////////////////////////////////////////
//  LocalizedMessage
//
//  HUD received a localized message.
////////////////////////////////////////////////////////////////////////////////
simulated function LocalizedMessage(
    class<LocalMessage>             MessageClass,
    optional int                    Switch,
    optional PlayerReplicationInfo  RelatedPRI1,
    optional PlayerReplicationInfo  RelatedPRI2,
    optional Object                 OptionalObject,
    optional String                 CriticalString)
{
    local vmodHUDLocalizedMessage_s Message;
    
    if(MessageClass == None)    return;
    if(CriticalString == "")    return;
    
    // Construct new message
    Message.MessageClass    = MessageClass;
    Message.MessageString   = CriticalString;
    Message.PRI1            = RelatedPRI1;
    Message.PRI2            = RelatedPRI2;
    Message.LifeStart       = Level.TimeSeconds;
    Message.LifeEnd         = Message.LifeStart + MessageLifeTime;
    Message.MessageColor    = WhiteColor;
    
    // Handle GameNotification messages
    if(ClassIsChildOf(MessageClass, Class'Vmod.vmodLocalMessageGameNotification'))
    {
        switch(MessageClass)
        {
            case Class'Vmod.vmodLocalMessagePreGame':
                MangleMessagePreGame(Message);
                break;
            case Class'Vmod.vmodLocalMessageStartingGame':
                MangleMessageStartingGame(Message);
                break;
            case Class'Vmod.vmodLocalMessageLiveGame':
                MangleMessageLiveGame(Message);
                break;
            case Class'Vmod.vmodLocalMessagePostGame':
                MangleMessagePostGame(Message);
                break;
            case Class'Vmod.vmodLocalMessagePreRound':
                MangleMessagePreRound(Message);
                break;
            case Class'Vmod.vmodLocalMessageStartingRound':
                MangleMessageStartingRound(Message);
                break;
            case Class'Vmod.vmodLocalMessagePostRound':
                MangleMessagePostRound(Message);
                break;
            case Class'Vmod.vmodLocalMessageGameNotification':
                MangleMessageGameNotification(Message);
                break;
            case Class'Vmod.vmodLocalMessagePlayerReady':
                MangleMessagePlayerReady(Message);
                break;
            case Class'Vmod.vmodLocalMessageGameNotificationPersistent':
                MangleMessageGameNotificationPersistent(Message);
                MessageGameNotificationPersistent = Message;
                return;
        }
        
        MessageGameNotification = Message;
        return;
    }
    // Handle all other messages
    else
    {
        switch(MessageClass)
        {
            case Class'RuneI.SayMessage':
                MangleMessageSay(Message);
                break;
        }
        
        QueuePushMessage(Message);
    }
}


////////////////////////////////////////////////////////////////////////////////
//  DetermineClass
////////////////////////////////////////////////////////////////////////////////
simulated function Class<LocalMessage> DetermineClass(name MsgType)
{
	local Class<LocalMessage> MessageClass;
    
    switch(MsgType)
    {
        // Messages from vmodGameInfo
        case 'PreGame':         return Class'Vmod.vmodLocalMessagePreGame';
        case 'StartingGame':    return Class'Vmod.vmodLocalMessageStartingGame';
        case 'LiveGame':        return Class'Vmod.vmodLocalMessageLiveGame';
        case 'PostGame':        return Class'Vmod.vmodLocalMessagePostGame';
        case 'PlayerReady':     return Class'Vmod.vmodLocalMessagePlayerReady';
        
        // Messages from vmodGameInfoRoundBased
        case 'PreRound':        return Class'Vmod.vmodLocalMessagePreRound';
        case 'StartingRound':   return Class'Vmod.vmodLocalMessageStartingRound';
        case 'PostRound':       return Class'Vmod.vmodLocalMessagePostRound';
        
        // Other messages
        case 'Subtitle':        return Class'SubtitleMessage';
        case 'RedSubtitle':     return Class'SubtitleRed';
        case 'Pickup':          return Class'PickupMessage';
        case 'Say':             return Class'SayMessage';
        case 'TeamSay':         return Class'SayMessage';
        case 'NoRunePower':     return Class'NoRunePowerMessage';
        
        // Defaults
        case 'CriticalEvent':
        case 'DeathMessage':
        case 'Event':
        default:                return Class'GenericMessage';
    }
    
    return MessageClass;
}

defaultproperties
{
    WhiteColor=(R=255,G=255,b=255)
    RedColor=(R=255,G=0,B=0)
    BlueColor=(R=0,G=0,B=255)
    GreenColor=(R=0,G=255,B=0)
    GoldColor=(R=255,G=255,B=0)
    MessageLifeTime=2.0
    MessageGlowRate=0.5
    MessageQueueLifeTime=8.0
    MessageQueueFront=0
}