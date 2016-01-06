-- Author: NmdSnprEnigma

--- Loop that controls the increase in the level of XLR8 over time
function SpeedUpLoop(keys)
	local delay = keys.interval
	
	-- This accounts for the one-time delay on activation, after this a constant smaller delay is used.
	if keys.initial then
		delay = keys.initial
		keys.initial = nil
		
	
	else
		-- increase the level of XLR8 by 1
		local lvl = math.min( keys.ability:GetLevel() + 1, keys.ability:GetMaxLevel() )
		keys.ability:SetLevel(lvl)
		
		-- find and remove the current buff from everyone in the (larger) unphased radius
		-- otherwise the weaker buff with get refreshed as we level and we won't get the stronger higher levels
		local radius = keys.ability:GetSpecialValueFor("phased_radius")
		local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, keys.caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)
		for _, unit in pairs(units) do
			unit:RemoveModifierByNameAndCaster( "modifier_xlr8_attack_bonus", keys.caster)
		end
	end

	-- if this is the highest level of xlr8, we can stop loopsg to get faster.
	if keys.ability:GetLevel() >= keys.ability:GetMaxLevel() then
		return
	end
	
	-- ... but if it's not, then let's run through the loop again in DELAY seconds.
	Timers:CreateTimer(delay, function() 
		if keys.caster:HasModifier("modifier_xlr8_location_thinker") then
			SpeedUpLoop(keys)
		end
	end )
end

--- Record the initial state of a ho when he casts XLR8, including location and new cooldown
function SetLocation(keys)
	keys.ability:SetActivated(false)
	keys.caster.sdata.xlr8_cooldown = 0
	keys.caster.sdata.xlr8_location = keys.caster:GetAbsOrigin()
end

--- Every three seconds, update the current position.
function UpdateLocation(keys)
	local old_location = keys.caster.sdata.xlr8_location
	local new_location = keys.caster:GetAbsOrigin()
	local buff_name = "modifier_xlr8_location_thinker"
	local buff = keys.caster:FindModifierByName(buff_name)
	
	-- If the ho has moved move than 100 units in 3 seconds, remove the buff.
	if (new_location - old_location):Length() > 100 then
		keys.caster:RemoveModifierByName(buff_name)
		return
	end
	
	-- otherwise, update the location and add to the cooldown counter
	keys.caster.sdata.xlr8_location = keys.caster:GetAbsOrigin()
	keys.caster.sdata.xlr8_cooldown = keys.caster.sdata.xlr8_cooldown + 3 + 3 * math.floor(buff:GetElapsedTime()/20)
end

---
function ResetAbility(keys)
	keys.ability:SetLevel(1)
	
	-- TODO implement rank bonus for the xlr8 cooldown
	local rank = 4
	
	-- Convert the cooldown counter to an actual cooldown using the rank bonus
	local cd = Round( (keys.caster.sdata.xlr8_cooldown) / ({1.5356,2.1070,2.9226,3.9391})[rank] ) + 5
	
	-- Reenable the ability and start the calculated cooldown
	keys.ability:SetActivated(true)
	keys.ability:StartCooldown(cd)
end

