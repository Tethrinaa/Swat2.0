--[[Item Teleport
	Author: Dokuno
	Date: 23.09.2015.]]
 
-- When Item Teleport is cast this function determines the nature of the target:
-- If the target is a destination (location, ABM, Hero, Storage) then we call SetDestination.
-- If the target is an item we call Teleport. 
function DeployCamera( keys )
	local caster = keys.caster
	local target_point = keys.target_points[1]
	local ability = keys.ability
   local ability_level = ability:GetLevel() - 1

   local vision_radius = ability:GetLevelSpecialValueFor("vision_radius", ability_level) 
	local duration = ability:GetLevelSpecialValueFor("duration", ability_level)
   
	-- Create the land mine and apply the land mine modifier
   -- find clear space for unit
	local camera = CreateUnitByName("npc_dota_observer_wards", target_point, false, nil, nil, caster:GetTeamNumber())
   -- Apply invis to the camera...
   ability:ApplyDataDrivenModifier(caster, camera, modifier_camera_invis, {})
   return 0
end


