-- Contains information about the firefly enemy
--

SHOW_FIREFLY_LOGS = SHOW_MINION_LOGS -- these are a bit verbose so probably not needed to normaly be displayed unless specifically debuging this class

FireflySpawner = {}

FireflySpawner.FIREFLY_UNIT_NAME = "enemy_minion_firefly"
FireflySpawner.RADIUS_CHECK = 1800 -- when we spawn fireflies, this is the radius we check for enemy heroes

function FireflySpawner:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.fireflyCount = 0

    return o
end

-- Spawns fireflies at the location
-- Fireflies will automatically acquire nearby heroes as targets and set their leife
-- @param position | The position to spawn the fireflies
-- @param kiler | (Optional) If no heroes are found near enough to the position, fireflies will target the killer (if provided)
function FireflySpawner:spawnFireflies(position, killer)

    --local enemyHeroes = FindUnitsInRadius(DOTA_TEAM_BADGUYS
                                          --, position
                                          --, nil
                                          --, FireflySpawner.RADIUS_CHECK
                                          --, DOTA_UNIT_TARGET_TEAM_ENEMY
                                          --, DOTA_UNIT_TARGET_HERO
                                          --, 0, 0, false)
    local playersInfo = g_PlayerManager.playersInfo
    local nearbyPlayerInfo = {} -- player info objects for nearby heroes
    local count = 0

    -- Find all player heroes within radius
    for _,playerInfo in pairs(playersInfo) do
        local playerHero = playerInfo.hero
        if playerHero:IsAlive() and distanceBetweenVectors(playerHero:GetAbsOrigin(), position) < FireflySpawner.RADIUS_CHECK then
            table.insert(nearbyPlayerInfo, playerInfo)
            count = count + 1
        end
    end

    if count < 2 then
        -- Only one person nearby
        if killer then
            -- Add killer's owning hero if possible
            local id = killer:GetPlayerID()
            local playerInfoOfKiller = g_PlayerManager:getPlayerInfoForPlayerId(id)
            if playerInfoOfKiller then
                table.insert(nearbyPlayerInfo, playerInfo)
                count = count + 1
            end
        end

        -- add all the heroes regardless of where they are (including killer again and nearby guy again)
        for _,playerInfo in pairs(playersInfo) do
            table.insert(nearbyPlayerInfo, playerInfo)
            count = count + 1
        end
    end

    --add non-lights to the list again so they're more likely targets
    local currentSize = count
    for i = 1,currentSize do
        local playerInfo = nearbyPlayerInfo[i]

        if playerInfo.armorValue > 1 then
            -- heavy / adv get added 3 more times
            table.insert(nearbyPlayerInfo, playerInfo)
            table.insert(nearbyPlayerInfo, playerInfo)
            table.insert(nearbyPlayerInfo, playerInfo)
            count = count + 3
        elseif playerInfo.armorValue > 0 then
            -- Medium armor get added one more time
            table.insert(nearbyPlayerInfo, playerInfo)
            count = count + 1
        end
    end

    -- Figure out how many to spawn
    local numberToSpawn = 0
    if g_GameManager.difficultyValue > 2 then
        -- Normal mode only spawns one. Just give em a taste
        local numberToSpawn = 1
    else
        -- This crazy formula brought to you by redscull
        numberToSpawn = 1 + RandomInt( math.floor(g_PlayerManager.playerCount / 4)
                                      ,  math.floor(g_PlayerManager.playerCount / 2
                                                    + (((g_PlayerManager.playerCount + 1) / 3) * g_GameManager.nightmareValue)
                                                    + (g_DayNightManager.currentDay / (4 - ((g_PlayerManager.playerCount + 2) / 3)))))

        if g_GameManager.difficultyValue > 1 then
            -- hard mode reduction
            numberToSpawn = math.floor(numberToSpawn / 3)
        end

        local availableToSpawn = g_PlayerManager.playerCount + (2 * g_GameManager.nightmareValue) - self.fireflyCount

        if availableToSpawn < 0 then
            availableToSpawn = 0
        end
        if availableToSpawn < numberToSpawn then
            -- enforce the cap
            numberToSpawn = ((numberToSpawn - availableToSpawn) / 3) + availableToSpawn
        end
        if numberToSpawn < 1 then
            numberToSpawn = 1
        end
    end

    if SHOW_FIREFLY_LOGS then
        print("FireflySpawner | Spawning Fireflies ([numberToSpawn=" .. numberToSpawn .. " | heroesCount=" .. count .. "]")
    end

    -- Spawn them
    local createdUnits = {}
    local maxIndex = count -- The max index we can select from
    for i = 1,count do
        print("Creating Firefly")

        self.fireflyCount = self.fireflyCount + 1

        local randomPosition = position + RandomSizedVector(45)

        unit = CreateUnitByName( FireflySpawner.FIREFLY_UNIT_NAME, randomPosition, true, nil, nil, DOTA_TEAM_BADGUYS )
        unit.onDeathFunction = function(killedUnit, killerEntity, killerAbility) self:onDeath(killedUnit, killerEntity, killerAbility) end

        -- TODO: Better particle effect needed for fireflies
        unit:SetRenderColor(255, 255, 0)

        -- Find the target enemy
        if count > 0 then
            if maxIndex < 1 then
                maxIndex = count
            end
            local targetIndex = RandomInt(1, maxIndex)
            local targetPlayerInfo = nearbyPlayerInfo[targetIndex]
            if targetPlayerInfo.hero:IsAlive() then
                print("DEBUG - Targetting: " .. tostring(targetPlayerInfo.playerId))
                unit.targetUnit = targetPlayerInfo.hero
                -- Swap targeted index with max index so we ensure that the same hero doesn't get picked twice until everyone is
                nearbyPlayerInfo[targetIndex] = nearbyPlayerInfo[maxIndex]
                nearbyPlayerInfo[maxIndex] = targetPlayerInfo
            end
            maxIndex = maxIndex - 1
        else
            print("DEBUG - NO TARGETS")
        end

        table.insert(createdUnits, unit)
    end

    -- Send each firefly towards their targets
    -- Issueing an order to a unit immediately after it spawns seems to not consistently work
    -- so we'll wait a second before telling the group where to go
    Timers:CreateTimer(0.3, function()
        for _,unit in pairs(createdUnits) do
            if unit.targetUnit then
                ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), OrderType =  DOTA_UNIT_ORDER_ATTACK_TARGET , TargetIndex = unit.targetUnit:GetEntityIndex() })
            else
                print("DEBUG | NO TARGET UNIT")
            end
        end
    end)
end

-- Called when an special innard dies
function FireflySpawner:onDeath(killedUnit, killerEntity, killerAbility)
    self.fireflyCount = self.fireflyCount - 1
end
