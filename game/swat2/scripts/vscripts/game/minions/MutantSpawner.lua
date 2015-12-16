-- Contains information about the beast enemy
--

SHOW_MUTANT_LOGS = SHOW_MINION_LOGS -- these are a bit verbose so probably not needed to normaly be displayed unless specifically debuging this class

MutantSpawner = {}

MutantSpawner.MUTANT_UNIT_NAME = "enemy_minion_mutant"

function MutantSpawner:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.mutantUpgradesLevel = 0

    return o
end

-- Generic enemy creation method called by EnemySpawner during normal spawning
-- Will generate a random type and return it
-- @param position | the position to create the unit
-- returns the created unit
function MutantSpawner:spawnMinion(position)
    --if (udg_CurrentDay > 1) and (GetRandomInt(0,14-udg_iPlayerCount) < udg_nmsurv) then
    --  TODO: Create charred (NM)
    return self:createNormal(position)
end

function MutantSpawner:createNormal(position)
    local unit = CreateUnitByName(MutantSpawner.MUTANT_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )

    -- Set the mutants abilities
    unit:FindAbilityByName("enemy_mutant_upgrades"):SetLevel(self.mutantUpgradesLevel)
    unit:FindAbilityByName("enemy_mutant_bash"):SetLevel(g_GameManager.nightmareValue + 1)

    -- EnemySpawner will look for onDeathFunctions and call them
    -- TODO: Use or remove
    --unit.onDeathFunction = function(killedUnit, killerEntity, killerAbility) self:onDeath(killedUnit, killerEntity, killerAbility) end

    return unit
end

-- Called when this unit dies
function MutantSpawner:onDeath(killedUnit, killerEntity, killerAbility)
    -- TODO
end

-- Updates the mutant_upgrades_level for ALL mutants (alive and when they spawn)
function MutantSpawner:updateMutantUpgrades()
    -- The mutant upgrades skill includes levels for all difficulties and rad brackets
    -- The level of this skill should be : 4 * (rad level[1-4]) + (difficulty[0-4])
    --                  4 * (0-(20-39),1-(40-59),2-(60-79),3-(80+)) + (1-normal, 2-hard, 3-insane, 4-NM+)
    --                  (or 0 if the radiation level is less than 1)!

    local newMutantUpgrades = math.max(0,(4 * ((math.max(0, math.min(4, g_RadiationManager.radiationLevel))) - 1))
                                       + ((4 - g_GameManager.difficultyValue) + math.min(1, g_GameManager.nightmareValue)))

    if newMutantUpgrades ~= self.mutantUpgradesLevel then
        self.mutantUpgradesLevel = newMutantUpgrades

        if SHOW_MUTANT_LOGS then
            print("MutantSpawner | Upgrading mutant upgrades to: " .. tostring(self.mutantUpgradesLevel) .. " | (diff=" .. tostring(g_GameManager.difficultyValue) .. " | nightmare=" .. tostring(g_GameManager.nightmareValue) .. " | radLevel=" .. tostring(g_RadiationManager.radiationLevel) .. ")")
        end

        -- Now update all existing mutants
        local enemyUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                                                Vector(0, 0, 0),
                                                nil,
                                                FIND_UNITS_EVERYWHERE,
                                                DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                                DOTA_UNIT_TARGET_ALL,
                                                DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS,
                                                FIND_ANY_ORDER,
                                                false)
        for _,unit in pairs(enemyUnits) do
            if unit:GetUnitName() == MutantSpawner.MUTANT_UNIT_NAME then
                unit:FindAbilityByName("enemy_mutant_upgrades"):SetLevel(self.mutantUpgradesLevel)
            end
        end
    end
end
