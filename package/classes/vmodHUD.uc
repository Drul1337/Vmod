////////////////////////////////////////////////////////////////////////////////
// vmodHUD
////////////////////////////////////////////////////////////////////////////////
class vmodHUD extends HUD;

#EXEC TEXTURE IMPORT NAME=crosshair FILE=..\Vmod\Textures\crosshair.bmp

////////////////////////////////////////////////////////////////////////////////
//  Global classes
// TODO: Implement interpolation in utilities class
var Class<vmodStaticUtilities>      UtilitiesClass;
var Class<vmodStaticColorsTeams>    ColorsTeamsClass;
var Class<vmodStaticLocalMessages>  LocalMessagesClass;
var Class<vmodStaticFonts>          FontsClass;

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
var float PosXMessageQueue;
var float PosYMessageQueue;

var private MessageQueue_s MessageQueueKills;
var float PosXKillsQueue;
var float PosYKillsQueue;

var Texture TextureMessageQueue;

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

struct HudMeter_s
{
    var Texture TexCapLow;      // Low cap texture
    var Texture TexCapHigh;     // High cap texture
    var Texture TexBackDrop;    // BackDrop texture
    var Texture TexFill;        // Meter fill texture
    var float P0;               // Interp value 0
    var float P1;               // Interp value 1
    var float TimeStamp;        // Last update timestamp
};
var HudMeter_s MeterHealth;
var HudMeter_s MeterShield;
var HudMeter_s MeterStrength;

////////////////////////////////////////////////////////////////////////////////
//  Overrides

// Prevents small messages from being drawn
simulated function bool DisplayMessages(Canvas C) { return true; }

////////////////////////////////////////////////////////////////////////////////
//  Tick
////////////////////////////////////////////////////////////////////////////////
simulated event Tick(float DT)
{
    Super.Tick(DT);
}

////////////////////////////////////////////////////////////////////////////////
//  PostBeginPlay
//
//  Purge all message queues here so that at the start of game play the messages
//  are not incorrectly offset.
////////////////////////////////////////////////////////////////////////////////
event PostBeginPlay()
{
    // Spawn scoreboard
    if(PlayerPawn(Owner).ScoringType != None)
        PlayerPawn(Owner).Scoring = Spawn(PlayerPawn(Owner).ScoringType, Owner);
    
    MessageQueuePurgeAll(MessageQueueGeneral);
    MessageQueuePurgeAll(MessageQueueKills);
    Super.PostBeginPlay();
}

////////////////////////////////////////////////////////////////////////////////
simulated function DrawMeter(
    Canvas C,
    HudMeter_s Meter,
    float PosX,
    float PosY)
{
    local float t;
    local float Width, Height;
    
    // Draw backdrop
    Width   = Meter.TexBackDrop.USize;
    Height  = Meter.TexBackDrop.VSize;
    
    // TODO: This is a temp just for playtesting
    Height = Height * 10;
    
    C.DrawColor = ColorsTeamsClass.Static.ColorWhite();
    C.Style     = ERenderStyle.STY_Normal;
    C.SetPos(PosX, PosY - Height);
    C.DrawRect(Meter.TexBackDrop, Width, Height);
    
    // Get tweened value
    t = UtilitiesClass.Static.InterpQuadratic(
        Level.TimeSeconds - Meter.TimeStamp,    // Current time
        Meter.P0,                               // Starting value
        Meter.P1,                               // Ending value
        0.25);                                  // Interp duration
    
    t = t / vmodRunePlayer(Owner).GetHealthMax();
    if(t < 0.0) t = 0.0;
    if(t > 1.0) t = 1.0;
    
    // Draw fill
    Width   = Meter.TexFill.USize;
    Height  = Meter.TexFill.VSize * t;
    
    // TODO: This is a temp just for playtesting
    Height = Height * 10;
    
    C.DrawColor = ColorsTeamsClass.Static.ColorWhite();
    C.Style     = ERenderStyle.STY_Normal;
    C.SetPos(PosX, PosY - Height);
    C.DrawRect(Meter.TexFill, Width, Height);
}

simulated function UpdateMeterHealth()
{
    local float UpdatedHealth;
    
    UpdatedHealth = vmodRunePlayer(Owner).GetHealth();
    if(MeterHealth.P1 == UpdatedHealth)
        return;
    MeterHealth.P0 = MeterHealth.P1;
    MeterHealth.P1 = UpdatedHealth;
    MeterHealth.TimeStamp = Level.TimeSeconds;
}

