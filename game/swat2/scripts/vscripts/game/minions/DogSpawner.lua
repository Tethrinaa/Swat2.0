-- Contains information about the beast enemy
--

SHOW_DOG_LOGS = SHOW_MINION_LOGS

DogSpawner = {}

function DogSpawner:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

-- Generic enemy creation method called by EnemySpawner
-- @param position | the position to create the unit
-- @param specialType | a field that can be used to spawn special types of this minion
-- returns the created unit
function DogSpawner:spawnMinion(position, specialType)
    --print("EnemySpawner | Spawning Zombie(" .. specialType .. ")")
    local unit = CreateUnitByName( "npc_dota_creature_basic_dog", position, true, nil, nil, DOTA_TEAM_BADGUYS )

    -- EnemySpawner will look for onDeathFunctions and call them
    unit.onDeathFunction = function(killedUnit, killerEntity, killerAbility) self:onDeath(killedUnit, killerEntity, killerAbility) end

    return unit
end

-- Called when this unit dies
function DogSpawner:onDeath(killedUnit, killerEntity, killerAbility)
    -- TODO
end
