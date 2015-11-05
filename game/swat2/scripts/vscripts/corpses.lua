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
    if unit_info and unit_info["CorpseDuration"] then
        if unit_info["CorpseDuration"] == 0 then
            return
        else
            SetCorpseDuration(corpse, unit_info["CorpseDuration"])
        end
    else
        SetCorpseDuration(corpse, CORPSE_DURATION)
    end
	return corpse
end

-- Custom Corpse Mechanic
function LeavesCorpse( unit )
	if not unit or not IsValidEntity(unit) then
		return false

	-- Ignore buildings	
	elseif unit.GetInvulnCount ~= nil then
		return false

	-- Ignore custom buildings
	elseif unit:FindAbilityByName("ability_building") then
		return false

	-- Ignore units that start with dummy keyword	
	elseif string.find(unit:GetUnitName(), "dummy") then
		return false

	-- Ignore units that were specifically set to leave no corpse
	elseif unit.no_corpse then
		return false

	-- Read the LeavesCorpse KV
	else
		local unit_info = GameMode.unit_infos[unit:GetUnitName()]
		if unit_info and unit_info["LeavesCorpse"] and unit_info["LeavesCorpse"] == 0 then
			return false
		else
			-- Leave corpse		
			return true
		end
	end
end

function SetNoCorpse( event )
	event.target.no_corpse = true
end