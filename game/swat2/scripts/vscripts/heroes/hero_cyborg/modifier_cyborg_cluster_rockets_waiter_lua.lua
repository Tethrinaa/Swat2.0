-- Author: NSEnigma
modifier_cyborg_cluster_rockets_waiter_lua = class({})
LinkLuaModifier( "modifier_cyborg_cluster_rockets_damager_lua", "heroes/hero_cyborg/modifier_cyborg_cluster_rockets_damager_lua", LUA_MODIFIER_MOTION_NONE )

function modifier_cyborg_cluster_rockets_waiter_lua:OnCreated(params)
	-- Save the params that got passed in from the creation call in the cyborg_cluster_rockets_lua_ability
	self.params = params
	if IsServer() then
		-- Start the thinker ticking to account for the flight time
		self:SetDuration( params.delay, true )
	end
end

function modifier_cyborg_cluster_rockets_waiter_lua:OnDestroy()
	-- Create the damaging thinker
	local modifier = CreateModifierThinker( self:GetCaster(), self:GetAbility(), "modifier_cyborg_cluster_rockets_damager_lua", self.params, self:GetParent():GetAbsOrigin(), self:GetCaster():GetTeamNumber(), false)
end
