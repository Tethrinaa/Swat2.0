-- Debuff a target and force it to attack a dummy for a duration
function MindRotTarget( target, caster, ability, isZombie, isMiniboss, duration, rottee )
	local indef_buff_name = "modifier_mind_rot_indefinite"
	local temp_buff_name = "modifier_mind_rot_temporary"
	
	-- Give minibosses a lesser buff
	if isMiniboss then
		temp_buff_name = temp_buff_name.."_miniboss"
	end
	
	if isZombie then
		-- remove mana and abilities from zombies
		target:SetMana(0)
		-- TODO reduce self heal on atmoic zombies
		if target:HasModifier(temp_buff_name) then
			return
		end
	
		local abil_names = { "enemy_zombie_brainlust", "enemy_zombie_regeneration", "enemy_common_radinating_regeneration", "enemy_zombie_phase_shift", "enemy_common_radinating_rad_bolt" }
		for _, abil_name in pairs(abil_names) do
			if target:HasAbility(abil_name) then target:RemoveAbility(abil_name) end
		end
	end
	
	-- Order the targets to attack the provided rottee
	-- TODO they can't attack the rottees because their team can't see them - need to give global vision to zombies
	-- local order_target =
	-- {
		-- UnitIndex = target:entindex(),
		-- OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		-- TargetIndex = rottee:entindex()
	-- }
	local order_target =
	{
		UnitIndex = target:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = rottee:GetAbsOrigin(),
		Queue = false
	}
	target:Stop()
	ExecuteOrderFromTable(order_target)

	-- Update and reapply the debuffs
	target:RemoveModifierByName(indef_buff_name)
	ability:ApplyDataDrivenModifier(caster, target, indef_buff_name, {})
	ability:ApplyDataDrivenModifier(caster, target, temp_buff_name, {duration = duration})
end


-- only and all dogs, mutants, zombies, and spiders count as valid rot targets
function MindRotValidTarget(target)
	local name = target:GetUnitName()
	local unit_types = {"dog", "zombie", "mutant", "spider"}
	
	for _, unit_type in pairs(unit_types) do
		if string.find(name, unit_type) then
			return true, unit_type
		end
	end
	
	return false
end

function MindRot( keys )
	-- Grab all the affects units
	local caster = keys.caster
	local targets = FindUnitsInRadius(keys.caster:GetTeamNumber(), keys.target_points[1], nil, keys.Radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	
	-- Calculate his effective int
	local white_int = caster:GetBaseIntellect()
	local green_int = caster:GetIntellect() - white_int
	local int = white_int + math.floor(green_int/3) - 100 -- drug int counts for one third
	
	-- Find his percentage of the max_weighted_int possible
	local max_weighted_int = keys.gt100_factor*50+keys.gt150_factor*50+keys.gt200_factor*(keys.max_int-200) -- -200 because 100 is the base and 100 has already been bucketed
	local weighted_int = 0
	if int > 100 then
		weighted_int = keys.gt100_factor*50+keys.gt150_factor*50+keys.gt200_factor*(int-100)-- int over 200 is weighted .2
	elseif int > 50 then
		weighted_int = keys.gt100_factor*50+keys.gt150_factor*(int-50) -- int between 150 and 200 is weighted .6
	else
		weighted_int = keys.gt100_factor*int      -- int up to 150 is weighted 1
	end
	
	-- Take that proportion and find the seconds based on the max possible seconds from int
	local rot_time = weighted_int / max_weighted_int * keys.max_int_seconds
	
	-- Add the base duration
	rot_time = rot_time + keys.base_duration
	
	-- Miniboss are only rotted for a fraction of the time
	local miniboss_rot_time = rot_time * keys.miniboss_duration_factor
	
	-- These 8 dummy units are what the zombies will go away to attack during the rot duration
	local rottees = { -- TODO these locations need to be adjusted with the new map
		CreateUnitByName( "psy_rottee", Vector(-11557,  11296), false, nil, nil, DOTA_TEAM_BADGUYS ),
		CreateUnitByName( "psy_rottee", Vector( 11535,  11299), false, nil, nil, DOTA_TEAM_BADGUYS ),
		CreateUnitByName( "psy_rottee", Vector( 11535, -11817), false, nil, nil, DOTA_TEAM_BADGUYS ),
		CreateUnitByName( "psy_rottee", Vector(-11545, -11912), false, nil, nil, DOTA_TEAM_BADGUYS ),
		CreateUnitByName( "psy_rottee", Vector(  -179,  11304), false, nil, nil, DOTA_TEAM_BADGUYS ),
		CreateUnitByName( "psy_rottee", Vector( 11583,    591), false, nil, nil, DOTA_TEAM_BADGUYS ),
		CreateUnitByName( "psy_rottee", Vector(  -100, -11835), false, nil, nil, DOTA_TEAM_BADGUYS ),
		CreateUnitByName( "psy_rottee", Vector(-11573,      0), false, nil, nil, DOTA_TEAM_BADGUYS )
	}
	
	-- Rot all the valid targets in the radius
	for _, target in pairs(targets) do
		local valid, unit_type = MindRotValidTarget(target)
		if valid then
			local rottee = rottees[ math.random( #rottees ) ]
			
			-- Rot them and then send them back into action afterwards
			if false then  -- TODO what defines a miniboss?
				MindRotTarget(target, caster, keys.ability, unit_type == "zombie", false, miniboss_rot_time, rottee)
				Timers:CreateTimer( miniboss_rot_time, function() target:Stop() end ) -- TODO this should be EnemyCommander:doMobAction(target, nil) but it thinks Locations.graveyard is nil
			else
				MindRotTarget(target, caster, keys.ability, unit_type == "zombie", true, rot_time, rottee)
				Timers:CreateTimer( rot_time, function() target:Stop() end) -- TODO this should be EnemyCommander:doMobAction(target, nil) but it thinks Locations.graveyard is nil
			end
		end
	end
end