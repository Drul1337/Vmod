////////////////////////////////////////////////////////////////////////////////
// vmodScoreBoard
////////////////////////////////////////////////////////////////////////////////
class vmodScoreBoard extends ScoreBoard;

var Class<vmodStaticColorsTeams> ColorsTeamsClass;

var String TextLevel;
var String TextAuthor;
var String TextIdealLoad;
var String TextServer;
var String TextIP;
var String TextGameType;
var String TextPlayers;
var String TextSpectators;
var String TextScore;
var String TextDeaths;

var Texture TextureBackdrop;

enum SortType_e
{
    SORT_ALPHABETICAL,
    SORT_SCORE
};

const MAX_PRI = 128;
var PlayerReplicationInfo PRIOrdered[128];
var int PRIPlayerCount;
var int PRISpectatorCount;

var float TimeStamp;
var float FadeTime;

////////////////////////////////////////////////////////////////////////////////
//  Sorting Functions
//
//  TODO: See if there's a way to use delegates for sorting conditions.
//  Implement something faster than selection sort.
////////////////////////////////////////////////////////////////////////////////
function SortPRIByTeam(int Start, int Count)
{
    local int Smallest;
    local int i, j;
    local PlayerReplicationInfo PRITemp;
    
    for(i = Start; i < Count - 1; i++)
    {
        Smallest = i;
        for(j = i + 1; j < Count; j++)
        {
            if(PRIOrdered[j].Team < PRIOrdered[Smallest].Team)
                Smallest = j;
        }
        PRITemp = PRIOrdered[i];
        PRIOrdered[i] = PRIOrdered[Smallest];
        PRIOrdered[Smallest] = PRITemp;
    }
}

function SortPRIByScore(int Start, int Count)
{
    local int Smallest;
    local int i, j;
    local PlayerReplicationInfo PRITemp;
    
    for(i = Start; i < Count - 1; i++)
    {
        Smallest = i;
        for(j = i + 1; j < Count; j++)
        {
            if(PRIOrdered[j].Score > PRIOrdered[Smallest].Score)
                Smallest = j;
        }
        PRITemp = PRIOrdered[i];
        PRIOrdered[i] = PRIOrdered[Smallest];
        PRIOrdered[Smallest] = PRITemp;
    }
}







function UpdateTimeStamp(float t)
{
    TimeStamp = t;
}

////////////////////////////////////////////////////////////////////////////////
//  ShowScore
////////////////////////////////////////////////////////////////////////////////
function ShowScores(Canvas C)
{
    local float t; // Interp value
    
    if(Level.TimeSeconds < TimeStamp + FadeTime)
        t = (Level.TimeSeconds - TimeStamp) / (FadeTime);
    else
        t = 1.0;
    
    // TODO: This is called from vmodHUD.
    // To implement fading, going to need to have HUD pass a timestamp in
	C.Font = RegFont;
    DrawHeader(C, t);
    DrawPlayerScores(C, t, SORT_SCORE);
}

////////////////////////////////////////////////////////////////////////////////
//  DrawHeader
////////////////////////////////////////////////////////////////////////////////
function DrawHeader(Canvas C, float t)
{
    local float Width, TempWidth;
    local Color GreenColor;
    local Color WhiteColor;
    
    GreenColor.G = 255;
    GreenColor.R = 60;
    GreenColor.B = 60;
    GreenColor = GreenColor * t;
    
    WhiteColor.G = 255;
    WhiteColor.R = 255;
    WhiteColor.B = 255;
    WhiteColor = WhiteColor * t;
    
    C.bCenter = false;
    
    // Left side
    C.DrawColor = GreenColor;
    
    // Level
    C.SetPos(C.ClipX * 0.1, C.ClipY * 0.1);
    C.DrawText(TextLevel);
    
    // Author
    C.SetPos(C.ClipX * 0.1, C.ClipY * 0.1 + 16);
    C.DrawText(TextAuthor);
    
    // Ideal player load
    C.SetPos(C.ClipX * 0.1, C.ClipY * 0.1 + 32);
    C.DrawText(TextIdealLoad);
    
    // Values
    C.DrawColor = WhiteColor;
    
    // Level value
    C.SetPos(C.ClipX * 0.1 + 512, C.ClipY * 0.1);
    C.DrawTextRightJustify(Level.Title, C.Curx, C.CurY);
    
    // Author value
    C.SetPos(C.ClipX * 0.1 + 512, C.ClipY * 0.1 + 16);
    C.DrawTextRightJustify(Level.Author, C.Curx, C.CurY);
    
    // Ideal player load value
    C.SetPos(C.ClipX * 0.1 + 512, C.ClipY * 0.1 + 32);
    C.DrawTextRightJustify(Level.IdealPlayerCount, C.Curx, C.CurY);
    
    // Right Side
    C.DrawColor = GreenColor;
    
    // Server
    C.SetPos(C.ClipX * 0.9 - 512, C.ClipY * 0.1);
    C.DrawText(TextServer);
    
    // Game type
    C.SetPos(C.ClipX * 0.9 - 512, C.ClipY * 0.1 + 32);
    C.DrawText(TextGameType);
    
    // Values
    C.DrawColor = WhiteColor;
    
    // Server value
    C.SetPos(C.ClipX * 0.9, C.ClipY * 0.1);
    C.DrawTextRightJustify(
        PlayerPawn(Owner).GameReplicationInfo.ServerName, C.CurX, C.CurY);
        
    // Game type value
    C.SetPos(C.ClipX * 0.9, C.ClipY * 0.1 + 32);
    C.DrawTextRightJustify(
        PlayerPawn(Owner).GameReplicationInfo.GameName, C.CurX, C.CurY);
}

