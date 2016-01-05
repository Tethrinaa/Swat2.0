-- Called when a unit enters the televac's teleport aura
-- (Also called on all units near aura when it activates)
function unit_enters_televac_aura(keys)
    local unit = keys.target
    local unitName = unit:GetUnitName()
    local televac = keys.caster

    if unitName == "civillian_male" or unitName == "civillian_female" then
        -- Alert CivillianManager of civillians that walk into this aura
        g_CivillianManager:onCivEntersTelevacTeleport(televac, unit)
    end
end

-- Called every second or so to check and see if we should activate the televac aura or not
-- (Also called on all units near aura when it activates)
function televac_check_mana(keys)
    local televac = keys.caster
    televac.canTeleport = televac.canTeleport or false

    if (not televac.canTeleport) and televac:GetMana() > CivillianManager.TELEVAC_TELEPORT_COST then
        -- Now has enough mana to teleport
        local ability = keys.ability
        ability:ApplyDataDrivenModifier(televac, televac, "modifier_televac_teleport_aura", {})
        televac.canTeleport = true
    elseif televac.canTeleport and televac:GetMana() < CivillianManager.TELEVAC_TELEPORT_COST then
        -- No longer has enough mana for the aura
        televac:RemoveModifierByName("modifier_televac_teleport_aura")
        televac:RemoveModifierByName("modifier_televac_teleport_effect")
        televac.canTeleport = false
    end
end
