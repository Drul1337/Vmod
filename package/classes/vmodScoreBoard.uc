////////////////////////////////////////////////////////////////////////////////
// vmodScoreBoard
////////////////////////////////////////////////////////////////////////////////
class vmodScoreBoard extends ScoreBoard;

var Class<vmodStaticUtilities>      UtilitiesClass;
var Class<vmodStaticColorsTeams>    ColorsTeamsClass;
var Class<vmodStaticFonts>          FontsClass;

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
var String TextPing;

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

var float RelYScoreBoard;
var float RelWScoreBoard;

var float TextYPadding;

var String TextHeaderMessages[4];
var Texture TextureHBorder;

enum TableJustify_e
{
    JUSTIFY_MIN,    // X: Left      Y: Top
    JUSTIFY_MAX,    // X: Right     Y: Bottom
    JUSTIFY_CENTER  // X: Center    Y: Center
};


var int TableRows;
var int TableCols;
const TABLE_WIDTH = 0.8;
const TABLE_HEIGHT = 0.8;


////////////////////////////////////////////////////////////////////////////////
//  DrawCellString
//
//  TODO: Implement a table struct so that there can be several different
//  tables at once.
//
//  TODO: Clip all drawing to the cell span
//
//  TODO: Implement the ability to display scrolling text in a span of cells.
////////////////////////////////////////////////////////////////////////////////
function DrawCellString(
    Canvas                      C,
    int                         Row,        // Upper-left starting row
    int                         Col,        // Upper-left starting col
    int                         RowSpan,    // Number of merged rows down
    int                         ColSpan,    // Number of merged cols right
    String                      S,
    optional TableJustify_e     JustifyX,
    optional TableJustify_e     JustifyY)
{
    local float CellW, CellH;
    local float SpanW, SpanH;
    local float PosX, PosY;
    local float StrW, StrH;
    
    // Invalid without a string
    if(S == "")
        return;
    
    // Adjust out of bounds indices
    if(Row < 0)                     Row = 0;
    if(Row >= TableRows)            Row = TableRows - 1;
    if(Col < 0)                     Col = 0;
    if(Col >= TableCols)            Col = TableCols - 1;
    
    // Adjust out of bounds spans
    if(Row + RowSpan > TableRows)   RowSpan = TableRows - Row;
    if(Col + ColSpan > TableCols)   ColSpan = TableCols - Col;

    // Determine cell dimensions
    CellW = C.ClipX * TABLE_WIDTH / float(TableCols);
    CellH = C.ClipY * TABLE_HEIGHT / float(TableRows);
    
    // Determine span dimensions
    SpanW = CellW * float(ColSpan);
    SpanH = CellH * float(RowSpan);
    
    // Determine upper-left position
    PosX = (C.ClipX * (1.0 - TABLE_WIDTH)  / 2.0) + (CellW * float(Col));
    PosY = (C.ClipY * (1.0 - TABLE_HEIGHT) / 2.0) + (CellH * float(Row));
    
    // Adjust according to justification
    C.StrLen(S, StrW, StrH);
    switch(JustifyX)
    {
        case JUSTIFY_MAX:
            PosX = PosX + SpanW - StrW;
            break;
        
        case JUSTIFY_CENTER:
            PosX = PosX + (SpanW / 2.0) - (StrW / 2.0);
            break;
            
        case JUSTIFY_MIN:
        default:
            break;
    }
    
    switch(JustifyY)
    {
        case JUSTIFY_MAX:
            PosY = PosY + SpanH - StrH;
            break;
            
        case JUSTIFY_CENTER:
            PosY = PosY + (SpanH / 2.0) - (StrH / 2.0);
            break;
        
        case JUSTIFY_MIN:
        default:
            break;
    }
    
    C.SetPos(PosX, PosY);
    C.DrawColor = ColorsTeamsClass.Static.ColorWhite();
    C.DrawText(S);
}



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
    // Draw server name
    DrawCellString(
        C,
        0, 0,
        1, TableCols,
        PlayerPawn(Owner).GameReplicationInfo.ServerName,
        JUSTIFY_CENTER,
        JUSTIFY_CENTER);
    
    // Draw a helpful little messages
    DrawCellString(
        C,
        1, 0,
        1, TableCols,
        "Smash your keyboard to join the game",
        JUSTIFY_CENTER,
        JUSTIFY_CENTER);
    
    //local int i, j;
    //local String s;
    //for(i = 0; i < TableRows; i++)
    //    for(j = i; j < TableCols; j = j + 2)
    //    {
    //        s = "" $ (i * TableCols + j);
    //        DrawCellString(
    //            C, i, j, 1, 2, s, JUSTIFY_CENTER, JUSTIFY_MAX);
    //    }
    //DrawCellString(
    //    C,
    //    5, 5,
    //    1, 1,
    //    "ThisIsMyTestString");
    
    //function DrawCellString(
    //Canvas  C,
    //int     Row,        // The upper-left starting row / col
    //int     Col,
    //int     RowSpan,    // The number of "merged" cells for this draw
    //int     ColSpan,
    //String  S)
    
    //var float RelYScoreBoard;
    //var float RelWScoreBoard;
    //Canvas.StrLen("R ", XL, YL);
    //C.DrawRect(Meter.TexBackDrop, Width, Height);
    
    //local String HeaderString;
    //local float StrW, StrH;
    //local float CurX, CurY;
    //local int i;
    //
    //C.Style = ERenderStyle.STY_Translucent;
    //
    //// Header top banner
    //HeaderString = PlayerPawn(Owner).GameReplicationInfo.ServerName;
    //C.StrLen(HeaderString, StrW, StrH);
    //CurX = C.ClipX * ((1.0 - RelWScoreBoard) / 2.0);
    //CurY = C.ClipY * RelYScoreBoard + StrH + (TextYPadding * 2.0);
    //C.SetPos(CurX, CurY);
    //C.DrawColor = ColorsTeamsClass.Static.ColorWhite() * 0.25;
    //C.DrawRect(TextureHBorder, C.ClipX * RelWScoreBoard, StrH);
    //
    //// Server name
    //CurX = (C.ClipX * 0.5) - (StrW / 2.0);
    //CurY = C.ClipY * RelYScoreBoard + StrH;
    //C.SetPos(CurX, CurY);
    //C.DrawColor = ColorsTeamsClass.Static.ColorWhite();
    //C.DrawText(HeaderString);
    //
    //// Draw the server messages
    //for(i = 0; i < 4; i++)
    //{
    //    CurY += StrH + TextYPadding;
    //    C.StrLen(TextHeaderMessages[i], StrW, StrH);
    //    CurX = (C.ClipX * 0.5) - (StrW / 2.0);
    //    C.SetPos(CurX, CurY);
    //    C.DrawColor = ColorsTeamsClass.Static.ColorGreen();
    //    C.DrawText(TextHeaderMessages[i]);
    //}
    
    //local float Width, TempWidth;
    //local Color GreenColor;
    //local Color WhiteColor;
    //
    //GreenColor.G = 255;
    //GreenColor.R = 60;
    //GreenColor.B = 60;
    //GreenColor = GreenColor * t;
    //
    //WhiteColor.G = 255;
    //WhiteColor.R = 255;
    //WhiteColor.B = 255;
    //WhiteColor = WhiteColor * t;
    //
    //C.bCenter = false;
    //
    //// Left side
    //C.DrawColor = GreenColor;
    //
    //// Level
    //C.SetPos(C.ClipX * 0.1, C.ClipY * 0.1);
    //C.DrawText(TextLevel);
    //
    //// Author
    //C.SetPos(C.ClipX * 0.1, C.ClipY * 0.1 + 16);
    //C.DrawText(TextAuthor);
    //
    //// Ideal player load
    //C.SetPos(C.ClipX * 0.1, C.ClipY * 0.1 + 32);
    //C.DrawText(TextIdealLoad);
    //
    //// Values
    //C.DrawColor = WhiteColor;
    //
    //// Level value
    //C.SetPos(C.ClipX * 0.1 + 512, C.ClipY * 0.1);
    //C.DrawTextRightJustify(Level.Title, C.Curx, C.CurY);
    //
    //// Author value
    //C.SetPos(C.ClipX * 0.1 + 512, C.ClipY * 0.1 + 16);
    //C.DrawTextRightJustify(Level.Author, C.Curx, C.CurY);
    //
    //// Ideal player load value
    //C.SetPos(C.ClipX * 0.1 + 512, C.ClipY * 0.1 + 32);
    //C.DrawTextRightJustify(Level.IdealPlayerCount, C.Curx, C.CurY);
    //
    //// Right Side
    //C.DrawColor = GreenColor;
    //
    //// Server
    //C.SetPos(C.ClipX * 0.9 - 512, C.ClipY * 0.1);
    //C.DrawText(TextServer);
    //
    //// Game type
    //C.SetPos(C.ClipX * 0.9 - 512, C.ClipY * 0.1 + 32);
    //C.DrawText(TextGameType);
    //
    //// Values
    //C.DrawColor = WhiteColor;
    //
    //// Server value
    //C.SetPos(C.ClipX * 0.9, C.ClipY * 0.1);
    //C.DrawTextRightJustify(
    //    PlayerPawn(Owner).GameReplicationInfo.ServerName, C.CurX, C.CurY);
    //    
    //// Game type value
    //C.SetPos(C.ClipX * 0.9, C.ClipY * 0.1 + 32);
    //C.DrawTextRightJustify(
    //    PlayerPawn(Owner).GameReplicationInfo.GameName, C.CurX, C.CurY);
}

