-- The main manager of player related functions

SHOW_PLAYER_LOGS = SHOW_DEBUG_LOGS

-- Systems and classes PlayerManager is responsible for
require('players/ExperienceManager')
require('players/PlayerBuilder')
require('players/PlayerInfo')

-- The systems instance stored as global variables
g_ExperienceManager = {}
g_PlayerBuilder = {}

PlayerManager = {}
function PlayerManager:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.playersInfo = {}
    self.playerCount = 0

    self:initializeSystems()

    return o
end

function PlayerManager:initializeSystems()
    -- Note: Make sure locations are set up before anything else
    initializeGlobalLocations()

    g_ExperienceManager = ExperienceManager:new()
    g_PlayerBuilder = PlayerBuilder:new()
end

-- Called when the first player loads in and pregame has started
function PlayerManager:onPreGameStarted()
    g_ExperienceManager:onPreGameStarted()
end

-- Called when the horn blows and the game begins
function PlayerManager:onGameStarted()
end

-- Sets the game to one of the selectable options
function PlayerManager:setDifficulty(difficulty)
    -- Tell our systems of the difficulty
    g_ExperienceManager:onDifficultySet(difficulty)
end

-- Called when a player's hero has been created
-- @param playerInfo | A PlayerInfo object of the created hero
function PlayerManager:onPlayerLoaded(playerInfo)
    if SHOW_PLAYER_LOGS then
        print("PlayerManager | onPlayerLoaded | index=" .. playerInfo.playerIndex)
    end

    self.playerCount = self.playerCount + 1
    g_ExperienceManager:updateExperienceModifier()

    -- Add the player info so other systems can use it
    table.insert(self.playersInfo, playerInfo)

   -- Alert for uber calculations
   g_EnemyUpgrades:onPlayerLevelUp(playerInfo.playerIndex, 1)
end

function PlayerManager:onPlayerLeftGame(playerId)
    -- TODO Call this
    self.playerCount = self.playerCount - 1
    g_ExperienceManager:updateExperienceModifier()
end
