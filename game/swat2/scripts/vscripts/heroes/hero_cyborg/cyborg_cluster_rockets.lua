-- Author: NSEnigma

function ClusterThink(keys)
	local radius = keys.ability:GetSpecialValueFor("radius")
	local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, keys.target:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
	local count = #units
	if count < 1 then
		return
	end
	
	local total_damage_cap =  keys.ability:GetSpecialValueFor("total_damage_cap")
	local unit_damage_cap = keys.ability:GetSpecialValueFor("unit_damage_cap")
	local damage = total_damage_cap / count
	if (damage > unit_damage_cap) then
		damage = unit_damage_cap
	end
	damage = damage / keys.ability:GetSpecialValueFor("ticks")
	for _,unit in pairs(units) do
		if unit ~= nil then
			local thinker_modifier = keys.target:FindModifierByName("modifier_cyborg_cluster_rockets_thinker")
			local stun_time = keys.ability:GetSpecialValueFor("stun_duration")
			local stun_remaining = stun_time - thinker_modifier:GetElapsedTime()
			
			unit:AddNewModifier( keys.target, keys.ability, "modifier_stunned", { duration = stun_remaining} )
						
			local damage_table = {
				victim = unit,
				attacker = keys.caster,
				damage = damage,
				damage_type = DAMAGE_TYPE_PURE,
				ability = keys.ability
			}
			ApplyDamage( damage_table )
		end
	end
	
end