////////////////////////////////////////////////////////////////////////////////
//  DrawPlayerScores
////////////////////////////////////////////////////////////////////////////////
function DrawPlayerScores(Canvas C, float t, SortType_e SortType)
{
    local PlayerReplicationInfo PRI;
    local int i;
    
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
    
    // Draw players
    if(PRIPlayerCount > 0)
    {
        // Sort players array
        SortPRIByScore(0, PRIPlayerCount);
        
        // Players heading
        DrawCellString(
            C,
            3, 0,
            1, 3,
            "Players",
            JUSTIFY_CENTER,
            JUSTIFY_CENTER);
        
        // Draw each player's name
        for(i = 0; i < PRIPlayerCount; i++)
        {
            DrawCellString(
                C,
                4 + i, 0,
                1, 3,
                PRIOrdered[i].PlayerName,
                JUSTIFY_MIN,
                JUSTIFY_CENTER);
        }
        
        // Score heading
        DrawCellString(
            C,
            3, 4,
            1, 2,
            "Score",
            JUSTIFY_CENTER,
            JUSTIFY_CENTER);
        
        // Draw each player's score
        for(i = 0; i < PRIPlayerCount; i++)
        {
            DrawCellString(
                C,
                4 + i, 4,
                1, 2,
                "" $ int(PRIOrdered[i].Score),
                JUSTIFY_MIN,
                JUSTIFY_CENTER);
        }
        
        // Deaths heading
        DrawCellString(
            C,
            3, 6,
            1, 2,
            "Deaths",
            JUSTIFY_CENTER,
            JUSTIFY_CENTER);
        
        // Draw each player's deaths
        for(i = 0; i < PRIPlayerCount; i++)
        {
            DrawCellString(
                C,
                4 + i, 6,
                1, 2,
                "" $ int(PRIOrdered[i].Deaths),
                JUSTIFY_MIN,
                JUSTIFY_CENTER);
        }
    }
    
    
    //local PlayerReplicationInfo PRI;
    //local int i;
    //local Color GoldColor;
    //local Color WhiteColor;
    //
    //GoldColor.G = 255;
    //GoldColor.R = 255;
    //GoldColor.B = 60;
    //GoldColor = GoldColor * t;
    //
    //WhiteColor.G = 255;
    //WhiteColor.R = 255;
    //WhiteColor.B = 255;
    //WhiteColor = WhiteColor * t;
    //
    //PRIPlayerCount = 0;
    //PRISpectatorCount = 0;
    //
    //// Populate player array
    //for(i = 0; i < MAX_PRI; i++)
    //{
    //    PRI = PlayerPawn(Owner).GameReplicationInfo.PRIArray[i];
    //    if(PRI == None)
    //        break;
    //    
    //    if(PRI.bIsSpectator)
    //    {
    //        // Place spectators at the back of the array
    //        PRIOrdered[(MAX_PRI - 1) - PRISpectatorCount] = PRI;
    //        PRISpectatorCount++;
    //    }
    //    else
    //    {
    //        // Place players at the front of the array
    //        PRIOrdered[PRIPlayerCount] = PRI;
    //        PRIPlayerCount++;
    //    }
    //}
    //
    //// TODO: Peform sorting here
    //
    //// Players heading
    //C.DrawColor = GoldColor;
    //C.SetPos(C.ClipX * 0.1, C.ClipY * 0.225);
    //C.DrawText(TextPlayers);
    //
    //// Score heading
    //C.SetPos(C.ClipX * 0.3, C.ClipY * 0.225);
    //C.DrawText(TextScore);
    //
    //// Deaths heading
    //C.SetPos(C.ClipX * 0.35, C.ClipY * 0.225);
    //C.DrawText(TextDeaths);
    //
    //// Ping heading
    //C.SetPos(C.ClipX * 0.6, C.ClipY * 0.225);
    //C.DrawText(TextPing);
    //
    //// Draw the players
    //if(PRIPlayerCount > 0)
    //{
    //    C.Style = ERenderStyle.STY_Translucent;
    //    for(i = 0; i < PRIPlayerCount; i++)
    //    {
    //        // Name
    //        C.DrawColor = WhiteColor * 0.05;
    //        C.SetPos(C.ClipX * 0.1, (C.ClipY * 0.25) + (i * 16) + 2);
    //        C.DrawTile(
    //            TextureBackdrop,
    //            C.ClipX * 0.8, 12,
    //            0, 0,
    //            TextureBackdrop.USize,
    //            TextureBackdrop.VSize);
    //        C.DrawColor = WhiteColor;
    //        C.SetPos(C.ClipX * 0.1, (C.ClipY * 0.25) + (i * 16) + 4);
    //        C.DrawText(PRIOrdered[i].PlayerName);
    //        
    //        // Score
    //        C.SetPos(C.ClipX * 0.3, (C.ClipY * 0.25) + (i * 16) + 4);
    //        C.DrawText(int(PRIOrdered[i].Score));
    //        
    //        // Deaths
    //        C.SetPos(C.ClipX * 0.35, (C.ClipY * 0.25) + (i * 16) + 4);
    //        C.DrawText(int(PRIOrdered[i].Deaths));
    //        
    //        // Ping
    //        C.SetPos(C.ClipX * 0.6, (C.ClipY * 0.25) + (i * 16) + 4);
    //        C.DrawText(PRIOrdered[i].Ping);
    //    }
    //}
    //
    //// Draw the spectators heading
    //if(PRISpectatorCount > 0)
    //{
    //    C.DrawColor = GoldColor;
    //    C.SetPos(C.ClipX * 0.1, C.ClipY * 0.475);
    //    C.DrawText(TextSpectators);
    //    
    //    // Draw the spectators
    //    C.DrawColor = WhiteColor;
    //    for(i = 0; i < PRISpectatorCount; i++)
    //    {
    //        C.SetPos(C.ClipX * 0.1, (C.ClipY) * 0.5 + (i * 16));
    //        C.DrawText(PRIOrdered[MAX_PRI - 1 - i].PlayerName);
    //    }
    //}
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
    TextPing="Ping"
    TextHeaderMessages(0)="Test \n line 1"
    TextHeaderMessages(1)="dAssdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasd"
    TextHeaderMessages(2)="hehehehe"
    TextHeaderMessages(3)="test line 3 fsdjsdfijgso"
    
    TextureBackdrop=Texture'RuneI.sb_horizramp'
    
    FadeTime=0.25
    UtilitiesClass=Class'Vmod.vmodStaticUtilities'
    ColorsTeamsClass=Class'Vmod.vmodStaticColorsTeams'
    FontsClass=Class'Vmod.vmodStaticFonts'
    
    RelYScoreBoard=0.1
    RelWScoreBoard=0.6
    TextYPadding=2.0
    TextureHBorder=Texture'RuneI.sb_horizramp'
    
    TableRows=16
    TableCols=16
}