-- Called when a firefly is hit
function convert_firefly(keys)
    print("Converting Firefly")

    local unit = keys.caster

    -- Make unit invulnerable/unselectable
    unit:AddAbility("common_invulnerable")
    unit:FindAbilityByName("common_invulnerable"):SetLevel(1)
    unit:AddAbility("common_unselectable")
    unit:FindAbilityByName("common_unselectable"):SetLevel(1)

    -- Prevent the firefly from calling this again
    unit:RemoveModifierByName("modifier_enemy_firefly_conversion")

    -- Create firefly duration range
    local durationMin = 0
    local durationMax = 0
    if g_GameManager.difficultyValue < 2 then
        -- Insane+ durations
        durationMin = 4 + (g_GameManager.nightmareValue * 2)
        durationMax = 7 + math.floor((g_PlayerManager.playerCount - 1) / 3) + (g_GameManager.nightmareValue * 2)
    else
        -- Easy/Hard durations
        durationMin = 4 - g_GameManager.difficultyValue
        durationMax = 12 - (3 * g_GameManager.difficultyValue)
    end

    local duration = RandomInt(durationMin, durationMax)
    unit:AddNewModifier(caster, nil, "modifier_kill", {duration=duration})
end