simulated function UpdateMeterStrength()
{
    local float UpdatedStrength;
    
    UpdatedStrength = vmodRunePlayer(Owner).GetStrength();
    if(MeterStrength.P1 == UpdatedStrength)
        return;
    MeterStrength.P0 = MeterStrength.P1;
    MeterStrength.P1 = UpdatedStrength;
    MeterStrength.TimeStamp = Level.TimeSeconds;
}

////////////////////////////////////////////////////////////////////////////////
//  PostRender
//
//  Draw the HUD
////////////////////////////////////////////////////////////////////////////////
simulated function PostRender(Canvas C)
{
    DrawMessages(C);
    
    // Things to draw only if the player is currently active in game
    if(vmodRunePlayer(Owner).CheckIsGameActive())
    {
        // Health
        UpdateMeterHealth();
        DrawMeter(C, MeterHealth, C.ClipX * 0.01, C.ClipY * 0.99);
        
        // Shield
        MeterShield.P0 = 0.0;
        DrawMeter(C, MeterShield, C.ClipX * 0.99, C.ClipY * 0.99);
        
        // Strength
        UpdateMeterStrength();
        DrawMeter(C, MeterStrength, C.ClipX * 0.99 - 64, C.ClipY * 0.99);
		
		//// Crosshair
		//C.SetPos(C.SizeX/2, C.SizeY/2);
		//C.DrawColor.A = 128;
		//C.DrawRect(Texture'vmod.crosshair', 32, 32);
    }
    
    // Draw the scoreboard
    if(vmodRunePlayer(Owner).CheckIsShowingScores())
    {
        DrawScoreBoard(C);
    }
    else
    {
        // TODO: This is a hacky way to do fading
        vmodScoreBoard(vmodRunePlayer(Owner).Scoring).UpdateTimeStamp(Level.TimeSeconds);
    }
    
    /*
    ////////////////////////////////////////////////////////////////////////////
    local PlayerPawn thePlayer;
	local Texture Tex;
	local float XSize, YSize;

	thePlayer = PlayerPawn(Owner);
	if (thePlayer == None || thePlayer.RendMap == 0)
		return;

	if (HudMode==0)
	{	// Hud is off
		DrawMessages(C);
		DrawRuneMessages(C);

		// Draw Progress Bar
		C.SetColor(255,255,255);
		if ( thePlayer.ProgressTimeOut > Level.TimeSeconds )
			DisplayProgressMessage(C);
		C.SetColor(255,255,255);

		// Reset the translucency of the HUD back to normal
		C.Style = ERenderStyle.STY_Normal;		
		C.DrawColor.R = 255;
		C.DrawColor.G = 255;
		C.DrawColor.B = 255;
		return;
	}

	DefaultCanvas(C);
	bResChanged = (C.ClipX != OldClipX);
	OldClipX = C.ClipX;

	// Set the relative HUD scale to 640x480
	HudScale = C.ClipX / 640;

	if (!Owner.IsA('Spectator'))
	{
		bHealth = true;

		if(thePlayer.bBloodLust)
			bBloodLust = true;
		else
			bBloodLust = false;

		if(thePlayer.Weapon != None || thePlayer.RunePower > 0)
			bPower = true;

		bBloodLust = true;
		if(thePlayer.Shield != None)
			bShield = true;
		else
			bShield = false;


		if(thePlayer.Region.Zone.bWaterZone)
			bAir = true;
		else
			bAir = false;

		// Draw Health/Shield/Strength Bars
		SetHudFade(C, FadeHealth);
		DrawHealth(C, 4 * HudScale, C.ClipY - 4 * HudScale);

		if(FadeBloodlust > 0)
		{
			SetHudFade(C, FadeBloodlust);
			DrawStrength(C, C.ClipX * 0.5, C.ClipY - 4 * HudScale);
		}
		if(FadePower > 0)	
		{
			SetHudFade(C, FadePower);
			DrawPower(C, C.ClipX - 36 * HudScale, C.ClipY - 4 * HudScale);
		}
		if(FadeShield > 0)
		{
			SetHudFade(C, FadeShield);
			DrawShield(C, C.ClipX - 60 * HudScale, C.ClipY - 4 * HudScale);
		}
		if(FadeAir > 0 && Level.Netmode==NM_Standalone)
		{
			SetHudFade(C, FadeAir);
			DrawAir(C, 40 * HudScale, C.ClipY - 4 * HudScale);
		}
	}

	DrawMessages(C);

	// Reset the translucency of the HUD back to normal
	C.Style = ERenderStyle.STY_Normal;		
	C.DrawColor.R = 255;
	C.DrawColor.G = 255;
	C.DrawColor.B = 255;

	// Draw scoreboard (if active)
    HandleScoreBoard(C);

	DrawNetPlug(C);

	// Draw Remaining Time
	if ( bTimeDown || (thePlayer.GameReplicationInfo != None && thePlayer.GameReplicationInfo.RemainingTime > 0) )
	{
		bTimeDown = true;
		DrawRemainingTime(C, 0, 0);
	}

	if (!Owner.IsA('Spectator'))
	{
		// Draw Frag count
		if ( (Level.Game == None) || Level.Game.bDeathMatch ) 
		{
			DrawFragCount(C, C.ClipX, 0);
		}
	}

	if ( HUDMutator != None )
		HUDMutator.PostRender(C);

	// Draw Menu (if active)
	if ( thePlayer.bShowMenu )
	{
		DisplayMenu(C);
		return;
	}

	if ( Level.NetMode != NM_StandAlone)
		DrawTypingPlayers(C);

	// Draw Progress Bar
	C.SetColor(255,255,255);
	if ( thePlayer.ProgressTimeOut > Level.TimeSeconds )
		DisplayProgressMessage(C);
	C.SetColor(255,255,255);
    ////////////////////////////////////////////////////////////////////////////
    
    DrawRemainingTime(C, 0, 0);
    */
}

