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

function bool ReadyToGoLive()
{ return bReadyToPlay; }

function bool CheckIsSpectator()
{
    return PlayerReplicationInfo.bIsSpectator;
}

function bool CheckIsPlaying()
{
    return !PlayerReplicationInfo.bIsSpectator;
}

// Received from GameInfo
function NotifyBecameSpectator()
{
    PlayerReplicationInfo.bIsSpectator = true;
    bHidden = true;
    Visibility = 0;
    GotoState('PlayerSpectating');
}

function NotifyJoinedGame()
{
    PlayerReplicationInfo.bIsSpectator = false;
    bHidden = false;
    Visibility = Default.Visibility;
    GotoState('PlayerWalking');
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
//  Game interface
///////////////////////////////////////////////////////////////////////////////
exec final function Vcmd()
{
    // TODO: Probably a better way to implement this based on what Vcmds there are
    ClientMessage("VcmdGameReset");
    ClientMessage("VcmdGameEnd");
    ClientMessage("VcmdGameStart");
    ClientMessage("VcmdReady");
    ClientMessage("VcmdNotReady");
    ClientMessage("VcmdSpectate");
    ClientMessage("VcmdPlay");
    ClientMessage("VcmdChangeTeam");
    ClientMessage("VcmdGetPlayerList");
    ClientMessage("VcmdSetPlayerTeam");
    ClientMessage("VcmdBroadcast");
    ClientMessage("VcmdGiveWeapon");
    ClientMessage("VcmdShuffleTeams");
    ClientMessage("VcmdAddBot");
    ClientMessage("VcmdRemoveBots");
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

exec final function VcmdReady()
{
    vmodGameInfo(Level.Game).PlayerRequestReadyToPlay(self);
}

exec final function VcmdNotReady()
{
    vmodGameInfo(Level.Game).PlayerRequestNotReadyToPlay(self);
}

exec final function VcmdClearInventory()
{
    if(vmodGameInfo(Level.Game) != None)
        vmodGameInfo(Level.Game).ClearPlayerInventory(self);
}

exec final function VcmdGiveWeapon(class<Weapon> WeaponClass)
{
    vmodGameInfo(Level.Game).AdminRequestGiveWeapon(Self, WeaponClass);
}

exec final function VcmdSpectate()
{
    vmodGameInfo(Level.Game).PlayerRequestSpectate(self);
}

exec final function VcmdPlay()
{
    vmodGameInfo(Level.Game).PlayerRequestJoinGame(self);
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
    vmodGameInfo(Level.Game).AdminRequestRemoveBots(self);
}

defaultproperties
{
    bReadyToPlay=false
    PlayerReplicationInfoClass=Class'Vmod.vmodPlayerReplicationInfo'
}