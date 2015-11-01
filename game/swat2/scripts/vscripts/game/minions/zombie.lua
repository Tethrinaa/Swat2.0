-- Contains information about the zombie enemy
--

Zombie = {}

Zombie.ZOMBIE_REVIVE_QUEUE_SIZE = 600
Zombie.ZOMBIE_CORPSE_MODEL = "models/heroes/undying/undying_minion_torso.vmdl"

function Zombie:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.zombieReviveQueue = {}
    for i = 1, Zombie.ZOMBIE_REVIVE_QUEUE_SIZE do
        self.zombieReviveQueue[i] = nil
    end
    self.zombieReviveIndex = 1

    self:searchZombieQueue() -- begin searching the queue

    return o
end

-- Generic enemy creation method called by EnemySpawner
-- @param position | the position to create the unit
-- @param specialType | a field that can be used to spawn special types of this minion
-- returns the created unit
function Zombie:spawnMinion(position, specialType)
    --print("EnemySpawner | Spawning Zombie(" .. specialType .. ")")
    local unit = CreateUnitByName( "npc_dota_creature_basic_zombie", position, true, nil, nil, DOTA_TEAM_BADGUYS )
    self:addZombieMutation(unit)

    unit.zombieLives = 0

    -- EnemySpawner will look for onDeathFunctions and call them
    unit.onDeathFunction = function(killedUnit, killerEntity, killerAbility) self:onZombieDeath(killedUnit, killerEntity, killerAbility) end

    return unit
end

-- Adds a random zombie mutation to the zombie
function Zombie:addZombieMutation(zombie)
end

-- Called when this zombie dies
function Zombie:onZombieDeath(killedUnit, killerEntity, killerAbility)
    local lives = killedUnit.zombieLives or 0

    -- TODO: Check if killer ability was Nuke or if the zombie was AIMed
    local wasNuked = false
    if lives < RandomInt((g_GameManager.nightmareValue * 3 ) / 2, 9) then
        -- Reanimate the zombie
        print("DEBUG | Enemy Killed: zombie died! But he will revive! Lives=" .. lives)
        self:queueZombieForRevive(killedUnit, killerEntity, wasNuked)
    else
        print("DEBUG | Enemy Killed: zombie died! He will not revive.")
        -- We still want to spawn a dummy corpse though!
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
function Zombie:createDummyCorpse(killedUnit)
    local corpse = CreateUnitByName("zombie_corpse", killedUnit:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
    corpse:SetModel(Zombie.ZOMBIE_CORPSE_MODEL)
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

function Zombie:queueZombieForRevive(killedUnit, killerEntity, wasNuked)
    -- Create a Zombie corpse
    local corpse = self:createDummyCorpse(killedUnit)


    -- Add zombie to the revive list
    local i = self.zombieReviveIndex + RandomInt(230, 299)
    if i > Zombie.ZOMBIE_REVIVE_QUEUE_SIZE then
        i = i - Zombie.ZOMBIE_REVIVE_QUEUE_SIZE
    end
    -- Find the first empty slot (loop back to 0 if we approach the end)
    while self.zombieReviveQueue[i] ~= nil do
        if i == Zombie.ZOMBIE_REVIVE_QUEUE_SIZE then
            i = 1
        else
            i = i + 1
        end
    end
    print("Zombie | ZombieQueue | Adding zombie at " .. i)
    self.zombieReviveQueue[i] = {corpse=corpse, killer=killerEntity, nuked=wasNuked, mana=killedUnit:GetMana(), zombieLives=killedUnit.zombieLives}
end

-- Searches the zombie queue for a filled slot in the queue
function Zombie:searchZombieQueue()
    local i = self.zombieReviveIndex
    local indicesSearched = 0
    while self.zombieReviveQueue[i] == nil and indicesSearched < 39 do
        indicesSearched = indicesSearched + 1
        if i == Zombie.ZOMBIE_REVIVE_QUEUE_SIZE then
            i = 1
        else
            i = i + 1
        end
    end
    if i == Zombie.ZOMBIE_REVIVE_QUEUE_SIZE then
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
        print("Zombie | ZombieQueue Index= " .. self.zombieReviveIndex .. " | No zombie found. Waiting " .. waitTime)
        Timers:CreateTimer(waitTime, function() self:searchZombieQueue() end)
    else
        -- we found a corpse. Revive it
        print("Zombie | ZombieQueue Index= " .. self.zombieReviveIndex .. " | Reviving Zombie in " .. waitTime)
        Timers:CreateTimer(waitTime, function() self:reviveZombie(zombieInfo) end)
    end

end

-- Revives a zombie, given the zombie info saved in the zombieReviveQueue
function Zombie:reviveZombie(zombieInfo)
    -- Calculate how many "lives" we should increment by
    local livesIncrement = math.max(1, (2 * g_GameManager.difficultyValue) - g_GameManager.survivalValue)

    if zombieInfo.corpse.isRevivable then
        if g_EnemySpawner:canSpawnMinion() then
            print("Zombie | Revive | Reviving zombie")
            -- Revive the zombie
            local zombie = CreateUnitByName( "npc_dota_creature_basic_zombie", zombieInfo.corpse:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS )
            if zombieInfo.nuked then
                -- The zombie died via nuke (revives with less life, but does keep its mana)
                zombie:SetHealth(math.max(1, RandomInt(1, 180 - (30 * g_GameManager.difficultyValue) + (15 * g_GameManager.nightmareValue))))
                zombie:SetMana(zombieInfo.mana)
                zombie.zombieLives = zombieInfo.zombieLives -- don't reduce chance of zombie from reviving
            else
                -- zombie died normally
                zombie:SetHealth(math.max(1, RandomInt(1, 250 - (50 * g_GameManager.difficultyValue) + (25 * g_GameManager.nightmareValue) + (zombieInfo.mana * (3.0 - g_GameManager.difficultyBase)))))
                zombie.zombieLives = zombieInfo.zombieLives + livesIncrement -- reduce chance for future revives

                -- TODO Spawn Innards
            end

            -- Set its speed
            zombie:SetBaseMoveSpeed(g_EnemyUpgrades:calculateMovespeed(zombie, math.floor((zombieInfo.zombieLives + livesIncrement) / livesIncrement) * (9.0 / g_GameManager.difficultyBase)))
            -- Give it a mutation
            self:addZombieMutation(zombie)

            -- EnemySpawner will look for onDeathFunctions and call them
            zombie.onDeathFunction = function(killedUnit, killerEntity, killerAbility) self:onZombieDeath(killedUnit, killerEntity, killerAbility) end

            -- Send it after whoever killed it!
            -- Issueing an order to a unit immediately after it spawns seems to not consistently work
            -- so we'll wait a second before telling the group where to go
            Timers:CreateTimer(0.5, function()
                g_EnemyCommander:doMobAction(zombie, zombieInfo.killer)
            end)
        else
            print("Zombie | Revive | Zombie corpse added to minion queue")
            -- Add this zombie to the minion queue
            -- TODO
        end
    else
        print("Zombie | Revive | Corpse Killed")
        -- This corpse was "killed". Award experience
        -- TODO: Award experience.
    end

    -- Remove the corpse
    zombieInfo.corpse:RemoveSelf()

    -- Start searching again
    self:searchZombieQueue()
end
