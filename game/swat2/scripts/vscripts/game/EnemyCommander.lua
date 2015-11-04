-- Issues commands to the units

SHOW_ENEMY_COMMANDER_LOGS = SHOW_GAME_SYSTEM_LOGS

EnemyCommander = {}

function EnemyCommander:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- All of the enemies will periodically be charged with targetting a specific hero
    self.targettedHero = nil

    return o
end

-- Gets all of the units on the map and tells them to target an area near the current targetted hero
function EnemyCommander:collectEmUp()
    if SHOW_ENEMY_COMMANDER_LOGS then
        print("EnemyCommander | collectEmUp()")
    end

    self:pickHeroToKill()

    local enemyUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                                            Vector(0, 0, 0),
                                            nil,
                                            FIND_UNITS_EVERYWHERE,
                                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                            DOTA_UNIT_TARGET_ALL,
                                            DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,
                                            FIND_ANY_ORDER,
                                            false)

    if(g_GameManager.isSurvival) then
        g_EnemyUpgrades.collectionZombieBonus = math.max(2 * g_GameManager.difficultyValue - g_GameManager.survivalValue)
    end

    -- Check to see if we have units in the minion queue, if we do we're going to speed up the units
    local increaseMoveSpeed = g_EnemySpawner.minionQueue > 0
    for _,unit in pairs(enemyUnits) do
        -- Units that are Ancients on the DOTA_TEAM_BADGUYS should not be controlled (like rad frags)
        if not unit:IsAncient() then
            if increaseMoveSpeed then
                -- Up this units move speed
                -- TODO check if unit has the % movespeed skill
                local hasMovementSpeedBuff = false
                if hasMovementSpeedBuff then
                    -- If they have the movement speed skill, we should reduce this buff a bit
                    unit:SetBaseMoveSpeed(g_EnemyUpgrades:calculateMovespeed(unit, g_EnemyUpgrades:calculateZombieBonus(unit)) / 2.5)
                else
                    unit:SetBaseMoveSpeed(g_EnemyUpgrades:calculateMovespeed(unit, g_EnemyUpgrades:calculateZombieBonus(unit)))
                end
            end

            self:doMobAction(unit, nil)
        end

    end
end

-- Starts the cycle which calls collectEmUp() periodically
function EnemyCommander:startCollectEmUpCycle()
    if SHOW_ENEMY_COMMANDER_LOGS then
        print("EnemyCommander | Starting collectEmUp cycle")
    end
    Timers:CreateTimer( 0.0, function()
        self:collectEmUp()
        return 75.00 - 15 * (g_GameManager.difficultyValue - g_GameManager.survivalValue)
    end)
end

-- Pleasant function that picks a random hero for the mobs to move towards
function EnemyCommander:pickHeroToKill()
    --print("EnemyCommander | Picking new hero to target")
    local players = Global_Player_Heroes
    local randomPlayerIndex = RandomInt(1, #players)

    self.targettedHero = players[randomPlayerIndex]
end

-- Basic command function. If there is a target, the mob will attack move towards that target
-- otherwise, it will go towards the targetted hero
function EnemyCommander:doMobAction(unit, target)
    target = target or self.targettedHero
    local position = nil
    if target ~= nil and target:GetHealth() > 0 then
        -- Attack move to that targets locations
        position = target:GetAbsOrigin() + RandomSizedVector(499)
    else
        -- Just go to the graveyard
        position = GetRandomPointInGraveyard()
    end
    ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), OrderType =  DOTA_UNIT_ORDER_ATTACK_MOVE , Position = position, Queue = false})
end
