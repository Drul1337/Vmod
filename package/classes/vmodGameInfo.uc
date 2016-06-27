////////////////////////////////////////////////////////////////////////////////
// vmodGameInfo
////////////////////////////////////////////////////////////////////////////////
class vmodGameInfo extends vmodGameInfoBaseTeams abstract;

// TODO: Split base game info and team game code up amongst gameinfobase and
// gameinfobaseteams classes.

// TODO: Maybe create a third class as the base implementation for all states

// TODO: Use this class as an interface and event dispatcher for player pawns?


// Player interacts with game through an interface like this
// function PlayerRequestTeamChange(Pawn P, byte Team);
// function PlayerRequestAdminRights(Pawn P);
// function PlayerRequestVoteMapChange(Pawn P);
// function PlayerRequestVoteShuffle(Pawn P);
// function PlayerRequestVoteKick(Pawn P, int ID);
// function PlayerRequestReadyToPlay(Pawn P);
// function PlayerRequestNotReadyToPlay(Pawn P);
// function PlayerRequestJoinGame(Pawn P);
// function PlayerRequestSpectate(Pawn P);


////////////////////////////////////////////////////////////////////////////////
//  Player Request Interface
//
//  This is the interface for Players who would like to interact with the game.
//
//  TODO: These are the ONLY gameinfo functions that player should ever call,
//  it may take a lot of verification with original classes to make sure
////////////////////////////////////////////////////////////////////////////////
function PlayerRequestJoinGame(Pawn P)  // Override in states
{
    PlayerJoinGame(P);
}

function PlayerRequestSpectate(Pawn P) // Override in states
{
    PlayerSpectate(P);
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

////////////////////////////////////////////////////////////////////////////////
//  STATE: PreGame
////////////////////////////////////////////////////////////////////////////////
state PreGame
{
    function PlayerRequestReadyToPlay(Pawn P)
    {
        // If there are not enough players in the game, player cannot ready up
        if(!EnoughPlayersToStart())
        {
            PlayerMessageNotEnoughPlayersToStart(
                P,
                MinimumPlayersRequiredForStart);
            return;
        }
        
        // If the player is already ready, play waiting for others message
        if(IsPlayerReady(P))
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
        // If the player is already not ready, just return
        if(!IsPlayerReady(P))
            return;
        
        PlayerNotReady(P);
    }
}