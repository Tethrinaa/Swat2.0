-- Deals damage per second. This damage goes through all protections including nanites. Is fatal
function modifier_enemy_toxic_damage(keys)
    local damage_to_deal = keys.DamagePerSecond * keys.DamageInterval

    -- Toxic damage is pure. We will just subtract the health
    local newTargetHealth = keys.target:GetHealth() - damage_to_deal
    if newTargetHealth >= 1 then
        keys.target:SetHealth(newTargetHealth)
    else
        keys.target:Kill(keys.ability, keys.caster)
    end
end

-- Drops a toxic rat at the caster's location
function drop_rat(keys)
    local position = keys.caster:GetAbsOrigin()
    g_EnemySpawner.ratSpawner:spawnMinion(position, RatSpawner.SPECIAL_TOXIC, nil) -- Spawn a toxic rat there
end
