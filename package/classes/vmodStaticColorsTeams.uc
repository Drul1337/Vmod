////////////////////////////////////////////////////////////////////////////////
//  vmodStaticColorsTeams
////////////////////////////////////////////////////////////////////////////////
class vmodStaticColorsTeams extends vmodStaticColors;

// TODO: Normalize these color values

////////////////////////////////////////////////////////////////////////////////
//  GetTeamColor
//
//  This is the end-all function for determining team colors. Override these
//  functions in base classes for custom game mode colors.
////////////////////////////////////////////////////////////////////////////////
static function GetTeamColor(
    byte Team,
    optional out byte R,
    optional out byte G,
    optional out byte B)
{
    local Color C;
    switch(Team)
    {
        case 0:     C = ColorRed();         break;
        case 1:     C = ColorBlue();        break;
        case 2:     C = ColorGreen();       break;
        case 3:     C = ColorGold();        break;
        case 255:   
        default:    C = GetDefaultColor();  break;
    }
    R = C.R;
    G = C.G;
    B = C.B;
}

static function Color GetDefaultColor()
{
    return ColorWhite();
}

// TODO: Find a way to unify these functions
static function GetTeamColorVector(
    byte Team,
    optional out float R,
    optional out float G,
    optional out float B)
{
    switch(Team)
    {
        case 0:     R = 1.000;  G = 0.235;  B = 0.235;  break;  // Red
        case 1:     R = 0.235;  G = 0.235;  B = 1.000;  break;  // Blue
        case 2:     R = 0.235;  G = 1.000;  B = 0.235;  break;  // Green
        case 3:     R = 1.000;  G = 1.000;  B = 0.235;  break;  // Gold
        case 255:
        default:    GetDefaultColorVector(R, G, B);             // Default
    }
}

static function GetDefaultColorVector(out float R, out float G, out float B)
{
    R = 1.0;
    G = 1.0;
    B = 1.0;
}