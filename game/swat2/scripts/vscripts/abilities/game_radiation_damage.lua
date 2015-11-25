function modifier_game_radiation_damage(keys)
    local damage_to_deal = keys.RadiationDamage
    --print("DEBUG | Radiation! Dealing " .. damage_to_deal)
    -- TODO: Check if unit is a bunker (and don't apply damage)
    if keys.IsFatal == 1  then
        -- Let this damage potentially kill the unit
        ApplyDamage({victim = keys.target, attacker = keys.caster, damage = damage_to_deal, damage_type = DAMAGE_TYPE_MAGICAL,})
    else
        -- Make sure we don't kill the unit with this
        if keys.target:GetHealth() <= damage_to_deal then
            damage_to_deal = keys.target:GetHealth() - 1
            --print("DEBUG | Too Low health. Applying " .. damage_to_deal .. " damage")
        end
        ApplyDamage({victim = keys.target, attacker = keys.caster, damage = damage_to_deal, damage_type = DAMAGE_TYPE_MAGICAL,})
    end
end
