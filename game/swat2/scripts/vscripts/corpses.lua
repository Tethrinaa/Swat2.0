CORPSE_MODEL = "models/creeps/neutral_creeps/n_creep_troll_skeleton/n_creep_troll_skeleton_fx.vmdl"
CORPSE_UNIT = "dummy_unit"
CORPSE_DURATION = 88

function IsCorpse( unit )
    return unit.killedUnit ~= nil
end

function SetCorpseDuration( corpse, duration )
    corpse.corpse_expiration = GameRules:GetGameTime() + duration
    Timers:CreateTimer(duration, function()
        if corpse and IsValidEntity(corpse) then
            corpse:RemoveSelf()
        end
    end)
end

function LeaveCorpse( unit )
    -- Create unit and make invulnerable
	local corpse = CreateUnitByName("dummy_unit", unit:GetAbsOrigin(), true, unit, unit, unit:GetTeamNumber())

    -- Create the default corpse unless a different one is specified in the config for the unit
    local model = CORPSE_MODEL
    local unit_info = GameMode.unit_infos[unit:GetUnitName()]
    if unit_info and unit_info["CorpseModel"] then
        model = unit_info["CorpseModel"]
    end
	corpse:SetModel(model)

	-- Set the corpse invisible until the dota corpse disappears
	corpse:AddNoDraw()

    -- Keep a reference to the unit whose body this was
	corpse.killedUnit = unit

	-- Set custom corpse visible
	Timers:CreateTimer(.5, function()
		if IsValidEntity(corpse) then
			corpse:RemoveNoDraw()
		end
	end)

	-- Remove itself after the corpse duration
	-- If this unit type has a certain duration specified ...
    if unit_info and unit_info["CorpseDuration"] then
	
		-- ... use that duration ...
        if unit_info["CorpseDuration"] ~= 0 then
            SetCorpseDuration(corpse, unit_info["CorpseDuration"])
			
		-- ... but 0 means indefinite ...
        else 
            return nil
        end
		
	-- ... otherwise just use the default duration for corpses
    else
        SetCorpseDuration(corpse, CORPSE_DURATION)
    end
	return corpse
end

--- Determines if a unit leaves a corpse on death.
-- @param unit The unit to check
-- @return boolean true if it leaves a corpse, false otherwise.
function LeavesCorpse( unit )
	if not unit or not IsValidEntity(unit) then
		return false
		
	-- no mechanical units leave corpses
	elseif IsMechanical(unit) then
		return false

	-- Ignore units that start with dummy keyword
	elseif string.find(unit:GetUnitName(), "dummy") then
		return false

	-- Ignore units that were specifically set to leave no corpse
	-- e.g. microwaved
	elseif unit.no_corpse then
		return false

	-- Read the LeavesCorpse KV
	else
		local unit_info = GameMode.unit_infos[unit:GetUnitName()]
		
		-- Only skip a corpse if it specifically says to skip it for the unit type
		if unit_info and unit_info["LeavesCorpse"] and unit_info["LeavesCorpse"] == 0 then
			return false
			
		-- otherwise, assume everything leaves a corpse.
		else
			return true
		end
	end
end

--- Sets a unit to not leave a corpse on death.
-- @param unit The unit to remove from corpsing
function SetNoCorpse( unit )
	unit.no_corpse = true
end
