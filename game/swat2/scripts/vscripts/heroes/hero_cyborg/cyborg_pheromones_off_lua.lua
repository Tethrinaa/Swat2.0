
function ValidPheroTarget(unit)
	return true
end

function OnToggleOff(keys)
	local caster = keys.caster
	local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, caster:GetOrigin(), nil, keys.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	
	for _,unit in ipairs(units) do
		if unit ~= nil and ValidPheroTarget(unit) then
			local order = {}
			if caster:IsAlive() then
				order = { UnitIndex = unit:GetEntityIndex(), 
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = caster:entindex()
					}
			else
				order = { UnitIndex = unit:GetEntityIndex(), 
					OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
					Position = caster:GetAbsOrigin()
					}
			end
			ExecuteOrderFromTable( order )
		end
	end
	
	-- Swap sub_ability
	local sub_ability_name = "cyborg_pheromones_off_lua"
	local main_ability_name = self:GetAbilityName()

	caster:SwapAbilities( main_ability_name, sub_ability_name, false, true )
end