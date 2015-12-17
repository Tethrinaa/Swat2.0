--- Returns true if the unit type is mechanical.
function IsMechanical(unit)
    return HasUnitTypeFlag(unit, "IsMechanical")
end

--- Returns true if the unit type is organic.
function IsOrganic(unit)
    return not IsMechanical(unit)
end

--- Returns true if the unit type is wearing PA.
function IsPowerArmor(unit)
    return HasUnitTypeFlag(unit, "IsPowerArmor")
end

--- Returns if a unit type has a flag.
-- Determines this by checking the K-V pairs for a unit's type for a value of 1.
-- @param unit Unit to check
-- @param flag_name The name of the key to check
function HasUnitTypeFlag(unit, flag_name)
    local unit_info = GameMode.unit_infos[unit:GetUnitName()]

	-- If it is defined, and the flag_name value is 1 then return true
	-- otherwise, the default is false
    return unit_info ~= nil and unit_info[flag_name] == 1
end


function SwapAbilitiesLua(caster, on_ability, off_ability)
    caster:SwapAbilities(on_ability, off_ability, true, false)
end

function SwapAbilitiesDataDriven(keys)
    SwapAbilitiesLua(keys.caster, keys.on_ability, keys.off_ability)
end

--- Searches for valid revive targets in an area.
-- @param location The center of the search area
-- @param location The radius of the search area
-- @param location The team number of the corpses to find
-- @return List containing the eligible corpses
function FindValidReviveTargets(location, radius, team_number)
    -- Grab all entities in the area
	local units = Entities:FindAllInSphere(location, radius)
    local corpses = {}
	
	-- if the entity is a unit (i.e. has a unit name function)...
    for k, corpse in ipairs(units) do
		if corpse.GetUnitName then
			
			-- ... and if it is a corpse ...
			if IsCorpse(corpse) and corpse:GetTeamNumber() == team_number then
				
				-- ... add it to the list of corpses
				table.insert(corpses, corpse)
			end
		end
    end
	
    return corpses
end

--- Increases the power armor damage.
-- @param unit The unit (hero) whose armor needs to be broken
-- @return boolean whether the armor was broken more or not (used by watchman Partner)
function ApplyPowerArmorDamage(unit)
    -- TODO this needs to not apply to heros with the power armor trait
    if not unit:IsHero() then
        return
    end

    -- Try to grab the passive ability that handles power armor damage
    local damaged_armor_abil = unit:FindAbilityByName("damaged_power_armor")
    
    -- Add it if you need to
    if not damaged_armor_abil then
        damaged_armor_abil = unit:AddAbility("damaged_power_armor")
    end
    
    -- Increase the level by 1 as long as that doesn't bring the hero over the max
    local damaged_armor_level = damaged_armor_abil:GetLevel()
    if damaged_armor_level < damaged_armor_abil:GetMaxLevel() then
        damaged_armor_abil:SetLevel(damaged_armor_level + 1)
		
		-- Signal that we were able to damage the armor
		return true
    end
	
	-- Return false to indicate that the armor couldn't be damaged any further
	return false
end

