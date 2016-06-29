////////////////////////////////////////////////////////////////////////////////
//  vmodStaticLocalMessages
////////////////////////////////////////////////////////////////////////////////
class vmodStaticLocalMessages extends Object abstract;

// Message class - name pairings
const MESSAGE_CLASS_DEFAULT         = Class'LocalMessage';
const MESSAGE_CLASS_PREGAME         = Class'Vmod.vmodLocalMessagePreGame';
const MESSAGE_CLASS_STARTINGGAME    = Class'Vmod.vmodLocalMessageStartingGame';
const MESSAGE_CLASS_LIVEGAME        = Class'Vmod.vmodLocalMessageLiveGame';
const MESSAGE_CLASS_POSTGAME        = Class'Vmod.vmodLocalMessagePostGame';
const MESSAGE_CLASS_PLAYERREADY     = Class'Vmod.vmodLocalMessagePlayerReady';
const MESSAGE_CLASS_PLAYERKILLED    = Class'Vmod.vmodLocalMessagePlayerKilled';
const MESSAGE_CLASS_PREROUND        = Class'Vmod.vmodLocalMessagePreRound';
const MESSAGE_CLASS_STARTINGROUND   = Class'Vmod.vmodLocalMessageStartingRound';
const MESSAGE_CLASS_POSTROUND       = Class'Vmod.vmodLocalMessagePostRound';

const MESSAGE_CLASS_SUBTITLE        = Class'SubtitleMessage';
const MESSAGE_CLASS_REDSUBTITLE     = Class'SubtitleRed';
const MESSAGE_CLASS_PICKUP          = Class'PickupMessage';
const MESSAGE_CLASS_SAY             = Class'SayMessage';
const MESSAGE_CLASS_TEAMSAY         = Class'SayMessage';
const MESSAGE_CLASS_NORUNEPOWER     = Class'NoRunePowerMessage';
const MESSAGE_CLASS_CRITICALEVENT   = Class'GenericMessage';
const MESSAGE_CLASS_DEATHMESSAGE    = Class'GenericMessage';
const MESSAGE_CLASS_EVENT           = Class'GenericMessage';

const MESSAGE_NAME_DEFAULT          = 'Default';
const MESSAGE_NAME_PREGAME          = 'PreGame';
const MESSAGE_NAME_STARTINGGAME     = 'StartingGame';
const MESSAGE_NAME_LIVEGAME         = 'LiveGame';
const MESSAGE_NAME_POSTGAME         = 'PostGame';
const MESSAGE_NAME_PLAYERREADY      = 'PlayerReady';
const MESSAGE_NAME_PLAYERKILLED     = 'PlayerKilled';
const MESSAGE_NAME_PREROUND         = 'PreRound';
const MESSAGE_NAME_STARTINGROUND    = 'StartingRound';
const MESSAGE_NAME_POSTROUND        = 'PostRound';

const MESSAGE_NAME_SUBTITLE         = 'Subtitle';
const MESSAGE_NAME_REDSUBTITLE      = 'RedSubtitle';
const MESSAGE_NAME_PICKUP           = 'Pickup';
const MESSAGE_NAME_SAY              = 'Say';
const MESSAGE_NAME_TEAMSAY          = 'TeamSay';
const MESSAGE_NAME_NORUNEPOWER      = 'NoRunePower';
const MESSAGE_NAME_CRITICALEVENT    = 'CriticalEvent';
const MESSAGE_NAME_DEATHMESSAGE     = 'DeathMessage';
const MESSAGE_NAME_EVENT            = 'Event';

////////////////////////////////////////////////////////////////////////////////
//  MessageTypeNames
////////////////////////////////////////////////////////////////////////////////
static function Name GetMessageTypeName(class<LocalMessage> MessageClass)
{
    switch(MessageClass)
    {
        case MESSAGE_CLASS_PREGAME:         return MESSAGE_NAME_PREGAME;
        case MESSAGE_CLASS_STARTINGGAME:    return MESSAGE_NAME_STARTINGGAME;
        case MESSAGE_CLASS_LIVEGAME:        return MESSAGE_NAME_LIVEGAME;
        case MESSAGE_CLASS_POSTGAME:        return MESSAGE_NAME_POSTGAME;
        case MESSAGE_CLASS_PLAYERREADY:     return MESSAGE_NAME_PLAYERREADY;
        case MESSAGE_CLASS_PLAYERKILLED:    return MESSAGE_NAME_PLAYERKILLED;
        case MESSAGE_CLASS_PREROUND:        return MESSAGE_NAME_PREROUND;
        case MESSAGE_CLASS_STARTINGROUND:   return MESSAGE_NAME_STARTINGROUND;
        case MESSAGE_CLASS_POSTROUND:       return MESSAGE_NAME_POSTROUND;
        case MESSAGE_CLASS_SUBTITLE:        return MESSAGE_NAME_SUBTITLE;
        case MESSAGE_CLASS_REDSUBTITLE:     return MESSAGE_NAME_REDSUBTITLE;
        case MESSAGE_CLASS_PICKUP:          return MESSAGE_NAME_PICKUP;
        case MESSAGE_CLASS_SAY:             return MESSAGE_NAME_SAY;
        case MESSAGE_CLASS_TEAMSAY:         return MESSAGE_NAME_TEAMSAY;
        case MESSAGE_CLASS_NORUNEPOWER:     return MESSAGE_NAME_NORUNEPOWER;
        case MESSAGE_CLASS_CRITICALEVENT:   return MESSAGE_NAME_CRITICALEVENT;
        case MESSAGE_CLASS_DEATHMESSAGE:    return MESSAGE_NAME_DEATHMESSAGE;
        case MESSAGE_CLASS_EVENT:           return MESSAGE_NAME_EVENT;
        default:                            return MESSAGE_NAME_DEFAULT;
    }
}

