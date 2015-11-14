-- Author: NSEnigma

--- A single instance of a cluster tick.
-- Tick count and interval controlled by a datadriven thinker
function ClusterThink(keys)

	local radius = keys.ability:GetSpecialValueFor("radius")
	local team =  keys.ability:GetAbilityTargetTeam()
	local Type =  keys.ability:GetAbilityTargetType()
	local flags = keys.ability:GetAbilityTargetFlags()
	local damage_type = keys.ability:GetAbilityDamageType()

	-- Grab all the units in cluster rockets target area	
	local units = FindUnitsInRadius(keys.caster:GetTeamNumber(), keys.target:GetAbsOrigin(), nil, radius, team, Type, flags, FIND_ANY_ORDER, false)
	local count = #units
	if count < 1 then
		return
	end
	
	-- Split the damage over all the units
	local total_damage_cap =  keys.ability:GetSpecialValueFor("total_damage_cap")
	local unit_damage_cap = keys.ability:GetSpecialValueFor("unit_damage_cap")
	local damage = total_damage_cap / count
	if (damage > unit_damage_cap) then
		damage = unit_damage_cap
	end
	damage = damage / keys.ability:GetSpecialValueFor("ticks")
	
	
	for _,unit in pairs(units) do
		if unit ~= nil then
		
			-- Set the stun duration so they all end at the same time regardless of when they walk into the area
			local thinker_modifier = keys.target:FindModifierByName("modifier_cyborg_cluster_rockets_thinker")
			local stun_time = keys.ability:GetSpecialValueFor("stun_duration")
			local stun_remaining = stun_time - thinker_modifier:GetElapsedTime()
			unit:AddNewModifier( keys.target, keys.ability, "modifier_stunned", { duration = stun_remaining} )
			
			-- Deal the split damage
			local damage_table = {
				victim = unit,
				attacker = keys.caster,
				damage = damage,
				damage_type = damage_type,
				ability = keys.ability
			}
			ApplyDamage( damage_table )
		end
	end
	
end
