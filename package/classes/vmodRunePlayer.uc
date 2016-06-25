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
//class vmodRunePlayer extends PlayerPawn config(user) abstract;

//var bool bCanRestart;
//
//replication
//{
//    // Client --> Server
//    reliable if ( Role < ROLE_Authority )
//        VcmdGameReset,
//        VcmdReady,
//        VcmdUnready,
//        VcmdEndGame,
//        VcmdClearInventory,
//        VcmdGiveWeapon,
//        VcmdSpectate,
//        VcmdPlay;
//}
//
//function bool ReadyToGoLive()
//{ return bReadyToPlay; }
//
//function SetReadyToGoLive(bool B)
//{
//    if(B)
//        vmodGameInfo(Level.Game).PlayerRequestingToGoReady(self);
//    else
//        vmodGameInfo(Level.Game).PlayerRequestingToGoNotReady(self);
//}
//
/////////////////////////////////////////////////////////////////////////////////
////  Game Notifications
/////////////////////////////////////////////////////////////////////////////////
//function NotifyGamePreGame()
//{
//    //GotoState('PlayerWalking');
//    GotoState('PlayerSpectating');
//}
//
//function NotifyGameStarting()
//{
//    GotoState('PlayerWalking');
//}
//
//function NotifyGameLive()
//{
//    GotoState('PlayerWalking');
//}
//
//function NotifyGamePostGame()
//{
//    GotoState('GameEnded');
//    ClientGameEnded();
//}
//
//function NotifyGamePreRound()
//{}
//
//function NotifyGameStartingRound()
//{}
//
//function NotifyGamePostRound()
//{}
//
//function NotifyReadyToGoLive()
//{ bReadyToPlay = true; }
//
//function NotifyNotReadyToGoLive()
//{ bReadyToPlay = false; }
//
/////////////////////////////////////////////////////////////////////////////////
////  Game interface
/////////////////////////////////////////////////////////////////////////////////
//exec final function VcmdGameReset()
//{
//    if( bAdmin || Level.NetMode==NM_Standalone || Level.netMode==NM_ListenServer )
//        if(Level.Game.IsA('vmodGameInfo'))
//            vmodGameInfo(Level.Game).GameReset();
//}
//
//exec final function VcmdReady()
//{
//    SetReadyToGoLive(true);
//}
//
//exec final function VcmdUnready()
//{
//    SetReadyToGoLive(false);
//}
//
//exec final function VcmdEndGame()
//{
//    if(vmodGameInfo(Level.Game) != None)
//        vmodGameInfo(Level.Game).GotoStatePostGame();
//}
//
//exec final function VcmdClearInventory()
//{
//    if(vmodGameInfo(Level.Game) != None)
//        vmodGameInfo(Level.Game).ClearPlayerInventory(self);
//}
//
//exec final function VcmdGiveWeapon(class<Weapon> WeaponClass)
//{
//    if(vmodGameInfo(Level.Game) != None)
//        vmodGameInfo(Level.Game).GivePlayerWeapon(self, WeaponClass);
//}
//
//exec final function VcmdSpectate()
//{
//    GotoState('PlayerSpectating');
//}
//
//exec final function VcmdPlay()
//{
//    GotoState('PlayerWalking');
//}
//
//defaultproperties
//{
//    bReadyToPlay=false
//    PlayerReplicationInfoClass=Class'Vmod.vmodPlayerReplicationInfo'
//}