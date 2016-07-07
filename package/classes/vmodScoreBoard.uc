////////////////////////////////////////////////////////////////////////////////
// vmodScoreBoard
////////////////////////////////////////////////////////////////////////////////
class vmodScoreBoard extends ScoreBoard;

var Class<vmodStaticUtilities>      UtilitiesClass;
var Class<vmodStaticColorsTeams>    ColorsTeamsClass;
var Class<vmodStaticFonts>          FontsClass;
var Class<vmodStaticLocalText>      TextClass;

var Texture TextureBackdrop;

enum SortType_e
{
    SORT_ALPHABETICAL,
    SORT_SCORE
};

var float TimeStamp;
var float FadeTime;

var float RelYScoreBoard;
var float RelWScoreBoard;

var float TextYPadding;

var String TextHeaderMessages[4];
var Texture TextureHBorder;

// Test vars
var float ScrollingInterp0;

var int TableRows;
var int TableCols;
const TABLE_WIDTH = 0.8;
const TABLE_HEIGHT = 0.8;







// Used for holding and sorting player replication info
const MAX_PRI = 128;
var PlayerReplicationInfo PRIOrdered[128];
var int PRIPlayerCount;     // Players are placed at the front of the array
var int PRISpectatorCount;  // Spectators are placed at the back of the array

////////////////////////////////////////////////////////////////////////////////
//  Table structs
struct Table_s
{
    var int Rows;   // Row x Col resolution
    var int Cols;
    var float W;    // Relative dimensions
    var float H;
    var float X;    // Relative position
    var float Y;
};

enum Justification_e
{
    JUSTIFY_MIN,    // X: Left      Y: Top
    JUSTIFY_MAX,    // X: Right     Y: Bottom
    JUSTIFY_CENTER  // X: Center    Y: Center
};

struct TableCell_s
{
    var int             Row;
    var int             Col;
    var int             RowSpan;
    var int             ColSpan;
    var Texture         Tex;
    var Color           TexColor;
    var String          Str;
    var Color           StrColor;
    var Justification_e JustifyX;
    var Justification_e JustifyY;
};

var Table_s         TableHeader;
var TableCell_s     TableCellServerName;

////////////////////////////////////////////////////////////////////////////////
//  Table implementation
function TableSetResolution(
    out Table_s     T,
    int             Rows, 
    int             Cols)
{
    T.Rows = Rows;
    T.Cols = Cols;
}

function TableSetDimensions(
    out Table_s     T,
    float           W,
    float           H)
{
    if(W < 0.0) W = 0.0;
    if(W > 1.0) W = 1.0;
    if(H < 0.0) H = 0.0;
    if(H > 1.0) H = 1.0;
    T.W = W;
    T.H = H;
}

function TableSetPosition(
    out Table_s     T,
    float           X,
    float           Y)
{
    if(X < 0.0) X = 0.0;
    if(X > 1.0) X = 1.0;
    if(Y < 0.0) Y = 0.0;
    if(Y > 1.0) Y = 1.0;
    T.X = X;
    T.Y = Y;
}

function TableGetCellInfo(
    Canvas              C,
    out Table_s         T,
    out TableCell_s     TC,
    out float           CellX,
    out float           CellY,
    out float           CellW,
    out float           CellH)
{
    local int DRow, DCol;
    local int DRowSpan, DColSpan;
    
    // Get table index
    DRow = TC.Row;
    DCol = TC.Col;
    if(DRow < 0)         DRow = 0;
    if(DRow >= T.Rows)   DRow = T.Rows - 1;
    if(DCol < 0)         DCol = 0;
    if(DCol >= T.Cols)   DCol = T.Cols - 1;
    
    // Get row and col span
    DRowSpan = TC.RowSpan;
    DColSpan = TC.ColSpan;
    if(DRow + DRowSpan > T.Rows)    DRowSpan = T.Rows - DRow;
    if(DCol + DColSpan > T.Cols)    DColSpan = T.Cols - DCol;
    
    // Determine the dimensions of a cell
    CellW = (C.ClipX * T.W) / float(T.Cols);
    CellH = (C.ClipY * T.H) / float(T.Rows);
    
    // Determine the top-left draw position of the cell index
    CellX = (C.ClipX * T.X) + (CellW * DCol);
    CellY = (C.ClipY * T.Y) + (CellH * DRow);
    
    // Determine the draw dimensions
    CellW = CellW * DColSpan;
    CellH = CellH * DRowSpan;
}

