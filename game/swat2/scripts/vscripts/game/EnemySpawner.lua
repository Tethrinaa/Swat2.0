-- This file will be responsible spawning waves.
--


EnemySpawner = {}

EnemySpawner.MAX_MINIONS = 200 -- The cap on minions that are allowed out before we add them to the minion queue
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
function EnemyUpgrades:onDifficultySet(difficulty)
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
        print("EnemySpawner | Spawning WaveGroup of " .. groupSize .. " enemies")

        -- 75% of the wave is always zombies (and maybe one mutant based on radiation level)
        local j = Round(groupSize * .25) + 1
        if groupSize > j and RandomInt(1, 4) < g_RadiationManager.radiationLevel then
            groupSize = groupSize - 1
            self:spawnEnemy(EnemySpawner.ENEMY_CODE_MUTANT, GetRandomPointInRegion(location))
        end
        while groupSize > j do
            groupSize = groupSize - 1
            self:spawnEnemy(EnemySpawner.ENEMY_CODE_ZOMBIE, GetRandomPointInRegion(location), 0)
        end

        -- The rest of the wave can be anything
        while groupSize > 0 do
            groupSize = groupSize - 1
            j = RandomInt(0, 9)
            local position = GetRandomPointInRegion(location)

            if j < 1 then
                self:spawnEnemy(EnemySpawner.ENEMY_CODE_BEAST, position, RandomInt(0 - g_EnemyUpgrades.nightmareUpgrade, 77))
            elseif j < 2 then
                self:spawnEnemy(EnemySpawner.ENEMY_CODE_GROTESQUE, position, 30)
            elseif j < 4 then
                self:spawnEnemy(EnemySpawner.ENEMY_CODE_DOG, position, RandomInt(0 - g_EnemyUpgrades.nightmareUpgrade, 77))
            else
                -- TODO: Not 100% this is radiationLevel (which it is in source) and not radiationFragments
                if RandomInt(-1, 43) < g_RadiationManager.radiationLevel then
                    self:spawnEnemy(EnemySpawner.ENEMY_CODE_MUTANT, GetRandomPointInRegion(location))
                else
                    self:spawnEnemy(EnemySpawner.ENEMY_CODE_ZOMBIE, GetRandomPointInRegion(location), RandomInt(1, 13))
                end
            end
        end

    else
        -- Nemesis fight spawns minions in graveyard
        -- TODO
    end
end



----------------------
------- MINION SPAWN FUNCTIONS
----------------------


-- Generic enemy spawner. Should pass in an enemy code defined here
function EnemySpawner:spawnEnemy(enemy, position, specialType, shouldAddToMibionQueueIfFail)
    if self.minionCount >= EnemySpawner.MAX_MINIONS then
        -- Too many units in play, just add this unit to the minion queue
        -- Nauty players will be punished, but the minions now go into the minion queue
        if(shouldAddToMinionQueueIfFail) then
            print("EnemySpawner | Adding enemy to minion queue!")
            self.minionQueue = self.minionQueue + 1
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
        -- Tell it to go fight the targetted hero
        g_EnemyCommander:doMobAction(unit, nil)

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
