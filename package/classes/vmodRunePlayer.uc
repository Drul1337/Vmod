///////////////////////////////////////////////////////////////////////////////
// vmodRunePlayerInterface.uc
//
//		|---Object
//			|---Actor
//				|---Pawn
//					|---PlayerPawn
//						|---vmodPlayerPawnBase
//							|---vmodPlayerPawnInterface
//								|---vmodRunePlayerBase
//									|---vmodRunePlayerInterface
//										|---vmodRunePlayer
//

class vmodRunePlayer extends vmodRunePlayerInterface config(user) abstract;
//class vmodRunePlayer extends RunePlayer config(user) abstract;

var Class<vmodStaticColorsTeams>    ColorsTeamsClass;
var bool bCanRestart;

replication
{
    // Client --> Server
    reliable if ( Role < ROLE_Authority )
        VcmdGameReset,
        VcmdReady,
        VcmdNotReady,
        VcmdGameEnd,
        VcmdGameStart,
        VcmdClearInventory,
        VcmdGiveWeapon,
        VcmdSpectate,
        VcmdPlay,
        VcmdChangeTeam,
        VcmdGetPlayerList,
        VcmdSetPlayerTeam,
        VcmdBroadcast,
        VcmdShuffleTeams,
        VcmdAddBot,
        VcmdRemoveBots,
        VcmdGrantAdmin;
}

///////////////////////////////////////////////////////////////////////////////
//  Check functions used by vmodGameInfo classes
function bool CheckIsAdministrator()    { return bAdmin; }
function bool CheckIsHuman()            { return true; }
function bool CheckIsAI()               { return false; }
function bool CheckIsGameActive()       { return !PlayerReplicationInfo.bIsSpectator; }
function bool CheckIsGameInactive()     { return PlayerReplicationInfo.bIsSpectator; }
function bool CheckIsReadyToPlay()      { return bReadyToPlay; }
function bool CheckIsNotReadyToPlay()   { return !bReadyToPlay; }
function bool CheckIsAlive()            { return Health > 0; }
function bool CheckIsDead()             { return Health <= 0; }
function bool CheckIsShowingScores()    { return bShowScores; }
function bool CheckIsNotShowingScores() { return !bShowScores; }

function int GetHealth()                { return Health; }
function int GetHealthMax()             { return MaxHealth; }
function int GetStrength()              { return Strength; }
function byte GetTeam()                 { return PlayerReplicationInfo.Team; }
function int GetID()                    { return PlayerReplicationInfo.PlayerID; }


function ResetPlayerStatistics()
{
    PlayerReplicationInfo.Score         = 0;
    PlayerReplicationInfo.Deaths        = 0;
    PlayerReplicationInfo.bReadyToPlay  = false;
    PlayerReplicationInfo.bFirstBlood   = false;
    PlayerReplicationInfo.MaxSpree      = 0;
    PlayerReplicationInfo.HeadKills     = 0;
}




// Received from GameInfo
function NotifyBecameAdministrator()
{
    bAdmin = true;
    PlayerReplicationInfo.bAdmin = bAdmin;
}

function NotifyNoLongerAdministrator()
{
    bAdmin = false;
    PlayerReplicationInfo.bAdmin = bAdmin;
}

function NotifyBecameGameActive()
{
    PlayerReplicationInfo.bIsSpectator = false;
    bHidden = false;
    Visibility = Default.Visibility;
    GotoState('PlayerWalking');
}

function NotifyBecameGameInactive()
{
    GotoStatePlayerSpectating();
}

function NotifyBecameReadyToPlay()
{
    bReadyToPlay = true;
}

function NotifyBecameNotReadyToPlay()
{
    bReadyToPlay = false;
}

function AdjustColor()
{
    local Vector V;
    local float Brightness;
    
    Brightness = 255.0;
    ColorsTeamsClass.Static.GetTeamColorVector(
        GetTeam(),
        V.X,
        V.Y,
        V.Z);
    DesiredColorAdjust = V * Brightness;
}

function NotifyChangedTeam(byte Team)
{
    PlayerReplicationInfo.Team = Team;
    AdjustColor();
}

function NotifyRespawn()
{
    AdjustColor();
}

///////////////////////////////////////////////////////////////////////////////
//  Game Notifications
///////////////////////////////////////////////////////////////////////////////
function NotifyGamePreGame()
{}

function NotifyGameStarting()
{}

function NotifyGameLive()
{}