////////////////////////////////////////////////////////////////////////////////
//  TableCell implementation
function TableCellSetIndex(
    out TableCell_s     TC,
    int                 Row,
    int                 Col)
{
    TC.Row = Row;
    TC.Col = Col;
}

function TableCellSetSpan(
    out TableCell_s     TC,
    int                 Rows,
    int                 Cols)
{
    TC.RowSpan = Rows;
    TC.ColSpan = Cols;
}

function TableCellSetTexture(
    out TableCell_s     TC,
    Texture             Tex)
{
    TC.Tex = Tex;
}

function TableCellSetString(
    out TableCell_s             TC,
    String                      Str,
    optional Color              StrColor,
    optional Justification_e    JustifyX,
    optional Justification_e    JustifyY)
{
    TC.Str = Str;
    TC.StrColor = StrColor;
    TC.JustifyX = JustifyX;
    TC.JustifyY = JustifyY;
}

////////////////////////////////////////////////////////////////////////////////
//  DrawTableCell
//
//  Given a table and a table cell, a texture and a string may be drawn onto
//  the players scoreboard.
////////////////////////////////////////////////////////////////////////////////
function DrawTableCell(Canvas C, Table_s T, TableCell_s TC)
{
    local float DX, DY;
    local float DW, DH;
    local float StrW, StrH;
    
    TableGetCellInfo(C, T, TC, DX, DY, DW, DH);
    
    // Draw the texture
    if(TC.Tex != None)
    {
        
    }
    
    // Draw the string
    if(TC.Str != "")
    {
        C.StrLen(TC.Str, StrW, StrH);
        switch(TC.JustifyX)
        {
            case JUSTIFY_MAX:       // Right justify
                DX = DX + DW - StrW;
                break;
            
            case JUSTIFY_CENTER:    // Center justify
                DX = DX + (DW * 0.5) - (StrW * 0.5);
                break;
            
            case JUSTIFY_MIN:       // Left justify
            default:
                break;
        }
        
        switch(TC.JustifyY)
        {
            case JUSTIFY_MAX:       // Bottom justify
                DY = DY + DH - StrH;
                break;
            
            case JUSTIFY_CENTER:    // Center justify
                DY = DY + (DH * 0.5) - (StrH * 0.5);
                break;
            
            case JUSTIFY_MIN:       // Left justify
            default:
                break;
        }
        
        //C.DrawColor = ColorsTeamsClass.Static.ColorWhite();
        C.DrawColor = TC.StrColor;
        C.SetPos(DX, DY);
        C.DrawText(TC.Str);
    }
}

////////////////////////////////////////////////////////////////////////////////
//  DrawTableCellScrolling
//
//  Same as DrawTableCell, except any string values will have their X position
//  interpolated, giving the appearance of scrolling text.
////////////////////////////////////////////////////////////////////////////////
function DrawTableCellScrolling(
    Canvas          C,
    Table_s         T,
    TableCell_s     TC,
    float           Interp)
{
    local float DX, DY;
    local float DW, DH;
    local float StrW, StrH;
    
    TableGetCellInfo(C, T, TC, DX, DY, DW, DH);
    
    // Draw the string
    if(TC.Str != "")
    {
        C.StrLen(TC.Str, StrW, StrH);
        switch(TC.JustifyY)
        {
            case JUSTIFY_MAX:       // Bottom justify
                DY = DY + DH - StrH;
                break;
            
            case JUSTIFY_CENTER:    // Center justify
                DY = DY + (DH * 0.5) - (StrH * 0.5);
                break;
            
            case JUSTIFY_MIN:       // Left justify
            default:
                break;
        }
        
        DX = UtilitiesClass.Static.InterpLinear(Interp, (DX + DW), DX, 1.0);
        C.DrawColor = ColorsTeamsClass.Static.ColorWhite();
        C.SetPos(DX, DY);
        C.DrawText(TC.Str);
    }
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

function UpdatePRIArray()
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
}

