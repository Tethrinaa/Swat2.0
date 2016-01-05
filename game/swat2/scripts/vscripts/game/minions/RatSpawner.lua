-- Contains information about the toxic rat enemy
-- (These are generally only spawned during events, like a toxic enemy dying)

SHOW_RAT_LOGS = SHOW_MINION_LOGS -- these are a bit verbose so probably not needed to normaly be displayed unless specifically debuging this class

RatSpawner = {}

RatSpawner.RAT_UNIT_NAME = "enemy_minion_rat"

RatSpawner.WANDER_DELAY_MIN = 3 -- min time before moving
RatSpawner.WANDER_DELAY_MAX = 6 -- max time before moving
RatSpawner.WANDER_MAX_DISTANCE = 100 -- max distance from its initial position it will wander

function RatSpawner:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

-- Generic enemy creation method called by EnemySpawner
-- @param position | the position to create the unit
-- @param specialType | a field that can be used to spawn special types of this minion
-- returns the created unit
function RatSpawner:createRat(position)

    local unit = CreateUnitByName( RatSpawner.RAT_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )

    local duration = 40 - math.max(0, RandomInt(-10, 30))
    unit:AddNewModifier(caster, nil, "modifier_kill", {duration=duration})

    self:makeRatWander(unit, position)

    return unit
end

function RatSpawner:createToxicRat(position)
    local unit = self:createRat(position)

    -- Give it the toxic aura ability
    unit:AddAbility("enemy_rat_toxic_aura")
    unit:FindAbilityByName("enemy_rat_toxic_aura"):SetLevel(1)
    unit:SetRenderColor(107, 142, 35)

    return unit
end

-- Makes the rat "wander" around the position
function RatSpawner:makeRatWander(unit, position)
    Timers:CreateTimer(RandomInt(RatSpawner.WANDER_DELAY_MIN, RatSpawner.WANDER_DELAY_MAX)
           , function()
           -- First check to make sure rat is not dead
           if unit:IsNull() == false then
               -- Not dead. Go wander somewhere else rat.
               local newPosition = position + RandomSizedVector(RatSpawner.WANDER_MAX_DISTANCE)
               ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), OrderType =  DOTA_UNIT_ORDER_MOVE_TO_POSITION , Position = newPosition, Queue = false})

               -- Queue rat to wander again later
               return RandomInt(RatSpawner.WANDER_DELAY_MIN, RatSpawner.WANDER_DELAY_MAX)
           end
       end
   )
end
