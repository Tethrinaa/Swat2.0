-- This method is called from the map itself from registered triggers
-- It is used to alert the game of various events when units enter certain triggers
--
-- Passed in values to these methods
-- Not sure what userdata is
-- Relevant keys:
--      keys.activator = The unit entering the trigger
--      keys.caller = The region triggered

-- Called when a unit enters a warehouse
function UnitEntersWarehouse(userdata, keys)
    local region = keys.caller

    -- Check if powerplant
    if Locations:isPowerPlant(region) then
        UnitEntersPowerPlant(userdata, keys)
    elseif Locations:isBlackMark(region) then
        UnitEntersBlackMarket(userdata, keys)
    else
        --print("DEBUG Unit Entered Warehouse!") -- TODO REMOVE
        local unit = keys.activator

        -- Check if the unit is a player's hero or a "pet" (mini droids, cadet..etc)
        -- (Old system values 3 and 4)
        -- TODO: If not either of these, this method should DO NOTHING

        -- Check if the unit that entered was a pet
        -- We want to ignore this event if the pet is close its master
        -- TODO: Mark some units as "pets"
        if unit.isPet then
            local player = unit:GetPlayerOwner()
            local playerHero = player:GetAssignedHero()

            if playerHero:IsAlive() and distanceBetweenVectors(playerHero:GetAbsOrigin(), unit:GetAbsOrigin()) < 2900 then
                -- The master is alive and the pet is close to the master that we should ignore this event
                return
            end
        end

        -- The unit is not a pet or it is not close enough to its master

        -- Check if we should spawn spiders
        g_EnemySpawner.spiderSpawner:rollForSpidersSpawn(region, unit)

        -- Set this region as a recently entered building in some time
        Timers:CreateTimer(25, function()
            g_EnemySpawner:setRecentlyEnteredBuilding(region)
        end)
    end
end

function UnitEntersPowerPlant(userdata, keys)
    print("DEBUG Unit Entered PowerPlant!") -- TODO REMOVE
    local unit = keys.activator
    local region = keys.caller
end

function UnitEntersBlackMarket(userdata, keys)
    print("DEBUG Unit Entered BlackMarket!") -- TODO REMOVE
    local unit = keys.activator
    local region = keys.caller
end

-- Called when a unit enters the graveyard
function UnitEntersGraveyard(keys)
    --print("DEBUG Unit Entered Graveyard!") -- TODO REMOVE
    local unit = keys.activator

    -- Check if the unit is a player's hero or a "pet" (mini droids, cadet..etc), civ (converted and non)
    -- Don't allow things like sniper cams to trigger
    -- (Old system values < 6)
    -- TODO: If not either of these, this method should DO NOTHING

    g_EnemySpawner:startGraveyardEncounter(unit)
end

-- Called when a unit enters a bunker (or lab)
function UnitEntersBunker(userdata, keys)
    --print("DEBUG Unit Entered Bunker!") -- TODO REMOVE
    local unit = keys.activator
    local region = keys.caller

    -- Add the bunker status (rad immune)
    unit:AddAbility("game_bunker_status")
    unit:FindAbilityByName("game_bunker_status"):SetLevel(1)

    -- Disable experience
    if unit.playerInfo then
        unit.playerInfo.experienceDisabled = unit.playerInfo.experienceDisabled + 1
    end
end

-- Called when a unit leaves a bunker (or lab)
function UnitLeavesBunker(userdata, keys)
    --print("DEBUG Unit Left Bunker!") -- TODO REMOVE
    local unit = keys.activator
    local region = keys.caller

    -- Remove the bunker status (rad immune)
    unit:RemoveModifierByName("modifier_game_bunker_status")
    unit:RemoveAbility("game_bunker_status")

    -- Enable experience
    if unit.playerInfo then
        unit.playerInfo.experienceDisabled = math.max(0, unit.playerInfo.experienceDisabled - 1)
    end
end

-- Called when a unit enters a bunker (or lab)
function UnitEntersLab(userdata, keys)
    --print("DEBUG Unit Entered Lab!") -- TODO REMOVE
    local unit = keys.activator
    local region = keys.caller
end

-- Called when a unit leaves the lab
function UnitLeavesLab(userdata, keys)
    --print("DEBUG Unit Left Lab!") -- TODO REMOVE
    local unit = keys.activator
    local region = keys.caller
end
