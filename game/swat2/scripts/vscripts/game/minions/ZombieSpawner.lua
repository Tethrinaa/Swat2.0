-- Contains information about the zombie enemy
--

SHOW_ZOMBIE_LOGS = false -- these are a bit verbose so probably not needed to normaly be displayed unless specifically debuging this class

ZombieSpawner = {}

ZombieSpawner.ZOMBIE_REVIVE_QUEUE_SIZE = 600
ZombieSpawner.ZOMBIE_CORPSE_MODEL = "models/heroes/undying/undying_minion_torso.vmdl"

function ZombieSpawner:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.zombieReviveQueue = {}
    for i = 1, ZombieSpawner.ZOMBIE_REVIVE_QUEUE_SIZE do
        self.zombieReviveQueue[i] = nil
    end
    self.zombieReviveIndex = 1

    -- Keep a cache of queued lives. If the zombie lives queue has a value in it, we set that value to the zombie's lives
    self.zombieLivesQueue = Queue:new()

    -- Cache the experience worth of a zombie for when we revive)
    self.zombieExperienceValue = GameMode.unit_infos["npc_dota_creature_basic_zombie"]["SwatXP"] or 1

    self:searchZombieQueue() -- begin searching the queue

    return o
end

-- Generic enemy creation method called by EnemySpawner
-- @param position | the position to create the unit
-- @param specialType | a field that can be used to spawn special types of this minion
-- returns the created unit
function ZombieSpawner:spawnMinion(position, specialType)
    --print("EnemySpawner | Spawning Zombie(" .. specialType .. ")")
    local unit = CreateUnitByName( "npc_dota_creature_basic_zombie", position, true, nil, nil, DOTA_TEAM_BADGUYS )
    self:addZombieMutation(unit)

    if self.zombieLivesQueue:getSize() == 0 then
        -- No zombie lives stored from queue
        unit.zombieLives = 0
    else
        -- A zombie tried to reanimate but was blocked because of minion queue
        -- Apply that zombie's lives to this zombie
        unit.zombieLives = self.zombieLivesQueue:pop_first()
        if SHOW_ZOMBIE_LOGS then
            print("ZombieSpawner | Spawned Zombie set with queued lives=" .. unit.zombieLives)
        end
    end

    -- EnemySpawner will look for onDeathFunctions and call them
    unit.onDeathFunction = function(killedUnit, killerEntity, killerAbility) self:onDeath(killedUnit, killerEntity, killerAbility) end

    return unit
end

-- Adds a random zombie mutation to the zombie
function ZombieSpawner:addZombieMutation(zombie)
end

-- Called when this zombie dies
function ZombieSpawner:onDeath(killedUnit, killerEntity, killerAbility)
    local lives = killedUnit.zombieLives or 0

    -- TODO: Check if killer ability was Nuke or if the zombie was AIMed
    local wasNuked = false
    if lives < RandomInt((g_GameManager.nightmareValue * 3 ) / 2, 9) then
        -- Reanimate the zombie
        self:queueZombieForRevive(killedUnit, killerEntity, wasNuked)
    else
        -- We still want to spawn a dummy corpse though!
        if SHOW_ZOMBIE_LOGS then
            print("ZombieSpawner | Zombie died and he will not revive")
        end
        local corpse = self:createDummyCorpse(killedUnit)
        corpse.isRevivable = false
        Timers:CreateTimer(RandomInt(15, 25), function()
            -- Remove the corpse after a variable amount of time
            corpse:ForceKill(true)
        end)
    end
end

