cyborg_forcefield_off_lua_ability = class({})

-- Necessary with a Lua ability - the value from the data driven is ignored
function cyborg_forcefield_off_lua_ability:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
end

function cyborg_forcefield_off_lua_ability:OnSpellStart(keys)
	local caster = self:GetCaster()
	
	caster:RemoveModifierByName("modifier_cyborg_forcefield_lua")
	
	-- Swap sub_ability
	local main_ability_name = "cyborg_forcefield_lua_ability"
	local sub_ability_name = self:GetAbilityName()

	caster:SwapAbilities( main_ability_name, sub_ability_name, true, false )
end
