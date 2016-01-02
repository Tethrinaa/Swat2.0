-- Called when a unit is hit with the antidote item
function unit_hit_with_antidote(keys)
    local unit = keys.target

    if unit:FindAbilityByName("civillian_partial_cure") then
        -- Sparkly zombie doted
        -- Don't make this cost a charge
        g_CivillianManager:onBlueZombieDoted(unit, keys.caster)
    elseif unit:GetUnitName() == "enemy_minion_zombie" then
        if unit:FindAbilityByName("civillian_innoculated") then
            -- This zombie is already innoculated
            -- Don't make this cost a charge
        else
            -- Normal zombie. Try to innoculate
            -- TODO: Check to see if this zombie is dotable (super zombies are not dotable but I believe all < NM zombies are dotable)
            g_CivillianManager:onRegularZombieDoted(unit, keys.caster)

            -- Costs a charge
            if keys.ability:GetCurrentCharges() > 1 then
                keys.ability:SetCurrentCharges(keys.ability:GetCurrentCharges() - 1)
            else
                keys.caster:RemoveItem(keys.ability)
            end
        end
    end
end
