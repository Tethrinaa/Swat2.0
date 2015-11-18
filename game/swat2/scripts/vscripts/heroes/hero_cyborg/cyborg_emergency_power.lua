
function RestoreMana( keys )
    local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local mana_restore = ability:GetLevelSpecialValueFor("mana_restore", (ability:GetLevel() - 1))

	caster:GiveMana(mana_restore)
end
