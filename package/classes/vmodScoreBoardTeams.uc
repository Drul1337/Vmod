////////////////////////////////////////////////////////////////////////////////
// vmodScoreBoardTeams
////////////////////////////////////////////////////////////////////////////////
class vmodScoreBoardTeams extends vmodScoreBoard;

////////////////////////////////////////////////////////////////////////////////
//  DrawPlayerScores
////////////////////////////////////////////////////////////////////////////////
function DrawPlayerScores(Canvas C, float t, SortType_e SortType)
{
    local PlayerReplicationInfo PRI;
    local int i, j;
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
    // Sort all PRI by team
    SortPRIByTeam(0, PRIPlayerCount);
    
    // Sort the individual players in each team
    i = 0;
    j = 0;
    while(i < PRIPlayerCount)
    {
        while(j < PRIPlayerCount && PRIOrdered[i].Team == PRIOrdered[j].Team)
            j++;
        SortPRIByScore(i, j);
        i = j;
    }
    
    
    // Players heading
    if(PRIPlayerCount > 0)
    {
        C.DrawColor = GoldColor;
        C.SetPos(C.ClipX * 0.1, C.ClipY * 0.225);
        C.DrawText(TextClass.Static.ScoreBoardPlayers());
        
        // Score heading
        C.SetPos(C.ClipX * 0.3, C.ClipY * 0.225);
        C.DrawText(TextClass.Static.ScoreBoardScore());
        
        // Deaths heading
        C.SetPos(C.ClipX * 0.35, C.ClipY * 0.225);
        C.DrawText(TextClass.Static.ScoreBoardDeaths());
        
        // Draw the players
        C.Style = ERenderStyle.STY_Translucent;
        for(i = 0; i < PRIPlayerCount; i++)
        {
            // Name
            //C.DrawColor = WhiteColor * 0.05;
            ColorsTeamsClass.Static.GetTeamColor(
                PRIOrdered[i].Team,
                C.DrawColor.R,
                C.DrawColor.G,
                C.DrawColor.B);
            C.DrawColor = C.DrawColor * 0.25 * t;
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
        C.DrawText(TextClass.Static.ScoreBoardSpectators());
        
        // Draw the spectators
        C.DrawColor = WhiteColor;
        for(i = 0; i < PRISpectatorCount; i++)
        {
            C.SetPos(C.ClipX * 0.1, (C.ClipY) * 0.5 + (i * 16));
            C.DrawText(PRIOrdered[MAX_PRI - 1 - i].PlayerName);
        }
    }
}