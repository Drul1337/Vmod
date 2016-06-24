////////////////////////////////////////////////////////////////////////////////
// vmodScoreBoard
////////////////////////////////////////////////////////////////////////////////
class vmodScoreBoard extends RuneScoreBoard;

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
	if (PRI.bAdmin)	//FONT ALTER
	{
		//Canvas.Font = Font'SmallFont';
		if(MyFonts != None)
			Canvas.Font = MyFonts.GetStaticSmallFont();
		else
			Canvas.Font = Font'SmallFont';
	}
	else
	{	//FONT ALTER
		//Canvas.Font = RegFont;
		if(MyFonts != None)
			Canvas.Font = MyFonts.GetStaticMedFont();
		else
			Canvas.Font = RegFont;
	}

	Canvas.SetPos(Canvas.ClipX*0.1, YOffset);
	Canvas.DrawText(PRI.PlayerName, false);
		//FONT ALTER
	//Canvas.Font = RegFont;
	if(MyFonts != None)
		Canvas.Font = MyFonts.GetStaticMedFont();
	else
		Canvas.Font = RegFont;

    // Draw ready
    if(vmodPlayerReplicationInfo(PRI).bReadyToGoLive)
    {
        Canvas.SetPos(Canvas.ClipX*0.3, YOffset);
        Canvas.DrawColor = GreenColor;
        Canvas.DrawText("ready", false);
    }
    
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

defaultproperties
{
    NameText="Name"
    FragsText="Frags"
    DeathsText="Deaths"
    PingText="Ping"
    AwardsText="Trophies"
}