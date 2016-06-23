///////////////////////////////////////////////////////////////////////////////
// vmodPlayerPawnInterface.uc
//
//      |---Object
//          |---Actor
//              |---Pawn
//                  |---PlayerPawn
//                      |---vmodPlayerPawnBase
//                          |---vmodPlayerPawnInterface
//
// This class acts as a command interface into a vmodPlayerPawnBase. This is
// extended from a vmodPlayerPawnBase to avoid instantiation. This class,
// and only this class should handle all exec functions that a user can call
// from the in-game console. vmodPlayerPawn subclasses should not directly
// extend vmodPlayerPawnBase, they should extend this class.
//
class vmodPlayerPawnInterface extends vmodPlayerPawnBase abstract;


///////////////////////////////////////////////////////////////////////////////
//  General player commands
//
//  Basic vmodPlayerPawn interface functions.
///////////////////////////////////////////////////////////////////////////////
exec final function VcmdAdminLogin(string pwd)  { VcmdHandleAdminLogin(pwd); }
exec final function VcmdAdminLogout()           { VcmdHandleAdminLogout(); }
exec final function VcmdAlwaysMouseLook(bool b) { VcmdHandleAlwaysMouseLook(b); }
exec final function VcmdAttack()                { VcmdHandleAttack(); }
exec final function VcmdDefend()                { VcmdHandleDefend(); }
exec final function VcmdFunctionKey(byte f)     { VcmdHandleFunctionKey(f); }
exec final function VcmdJump()                  { VcmdHandleJump(); }
exec final function VcmdMutate(string s)        { VcmdHandleMutate(s); }
exec final function VcmdPing()                  { VcmdHandlePing(); }
exec final function VcmdPlayerList()            { VcmdHandlePlayerList(); }
exec final function VcmdSay(string s)           { VcmdHandleSay(s); }
exec final function VcmdSayTeam(string s)       { VcmdHandleSayTeam(s); }
exec final function VcmdShowMenu()              { VcmdHandleShowMenu(); }
exec final function VcmdSShot()                 { VcmdHandleSShot(); }
exec final function VcmdStow()                  { VcmdHandleStow(); }
exec final function VcmdSuicide()               { VcmdHandleSuicide(); }
exec final function VcmdSwitchInventory(byte f) { VcmdHandleSwitchInventory(f); }
exec final function VcmdTaunt()                 { VcmdHandleTaunt(); }
exec final function VcmdThrow()                 { VcmdHandleThrow(); }
exec final function VcmdToggleHUD()             { VcmdHandleToggleHUD(); }
exec final function VcmdToggleScoreboard()      { VcmdHandleToggleScoreboard(); }
exec final function VcmdUse()                   { VcmdHandleUse(); }


///////////////////////////////////////////////////////////////////////////////
//  Configuration commands
//
//  These commands set and save vmodPlayerPawn configuration variables.
///////////////////////////////////////////////////////////////////////////////
exec final function VcmdSetDodgeClickTime(float t)  { VcmdHandleSetDodgeClickTime(t); }
exec final function VcmdSetFov(float fov)           { VcmdHandleSetFov(fov); }
exec final function VcmdSetInvertMouse(bool b)      { VcmdHandleSetInvertMouse(b); }
exec final function VcmdSetName(coerce string s)    { VcmdHandleSetName(s); }
exec final function VcmdSetSensitivity(float f)     { VcmdHandleSetSensitivity(f); }


///////////////////////////////////////////////////////////////////////////////
//  Cheat-enabled commands
//
//  These commands are only available when the vmodPlayerPawn has cheats on.
///////////////////////////////////////////////////////////////////////////////
exec final function VcmdAmphibious()            { VcmdHandleAmphibious(); }
exec final function VcmdCauseEvent(name n)      { VcmdHandleCauseEvent(n); }


///////////////////////////////////////////////////////////////////////////////
//  Administrator commands
//
//  These commands are only available when the vmodPlayerPawn is an admin.
///////////////////////////////////////////////////////////////////////////////
exec final function VcmdBanPlayerName(string n)     { VcmdHandleBanPlayerName(n); }
exec final function VcmdEnableCheats(optional int id){ VcmdHandleEnableCheats(id); }
exec final function VcmdKickPlayerName(string n)    { VcmdHandleKickPlayerName(n); }
exec final function VcmdResetGame()                 { VcmdHandleResetGame(); }
exec final function VcmdSwitchLevel(string url)     { VcmdHandleSwitchLevel(url); }




// TODO: These have not all been tested to guarantee they are being called correctly
// TODO: Need to double check that none of these functions are overridden in vmodRunePlayer
///////////////////////////////////////////////////////////////////////////////
//  Deprecated original PlayerPawn commands
//
//  These commands have all been overridden to either do nothing, or to
//  interface with their corresponding Vcmd command. It is not recommend that
//  vmodPlayerPawn's use these commands, but they are left here to avoid
//  breaking any current user configurations.
///////////////////////////////////////////////////////////////////////////////
exec function ActivateInventoryItem(class InvItem)  { }
exec function ActivateItem()                        { }
exec function ActorState(class<actor> ac, name sn)  { }
exec function AddBots(int N)                        { }
exec function Admin(string CommandLine)             { }
exec function AdminLogin(string pwd)                { VcmdAdminLogin(pwd); }
exec function AdminLogout()                         { VcmdAdminLogout(); }
exec function AltFire(optional float F)             { VcmdDefend(); }
exec function AlwaysMouseLook(Bool B)               { VcmdAlwaysMouseLook(B); }
exec function Amphibious()                          { VcmdAmphibious(); }
exec function BehindView(Bool B)                    { }
exec function Bug(string Msg)                       { }
exec function CallForHelp()                         { }
exec function CauseEvent(name n)                    { VcmdHandleCauseEvent(n); }
//exec function ChangeCrosshair()                       { }
////exec function ChangeHud()                           { }
exec function CheatPlease()                         { VcmdEnableCheats(); }
exec function CheatView( class<actor> aClass )      { }
exec function ClearProgressMessages()               { }
exec function Damage(string Params)                 { }
exec function DebugCommand( string text )           { }
exec function DebugContinue()                       { }
exec function FeignDeath()                          { }
exec function Fire( optional float F )              { VcmdAttack(); }
exec function Fly()                                 { }
exec function FOV(float F)                          { VcmdSetFov(F); }
exec function FunctionKey(byte f)                   { VcmdFunctionKey(f); }
exec function GetWeapon(class<Weapon> nwc )         { }
exec function Ghost()                               { }
exec function God()                                 { }
exec function Grab()                                { }
exec function InvertMouse(bool b)                   { VcmdSetInvertMouse(b); }
exec function Invisible(bool B)                     { }
exec function Jump(optional float F)                { VcmdJump(); }
exec function Kick(string s)                        { VcmdKickPlayerName(s); }
exec function KickBan(string s)                     { VcmdBanPlayerName(s); }
exec function KillAll(class<actor> aClass)          { }
exec function KillPawns()                           { }
exec function Loc()                                 { }
exec function LocalTravel( string URL )             { }
exec function Mutate(string s)                      { VcmdMutate(s); }
exec function Name(coerce string s)                 { VcmdSetName(s); }
exec function NeverSwitchOnPickup( bool B )         { }
exec function NextWeapon()                          { }
exec function Pause()                               { }
exec function Ping()                                { VcmdPing(); }
exec function PlayerList()                          { VcmdPlayerList(); }
exec function PlayersOnly()                         { }
exec function Powerup()                             { }
exec function PrevItem()                            { }
exec function PrevWeapon()                          { }
exec function Profile()                             { }
exec function QuickLoad()                           { }
exec function QuickSave()                           { }
exec function RememberSpot()                        { }
exec function RestartLevel()                        { }
exec function RuleList()                            { }
exec function Say(string s)                         { VcmdSay(s); }
exec function SetAutoAim( float F )                 { }
exec function SetBob(float F)                       { }
exec function SetDesiredFOV(float F)                { VcmdSetFov(F); }
exec function SetDodgeClickTime(float F)            { VcmdSetDodgeClickTime(F); }
exec function SetFriction( float F )                { }
exec function SetJumpZ( float F )                   { }
exec function SetMaxMouseSmoothing( bool B )        { }
exec function SetMouseSmoothThreshold( float F )    { }
exec function SetName(coerce string s)              { VcmdSetName(s); }
exec function SetProgressColor(color C, int idx)    { }
exec function SetProgressMessage(string S, int idx) { }
exec function SetProgressTime( float T )            { }
exec function SetSensitivity(float F)               { VcmdSetSensitivity(F); }
exec function SetSpeed( float F )                   { }
exec function SetViewFlash(bool B)                  { }
exec function SetWeaponStay( bool B)                { }
exec function ShowInventory()                       { }
exec function ShowLoadMenu()                        { }
exec function ShowMenu()                            { VcmdHandleShowMenu(); }
exec function ShowPath()                            { }
exec function ShowScores()                          { VcmdToggleScoreboard(); }
exec function ShowSpecialMenu( string ClassName )   { }
exec function ShowTags(optional string cmdline)     { }
exec function ShutUp()                              { }
exec function SloMo( float T )                      { }
exec function SnapView( bool B )                    { }
exec function Speech(int t, int idx, int cs)        { }
exec function SShot()                               { VcmdSShot(); }
exec function StairLook( bool B )                   { }
exec function Suicide()                             { VcmdSuicide(); }
//exec function Summon(string ClassName)                { }
exec function SwitchCoopLevel( string URL )         { VcmdSwitchLevel(URL); }
exec function SwitchLevel( string URL )             { VcmdSwitchLevel(URL); }
exec function bool SwitchToBestWeapon()             { }
exec function SwitchWeapon(byte F)                  { VcmdSwitchInventory(F); }
exec function Taunt()                               { VcmdTaunt(); }
exec function Team( int N )                         { }
exec function TeamSay(string s)                     { VcmdSayTeam(s); }
exec function Tele(vector newLoc)                   { }
exec function Throw()                               { VcmdThrow(); }
exec function ToggleRuneHUD()                       { VcmdToggleHUD(); }
exec function Use()                                 { VcmdUse(); }
exec function ViewPlayer(string S )                 { }
exec function ViewPlayerNum(optional int num)       { }
exec function ViewSelf()                            { }
exec function Walk()                                { }
exec function Watch( string ClassName )             { }





