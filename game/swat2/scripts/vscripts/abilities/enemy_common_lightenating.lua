-- Called when a rad fragment is destroyed
function lightenating_death(keys)
    --local attacker = keys.attacker
    --local ability = keys.ability

    local position = keys.unit:GetAbsOrigin()

   g_EnemySpawner.fireflySpawner:spawnFireflies(position)
end
