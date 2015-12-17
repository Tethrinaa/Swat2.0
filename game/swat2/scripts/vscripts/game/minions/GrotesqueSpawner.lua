-- Contains information about the grotesque enemy
--

SHOW_GROTESQUE_LOGS = SHOW_MINION_LOGS -- these are a bit verbose so probably not needed to normaly be displayed unless specifically debuging this class

GrotesqueSpawner = {}

GrotesqueSpawner.GROTESQUE_UNIT_NAME = "enemy_minion_grotesque"
GrotesqueSpawner.GROTESQUE_RADINATING_UNIT_NAME = "enemy_minion_grotesque_radinating"

function GrotesqueSpawner:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

-- Generic enemy creation method called by EnemySpawner during normal spawning
-- Will generate a random type and return it
-- @param position | the position to create the unit
-- returns the created unit
function GrotesqueSpawner:spawnMinion(position)
    local specialType = RandomInt(0, 30)

    if specialType < 3 then
        -- Create toxic or burninating
        if RandomInt(0, 8) < 1 then
            return self:createToxic(position)
        else
            return self:createBurninating(position)
        end
    --elseif ((udg_CurrentDay > 1) and (udg_Nightmare > 0) and (udg_SuperGarg == null) and (GetRandomInt(0, 41-2*udg_iPlayerCount) < 1)) then //super grotesque
        --TODO Super garg
    elseif RandomInt(-1, 398) < math.min(1, g_RadiationManager.radiationLevel) then
        return self:createRadinating(position)
    else
        return self:createNormal(position)
    end
end

function GrotesqueSpawner:createNormal(position)
    local unit = CreateUnitByName( GrotesqueSpawner.GROTESQUE_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )

    -- Evasion level is based on difficulty
    unit:FindAbilityByName("enemy_grotesque_evasion"):SetLevel(g_GameManager.nightmareValue + 1)

    unit:SetMana(0)

    -- EnemySpawner will look for onDeathFunctions and call them
    -- TODO: Use or remove
    --unit.onDeathFunction = function(killedUnit, killerEntity, killerAbility) self:onDeath(killedUnit, killerEntity, killerAbility) end

    return unit
end

function GrotesqueSpawner:createBurninating(position)
    local unit = self:createNormal(position)

    unit:AddAbility("enemy_common_burninating")
    unit:FindAbilityByName("enemy_common_burninating"):SetLevel(1)

    return unit
end

function GrotesqueSpawner:createToxic(position)
    local unit = self:createNormal(position)

    unit:AddAbility("enemy_common_toxic_aura")
    unit:FindAbilityByName("enemy_common_toxic_aura"):SetLevel(1)

    return unit
end

function GrotesqueSpawner:createRadinating(position)
    if g_RadiationManager:canSpawnRadinating() then
        g_RadiationManager:incrementRadCount()

        local unit = CreateUnitByName( GrotesqueSpawner.GROTESQUE_RADINATING_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )

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

-- Called when this unit dies
function GrotesqueSpawner:onDeath(killedUnit, killerEntity, killerAbility)
    -- TODO
end
