-- Called whenever the partial cure modifier is removed
-- If the skill still exists, then it expired normally
-- Otherwise, it was removed by a dote and should not trigger
--
-- This skill turns the afflicted unit into an evil civ
function partial_cure_destroyed(keys)
    local unit = keys.caster
    if not unit:IsNull() and unit:IsAlive() and unit:FindAbilityByName("civillian_partial_cure") then
        local position = unit:GetAbsOrigin()

        -- Kill the old blue zombie
        unit:AddNoDraw()
        unit:ForceKill(true)

        local unitName = (RandomInt(0, 1) == 0) and CivillianManager.CIVILIAN_MALE_UNIT_NAME or CivillianManager.CIVILIAN_FEMALE_UNIT_NAME
        local unit = CreateUnitByName( unitName, position, true, nil, nil, DOTA_TEAM_BADGUYS )
        unit:RemoveAbility("common_low_priority")
        unit:RemoveModifierByName("common_low_priority")
        unit:AddAbility("civillian_failed_cure")
        unit:FindAbilityByName("civillian_failed_cure"):SetLevel(1)
        unit:SetBaseMoveSpeed(g_EnemyUpgrades:calculateMovespeed(unit, 0.0))

        -- Send created zombies after the target
        Timers:CreateTimer(0.1, function()
            g_EnemyCommander:doMobAction(unit)
        end)
    end
end
