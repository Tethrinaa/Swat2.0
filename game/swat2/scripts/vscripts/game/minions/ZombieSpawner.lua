-- Contains information about the zombie enemy
--

SHOW_ZOMBIE_LOGS = false -- these are a bit verbose so probably not needed to normaly be displayed unless specifically debuging this class

ZombieSpawner = {}

ZombieSpawner.ZOMBIE_REVIVE_QUEUE_SIZE = 600
ZombieSpawner.ZOMBIE_UNIT_NAME = "enemy_minion_zombie"
ZombieSpawner.ZOMBIE_RADINATING_UNIT_NAME = "enemy_minion_zombie_radinating"
ZombieSpawner.ZOMBIE_CORPSE_UNIT_NAME = "enemy_minion_zombie_corpse"
ZombieSpawner.ZOMBIE_CORPSE_MODEL = "models/heroes/undying/undying_minion_torso.vmdl"

-- Special zombie type codes (pass to spawnMinion)
ZombieSpawner.SPECIAL_TYPE_NONE = -1 -- Will not apply any special type
ZombieSpawner.SPECIAL_TYPE_NORMAL = 0 -- Rolls the dice to see what it will be
ZombieSpawner.SPECIAL_TYPE_BURN_OR_TOXIC = 1 -- Rolls the dice to see what it will be
ZombieSpawner.SPECIAL_TYPE_LIGNTENATING_CHANCE = 2 -- Rolls the dice to see if this will be a ligntenating zombie


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
    self.zombieExperienceValue = GameMode.unit_infos[ZombieSpawner.ZOMBIE_UNIT_NAME]["SwatXP"] or 1

    self:searchZombieQueue() -- begin searching the queue

    return o
end

-- Generic enemy creation method called by EnemySpawner
-- @param position | the position to create the unit
-- @param specialType | a field that can be used to spawn special types of this minion
-- returns the created unit
function ZombieSpawner:spawnMinion(position, specialType)
    specialType = specialType or ZombieSpawner.SPECIAL_TYPE_NORMAL

    -- Yes, this method is a bit ugly, but it's more or less the same as Red's.

    --print("EnemySpawner | Spawning Zombie(" .. specialType .. ")")

    if specialType == ZombieSpawner.SPECIAL_TYPE_NONE then
        return self:createNormal(position)
    elseif specialType == ZombieSpawner.SPECIAL_TYPE_NORMAL then
        -- Normal roll for zombie type
        if RandomInt(0, 10) == 0 then
            if RandomInt(0, 8) < 1 then
                -- Create TNT
                return self:createTnt(position)
            elseif RandomInt(0, 8) < 2 then
                -- Create Toxic
                return self:createToxic(position)
            else
                -- Create burninating
                return self:createBurninating(position)
            end
        elseif RandomInt(-1, 398) < math.min(1, g_RadiationManager.radiationLevel) then
            -- Spawn radinating (if we can)
            if g_RadiationManager:canSpawnRadinating() then
                return self:createRadinating(position)
            else
                -- Couldn't create a radinating, just make a normal
                return self:createNormal(position)
            end
        else
            -- Nothing special
            return self:createNormal(position)
        end
    elseif specialType == ZombieSpawner.SPECIAL_TYPE_BURN_OR_TOXIC then
        -- rolls for burn/tnt/toxic (but higher chance) for tnt and toxic
        if RandomInt(0, 8) < 4 then
            -- Create TNT
            return self:createTnt(position)
        elseif RandomInt(0, 8) < 5 then
            -- Create Toxic
            return self:createToxic(position)
        else
            -- Create burninating
            return self:createBurninating(position)
        end
    elseif RandomInt(-1, 398) < math.min(1, g_RadiationManager.radiationLevel) then
        -- Yes, if we're not one of the first 2 types, we always have a chance to be walker
        -- This was in original code
        if g_RadiationManager:canSpawnRadinating() then
            return self:createRadinating(position)
        else
            -- Couldn't create a radinating, just make a normal
            return self:createNormal(position)
        end
    elseif specialType == ZombieSpawner.SPECIAL_TYPE_LIGNTENATING_CHANCE then
        return self:createLightenating(position)
    else
        return self:createNormal(position)
    end
end

-- Allows the zombie to revive (and spawns a corpse)
function ZombieSpawner:addReviveAbility(unit)
    -- Set up Zombie lives
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
end

