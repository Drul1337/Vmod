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
var float PosXKillsQueue;
var float PosYKillsQueue;

var Texture TextureMessageQueue;

struct vmodHUDLocalizedMessage_s
{
    var Class<LocalMessage>     MessageClass;
    var String                  MessageString;
    var String                  MessageStringAdditional;
	var PlayerReplicationInfo   PRI1;
    var PlayerReplicationInfo   PRI2;
    var float                   TimeStamp;
    var Color                   MessageColor;
};
var vmodHUDLocalizedMessage_s MessageGameNotification;
var vmodHUDLocalizedMessage_s MessageGameNotificationPersistent;

// Message queues
const MESSAGE_QUEUE_SIZE = 64;
struct MessageQueue_s
{
    var vmodHUDLocalizedMessage_s   Messages[64];
    var int                         Front;
};
var private MessageQueue_s MessageQueueGeneral;
var private MessageQueue_s MessageQueueKills;

// Message justification types
enum MessageJustificationType_e
{
    JUSTIFY_LEFT,
    JUSTIFY_RIGHT,
    JUSTIFY_CENTER
};

// Interpolation types
enum InterpolationType_e
{
    INTERP_LINEAR,
    INTERP_QUADRATIC
};

var float MessageLifeTime;
var float MessageQueueLifeTime;
var float MessageGlowRate;
var float MessageBackdropWidth;

////////////////////////////////////////////////////////////////////////////////
//  PostBeginPlay
////////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
    // Expire all queue messages
    MessageQueuePurgeAll(MessageQueueGeneral);
    MessageQueuePurgeAll(MessageQueueKills);
    Super.PostBeginPlay();
}

////////////////////////////////////////////////////////////////////////////////
//  MessageQueue
////////////////////////////////////////////////////////////////////////////////
simulated function MessageQueuePush(
    out MessageQueue_s Q,
    vmodHUDLocalizedMessage_s M)
{
    Q.Front = (Q.Front + 1) % MESSAGE_QUEUE_SIZE;
    Q.Messages[Q.Front] = M;
}

simulated function MessageQueuePurgeAll(out MessageQueue_s Q)
{
    local int i;
    for(i = 0; i < MESSAGE_QUEUE_SIZE; i++)
    {
        // TODO: Implement negative infinity?
        Q.Messages[i].TimeStamp = -9999.0;
    }
}

simulated function MessageQueueDraw(
    Canvas C,
    MessageQueue_s Q,
    float RelX, float RelY,
    int MaxMessages,
    optional float LifeTime,
    optional MessageJustificationType_e Justification,
    optional bool BackDrop,
    optional InterpolationType_e InterpType)
{
    local int i, j, k;
    
    // Handle optional LifeTime
    if(LifeTime == 0.0)
        LifeTime = MessageLifeTime;
    
    if(MaxMessages > MESSAGE_QUEUE_SIZE)
        MaxMessages = MESSAGE_QUEUE_SIZE;
    
    // Count how many messages will be rendered
    for(i = 0; i < MaxMessages; i++)
    {
        j = Q.Front - i;
        if(j < 0)
            j += MESSAGE_QUEUE_SIZE;
        if(MessageExpired(Q.Messages[j], LifeTime))
            break;
    }
    
    // Return if no messages
    if(i <= 0)
        return;
    
    // Set font
    if(MyFonts != None) C.Font = MyFonts.GetStaticBigFont();
	else                C.Font = C.BigFont;
    
    // Set canvas
    C.Style = ERenderStyle.STY_Translucent;
    //C.bCenter = false;
    
    // Render i messages from the queue
    for(j = 0; j < i; j++)
    {
        k = Q.Front - j;
        if(k < 0)
            k += MESSAGE_QUEUE_SIZE;
        
        DrawMessage(
            C, Q.Messages[k],
            (C.ClipX * RelX),
            (C.ClipY * RelY + ((i - j - 1) * 16)),
            LifeTime,
            Justification,
            Backdrop,
            InterpType);
    }
}

