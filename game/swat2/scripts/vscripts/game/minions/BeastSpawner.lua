-- Contains information about the beast enemy
--

SHOW_BEAST_LOGS = SHOW_MINION_LOGS -- these are a bit verbose so probably not needed to normaly be displayed unless specifically debuging this class

BeastSpawner = {}

BeastSpawner.BEAST_UNIT_NAME = "enemy_minion_beast"
BeastSpawner.BEAST_RADINATING_UNIT_NAME = "enemy_minion_beast_radinating"
BeastSpawner.BEASTLING_UNIT_NAME = "enemy_minion_beastling"

function BeastSpawner:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

-- Generic enemy creation method called by EnemySpawner during normal spawning
-- Will generate a random type and return it
-- @param position | the position to create the unit
-- returns the created unit
function BeastSpawner:spawnMinion(position, specialType)
    local specialType = RandomInt(0 - g_EnemyUpgrades.nightmareUpgrade, 77)
    --if (udg_CurrentDay > 2) and (GetRandomInt(1, 26 + 2*udg_Nightmare) > 27) then //spawn hyperbeast
        --TODO: Create hyperbeast
    if specialType < 9 then
        local x = math.max(specialType - 6, 0)
        if RandomInt(0, 8) < x then
            -- TODO: NM/Ext roll for double TNT
            return self:createTnt(position)
        elseif RandomInt(0, 8) < x + 1 then
            return self:createToxic(position)
        else
            return self:createBurninating(position)
        end
    elseif RandomInt(-1, 398) < math.min(1, g_RadiationManager.radiationLevel) then
        return self:createRadinating(position)
    else
        return self:createNormal(position)
    end
end

function BeastSpawner:createNormal(position)
    local unit = CreateUnitByName( BeastSpawner.BEAST_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )

    unit:SetMana(0)

    -- EnemySpawner will look for onDeathFunctions and call them
    unit.onDeathFunction = function(killedUnit, killerEntity, killerAbility) self:onDeath(killedUnit, killerEntity, killerAbility) end

    return unit
end

function BeastSpawner:createBurninating(position)
    local unit = self:createNormal(position)

    unit:AddAbility("enemy_common_burninating")
    unit:FindAbilityByName("enemy_common_burninating"):SetLevel(1)

    return unit
end

function BeastSpawner:createToxic(position)
    local unit = self:createNormal(position)

    unit:AddAbility("enemy_common_toxic_aura")
    unit:FindAbilityByName("enemy_common_toxic_aura"):SetLevel(1)

    return unit
end

function BeastSpawner:createTnt(position)
    -- Not Normal unit (tnt zombies do not revive)
    local unit = self:createNormal(position)

    unit:AddAbility("enemy_common_tnt")
    unit:FindAbilityByName("enemy_common_tnt"):SetLevel(1)

    return unit
end

function BeastSpawner:createRadinating(position)
    if g_RadiationManager:canSpawnRadinating() then
        g_RadiationManager:incrementRadCount()

        local unit = CreateUnitByName( BeastSpawner.BEAST_RADINATING_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )

        unit:FindAbilityByName("enemy_common_radinating"):SetLevel(1)
        unit:FindAbilityByName("enemy_common_radinating_rad_bolt"):SetLevel(2)
        -- Radinating enemies get the zombie regeneration mutation
        if RandomInt(1, g_GameManager.difficultyValue) == 1 then
            unit:FindAbilityByName("enemy_common_radinating_regeneration"):SetLevel(g_GameManager.nightmareValue + 1)
        else
            unit:RemoveAbility("enemy_common_radinating_regeneration")
        end
        unit:SetMana(300)

        -- Alert radiation manager of the new walker
        g_RadiationManager:onWalkerCreated(unit)

        return unit
    else
        return self:createNormal(position)
    end
end

-- Spawns beastling at the provided location
function BeastSpawner:spawnBeastling(position)
    local unit = CreateUnitByName( BeastSpawner.BEASTLING_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )

    unit:SetMana(1) -- One blink initially

    -- Apply enemy upgrades
    g_EnemyUpgrades:upgradeMob(unit)

    -- Set its speed
    unit:SetBaseMoveSpeed(g_EnemyUpgrades:calculateMovespeed(unit, 24 / g_GameManager.difficultyBase))

    -- Increase minion count
    g_EnemySpawner.minionCount = g_EnemySpawner.minionCount + 1

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

    return unit
end


-- Spawns flaming beastling at the provided location
function BeastSpawner:spawnFlamingBeastling(position)
    local unit = self:spawnBeastling(position)

    unit:AddAbility("enemy_common_burninating")
    unit:FindAbilityByName("enemy_common_burninating"):SetLevel(1)

    return unit
end

-- Called when this unit dies
function BeastSpawner:onDeath(killedUnit, killerEntity, killerAbility)
    -- Spawns beastling if we have enough mana
    local numberToSpawn = math.floor(killedUnit:GetMana() / 11.2)

    -- TODO: Check to see if this beast died by something like an ion strike or something and don't spawn beastlings

    if numberToSpawn > 0 then
        local applyFlaming = (killedUnit:FindAbilityByName("enemy_common_burninating") ~= nil)
        if SHOW_BEAST_LOGS then
            print("BeastSpawner | Beast died. Spawning " .. numberToSpawn .. " beastlings! (fire= " .. tostring(applyFlaming) .. ")")
        end

        local position = killedUnit:GetAbsOrigin()

        Timers:CreateTimer(RandomFloat(0, 3), function()
            local unit = nil
            if applyFlaming then
                unit = self:spawnFlamingBeastling(position)
            else
                unit = self:spawnBeastling(position)
            end

            if killerEntity then
                -- Send it after whoever killed it!
                -- Issueing an order to a unit immediately after it spawns seems to not consistently work
                -- so we'll wait a second before telling the group where to go
                Timers:CreateTimer(0.5, function()
                    g_EnemyCommander:doMobAction(unit, killerEntity)
                end)
            end

            numberToSpawn = numberToSpawn - 1
            if numberToSpawn > 0 then
                return RandomFloat(0, 3)
            end
        end)
    else
        -- Not enough to mana to create any
        if SHOW_BEAST_LOGS then
            print("BeastSpawner | Beast died. But no beastlings will spawn")
        end
    end
end