-- Spawns a dummy corpse at the position after a short delay
-- Returns the created dummy unit
function ZombieSpawner:createDummyCorpse(killedUnit)
    local corpse = CreateUnitByName("zombie_corpse", killedUnit:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
    corpse:SetModel(ZombieSpawner.ZOMBIE_CORPSE_MODEL)
    -- Set the corpse invisible until the dota corpse disappears
    corpse:AddNoDraw()
    -- Set the angles
    local zombieAngles = killedUnit:GetAnglesAsVector()
    corpse:SetAngles(zombieAngles.x, zombieAngles.y, zombieAngles.z)
    corpse.isRevivable = true -- TODO can later be set to false by things like Ion Strikes
    -- Set custom corpse visible
    Timers:CreateTimer(1, function() if IsValidEntity(corpse) then corpse:RemoveNoDraw() end end)

    return corpse
end

function ZombieSpawner:queueZombieForRevive(killedUnit, killerEntity, wasNuked)
    -- Create a Zombie corpse
    local corpse = self:createDummyCorpse(killedUnit)


    -- Add zombie to the revive list
    local i = self.zombieReviveIndex + RandomInt(230, 299)
    if i > ZombieSpawner.ZOMBIE_REVIVE_QUEUE_SIZE then
        i = i - ZombieSpawner.ZOMBIE_REVIVE_QUEUE_SIZE
    end
    -- Find the first empty slot (loop back to 0 if we approach the end)
    while self.zombieReviveQueue[i] ~= nil do
        if i == ZombieSpawner.ZOMBIE_REVIVE_QUEUE_SIZE then
            i = 1
        else
            i = i + 1
        end
    end
    if SHOW_ZOMBIE_LOGS then
        print("ZombieSpawner | ZombieQueue | Adding zombie at " .. i)
    end
    self.zombieReviveQueue[i] = {corpse=corpse, killer=killerEntity, nuked=wasNuked, mana=killedUnit:GetMana(), zombieLives=killedUnit.zombieLives}
end

-- Searches the zombie queue for a filled slot in the queue
function ZombieSpawner:searchZombieQueue()
    local i = self.zombieReviveIndex
    local indicesSearched = 0
    while self.zombieReviveQueue[i] == nil and indicesSearched < 39 do
        indicesSearched = indicesSearched + 1
        if i == ZombieSpawner.ZOMBIE_REVIVE_QUEUE_SIZE then
            i = 1
        else
            i = i + 1
        end
    end
    if i == ZombieSpawner.ZOMBIE_REVIVE_QUEUE_SIZE then
        self.zombieReviveIndex = 1
    else
        self.zombieReviveIndex = i + 1
    end

    local waitTime = 0
    if indicesSearched > 0 then
        -- We passed over at least one blank to find that zombie (or nothing), now wait
        waitTime = indicesSearched * 0.13
    end

    -- Pop the info out of the list
    local zombieInfo = self.zombieReviveQueue[i]
    self.zombieReviveQueue[i] = nil
    if zombieInfo == nil then
        -- We found no zombie, wait and then search again
        --print("Zombie | ZombieQueue Index= " .. self.zombieReviveIndex .. " | No zombie found. Waiting " .. waitTime)
        Timers:CreateTimer(waitTime, function() self:searchZombieQueue() end)
    else
        -- we found a corpse. Revive it
        if SHOW_ZOMBIE_LOGS then
            print("ZombieSpawner | ZombieQueue Index= " .. self.zombieReviveIndex .. " | Reviving Zombie in " .. waitTime)
        end
        Timers:CreateTimer(waitTime, function() self:reviveZombie(zombieInfo) end)
    end

end

-- Revives a zombie, given the zombie info saved in the zombieReviveQueue
function ZombieSpawner:reviveZombie(zombieInfo)
    -- Calculate how many "lives" we should increment by
    local livesIncrement = math.max(1, (2 * g_GameManager.difficultyValue) - g_GameManager.survivalValue)

    if zombieInfo.corpse.isRevivable then
        if g_EnemySpawner:canSpawnMinion() then
            -- Increment the minion count
            g_EnemySpawner.minionCount = g_EnemySpawner.minionCount + 1

            -- Revive the zombie
            local position = zombieInfo.corpse:GetAbsOrigin()
            local zombie = CreateUnitByName( "npc_dota_creature_basic_zombie", position, true, nil, nil, DOTA_TEAM_BADGUYS )

            -- Apply enemy upgrades
            g_EnemyUpgrades:upgradeMob(zombie)

            if zombieInfo.nuked then
                -- The zombie died via nuke (revives with less life, but does keep its mana)
                zombie:SetHealth(math.max(1, RandomInt(1, 180 - (30 * g_GameManager.difficultyValue) + (15 * g_GameManager.nightmareValue))))
                zombie:SetMana(zombieInfo.mana)
                zombie.zombieLives = zombieInfo.zombieLives -- don't reduce chance of zombie from reviving
            else
                -- zombie died normally
                zombie:SetHealth(math.max(1, RandomInt(1, 250 - (50 * g_GameManager.difficultyValue) + (25 * g_GameManager.nightmareValue) + (zombieInfo.mana * (3.0 - g_GameManager.difficultyBase)))))
                zombie.zombieLives = zombieInfo.zombieLives + livesIncrement -- reduce chance for future revives

                -- Potentially spawn some innards
                if g_EnemySpawner.innardsSpawner.innardsChance > 0 then
                    g_EnemySpawner.innardsSpawner:rollForInnardsSpawn(position, zombieInfo.killer)
                end
            end

            -- Set its speed
            zombie:SetBaseMoveSpeed(g_EnemyUpgrades:calculateMovespeed(zombie, math.floor((zombieInfo.zombieLives + livesIncrement) / livesIncrement) * (9.0 / g_GameManager.difficultyBase)))
            -- Give it a mutation
            self:addZombieMutation(zombie)

            -- Give it some XP worth
            zombie.experience = self.zombieExperienceValue

            -- EnemySpawner will look for onDeathFunctions and call them
            zombie.onDeathFunction = function(killedUnit, killerEntity, killerAbility) self:onDeath(killedUnit, killerEntity, killerAbility) end

            -- Send it after whoever killed it!
            -- Issueing an order to a unit immediately after it spawns seems to not consistently work
            -- so we'll wait a second before telling the group where to go
            Timers:CreateTimer(0.5, function()
                g_EnemyCommander:doMobAction(zombie, zombieInfo.killer)
            end)
        else
            if SHOW_ZOMBIE_LOGS then
                print("ZombieSpawner | Revive | Zombie corpse added to minion queue")
            end
            -- Add this zombie to the minion queue
            g_EnemySpawner.minionQueue = g_EnemySpawner.minionQueue + 1

            -- Add this zombies lives to the minion queue
            self.zombieLivesQueue:push_last(zombieInfo.zombieLives + (2 * g_GameManager.difficultyValue) - 1)
        end
    else
        if SHOW_ZOMBIE_LOGS then
            print("ZombieSpawner | Revive | Corpse Killed")
        end
        -- This corpse was "killed". Award experience
        -- TODO: Award experience.
    end

    -- Remove the corpse
    zombieInfo.corpse:RemoveSelf()

    -- Start searching again
    self:searchZombieQueue()
end