///////////////////////////////////////////////////////////////////////////////
//
//  STATES
//
//  Guarantee that only the global exec function is ever called. Override the
//  command handler function for state-specific functionality.
//
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// STATE: PlayerWalking
state PlayerWalking
{
    exec function ActivateInventoryItem(class InvItem)              { Global.ActivateInventoryItem(InvItem); }
    exec function ActivateItem()                                    { Global.ActivateItem(); }
    exec function ActorState(class<actor> aClass, name statename)   { Global.ActorState(aClass, statename); }
    exec function AddBots(int N)                                    { Global.AddBots(N); }
    exec function Admin(string CommandLine)                         { Global.Admin(CommandLine); }
    exec function AdminLogin( string Password )                     { Global.AdminLogin(Password); }
    exec function AdminLogout()                                     { Global.AdminLogout(); }
    exec function AltFire( optional float F )                       { Global.AltFire(F); }
    exec function AlwaysMouseLook( Bool B )                         { Global.AlwaysMouseLook(B); }
    exec function Amphibious()                                      { Global.Amphibious(); }
    exec function Bug(string Msg)                                   { Global.Bug(Msg); }
    exec function CallForHelp()                                     { Global.CallForHelp(); }
    exec function CauseEvent( name N )                              { Global.CauseEvent(N); }
    //exec function ChangeCrosshair()                                   { Global.ChangeCrosshair(); }
    //exec function ChangeHud()                                       { Global.ChangeHud(); }
    exec function CheatPlease()                                     { Global.CheatPlease(); }
    exec function CheatView( class<actor> aClass )                  { Global.CheatView(aClass); }
    exec function ClearProgressMessages()                           { Global.ClearProgressMessages(); }
    exec function DebugCommand( string text )                       { Global.DebugCommand(text); }
    exec function DebugContinue()                                   { Global.DebugContinue(); }
    exec function FeignDeath()                                      { Global.FeignDeath(); }
    exec function Fire( optional float F )                          { Global.Fire(F); }
    exec function Fly()                                             { Global.Fly(); }
    exec function FOV(float F)                                      { Global.FOV(F); }
    exec function FunctionKey( byte Num )                           { Global.FunctionKey(Num); }
    exec function GetWeapon(class<Weapon> NewWeaponClass )          { Global.GetWeapon(NewWeaponClass); }
    exec function Ghost()                                           { Global.Ghost(); }
    exec function God()                                             { Global.God(); }
    exec function Grab()                                            { Global.Grab(); }
    exec function InvertMouse( bool B )                             { Global.InvertMouse(B); }
    exec function Invisible(bool B)                                 { Global.Invisible(B); }
    exec function Jump( optional float F )                          { Global.Jump(F); }
    exec function Kick( string S )                                  { Global.Kick(S); }
    exec function KickBan( string S )                               { Global.KickBan(S); }
    exec function KillAll(class<actor> aClass)                      { Global.KillAll(aClass); }
    exec function KillPawns()                                       { Global.KillPawns(); }
    exec function Loc()                                             { Global.Loc(); }
    exec function LocalTravel( string URL )                         { Global.LocalTravel(URL); }
    exec function Mutate(string MutateString)                       { Global.Mutate(MutateString); }
    exec function Name( coerce string S )                           { Global.Name(S); }
    exec function NeverSwitchOnPickup( bool B )                     { Global.NeverSwitchOnPickup(B); }
    exec function NextWeapon()                                      { Global.NextWeapon(); }
    exec function Pause()                                           { Global.Pause(); }
    exec function Ping()                                            { Global.Ping(); }
    exec function PlayerList()                                      { Global.PlayerList(); }
    exec function PlayersOnly()                                     { Global.PlayersOnly(); }
    exec function PrevItem()                                        { Global.PrevItem(); }
    exec function PrevWeapon()                                      { Global.PrevWeapon(); }
    exec function Profile()                                         { Global.Profile(); }
    exec function QuickLoad()                                       { Global.QuickLoad(); }
    exec function QuickSave()                                       { Global.QuickSave(); }
    exec function RememberSpot()                                    { Global.RememberSpot(); }
    exec function RestartLevel()                                    { Global.RestartLevel(); }
    exec function RuleList()                                        { Global.RuleList(); }
    exec function Say( string Msg )                                 { Global.Say(Msg); }
    exec function SetAutoAim( float F )                             { Global.SetAutoAim(F); }
    exec function SetBob(float F)                                   { Global.SetBob(F); }
    exec function SetDesiredFOV(float F)                            { Global.SetDesiredFOV(F); }
    exec function SetDodgeClickTime( float F )                      { Global.SetDodgeClickTime(F); }
    exec function SetFriction( float F )                            { Global.SetFriction(F); }
    exec function SetJumpZ( float F )                               { Global.SetJumpZ(F); }
    exec function SetMaxMouseSmoothing( bool B )                    { Global.SetMaxMouseSmoothing(B); }
    exec function SetMouseSmoothThreshold( float F )                { Global.SetMouseSmoothThreshold(F); }
    exec function SetName( coerce string S )                        { Global.SetName(S); }
    exec function SetProgressColor( color C, int Index )            { Global.SetProgressColor(C, Index); }
    exec function SetProgressMessage( string S, int Index )         { Global.SetProgressMessage(S, Index); }
    exec function SetProgressTime( float T )                        { Global.SetProgressTime(T); }
    exec function SetSensitivity(float F)                           { Global.SetSensitivity(F); }
    exec function SetSpeed( float F )                               { Global.SetSpeed(F); }
    exec function SetViewFlash(bool B)                              { Global.SetViewFlash(B); }
    exec function SetWeaponStay( bool B)                            { Global.SetWeaponStay(B); }
    exec function ShowInventory()                                   { Global.ShowInventory(); }
    exec function ShowLoadMenu()                                    { Global.ShowLoadMenu(); }
    exec function ShowMenu()                                        { Global.ShowMenu(); }
    exec function ShowPath()                                        { Global.ShowPath(); }
    exec function ShowScores()                                      { Global.ShowScores(); }
    exec function ShowSpecialMenu( string ClassName )               { Global.ShowSpecialMenu(ClassName); }
    exec function ShowTags(optional string cmdline)                 { Global.ShowTags(cmdline); }
    exec function ShutUp()                                          { Global.ShutUp(); }
    exec function SloMo( float T )                                  { Global.SloMo(T); }
    exec function SnapView( bool B )                                { Global.SnapView(B); }
    exec function Speech( int Type, int Index, int Callsign )       { Global.Speech(Type, Index, Callsign); }
    exec function SShot()                                           { Global.SShot(); }
    exec function StairLook( bool B )                               { Global.StairLook(B); }
    exec function Suicide()                                         { Global.Suicide(); }
    exec function SwitchCoopLevel( string URL )                     { Global.SwitchCoopLevel(URL); }
    exec function SwitchLevel( string URL )                         { Global.SwitchLevel(URL); }
    exec function bool SwitchToBestWeapon()                         { Global.SwitchToBestWeapon(); }
    exec function Team( int N )                                     { Global.Team(N); }
    exec function TeamSay( string Msg )                             { Global.TeamSay(Msg); }
    exec function Tele(vector newLoc)                               { Global.Tele(newLoc); }
    exec function ToggleRuneHUD()                                   { Global.ToggleRuneHUD(); }
    exec function ViewPlayer( string S )                            { Global.ViewPlayer(S); }
    exec function ViewPlayerNum(optional int num)                   { Global.ViewPlayerNum(num); }
    exec function ViewSelf()                                        { Global.ViewSelf(); }
    exec function Walk()                                            { Global.Walk(); }
    exec function Watch( string ClassName )                         { Global.Watch(ClassName); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: EdgeHanging
state EdgeHanging
{
    exec function ActivateInventoryItem(class InvItem)              { Global.ActivateInventoryItem(InvItem); }
    exec function ActivateItem()                                    { Global.ActivateItem(); }
    exec function ActorState(class<actor> aClass, name statename)   { Global.ActorState(aClass, statename); }
    exec function AddBots(int N)                                    { Global.AddBots(N); }
    exec function Admin(string CommandLine)                         { Global.Admin(CommandLine); }
    exec function AdminLogin( string Password )                     { Global.AdminLogin(Password); }
    exec function AdminLogout()                                     { Global.AdminLogout(); }
    exec function AltFire( optional float F )                       { Global.AltFire(F); }
    exec function AlwaysMouseLook( Bool B )                         { Global.AlwaysMouseLook(B); }
    exec function Amphibious()                                      { Global.Amphibious(); }
    exec function Bug(string Msg)                                   { Global.Bug(Msg); }
    exec function CallForHelp()                                     { Global.CallForHelp(); }
    exec function CauseEvent( name N )                              { Global.CauseEvent(N); }
    //exec function ChangeCrosshair()                                   { Global.ChangeCrosshair(); }
    //exec function ChangeHud()                                       { Global.ChangeHud(); }
    exec function CheatPlease()                                     { Global.CheatPlease(); }
    exec function CheatView( class<actor> aClass )                  { Global.CheatView(aClass); }
    exec function ClearProgressMessages()                           { Global.ClearProgressMessages(); }
    exec function DebugCommand( string text )                       { Global.DebugCommand(text); }
    exec function DebugContinue()                                   { Global.DebugContinue(); }
    exec function FeignDeath()                                      { Global.FeignDeath(); }
    exec function Fire( optional float F )                          { Global.Fire(F); }
    exec function Fly()                                             { Global.Fly(); }
    exec function FOV(float F)                                      { Global.FOV(F); }
    exec function FunctionKey( byte Num )                           { Global.FunctionKey(Num); }
    exec function GetWeapon(class<Weapon> NewWeaponClass )          { Global.GetWeapon(NewWeaponClass); }
    exec function Ghost()                                           { Global.Ghost(); }
    exec function God()                                             { Global.God(); }
    exec function Grab()                                            { Global.Grab(); }
    exec function InvertMouse( bool B )                             { Global.InvertMouse(B); }
    exec function Invisible(bool B)                                 { Global.Invisible(B); }
    exec function Jump( optional float F )                          { Global.Jump(F); }
    exec function Kick( string S )                                  { Global.Kick(S); }
    exec function KickBan( string S )                               { Global.KickBan(S); }
    exec function KillAll(class<actor> aClass)                      { Global.KillAll(aClass); }
    exec function KillPawns()                                       { Global.KillPawns(); }
    exec function Loc()                                             { Global.Loc(); }
    exec function LocalTravel( string URL )                         { Global.LocalTravel(URL); }
    exec function Mutate(string MutateString)                       { Global.Mutate(MutateString); }
    exec function Name( coerce string S )                           { Global.Name(S); }
    exec function NeverSwitchOnPickup( bool B )                     { Global.NeverSwitchOnPickup(B); }
    exec function NextWeapon()                                      { Global.NextWeapon(); }
    exec function Pause()                                           { Global.Pause(); }
    exec function Ping()                                            { Global.Ping(); }
    exec function PlayerList()                                      { Global.PlayerList(); }
    exec function PlayersOnly()                                     { Global.PlayersOnly(); }
    exec function PrevItem()                                        { Global.PrevItem(); }
    exec function PrevWeapon()                                      { Global.PrevWeapon(); }
    exec function Profile()                                         { Global.Profile(); }
    exec function QuickLoad()                                       { Global.QuickLoad(); }
    exec function QuickSave()                                       { Global.QuickSave(); }
    exec function RememberSpot()                                    { Global.RememberSpot(); }
    exec function RestartLevel()                                    { Global.RestartLevel(); }
    exec function RuleList()                                        { Global.RuleList(); }
    exec function Say( string Msg )                                 { Global.Say(Msg); }
    exec function SetAutoAim( float F )                             { Global.SetAutoAim(F); }
    exec function SetBob(float F)                                   { Global.SetBob(F); }
    exec function SetDesiredFOV(float F)                            { Global.SetDesiredFOV(F); }
    exec function SetDodgeClickTime( float F )                      { Global.SetDodgeClickTime(F); }
    exec function SetFriction( float F )                            { Global.SetFriction(F); }
    exec function SetJumpZ( float F )                               { Global.SetJumpZ(F); }
    exec function SetMaxMouseSmoothing( bool B )                    { Global.SetMaxMouseSmoothing(B); }
    exec function SetMouseSmoothThreshold( float F )                { Global.SetMouseSmoothThreshold(F); }
    exec function SetName( coerce string S )                        { Global.SetName(S); }
    exec function SetProgressColor( color C, int Index )            { Global.SetProgressColor(C, Index); }
    exec function SetProgressMessage( string S, int Index )         { Global.SetProgressMessage(S, Index); }
    exec function SetProgressTime( float T )                        { Global.SetProgressTime(T); }
    exec function SetSensitivity(float F)                           { Global.SetSensitivity(F); }
    exec function SetSpeed( float F )                               { Global.SetSpeed(F); }
    exec function SetViewFlash(bool B)                              { Global.SetViewFlash(B); }
    exec function SetWeaponStay( bool B)                            { Global.SetWeaponStay(B); }
    exec function ShowInventory()                                   { Global.ShowInventory(); }
    exec function ShowLoadMenu()                                    { Global.ShowLoadMenu(); }
    exec function ShowMenu()                                        { Global.ShowMenu(); }
    exec function ShowPath()                                        { Global.ShowPath(); }
    exec function ShowScores()                                      { Global.ShowScores(); }
    exec function ShowSpecialMenu( string ClassName )               { Global.ShowSpecialMenu(ClassName); }
    exec function ShowTags(optional string cmdline)                 { Global.ShowTags(cmdline); }
    exec function ShutUp()                                          { Global.ShutUp(); }
    exec function SloMo( float T )                                  { Global.SloMo(T); }
    exec function SnapView( bool B )                                { Global.SnapView(B); }
    exec function Speech( int Type, int Index, int Callsign )       { Global.Speech(Type, Index, Callsign); }
    exec function SShot()                                           { Global.SShot(); }
    exec function StairLook( bool B )                               { Global.StairLook(B); }
    exec function Suicide()                                         { Global.Suicide(); }
    exec function SwitchCoopLevel( string URL )                     { Global.SwitchCoopLevel(URL); }
    exec function SwitchLevel( string URL )                         { Global.SwitchLevel(URL); }
    exec function bool SwitchToBestWeapon()                         { Global.SwitchToBestWeapon(); }
    exec function Team( int N )                                     { Global.Team(N); }
    exec function TeamSay( string Msg )                             { Global.TeamSay(Msg); }
    exec function Tele(vector newLoc)                               { Global.Tele(newLoc); }
    exec function ToggleRuneHUD()                                   { Global.ToggleRuneHUD(); }
    exec function ViewPlayer( string S )                            { Global.ViewPlayer(S); }
    exec function ViewPlayerNum(optional int num)                   { Global.ViewPlayerNum(num); }
    exec function ViewSelf()                                        { Global.ViewSelf(); }
    exec function Walk()                                            { Global.Walk(); }
    exec function Watch( string ClassName )                         { Global.Watch(ClassName); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: FeigningDeath
state FeigningDeath
{
    exec function ActivateInventoryItem(class InvItem)              { Global.ActivateInventoryItem(InvItem); }
    exec function ActivateItem()                                    { Global.ActivateItem(); }
    exec function ActorState(class<actor> aClass, name statename)   { Global.ActorState(aClass, statename); }
    exec function AddBots(int N)                                    { Global.AddBots(N); }
    exec function Admin(string CommandLine)                         { Global.Admin(CommandLine); }
    exec function AdminLogin( string Password )                     { Global.AdminLogin(Password); }
    exec function AdminLogout()                                     { Global.AdminLogout(); }
    exec function AltFire( optional float F )                       { Global.AltFire(F); }
    exec function AlwaysMouseLook( Bool B )                         { Global.AlwaysMouseLook(B); }
    exec function Amphibious()                                      { Global.Amphibious(); }
    exec function Bug(string Msg)                                   { Global.Bug(Msg); }
    exec function CallForHelp()                                     { Global.CallForHelp(); }
    exec function CauseEvent( name N )                              { Global.CauseEvent(N); }
    //exec function ChangeCrosshair()                                   { Global.ChangeCrosshair(); }
    //exec function ChangeHud()                                       { Global.ChangeHud(); }
    exec function CheatPlease()                                     { Global.CheatPlease(); }
    exec function CheatView( class<actor> aClass )                  { Global.CheatView(aClass); }
    exec function ClearProgressMessages()                           { Global.ClearProgressMessages(); }
    exec function DebugCommand( string text )                       { Global.DebugCommand(text); }
    exec function DebugContinue()                                   { Global.DebugContinue(); }
    exec function FeignDeath()                                      { Global.FeignDeath(); }
    exec function Fire( optional float F )                          { Global.Fire(F); }
    exec function Fly()                                             { Global.Fly(); }
    exec function FOV(float F)                                      { Global.FOV(F); }
    exec function FunctionKey( byte Num )                           { Global.FunctionKey(Num); }
    exec function GetWeapon(class<Weapon> NewWeaponClass )          { Global.GetWeapon(NewWeaponClass); }
    exec function Ghost()                                           { Global.Ghost(); }
    exec function God()                                             { Global.God(); }
    exec function Grab()                                            { Global.Grab(); }
    exec function InvertMouse( bool B )                             { Global.InvertMouse(B); }
    exec function Invisible(bool B)                                 { Global.Invisible(B); }
    exec function Jump( optional float F )                          { Global.Jump(F); }
    exec function Kick( string S )                                  { Global.Kick(S); }
    exec function KickBan( string S )                               { Global.KickBan(S); }
    exec function KillAll(class<actor> aClass)                      { Global.KillAll(aClass); }
    exec function KillPawns()                                       { Global.KillPawns(); }
    exec function Loc()                                             { Global.Loc(); }
    exec function LocalTravel( string URL )                         { Global.LocalTravel(URL); }
    exec function Mutate(string MutateString)                       { Global.Mutate(MutateString); }
    exec function Name( coerce string S )                           { Global.Name(S); }
    exec function NeverSwitchOnPickup( bool B )                     { Global.NeverSwitchOnPickup(B); }
    exec function NextWeapon()                                      { Global.NextWeapon(); }
    exec function Pause()                                           { Global.Pause(); }
    exec function Ping()                                            { Global.Ping(); }
    exec function PlayerList()                                      { Global.PlayerList(); }
    exec function PlayersOnly()                                     { Global.PlayersOnly(); }
    exec function PrevItem()                                        { Global.PrevItem(); }
    exec function PrevWeapon()                                      { Global.PrevWeapon(); }
    exec function Profile()                                         { Global.Profile(); }
    exec function QuickLoad()                                       { Global.QuickLoad(); }
    exec function QuickSave()                                       { Global.QuickSave(); }
    exec function RememberSpot()                                    { Global.RememberSpot(); }
    exec function RestartLevel()                                    { Global.RestartLevel(); }
    exec function RuleList()                                        { Global.RuleList(); }
    exec function Say( string Msg )                                 { Global.Say(Msg); }
    exec function SetAutoAim( float F )                             { Global.SetAutoAim(F); }
    exec function SetBob(float F)                                   { Global.SetBob(F); }
    exec function SetDesiredFOV(float F)                            { Global.SetDesiredFOV(F); }
    exec function SetDodgeClickTime( float F )                      { Global.SetDodgeClickTime(F); }
    exec function SetFriction( float F )                            { Global.SetFriction(F); }
    exec function SetJumpZ( float F )                               { Global.SetJumpZ(F); }
    exec function SetMaxMouseSmoothing( bool B )                    { Global.SetMaxMouseSmoothing(B); }
    exec function SetMouseSmoothThreshold( float F )                { Global.SetMouseSmoothThreshold(F); }
    exec function SetName( coerce string S )                        { Global.SetName(S); }
    exec function SetProgressColor( color C, int Index )            { Global.SetProgressColor(C, Index); }
    exec function SetProgressMessage( string S, int Index )         { Global.SetProgressMessage(S, Index); }
    exec function SetProgressTime( float T )                        { Global.SetProgressTime(T); }
    exec function SetSensitivity(float F)                           { Global.SetSensitivity(F); }
    exec function SetSpeed( float F )                               { Global.SetSpeed(F); }
    exec function SetViewFlash(bool B)                              { Global.SetViewFlash(B); }
    exec function SetWeaponStay( bool B)                            { Global.SetWeaponStay(B); }
    exec function ShowInventory()                                   { Global.ShowInventory(); }
    exec function ShowLoadMenu()                                    { Global.ShowLoadMenu(); }
    exec function ShowMenu()                                        { Global.ShowMenu(); }
    exec function ShowPath()                                        { Global.ShowPath(); }
    exec function ShowScores()                                      { Global.ShowScores(); }
    exec function ShowSpecialMenu( string ClassName )               { Global.ShowSpecialMenu(ClassName); }
    exec function ShowTags(optional string cmdline)                 { Global.ShowTags(cmdline); }
    exec function ShutUp()                                          { Global.ShutUp(); }
    exec function SloMo( float T )                                  { Global.SloMo(T); }
    exec function SnapView( bool B )                                { Global.SnapView(B); }
    exec function Speech( int Type, int Index, int Callsign )       { Global.Speech(Type, Index, Callsign); }
    exec function SShot()                                           { Global.SShot(); }
    exec function StairLook( bool B )                               { Global.StairLook(B); }
    exec function Suicide()                                         { Global.Suicide(); }
    exec function SwitchCoopLevel( string URL )                     { Global.SwitchCoopLevel(URL); }
    exec function SwitchLevel( string URL )                         { Global.SwitchLevel(URL); }
    exec function bool SwitchToBestWeapon()                         { Global.SwitchToBestWeapon(); }
    exec function Team( int N )                                     { Global.Team(N); }
    exec function TeamSay( string Msg )                             { Global.TeamSay(Msg); }
    exec function Tele(vector newLoc)                               { Global.Tele(newLoc); }
    exec function ToggleRuneHUD()                                   { Global.ToggleRuneHUD(); }
    exec function ViewPlayer( string S )                            { Global.ViewPlayer(S); }
    exec function ViewPlayerNum(optional int num)                   { Global.ViewPlayerNum(num); }
    exec function ViewSelf()                                        { Global.ViewSelf(); }
    exec function Walk()                                            { Global.Walk(); }
    exec function Watch( string ClassName )                         { Global.Watch(ClassName); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: PlayerSwimming
state PlayerSwimming
{
    exec function ActivateInventoryItem(class InvItem)              { Global.ActivateInventoryItem(InvItem); }
    exec function ActivateItem()                                    { Global.ActivateItem(); }
    exec function ActorState(class<actor> aClass, name statename)   { Global.ActorState(aClass, statename); }
    exec function AddBots(int N)                                    { Global.AddBots(N); }
    exec function Admin(string CommandLine)                         { Global.Admin(CommandLine); }
    exec function AdminLogin( string Password )                     { Global.AdminLogin(Password); }
    exec function AdminLogout()                                     { Global.AdminLogout(); }
    exec function AltFire( optional float F )                       { Global.AltFire(F); }
    exec function AlwaysMouseLook( Bool B )                         { Global.AlwaysMouseLook(B); }
    exec function Amphibious()                                      { Global.Amphibious(); }
    exec function Bug(string Msg)                                   { Global.Bug(Msg); }
    exec function CallForHelp()                                     { Global.CallForHelp(); }
    exec function CauseEvent( name N )                              { Global.CauseEvent(N); }
    //exec function ChangeCrosshair()                                   { Global.ChangeCrosshair(); }
    //exec function ChangeHud()                                       { Global.ChangeHud(); }
    exec function CheatPlease()                                     { Global.CheatPlease(); }
    exec function CheatView( class<actor> aClass )                  { Global.CheatView(aClass); }
    exec function ClearProgressMessages()                           { Global.ClearProgressMessages(); }
    exec function DebugCommand( string text )                       { Global.DebugCommand(text); }
    exec function DebugContinue()                                   { Global.DebugContinue(); }
    exec function FeignDeath()                                      { Global.FeignDeath(); }
    exec function Fire( optional float F )                          { Global.Fire(F); }
    exec function Fly()                                             { Global.Fly(); }
    exec function FOV(float F)                                      { Global.FOV(F); }
    exec function FunctionKey( byte Num )                           { Global.FunctionKey(Num); }
    exec function GetWeapon(class<Weapon> NewWeaponClass )          { Global.GetWeapon(NewWeaponClass); }
    exec function Ghost()                                           { Global.Ghost(); }
    exec function God()                                             { Global.God(); }
    exec function Grab()                                            { Global.Grab(); }
    exec function InvertMouse( bool B )                             { Global.InvertMouse(B); }
    exec function Invisible(bool B)                                 { Global.Invisible(B); }
    exec function Jump( optional float F )                          { Global.Jump(F); }
    exec function Kick( string S )                                  { Global.Kick(S); }
    exec function KickBan( string S )                               { Global.KickBan(S); }
    exec function KillAll(class<actor> aClass)                      { Global.KillAll(aClass); }
    exec function KillPawns()                                       { Global.KillPawns(); }
    exec function Loc()                                             { Global.Loc(); }
    exec function LocalTravel( string URL )                         { Global.LocalTravel(URL); }
    exec function Mutate(string MutateString)                       { Global.Mutate(MutateString); }
    exec function Name( coerce string S )                           { Global.Name(S); }
    exec function NeverSwitchOnPickup( bool B )                     { Global.NeverSwitchOnPickup(B); }
    exec function NextWeapon()                                      { Global.NextWeapon(); }
    exec function Pause()                                           { Global.Pause(); }
    exec function Ping()                                            { Global.Ping(); }
    exec function PlayerList()                                      { Global.PlayerList(); }
    exec function PlayersOnly()                                     { Global.PlayersOnly(); }
    exec function PrevItem()                                        { Global.PrevItem(); }
    exec function PrevWeapon()                                      { Global.PrevWeapon(); }
    exec function Profile()                                         { Global.Profile(); }
    exec function QuickLoad()                                       { Global.QuickLoad(); }
    exec function QuickSave()                                       { Global.QuickSave(); }
    exec function RememberSpot()                                    { Global.RememberSpot(); }
    exec function RestartLevel()                                    { Global.RestartLevel(); }
    exec function RuleList()                                        { Global.RuleList(); }
    exec function Say( string Msg )                                 { Global.Say(Msg); }
    exec function SetAutoAim( float F )                             { Global.SetAutoAim(F); }
    exec function SetBob(float F)                                   { Global.SetBob(F); }
    exec function SetDesiredFOV(float F)                            { Global.SetDesiredFOV(F); }
    exec function SetDodgeClickTime( float F )                      { Global.SetDodgeClickTime(F); }
    exec function SetFriction( float F )                            { Global.SetFriction(F); }
    exec function SetJumpZ( float F )                               { Global.SetJumpZ(F); }
    exec function SetMaxMouseSmoothing( bool B )                    { Global.SetMaxMouseSmoothing(B); }
    exec function SetMouseSmoothThreshold( float F )                { Global.SetMouseSmoothThreshold(F); }
    exec function SetName( coerce string S )                        { Global.SetName(S); }
    exec function SetProgressColor( color C, int Index )            { Global.SetProgressColor(C, Index); }
    exec function SetProgressMessage( string S, int Index )         { Global.SetProgressMessage(S, Index); }
    exec function SetProgressTime( float T )                        { Global.SetProgressTime(T); }
    exec function SetSensitivity(float F)                           { Global.SetSensitivity(F); }
    exec function SetSpeed( float F )                               { Global.SetSpeed(F); }
    exec function SetViewFlash(bool B)                              { Global.SetViewFlash(B); }
    exec function SetWeaponStay( bool B)                            { Global.SetWeaponStay(B); }
    exec function ShowInventory()                                   { Global.ShowInventory(); }
    exec function ShowLoadMenu()                                    { Global.ShowLoadMenu(); }
    exec function ShowMenu()                                        { Global.ShowMenu(); }
    exec function ShowPath()                                        { Global.ShowPath(); }
    exec function ShowScores()                                      { Global.ShowScores(); }
    exec function ShowSpecialMenu( string ClassName )               { Global.ShowSpecialMenu(ClassName); }
    exec function ShowTags(optional string cmdline)                 { Global.ShowTags(cmdline); }
    exec function ShutUp()                                          { Global.ShutUp(); }
    exec function SloMo( float T )                                  { Global.SloMo(T); }
    exec function SnapView( bool B )                                { Global.SnapView(B); }
    exec function Speech( int Type, int Index, int Callsign )       { Global.Speech(Type, Index, Callsign); }
    exec function SShot()                                           { Global.SShot(); }
    exec function StairLook( bool B )                               { Global.StairLook(B); }
    exec function Suicide()                                         { Global.Suicide(); }
    exec function SwitchCoopLevel( string URL )                     { Global.SwitchCoopLevel(URL); }
    exec function SwitchLevel( string URL )                         { Global.SwitchLevel(URL); }
    exec function bool SwitchToBestWeapon()                         { Global.SwitchToBestWeapon(); }
    exec function Team( int N )                                     { Global.Team(N); }
    exec function TeamSay( string Msg )                             { Global.TeamSay(Msg); }
    exec function Tele(vector newLoc)                               { Global.Tele(newLoc); }
    exec function ToggleRuneHUD()                                   { Global.ToggleRuneHUD(); }
    exec function ViewPlayer( string S )                            { Global.ViewPlayer(S); }
    exec function ViewPlayerNum(optional int num)                   { Global.ViewPlayerNum(num); }
    exec function ViewSelf()                                        { Global.ViewSelf(); }
    exec function Walk()                                            { Global.Walk(); }
    exec function Watch( string ClassName )                         { Global.Watch(ClassName); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: PlayerFlying
state PlayerFlying
{
    exec function ActivateInventoryItem(class InvItem)              { Global.ActivateInventoryItem(InvItem); }
    exec function ActivateItem()                                    { Global.ActivateItem(); }
    exec function ActorState(class<actor> aClass, name statename)   { Global.ActorState(aClass, statename); }
    exec function AddBots(int N)                                    { Global.AddBots(N); }
    exec function Admin(string CommandLine)                         { Global.Admin(CommandLine); }
    exec function AdminLogin( string Password )                     { Global.AdminLogin(Password); }
    exec function AdminLogout()                                     { Global.AdminLogout(); }
    exec function AltFire( optional float F )                       { Global.AltFire(F); }
    exec function AlwaysMouseLook( Bool B )                         { Global.AlwaysMouseLook(B); }
    exec function Amphibious()                                      { Global.Amphibious(); }
    exec function Bug(string Msg)                                   { Global.Bug(Msg); }
    exec function CallForHelp()                                     { Global.CallForHelp(); }
    exec function CauseEvent( name N )                              { Global.CauseEvent(N); }
    //exec function ChangeCrosshair()                                   { Global.ChangeCrosshair(); }
    //exec function ChangeHud()                                       { Global.ChangeHud(); }
    exec function CheatPlease()                                     { Global.CheatPlease(); }
    exec function CheatView( class<actor> aClass )                  { Global.CheatView(aClass); }
    exec function ClearProgressMessages()                           { Global.ClearProgressMessages(); }
    exec function DebugCommand( string text )                       { Global.DebugCommand(text); }
    exec function DebugContinue()                                   { Global.DebugContinue(); }
    exec function FeignDeath()                                      { Global.FeignDeath(); }
    exec function Fire( optional float F )                          { Global.Fire(F); }
    exec function Fly()                                             { Global.Fly(); }
    exec function FOV(float F)                                      { Global.FOV(F); }
    exec function FunctionKey( byte Num )                           { Global.FunctionKey(Num); }
    exec function GetWeapon(class<Weapon> NewWeaponClass )          { Global.GetWeapon(NewWeaponClass); }
    exec function Ghost()                                           { Global.Ghost(); }
    exec function God()                                             { Global.God(); }
    exec function Grab()                                            { Global.Grab(); }
    exec function InvertMouse( bool B )                             { Global.InvertMouse(B); }
    exec function Invisible(bool B)                                 { Global.Invisible(B); }
    exec function Jump( optional float F )                          { Global.Jump(F); }
    exec function Kick( string S )                                  { Global.Kick(S); }
    exec function KickBan( string S )                               { Global.KickBan(S); }
    exec function KillAll(class<actor> aClass)                      { Global.KillAll(aClass); }
    exec function KillPawns()                                       { Global.KillPawns(); }
    exec function Loc()                                             { Global.Loc(); }
    exec function LocalTravel( string URL )                         { Global.LocalTravel(URL); }
    exec function Mutate(string MutateString)                       { Global.Mutate(MutateString); }
    exec function Name( coerce string S )                           { Global.Name(S); }
    exec function NeverSwitchOnPickup( bool B )                     { Global.NeverSwitchOnPickup(B); }
    exec function NextWeapon()                                      { Global.NextWeapon(); }
    exec function Pause()                                           { Global.Pause(); }
    exec function Ping()                                            { Global.Ping(); }
    exec function PlayerList()                                      { Global.PlayerList(); }
    exec function PlayersOnly()                                     { Global.PlayersOnly(); }
    exec function PrevItem()                                        { Global.PrevItem(); }
    exec function PrevWeapon()                                      { Global.PrevWeapon(); }
    exec function Profile()                                         { Global.Profile(); }
    exec function QuickLoad()                                       { Global.QuickLoad(); }
    exec function QuickSave()                                       { Global.QuickSave(); }
    exec function RememberSpot()                                    { Global.RememberSpot(); }
    exec function RestartLevel()                                    { Global.RestartLevel(); }
    exec function RuleList()                                        { Global.RuleList(); }
    exec function Say( string Msg )                                 { Global.Say(Msg); }
    exec function SetAutoAim( float F )                             { Global.SetAutoAim(F); }
    exec function SetBob(float F)                                   { Global.SetBob(F); }
    exec function SetDesiredFOV(float F)                            { Global.SetDesiredFOV(F); }
    exec function SetDodgeClickTime( float F )                      { Global.SetDodgeClickTime(F); }
    exec function SetFriction( float F )                            { Global.SetFriction(F); }
    exec function SetJumpZ( float F )                               { Global.SetJumpZ(F); }
    exec function SetMaxMouseSmoothing( bool B )                    { Global.SetMaxMouseSmoothing(B); }
    exec function SetMouseSmoothThreshold( float F )                { Global.SetMouseSmoothThreshold(F); }
    exec function SetName( coerce string S )                        { Global.SetName(S); }
    exec function SetProgressColor( color C, int Index )            { Global.SetProgressColor(C, Index); }
    exec function SetProgressMessage( string S, int Index )         { Global.SetProgressMessage(S, Index); }
    exec function SetProgressTime( float T )                        { Global.SetProgressTime(T); }
    exec function SetSensitivity(float F)                           { Global.SetSensitivity(F); }
    exec function SetSpeed( float F )                               { Global.SetSpeed(F); }
    exec function SetViewFlash(bool B)                              { Global.SetViewFlash(B); }
    exec function SetWeaponStay( bool B)                            { Global.SetWeaponStay(B); }
    exec function ShowInventory()                                   { Global.ShowInventory(); }
    exec function ShowLoadMenu()                                    { Global.ShowLoadMenu(); }
    exec function ShowMenu()                                        { Global.ShowMenu(); }
    exec function ShowPath()                                        { Global.ShowPath(); }
    exec function ShowScores()                                      { Global.ShowScores(); }
    exec function ShowSpecialMenu( string ClassName )               { Global.ShowSpecialMenu(ClassName); }
    exec function ShowTags(optional string cmdline)                 { Global.ShowTags(cmdline); }
    exec function ShutUp()                                          { Global.ShutUp(); }
    exec function SloMo( float T )                                  { Global.SloMo(T); }
    exec function SnapView( bool B )                                { Global.SnapView(B); }
    exec function Speech( int Type, int Index, int Callsign )       { Global.Speech(Type, Index, Callsign); }
    exec function SShot()                                           { Global.SShot(); }
    exec function StairLook( bool B )                               { Global.StairLook(B); }
    exec function Suicide()                                         { Global.Suicide(); }
    exec function SwitchCoopLevel( string URL )                     { Global.SwitchCoopLevel(URL); }
    exec function SwitchLevel( string URL )                         { Global.SwitchLevel(URL); }
    exec function bool SwitchToBestWeapon()                         { Global.SwitchToBestWeapon(); }
    exec function Team( int N )                                     { Global.Team(N); }
    exec function TeamSay( string Msg )                             { Global.TeamSay(Msg); }
    exec function Tele(vector newLoc)                               { Global.Tele(newLoc); }
    exec function ToggleRuneHUD()                                   { Global.ToggleRuneHUD(); }
    exec function ViewPlayer( string S )                            { Global.ViewPlayer(S); }
    exec function ViewPlayerNum(optional int num)                   { Global.ViewPlayerNum(num); }
    exec function ViewSelf()                                        { Global.ViewSelf(); }
    exec function Walk()                                            { Global.Walk(); }
    exec function Watch( string ClassName )                         { Global.Watch(ClassName); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: CheatFlying
state CheatFlying
{
    exec function ActivateInventoryItem(class InvItem)              { Global.ActivateInventoryItem(InvItem); }
    exec function ActivateItem()                                    { Global.ActivateItem(); }
    exec function ActorState(class<actor> aClass, name statename)   { Global.ActorState(aClass, statename); }
    exec function AddBots(int N)                                    { Global.AddBots(N); }
    exec function Admin(string CommandLine)                         { Global.Admin(CommandLine); }
    exec function AdminLogin( string Password )                     { Global.AdminLogin(Password); }
    exec function AdminLogout()                                     { Global.AdminLogout(); }
    exec function AltFire( optional float F )                       { Global.AltFire(F); }
    exec function AlwaysMouseLook( Bool B )                         { Global.AlwaysMouseLook(B); }
    exec function Amphibious()                                      { Global.Amphibious(); }
    exec function Bug(string Msg)                                   { Global.Bug(Msg); }
    exec function CallForHelp()                                     { Global.CallForHelp(); }
    exec function CauseEvent( name N )                              { Global.CauseEvent(N); }
    //exec function ChangeCrosshair()                                   { Global.ChangeCrosshair(); }
    //exec function ChangeHud()                                       { Global.ChangeHud(); }
    exec function CheatPlease()                                     { Global.CheatPlease(); }
    exec function CheatView( class<actor> aClass )                  { Global.CheatView(aClass); }
    exec function ClearProgressMessages()                           { Global.ClearProgressMessages(); }
    exec function DebugCommand( string text )                       { Global.DebugCommand(text); }
    exec function DebugContinue()                                   { Global.DebugContinue(); }
    exec function FeignDeath()                                      { Global.FeignDeath(); }
    exec function Fire( optional float F )                          { Global.Fire(F); }
    exec function Fly()                                             { Global.Fly(); }
    exec function FOV(float F)                                      { Global.FOV(F); }
    exec function FunctionKey( byte Num )                           { Global.FunctionKey(Num); }
    exec function GetWeapon(class<Weapon> NewWeaponClass )          { Global.GetWeapon(NewWeaponClass); }
    exec function Ghost()                                           { Global.Ghost(); }
    exec function God()                                             { Global.God(); }
    exec function Grab()                                            { Global.Grab(); }
    exec function InvertMouse( bool B )                             { Global.InvertMouse(B); }
    exec function Invisible(bool B)                                 { Global.Invisible(B); }
    exec function Jump( optional float F )                          { Global.Jump(F); }
    exec function Kick( string S )                                  { Global.Kick(S); }
    exec function KickBan( string S )                               { Global.KickBan(S); }
    exec function KillAll(class<actor> aClass)                      { Global.KillAll(aClass); }
    exec function KillPawns()                                       { Global.KillPawns(); }
    exec function Loc()                                             { Global.Loc(); }
    exec function LocalTravel( string URL )                         { Global.LocalTravel(URL); }
    exec function Mutate(string MutateString)                       { Global.Mutate(MutateString); }
    exec function Name( coerce string S )                           { Global.Name(S); }
    exec function NeverSwitchOnPickup( bool B )                     { Global.NeverSwitchOnPickup(B); }
    exec function NextWeapon()                                      { Global.NextWeapon(); }
    exec function Pause()                                           { Global.Pause(); }
    exec function Ping()                                            { Global.Ping(); }
    exec function PlayerList()                                      { Global.PlayerList(); }
    exec function PlayersOnly()                                     { Global.PlayersOnly(); }
    exec function PrevItem()                                        { Global.PrevItem(); }
    exec function PrevWeapon()                                      { Global.PrevWeapon(); }
    exec function Profile()                                         { Global.Profile(); }
    exec function QuickLoad()                                       { Global.QuickLoad(); }
    exec function QuickSave()                                       { Global.QuickSave(); }
    exec function RememberSpot()                                    { Global.RememberSpot(); }
    exec function RestartLevel()                                    { Global.RestartLevel(); }
    exec function RuleList()                                        { Global.RuleList(); }
    exec function Say( string Msg )                                 { Global.Say(Msg); }
    exec function SetAutoAim( float F )                             { Global.SetAutoAim(F); }
    exec function SetBob(float F)                                   { Global.SetBob(F); }
    exec function SetDesiredFOV(float F)                            { Global.SetDesiredFOV(F); }
    exec function SetDodgeClickTime( float F )                      { Global.SetDodgeClickTime(F); }
    exec function SetFriction( float F )                            { Global.SetFriction(F); }
    exec function SetJumpZ( float F )                               { Global.SetJumpZ(F); }
    exec function SetMaxMouseSmoothing( bool B )                    { Global.SetMaxMouseSmoothing(B); }
    exec function SetMouseSmoothThreshold( float F )                { Global.SetMouseSmoothThreshold(F); }
    exec function SetName( coerce string S )                        { Global.SetName(S); }
    exec function SetProgressColor( color C, int Index )            { Global.SetProgressColor(C, Index); }
    exec function SetProgressMessage( string S, int Index )         { Global.SetProgressMessage(S, Index); }
    exec function SetProgressTime( float T )                        { Global.SetProgressTime(T); }
    exec function SetSensitivity(float F)                           { Global.SetSensitivity(F); }
    exec function SetSpeed( float F )                               { Global.SetSpeed(F); }
    exec function SetViewFlash(bool B)                              { Global.SetViewFlash(B); }
    exec function SetWeaponStay( bool B)                            { Global.SetWeaponStay(B); }
    exec function ShowInventory()                                   { Global.ShowInventory(); }
    exec function ShowLoadMenu()                                    { Global.ShowLoadMenu(); }
    exec function ShowMenu()                                        { Global.ShowMenu(); }
    exec function ShowPath()                                        { Global.ShowPath(); }
    exec function ShowScores()                                      { Global.ShowScores(); }
    exec function ShowSpecialMenu( string ClassName )               { Global.ShowSpecialMenu(ClassName); }
    exec function ShowTags(optional string cmdline)                 { Global.ShowTags(cmdline); }
    exec function ShutUp()                                          { Global.ShutUp(); }
    exec function SloMo( float T )                                  { Global.SloMo(T); }
    exec function SnapView( bool B )                                { Global.SnapView(B); }
    exec function Speech( int Type, int Index, int Callsign )       { Global.Speech(Type, Index, Callsign); }
    exec function SShot()                                           { Global.SShot(); }
    exec function StairLook( bool B )                               { Global.StairLook(B); }
    exec function Suicide()                                         { Global.Suicide(); }
    exec function SwitchCoopLevel( string URL )                     { Global.SwitchCoopLevel(URL); }
    exec function SwitchLevel( string URL )                         { Global.SwitchLevel(URL); }
    exec function bool SwitchToBestWeapon()                         { Global.SwitchToBestWeapon(); }
    exec function Team( int N )                                     { Global.Team(N); }
    exec function TeamSay( string Msg )                             { Global.TeamSay(Msg); }
    exec function Tele(vector newLoc)                               { Global.Tele(newLoc); }
    exec function ToggleRuneHUD()                                   { Global.ToggleRuneHUD(); }
    exec function ViewPlayer( string S )                            { Global.ViewPlayer(S); }
    exec function ViewPlayerNum(optional int num)                   { Global.ViewPlayerNum(num); }
    exec function ViewSelf()                                        { Global.ViewSelf(); }
    exec function Walk()                                            { Global.Walk(); }
    exec function Watch( string ClassName )                         { Global.Watch(ClassName); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: PlayerWaiting
state PlayerWaiting
{
    exec function ActivateInventoryItem(class InvItem)              { Global.ActivateInventoryItem(InvItem); }
    exec function ActivateItem()                                    { Global.ActivateItem(); }
    exec function ActorState(class<actor> aClass, name statename)   { Global.ActorState(aClass, statename); }
    exec function AddBots(int N)                                    { Global.AddBots(N); }
    exec function Admin(string CommandLine)                         { Global.Admin(CommandLine); }
    exec function AdminLogin( string Password )                     { Global.AdminLogin(Password); }
    exec function AdminLogout()                                     { Global.AdminLogout(); }
    exec function AltFire( optional float F )                       { Global.AltFire(F); }
    exec function AlwaysMouseLook( Bool B )                         { Global.AlwaysMouseLook(B); }
    exec function Amphibious()                                      { Global.Amphibious(); }
    exec function Bug(string Msg)                                   { Global.Bug(Msg); }
    exec function CallForHelp()                                     { Global.CallForHelp(); }
    exec function CauseEvent( name N )                              { Global.CauseEvent(N); }
    //exec function ChangeCrosshair()                                   { Global.ChangeCrosshair(); }
    //exec function ChangeHud()                                       { Global.ChangeHud(); }
    exec function CheatPlease()                                     { Global.CheatPlease(); }
    exec function CheatView( class<actor> aClass )                  { Global.CheatView(aClass); }
    exec function ClearProgressMessages()                           { Global.ClearProgressMessages(); }
    exec function DebugCommand( string text )                       { Global.DebugCommand(text); }
    exec function DebugContinue()                                   { Global.DebugContinue(); }
    exec function FeignDeath()                                      { Global.FeignDeath(); }
    exec function Fire( optional float F )                          { Global.Fire(F); }
    exec function Fly()                                             { Global.Fly(); }
    exec function FOV(float F)                                      { Global.FOV(F); }
    exec function FunctionKey( byte Num )                           { Global.FunctionKey(Num); }
    exec function GetWeapon(class<Weapon> NewWeaponClass )          { Global.GetWeapon(NewWeaponClass); }
    exec function Ghost()                                           { Global.Ghost(); }
    exec function God()                                             { Global.God(); }
    exec function Grab()                                            { Global.Grab(); }
    exec function InvertMouse( bool B )                             { Global.InvertMouse(B); }
    exec function Invisible(bool B)                                 { Global.Invisible(B); }
    exec function Jump( optional float F )                          { Global.Jump(F); }
    exec function Kick( string S )                                  { Global.Kick(S); }
    exec function KickBan( string S )                               { Global.KickBan(S); }
    exec function KillAll(class<actor> aClass)                      { Global.KillAll(aClass); }
    exec function KillPawns()                                       { Global.KillPawns(); }
    exec function Loc()                                             { Global.Loc(); }
    exec function LocalTravel( string URL )                         { Global.LocalTravel(URL); }
    exec function Mutate(string MutateString)                       { Global.Mutate(MutateString); }
    exec function Name( coerce string S )                           { Global.Name(S); }
    exec function NeverSwitchOnPickup( bool B )                     { Global.NeverSwitchOnPickup(B); }
    exec function NextWeapon()                                      { Global.NextWeapon(); }
    exec function Pause()                                           { Global.Pause(); }
    exec function Ping()                                            { Global.Ping(); }
    exec function PlayerList()                                      { Global.PlayerList(); }
    exec function PlayersOnly()                                     { Global.PlayersOnly(); }
    exec function PrevItem()                                        { Global.PrevItem(); }
    exec function PrevWeapon()                                      { Global.PrevWeapon(); }
    exec function Profile()                                         { Global.Profile(); }
    exec function QuickLoad()                                       { Global.QuickLoad(); }
    exec function QuickSave()                                       { Global.QuickSave(); }
    exec function RememberSpot()                                    { Global.RememberSpot(); }
    exec function RestartLevel()                                    { Global.RestartLevel(); }
    exec function RuleList()                                        { Global.RuleList(); }
    exec function Say( string Msg )                                 { Global.Say(Msg); }
    exec function SetAutoAim( float F )                             { Global.SetAutoAim(F); }
    exec function SetBob(float F)                                   { Global.SetBob(F); }
    exec function SetDesiredFOV(float F)                            { Global.SetDesiredFOV(F); }
    exec function SetDodgeClickTime( float F )                      { Global.SetDodgeClickTime(F); }
    exec function SetFriction( float F )                            { Global.SetFriction(F); }
    exec function SetJumpZ( float F )                               { Global.SetJumpZ(F); }
    exec function SetMaxMouseSmoothing( bool B )                    { Global.SetMaxMouseSmoothing(B); }
    exec function SetMouseSmoothThreshold( float F )                { Global.SetMouseSmoothThreshold(F); }
    exec function SetName( coerce string S )                        { Global.SetName(S); }
    exec function SetProgressColor( color C, int Index )            { Global.SetProgressColor(C, Index); }
    exec function SetProgressMessage( string S, int Index )         { Global.SetProgressMessage(S, Index); }
    exec function SetProgressTime( float T )                        { Global.SetProgressTime(T); }
    exec function SetSensitivity(float F)                           { Global.SetSensitivity(F); }
    exec function SetSpeed( float F )                               { Global.SetSpeed(F); }
    exec function SetViewFlash(bool B)                              { Global.SetViewFlash(B); }
    exec function SetWeaponStay( bool B)                            { Global.SetWeaponStay(B); }
    exec function ShowInventory()                                   { Global.ShowInventory(); }
    exec function ShowLoadMenu()                                    { Global.ShowLoadMenu(); }
    exec function ShowMenu()                                        { Global.ShowMenu(); }
    exec function ShowPath()                                        { Global.ShowPath(); }
    exec function ShowScores()                                      { Global.ShowScores(); }
    exec function ShowSpecialMenu( string ClassName )               { Global.ShowSpecialMenu(ClassName); }
    exec function ShowTags(optional string cmdline)                 { Global.ShowTags(cmdline); }
    exec function ShutUp()                                          { Global.ShutUp(); }
    exec function SloMo( float T )                                  { Global.SloMo(T); }
    exec function SnapView( bool B )                                { Global.SnapView(B); }
    exec function Speech( int Type, int Index, int Callsign )       { Global.Speech(Type, Index, Callsign); }
    exec function SShot()                                           { Global.SShot(); }
    exec function StairLook( bool B )                               { Global.StairLook(B); }
    exec function Suicide()                                         { Global.Suicide(); }
    exec function SwitchCoopLevel( string URL )                     { Global.SwitchCoopLevel(URL); }
    exec function SwitchLevel( string URL )                         { Global.SwitchLevel(URL); }
    exec function bool SwitchToBestWeapon()                         { Global.SwitchToBestWeapon(); }
    exec function Team( int N )                                     { Global.Team(N); }
    exec function TeamSay( string Msg )                             { Global.TeamSay(Msg); }
    exec function Tele(vector newLoc)                               { Global.Tele(newLoc); }
    exec function ToggleRuneHUD()                                   { Global.ToggleRuneHUD(); }
    exec function ViewPlayer( string S )                            { Global.ViewPlayer(S); }
    exec function ViewPlayerNum(optional int num)                   { Global.ViewPlayerNum(num); }
    exec function ViewSelf()                                        { Global.ViewSelf(); }
    exec function Walk()                                            { Global.Walk(); }
    exec function Watch( string ClassName )                         { Global.Watch(ClassName); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: PlayerSpectating
state PlayerSpectating
{
    exec function ActivateInventoryItem(class InvItem)              { Global.ActivateInventoryItem(InvItem); }
    exec function ActivateItem()                                    { Global.ActivateItem(); }
    exec function ActorState(class<actor> aClass, name statename)   { Global.ActorState(aClass, statename); }
    exec function AddBots(int N)                                    { Global.AddBots(N); }
    exec function Admin(string CommandLine)                         { Global.Admin(CommandLine); }
    exec function AdminLogin( string Password )                     { Global.AdminLogin(Password); }
    exec function AdminLogout()                                     { Global.AdminLogout(); }
    exec function AltFire( optional float F )                       { Global.AltFire(F); }
    exec function AlwaysMouseLook( Bool B )                         { Global.AlwaysMouseLook(B); }
    exec function Amphibious()                                      { Global.Amphibious(); }
    exec function Bug(string Msg)                                   { Global.Bug(Msg); }
    exec function CallForHelp()                                     { Global.CallForHelp(); }
    exec function CauseEvent( name N )                              { Global.CauseEvent(N); }
    //exec function ChangeCrosshair()                                   { Global.ChangeCrosshair(); }
    //exec function ChangeHud()                                       { Global.ChangeHud(); }
    exec function CheatPlease()                                     { Global.CheatPlease(); }
    exec function CheatView( class<actor> aClass )                  { Global.CheatView(aClass); }
    exec function ClearProgressMessages()                           { Global.ClearProgressMessages(); }
    exec function DebugCommand( string text )                       { Global.DebugCommand(text); }
    exec function DebugContinue()                                   { Global.DebugContinue(); }
    exec function FeignDeath()                                      { Global.FeignDeath(); }
    exec function Fire( optional float F )                          { Global.Fire(F); }
    exec function Fly()                                             { Global.Fly(); }
    exec function FOV(float F)                                      { Global.FOV(F); }
    exec function FunctionKey( byte Num )                           { Global.FunctionKey(Num); }
    exec function GetWeapon(class<Weapon> NewWeaponClass )          { Global.GetWeapon(NewWeaponClass); }
    exec function Ghost()                                           { Global.Ghost(); }
    exec function God()                                             { Global.God(); }
    exec function Grab()                                            { Global.Grab(); }
    exec function InvertMouse( bool B )                             { Global.InvertMouse(B); }
    exec function Invisible(bool B)                                 { Global.Invisible(B); }
    exec function Jump( optional float F )                          { Global.Jump(F); }
    exec function Kick( string S )                                  { Global.Kick(S); }
    exec function KickBan( string S )                               { Global.KickBan(S); }
    exec function KillAll(class<actor> aClass)                      { Global.KillAll(aClass); }
    exec function KillPawns()                                       { Global.KillPawns(); }
    exec function Loc()                                             { Global.Loc(); }
    exec function LocalTravel( string URL )                         { Global.LocalTravel(URL); }
    exec function Mutate(string MutateString)                       { Global.Mutate(MutateString); }
    exec function Name( coerce string S )                           { Global.Name(S); }
    exec function NeverSwitchOnPickup( bool B )                     { Global.NeverSwitchOnPickup(B); }
    exec function NextWeapon()                                      { Global.NextWeapon(); }
    exec function Pause()                                           { Global.Pause(); }
    exec function Ping()                                            { Global.Ping(); }
    exec function PlayerList()                                      { Global.PlayerList(); }
    exec function PlayersOnly()                                     { Global.PlayersOnly(); }
    exec function PrevItem()                                        { Global.PrevItem(); }
    exec function PrevWeapon()                                      { Global.PrevWeapon(); }
    exec function Profile()                                         { Global.Profile(); }
    exec function QuickLoad()                                       { Global.QuickLoad(); }
    exec function QuickSave()                                       { Global.QuickSave(); }
    exec function RememberSpot()                                    { Global.RememberSpot(); }
    exec function RestartLevel()                                    { Global.RestartLevel(); }
    exec function RuleList()                                        { Global.RuleList(); }
    exec function Say( string Msg )                                 { Global.Say(Msg); }
    exec function SetAutoAim( float F )                             { Global.SetAutoAim(F); }
    exec function SetBob(float F)                                   { Global.SetBob(F); }
    exec function SetDesiredFOV(float F)                            { Global.SetDesiredFOV(F); }
    exec function SetDodgeClickTime( float F )                      { Global.SetDodgeClickTime(F); }
    exec function SetFriction( float F )                            { Global.SetFriction(F); }
    exec function SetJumpZ( float F )                               { Global.SetJumpZ(F); }
    exec function SetMaxMouseSmoothing( bool B )                    { Global.SetMaxMouseSmoothing(B); }
    exec function SetMouseSmoothThreshold( float F )                { Global.SetMouseSmoothThreshold(F); }
    exec function SetName( coerce string S )                        { Global.SetName(S); }
    exec function SetProgressColor( color C, int Index )            { Global.SetProgressColor(C, Index); }
    exec function SetProgressMessage( string S, int Index )         { Global.SetProgressMessage(S, Index); }
    exec function SetProgressTime( float T )                        { Global.SetProgressTime(T); }
    exec function SetSensitivity(float F)                           { Global.SetSensitivity(F); }
    exec function SetSpeed( float F )                               { Global.SetSpeed(F); }
    exec function SetViewFlash(bool B)                              { Global.SetViewFlash(B); }
    exec function SetWeaponStay( bool B)                            { Global.SetWeaponStay(B); }
    exec function ShowInventory()                                   { Global.ShowInventory(); }
    exec function ShowLoadMenu()                                    { Global.ShowLoadMenu(); }
    exec function ShowMenu()                                        { Global.ShowMenu(); }
    exec function ShowPath()                                        { Global.ShowPath(); }
    exec function ShowScores()                                      { Global.ShowScores(); }
    exec function ShowSpecialMenu( string ClassName )               { Global.ShowSpecialMenu(ClassName); }
    exec function ShowTags(optional string cmdline)                 { Global.ShowTags(cmdline); }
    exec function ShutUp()                                          { Global.ShutUp(); }
    exec function SloMo( float T )                                  { Global.SloMo(T); }
    exec function SnapView( bool B )                                { Global.SnapView(B); }
    exec function Speech( int Type, int Index, int Callsign )       { Global.Speech(Type, Index, Callsign); }
    exec function SShot()                                           { Global.SShot(); }
    exec function StairLook( bool B )                               { Global.StairLook(B); }
    exec function Suicide()                                         { Global.Suicide(); }
    exec function SwitchCoopLevel( string URL )                     { Global.SwitchCoopLevel(URL); }
    exec function SwitchLevel( string URL )                         { Global.SwitchLevel(URL); }
    exec function bool SwitchToBestWeapon()                         { Global.SwitchToBestWeapon(); }
    exec function Team( int N )                                     { Global.Team(N); }
    exec function TeamSay( string Msg )                             { Global.TeamSay(Msg); }
    exec function Tele(vector newLoc)                               { Global.Tele(newLoc); }
    exec function ToggleRuneHUD()                                   { Global.ToggleRuneHUD(); }
    exec function ViewPlayer( string S )                            { Global.ViewPlayer(S); }
    exec function ViewPlayerNum(optional int num)                   { Global.ViewPlayerNum(num); }
    exec function ViewSelf()                                        { Global.ViewSelf(); }
    exec function Walk()                                            { Global.Walk(); }
    exec function Watch( string ClassName )                         { Global.Watch(ClassName); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: Pain
state Pain
{
    exec function ActivateInventoryItem(class InvItem)              { Global.ActivateInventoryItem(InvItem); }
    exec function ActivateItem()                                    { Global.ActivateItem(); }
    exec function ActorState(class<actor> aClass, name statename)   { Global.ActorState(aClass, statename); }
    exec function AddBots(int N)                                    { Global.AddBots(N); }
    exec function Admin(string CommandLine)                         { Global.Admin(CommandLine); }
    exec function AdminLogin( string Password )                     { Global.AdminLogin(Password); }
    exec function AdminLogout()                                     { Global.AdminLogout(); }
    exec function AltFire( optional float F )                       { Global.AltFire(F); }
    exec function AlwaysMouseLook( Bool B )                         { Global.AlwaysMouseLook(B); }
    exec function Amphibious()                                      { Global.Amphibious(); }
    exec function Bug(string Msg)                                   { Global.Bug(Msg); }
    exec function CallForHelp()                                     { Global.CallForHelp(); }
    exec function CauseEvent( name N )                              { Global.CauseEvent(N); }
    //exec function ChangeCrosshair()                                   { Global.ChangeCrosshair(); }
    //exec function ChangeHud()                                       { Global.ChangeHud(); }
    exec function CheatPlease()                                     { Global.CheatPlease(); }
    exec function CheatView( class<actor> aClass )                  { Global.CheatView(aClass); }
    exec function ClearProgressMessages()                           { Global.ClearProgressMessages(); }
    exec function DebugCommand( string text )                       { Global.DebugCommand(text); }
    exec function DebugContinue()                                   { Global.DebugContinue(); }
    exec function FeignDeath()                                      { Global.FeignDeath(); }
    exec function Fire( optional float F )                          { Global.Fire(F); }
    exec function Fly()                                             { Global.Fly(); }
    exec function FOV(float F)                                      { Global.FOV(F); }
    exec function FunctionKey( byte Num )                           { Global.FunctionKey(Num); }
    exec function GetWeapon(class<Weapon> NewWeaponClass )          { Global.GetWeapon(NewWeaponClass); }
    exec function Ghost()                                           { Global.Ghost(); }
    exec function God()                                             { Global.God(); }
    exec function Grab()                                            { Global.Grab(); }
    exec function InvertMouse( bool B )                             { Global.InvertMouse(B); }
    exec function Invisible(bool B)                                 { Global.Invisible(B); }
    exec function Jump( optional float F )                          { Global.Jump(F); }
    exec function Kick( string S )                                  { Global.Kick(S); }
    exec function KickBan( string S )                               { Global.KickBan(S); }
    exec function KillAll(class<actor> aClass)                      { Global.KillAll(aClass); }
    exec function KillPawns()                                       { Global.KillPawns(); }
    exec function Loc()                                             { Global.Loc(); }
    exec function LocalTravel( string URL )                         { Global.LocalTravel(URL); }
    exec function Mutate(string MutateString)                       { Global.Mutate(MutateString); }
    exec function Name( coerce string S )                           { Global.Name(S); }
    exec function NeverSwitchOnPickup( bool B )                     { Global.NeverSwitchOnPickup(B); }
    exec function NextWeapon()                                      { Global.NextWeapon(); }
    exec function Pause()                                           { Global.Pause(); }
    exec function Ping()                                            { Global.Ping(); }
    exec function PlayerList()                                      { Global.PlayerList(); }
    exec function PlayersOnly()                                     { Global.PlayersOnly(); }
    exec function PrevItem()                                        { Global.PrevItem(); }
    exec function PrevWeapon()                                      { Global.PrevWeapon(); }
    exec function Profile()                                         { Global.Profile(); }
    exec function QuickLoad()                                       { Global.QuickLoad(); }
    exec function QuickSave()                                       { Global.QuickSave(); }
    exec function RememberSpot()                                    { Global.RememberSpot(); }
    exec function RestartLevel()                                    { Global.RestartLevel(); }
    exec function RuleList()                                        { Global.RuleList(); }
    exec function Say( string Msg )                                 { Global.Say(Msg); }
    exec function SetAutoAim( float F )                             { Global.SetAutoAim(F); }
    exec function SetBob(float F)                                   { Global.SetBob(F); }
    exec function SetDesiredFOV(float F)                            { Global.SetDesiredFOV(F); }
    exec function SetDodgeClickTime( float F )                      { Global.SetDodgeClickTime(F); }
    exec function SetFriction( float F )                            { Global.SetFriction(F); }
    exec function SetJumpZ( float F )                               { Global.SetJumpZ(F); }
    exec function SetMaxMouseSmoothing( bool B )                    { Global.SetMaxMouseSmoothing(B); }
    exec function SetMouseSmoothThreshold( float F )                { Global.SetMouseSmoothThreshold(F); }
    exec function SetName( coerce string S )                        { Global.SetName(S); }
    exec function SetProgressColor( color C, int Index )            { Global.SetProgressColor(C, Index); }
    exec function SetProgressMessage( string S, int Index )         { Global.SetProgressMessage(S, Index); }
    exec function SetProgressTime( float T )                        { Global.SetProgressTime(T); }
    exec function SetSensitivity(float F)                           { Global.SetSensitivity(F); }
    exec function SetSpeed( float F )                               { Global.SetSpeed(F); }
    exec function SetViewFlash(bool B)                              { Global.SetViewFlash(B); }
    exec function SetWeaponStay( bool B)                            { Global.SetWeaponStay(B); }
    exec function ShowInventory()                                   { Global.ShowInventory(); }
    exec function ShowLoadMenu()                                    { Global.ShowLoadMenu(); }
    exec function ShowMenu()                                        { Global.ShowMenu(); }
    exec function ShowPath()                                        { Global.ShowPath(); }
    exec function ShowScores()                                      { Global.ShowScores(); }
    exec function ShowSpecialMenu( string ClassName )               { Global.ShowSpecialMenu(ClassName); }
    exec function ShowTags(optional string cmdline)                 { Global.ShowTags(cmdline); }
    exec function ShutUp()                                          { Global.ShutUp(); }
    exec function SloMo( float T )                                  { Global.SloMo(T); }
    exec function SnapView( bool B )                                { Global.SnapView(B); }
    exec function Speech( int Type, int Index, int Callsign )       { Global.Speech(Type, Index, Callsign); }
    exec function SShot()                                           { Global.SShot(); }
    exec function StairLook( bool B )                               { Global.StairLook(B); }
    exec function Suicide()                                         { Global.Suicide(); }
    exec function SwitchCoopLevel( string URL )                     { Global.SwitchCoopLevel(URL); }
    exec function SwitchLevel( string URL )                         { Global.SwitchLevel(URL); }
    exec function bool SwitchToBestWeapon()                         { Global.SwitchToBestWeapon(); }
    exec function Team( int N )                                     { Global.Team(N); }
    exec function TeamSay( string Msg )                             { Global.TeamSay(Msg); }
    exec function Tele(vector newLoc)                               { Global.Tele(newLoc); }
    exec function ToggleRuneHUD()                                   { Global.ToggleRuneHUD(); }
    exec function ViewPlayer( string S )                            { Global.ViewPlayer(S); }
    exec function ViewPlayerNum(optional int num)                   { Global.ViewPlayerNum(num); }
    exec function ViewSelf()                                        { Global.ViewSelf(); }
    exec function Walk()                                            { Global.Walk(); }
    exec function Watch( string ClassName )                         { Global.Watch(ClassName); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: Uninterrupted
state Uninterrupted
{
    exec function ActivateInventoryItem(class InvItem)              { Global.ActivateInventoryItem(InvItem); }
    exec function ActivateItem()                                    { Global.ActivateItem(); }
    exec function ActorState(class<actor> aClass, name statename)   { Global.ActorState(aClass, statename); }
    exec function AddBots(int N)                                    { Global.AddBots(N); }
    exec function Admin(string CommandLine)                         { Global.Admin(CommandLine); }
    exec function AdminLogin( string Password )                     { Global.AdminLogin(Password); }
    exec function AdminLogout()                                     { Global.AdminLogout(); }
    exec function AltFire( optional float F )                       { Global.AltFire(F); }
    exec function AlwaysMouseLook( Bool B )                         { Global.AlwaysMouseLook(B); }
    exec function Amphibious()                                      { Global.Amphibious(); }
    exec function Bug(string Msg)                                   { Global.Bug(Msg); }
    exec function CallForHelp()                                     { Global.CallForHelp(); }
    exec function CauseEvent( name N )                              { Global.CauseEvent(N); }
    //exec function ChangeCrosshair()                                   { Global.ChangeCrosshair(); }
    //exec function ChangeHud()                                       { Global.ChangeHud(); }
    exec function CheatPlease()                                     { Global.CheatPlease(); }
    exec function CheatView( class<actor> aClass )                  { Global.CheatView(aClass); }
    exec function ClearProgressMessages()                           { Global.ClearProgressMessages(); }
    exec function DebugCommand( string text )                       { Global.DebugCommand(text); }
    exec function DebugContinue()                                   { Global.DebugContinue(); }
    exec function FeignDeath()                                      { Global.FeignDeath(); }
    exec function Fire( optional float F )                          { Global.Fire(F); }
    exec function Fly()                                             { Global.Fly(); }
    exec function FOV(float F)                                      { Global.FOV(F); }
    exec function FunctionKey( byte Num )                           { Global.FunctionKey(Num); }
    exec function GetWeapon(class<Weapon> NewWeaponClass )          { Global.GetWeapon(NewWeaponClass); }
    exec function Ghost()                                           { Global.Ghost(); }
    exec function God()                                             { Global.God(); }
    exec function Grab()                                            { Global.Grab(); }
    exec function InvertMouse( bool B )                             { Global.InvertMouse(B); }
    exec function Invisible(bool B)                                 { Global.Invisible(B); }
    exec function Jump( optional float F )                          { Global.Jump(F); }
    exec function Kick( string S )                                  { Global.Kick(S); }
    exec function KickBan( string S )                               { Global.KickBan(S); }
    exec function KillAll(class<actor> aClass)                      { Global.KillAll(aClass); }
    exec function KillPawns()                                       { Global.KillPawns(); }
    exec function Loc()                                             { Global.Loc(); }
    exec function LocalTravel( string URL )                         { Global.LocalTravel(URL); }
    exec function Mutate(string MutateString)                       { Global.Mutate(MutateString); }
    exec function Name( coerce string S )                           { Global.Name(S); }
    exec function NeverSwitchOnPickup( bool B )                     { Global.NeverSwitchOnPickup(B); }
    exec function NextWeapon()                                      { Global.NextWeapon(); }
    exec function Pause()                                           { Global.Pause(); }
    exec function Ping()                                            { Global.Ping(); }
    exec function PlayerList()                                      { Global.PlayerList(); }
    exec function PlayersOnly()                                     { Global.PlayersOnly(); }
    exec function PrevItem()                                        { Global.PrevItem(); }
    exec function PrevWeapon()                                      { Global.PrevWeapon(); }
    exec function Profile()                                         { Global.Profile(); }
    exec function QuickLoad()                                       { Global.QuickLoad(); }
    exec function QuickSave()                                       { Global.QuickSave(); }
    exec function RememberSpot()                                    { Global.RememberSpot(); }
    exec function RestartLevel()                                    { Global.RestartLevel(); }
    exec function RuleList()                                        { Global.RuleList(); }
    exec function Say( string Msg )                                 { Global.Say(Msg); }
    exec function SetAutoAim( float F )                             { Global.SetAutoAim(F); }
    exec function SetBob(float F)                                   { Global.SetBob(F); }
    exec function SetDesiredFOV(float F)                            { Global.SetDesiredFOV(F); }
    exec function SetDodgeClickTime( float F )                      { Global.SetDodgeClickTime(F); }
    exec function SetFriction( float F )                            { Global.SetFriction(F); }
    exec function SetJumpZ( float F )                               { Global.SetJumpZ(F); }
    exec function SetMaxMouseSmoothing( bool B )                    { Global.SetMaxMouseSmoothing(B); }
    exec function SetMouseSmoothThreshold( float F )                { Global.SetMouseSmoothThreshold(F); }
    exec function SetName( coerce string S )                        { Global.SetName(S); }
    exec function SetProgressColor( color C, int Index )            { Global.SetProgressColor(C, Index); }
    exec function SetProgressMessage( string S, int Index )         { Global.SetProgressMessage(S, Index); }
    exec function SetProgressTime( float T )                        { Global.SetProgressTime(T); }
    exec function SetSensitivity(float F)                           { Global.SetSensitivity(F); }
    exec function SetSpeed( float F )                               { Global.SetSpeed(F); }
    exec function SetViewFlash(bool B)                              { Global.SetViewFlash(B); }
    exec function SetWeaponStay( bool B)                            { Global.SetWeaponStay(B); }
    exec function ShowInventory()                                   { Global.ShowInventory(); }
    exec function ShowLoadMenu()                                    { Global.ShowLoadMenu(); }
    exec function ShowMenu()                                        { Global.ShowMenu(); }
    exec function ShowPath()                                        { Global.ShowPath(); }
    exec function ShowScores()                                      { Global.ShowScores(); }
    exec function ShowSpecialMenu( string ClassName )               { Global.ShowSpecialMenu(ClassName); }
    exec function ShowTags(optional string cmdline)                 { Global.ShowTags(cmdline); }
    exec function ShutUp()                                          { Global.ShutUp(); }
    exec function SloMo( float T )                                  { Global.SloMo(T); }
    exec function SnapView( bool B )                                { Global.SnapView(B); }
    exec function Speech( int Type, int Index, int Callsign )       { Global.Speech(Type, Index, Callsign); }
    exec function SShot()                                           { Global.SShot(); }
    exec function StairLook( bool B )                               { Global.StairLook(B); }
    exec function Suicide()                                         { Global.Suicide(); }
    exec function SwitchCoopLevel( string URL )                     { Global.SwitchCoopLevel(URL); }
    exec function SwitchLevel( string URL )                         { Global.SwitchLevel(URL); }
    exec function bool SwitchToBestWeapon()                         { Global.SwitchToBestWeapon(); }
    exec function Team( int N )                                     { Global.Team(N); }
    exec function TeamSay( string Msg )                             { Global.TeamSay(Msg); }
    exec function Tele(vector newLoc)                               { Global.Tele(newLoc); }
    exec function ToggleRuneHUD()                                   { Global.ToggleRuneHUD(); }
    exec function ViewPlayer( string S )                            { Global.ViewPlayer(S); }
    exec function ViewPlayerNum(optional int num)                   { Global.ViewPlayerNum(num); }
    exec function ViewSelf()                                        { Global.ViewSelf(); }
    exec function Walk()                                            { Global.Walk(); }
    exec function Watch( string ClassName )                         { Global.Watch(ClassName); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: Dying
state Dying
{
    exec function ActivateInventoryItem(class InvItem)              { Global.ActivateInventoryItem(InvItem); }
    exec function ActivateItem()                                    { Global.ActivateItem(); }
    exec function ActorState(class<actor> aClass, name statename)   { Global.ActorState(aClass, statename); }
    exec function AddBots(int N)                                    { Global.AddBots(N); }
    exec function Admin(string CommandLine)                         { Global.Admin(CommandLine); }
    exec function AdminLogin( string Password )                     { Global.AdminLogin(Password); }
    exec function AdminLogout()                                     { Global.AdminLogout(); }
    exec function AltFire( optional float F )                       { Global.AltFire(F); }
    exec function AlwaysMouseLook( Bool B )                         { Global.AlwaysMouseLook(B); }
    exec function Amphibious()                                      { Global.Amphibious(); }
    exec function Bug(string Msg)                                   { Global.Bug(Msg); }
    exec function CallForHelp()                                     { Global.CallForHelp(); }
    exec function CauseEvent( name N )                              { Global.CauseEvent(N); }
    //exec function ChangeCrosshair()                                   { Global.ChangeCrosshair(); }
    //exec function ChangeHud()                                       { Global.ChangeHud(); }
    exec function CheatPlease()                                     { Global.CheatPlease(); }
    exec function CheatView( class<actor> aClass )                  { Global.CheatView(aClass); }
    exec function ClearProgressMessages()                           { Global.ClearProgressMessages(); }
    exec function DebugCommand( string text )                       { Global.DebugCommand(text); }
    exec function DebugContinue()                                   { Global.DebugContinue(); }
    exec function FeignDeath()                                      { Global.FeignDeath(); }
    exec function Fire( optional float F )                          { Global.Fire(F); }
    exec function Fly()                                             { Global.Fly(); }
    exec function FOV(float F)                                      { Global.FOV(F); }
    exec function FunctionKey( byte Num )                           { Global.FunctionKey(Num); }
    exec function GetWeapon(class<Weapon> NewWeaponClass )          { Global.GetWeapon(NewWeaponClass); }
    exec function Ghost()                                           { Global.Ghost(); }
    exec function God()                                             { Global.God(); }
    exec function Grab()                                            { Global.Grab(); }
    exec function InvertMouse( bool B )                             { Global.InvertMouse(B); }
    exec function Invisible(bool B)                                 { Global.Invisible(B); }
    exec function Jump( optional float F )                          { Global.Jump(F); }
    exec function Kick( string S )                                  { Global.Kick(S); }
    exec function KickBan( string S )                               { Global.KickBan(S); }
    exec function KillAll(class<actor> aClass)                      { Global.KillAll(aClass); }
    exec function KillPawns()                                       { Global.KillPawns(); }
    exec function Loc()                                             { Global.Loc(); }
    exec function LocalTravel( string URL )                         { Global.LocalTravel(URL); }
    exec function Mutate(string MutateString)                       { Global.Mutate(MutateString); }
    exec function Name( coerce string S )                           { Global.Name(S); }
    exec function NeverSwitchOnPickup( bool B )                     { Global.NeverSwitchOnPickup(B); }
    exec function NextWeapon()                                      { Global.NextWeapon(); }
    exec function Pause()                                           { Global.Pause(); }
    exec function Ping()                                            { Global.Ping(); }
    exec function PlayerList()                                      { Global.PlayerList(); }
    exec function PlayersOnly()                                     { Global.PlayersOnly(); }
    exec function PrevItem()                                        { Global.PrevItem(); }
    exec function PrevWeapon()                                      { Global.PrevWeapon(); }
    exec function Profile()                                         { Global.Profile(); }
    exec function QuickLoad()                                       { Global.QuickLoad(); }
    exec function QuickSave()                                       { Global.QuickSave(); }
    exec function RememberSpot()                                    { Global.RememberSpot(); }
    exec function RestartLevel()                                    { Global.RestartLevel(); }
    exec function RuleList()                                        { Global.RuleList(); }
    exec function Say( string Msg )                                 { Global.Say(Msg); }
    exec function SetAutoAim( float F )                             { Global.SetAutoAim(F); }
    exec function SetBob(float F)                                   { Global.SetBob(F); }
    exec function SetDesiredFOV(float F)                            { Global.SetDesiredFOV(F); }
    exec function SetDodgeClickTime( float F )                      { Global.SetDodgeClickTime(F); }
    exec function SetFriction( float F )                            { Global.SetFriction(F); }
    exec function SetJumpZ( float F )                               { Global.SetJumpZ(F); }
    exec function SetMaxMouseSmoothing( bool B )                    { Global.SetMaxMouseSmoothing(B); }
    exec function SetMouseSmoothThreshold( float F )                { Global.SetMouseSmoothThreshold(F); }
    exec function SetName( coerce string S )                        { Global.SetName(S); }
    exec function SetProgressColor( color C, int Index )            { Global.SetProgressColor(C, Index); }
    exec function SetProgressMessage( string S, int Index )         { Global.SetProgressMessage(S, Index); }
    exec function SetProgressTime( float T )                        { Global.SetProgressTime(T); }
    exec function SetSensitivity(float F)                           { Global.SetSensitivity(F); }
    exec function SetSpeed( float F )                               { Global.SetSpeed(F); }
    exec function SetViewFlash(bool B)                              { Global.SetViewFlash(B); }
    exec function SetWeaponStay( bool B)                            { Global.SetWeaponStay(B); }
    exec function ShowInventory()                                   { Global.ShowInventory(); }
    exec function ShowLoadMenu()                                    { Global.ShowLoadMenu(); }
    exec function ShowMenu()                                        { Global.ShowMenu(); }
    exec function ShowPath()                                        { Global.ShowPath(); }
    exec function ShowScores()                                      { Global.ShowScores(); }
    exec function ShowSpecialMenu( string ClassName )               { Global.ShowSpecialMenu(ClassName); }
    exec function ShowTags(optional string cmdline)                 { Global.ShowTags(cmdline); }
    exec function ShutUp()                                          { Global.ShutUp(); }
    exec function SloMo( float T )                                  { Global.SloMo(T); }
    exec function SnapView( bool B )                                { Global.SnapView(B); }
    exec function Speech( int Type, int Index, int Callsign )       { Global.Speech(Type, Index, Callsign); }
    exec function SShot()                                           { Global.SShot(); }
    exec function StairLook( bool B )                               { Global.StairLook(B); }
    exec function Suicide()                                         { Global.Suicide(); }
    exec function SwitchCoopLevel( string URL )                     { Global.SwitchCoopLevel(URL); }
    exec function SwitchLevel( string URL )                         { Global.SwitchLevel(URL); }
    exec function bool SwitchToBestWeapon()                         { Global.SwitchToBestWeapon(); }
    exec function Team( int N )                                     { Global.Team(N); }
    exec function TeamSay( string Msg )                             { Global.TeamSay(Msg); }
    exec function Tele(vector newLoc)                               { Global.Tele(newLoc); }
    exec function ToggleRuneHUD()                                   { Global.ToggleRuneHUD(); }
    exec function ViewPlayer( string S )                            { Global.ViewPlayer(S); }
    exec function ViewPlayerNum(optional int num)                   { Global.ViewPlayerNum(num); }
    exec function ViewSelf()                                        { Global.ViewSelf(); }
    exec function Walk()                                            { Global.Walk(); }
    exec function Watch( string ClassName )                         { Global.Watch(ClassName); }
}


///////////////////////////////////////////////////////////////////////////////
// STATE: GameEnded
state GameEnded
{
    exec function ActivateInventoryItem(class InvItem)              { Global.ActivateInventoryItem(InvItem); }
    exec function ActivateItem()                                    { Global.ActivateItem(); }
    exec function ActorState(class<actor> aClass, name statename)   { Global.ActorState(aClass, statename); }
    exec function AddBots(int N)                                    { Global.AddBots(N); }
    exec function Admin(string CommandLine)                         { Global.Admin(CommandLine); }
    exec function AdminLogin( string Password )                     { Global.AdminLogin(Password); }
    exec function AdminLogout()                                     { Global.AdminLogout(); }
    exec function AltFire( optional float F )                       { Global.AltFire(F); }
    exec function AlwaysMouseLook( Bool B )                         { Global.AlwaysMouseLook(B); }
    exec function Amphibious()                                      { Global.Amphibious(); }
    exec function Bug(string Msg)                                   { Global.Bug(Msg); }
    exec function CallForHelp()                                     { Global.CallForHelp(); }
    exec function CauseEvent( name N )                              { Global.CauseEvent(N); }
    //exec function ChangeCrosshair()                                   { Global.ChangeCrosshair(); }
    //exec function ChangeHud()                                       { Global.ChangeHud(); }
    exec function CheatPlease()                                     { Global.CheatPlease(); }
    exec function CheatView( class<actor> aClass )                  { Global.CheatView(aClass); }
    exec function ClearProgressMessages()                           { Global.ClearProgressMessages(); }
    exec function DebugCommand( string text )                       { Global.DebugCommand(text); }
    exec function DebugContinue()                                   { Global.DebugContinue(); }
    exec function FeignDeath()                                      { Global.FeignDeath(); }
    exec function Fire( optional float F )                          { Global.Fire(F); }
    exec function Fly()                                             { Global.Fly(); }
    exec function FOV(float F)                                      { Global.FOV(F); }
    exec function FunctionKey( byte Num )                           { Global.FunctionKey(Num); }
    exec function GetWeapon(class<Weapon> NewWeaponClass )          { Global.GetWeapon(NewWeaponClass); }
    exec function Ghost()                                           { Global.Ghost(); }
    exec function God()                                             { Global.God(); }
    exec function Grab()                                            { Global.Grab(); }
    exec function InvertMouse( bool B )                             { Global.InvertMouse(B); }
    exec function Invisible(bool B)                                 { Global.Invisible(B); }
    exec function Jump( optional float F )                          { Global.Jump(F); }
    exec function Kick( string S )                                  { Global.Kick(S); }
    exec function KickBan( string S )                               { Global.KickBan(S); }
    exec function KillAll(class<actor> aClass)                      { Global.KillAll(aClass); }
    exec function KillPawns()                                       { Global.KillPawns(); }
    exec function Loc()                                             { Global.Loc(); }
    exec function LocalTravel( string URL )                         { Global.LocalTravel(URL); }
    exec function Mutate(string MutateString)                       { Global.Mutate(MutateString); }
    exec function Name( coerce string S )                           { Global.Name(S); }
    exec function NeverSwitchOnPickup( bool B )                     { Global.NeverSwitchOnPickup(B); }
    exec function NextWeapon()                                      { Global.NextWeapon(); }
    exec function Pause()                                           { Global.Pause(); }
    exec function Ping()                                            { Global.Ping(); }
    exec function PlayerList()                                      { Global.PlayerList(); }
    exec function PlayersOnly()                                     { Global.PlayersOnly(); }
    exec function PrevItem()                                        { Global.PrevItem(); }
    exec function PrevWeapon()                                      { Global.PrevWeapon(); }
    exec function Profile()                                         { Global.Profile(); }
    exec function QuickLoad()                                       { Global.QuickLoad(); }
    exec function QuickSave()                                       { Global.QuickSave(); }
    exec function RememberSpot()                                    { Global.RememberSpot(); }
    exec function RestartLevel()                                    { Global.RestartLevel(); }
    exec function RuleList()                                        { Global.RuleList(); }
    exec function Say( string Msg )                                 { Global.Say(Msg); }
    exec function SetAutoAim( float F )                             { Global.SetAutoAim(F); }
    exec function SetBob(float F)                                   { Global.SetBob(F); }
    exec function SetDesiredFOV(float F)                            { Global.SetDesiredFOV(F); }
    exec function SetDodgeClickTime( float F )                      { Global.SetDodgeClickTime(F); }
    exec function SetFriction( float F )                            { Global.SetFriction(F); }
    exec function SetJumpZ( float F )                               { Global.SetJumpZ(F); }
    exec function SetMaxMouseSmoothing( bool B )                    { Global.SetMaxMouseSmoothing(B); }
    exec function SetMouseSmoothThreshold( float F )                { Global.SetMouseSmoothThreshold(F); }
    exec function SetName( coerce string S )                        { Global.SetName(S); }
    exec function SetProgressColor( color C, int Index )            { Global.SetProgressColor(C, Index); }
    exec function SetProgressMessage( string S, int Index )         { Global.SetProgressMessage(S, Index); }
    exec function SetProgressTime( float T )                        { Global.SetProgressTime(T); }
    exec function SetSensitivity(float F)                           { Global.SetSensitivity(F); }
    exec function SetSpeed( float F )                               { Global.SetSpeed(F); }
    exec function SetViewFlash(bool B)                              { Global.SetViewFlash(B); }
    exec function SetWeaponStay( bool B)                            { Global.SetWeaponStay(B); }
    exec function ShowInventory()                                   { Global.ShowInventory(); }
    exec function ShowLoadMenu()                                    { Global.ShowLoadMenu(); }
    exec function ShowMenu()                                        { Global.ShowMenu(); }
    exec function ShowPath()                                        { Global.ShowPath(); }
    exec function ShowScores()                                      { Global.ShowScores(); }
    exec function ShowSpecialMenu( string ClassName )               { Global.ShowSpecialMenu(ClassName); }
    exec function ShowTags(optional string cmdline)                 { Global.ShowTags(cmdline); }
    exec function ShutUp()                                          { Global.ShutUp(); }
    exec function SloMo( float T )                                  { Global.SloMo(T); }
    exec function SnapView( bool B )                                { Global.SnapView(B); }
    exec function Speech( int Type, int Index, int Callsign )       { Global.Speech(Type, Index, Callsign); }
    exec function SShot()                                           { Global.SShot(); }
    exec function StairLook( bool B )                               { Global.StairLook(B); }
    exec function Suicide()                                         { Global.Suicide(); }
    exec function SwitchCoopLevel( string URL )                     { Global.SwitchCoopLevel(URL); }
    exec function SwitchLevel( string URL )                         { Global.SwitchLevel(URL); }
    exec function bool SwitchToBestWeapon()                         { Global.SwitchToBestWeapon(); }
    exec function Team( int N )                                     { Global.Team(N); }
    exec function TeamSay( string Msg )                             { Global.TeamSay(Msg); }
    exec function Tele(vector newLoc)                               { Global.Tele(newLoc); }
    exec function ToggleRuneHUD()                                   { Global.ToggleRuneHUD(); }
    exec function ViewPlayer( string S )                            { Global.ViewPlayer(S); }
    exec function ViewPlayerNum(optional int num)                   { Global.ViewPlayerNum(num); }
    exec function ViewSelf()                                        { Global.ViewSelf(); }
    exec function Walk()                                            { Global.Walk(); }
    exec function Watch( string ClassName )                         { Global.Watch(ClassName); }
}