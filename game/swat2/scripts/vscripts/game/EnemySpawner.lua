-- This file will be responsible spawning waves.
--

SHOW_ENEMY_SPAWNER_LOGS = SHOW_GAME_SYSTEM_LOGS
SHOW_BOSS_LOGS = SHOW_ENEMY_SPAWNER_LOGS -- Will enable showing log messages in the boss files
SHOW_MINION_LOGS = SHOW_ENEMY_SPAWNER_LOGS -- Will enable showing log messages in the minion files

EnemySpawner = {}

-- Require the minion and boss files we'll be using
require("game/bosses/AbominationSpawner")
require("game/bosses/HorrorSpawner")
require("game/bosses/TyrantSpawner")
require("game/minions/ZombieSpawner")
require("game/minions/BeastSpawner")
require("game/minions/MutantSpawner")
require("game/minions/DogSpawner")
require("game/minions/GrotesqueSpawner")
require("game/minions/InnardsSpawner")

EnemySpawner.MAX_MINIONS = 200 -- The cap on minions that are allowed out before we add them to the minion queue
EnemySpawner.MAX_MINIONS_WAVE_START = EnemySpawner.MAX_MINIONS / 3 -- If mobs over this amount when a wave wants to start, it waits (and buffs existing mobs)
EnemySpawner.MAX_GROUP_SIZE = 21 -- The largest size a minion group can be

EnemySpawner.WAVE_SPAWN_DELAY = 30 -- The wait time from difficulty being set to when we start the wave spawning (note: the first wave will still take an additional 85-105 seconds)
EnemySpawner.BOSS_SPAWN_DELAY = 45 -- The wait time from waves spawning before boss wave cycle begins (note: the first boss will still have an initial wait period)

-- At least one of these conditions needs to be met for a boss to spawn
EnemySpawner.BOSS_CHECK_MINION_COUNT = EnemySpawner.MAX_MINIONS / 4 * 3 -- The current number of minions must be less than this
EnemySpawner.BOSS_CHECK_QUEUE_COUNT = EnemySpawner.MAX_MINIONS / 8 -- The minion queue must be lower than this
EnemySpawner.BOSS_CHECK_TYRANT_QUEUE_COUNT = EnemySpawner.MAX_MINIONS / 8  * 7 -- The minion queue + this amount must be less than last queue amount when we spawned a tyrant

-- An enum for the type of enemy to spawn
EnemySpawner.ENEMY_CODE_ZOMBIE = 0
EnemySpawner.ENEMY_CODE_GROTESQUE = 1
EnemySpawner.ENEMY_CODE_BEAST = 2
EnemySpawner.ENEMY_CODE_DOG = 3
EnemySpawner.ENEMY_CODE_MUTANT = 4

function EnemySpawner:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- Number of minions out (that count against the cap)
    self.minionCount = 0

    -- Number of bosses
    self.bossCount = 0

    -- Count of killed minions (just keeps incrementing)
    self.minionsKilled = 0

    -- Number of groups remaining in current wave
    self.waveGroups = 0
    -- count of minions added to "overflow"
    self.minionQueue = 0

    -- Time between we roll for wave spawns
    self.waveGroupDelay = 6

    -- Chance of spawning innards (higher == more chance)
    self.innardsChance = 0

    -- Minion Spawners
    self.zombieSpawner = ZombieSpawner:new()
    self.beastSpawner = BeastSpawner:new()
    self.mutantSpawner = MutantSpawner:new()
    self.dogSpawner = DogSpawner:new()
    self.grotesqueSpawner = GrotesqueSpawner:new()
    self.innardsSpawner = InnardsSpawner:new()

    -- Boss parameters
    self.abomsCurrentlyAlive = 0

    self.abomSpawner = AbominationSpawner:new() -- There are situations where we just need to spawn an abom
    self.tyrantSpawner = TyrantSpawner:new() -- There are situations where we just need to spawn an abom
    local horrorSpawner = HorrorSpawner:new()

    -- Create the bosses list [Order is Important! Abom last!!] (for all difficulties except Normal)
    self.bosses = {}
    table.insert(self.bosses, horrorSpawner)
    table.insert(self.bosses, self.abomSpawner)

    -- Normal can only get a few bosses [Order is Important! Abom last!!]
    self.normalDiffBosses = {}
    table.insert(self.normalDiffBosses, horrorSpawner)
    table.insert(self.normalDiffBosses, self.abomSpawner)

    self.survivalDoubleBoss = false -- true if the last boss spawn was a double boss
    self.useTyrantTrack = 0 -- Used for tracking tyrant spawning
    self.useTyrantQueue = 0 -- Stores the minion queue count when we last spawned a tyrant

    return o