static function Name GetMessageTypeNameDefault()
{ return GetMessageTypeName(MESSAGE_CLASS_DEFAULT); }

static function Name GetMessageTypeNamePreGame()
{ return GetMessageTypeName(MESSAGE_CLASS_PREGAME); }

static function Name GetMessageTypeNameStartingGame()
{ return GetMessageTypeName(MESSAGE_CLASS_STARTINGGAME); }

static function Name GetMessageTypeNameLiveGame()
{ return GetMessageTypeName(MESSAGE_CLASS_LIVEGAME); }

static function Name GetMessageTypeNamePostGame()
{ return GetMessageTypeName(MESSAGE_CLASS_POSTGAME); }

static function Name GetMessageTypeNamePlayerReady()
{ return GetMessageTypeName(MESSAGE_CLASS_PLAYERREADY); }

static function Name GetMessageTypeNamePlayerKilled()
{ return GetMessageTypeName(MESSAGE_CLASS_PLAYERKILLED); }

static function Name GetMessageTypeNamePreRound()
{ return GetMessageTypeName(MESSAGE_CLASS_PREROUND); }

static function Name GetMessageTypeNameStartingRound()
{ return GetMessageTypeName(MESSAGE_CLASS_STARTINGROUND); }

static function Name GetMessageTypeNamePostRound()
{ return GetMessageTypeName(MESSAGE_CLASS_POSTROUND); }


////////////////////////////////////////////////////////////////////////////////
//  MessageTypeClasses
////////////////////////////////////////////////////////////////////////////////
static function Class<LocalMessage> GetMessageTypeClass(Name MessageName)
{
    switch(MessageName)
    {
        case MESSAGE_NAME_PREGAME:          return MESSAGE_CLASS_PREGAME;   
        case MESSAGE_NAME_STARTINGGAME:     return MESSAGE_CLASS_STARTINGGAME;
        case MESSAGE_NAME_LIVEGAME:         return MESSAGE_CLASS_LIVEGAME;
        case MESSAGE_NAME_POSTGAME:         return MESSAGE_CLASS_POSTGAME;
        case MESSAGE_NAME_PLAYERREADY:      return MESSAGE_CLASS_PLAYERREADY;
        case MESSAGE_NAME_PLAYERKILLED:     return MESSAGE_CLASS_PLAYERKILLED;
        case MESSAGE_NAME_PREROUND:         return MESSAGE_CLASS_PREROUND;     
        case MESSAGE_NAME_STARTINGROUND:    return MESSAGE_CLASS_STARTINGROUND;
        case MESSAGE_NAME_POSTROUND:        return MESSAGE_CLASS_POSTROUND;
        case MESSAGE_NAME_SUBTITLE:         return MESSAGE_CLASS_SUBTITLE;
        case MESSAGE_NAME_REDSUBTITLE:      return MESSAGE_CLASS_REDSUBTITLE;
        case MESSAGE_NAME_PICKUP:           return MESSAGE_CLASS_PICKUP;
        case MESSAGE_NAME_SAY:              return MESSAGE_CLASS_SAY;
        case MESSAGE_NAME_TEAMSAY:          return MESSAGE_CLASS_TEAMSAY;
        case MESSAGE_NAME_NORUNEPOWER:      return MESSAGE_CLASS_NORUNEPOWER;
        case MESSAGE_NAME_CRITICALEVENT:    return MESSAGE_CLASS_CRITICALEVENT;
        case MESSAGE_NAME_DEATHMESSAGE:     return MESSAGE_CLASS_DEATHMESSAGE;
        case MESSAGE_NAME_EVENT:            return MESSAGE_CLASS_EVENT;
        default:                            return MESSAGE_CLASS_DEFAULT;
    }
}

static function Class<LocalMessage> GetMessageTypeClassDefault()
{ return GetMessageTypeClass(MESSAGE_NAME_DEFAULT); }

static function Class<LocalMessage> GetMessageTypeClassPreGame()
{ return GetMessageTypeClass(MESSAGE_NAME_PREGAME); }

static function Class<LocalMessage> GetMessageTypeClassStartingGame()
{ return GetMessageTypeClass(MESSAGE_NAME_STARTINGGAME); }

static function Class<LocalMessage> GetMessageTypeClassLiveGame()
{ return GetMessageTypeClass(MESSAGE_NAME_LIVEGAME); }

static function Class<LocalMessage> GetMessageTypeClassPostGame()
{ return GetMessageTypeClass(MESSAGE_NAME_POSTGAME); }

static function Class<LocalMessage> GetMessageTypeClassPlayerReady()
{ return GetMessageTypeClass(MESSAGE_NAME_PLAYERREADY); }

static function Class<LocalMessage> GetMessageTypeClassPlayerKilled()
{ return GetMessageTypeClass(MESSAGE_NAME_PLAYERKILLED); }

static function Class<LocalMessage> GetMessageTypeClassPreRound()
{ return GetMessageTypeClass(MESSAGE_NAME_PREROUND); }

static function Class<LocalMessage> GetMessageTypeClassStartingRound()
{ return GetMessageTypeClass(MESSAGE_NAME_STARTINGROUND); }

static function Class<LocalMessage> GetMessageTypeClassPostRound()
{ return GetMessageTypeClass(MESSAGE_NAME_POSTROUND); }