cyborg_cluster_rockets_lua_ability = class ({})
LinkLuaModifier( "modifier_cyborg_cluster_rockets_waiter_lua", "heroes/hero_cyborg/modifier_cyborg_cluster_rockets_waiter_lua", LUA_MODIFIER_MOTION_NONE )
--[[Author: NSEnigma
	Date: 2015.10.7
	]]

-- Necessary with a Lua ability - the value from the data driven is ignored
function cyborg_cluster_rockets_lua_ability:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
end

-- Necessary with a Lua ability - the value from the data driven is ignored
-- Determines the AOE of the targetting cursor
function cyborg_cluster_rockets_lua_ability:GetAOERadius()
	return self:GetSpecialValueFor( "radius" )
end

-- Necessary with a Lua ability - the value from the data driven is ignored
-- Shows PURE damage for the tooltip
function cyborg_cluster_rockets_lua_ability:GetAbilityDamageType()
	return DAMAGE_TYPE_PURE
end

-- Necessary with a Lua ability - the value from the data driven is ignored
-- Shows team as BOTH for the tooltip
function cyborg_cluster_rockets_lua_ability:GetAbilityTargetTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

-- Necessary with a Lua ability - the value from the data driven is ignored
-- Shows target as UNITS for the tooltip
function cyborg_cluster_rockets_lua_ability:GetAbilityTargetType()
	return DOTA_UNIT_TARGET_ALL
end

function cyborg_cluster_rockets_lua_ability:OnSpellStart()
	local mod = {}
	
	-- Set up all the parameters for the waiting thinker, which will create the damaging thinker
	mod.total_damage_cap = self:GetSpecialValueFor( "total_damage_cap" )
	mod.unit_damage_cap = self:GetSpecialValueFor( "unit_damage_cap" )
	mod.radius = self:GetSpecialValueFor( "radius" )
	mod.stun_duration = self:GetSpecialValueFor( "stun_duration" )
	mod.damage_duration = self:GetSpecialValueFor( "damage_duration" )
	mod.tick_rate = self:GetSpecialValueFor( "tick_rate" )
	mod.ticks = math.floor(mod.damage_duration / mod.tick_rate)
	mod.delay = self:GetSpecialValueFor( "delay" )
	
	-- Create the waiting thinker
	local modifier = CreateModifierThinker( self:GetCaster(), self, "modifier_cyborg_cluster_rockets_waiter_lua", mod, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
end
