cyborg_cluster_rockets_lua_ability = class ({})
LinkLuaModifier( "modifier_cyborg_cluster_rockets_thinker_lua", "heroes/hero_cyborg/modifier_cyborg_cluster_rockets_thinker_lua", LUA_MODIFIER_MOTION_NONE )
--[[Author: NSEnigma
	Date: 2015.10.7
	]]

function cyborg_cluster_rockets_lua_ability:OnSpellStart()
	print("Rockets Cast!")
	print("Creating Thinker!")
	local mod = {}
	mod.total_damage_cap = self:GetSpecialValueFor( "total_damage_cap" )
	mod.unit_damage_cap = self:GetSpecialValueFor( "unit_damage_cap" )
	mod.radius = self:GetSpecialValueFor( "radius" )
	mod.stun_duration = self:GetSpecialValueFor( "stun_duration" )
	
	mod.damage_duration = self:GetSpecialValueFor( "damage_duration" )
	mod.tick_rate = self:GetSpecialValueFor( "tick_rate" )
	mod.ticks = math.floor(mod.damage_duration / mod.tick_rate)
	local modifier = CreateModifierThinker( self:GetCaster(), self, "modifier_cyborg_cluster_rockets_thinker_lua", mod, self:GetCursorPosition(), self:GetCaster():GetTeamNumber(), false)
end
