modifier_cyborg_cluster_rockets_damager_lua = class({})
LinkLuaModifier( "modifier_cyborg_cluster_rockets_stunned_lua", "heroes/hero_cyborg/modifier_cyborg_cluster_rockets_stunned_lua", LUA_MODIFIER_MOTION_NONE )

function modifier_cyborg_cluster_rockets_damager_lua:OnIntervalThink()
	local params = self.params
	if IsServer() then
		local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, self:GetParent():GetOrigin(), nil, params.radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
		local count = #units
		if count < 1 then
			return
		end
		local total_damage_cap = params.total_damage_cap
		local unit_damage_cap = params.unit_damage_cap
		local damage = total_damage_cap / count
		if (damage > unit_damage_cap) then
			damage = unit_damage_cap
		end
		damage = damage / params.ticks
		for _,unit in pairs(units) do
			if unit ~= nil then
				if unit:GetModifierStackCount("modifier_cyborg_cluster_rockets_stunned_lua", self:GetCaster()) < 1 then
				  unit:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_cyborg_cluster_rockets_stunned_lua", { duration = params.stun_duration} )
				end
				
				local damage_table = {
					victim = unit,
					attacker = self:GetCaster(),
					damage = damage,
					damage_type = DAMAGE_TYPE_PURE,
					ability = self:GetAbility()
				}
				ApplyDamage( damage_table )
			end
		end
	end
end

function modifier_cyborg_cluster_rockets_damager_lua:OnCreated(params)
	-- Save the params that got passed in from the creation call in the cyborg_cluster_rockets_lua_ability
	self.params = params
	if IsServer() then
		-- Start the thinker ticking
		self:SetDuration( params.damage_duration, true )
		self:StartIntervalThink( params.tick_rate )
	end
end