function NotifyGamePostGame()
{
    GotoState('GameEnded');
    ClientGameEnded();
}

function NotifyGamePreRound()
{}

function NotifyGameStartingRound()
{}

function NotifyGamePostRound()
{}


///////////////////////////////////////////////////////////////////////////////
//  Command Interface
///////////////////////////////////////////////////////////////////////////////
exec final function Vcmd()
{
    ClientMessage("-Vmod Commands-");
    Clientmessage("VcmdReady");
    Clientmessage("VcmdNotReady");
    Clientmessage("VcmdSpectate");
    Clientmessage("VcmdPlay");
    Clientmessage("VcmdChangeTeam");
    Clientmessage("VcmdGetPlayerList");
    
    ClientMessage("-Vmod Admin Commands-");
    Clientmessage("VcmdBroadcast");
    Clientmessage("VcmdGameReset");
    Clientmessage("VcmdGameEnd");
    Clientmessage("VcmdGameStart");
    Clientmessage("VcmdGiveWeapon");
    Clientmessage("VcmdSetPlayerTeam");
    Clientmessage("VcmdShuffleTeams");
    Clientmessage("VcmdAddBot");
    Clientmessage("VcmdRemoveBots");
    Clientmessage("VcmdGrantAdmin");
}

// Administrator commands
exec final function VcmdGrantAdmin(int ID)
{
    vmodGameInfo(Level.Game).AdminRequestGrantAdmin(Self, ID);
}

exec final function VcmdBroadcast(String Message)
{
    vmodGameInfo(Level.Game).AdminRequestBroadcast(Self, Message);
}

exec final function VcmdGameReset()
{
    vmodGameInfo(Level.Game).AdminRequestGameReset(Self);
}

exec final function VcmdGameEnd()
{
    vmodGameInfo(Level.Game).AdminRequestGameEnd(Self);
}

exec final function VcmdGameStart()
{
    vmodGameInfo(Level.Game).AdminRequestGameStart(Self);
}
//
exec final function VcmdGiveWeapon(class<Weapon> WeaponClass)
{
    vmodGameInfo(Level.Game).AdminRequestGiveWeapon(Self, WeaponClass);
}

exec final function VcmdSetPlayerTeam(int PlayerID, byte Team)
{
    vmodGameInfo(Level.Game).AdminRequestTeamChange(Self, PlayerID, Team);
}

exec final function VcmdShuffleTeams()
{
    vmodGameInfo(Level.Game).AdminRequestShuffleTeams(Self);
}

exec final function VcmdAddBot()
{
    vmodGameInfo(Level.Game).AdminRequestAddBot(self);
}

exec final function VcmdRemoveBots()
{
    vmodGameInfo(Level.Game).AdminRequestRemoveAllBots(self);
}


// General player commands
exec final function VcmdReady()
{
    vmodGameInfo(Level.Game).PlayerRequestReadyToPlay(self);
}

exec final function VcmdNotReady()
{
    vmodGameInfo(Level.Game).PlayerRequestNotReadyToPlay(self);
}

exec final function VcmdSpectate()
{
    vmodGameInfo(Level.Game).PlayerRequestGoGameInactive(self);
}

exec final function VcmdPlay()
{
    vmodGameInfo(Level.Game).PlayerRequestGoGameActive(self);
}

exec final function VcmdChangeTeam(byte team)
{
    vmodGameInfo(Level.Game).PlayerRequestTeamChange(self, team);
}

// TODO: If admin, display a player ID on the scoreboard
exec final function VcmdGetPlayerList()
{
    vmodGameInfo(Level.Game).PlayerRequestPlayerList(self);
}


// Test functions
exec final function VcmdClearInventory()
{
    if(vmodGameInfo(Level.Game) != None)
        vmodGameInfo(Level.Game).ClearPlayerInventory(self);
}



//state PlayerSpectating
//{
//    function BeginState()
//	{
//		PlayerReplicationInfo.bIsSpectator = true;
//        bHidden = true;
//        Visibility = 0;
//        PlayerReplicationInfo.bWaitingPlayer = true;
//        Mesh = None;
//        SetCollision(false,false,false);
//        bCollideWorld = false;
//		EyeHeight = Default.BaseEyeHeight;
//		SetPhysics(PHYS_None);
//	}
//}





defaultproperties
{
    bReadyToPlay=false
    PlayerReplicationInfoClass=Class'Vmod.vmodPlayerReplicationInfo'
    ColorsTeamsClass=Class'Vmod.vmodStaticColorsTeams'
}