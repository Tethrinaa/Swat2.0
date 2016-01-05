-- Contains information about the spiders enemy
--

SHOW_SPIDER_LOGS = SHOW_MINION_LOGS -- these are a bit verbose so probably not needed to normaly be displayed unless specifically debuging this class

SpiderSpawner = {}

SpiderSpawner.SPIDER_UNIT_NAME = "enemy_minion_spider"

function SpiderSpawner:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- Used to prevent spawning spiders after recently spawning them
    self.spidersReady = true

    return o
end

-- Rolls and potentially spawns spiders at the position passed
-- If successful, the targetUnit will be attacked and webbed
function SpiderSpawner:rollForSpidersSpawn(region, targetUnit)
    -- Roll for spiders (if they're ready)
    local chance = RandomInt(1, 4 * ( g_GameManager.difficultyValue + 4 - math.min(g_GameManager.survivalValue, 3)))
    if self.spidersReady and chance == 1 then
        -- Set a cooldown period (unless the unit is a pet. Fuck pets)
        if targetUnit.isPet then
            -- Pets far from their masters do not cause spider cooldown periods
        else
            -- Prevent future spider spawns for a bit
            self.spidersReady = false
            Timers:CreateTimer(RandomInt(20, 60), function()
                self.spidersReady = true
            end)
        end

        -- Spawn the spiders in 3 seconds
        Timers:CreateTimer(3, function()
            self:spawnSpidersInRegion(region, targetUnit)
        end)
    end
end

function SpiderSpawner:spawnSpidersInRegion(region, targetUnit)
    if targetUnit then
        -- Spawn one spider and give it web so it can web the targetUnit
        local position = targetUnit:GetAbsOrigin() + RandomVector(RandomInt(50,90))
        local unit = self:createSpider(position, targetUnit, true)
    end

    local spidersToSpawn = math.min(10 - g_GameManager.difficultyValue
                                    , (4 - g_GameManager.difficultyValue) + math.max(1, Round(g_EnemyUpgrades.minionUber / 20.0)))
    if SHOW_SPIDER_LOGS then
        print("SpiderSpawner | Spawning " .. spidersToSpawn .. " spiders")
    end
    for i = 1, spidersToSpawn do
        local position = GetRandomPointInRegion(region)
        self:createSpider(position, targetUnit, false)
    end
end

-- Generic enemy creation method called by EnemySpawner
-- @param position | the position to create the unit
-- @param targetUnit | the target the spider should attack towards. Note: If hasWeb is true, the target unit will be webbed
-- @param hasWeb | boolean. States whether the spider should have the web ability
-- returns the created unit
function SpiderSpawner:createSpider(position, targetUnit, hasWeb)
    local unit = CreateUnitByName( SpiderSpawner.SPIDER_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )

    g_EnemyUpgrades:upgradeMob(unit)
    -- Set its speed
    unit:SetBaseMoveSpeed(g_EnemyUpgrades:calculateMovespeed(unit, unit:GetBaseMoveSpeed() + (30 / g_GameManager.difficultyValue)))

    -- Evasion level is based on difficulty
    unit:FindAbilityByName("enemy_common_evasion"):SetLevel(g_GameManager.nightmareValue + 1)

    if hasWeb == false then
        unit:RemoveAbility("enemy_spider_web")
    end

    if targetUnit then
        -- Send it after whoever killed it!
        -- Issueing an order to a unit immediately after it spawns seems to not consistently work
        -- so we'll wait a second before telling the group where to go
        Timers:CreateTimer(0.3, function()
            g_EnemyCommander:doMobAction(unit, targetUnit)

            if hasWeb then
                -- force webbing of the target unit
                local webAbility = unit:FindAbilityByName("enemy_spider_web")
                unit:CastAbilityOnTarget(targetUnit, webAbility, unit:GetPlayerOwnerID())
            end
        end)
    end

    return unit
end