////////////////////////////////////////////////////////////////////////////////
//  DrawPlayerScores
////////////////////////////////////////////////////////////////////////////////
function DrawPlayerScores(Canvas C, float t, SortType_e SortType)
{
    local PlayerReplicationInfo PRI;
    local int i;
    local Color GoldColor;
    local Color WhiteColor;
    
    GoldColor.G = 255;
    GoldColor.R = 255;
    GoldColor.B = 60;
    GoldColor = GoldColor * t;
    
    WhiteColor.G = 255;
    WhiteColor.R = 255;
    WhiteColor.B = 255;
    WhiteColor = WhiteColor * t;
    
    PRIPlayerCount = 0;
    PRISpectatorCount = 0;
    
    // Populate player array
    for(i = 0; i < MAX_PRI; i++)
    {
        PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
        if(PRI == None)
            break;
        
        if(PRI.bIsSpectator)
        {
            // Place spectators at the back of the array
            PRIOrdered[(MAX_PRI - 1) - PRISpectatorCount] = PRI;
            PRISpectatorCount++;
        }
        else
        {
            // Place players at the front of the array
            PRIOrdered[PRIPlayerCount] = PRI;
            PRIPlayerCount++;
        }
    }
    
    // TODO: Peform sorting here
    
    // Players heading
    C.DrawColor = GoldColor;
    C.SetPos(C.ClipX * 0.1, C.ClipY * 0.225);
    C.DrawText(TextPlayers);
    
    // Score heading
    C.SetPos(C.ClipX * 0.3, C.ClipY * 0.225);
    C.DrawText(TextScore);
    
    // Deaths heading
    C.SetPos(C.ClipX * 0.35, C.ClipY * 0.225);
    C.DrawText(TextDeaths);
    
    // Draw the players
    if(PRIPlayerCount > 0)
    {
        C.Style = ERenderStyle.STY_Translucent;
        for(i = 0; i < PRIPlayerCount; i++)
        {
            // Name
            C.DrawColor = WhiteColor * 0.05;
            C.SetPos(C.ClipX * 0.1, (C.ClipY * 0.25) + (i * 16) + 2);
            C.DrawTile(
                TextureBackdrop,
                C.ClipX * 0.8, 12,
                0, 0,
                TextureBackdrop.USize,
                TextureBackdrop.VSize);
            C.DrawColor = WhiteColor;
            C.SetPos(C.ClipX * 0.1, (C.ClipY * 0.25) + (i * 16) + 4);
            C.DrawText(PRIOrdered[i].PlayerName);
            
            // Score
            C.SetPos(C.ClipX * 0.3, (C.ClipY * 0.25) + (i * 16) + 4);
            C.DrawText(int(PRIOrdered[i].Score));
            
            // Deaths
            C.SetPos(C.ClipX * 0.35, (C.ClipY * 0.25) + (i * 16) + 4);
            C.DrawText(int(PRIOrdered[i].Deaths));
        }
    }
    
    // Draw the spectators heading
    if(PRISpectatorCount > 0)
    {
        C.DrawColor = GoldColor;
        C.SetPos(C.ClipX * 0.1, C.ClipY * 0.475);
        C.DrawText(TextSpectators);
        
        // Draw the spectators
        C.DrawColor = WhiteColor;
        for(i = 0; i < PRISpectatorCount; i++)
        {
            C.SetPos(C.ClipX * 0.1, (C.ClipY) * 0.5 + (i * 16));
            C.DrawText(PRIOrdered[MAX_PRI - 1 - i].PlayerName);
        }
    }
}