--- Revives a unit. For use with medic_revive and item_revive
-- @param corpse A dummy unit marking where the body died.
-- @param ability The revive ability
-- @param victimized boolean for skipping armor and rez_sick
function ReviveUnit(corpse, ability, victimized)
    local unit = corpse.killedUnit
	
    -- sdata (SWAT data) doesn't follow a unit through respawn so we have to move it manually
    local sdata = unit.sdata
    	
	-- This was a standard unit that died, we'll have to recreate it from its sdata
	if unit:IsNull() or not unit:UnitCanRespawn() then
	
		-- Create a copy of the unit where the corpse was
		local location = corpse:GetAbsOrigin()
		unit = CreateUnitByName(unit.sdata.unit_name, location, true, corpse, corpse, corpse:GetTeamNumber())
		FindClearSpaceForUnit(unit, location, false)
		
		-- move over its sdata
		unit.sdata = sdata
		
		-- set the appropriate amount of revive energy (main for returners)
		if sdata.revive_energy then
			unit:SetMana(sdata.revive_energy)
		end
		
		-- clear out the corpse
		corpse:RemoveSelf()
		
	-- This was a hero
    elseif unit:UnitCanRespawn() then    
		unit:RespawnUnit()
		
		-- move the unit's sdata over from the old unit
		unit.sdata = sdata
        
        -- Move the unit to where the corpse was
		local location = corpse:GetAbsOrigin()
        FindClearSpaceForUnit(unit, location, false)
        corpse:RemoveSelf()
        
        -- As long as the player was neither a victim or noob, break armor and apply rez sick
        if not victimized then
            local armor_index = 0
            if unit.sdata.armor_index then
				armor_index = unit.sdata.armor_index
			end
        
            -- If this revive needs to apply rez_sickness to the target
            if unit:IsHero() then  
                -- Set the revive energy based on your armor type
                unit:SetMana(ability:GetLevelSpecialValueFor("revive_energy", armor_index))
                
                -- TODO This will need to get factored into the experience system
                local exp_bonus_percent = ability:GetSpecialValueFor("exp_bonus_percent")
                
                -- Apply the rez sickness itself
                local mod_keys = {}
                mod_keys.duration = ability:GetLevelSpecialValueFor("sickness_duration", armor_index)
                mod_keys.ms_bonus_percent = ability:GetLevelSpecialValueFor("ms_bonus_percent", armor_index)
                mod_keys.as_bonus_percent = ability:GetLevelSpecialValueFor("as_bonus_percent", armor_index)
				DeepPrintTable(mod_keys)
                Timers:CreateTimer(1, function() unit:AddNewModifier( ability:GetCaster(), ability, "modifier_medic_revive_rez_sickness_lua", mod_keys ) end)
            end
            
            -- If this revive needs to damage the unit's power armor
            if unit:IsHero() then -- TODO break power armor
                -- ApplyPowerArmorDamage(unit)
            end
        end
    else
		print("Should never have gotten here")
	end
end

--- Abort the cast of an ability.
-- @param ability The ability to abort/refresh
-- @param error_message The error message, hopefully a #key into the tooltips file
function AbortAbilityCast(ability, error_message)
	local caster = ability:GetCaster()
	local pID = caster:GetPlayerOwnerID()
	
	caster:Interrupt()
	SendErrorMessage(pID, error_message)
	
	-- refund and reset the cooldown
	local mana = caster:GetMana()
	Timers:CreateTimer(function() ability:EndCooldown() end)		
	Timers:CreateTimer(function() caster:SetMana(mana) end)
end

--- Determine if a unit is a target for Mend Wounds
function IsMendWoundsTarget(unit)
	return IsOrganic(unit) and unit:GetHealthDeficit() > 0
end

--- Ensure that the target of an ability is valid.
-- This function should be called in the OnAbilityPhaseStart action of an ability.
-- That ability should have a cast point greater than 0 to allow this function to abort it.
-- @param ability The ability being cast
-- @param target The target unit of the ability cast
-- @param filter_func The function determining the validity of the target
-- @param error_message The error message, hopefully a #key into the tooltips file
-- @return true if the target was valid, false otherwise
function ValidateAbilityTarget(ability, target, filter_func, error_message)

	-- if the target doesn't pass the filter, then abort the ability
    if not filter_func(target) then
		AbortAbilityCast(ability, error_message)
		return false
    end
	
	return true
end

--- Force a caster to cast an ability on the nearest eligible target in a radius.
-- @param ability The ability that will be cast
-- @param autocast_radius The radius to search for a target
-- @param target_team The team (relative to the caster) to search for
-- @param filter_func Functions which returns true for eligible targets
function AutoCastAbility(ability, autocast_radius, target_team, filter_func)
	local caster = ability:GetCaster()

	-- Get if the ability is on autocast mode and is castable right now...
	if caster:IsIdle() and ability:GetAutoCastState() and ability:IsFullyCastable() then
		-- Find targets in radius...
		local target
		local targets = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, autocast_radius, target_team, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)

		-- Find the closest target ...
		for _,unit in pairs(targets) do
			-- ... who passes the filter 
			if filter_func(unit) then
				target = unit
				break
			end
		end

		-- Cast the ability on him
		if not target then
			return
		else
			caster:CastAbilityOnTarget(target, ability, caster:GetPlayerOwnerID())
		end
	else
		-- The caster wasn't ready for one reason or another
	end
end