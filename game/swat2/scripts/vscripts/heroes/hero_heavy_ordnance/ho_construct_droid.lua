--[[
	Author: Noya
	Date: April 5, 2015
	Get a point at a distance in front of the caster
]]
function GetFrontPoint( keys )
	local caster = keys.caster
	local fv = caster:GetForwardVector()
	local origin = caster:GetAbsOrigin()
	local distance = keys.Distance
	
	local front_position = origin + fv * distance
	local result = {}
	table.insert(result, front_position)

	return result
end

-- Set the units looking at the same point of the caster
function SetUnitsMoveForward( keys )
	local caster = keys.caster
	local target = keys.target
	local fv = caster:GetForwardVector()
	target:SetForwardVector(fv)
end

function SpinUpDroid(keys)
    -- Increase the level of the construct droid ability to update the cost
    local level = math.min(keys.ability:GetLevel() + 1, 5)
    keys.ability:SetLevel(level)
    
    -- create the set of minidroids if it doesn't already exist
    if not keys.caster.sdata.minidroids then
        keys.caster.sdata.minidroids = {}
    end
    
    local minidroids = keys.caster.sdata.minidroids
    
    -- Find an open id for the minidroid to use
    for i=1,5 do
        if not minidroids[i] then
            keys.target.minidroid_id = i
            break
        end
    end
    
    -- save the minidroid to his id
    minidroids[keys.target.minidroid_id] = keys.target
    
    -- find and apply the open aura
    local which_def_matrix = "modifier_defense_matrix_owner"..keys.target.minidroid_id
    keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, which_def_matrix, {})
    keys.ability:ApplyDataDrivenModifier(keys.caster, keys.target, "modifier_defense_matrix_all", {})
end

function SpinDownDroid(keys)
    -- Decrease the level of the construct droid ability to update the cost
    local level = math.max(keys.ability:GetLevel() - 1, 0)
    keys.ability:SetLevel(level)
    
    keys.caster.sdata.minidroids[keys.target.minidroid_id] = nil
end