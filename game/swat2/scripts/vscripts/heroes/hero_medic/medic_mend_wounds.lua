function OnAbilityPhaseStart(keys)
	ValidateAbilityTarget(keys.ability, keys.target, IsMendWoundsTarget, "#error_mend_wounds_target")
end

--- Handles mend wounds autocast logic
function HealAutocast( keys )
	local caster = keys.caster
	local ability = keys.ability
	local autocast_radius = ability:GetSpecialValueFor("auto_cast_range")
	
	AutoCastAbility(ability, autocast_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, IsMendWoundsTarget)
end