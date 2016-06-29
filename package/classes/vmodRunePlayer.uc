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

//class vmodRunePlayer extends vmodRunePlayerInterface config(user) abstract;
class vmodRunePlayer extends RunePlayer config(user) abstract;

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
        VcmdRemoveBots;
}

///////////////////////////////////////////////////////////////////////////////
//  Check functions used by vmodGameInfo classes
function bool CheckIsHuman()            { return true; }
function bool CheckIsAI()               { return false; }
function bool CheckIsGameActive()       { return !PlayerReplicationInfo.bIsSpectator; }
function bool CheckIsGameInactive()     { return PlayerReplicationInfo.bIsSpectator; }
function bool CheckIsReadyToPlay()      { return bReadyToPlay; }
function bool CheckIsNotReadyToPlay()   { return !bReadyToPlay; }


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
function NotifyBecameGameActive()
{
    PlayerReplicationInfo.bIsSpectator = false;
    bHidden = false;
    Visibility = Default.Visibility;
    GotoState('PlayerWalking');
}

function NotifyBecameGameInactive()
{
    PlayerReplicationInfo.bIsSpectator = true;
    bHidden = true;
    Visibility = 0;
    GotoState('PlayerSpectating');
}

function NotifyBecameReadyToPlay()
{
    bReadyToPlay = true;
}

function NotifyBecameNotReadyToPlay()
{
    bReadyToPlay = false;
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
}

// Administrator commands
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


defaultproperties
{
    bReadyToPlay=false
    PlayerReplicationInfoClass=Class'Vmod.vmodPlayerReplicationInfo'
}