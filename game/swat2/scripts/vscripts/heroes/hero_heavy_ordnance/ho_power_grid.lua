-- Author: NmdSnprEnigma

function ApplyPowerModifier(keys)
	local caster = keys.caster
	
	-- Decide the appropriate modifier based on the number of plants filled
	local modifier = "modifier_power_grid_unpowered" and ((g_PowerManager.powerPlantsFilled or 0) > 1) or "modifier_power_grid_powered" -- TODO GameManager is nil here??? or g_GameManager.isSurvival) or "modifier_power_grid_powered"
	-- TODO This needs to be enabled in survival
	
	-- Apply the selected modifier to the caster
	keys.ability:ApplyDataDrivenModifier(caster, caster, modifier, {} )
end