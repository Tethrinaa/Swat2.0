-- Contains information about the innards enemy
--

SHOW_INNARDS_LOGS = SHOW_MINION_LOGS -- these are a bit verbose so probably not needed to normaly be displayed unless specifically debuging this class

InnardsSpawner = {}

InnardsSpawner.INNARD_UNIT_NAME_FIRST = "enemy_minion_innard_initial" -- The first type of innard spawned
InnardsSpawner.INNARD_UNIT_NAME_SECOND = "enemy_minion_innard_reborn" -- The second type of innard spawned (after first one dies)

function InnardsSpawner:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- innards increases by 1 for every zombie death, or resets to 0 if high (above 500-900 depending of diff)
    -- There is a innardsChance / innardsBuildup chance to spawn an innard on each zombie death
    -- So, multiple innards generally spawn if the count is low
    self.innards = -100 -- don't spawn them for the first 100 zombie deaths

    self.innardsChance = 0
    self.innardsReset = 499
    self.innardsInitial = 1

    return o
end

-- Updates the chance for innards
function InnardsSpawner:updateInnardsChance()
    local difficulty = g_GameManager.difficultyName
    if difficulty == "insane" then
        -- Insane mode
        self.innardsChance = 2
        self.innardsReset = 499
        self.innardsInitial = 1
    elseif difficulty == "nightmare" or difficulty == "extinction" then
        self.innardsReset = 499 + (200 * g_GameManager.nightmareValue)
        self.innardsInitial = 10

        if g_PlayerManager.playerCount > 6 then
            self.innardsChance = 7
        elseif g_PlayerManager.playerCount > 3 then
            self.innardsChance = 6
        elseif g_PlayerManager.playerCount > 2 then
            self.innardsChance = 5
        elseif g_PlayerManager.playerCount > 1 then
            self.innardsChance = 4
        else
            self.innardsChance = 2
        end
    else
        -- Not insane+
        self.innardsChance = 0
    end

    if SHOW_INNARDS_LOGS then
        if self.innardsChance > 0 then
            print("InnardsSpawner | Innards Chance Updated [chance=" .. self.innardsChance .. " , reset=" .. self.innardsReset .. " , initial=" .. self.innardsInitial .. "]")
        else
            print("InnardsSpawner | Innards have no chance of spawning")
        end
    end

end

-- Rolls and potentially spawns innards at the position passed
function InnardsSpawner:rollForInnardsSpawn(position, targetUnit)
    if self.innards > self.innardsReset then
        self.innards = self.innardsInitial
    else
        self.innards = self.innards + 1
    end
    if self.innards > 0 and RandomInt(1, self.innards) < self.innardsChance then
        self:createInnard(position, targetUnit, false)
    end
end

-- Generic enemy creation method called by EnemySpawner
-- @param position | the position to create the unit
-- @param targetUnit | the target the innard should attack towards
-- @param reborn | boolean. States whether to create an initial or reborn innard
-- returns the created unit
function InnardsSpawner:createInnard(position, targetUnit, reborn)
    local unit = nil
    if not reborn then
        -- Spawn a normal innard
        -- EnemySpawner will look for onDeathFunctions and call them
        -- This will spawn more innards when it dies!
        unit = CreateUnitByName( InnardsSpawner.INNARD_UNIT_NAME_FIRST, position, true, nil, nil, DOTA_TEAM_BADGUYS )
        unit.onDeathFunction = function(killedUnit, killerEntity, killerAbility) self:onDeath(killedUnit, killerEntity, killerAbility) end
        local duration = 2 + RandomFloat(0.0, 1.0) + RandomFloat(0.0, 1.0)
        unit:AddNewModifier(caster, nil, "modifier_kill", {duration=duration})
    else
        -- Spawn a REBORN innard
        -- Spawn an invulnerable, timed life innard
        unit = CreateUnitByName( InnardsSpawner.INNARD_UNIT_NAME_SECOND, position, true, nil, nil, DOTA_TEAM_BADGUYS )
        -- Apply a timed life to the unit
        local duration = 6 + (14 * g_GameManager.nightmareOrSurvivalValue)
        unit:AddNewModifier(caster, nil, "modifier_kill", {duration=duration})
        unit:SetHealth(duration)
        -- TODO: Shooting the innard should reduce its timed life by 1 per hit regardless of damage)
    end

    unit:SetRenderColor(105,0,0)

    if targetUnit then
        -- Send it after whoever killed it!
        -- Issueing an order to a unit immediately after it spawns seems to not consistently work
        -- so we'll wait a second before telling the group where to go
        Timers:CreateTimer(0.5, function()
            g_EnemyCommander:doMobAction(unit, targetUnit)
        end)
    end

    return unit
end

-- Called when an special innard dies
function InnardsSpawner:onDeath(killedUnit, killerEntity, killerAbility)
    -- Spawn another innard (that won't spawn more)
    self:createInnard(killedUnit:GetOrigin(), killerEntity, true)
    if g_GameManager.nightmareValue > 0 and g_PlayerManager.playerCount > 2 then
        -- Even more on Nightmare+
        self:createInnard(killedUnit:GetOrigin(), killerEntity, true)
        if RandomInt(g_PlayerManager.playerCount - 12, g_GameManager.nightmareValue) > 1 then
            -- Chance for even more on Extinction!!
            self:createInnard(killedUnit:GetOrigin(), killerEntity, true)
        end
    end
end
