function OnAbilityPhaseStart(keys)
	ValidateAbilityTarget(keys.ability, keys.target, IsOrganic, "#error_inorganic_target")
end