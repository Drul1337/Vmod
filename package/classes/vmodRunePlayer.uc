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

replication
{
    reliable if ( Role < ROLE_Authority )
        VcmdGameReset,
        VcmdReady,
        VcmdUnready,
        VcmdEndGame;
}

function NotifyGamePreGame()
{
    GotoState('PlayerWalking');
}

function NotifyGameStarting()
{}

function NotifyGameLive()
{
    GotoState('PlayerWalking');
}

function NotifyGamePostGame()
{
    GotoState('GameEnded');
    ClientGameEnded();
}

exec final function VcmdGameReset()
{
    if( bAdmin || Level.NetMode==NM_Standalone || Level.netMode==NM_ListenServer )
        if(Level.Game.IsA('vmodGameInfo'))
            vmodGameInfo(Level.Game).GameReset();
}

exec final function VcmdReady()
{
    bReadyToPlay = true;
    if(vmodGameInfo(Level.Game) != None)
        vmodGameInfo(Level.Game).PlayerReadied(self);
}

exec final function VcmdUnready()
{
    bReadyToPlay = false;
    if(vmodGameInfo(Level.Game) != None)
        vmodGameInfo(Level.Game).PlayerUnreadied(self);
}

exec final function VcmdEndGame()
{
    if(vmodGameInfo(Level.Game) != None)
        vmodGameInfo(Level.Game).GotoStatePostGame();
}