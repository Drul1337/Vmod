////////////////////////////////////////////////////////////////////////////////
// vmodHUD
////////////////////////////////////////////////////////////////////////////////
// class vmodHUD extends HUD;
class vmodHUD extends RuneHUD;

var color RedColor;
var color BlueColor;
var color GreenColor;
var color GoldColor;

var float PosXMessageQueue;
var float PosYMessageQueue;
var float PosXKilledQueue;
var float PosYKilledQueue;

var Texture TextureMessageQueue;

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

// General message queue
const MESSAGE_QUEUE_SIZE = 64;
var private vmodHUDLocalizedMessage_s MessageQueue[64];
var private int MessageQueueFront;
var int MessageQueueMaxMessages;

// Killed message queue
const KILLED_QUEUE_SIZE = 64;
var private vmodHUDLocalizedMessage_s KilledQueue[64];
var private int KilledQueueFront;
var int KilledQueueMaxMessages;

var float MessageLifeTime;
var float MessageQueueLifeTime;
var float MessageGlowRate;
var float MessageBackdropWidth;

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
    local int i, j, k;
    local float t;
    local float currx, curry;
    
    // Any messages in the queue?
    if(MessageQueue[MessageQueueFront].LifeEnd <= Level.TimeSeconds)
        return;
    
    // Set font
    if(MyFonts != None)
		C.Font = MyFonts.GetStaticBigFont();
	else
		C.Font = C.BigFont;
    
    // Set canvas
    C.Style = ERenderStyle.STY_Translucent;
    C.bCenter = false;
    
    // Count how many messages will be rendered
    for(i = 0; i < MessageQueueMaxMessages; i++)
    {
        j = MessageQueueFront - i;
        if(j < 0)
            j += MESSAGE_QUEUE_SIZE;
        if(MessageQueue[j].LifeEnd <= Level.TimeSeconds)
            break;
    }
    
    // Render i messages from the queue
    for(j = 0; j < i; j++)
    {
        k = MessageQueueFront - j;
        if(k < 0)
            k += MESSAGE_QUEUE_SIZE;
        
        t = GetMessageFadeInterpolation(MessageQueue[k]);
        
        // Draw backdrop
        currx = 0;
        curry = C.ClipY * PosYMessageQueue + ((i - j - 1) * 16);
        C.SetPos(currx, curry);
        C.DrawColor = MessageQueue[k].MessageColor * t * 0.1;
        
        C.DrawTile(
            TextureMessageQueue,
            C.ClipX * MessageBackdropWidth, 16,
            0, 0,
            TextureMessageQueue.USize,
            TextureMessageQueue.VSize);
        
        // Draw message
        currx = C.ClipX * PosXMessageQueue;
        curry = C.ClipY * PosYMessageQueue + ((i - j - 1) * 16);
        C.SetPos(currx, curry);
        C.DrawColor = WhiteColor * t;
        
        // Draw the message according to class
        switch(MessageQueue[k].MessageClass)
        {
            case Class'RuneI.SayMessage':
                // Draw player's name
                C.DrawColor = MessageQueue[k].MessageColor * t;
                C.DrawText(MessageQueue[k].MessageStringAdditional);
                
                // Draw player's message
                currx += 96;
                C.SetPos(currx, curry);
                C.DrawColor = WhiteColor * t;
                C.DrawText(MessageQueue[k].MessageString);
                break;
            
            default:
                C.DrawColor = MessageQueue[k].MessageColor * t;
                C.DrawText(MessageQueue[k].MessageString, false);
                break;
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
//  DrawKilledQueue
////////////////////////////////////////////////////////////////////////////////
simulated function DrawKilledQueue(Canvas C)
{
    local int i, j, k;
    local float t;
    local float currx, curry;
    
    // Any messages in the queue?
    if(KilledQueue[KilledQueueFront].LifeEnd <= Level.TimeSeconds)
        return;
    
    // Set font
    if(MyFonts != None)
		C.Font = MyFonts.GetStaticBigFont();
	else
		C.Font = C.BigFont;
    
    // Set canvas
    C.Style = ERenderStyle.STY_Translucent;
    C.bCenter = false;
    
    // Count how many messages will be rendered
    for(i = 0; i < KilledQueueMaxMessages; i++)
    {
        j = KilledQueueFront - i;
        if(j < 0)
            j += KILLED_QUEUE_SIZE;
        if(KilledQueue[j].LifeEnd <= Level.TimeSeconds)
            break;
    }
    
    // Render i messages from the queue
    for(j = 0; j < i; j++)
    {
        k = KilledQueueFront - j;
        if(k < 0)
            k += KILLED_QUEUE_SIZE;
        
        t = GetMessageFadeInterpolation(KilledQueue[k]);
        
        // Draw message
        currx = C.ClipX * PosXKilledQueue;
        curry = C.ClipY * PosYKilledQueue + ((i - j - 1) * 16);
        C.DrawColor = RedColor * t;
        
        // Draw the message according to class
        switch(KilledQueue[k].MessageClass)
        {
            default:
                C.DrawTextRightJustify(KilledQueue[k].MessageString, currx, curry);
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
    DrawKilledQueue(C);
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
//  KilledPushMessage
//
//  Push a kill message onto the killed queue.
////////////////////////////////////////////////////////////////////////////////
simulated function KilledPushMessage(vmodHUDLocalizedMessage_s M)
{
    KilledQueueFront = (KilledQueueFront + 1) % KILLED_QUEUE_SIZE;
    KilledQueue[KilledQueueFront] = M;
    KilledQueue[KilledQueueFront].LifeStart = Level.TimeSeconds;
    KilledQueue[KilledQueueFront].LifeEnd =
        KilledQueue[KilledQueueFront].LifeStart + MessageQueueLifeTime;
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

simulated function MangleMessagePlayerKilled(out vmodHUDLocalizedMessage_s M)
{}

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
    
    // TODO: These return cases may be causing beeps without messages
    //if(MessageClass == None)    return;
    
    // Construct new message
    Message.MessageClass            = MessageClass;
    Message.MessageString           = CriticalString;
    Message.MessageStringAdditional = "";
    Message.PRI1                    = RelatedPRI1;
    Message.PRI2                    = RelatedPRI2;
    Message.LifeStart               = Level.TimeSeconds;
    Message.LifeEnd                 = Message.LifeStart + MessageLifeTime;
    Message.MessageColor            = WhiteColor;
    
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
    // Player killed messages
    else if(ClassIsChildOf(MessageClass, Class'Vmod.vmodLocalMessagePlayerKilled'))
    {
        switch(MessageClass)
        {
            case Class'Vmod.vmodLocalMessagePlayerKilled':
                MangleMessagePlayerKilled(Message);
                break;
        }
        
        // TODO: Implement a new queue for killed messages and push this there instead
        KilledPushMessage(Message);
    }
    // Handle all other messages
    else
    {
        Message.MessageColor.R = 100;
        Message.MessageColor.G = 255;
        Message.MessageColor.B = 100;
        
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
        
        // Player killed messages
        case 'PlayerKilled':    return Class'Vmod.vmodLocalMessagePlayerKilled';
        
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
    RedColor=(R=255,G=60,B=60)
    BlueColor=(R=60,G=60,B=255)
    GreenColor=(R=60,G=255,B=60)
    GoldColor=(R=255,G=255,B=60)
    MessageLifeTime=2.0
    MessageGlowRate=0.5
    MessageQueueLifeTime=8.0
    MessageBackdropWidth=0.2
    MessageQueueFront=0
    KilledQueueFront=0
    
    PosXMessageQueue=0.005
    PosYMessageQueue=0.00125
    PosXKilledQueue=0.995
    PosYKilledQueue=0.00125
    
    MessageQueueMaxMessages=8
    KilledQueueMaxMessages=8
    
    TextureMessageQueue=Texture'RuneI.sb_horizramp'
}