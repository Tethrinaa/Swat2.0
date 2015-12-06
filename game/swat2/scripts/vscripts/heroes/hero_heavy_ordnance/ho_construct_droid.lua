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

function UpdateHOMinidroidAuras(ho, ability)
	local minidroids = ho.sdata.minidroids
	local all_def_matrix = "modifier_defense_matrix_all"
	local all_def_matrix_bonus = "modifier_defense_matrix_all_armor_bonus"
	

	for _, minidroid in pairs(minidroids) do
		if not minidroid:IsNull() then
			local which_def_matrix = "modifier_defense_matrix_owner"..minidroid.minidroid_id
			local which_def_matrix_bonus = "modifier_defense_matrix_owner"..minidroid.minidroid_id.."_armor_bonus"
	
			print("Removing auras")
			minidroid:RemoveModifierByName(all_def_matrix)
			minidroid:RemoveModifierByName(which_def_matrix)
			
			print("Reapplying auras")
			ability:ApplyDataDrivenModifier(ho, minidroid, which_def_matrix, {})
			ability:ApplyDataDrivenModifier(ho, minidroid, all_def_matrix, {})
			
			print("Removing buffs")
			minidroid:RemoveModifierByName(all_def_matrix_bonus)
			ho:RemoveModifierByName(which_def_matrix_bonus)
		end
	end
	
	ho:RemoveModifierByName(all_def_matrix_bonus)
end

function SpinUpDroid(keys)
	--TODO minidroidplasma state

    -- Increase the level of the construct droid ability to update the cost
    local level = math.min(keys.ability:GetLevel() + 1, keys.ability:GetMaxLevel())
	local minidroid = keys.target
	local ho = keys.caster
    keys.ability:SetLevel(level)
	
	-- Set the minidroid level to half of the HO's rounded-down, but at least 1
	local ho_hero_level = ho:GetLevel()
	local ho_hero_level_factor = keys.ability:GetSpecialValueFor("hero_level_factor")
	-- minidroid:SetLevel( math.max(math.floor(ho_hero_level / ho_hero_level_factor), 1 ) ) TODO I don't think this is actually necessary
	
	-- TODO Droid Integrity, Droid Ammo, Droid Movespeed
	
    
    -- create the set of minidroids if it doesn't already exist
    if not ho.sdata.minidroids then
        ho.sdata.minidroids = {}
    end
		
	-- TODO these need to pull from the players selections, not just from the current levels of the abilities
	-- Set up the mini ability names that the HO abilities correlate with
	local ability_map = {}
	ability_map.weapon_plasma_rounds_mini = ho.sdata.weaponSkill
	ability_map.primary_ho_plasma_shield = "primary_ho_plasma_shield"
	ability_map.primary_minidroid_storage_cells = "primary_ho_storage_cells"
	ability_map.primary_minidroid_ammo 		=	"primary_ho_droid_ammo"
	ability_map.primary_minidroid_integrity =	"primary_ho_droid_integrity"
	ability_map.primary_minidroid_mobility	 = 	"primary_ho_droid_mobility"
	ability_map.primary_minidroid_energy_beam = "primary_ho_power_grid"
	ability_map.nanites_standard = ho.sdata.nanitesSkill
		
	for mini_ability_name, ho_ability_name in pairs(ability_map) do
		
		if not minidroid:HasAbility(mini_ability_name) then
			print("Adding", mini_ability_name)
			minidroid:AddAbility(mini_ability_name)
		end
		local mini_ability = minidroid:FindAbilityByName(mini_ability_name)
		
		-- as longa s the ability exists, try to set its level
		if mini_ability then
			-- Calculate the ability level from the HO's ability
			local ho_level = ho:FindAbilityByName(ho_ability_name):GetLevel()
			local factor = keys.ability:GetSpecialValueFor(mini_ability_name.."_factor")
			local constant = keys.ability:GetSpecialValueFor(mini_ability_name.."_constant")
			local mini_level = math.floor(ho_level / factor) + constant

			-- Remove this buff so we can drop its level to 0 maybe
			print("Maybe removing "..mini_ability_name.." buff: ", mini_ability:GetIntrinsicModifierName())
			if mini_ability:GetIntrinsicModifierName() then
				print("Removing ", mini_ability:GetIntrinsicModifierName())
				minidroid:RemoveModifierByName(mini_ability:GetIntrinsicModifierName())
			end			
			
			-- Special things for some abilities
			if mini_ability_name == "primary_ho_storage_cells" then
				-- Standard energy from levels in cells
				local base_energy = keys.ability:GetSpecialValueFor("base_cells_energy")
				local per_level_cells_energy = keys.ability:GetSpecialValueFor("per_level_cells_energy")
				minidroid:SetMana(base_energy + per_level_cells_energy * mini_level)
				
			elseif mini_ability_name == "primary_minidroid_energy_beam" then
				-- Free beam on birth as long as the ho is above 250
				local base_beam_energy = keys.ability:GetSpecialValueFor("base_beam_energy")
				local per_level_beam_energy = keys.ability:GetSpecialValueFor("per_level_beam_energy")
				local ho_energy = ho:GetMana()
				local transfer_energy = math.max(0, math.min(ho_energy - 250, base_beam_energy + per_level_beam_energy * mini_level))
				
				-- transfer the energy
				ho:GiveMana(-1 * transfer_energy)
				minidroid:GiveMana(transfer_energy)
			elseif mini_ability_name == "nanites_standard" then -- TODO this needs a separate ability just for mini nanites so the standard one can't get overleveled. this goes to 24.
				-- TODO Espionage
				if true or ho:IsEspionage() then
					mini_level = mini_level - 1
				end
				if true or IsExtinction() then -- TODO bonus nanites on NM+
					mini_level = mini_level + 3
				elseif true or IsNightmare() then
					mini_level = mini_level + 1
				end
				
				-- capped by creator's level
				mini_level = math.min(ho_hero_level + 1, mini_level + (player_epics or 0) + 1) -- TODO player epics
				
				-- toggle nanites on automatically
				mini_ability:ToggleAbility()
			end
			
			print(mini_ability_name,ho_ability_name,"->",mini_level)
			mini_ability:SetLevel(mini_level)
		end
	end
	
    -- Find an open id for the minidroid to use
    local minidroids = ho.sdata.minidroids
    for i=1,5 do
        if not minidroids[i] then
            minidroid.minidroid_id = i
            break
        end
    end
    
    -- save the minidroid to his id
    minidroids[minidroid.minidroid_id] = minidroid
    
    -- Update the auras on all the droids to reflect the new droid count
	ShallowPrintTable(keys)
	UpdateHOMinidroidAuras(ho, keys.ability)
	minidroid:MoveToNPC(ho)
end

function SpinDownDroid(keys)
    -- Decrease the level of the construct droid ability to update the cost
    local level = math.max(keys.ability:GetLevel() - 1, 0)
    keys.ability:SetLevel(level)
    
    keys.caster.sdata.minidroids[keys.target.minidroid_id] = nil
	
	-- Update the auras of the remaining droids to reflect the new droid count
	UpdateHOMinidroidAuras(keys.caster, keys.ability)
end