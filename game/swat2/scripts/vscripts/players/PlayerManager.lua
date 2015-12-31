-- The main manager of player related functions

SHOW_PLAYER_LOGS = SHOW_DEBUG_LOGS

-- Systems and classes PlayerManager is responsible for
require('players/ExperienceManager')
require('players/PlayerBuilder')
require('players/PlayerInfo')
require('players/PlayerHudManager')
require('players/GoldManager')

-- The systems instance stored as global variables
g_ExperienceManager = {}
g_PlayerBuilder = {}
g_PlayerHudManager = {}
g_GoldManager = {}

PlayerManager = {}
function PlayerManager:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.playersInfo = {}

    self.playerCount = PlayerResource:GetPlayerCountForTeam(DOTA_TEAM_GOODGUYS)
    if SHOW_PLAYER_LOGS then
        print("PlayerManager | Initializing. Player Count = " .. self.playerCount)
    end

    self:initializeSystems()

    return o
end

function PlayerManager:initializeSystems()
    g_ExperienceManager = ExperienceManager:new()
    g_PlayerBuilder = PlayerBuilder:new()
    g_PlayerHudManager = PlayerHudManager:new()
	g_GoldManager = GoldManager:new()
end

-- Called when the first player loads in and pregame has started
function PlayerManager:onPreGameStarted()
    g_PlayerBuilder:onPreGameStarted()
    g_ExperienceManager:onPreGameStarted()
    g_PlayerHudManager:startHudUpdateLoop()
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
function PlayerManager:onPlayerLoadedSwatHero(playerInfo)
    if SHOW_PLAYER_LOGS then
        print("PlayerManager | onPlayerLoaded | index=" .. playerInfo.playerIndex)
    end

    g_ExperienceManager:updateExperienceModifier()

    -- Add the player info so other systems can use it
    table.insert(self.playersInfo, playerInfo)

   -- Alert for uber calculations
   g_EnemyUpgrades:onPlayerLevelUp(playerInfo.playerIndex, 1)
end

function PlayerManager:onPlayerLeftGame(playerId)
    -- TODO Call this when someone leaves? (we first need to handle reconnects if that is possible)
    self.playerCount = self.playerCount - 1
    g_ExperienceManager:updateExperienceModifier()
end

-- Returns the player info for the supplied player id (or nil if there isn none)
function PlayerManager:getPlayerInfoForPlayerId(playerId)
    playerId = tonumber(playerId)
    for _,playerInfo in pairs(self.playersInfo) do
        print(tostring(playerInfo.playerId) .. " == " .. tostring(playerId) .. " | " .. tostring(tonumber(playerInfo.playerId) == tonumber(playerId)))
        print("PlayerInfo ID=" .. playerInfo.playerId)
        if tonumber(playerInfo.playerId) == playerId then
            return playerInfo
        end
    end
    return nil
end

-- Returns the player info for the supplied player id (or nil if there isn none)
function PlayerManager:getPlayerHeroes()
    local playerHeroes = {}
    for _,playerInfo in pairs(self.playersInfo) do
        table.insert(playerHeroes, playerInfo.hero)
    end
    return playerHeroes
end

function PlayerManager:onHeroDies(killedUnit, killerEntity, killerAbility)
  LeaveCorpse( killedUnit )
end