////////////////////////////////////////////////////////////////////////////////
//  MessageQueue Implementation
////////////////////////////////////////////////////////////////////////////////
simulated function DrawScoreBoard(Canvas C)
{
    if(vmodRunePlayer(Owner).Scoring == None)
        return;
    
    vmodRunePlayer(Owner).Scoring.ShowScores(C);
}


////////////////////////////////////////////////////////////////////////////////
//  MessageQueue Implementation
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
    Canvas C, MessageQueue_s Q,
    float RelX, float RelY,
    int MessageCount,
    optional float LifeTime,
    optional MessageJustificationType_e Justification,
    optional bool BackDrop,
    optional InterpolationType_e InterpType)
{
    // TODO: Could implement message fade-in and smooth tweening up
    // and down when messages disappear
    
    local int i, j, k;
    local float t;
    
    // Handle optional LifeTime
    if(LifeTime == 0.0)
        LifeTime = MessageLifeTime;
    
    // Constrain message count to queue size
    if(MessageCount > MESSAGE_QUEUE_SIZE)
        MessageCount = MESSAGE_QUEUE_SIZE;
    
    // Count how many messages will be rendered
    for(i = 0; i < MessageCount; i++)
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
    
    // Render i messages from the queue
    for(j = 0; j < i; j++)
    {
        k = Q.Front - j;
        if(k < 0)
            k += MESSAGE_QUEUE_SIZE;
        
        // Y interpolating
        // TODO: Implement this as a constant
        t = Level.TimeSeconds - Q.Messages[k].TimeStamp;
        if(t <= LifeTime * 0.004)
            t = t / (LifeTime * 0.004);
        else
            t = 1.0;
        
        // TODO: Just using 16 for height at the moment, need to get the
        // actual value
        DrawMessage(
            C, Q.Messages[k],
            (C.ClipX * RelX),
            (C.ClipY * RelY + (((i - j - 2) * 16) + (t * 16))), // TODO: Y tween
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
    local float w, h;
    local float t;
    
    if(MessageExpired(M, LifeTime))
        return;
    
    t = GetMessageTimeStampInterpolation(
            M,
            LifeTime,
            InterpType);
    
    // Set canvas
    C.Style = ERenderStyle.STY_Translucent;
    
    ////if(MyFonts != None) C.Font = MyFonts.GetStaticBigFont();
    ////else                C.Font = C.BigFont;
    //C.Font = FontsClass.Static.GetBigFont();
    C.Font = C.BigFont;
    
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
            C.StrLen(M.MessageString, w, h);
            C.SetPos((PosX - w), PosY);
            break;
        
        case JUSTIFY_CENTER:
            C.StrLen(M.MessageString, w, h);
            C.SetPos((PosX - (w >> 1)), PosY);
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
            C.DrawColor = ColorsTeamsClass.Static.ColorWhite() * t;
            C.DrawText(M.MessageString);
            break;
        
        default:
            C.DrawColor = M.MessageColor * t;
            C.DrawText(M.MessageString);
            break;
    }
}

////////////////////////////////////////////////////////////////////////////////
//  Interpolation functions
////////////////////////////////////////////////////////////////////////////////
simulated function float GetMessageTimeStampInterpolation(
    vmodHUDLocalizedMessage_s M,
    optional float LifeTime,
    optional InterpolationType_e InterpType)
{
    local float t, b, e, d;
    
    if(LifeTime == 0.0)
        LifeTime = MessageLifeTime;
    
    t = Level.TimeSeconds - M.TimeStamp;    // Current time
    b = 1.0;                                // Starting value
    e = 0.0;                                // Ending value
    d = LifeTime;                           // Duration
    
    switch(InterpType)
    {
        case INTERP_LINEAR:
            return UtilitiesClass.Static.InterpLinear(t, b, e, d);
        
        case INTERP_QUADRATIC:
            return UtilitiesClass.Static.InterpQuadratic(t, b, e, d);
            
        default:
            return 1.0;
    }
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
//  DrawMessages
////////////////////////////////////////////////////////////////////////////////
simulated function DrawMessages(canvas C)
{
    // Draw the game notification message
    // TODO: Need to draw the persistent message as well
    DrawMessage(
        C, MessageGameNotification,
        C.ClipX * 0.5, C.ClipY * 0.4,
        MessageLifeTime,
        JUSTIFY_CENTER,
        false,
        INTERP_QUADRATIC);
    
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
    //local int timeleft;
    //local int Hours, Minutes, Seconds;
    //
    //if (PlayerPawn(Owner)==None || PlayerPawn(Owner).GameReplicationInfo==None)
    //    return;
    //
    //timeleft = vmodGameReplicationInfo(PlayerPawn(Owner).GameReplicationInfo).GameTimer;
    //
    //if(timeleft <= 0)
    //    return;
    //
    //Canvas.bCenter = true;
    //
    //Hours   = timeleft / 3600;
    //Minutes = timeleft / 60;
    //Seconds = timeleft % 60;
    ////FONT ALTER
    ////Canvas.Font = Canvas.LargeFont;
    //if(MyFonts != None)
    //    Canvas.Font = MyFonts.GetStaticLargeFont();
    //else
    //    Canvas.Font = Canvas.LargeFont;
    //
    //Canvas.SetPos(x, y);
    //if (timeleft <= 30)
    //    Canvas.SetColor(255,0,0);
    //Canvas.DrawText(TwoDigitString(Minutes)$":"$TwoDigitString(Seconds), true);
    //Canvas.SetColor(255,255,255);
    //
    //Canvas.bCenter = false;
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
    M.MessageStringAdditional = M.PRI1.PlayerName;
    ColorsTeamsClass.Static.GetTeamColor(
        M.PRI1.Team,
        M.MessageColor.R,
        M.MessageColor.G,
        M.MessageColor.B);
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
    // TODO: Find a way to get the classes from static messages class instead
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
                
            case Class'RuneI.PickupMessage':
                Message.MessageString = MessageClass.Static.GetString(
                    Switch,
                    RelatedPRI1,
                    RelatedPRI2,
                    OptionalObject);
                break;
        }
        
        MessageQueuePush(MessageQueueGeneral, Message);
    }
}


