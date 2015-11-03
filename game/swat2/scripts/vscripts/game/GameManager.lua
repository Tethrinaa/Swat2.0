-- This file will be responsible as the "master" of the "game" logic, which includes things like the spawn system, radiation, difficulty tracking...etc
-- This file will also store a lot of the global generic variables used by game systems

GameManager = {}

SHOW_GAME_SYSTEM_LOGS = true

-- Systems GameManager is responsible for
require('game/Locations')
require('game/EnemyUpgrades')
require('game/EnemySpawner')
require('game/EnemyCommander')
require('game/objectives/RadiationManager')

-- The systems instances stored as global variables
g_RadiationManager = {}
g_EnemyUpgrades = {}
g_EnemySpawner = {}
g_EnemyCommander = {}

function GameManager:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- The difficulty name ("normal", "hard", "insane", "survival", "nightmare", "extinction")
    self.difficultyName = nil

    -- The game's difficulty value (used in calculations)
    --      3 = normal
    --      2 = hard
    --      1 = insane, nightmare, extinction
    --      (note: survival will change this value as time goes on)
    self.difficultyValue = 3

    -- Special survival value. (used in calculations)
    --      0 = Normal, Hard, Insane, Nightmare, Extinction
    --      1+ = Survival (increases as time goes on)
    self.survivalValue = 0

    -- Special nightmare value. (used in calculations)
    --      0 = Normal, Hard, Insane, Survival
    --      1 = Nightmare
    --      2 = Extinction
    self.nightmareValue = 0

    -- Special nightmare value. (used in calculations)
    --      0 = Normal, Hard, Insane
    --      1 = Survival, Nightmare, Extinction
    self.nightmareOrSurvivalValue = 0

    -- Boolean for if we're in survival mode
    self.isSurvival = false

    -- Current day (incremented every day cycle)
    self.currentDay = 1

    -- Total number of heroes (including those made by CPU slots)
    self.playerCount = 1

    -- Difficulty related variables
    -- difficultyBase - A constant value (except on survival), which scales the difficulty of the game over time
    --                - LOWER == MORE DIFFICULT
    self.difficultyBase = 0.0
    -- difficultyTime - This difficulty value increases over time (sunrise and sunset) based on the difficultyBase value
    --                - HIGHER == MORE DIFFICULT
    self.difficultyTime = 3.0

    -- Keeps track of the nemesis fight's stage.
    self.nemesisStage = 0


    -- Keeps track of the last building a player walked in
    -- This should store the Entity Trigger itself, not an index!
    -- TODO: Update this
    self.lastBuildingEntered = nil

    -- Boot up the systems
    self:initializeSystems()

    return o
end

function GameManager:initializeSystems()
    -- Note: Make sure locations are set up before anything else
    initializeGlobalLocations()


    g_RadiationManager = RadiationManager:new()
    g_EnemyUpgrades = EnemyUpgrades:new()
    g_EnemySpawner = EnemySpawner:new()
    g_EnemyCommander = EnemyCommander:new()
end

-- Sets the game to one of the selectable options
function GameManager:setDifficulty(difficulty)
    if SHOW_GAME_SYSTEM_LOGS then
        print("GameManager | Setting difficulty to: " .. difficulty)
    end
    self.difficultyName = difficulty
    if difficulty == "normal" then
        -- Normal mode
        self.difficultyValue = 3
        self.difficultyBase = 2.0
    elseif difficulty == "hard" then
        -- Hard mode
        self.difficultyValue = 2
        self.difficultyBase = 1.5
    elseif difficulty == "insane" then
        -- Insane mode
        self.difficultyValue = 1
        self.difficultyBase = 1.0
    elseif difficulty == "survival" then
        -- Survival mode
        self.difficultyValue = 3
        self.difficultyBase = 1.7 -- Note: This will change over time for survival
        self.isSurvival = true
        self.nightmareOrSurvivalValue = 1
    elseif difficulty == "nightmare" then
        -- Nightmare mode  (should be set after another difficulty was set)
        self.difficultyValue = 1
        self.difficultyBase = 1.0
        self.difficultyTime = 6.6
        self.nightmareOrSurvivalValue = 1
        self.nightmareValue = 1
    elseif difficulty == "extinction" then
        -- Extinction mode (should be set after another difficulty was set)
        self.difficultyValue = 1
        self.difficultyBase = 0.85
        self.difficultyTime = 12.6
        self.nightmareOrSurvivalValue = 1
        self.nightmareValue = 2
    else
        -- Unknown? Error! (Shouldn't happen)
        self.difficultyName = nil
        print("GameManager | UNKNOWN DIFFICULTY SET!: '" .. difficulty .. "'")
    end

    -- Spawn creates, power plants, abms...etc
    self:initializeBuildings()

    -- Now tell whoever needs to know about the difficulty changing
    g_RadiationManager:onDifficultySet(difficulty)
    g_EnemyUpgrades:onDifficultySet(difficulty)
    g_EnemySpawner:onDifficultySet(difficulty)

end

-- Called once difficulty set.
-- Spawns the creates, abms, powerplants...etc
function GameManager:initializeBuildings()
    -- Create the various building types in the game
    Locations:createRooms()

    -- TODO: Spawn Power Plants

    -- TODO: Spawn ABMs

    -- TODO: Spawn Crates

end

