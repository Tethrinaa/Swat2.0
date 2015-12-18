-- This method is called from the map itself from registered triggers
-- It is used to alert the game of various events when units enter certain triggers
--

-- Called when a unit enters a warehouse
-- Not sure what userdata is
-- Relevant keys:
--      keys.activator = The unit entering the warehouse
--      keys.caller = The warehouse region
function UnitEntersWarehouse(userdata, keys)
    print("DEBUG Unit Entered Warehouse!") -- TODO REMOVE
    local unit = keys.activator
    local region = keys.caller

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