////////////////////////////////////////////////////////////////////////////////
//  DetermineClass
////////////////////////////////////////////////////////////////////////////////
simulated function Class<LocalMessage> DetermineClass(Name MsgType)
{
    return LocalMessagesClass.Static.GetMessageTypeClass(MsgType);
}


////////////////////////////////////////////////////////////////////////////////
defaultproperties
{
    MessageLifeTime=2.0
    MessageGlowRate=0.5
    MessageQueueLifeTime=8.0
    MessageBackdropWidth=0.2
    
    PosXMessageQueue=0.005
    PosYMessageQueue=0.00125
    PosXKillsQueue=0.995
    PosYKillsQueue=0.00125
    
    TextureMessageQueue=Texture'RuneI.sb_horizramp'
    UtilitiesClass=Class'Vmod.vmodStaticUtilities'
    ColorsTeamsClass=Class'Vmod.vmodStaticColorsTeams'
    LocalMessagesClass=Class'Vmod.vmodStaticLocalMessages'
    FontsClass=Class'Vmod.vmodStaticFonts'
    MeterHealth=(P0=0.0,P1=0.0,TexBackDrop=Texture'HealthEmpty',TexFill=Texture'HealthFull')
    MeterShield=(P0=0.0,P1=0.0,TexBackDrop=Texture'HealthEmpty',TexFill=Texture'HealthFull')
    MeterStrength=(P0=0.0,P1=0.0,TexBackDrop=Texture'HealthEmpty',TexFill=Texture'HealthFull')
}