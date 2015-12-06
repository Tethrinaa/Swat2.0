function SpeedUpLoop(keys)
	print("**************function SpeedUp(keys)")
	ShallowPrintTable(keys)
	-- ShallowPrintTable(keys.caster.sdata)
	local delay = keys.interval
	if keys.initial then
		delay = keys.initial
		keys.initial = nil
	else
		local lvl = math.min( keys.ability:GetLevel() + 1, keys.ability:GetMaxLevel() )
		keys.ability:SetLevel(lvl)
		
		local radius = keys.ability:GetSpecialValueFor("phased_radius")
		
		local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, keys.caster:GetAbsOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_PLAYER_CONTROLLED, FIND_ANY_ORDER, false)
		
		for _, unit in pairs(units) do
			print("Stripping the old buff")
			unit:RemoveModifierByNameAndCaster( "modifier_xlr8_attack_bonus", keys.caster)
		end
	end
	
	if keys.ability:GetLevel() >= keys.ability:GetMaxLevel() then
		return
	end
	Timers:CreateTimer(delay, function() 
		if keys.caster:HasModifier("modifier_xlr8_location_thinker") then
			SpeedUpLoop(keys)
		end
	end )
	
end

function RefreshBuff(keys)
	print("**************function SetLocation(keys)")
	ShallowPrintTable(keys)
end

function SetLocation(keys)
	print("**************function SetLocation(keys)")
	-- ShallowPrintTable(keys)
	
	keys.ability:SetActivated(false)
	keys.caster.sdata.xlr8_cooldown = 0
	keys.caster.sdata.xlr8_location = keys.caster:GetAbsOrigin()
end

function UpdateLocation(keys)
	print("**************function UpdateLocation(keys)")
	-- ShallowPrintTable(keys)
	ShallowPrintTable(keys.caster.sdata)
	local old_location = keys.caster.sdata.xlr8_location
	local new_location = keys.caster:GetAbsOrigin()
	local buff = keys.caster:FindModifierByName("modifier_xlr8_location_thinker")
	
	if (new_location - old_location):Length() > 100 then
		keys.caster:RemoveModifierByName("modifier_xlr8_location_thinker")
		return
	end
	
	keys.caster.sdata.xlr8_location = keys.caster:GetAbsOrigin()
	print(buff:GetElapsedTime())
	
	keys.caster.sdata.xlr8_cooldown = keys.caster.sdata.xlr8_cooldown + 3 + 3 * math.floor(buff:GetElapsedTime()/20)
end

function ResetAbility(keys)
	print("**************function ResetAbility(keys)")
	keys.ability:SetLevel(1)
	
	-- TODO implement rank bonus for the xlr8 cooldown
	local rank = 4
	
	
	local cd = round( (keys.caster.sdata.xlr8_cooldown) / ({1.5356,2.1070,2.9226,3.9391})[rank] ) + 5
	print(cd)
	keys.ability:SetActivated(true)
	keys.ability:StartCooldown(cd)
end

