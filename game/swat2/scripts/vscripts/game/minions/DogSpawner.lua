-- Contains information about the beast enemy
--

SHOW_DOG_LOGS = SHOW_MINION_LOGS

DogSpawner = {}

DogSpawner.DOG_UNIT_NAME = "enemy_minion_dog"

function DogSpawner:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

-- Generic enemy creation method called by EnemySpawner during normal spawning
-- Will generate a random type and return it
-- @param position | the position to create the unit
-- returns the created unit
function DogSpawner:spawnMinion(position)
    local specialType = RandomInt(0 - g_EnemyUpgrades.nightmareUpgrade, 77)

    if specialType < 8 then
        return self:createBurninating(position)
    --elseif ( (udg_CurrentDay > 1) and (not udg_BlueDog) and (GetRandomInt(1, 48-2*udg_iPlayerCount+udg_BossChance[3]) < (udg_Nightmare*4)) ) then //blue dog
    --  TODO: Spawn blue dog
    else
        return self:createNormal(position)
    end
end

function DogSpawner:createNormal(position)
    local unit = CreateUnitByName( DogSpawner.DOG_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )
    unit:FindAbilityByName("common_truesight"):SetLevel(1)

    -- EnemySpawner will look for onDeathFunctions and call them
    -- TODO: Use or remove
    --unit.onDeathFunction = function(killedUnit, killerEntity, killerAbility) self:onDeath(killedUnit, killerEntity, killerAbility) end

    return unit
end

function DogSpawner:createBurninating(position)
    local unit = self:createNormal(position)

    unit:AddAbility("enemy_common_burninating")
    unit:FindAbilityByName("enemy_common_burninating"):SetLevel(1)

    return unit
end

-- Called when this unit dies
function DogSpawner:onDeath(killedUnit, killerEntity, killerAbility)
    -- TODO
end
