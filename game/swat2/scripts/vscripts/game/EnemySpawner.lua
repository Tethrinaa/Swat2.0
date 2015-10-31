-- This file will be responsible spawning waves.
--


EnemySpawner = {}

EnemySpawner.MAX_MINIONS = 200 -- The cap on minions that are allowed out before we add them to the minion queue
EnemySpawner.MAX_MINIONS_WAVE_START = EnemySpawner.MAX_MINIONS / 3 -- If mobs over this amount when a wave wants to start, it waits (and buffs existing mobs)
EnemySpawner.MAX_GROUP_SIZE = 21 -- The largest size a minion group can be

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

    -- Number of groups remaining in current wave
    self.waveGroups = 0
    -- count of minions added to "overflow"
    self.minionQueue = 0

    -- Time between we roll for wave spawns
    self.waveGroupDelay = 6

    -- Chance of spawning innards (higher == more chance)
    self.innardsChance = 0

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

    -- Start wave spawning in 30 seconds
    --Timers:CreateTimer(30.0, function()
        self:startWaveSpawning()
    --end)
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
        if shouldAddToMinionQueueIfFail then
            print("EnemySpawner | Spawning WaveGroup of " .. groupSize .. " enemies")
        else
            print("EnemySpawner | Spawning Queue WaveGroup of " .. groupSize .. " enemies. Queue size = " .. self.minionQueue)
        end

        local spawnedUnits = {}

        -- 75% of the wave is always zombies (and maybe one mutant based on radiation level)
        local j = Round(groupSize * .25) + 1
        if groupSize > j and RandomInt(1, 4) < g_RadiationManager.radiationLevel then
            groupSize = groupSize - 1
            table.insert(spawnedUnits, self:spawnEnemy(EnemySpawner.ENEMY_CODE_MUTANT, GetRandomPointInRegion(location), 0, shouldAddToMinionQueueIfFail))
        end
        while groupSize > j do
            groupSize = groupSize - 1
            table.insert(spawnedUnits, self:spawnEnemy(EnemySpawner.ENEMY_CODE_ZOMBIE, GetRandomPointInRegion(location), 0, shouldAddToMinionQueueIfFail))
        end

        -- The rest of the wave can be anything
        while groupSize > 0 do
            groupSize = groupSize - 1
            j = RandomInt(0, 9)
            local position = GetRandomPointInRegion(location)

            if j < 1 then
                table.insert(spawnedUnits, self:spawnEnemy(EnemySpawner.ENEMY_CODE_BEAST, position, RandomInt(0 - g_EnemyUpgrades.nightmareUpgrade, 77), shouldAddToMinionQueueIfFail))
            elseif j < 2 then
                table.insert(spawnedUnits, self:spawnEnemy(EnemySpawner.ENEMY_CODE_GROTESQUE, position, 30, shouldAddToMinionQueueIfFail))
            elseif j < 4 then
                table.insert(spawnedUnits, self:spawnEnemy(EnemySpawner.ENEMY_CODE_DOG, position, RandomInt(0 - g_EnemyUpgrades.nightmareUpgrade, 77), shouldAddToMinionQueueIfFail))
            else
                -- TODO: Not 100% this is radiationLevel (which it is in source) and not radiationFragments
                if RandomInt(-1, 43) < g_RadiationManager.radiationLevel then
                    table.insert(spawnedUnits, self:spawnEnemy(EnemySpawner.ENEMY_CODE_MUTANT, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail))
                else
                    table.insert(spawnedUnits, self:spawnEnemy(EnemySpawner.ENEMY_CODE_ZOMBIE, GetRandomPointInRegion(location), RandomInt(1, 13), shouldAddToMinionQueueIfFail))
                end
            end
        end

        -- Tell the group where to go
        -- Issueing an order to a unit immediately afte rit spawns seems to not consistently work
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

