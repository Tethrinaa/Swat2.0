-- Author: NSEnigma

function ValidPheroTarget(unit)
	-- TODO this needs to exclude phero immune units like innards and umbs
	return unit:GetAttackCapability() > 0
end

function SwapAbilities(keys)
	DeepPrintTable(keys)
	if keys.main_ability_name then
		keys.caster:SwapAbilities( keys.main_ability_name, keys.ability:GetAbilityName(), true, false )
	elseif keys.sub_ability_name then
		keys.caster:SwapAbilities( keys.ability:GetAbilityName(), keys.sub_ability_name, false, true )
	end
end

function OnSpellStart(keys)
	local caster = keys.caster
	
	-- find the units in the phero raidus
	local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, caster:GetOrigin(), nil, keys.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	
	for _,unit in ipairs(units) do
		-- if they are valid targets
		if unit ~= nil and ValidPheroTarget(unit) then
			local order = {}
			
			-- Order them to attack the borg if he's alive
			if caster:IsAlive() then
				order = { UnitIndex = unit:GetEntityIndex(), 
					OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
					TargetIndex = caster:entindex()
					}
			else -- attack-move to his last location
				order = { UnitIndex = unit:GetEntityIndex(), 
					OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
					Position = caster:GetAbsOrigin()
					}
			end
			ExecuteOrderFromTable( order )
		end
	end
	
	-- Swap the abilities back out
	local params = {}
	params.main_ability_name = keys.main_ability_name
	params.caster = caster
	params.ability = keys.ability
	SwapAbilities( params )
end