////////////////////////////////////////////////////////////////////////////////
//  ShowScore
////////////////////////////////////////////////////////////////////////////////
function ShowScores(Canvas C)
{
    local int CurrentRow, SavedRow;
    local int CurrentCol, SavedCol;
    
    local int i;
    local float t; // Interp value
    
    if(Level.TimeSeconds < TimeStamp + FadeTime)
        t = (Level.TimeSeconds - TimeStamp) / (FadeTime);
    else
        t = 1.0;
    
    // Update and sort the player replication info array
    UpdatePRIArray();
    SortPRIByScore(0, PRIPlayerCount);
    
    // Prepare the scoreboard table
    C.Font = RegFont;
    
    TableSetResolution(TableHeader, TableRows, TableCols);
    TableSetDimensions(TableHeader, 0.8, 0.8);
    TableSetPosition(TableHeader, 0.1, 0.1);
    
    CurrentRow = 0;
    CurrentCol = 0;
    
    // Draw server name
    TableCellSetIndex(TableCellServerName, CurrentRow, 0);
    TableCellSetSpan(TableCellServername, 1, TableHeader.Cols);
    TableCellSetTexture(TableCellServerName, None);
    TableCellSetString(
        TableCellServerName,
        PlayerPawn(Owner).GameReplicationInfo.ServerName,
        ColorsTeamsClass.Static.ColorGreen(),
        JUSTIFY_CENTER,
        JUSTIFY_CENTER);
    DrawTableCell(C, TableHeader, TableCellServerName);
    CurrentRow++;
    
    // Draw map info scrolling bar
    TableCellSetIndex(TableCellServerName, CurrentRow, 0);
    TableCellSetSpan(TableCellServername, 1, TableHeader.Cols);
    TableCellSetTexture(TableCellServerName, None);
    TableCellSetString(
        TableCellServerName,
        TextClass.Static.ScoreBoardAuthor() $ " [" $ Level.Author $ "]      " $
        TextClass.Static.ScoreBoardLevel() $ " [" $ Level.Title $ "]      " $
        TextClass.Static.ScoreBoardIdealLoad() $ " [" $ Level.IdealPlayerCount $ "]",
        ColorsTeamsClass.Static.ColorRed(),
        JUSTIFY_CENTER,
        JUSTIFY_CENTER);
    if(Level.TimeSeconds - ScrollingInterp0 >= 20.0)
        ScrollingInterp0 = Level.TimeSeconds;
    t = (Level.TimeSeconds - ScrollingInterp0) / 20.0;
    DrawTableCellScrolling(C, TableHeader, TableCellServerName, t);
    CurrentRow++;
    
    // Draw player info
    if(PRIPlayerCount > 0)
    {
        SavedRow = CurrentRow;
        
        // Draw player names
        CurrentCol = 0;
        TableCellSetIndex(TableCellServerName, CurrentRow, CurrentCol);
        TableCellSetSpan(TableCellServerName, 2, 3);
        TableCellSetString(
            TableCellServerName,
            TextClass.Static.ScoreBoardPlayers(),
            ColorsTeamsClass.Static.ColorGold(),
            JUSTIFY_MIN,
            JUSTIFY_CENTER);
        DrawTableCell(C, TableHeader, TableCellServerName);
        CurrentRow += 2;
        
        for(i = 0; i < PRIPlayerCount; i++)
        {
            TableCellSetIndex(TableCellServerName, CurrentRow, CurrentCol);
            TableCellSetSpan(TableCellServerName, 1, 3);
            TableCellSetString(
                TableCellServerName,
                PRIOrdered[i].PlayerName,
                ColorsTeamsClass.Static.ColorWhite(),
                JUSTIFY_MIN,
                JUSTIFY_CENTER);
            DrawTableCell(C, TableHeader, TableCellServerName);
            CurrentRow++;
        }
        CurrentRow = SavedRow;
        CurrentCol += 3;
        
        // Draw player scores
        TableCellSetIndex(TableCellServerName, CurrentRow, CurrentCol);
        TableCellSetSpan(TableCellServerName, 2, 1);
        TableCellSetString(
            TableCellServerName,
            TextClass.Static.ScoreBoardScore(),
            ColorsTeamsClass.Static.ColorGold(),
            JUSTIFY_MIN,
            JUSTIFY_CENTER);
        DrawTableCell(C, TableHeader, TableCellServerName);
        CurrentRow += 2;
        
        for(i = 0; i < PRIPlayerCount; i++)
        {
            TableCellSetIndex(TableCellServerName, CurrentRow, CurrentCol);
            TableCellSetSpan(TableCellServerName, 1, 1);
            TableCellSetString(
                TableCellServerName,
                "" $ int(PRIOrdered[i].Score),
                ColorsTeamsClass.Static.ColorWhite(),
                JUSTIFY_MIN,
                JUSTIFY_CENTER);
            DrawTableCell(C, TableHeader, TableCellServerName);
            CurrentRow++;
        }
        CurrentRow = SavedRow;
        CurrentCol += 1;
        
        // Draw player deaths
        TableCellSetIndex(TableCellServerName, CurrentRow, CurrentCol);
        TableCellSetSpan(TableCellServerName, 2, 1);
        TableCellSetString(
            TableCellServerName,
            TextClass.Static.ScoreBoardDeaths(),
            ColorsTeamsClass.Static.ColorGold(),
            JUSTIFY_MIN,
            JUSTIFY_CENTER);
        DrawTableCell(C, TableHeader, TableCellServerName);
        CurrentRow += 2;
        
        for(i = 0; i < PRIPlayerCount; i++)
        {
            TableCellSetIndex(TableCellServerName, CurrentRow, CurrentCol);
            TableCellSetSpan(TableCellServerName, 1, 1);
            TableCellSetString(
                TableCellServerName,
                "" $ int(PRIOrdered[i].Deaths),
                ColorsTeamsClass.Static.ColorWhite(),
                JUSTIFY_MIN,
                JUSTIFY_CENTER);
            DrawTableCell(C, TableHeader, TableCellServerName);
            CurrentRow++;
        }
        CurrentRow = SavedRow;
        CurrentCol += 1;
        
        // Draw player ping
        TableCellSetIndex(TableCellServerName, CurrentRow, CurrentCol);
        TableCellSetSpan(TableCellServerName, 2, 1);
        TableCellSetString(
            TableCellServerName,
            TextClass.Static.ScoreBoardPing(),
            ColorsTeamsClass.Static.ColorGold(),
            JUSTIFY_MIN,
            JUSTIFY_CENTER);
        DrawTableCell(C, TableHeader, TableCellServerName);
        CurrentRow += 2;
        
        for(i = 0; i < PRIPlayerCount; i++)
        {
            TableCellSetIndex(TableCellServerName, CurrentRow, CurrentCol);
            TableCellSetSpan(TableCellServerName, 1, 1);
            TableCellSetString(
                TableCellServerName,
                "" $ PRIOrdered[i].Ping,
                ColorsTeamsClass.Static.ColorWhite(),
                JUSTIFY_MIN,
                JUSTIFY_CENTER);
            DrawTableCell(C, TableHeader, TableCellServerName);
            CurrentRow++;
        }
    }
    CurrentRow++;
    CurrentCol = 0;
    
    // Draw spectator info
    if(PRISpectatorCount > 0)
    {
        // Draw player names
        TableCellSetIndex(TableCellServerName, CurrentRow, 0);
        TableCellSetSpan(TableCellServerName, 2, 3);
        TableCellSetString(
            TableCellServerName,
            TextClass.Static.ScoreBoardSpectators(),
            ColorsTeamsClass.Static.ColorGreen(),
            JUSTIFY_MIN,
            JUSTIFY_CENTER);
        DrawTableCell(C, TableHeader, TableCellServerName);
        CurrentRow += 2;
        
        for(i = 0; i < PRISpectatorCount; i++)
        {
            TableCellSetIndex(TableCellServerName, CurrentRow + i, 0);
            TableCellSetSpan(TableCellServerName, 1, 3);
            TableCellSetString(
                TableCellServerName,
                PRIOrdered[MAX_PRI - 1 - i].PlayerName,
                ColorsTeamsClass.Static.ColorBlue(),
                JUSTIFY_MIN,
                JUSTIFY_CENTER);
            DrawTableCell(C, TableHeader, TableCellServerName);
        }
    }
}








function UpdateTimeStamp(float t)
{
    TimeStamp = t;
}





defaultproperties
{
    RegFont=Font'Engine.MedFont'
    
    TextHeaderMessages(0)="Test \n line 1"
    TextHeaderMessages(1)="dAssdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasdasd"
    TextHeaderMessages(2)="hehehehe"
    TextHeaderMessages(3)="test line 3 fsdjsdfijgso"
    
    TextureBackdrop=Texture'RuneI.sb_horizramp'
    
    FadeTime=0.25
    UtilitiesClass=Class'Vmod.vmodStaticUtilities'
    ColorsTeamsClass=Class'Vmod.vmodStaticColorsTeams'
    FontsClass=Class'Vmod.vmodStaticFonts'
    TextClass=Class'Vmod.vmodStaticLocalText'
    
    RelYScoreBoard=0.1
    RelWScoreBoard=0.6
    TextYPadding=2.0
    TextureHBorder=Texture'RuneI.sb_horizramp'
    
    TableRows=16
    TableCols=16
}