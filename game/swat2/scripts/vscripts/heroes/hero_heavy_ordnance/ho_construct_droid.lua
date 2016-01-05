-- Author: NmdSnprEnigma

--- Grabs a point in front of the caster

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

-- Upgrades the aura of exist minis to the right level when a mini is born or dies
function UpdateHOMinidroidAuras(ho, ability)
	local minidroids = ho.sdata.minidroids
	local all_def_matrix = "modifier_defense_matrix_all"
	local all_def_matrix_bonus = "modifier_defense_matrix_all_armor_bonus"
	
	-- 
	for _, minidroid in pairs(minidroids) do
		if not minidroid:IsNull() then
			local which_def_matrix = "modifier_defense_matrix_owner"..minidroid.minidroid_id 
			-- TODO you are supposed to be able to make a multiplier stack
			local which_def_matrix_bonus = "modifier_defense_matrix_owner"..minidroid.minidroid_id.."_armor_bonus" 
	
			-- Remove and replace the HO and all units aura so the right levels will apply
			minidroid:RemoveModifierByName(all_def_matrix)
			minidroid:RemoveModifierByName(which_def_matrix)
			ability:ApplyDataDrivenModifier(ho, minidroid, which_def_matrix, {})
			ability:ApplyDataDrivenModifier(ho, minidroid, all_def_matrix, {})
			
			-- Remove the buffs so they can be repopulated by the auras
			-- Something about the self auras makes this necessary - the ho himself is fine without this
			minidroid:RemoveModifierByName(all_def_matrix_bonus)
			ho:RemoveModifierByName(which_def_matrix_bonus)
		end
	end
	
	ho:RemoveModifierByName(all_def_matrix_bonus)
end

--- Calculate the ability level from the HO's ability and return both

function CalculateMiniAbilityLevel(ho, ability, mini_ability_name, ho_ability_name)
	local ho_level = ho:FindAbilityByName(ho_ability_name):GetLevel()
	local factor = ability:GetSpecialValueFor(mini_ability_name.."_factor")
	local constant = ability:GetSpecialValueFor(mini_ability_name.."_constant")
	local mini_level = math.floor(ho_level / factor) + constant
	return mini_level, ho_level
end

require('heroes/hero_heavy_ordnance/minidroid_energy_beam')

function SpinUpDroid(keys)
	--TODO minidroidplasma state

    -- Increase the level of the construct droid ability to update the cost
    local level = math.min(keys.ability:GetLevel() + 1, keys.ability:GetMaxLevel())
	local minidroid = keys.target
	local ho = keys.caster
    keys.ability:SetLevel(level)
	
	-- create the set of minidroids if it doesn't already exist
    if not ho.sdata.minidroids then
        ho.sdata.minidroids = {}
    end
		
	-- TODO these need to pull from the players selections, not just from the current levels of the abilities
	-- Set up the mini ability names that the HO abilities correlate with
	local ability_map = {}
	table.insert(ability_map, {mini_ability_name = "weapon_plasma_rounds_mini" 		, ho_ability_name = ho.sdata.weaponSkill             	})
	table.insert(ability_map, {mini_ability_name = "primary_ho_plasma_shield" 		, ho_ability_name = "primary_ho_plasma_shield"        	})
	local cells_entry = {mini_ability_name = "primary_minidroid_storage_cells"		, ho_ability_name = "sub_ho_storage_cells" 			}
	table.insert(ability_map, cells_entry)
	table.insert(ability_map, {mini_ability_name = "minidroid_ammo" 				, ho_ability_name =	"sub_ho_droid_ammo"     			})
	table.insert(ability_map, {mini_ability_name = "minidroid_integrity" 			, ho_ability_name =	"sub_ho_droid_integrity"			})
	table.insert(ability_map, {mini_ability_name = "minidroid_mobility"	 			, ho_ability_name = "sub_ho_droid_mobility" 			})
	table.insert(ability_map, {mini_ability_name = "primary_minidroid_energy_beam" 	, ho_ability_name = "primary_ho_power_grid"      		})
	table.insert(ability_map, {mini_ability_name = "nanites_standard"				, ho_ability_name = ho.sdata.nanitesSkill				})

	-- Grant all the mini his abilities in the appropriate order, based on the list above
	for _, mapEntry in pairs(ability_map) do
		local mini_ability_name = mapEntry.mini_ability_name
		if not minidroid:HasAbility(mini_ability_name) then
			minidroid:AddAbility(mini_ability_name)
		end
	end
	
	-- Max mana has to be controlled via levels for creatures, so find and set the right level for this
	local mini_cells_name = cells_entry.mini_ability_name
	local ho_cells_name = cells_entry.ho_ability_name
	local mini_upgrade_level = CalculateMiniAbilityLevel(ho, keys.ability, mini_cells_name, ho_cells_name)
	minidroid:CreatureLevelUp(mini_upgrade_level)
	
	-- For each mini ability...
	for _, mapEntry in pairs(ability_map) do
		local mini_ability_name = mapEntry.mini_ability_name
		local ho_ability_name = mapEntry.ho_ability_name
		if not minidroid:HasAbility(mini_ability_name) then
			print("Adding", mini_ability_name)
			minidroid:AddAbility(mini_ability_name)
		end
		local mini_ability = minidroid:FindAbilityByName(mini_ability_name)
		
		-- as long as the ability exists, try to set its level
		if mini_ability then
			local mini_level, ho_level = CalculateMiniAbilityLevel(ho, keys.ability, mini_ability_name, ho_ability_name)
		
			-- Special things for some abilities
			if mini_ability_name == "primary_minidroid_storage_cells" then
				-- Standard energy from levels in cells
				minidroid:SetMana(keys.ability:GetLevelSpecialValueFor("cells_energy", ho_level + 1))
                print(minidroid:GetMana())
				
			elseif mini_ability_name == "primary_minidroid_energy_beam" then
				-- Free beam on birth as long as the ho is above 250
				local birth_energy_param = mini_level < 1 and "birth_energy_base" or "birth_energy"
				print("Energy:", mini_level, keys.ability:GetLevelSpecialValueFor(birth_energy_param, mini_level - 1))
				TransferEnergy(minidroid, ho, keys.ability:GetLevelSpecialValueFor(birth_energy_param, mini_level - 1), keys.ability:GetSpecialValueFor("birth_energy_reserve") )
				
			elseif mini_ability_name == "nanites_standard" then -- TODO this needs a separate ability just for mini nanites so the standard one can't get overleveled. this goes to 24.
				-- TODO Espionage
				if true or ho:IsEspionage() then
					mini_level = mini_level - 1
				end
				if false then -- and IsExtinction() then -- TODO bonus nanites on NM+
					mini_level = mini_level + 3
				elseif false then -- and IsNightmare() then
					mini_level = mini_level + 1
				end
				
				-- capped by creator's level
				local ho_hero_level = ho:GetLevel()
				mini_level = math.min(ho_hero_level + 1, mini_level + (player_epics or 0) + 1) -- TODO player epics
				
				-- toggle nanites on automatically
				mini_ability:ToggleAbility()
			end
			
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