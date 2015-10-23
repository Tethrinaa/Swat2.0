-- Author: NSEnigma
cyborg_forcefield_lua_ability = class({})
LinkLuaModifier( "modifier_cyborg_forcefield_lua", "heroes/hero_cyborg/modifier_cyborg_forcefield_lua", LUA_MODIFIER_MOTION_NONE )

--Necessary with a Lua ability - the value from the data driven is ignored
-- TODO The targetting tooltips are screwed up on the lua_abilities
function cyborg_forcefield_lua_ability:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_IMMEDIATE + DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE
end

function cyborg_forcefield_lua_ability:OnSpellStart(keys)
	local caster = self:GetCaster()
	
	local params = {}
	
	-- Create the Forcefield (this doesn't even to turn nanites off anymore! Cool, right?)
	caster:AddNewModifier(caster, self, "modifier_cyborg_forcefield_lua", params)
	
	-- Swap sub_ability
	local sub_ability_name = "cyborg_forcefield_off_lua_ability"
	local main_ability_name = self:GetAbilityName()

	caster:SwapAbilities( main_ability_name, sub_ability_name, false, true )
end