/*
function DrawPlayerInfo( canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset)
{
	local bool bLocalPlayer;
	local PlayerPawn PlayerOwner;
	local float XL,YL;
	local int AwardPos;

	PlayerOwner = PlayerPawn(Owner);
    
	bLocalPlayer = (PRI.PlayerName == PlayerOwner.PlayerReplicationInfo.PlayerName);
	//FONT ALTER
	//	Canvas.Font = RegFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;

	// Draw Ready
	//if (PRI.bReadyToPlay)
    //if(vmodPlayerReplicationInfo(PRI).bReadyToGoLive)
	//{
	//	Canvas.StrLen("R ", XL, YL);
	//	Canvas.SetPos(Canvas.ClipX*0.1-XL, YOffset);
	//	Canvas.DrawText(ReadyText, false);
	//}

	if (bLocalPlayer)
		Canvas.DrawColor = VioletColor;
	else
		Canvas.DrawColor = WhiteColor;

	// Draw Name
	//if (PRI.bAdmin)	//FONT ALTER
	//{
	//	//Canvas.Font = Font'SmallFont';
	//	if(MyFonts != None)
	//		Canvas.Font = MyFonts.GetStaticSmallFont();
	//	else
	//		Canvas.Font = Font'SmallFont';
	//}
	//else
	//{	//FONT ALTER
		//Canvas.Font = RegFont;
		if(MyFonts != None)
			Canvas.Font = MyFonts.GetStaticMedFont();
		else
			Canvas.Font = RegFont;
	//}

	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);
	Canvas.DrawText(PRI.PlayerName, false);
		//FONT ALTER
	//Canvas.Font = RegFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;
    
    // Draw ready
    if(vmodPlayerReplicationInfo(PRI).bReadyToPlay)
    {
        Canvas.SetPos(Canvas.ClipX*0.2, YOffset);
        Canvas.DrawColor = GreenColor;
        Canvas.DrawText("ready", false);
    }
    
    // Draw admin
    if(vmodPlayerReplicationInfo(PRI).bAdmin)
    {
        Canvas.SetPos(Canvas.ClipX*0.3, YOffset);
        Canvas.DrawColor = RedColor;
        Canvas.DrawText("admin", false);
    }
    
    // Draw team number
    Canvas.SetPos(Canvas.ClipX*0.4, YOffset);
    Canvas.DrawColor = RedColor;
    Canvas.DrawText(PRI.Team, false);
    Canvas.DrawColor = WhiteColor;
    
	// Draw Score
	Canvas.SetPos(Canvas.ClipX*0.5, YOffset);
	Canvas.DrawText(int(PRI.Score), false);

	// Draw Deaths
	Canvas.SetPos(Canvas.ClipX*0.6, YOffset);
	Canvas.DrawText(int(PRI.Deaths), false);

	if (Canvas.ClipX > 512 && Level.Netmode != NM_Standalone)
	{
		// Draw Ping
		Canvas.SetPos(Canvas.ClipX*0.7, YOffset);
		Canvas.DrawText(PRI.Ping, false);

		// Packetloss
			//FONT ALTER
		//Canvas.Font = RegFont;
		if(MyFonts != None)
			Canvas.Font = MyFonts.GetStaticMedFont();
		else
			Canvas.Font = RegFont;

		Canvas.DrawColor = WhiteColor;
	}

	// Draw Awards
	AwardPos = Canvas.ClipX*0.8;
	Canvas.DrawColor = WhiteColor;
		//FONT ALTER
	//Canvas.Font = Font'SmallFont';
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticSmallFont();
	else
		Canvas.Font = Font'SmallFont';

	Canvas.StrLen("00", XL, YL);
	if (PRI.bFirstBlood)
	{	// First blood
		Canvas.SetPos(AwardPos-YL+XL*0.25, YOffset-YL*0.5);
		Canvas.DrawTile(FirstBloodIcon, YL*2, YL*2, 0, 0, FirstBloodIcon.USize, FirstBloodIcon.VSize);
		AwardPos += XL*2;
	}
	if (PRI.MaxSpree > 2)
	{	// Killing sprees
		Canvas.SetPos(AwardPos-YL+XL*0.25, YOffset-YL*0.5);
		Canvas.DrawTile(SpreeIcon, YL*2, YL*2, 0, 0, SpreeIcon.USize, SpreeIcon.VSize);
		Canvas.SetPos(AwardPos, YOffset);
		Canvas.DrawColor = CyanColor;
		Canvas.DrawText(PRI.MaxSpree, false);
		Canvas.DrawColor = WhiteColor;
		AwardPos += XL*2;
	}
	if (PRI.HeadKills > 0)
	{	// Head kills
		Canvas.SetPos(AwardPos-YL+XL*0.25, YOffset-YL*0.5);
		Canvas.DrawTile(HeadIcon, YL*2, YL*2, 0, 0, HeadIcon.USize, HeadIcon.VSize);
		Canvas.SetPos(AwardPos, YOffset);
		Canvas.DrawColor = CyanColor;
		Canvas.DrawText(PRI.HeadKills, false);
		Canvas.DrawColor = WhiteColor;
		AwardPos += XL*2;
	}
		//FONT ALTER
	//Canvas.Font = RegFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;
}
*/

defaultproperties
{
    RegFont=Font'Engine.MedFont'
    
    TextLevel="Level"
    TextAuthor="Author"
    TextIdealLoad="Ideal Player Load"
    TextServer="Server"
    TextIP="IP"
    TextGameType="Game Type"
    TextPlayers="Players"
    TextSpectators="Spectators"
    TextScore="Score"
    TextDeaths="Deaths"
    
    TextureBackdrop=Texture'RuneI.sb_horizramp'
    
    FadeTime=0.25
    ColorsTeamsClass=Class'Vmod.vmodStaticColorsTeams'
}