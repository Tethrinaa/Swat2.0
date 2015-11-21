-- Deals raw damageafflicted unit (not affected by nanites)
function deal_raw_damage(keys)
    local base_damage = keys.Damage

    local target = keys.target
    local armor = target:GetPhysicalArmorValue()

    local damage_mult = 1 - ((0.06 * armor) / (1 + (0.06 * armor)))
    local damage = damage_mult * base_damage

    local health = target:GetHealth()
    if health > damage then
        target:SetHealth(health - damage)
    else
        -- Kil the target
        target:Kill(keys.ability, keys.caster)
    end

end