-- Sets a single random zombie mutation to the zombie (or no mutation)
function ZombieSpawner:setZombieMutation(zombie)
    local brainlust = zombie:FindAbilityByName("enemy_zombie_brainlust")
    local regeneration = zombie:FindAbilityByName("enemy_zombie_regeneration")
    local phase_shift = zombie:FindAbilityByName("enemy_zombie_phase_shift")

    local rand = RandomInt(0, 9)
    if rand > 5 then
        -- Give Brainlust (an no others)
        brainlust:SetLevel(g_GameManager.nightmareValue + 1)
        regeneration:SetLevel(0)
        phase_shift:SetLevel(0)
    elseif rand > 2 then
        -- Give Regeneration (an no others)
        brainlust:SetLevel(0)
        regeneration:SetLevel(g_GameManager.nightmareValue + 1)
        phase_shift:SetLevel(0)
    elseif rand > 0 then
        -- Give Planar (an no others)
        brainlust:SetLevel(0)
        regeneration:SetLevel(0)
        phase_shift:SetLevel(g_GameManager.nightmareValue + 1)
    else
        -- Give Nothing
        brainlust:SetLevel(0)
        regeneration:SetLevel(0)
        phase_shift:SetLevel(0)
    end
end

-- Returns a normal zombie
function ZombieSpawner:createNormal(position)
    local unit = CreateUnitByName( ZombieSpawner.ZOMBIE_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )
    self:setZombieMutation(unit)
    self:addReviveAbility(unit)
    unit:SetMana(0)

    return unit
end

-- Returns a burninating zombie
function ZombieSpawner:createBurninating(position)
    local unit = CreateUnitByName( ZombieSpawner.ZOMBIE_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )
    unit:AddAbility("enemy_common_burninating")
    unit:FindAbilityByName("enemy_common_burninating"):SetLevel(1)
    self:setZombieMutation(unit)
    self:addReviveAbility(unit)
    unit:SetRenderColor(133, 0, 0)
    unit:SetMana(0)

    return unit
end

-- Returns a tnt zombie (can't revive)
function ZombieSpawner:createTnt(position)
    local unit = CreateUnitByName( ZombieSpawner.ZOMBIE_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )
    unit:AddAbility("enemy_common_tnt")
    unit:FindAbilityByName("enemy_common_tnt"):SetLevel(1)
    self:setZombieMutation(unit)
    unit:SetRenderColor(240, 150, 150)
    unit:SetMana(0)

    return unit
end

-- Returns a toxic zombie (can't revive)
function ZombieSpawner:createToxic(position)
    local unit = CreateUnitByName( ZombieSpawner.ZOMBIE_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )
    unit:AddAbility("enemy_common_toxic_aura")
    unit:FindAbilityByName("enemy_common_toxic_aura"):SetLevel(1)
    self:setZombieMutation(unit)
    unit:SetRenderColor(107, 142, 35)
    unit:SetMana(0)

    return unit
end

-- Returns a radinating zombie
function ZombieSpawner:createRadinating(position)
    g_RadiationManager:incrementRadCount()

    local unit = CreateUnitByName( ZombieSpawner.ZOMBIE_RADINATING_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )

    unit:FindAbilityByName("enemy_common_radinating"):SetLevel(1)
    unit:FindAbilityByName("enemy_common_radinating_rad_bolt"):SetLevel(2)
    unit:FindAbilityByName("enemy_zombie_brainlust"):SetLevel(g_GameManager.nightmareValue + 1)
    unit:FindAbilityByName("enemy_zombie_regeneration"):SetLevel(g_GameManager.nightmareValue + 1)
    self:addReviveAbility(unit)
    unit:SetRenderColor(80, 199, 0)
    unit:SetMana(300)

    -- Alert radiation manager of the new walker
    g_RadiationManager:onWalkerCreated(unit)

    return unit
end

-- Returns a lightenating zombie (can't revive)
function ZombieSpawner:createLightenating(position)
    -- TODO
    local unit = CreateUnitByName( ZombieSpawner.ZOMBIE_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )

    --unit:FindAbilityByName("enemy_common_radinating"):SetLevel(1)
    --unit:FindAbilityByName("enemy_common_radinating_rad_bolt"):SetLevel(2)
    self:setZombieMutation(unit)
    unit:SetRenderColor(255, 255, 0)
    unit:SetMana(0)

    return unit
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
    local corpse = CreateUnitByName(ZombieSpawner.ZOMBIE_CORPSE_UNIT_NAME, killedUnit:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
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
            local zombie = self:createNormal(position)

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

                -- Reset its mana
                zombie:SetMana(0)

                -- Potentially spawn some innards
                if g_EnemySpawner.innardsSpawner.innardsChance > 0 then
                    g_EnemySpawner.innardsSpawner:rollForInnardsSpawn(position, zombieInfo.killer)
                end
            end

            -- Set its speed
            zombie:SetBaseMoveSpeed(g_EnemyUpgrades:calculateMovespeed(zombie, math.floor((zombieInfo.zombieLives + livesIncrement) / livesIncrement) * (9.0 / g_GameManager.difficultyBase)))
            -- Give it a mutation
            self:setZombieMutation(zombie)

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