end

-- Should be called when the difficulty is set in GameManager
function EnemySpawner:onDifficultySet(difficulty)
    if difficulty == "normal" then
        -- Normal mode
        self.innardsChance = 1
        self.waveGroupDelay = 6
    elseif difficulty == "hard" then
        -- Hard mode
        self.innardsChance = 1
        self.waveGroupDelay = 5
    elseif difficulty == "insane" then
        -- Insane mode
        self.innardsChance = 2
        self.waveGroupDelay = 5
    elseif difficulty == "survival" then
        -- Survival mode
        self.innardsChance = 1
        self.waveGroupDelay = 5
    elseif difficulty == "nightmare" then
        -- Nightmare mode  (should be set after another difficulty was set)
        self.innardsChance = 1
        self.waveGroupDelay = 5
    elseif difficulty == "extinction" then
        -- Extinction mode (should be set after another difficulty was set)
        self.innardsChance = 1
        self.waveGroupDelay = 5
    else
        -- Unknown? Error! (Shouldn't happen)
        print("EnemyUpgrades | UNKNOWN DIFFICULTY SET!: '" .. difficulty .. "'")
    end

    -- Spawn some initial zombies (we had to wait for difficulty so we can get the room layouts)
    self:spawnInitialZombies()
end

-- Called when the first player loads in and pregame has started
function EnemySpawner:onPreGameStarted()
    -- Spawn some zombies in the graveyard
    self:spawnZombiesInGraveyard()
end

-- Called when the horn blows and the game begins
function EnemySpawner:onGameStarted()
    -- Start wave spawning in 30 seconds
    Timers:CreateTimer(EnemySpawner.WAVE_SPAWN_DELAY, function()
        self:startWaveSpawning()
    end)
end


function EnemySpawner:canSpawnMinion()
    return self.minionCount < EnemySpawner.MAX_MINIONS
end


--------------------------
----- ENEMY WAVE SPAWNING
--------------------------

function EnemySpawner:startWaveSpawning()
    if SHOW_ENEMY_SPAWNER_LOGS then
        print("EnemySpawner | Starting Wave Spawning")
    end

    -- Start the CollectEmUp cycle
    g_EnemyCommander:startCollectEmUpCycle()

    -- Start the wave spawning
    self:spawnWave()

    Timers:CreateTimer(EnemySpawner.BOSS_SPAWN_DELAY, function()
        if SHOW_ENEMY_SPAWNER_LOGS then
            print("EnemySpawner | Starting Boss Spawn Cycle")
        end
        self:startBossCycle()
    end)
end

-- This method will go through the actions of a single wave
function EnemySpawner:spawnWave()
    if self.minionCount > EnemySpawner.MAX_MINIONS_WAVE_START then
        -- Too many minions out to spawn a new wave!
        if SHOW_ENEMY_SPAWNER_LOGS then
            print("EnemySpawner | Too many minions out to start a new wave")
        end
        -- Wait 15 seconds
        Timers:CreateTimer(15, function()
            -- Buff the zombies and try to spawn a wave
            g_EnemyUpgrades.mobSpeed = g_EnemyUpgrades.mobSpeed + 0.5
            self:spawnWave()
        end)
    else
        -- Begin the wave!
        self.minionQueue = 0
        g_EnemyUpgrades.mobSpeed = 0 -- Reset the buffs we gave to the previous wave while we waited

        -- Each wave group will spawn with about 5-15 seconds delays until we run out of groups
        local numberOfWaveGroups = 51 + g_PlayerManager.playerCount + ( 3 * g_GameManager.nightmareValue * g_GameManager.nightmareValue)

        -- We need to wait a bit before actually starting the wave (give the players a breather)
        local waveInitialWaitTime = 75.0 + (math.min(self.bossCount, 2) * 20.0) + 10 * ( g_GameManager.difficultyValue - math.min(g_GameManager.survivalValue, 4) )

        if SHOW_ENEMY_SPAWNER_LOGS then
            print("EnemySpawner | New Wave Starting in " .. waveInitialWaitTime .. " seconds")
            print("EnemySpawner | Spawning " .. numberOfWaveGroups .. " wave groups!")
        end

        Timers:CreateTimer(waveInitialWaitTime, function()
            -- There is a random chance we don't do anything
            local i = 0
            if g_GameManager.nightmareValue > 0 and g_GameManager.currentDay > 1 then
                i = 18 - (g_PlayerManager.playerCount / 4) - (g_GameManager.nightmareValue * g_GameManager.nightmareValue)
            else
                i = math.max(g_GameManager.difficultyValue * 10, 19 - (g_PlayerManager.playerCount / 4))
            end

            if RandomInt(1 + g_GameManager.survivalValue, 100) > i then
                -- We passed our random chance.
                numberOfWaveGroups = numberOfWaveGroups - 1
                if numberOfWaveGroups < 0 then
                    -- We're done spawning waves, start spawning the minion queue
                    self:spawnQueueGroups()
                else
                    -- Spawn a wave group!

                    -- Figure out a location for the spawn group
                    local location = nil
                    if g_GameManager.lastBuildingEntered ~= nil then
                        location = g_GameManager.lastBuildingEntered
                        g_GameManager.lastBuildingEntered = nil
                    else
                        location = GetRandomWarehouse()
                    end

                    self:spawnMinionGroup(location, true)

                    -- We have more wave groups. Just restart this timer
                    return self.waveGroupDelay
                end
            else
                -- We failed the roll. Wait waveGroupDelay and try again
                return self.waveGroupDelay
            end
        end)
    end
end

-- Spawns a group of minions at the provided location
-- If we can't spawn a minion because of minion cap, it will add one to the minion queue
--      if shouldAddToMinionQueueIfFail is true
--  @param location | A Trigger in which to randomly spawn enemies in
function EnemySpawner:spawnMinionGroup(location, shouldAddToMinionQueueIfFail)
    local groupSize = RandomInt( 4 - g_GameManager.difficultyValue + ( g_EnemyUpgrades.minionUber / 90 )
            , 6 - g_GameManager.difficultyValue + Round( g_EnemyUpgrades.minionUber / 30.0 + g_GameManager.difficultyTime / 4.8) + g_GameManager.survivalValue )

    if g_GameManager.nemesisStage < 1 then
        if groupSize > EnemySpawner.MAX_GROUP_SIZE then
            groupSize = EnemySpawner.MAX_GROUP_SIZE
        end
        if SHOW_ENEMY_SPAWNER_LOGS then
            if shouldAddToMinionQueueIfFail then
                print("EnemySpawner | Spawning WaveGroup of " .. groupSize .. " enemies")
            else
                print("EnemySpawner | Spawning Queue WaveGroup of " .. groupSize .. " enemies. Queue size = " .. self.minionQueue)
            end
        end

        local spawnedUnits = {}

        -- 75% of the wave is always zombies (and maybe one mutant based on radiation level)
        local j = Round(groupSize * .25) + 1
        if groupSize > j and RandomInt(1, 4) < g_RadiationManager.radiationLevel then
            groupSize = groupSize - 1
            local unit = self:spawnEnemy(EnemySpawner.ENEMY_CODE_MUTANT, GetRandomPointInRegion(location), 0, shouldAddToMinionQueueIfFail)
            if unit ~= nil then
                table.insert(spawnedUnits, unit)
            end
        end
        while groupSize > j do
            groupSize = groupSize - 1
            local unit = self:spawnEnemy(EnemySpawner.ENEMY_CODE_ZOMBIE, GetRandomPointInRegion(location), 0, shouldAddToMinionQueueIfFail)
            if unit ~= nil then
                table.insert(spawnedUnits, unit)
            end
        end

        -- The rest of the wave can be anything
        while groupSize > 0 do
            groupSize = groupSize - 1
            j = RandomInt(0, 9)
            local position = GetRandomPointInRegion(location)

            local unit = nil
            if j < 1 then
                unit = self:spawnEnemy(EnemySpawner.ENEMY_CODE_BEAST, position, RandomInt(0 - g_EnemyUpgrades.nightmareUpgrade, 77), shouldAddToMinionQueueIfFail)
            elseif j < 2 then
                unit = self:spawnEnemy(EnemySpawner.ENEMY_CODE_GROTESQUE, position, 30, shouldAddToMinionQueueIfFail)
            elseif j < 4 then
                unit = self:spawnEnemy(EnemySpawner.ENEMY_CODE_DOG, position, RandomInt(0 - g_EnemyUpgrades.nightmareUpgrade, 77), shouldAddToMinionQueueIfFail)
            else
                -- TODO: Not 100% this is radiationLevel (which it is in source) and not radiationFragments
                if RandomInt(-1, 43) < g_RadiationManager.radiationLevel then
                    unit = self:spawnEnemy(EnemySpawner.ENEMY_CODE_MUTANT, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
                else
                    unit = self:spawnEnemy(EnemySpawner.ENEMY_CODE_ZOMBIE, GetRandomPointInRegion(location), RandomInt(1, 13), shouldAddToMinionQueueIfFail)
                end
            end
            if unit ~= nil then
                table.insert(spawnedUnits, unit)
            end
        end

        -- Tell the group where to go
        -- Issueing an order to a unit immediately after it spawns seems to not consistently work
        -- so we'll wait a second before telling the group where to go
        Timers:CreateTimer(1.0, function()
            for _,unit in pairs(spawnedUnits) do
                g_EnemyCommander:doMobAction(unit, nil)
            end
        end)

    else
        -- Nemesis fight spawns minions in graveyard
        -- TODO
    end
end

-- Begins summoning from the queue until the queue is empty
-- Once the queue is empty, we summon another wave
function EnemySpawner:spawnQueueGroups()
    if self.minionQueue > 0 then
        if SHOW_ENEMY_SPAWNER_LOGS then
            print("EnemySpawner | Spawning from Queue")
        end
        local waitTimeBetweenQueueWaves = self.waveGroupDelay - g_GameManager.difficultyValue
        Timers:CreateTimer(waitTimeBetweenQueueWaves, function()
            if self.minionQueue  > 0 then
                if self.minionCount >= EnemySpawner.MAX_MINIONS then
                    if SHOW_ENEMY_SPAWNER_LOGS then
                        print("EnemySpawner | Queue Waiting - too many enemies already out")
                    end
                    -- Too many minions for the queue
                    -- Collect up the current zombies (which minorly buffs them) and wait to try again
                    g_EnemyCommander:collectEmUp()
                    return 48 - (2 * g_PlayerManager.playerCount)
                else
                    -- Spawn a full wave group regardless of how many are in the minion queue
                    local location = GetRandomWarehouse()
                    self:spawnMinionGroup(location, false)

                    return waitTimeBetweenQueueWaves
                end
            else
                if SHOW_ENEMY_SPAWNER_LOGS then
                    print("EnemySpawner | Queue now empty. Begin the next wave")
                end
                self:spawnWave()
            end
        end)
    else
        -- No queue, we can just start the next wave
        if SHOW_ENEMY_SPAWNER_LOGS then
            print("EnemySpawner | No minions queued up. Begin the next wave")
        end
        self:spawnWave()
    end

end

-- Generic enemy spawner. Should pass in an enemy code defined here
function EnemySpawner:spawnEnemy(enemy, position, specialType, shouldAddToMinionQueueIfFail)
    if self.minionCount >= EnemySpawner.MAX_MINIONS then
        -- Too many units in play, just add this unit to the minion queue
        -- Nauty players will be punished, but the minions now go into the minion queue
        if(shouldAddToMinionQueueIfFail) then
            self.minionQueue = self.minionQueue + 1
        end

        if SHOW_ENEMY_SPAWNER_LOGS then
            if(shouldAddToMinionQueueIfFail) then
                print("EnemySpawner | Adding enemy to minion queue! Queue size = " .. self.minionQueue)
            else
                print("EnemySpawner | Couldn't spawn queued enemy!")
            end
        end
    else
        -- We can spawn this unit

        -- Decrement the minion queue
        if self.minionQueue > 0 then
            self.minionQueue = self.minionQueue - 1
        end
        self.minionCount = self.minionCount + 1

        local unit = nil
        if enemy == EnemySpawner.ENEMY_CODE_ZOMBIE then
            unit = self.zombieSpawner:spawnMinion(position, specialType)
        elseif enemy == EnemySpawner.ENEMY_CODE_GROTESQUE then
            unit = self.grotesqueSpawner:spawnMinion(position, specialType)
        elseif enemy == EnemySpawner.ENEMY_CODE_BEAST then
            unit = self.beastSpawner:spawnMinion(position, specialType)
        elseif enemy == EnemySpawner.ENEMY_CODE_DOG then
            unit = self.dogSpawner:spawnMinion(position, specialType)
        elseif enemy == EnemySpawner.ENEMY_CODE_MUTANT then
            unit = self.mutantSpawner:spawnMinion(position)
        else
            print("EnemySpawner | WARNING - ATTEMPT TO SPAWN INVALID ENEMY CODE: " .. enemy)
        end

        -- Apply an experience value to the unit, if one was not already set in the spawner
        -- This value will be retrieved from the npc_units_custom file under the key SwatXP
        if not unit.experience then
            local unit_info = GameMode.unit_infos[unit:GetUnitName()]
            if unit_info then
                local experience = unit_info["SwatXP"]
                if experience then
                    unit.experience = experience
                end
            end
        end

        -- Apply enemy upgrades
        g_EnemyUpgrades:upgradeMob(unit)

        -- Let's hurt the unit a bit
        unit:SetHealth(math.max(1, unit:GetHealth() - RandomInt(0,99)))
        -- Set its speed
        unit:SetBaseMoveSpeed(g_EnemyUpgrades:calculateMovespeed(unit, g_GameManager.nemesisStage))

        return unit
    end

end

function EnemySpawner:onEnemyDies(killedUnit, killerEntity, killerAbility)

    -- Units that are Ancients on the DOTA_TEAM_BADGUYS should be ignored (like rad frags)
    if not killedUnit:IsAncient() then
        g_EnemySpawner.minionsKilled = g_EnemySpawner.minionsKilled + 1
        g_EnemySpawner.minionCount = math.max(0, g_EnemySpawner.minionCount - 1)

        -- Award experience if this unit has it
        if killedUnit.experience ~= nil and killedUnit.experience > 0 then
            g_ExperienceManager:awardExperience(killedUnit.experience)
        end

        -- When enemies are spawned, they can add and onDeath function to the onDeathFunction parameter
        -- of the unit. Here the EnemySpawner will call that function
        local onDeathFunction = killedUnit.onDeathFunction
        if onDeathFunction ~= nil then
            onDeathFunction(killedUnit, killerEntity, killerAbility)
        end
    end
end






--------------------------
----- BOSS STUFF
--------------------------

-- Function related to boss cycle
-- This function will spin up a timer and periodically spawn bosses
function EnemySpawner:startBossCycle()
    -- Bosses will not spawn if the minion count is too high, but we'll only wait so long...
    local waitCount = 11 - (g_GameManager.nightmareValue * g_GameManager.nightmareValue)

    if self.useTyrantTrack > 1 then
        waitCount = waitCount + 15 - (g_GameManager.nightmareValue * g_GameManager.nightmareValue)
    end

    if (not self.survivalDoubleBoss)
        and (g_GameManager.currentDay > 1)
        and (g_GameManager.nightmareOrSurvivalValue > 0)
        and (RandomInt(0, 4) < g_GameManager.nightmareOrSurvivalValue) then
        -- Spawn this boss really quickly (the ole Survival double boss)
        self.survivalDoubleBoss = true
        waitCount = waitCount + 5

        -- Wait for a bit then call the bossWaitForMinions
        Timers:CreateTimer(30 - (24 * g_GameManager.nightmareValue / 2), function()
            self:bossWaitForMinions(waitCount)
        end)
    elseif g_GameManager.isSurvival then
        -- Survival Mode
        self.survivalDoubleBoss = false

        local waitTimeFirst = math.max(40, (2 + g_GameManager.difficultyValue) * 60.0 - RandomInt(-10 * g_GameManager.difficultyValue, 10) - Round(g_GameManager.difficultyTime * 10.0))
        Timers:CreateTimer(waitTimeFirst, function()
            -- Now we wait again
            local waitTimeSecond = math.max(40, (2 + g_GameManager.difficultyValue) * 60.0 - RandomInt(-10 * g_GameManager.difficultyValue, 10) - Round(g_GameManager.difficultyTime * 5.0))
            Timers:CreateTimer(waitTimeSecond, function()
                self:bossWaitForMinions(waitCount)
            end)
        end)
    else
        -- Other modes
        self.survivalDoubleBoss = false

        local waitTimeFirst = math.max(90, (2 + g_GameManager.difficultyValue) * 60.0 - RandomInt(-10 * g_GameManager.difficultyValue, 10) - Round(g_GameManager.difficultyTime * 6.0))
        --print("EnemySpawner | Boss Spawning: First Wait: " .. waitTimeFirst)
        Timers:CreateTimer(waitTimeFirst, function()
            -- Now we wait again
            local waitTimeSecond = math.max(30 * g_GameManager.difficultyValue, (2 + g_GameManager.difficultyValue) * 60.0 - RandomInt(-10 * g_GameManager.difficultyValue, 10) - Round(g_GameManager.difficultyTime * 2.0))
            --print("EnemySpawner | Boss Spawning: Second Wait: " .. waitTimeSecond)
            Timers:CreateTimer(waitTimeSecond, function()
                self:bossWaitForMinions(waitCount)
            end)
        end)
    end
end

-- When we try to spawn a boss, we need to wait for the minion count to drop
-- We'll only wait `waitCount` amount of times before just spawning a Tyrant (and then the boss anyways)
function EnemySpawner:bossWaitForMinions(waitCount)
    Timers:CreateTimer(0, function()
        -- TODO: fix the second line to include something about queued lives
        -- exitwhen (udg_MinionQueue - udg_QLi/8*7) < (udg_MinionMax / 8) //queue is low, reincarnates counted against you only 12.5%
        if (self.minionCount < EnemySpawner.BOSS_CHECK_MINION_COUNT)
            or (self.minionQueue < EnemySpawner.BOSS_CHECK_QUEUE_COUNT)
            or (self.minionQueue + EnemySpawner.BOSS_CHECK_TYRANT_QUEUE_COUNT < self.useTyrantQueue) then
            -- We can spawn a boss

            -- Reset the tyrant variables
            self.useTyrantQueue = 0
            self.useTyrantTrack = 0

            -- Spawn the boss
            self:spawnBoss()

            -- Start the next boss cycle
            self:startBossCycle()
        else
            if SHOW_ENEMY_SPAWNER_LOGS then
                print("EnemySpawner | Boss is waiting to spawn! waitCount=" .. waitCount)
            end
            -- we can't spawn a boss, if we have wait counts we can wait
            if waitCount > 0 then
                waitCount = waitCount - 1
                return 8.5
            else
                -- We can't wait anymore, spawn a tyrant
                self.useTyrantQueue = self.minionQueue
                if self.useTyrantTrack < 2 then
                    self.useTyrantTrack = 3
                end
                self.tyrantSpawner:spawnBoss()

                -- Wait 20 seconds
                Timers:CreateTimer(20, function()
                    self.useTyrantTrack = 2
                    -- Lol, we'll still spawn a boss on them. No buddy puts baby in a corner
                    self:spawnBoss()

                    -- Start the next boss cycle
                    self:startBossCycle()
                end)
            end
        end

    end)
end

function EnemySpawner:spawnBoss()
    local boss = nil
    if g_GameManager.currentDay == 1 then
        -- We can only spawn Aboms on day 1
        boss = self.abomSpawner:spawnBoss()
    elseif g_GameManager.difficultyName == "normal" then
        -- Normal mode can only get Aboms and Horrors on Day > 1
        for _,bossSpawner in pairs(self.normalDiffBosses) do
            if bossSpawner:rollToSpawn() then
                boss = bossSpawner:spawnBoss()
            end
        end
    else
        -- Pick a random boss
        for _,bossSpawner in pairs(self.bosses) do
            if bossSpawner:rollToSpawn() then
                boss = bossSpawner:spawnBoss()
            end
        end
    end
    if SHOW_ENEMY_SPAWNER_LOGS then
        print("EnemySpawner | Spawning boss!! (" .. ((boss ~= nil) and boss:GetName() or "nil??") .. ")")
    end
end




--------------------------
----- OTHER STUFF
--------------------------




-- Function called at the start of the game to populate the starting map
function EnemySpawner:spawnInitialZombies()
    -- Spawn zombies in rooms!
    -- We always have a chance to spawn zombies in the non-power plant special rooms
    local specialBuildingsThatGetZombies = {
            Locations.abms
            , Locations.atme_rooms
            , Locations.clothing_room
            , Locations.chemical_plants
            , Locations.armories
            , Locations.tech_centers
            , Locations.cybernetic_facilities}
    for _,locationGroup in pairs(specialBuildingsThatGetZombies) do
        for _,location in pairs(locationGroup) do
            g_EnemySpawner:spawnInitialZombiesInWarehouse(location)
        end
    end
    -- Less chance in empty warehouses though
    local chance = g_GameManager.difficultyValue * 24
    for _,location in pairs(Locations.empty_warehouses) do
        if RandomInt(0, 99) > chance then
            g_EnemySpawner:spawnInitialZombiesInWarehouse(location)
        end
    end
end

-- Function called at the start of the game and when players enter the graveyard
-- Creates some zombies in the graveyard
function EnemySpawner:spawnZombiesInGraveyard()
    local zombiesToSpawn = RandomInt(24 / g_GameManager.difficultyValue, 50 - (8 * g_GameManager.difficultyValue))
    for i = 1,zombiesToSpawn do
        self:spawnEnemy(EnemySpawner.ENEMY_CODE_ZOMBIE, GetRandomPointInGraveyard(), 0, true)
    end
end

-- Function called when we initialize buildings. It has a chance to spawn a small amount of zombies in the supplied region
-- The zombies will head off to the graveyard
function EnemySpawner:spawnInitialZombiesInWarehouse(region)
    local zombiesToSpawn = RandomInt(-5, 4 - g_GameManager.difficultyValue)
    local units = {}
    for i = 1,zombiesToSpawn do
        units[i] = self:spawnEnemy(EnemySpawner.ENEMY_CODE_ZOMBIE, GetRandomPointInRegion(region), 0, true)
    end
    Timers:CreateTimer(10.0, function()
        for _,unit in pairs(units) do
            ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), OrderType =  DOTA_UNIT_ORDER_ATTACK_MOVE , Position = GetRandomPointInGraveyard(), Queue = false})
        end
    end)
end

function EnemySpawner:getAllMobs()
	local retval = {}
    local enemyUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                                            Vector(0, 0, 0),
                                            nil,
                                            FIND_UNITS_EVERYWHERE,
                                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                            DOTA_UNIT_TARGET_ALL,
                                            DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,
                                            FIND_ANY_ORDER,
                                            false)
	for _,unit in pairs(enemyUnits) do
        -- Units that are Ancients on the DOTA_TEAM_BADGUYS should not be controlled or counted (like rad frags)
        if not unit:IsAncient() then
            table.insert(retval, unit)
        end
    end

	return retval
end