-- This method will go through the actions of a single wave
function EnemySpawner:spawnWave()
    if self.minionCount > EnemySpawner.MAX_MINIONS_WAVE_START then
        -- Too many minions out to spawn a new wave!
        print("EnemySpawner | Too many minions out to start a new wave")
        -- Wait 15 seconds
        Timers:CreateTimer(15, function()
            -- Buff the zombies and try to spawn a wave
            g_EnemyUpgrades.mobSpeed = g_EnemyUpgrades.mobSpeed + 0.5
            self:spawnWave()
        end)
    else
        print("EnemySpawner | New Wave Started")
        -- Begin the wave!
        self.minionQueue = 0
        g_EnemyUpgrades.mobSpeed = 0 -- Reset the buffs we gave to the previous wave while we waited

        local numberOfWaveGroups = 51 + g_GameManager.playerCount + ( 3 * g_GameManager.nightmareValue * g_GameManager.nightmareValue)
        print("EnemySpawner | Spawning " .. numberOfWaveGroups .. " wave groups!")
        Timers:CreateTimer(0, function()
            -- There is a random chance we don't do anything
            local i = 0
            if g_GameManager.nightmareValue > 0 and g_GameManager.currentDay > 1 then
                i = 18 - (g_GameManager.playerCount / 4) - (g_GameManager.nightmareValue * g_GameManager.nightmareValue)
            else
                i = math.max(g_GameManager.difficultyValue * 10, 19 - (g_GameManager.playerCount / 4))
            end

            if RandomInt(1 + g_GameManager.survivalValue, 100) > i then
                -- We passed our random chance.
                numberOfWaveGroups = numberOfWaveGroups - 1
                if numberOfWaveGroups < 0 then
                    -- We're done spawning waves, start spawning the minion queue
                    print("EnemySpawner | Spawn from the minion queue!")
                    self:spawnQueueGroups()
                else
                    -- Spawn a wave group!

                    -- Figure out a location for the spawn group
                    local location = nil
                    if g_GameManager.lastBuildingEntered ~= nil then
                        print("EnemySpawner | Spawning in last entered warehouse!")
                        location = g_GameManager.lastBuildingEntered
                        g_GameManager.lastBuildingEntered = nil
                    else
                        print("EnemySpawner | Spawning in random warehouse!")
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

-- Begins summoning from the queue until the queue is empty
-- Once the queue is empty, we summon another wave
function EnemySpawner:spawnQueueGroups()
    if self.minionQueue > 0 then
        print("EnemySpawner | Spawning from Queue")
        local waitTimeBetweenQueueWaves = self.waveGroupDelay - g_GameManager.difficultyValue
        Timers:CreateTimer(waitTimeBetweenQueueWaves, function()
            if self.minionQueue  > 0 then
                if self.minionCount >= EnemySpawner.MAX_MINIONS then
                    print("EnemySpawner | Queue Waiting - too many enemies already out")
                    -- Too many minions for the queue
                    -- Collect up the current zombies (which minorly buffs them) and wait to try again
                    g_EnemyCommander:collectEmUp()
                    return 48 - (2 * g_GameManager.playerCount)
                else
                    -- Spawn a full wave group regardless of how many are in the minion queue
                    local location = GetRandomWarehouse()
                    self:spawnMinionGroup(location, false)

                    return waitTimeBetweenQueueWaves
                end
            else
                print("EnemySpawner | Queue now empty")
                self:spawnWave()
            end
        end)
    else
        -- No queue, we can just start the next wave
        self:spawnWave()
    end

end

function EnemySpawner:startWaveSpawning()
    print("EnemySpawner | Starting Wave Spawning")

    -- Start the CollectEmUp cycle
    g_EnemyCommander:startCollectEmUpCycle()

    -- Start the wave spawning
    self:spawnWave()
end


----------------------
------- MINION SPAWN FUNCTIONS
----------------------


-- Generic enemy spawner. Should pass in an enemy code defined here
function EnemySpawner:spawnEnemy(enemy, position, specialType, shouldAddToMinionQueueIfFail)
    if self.minionCount >= EnemySpawner.MAX_MINIONS then
        -- Too many units in play, just add this unit to the minion queue
        -- Nauty players will be punished, but the minions now go into the minion queue
        if(shouldAddToMinionQueueIfFail) then
            self.minionQueue = self.minionQueue + 1
            print("EnemySpawner | Adding enemy to minion queue! Queue size = " .. self.minionQueue)
        else
            print("EnemySpawner | Couldn't spawn queued enemy!")
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
            unit = self:spawnZombie(position, specialType)
        elseif enemy == EnemySpawner.ENEMY_CODE_GROTESQUE then
            unit = self:spawnGrotesque(position, specialType)
        elseif enemy == EnemySpawner.ENEMY_CODE_BEAST then
            unit = self:spawnBeast(position, specialType)
        elseif enemy == EnemySpawner.ENEMY_CODE_DOG then
            unit = self:spawnDog(position, specialType)
        elseif enemy == EnemySpawner.ENEMY_CODE_MUTANT then
            unit = self:spawnMutant(position)
        end

        -- Let's hurt the unit a bit
        unit:SetHealth(math.max(1, unit:GetHealth() - RandomInt(0,99)))
        -- Set its speed
        unit:SetBaseMoveSpeed(g_EnemyUpgrades:calculateMovespeed(unit, g_GameManager.nemesisStage))

        return unit
    end

end

-- Spawns a Zombie at a random point in the location
--  @param position | A vector where the enemy should be spawned
--  @param specialType | A value that is used to determine what type of zombie to spawn (flaming, TNT, rad...etc)
function EnemySpawner:spawnZombie(position, specialType)
    print("EnemySpawner | Spawning Zombie(" .. specialType .. ")")
    local unit = CreateUnitByName( "npc_dota_creature_basic_zombie", position, true, nil, nil, DOTA_TEAM_BADGUYS )

    return unit
end

function EnemySpawner:spawnMutant(position)
    print("EnemySpawner | Spawning Mutant")
    local unit = CreateUnitByName( "npc_dota_creature_basic_mutant", position, true, nil, nil, DOTA_TEAM_BADGUYS )

    return unit
end

function EnemySpawner:spawnDog(position, specialType)
    print("EnemySpawner | Spawning Dog(" .. specialType .. ")")
    local unit = CreateUnitByName( "npc_dota_creature_basic_dog", position, true, nil, nil, DOTA_TEAM_BADGUYS )

    return unit
end

function EnemySpawner:spawnGrotesque(position, specialType)
    print("EnemySpawner | Spawning Grotesque(" .. specialType .. ")")
    local unit = CreateUnitByName( "npc_dota_creature_basic_garg", position, true, nil, nil, DOTA_TEAM_BADGUYS )

    return unit
end

function EnemySpawner:spawnBeast(position, specialType)
    print("EnemySpawner | Spawning Beast(" .. specialType .. ")")
    local unit = CreateUnitByName( "npc_dota_creature_basic_beast", position, true, nil, nil, DOTA_TEAM_BADGUYS )

    return unit
end
