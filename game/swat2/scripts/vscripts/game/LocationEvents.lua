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
    print("DEBUG Unit Entered Warehouse!") -- TODO REMOVE
    local unit = keys.activator
    local region = keys.caller

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

-- Called when a unit enters the graveyard
function UnitEntersGraveyard(keys)
    print("DEBUG Unit Entered Graveyard!") -- TODO REMOVE
    local unit = keys.activator

    -- Check if the unit is a player's hero or a "pet" (mini droids, cadet..etc), civ (converted and non)
    -- Don't allow things like sniper cams to trigger
    -- (Old system values < 6)
    -- TODO: If not either of these, this method should DO NOTHING

    g_EnemySpawner:startGraveyardEncounter(unit)
end