////////////////////////////////////////////////////////////////////////////////
//  DrawMessage
////////////////////////////////////////////////////////////////////////////////
function DrawMessage(
    Canvas C,
    vmodHUDLocalizedMessage_s M,
    float PosX, float PosY,
    optional float LifeTime,
    optional MessageJustificationType_e Justification,
    optional bool Backdrop,
    optional InterpolationType_e InterpType)
{
    local float t;
    
    t = GetMessageTimeStampInterpolation(
            M,
            LifeTime,
            InterpType);
    
    // Draw backdrop
    if(BackDrop)
    {
        C.SetPos(PosX, PosY);
        C.DrawColor = M.MessageColor * t * 0.1;
        
        C.DrawTile(
            TextureMessageQueue,
            C.ClipX * MessageBackdropWidth, 16,
            0, 0,
            TextureMessageQueue.USize,
            TextureMessageQueue.VSize);
    }
    
    // Adjust for justification
    switch(Justification)
    {
        case JUSTIFY_LEFT:
            C.SetPos(PosX, PosY);
            break;
        
        case JUSTIFY_RIGHT:
            C.SetPos(PosX, PosY);
            break;
        
        case JUSTIFY_CENTER:
            C.SetPos(PosX, PosY);
            break;
    }
    
    // Draw the message according to class
    switch(M.MessageClass)
    {
        case Class'RuneI.SayMessage':
            // Draw player's name
            C.DrawColor = M.MessageColor * t;
            C.DrawText(M.MessageStringAdditional);
            
            // Draw player's message
            PosX += 96;
            C.SetPos(PosX, PosY);
            C.DrawColor = WhiteColor * t;
            C.DrawText(M.MessageString);
            break;
        
        default:
            C.DrawColor = M.MessageColor * t;
            C.DrawText(M.MessageString);
            break;
    }
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
simulated function float GetMessageTimeStampInterpolation(
    vmodHUDLocalizedMessage_s M,
    optional float LifeTime,
    optional InterpolationType_e InterpType)
{
    local float t, b, c, d;
    
    if(LifeTime == 0.0)
        LifeTime = MessageLifeTime;
    
    t = Level.TimeSeconds - M.TimeStamp;
    b = 0.0;
    c = 1.0;
    d = LifeTime;
    
    if(t > d)
        return 0.0;
    
    switch(InterpType)
    {
        case INTERP_LINEAR:
            return 1.0 - (t / d);
        
        case INTERP_QUADRATIC:
            t = t / d;
            return 1.0 - (c * t * t + b);
    }
    
    return 1.0;
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
//  MessageExpired
////////////////////////////////////////////////////////////////////////////////
simulated function bool MessageExpired(
    vmodHUDLocalizedMessage_s M,
    optional float LifeTime)
{
    return Level.TimeSeconds >= (M.TimeStamp + LifeTime);
}

////////////////////////////////////////////////////////////////////////////////
//  DrawMessageGameNotifications
////////////////////////////////////////////////////////////////////////////////
simulated function DrawMessageGameNotifications(
    Canvas C,
    optional float LifeTime,
    optional InterpolationType_e InterpType)
{
    local float t;
    
    // Handle optional LifeTime
    if(LifeTime == 0.0)
        LifeTime = MessageLifeTime;
    
    // Draw primary game notification
    if(!MessageExpired(MessageGameNotification, LifeTime) &&
        MessageGameNotification.MessageString != "")
    {
        if(MyFonts != None)
            C.Font = MyFonts.GetStaticBigFont();
        else
            C.Font = C.BigFont;
        
        t = GetMessageTimeStampInterpolation(
                MessageGameNotification,
                MessageLifeTime,
                InterpType);
        
        C.Style = ERenderStyle.STY_Translucent;
        C.bCenter = true;
        C.SetPos(0, C.ClipY * 0.4);
        C.DrawColor = MessageGameNotification.MessageColor * t;
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
//  DrawMessages
////////////////////////////////////////////////////////////////////////////////
simulated function DrawMessages(canvas C)
{
    DrawMessageGameNotifications(C, MessageLifeTime, INTERP_QUADRATIC);
    
    // Draw the general message queue
    MessageQueueDraw(
        C, MessageQueueGeneral,
        PosXMessageQueue, PosYMessageQueue,
        16, MessageQueueLifeTime,
        JUSTIFY_LEFT,
        true,
        INTERP_QUADRATIC);
    
    // Draw the kill messages
    MessageQueueDraw(
        C, MessageQueueKills,
        PosXKillsQueue, PosYKillsQueue,
        16, MessageQueueLifeTime,
        JUSTIFY_RIGHT,
        false,
        INTERP_QUADRATIC);
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
//  MangleMessage
//
//  After a message has been received by LocalizedMessage, it is constructed
//  based on message defaults. Then it is passed through a mangler function
//  corresponding to its class for further modification.
////////////////////////////////////////////////////////////////////////////////
simulated function MangleMessagePreGame(out vmodHUDLocalizedMessage_s M)
{}

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
    
    // Construct new message
    Message.MessageClass            = MessageClass;
    Message.MessageString           = CriticalString;
    Message.MessageStringAdditional = "";
    Message.PRI1                    = RelatedPRI1;
    Message.PRI2                    = RelatedPRI2;
    Message.TimeStamp               = Level.TimeSeconds;
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
        
        MessageQueuePush(MessageQueueKills, Message);
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
        
        MessageQueuePush(MessageQueueGeneral, Message);
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
    PosXKillsQueue=0.995
    PosYKillsQueue=0.00125
    
    MessageQueueMaxMessages=8
    KilledQueueMaxMessages=8
    
    TextureMessageQueue=Texture'RuneI.sb_horizramp'
}