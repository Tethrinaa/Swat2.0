-- Deals a percentage of damage per second
function modifier_enemy_toxic_damage(keys)
    local damage_to_deal = keys.DamagePerSecond* keys.DamageInterval
    ApplyDamage({victim = keys.target, attacker = keys.caster, damage = damage_to_deal, damage_type = DAMAGE_TYPE_MAGICAL,})
end

-- Drops a toxic rat at the caster's location
function drop_rat(keys)
    local position = keys.caster:GetAbsOrigin()
    g_EnemySpawner.ratSpawner:spawnMinion(position, RatSpawner.SPECIAL_TOXIC, nil) -- Spawn a toxic rat there
end
