////////////////////////////////////////////////////////////////////////////////
// vmodGameInfo
////////////////////////////////////////////////////////////////////////////////
class vmodGameInfo extends vmodGameInfoBaseTeams abstract;

////////////////////////////////////////////////////////////////////////////////
//  Player Request Interface
//
//  This is the interface for Players who would like to interact with the game.
//
//  TODO: These are the ONLY gameinfo functions that player should ever call,
//  it may take a lot of verification with original classes to make sure
////////////////////////////////////////////////////////////////////////////////
function PlayerRequestGoGameActive(Pawn P)  // Override in states
{
    PlayerBecomeGameActive(P);
}

function PlayerRequestGoGameInactive(Pawn P) // Override in states
{
    PlayerBecomeGameInactive(P);
}

function PlayerRequestReadyToPlay(Pawn P)       { } // Only valid in PreGame
function PlayerRequestNotReadyToPlay(Pawn P)    { } // Only valid in PreGame

function PlayerRequestTeamChange(Pawn P, byte Team)
{
    PlayerTeamChange(P, Team);
}

function PlayerRequestPlayerList(Pawn P)
{
    PlayerSendPlayerList(P);
}

////////////////////////////////////////////////////////////////////////////////
//  Administrator Requests
////////////////////////////////////////////////////////////////////////////////
function bool AdminRequestCheck(Pawn P)
{
    if(!PlayerPawn(P).bAdmin)
    {
        P.ClientMessage(
                "You must be an administrator",
                GetMessageTypeNameDefault(),
                false);
        return false;
    }
    return true;
}

function AdminRequestBroadcast(Pawn P, String Message)
{
    if(!AdminRequestCheck(P))
        return;
    
    PlayerBroadcast(P, Message);
}

function AdminRequestGameReset(Pawn P)
{
    if(!AdminRequestCheck(P))
        return;
    
    PlayerGameReset(P);
}

function AdminRequestGameEnd(Pawn P)
{
    if(!AdminRequestCheck(P))
        return;
    
    PlayerGameEnd(P);
}

function AdminRequestGameStart(Pawn P)
{
    if(!AdminRequestCheck(P))
        return;
    
    PlayerGameStart(P);
}

function AdminRequestTeamChange(Pawn P, int PlayerID, byte Team)
{
    local Pawn PCurr;
    
    if(!AdminRequestCheck(P))
        return;
    
    for(PCurr = Level.PawnList; PCurr != None; PCurr = PCurr.NextPawn)
        if(PCurr.PlayerReplicationInfo.PlayerID == PlayerID)
            PlayerTeamChange(PCurr, Team);
}

function AdminRequestGiveWeapon(Pawn P, Class<Weapon> WeaponClass)
{
    if(!AdminRequestCheck(P))
        return;
    
    PlayerGiveWeapon(P, WeaponClass);
}

function AdminRequestShuffleTeams(Pawn P)
{
    if(!AdminRequestCheck(P))
        return;
    
    ShuffleTeams();
}

function AdminRequestAddBot(Pawn P)
{
    if(!AdminRequestCheck(P))
        return;
    
    GameAddBot();
}

function AdminRequestRemoveBots(Pawn P)
{
    if(!AdminRequestCheck(P))
        return;
    
    GameRemoveBots();
}

////////////////////////////////////////////////////////////////////////////////
//  STATE: PreGame
////////////////////////////////////////////////////////////////////////////////
state PreGame
{
    function PlayerRequestReadyToPlay(Pawn P)
    {
        // Must be in the game
        if(!vmodRunePlayer(P).CheckIsPlaying())
            return;
        
        // If there are not enough players in the game, player cannot ready up
        if(!CheckEnoughPlayersInGame())
        {
            PlayerMessageNotEnoughPlayersToStart(
                P,
                MinimumPlayersRequiredForStart);
            return;
        }
        
        // If the player is already ready, play waiting for others message
        if(CheckPlayerReady(P))
        {
            PlayerMessageWaitingForOthers(
                P,
                MinimumPlayersRequiredForStart);
            return;
        }
        
        PlayerReady(P);
    }
    
    function PlayerRequestNotReadyToPlay(Pawn P)
    {
        // Must be in the game
        if(!vmodRunePlayer(P).CheckIsPlaying())
            return;
        
        // If the player is already not ready, just return
        if(!CheckPlayerReady(P))
            return;
        
        PlayerNotReady(P);
    }
}