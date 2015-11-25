-- Spawns a rad at the caster's location
function modifier_spawn_rad(keys)
    local position = keys.caster:GetAbsOrigin()

    -- Alert radiation manager of the killed radinating unit
    g_RadiationManager:onWalkerKilled(keys.caster)

    -- Spawn a rad fragment at the caster's location in 4 seconds
    Timers:CreateTimer(4, function()
        -- We do NOT increment rad count (it was increment when the radinating unit was created)
        local radFragment = g_RadiationManager:spawnRadFragment(position)
        -- Reduce the health of rad fragment based on the number of rad resist players
        radFragment:SetHealth(radFragment:GetMaxHealth() * (1.0 - ( 0.1 * g_RadiationManager.radResistPlayers )))
    end)
end
