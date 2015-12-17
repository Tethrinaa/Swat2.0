-- Called when a rad fragment is destroyed
function RadRemoved(keys)
    local rad = keys.unit
    --local attacker = keys.attacker
    --local ability = keys.ability

    -- TODO: Determine what this rad died by:
    --       Nukes? (Although nukes may just trigger kill them and not hit this)
    --       Robodog

    local position = rad:GetAbsOrigin()

   g_RadiationManager:onRadDestroyed(position)
end
