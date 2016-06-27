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
        VcmdEndGame,
        VcmdClearInventory,
        VcmdGiveWeapon,
        VcmdSpectate,
        VcmdPlay,
        VcmdChangeTeam,
        VcmdGetPlayerIds,
        VcmdSetPlayerTeam;
}

function bool ReadyToGoLive()
{ return bReadyToPlay; }

function SetReadyToGoLive(bool B)
{
    if(B)
        vmodGameInfo(Level.Game).PlayerRequestingToGoReady(self);
    else
        vmodGameInfo(Level.Game).PlayerRequestingToGoNotReady(self);
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

function NotifyReadyToGoLive()
{ bReadyToPlay = true; }

function NotifyNotReadyToGoLive()
{ bReadyToPlay = false; }

function NotifyTeamChange(byte team)
{
    PlayerReplicationInfo.Team = team;
}

///////////////////////////////////////////////////////////////////////////////
//  Game interface
///////////////////////////////////////////////////////////////////////////////
exec final function VcmdGameReset()
{
    if( bAdmin || Level.NetMode==NM_Standalone || Level.netMode==NM_ListenServer )
        if(Level.Game.IsA('vmodGameInfo'))
            vmodGameInfo(Level.Game).GameReset();
}

exec final function VcmdReady()
{
    SetReadyToGoLive(true);
}

exec final function VcmdNotReady()
{
    SetReadyToGoLive(false);
}

exec final function VcmdEndGame()
{
    if(vmodGameInfo(Level.Game) != None)
        vmodGameInfo(Level.Game).GotoStatePostGame();
}

exec final function VcmdClearInventory()
{
    if(vmodGameInfo(Level.Game) != None)
        vmodGameInfo(Level.Game).ClearPlayerInventory(self);
}

exec final function VcmdGiveWeapon(class<Weapon> WeaponClass)
{
    if(vmodGameInfo(Level.Game) != None)
        vmodGameInfo(Level.Game).GivePlayerWeapon(self, WeaponClass);
}

exec final function VcmdSpectate()
{
    GotoState('PlayerSpectating');
}

exec final function VcmdPlay()
{
    GotoState('PlayerWalking');
}

exec final function VcmdChangeTeam(byte team)
{
    vmodGameInfo(Level.Game).PlayerRequestingTeamChange(self, team);
}

// TODO: If admin, display a player ID on the scoreboard
exec final function VcmdGetPlayerIds()
{
    local Pawn P;
    
    for(P = Level.PawnList; P != None; P = P.NextPawn)
        ClientMessage(
            P.PlayerReplicationInfo.PlayerName $ " : " $ P.PlayerReplicationInfo.PlayerID,
            vmodGameInfo(Level.Game).GetMessageTypeNameDefault(),
            false);
}

exec final function VcmdSetPlayerTeam(int PlayerID, byte team)
{
    local Pawn P;
    for(P = Level.PawnList; P != None; P = P.NextPawn)
        if(P.PlayerReplicationInfo.PlayerID == PlayerID)
            vmodGameInfo(Level.Game).PlayerRequestingTeamChange(P, team);
}

defaultproperties
{
    bReadyToPlay=false
    PlayerReplicationInfoClass=Class'Vmod.vmodPlayerReplicationInfo'
}