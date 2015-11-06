ATTACK_TYPES = {
	["SWAT_ATTACK_TYPE_BULLETS"] 	= "bullets",
	["SWAT_ATTACK_TYPE_ROCKETS"] 	= "rockets",
	["SWAT_ATTACK_TYPE_FLAME"] 	= "flame",
	["SWAT_ATTACK_TYPE_LASER"] 	= "laser",
	["SWAT_ATTACK_TYPE_EXPLOSION"] 	= "explosion",
	["SWAT_ATTACK_TYPE_MELEE1"] 	= "melee1",
	["SWAT_ATTACK_TYPE_MELEE2"] 	= "melee2",
}

ARMOR_TYPES = {
	["SWAT_ARMOR_TYPE_NONE"] 	= "unarmored",
	["SWAT_ARMOR_TYPE_THICK_SKIN"] 	= "thick_skin",
	["SWAT_ARMOR_TYPE_POWER_ARMOR"] = "power_armor",
	["SWAT_ARMOR_TYPE_MK2"] 	= "mk2",
	["SWAT_ARMOR_TYPE_CONTRAPTION"] = "contraption",
	["SWAT_ARMOR_TYPE_VEHICLE"] 	= "vehicle",
}

-- Returns a string with the swat damage type
function GetAttackType( unit )
	local unitName = unit:GetUnitName()
	local attack_string = unit.AttackType
	return ATTACK_TYPES[attack_string]
end


-- Changes the Attack Type string defined in the KV, and the current visual tooltip
function SetAttackType( unit, attack_type )
	local unitName = unit:GetUnitName()
	if GameRules.UnitKV[unitName]["AttackType"] then
		local current_attack_type = GetAttackType(unit)
		unit:RemoveModifierByName("modifier_attack_"..current_attack_type)

		local attack_key = getIndexTable(ATTACK_TYPES, attack_type)
		GameRules.UnitKV[unitName]["AttackType"] = attack_key

		ApplyModifier(unit, "modifier_attack_"..attack_type)
	end
end

-- Returns a string with the swat armor type
function GetArmorType( unit )
	local unitName = unit:GetUnitName()
	local armor_string = unit.ArmorType
	return ARMOR_TYPES[armor_string]
end

-- Changes the Armor Type string defined in the KV, and the current visual tooltip
function SetArmorType( unit, armor_type )
	local unitName = unit:GetUnitName()
	if GameRules.UnitKV[unitName]["ArmorType"] then
		local current_armor_type = GetArmorType(unit)
		unit:RemoveModifierByName("modifier_armor_"..current_armor_type)

		local armor_key = getIndexTable(ARMOR_TYPES, armor_type)
		GameRules.UnitKV[unitName]["ArmorType"] = armor_key

		ApplyModifier(unit, "modifier_armor_"..armor_type)
	end
end

function GetDamageForAttackAndArmor( attack_type, armor_type )
--[[
         Unarm    Thick   Power   Mk2   Contrapt Vehicle   
Bullets   100%    100%     40%    32%     35%     10%   
Rockets   100%    140%     30%    24%     20%     40%    
Flame     100%    100%     15%    15%     10%      5%      
Laser     100%    100%    100%    80%     10%      5%     
Explosion 100%    150%     50%    40%     40%     99% 
Melee1    100%    100%    100%    66%     10%     90%
Melee2    100%     50%    100%    66%    100%     60%
-- Custom Attack Types -Unknown -BDO
Magic   100%    125%    75%     200%    35%    50%
Spells  100%    100%    100%    100%    100%   70%  
]]
	if attack_type == "bullets" then
		if armor_type == "unarmored" then
			return 1.00
		elseif armor_type == "thick_skin" then
			return 1.00
		elseif armor_type == "power_armor" then
			return 0.40
		elseif armor_type == "mk2" then
			return 0.32
		elseif armor_type == "contraption" then
			return 0.35
		elseif armor_type == "vehicle" then
			return 0.10
		end

	elseif attack_type == "rockets" then
		if armor_type == "unarmored" then
			return 1.00
		elseif armor_type == "thick_skin" then
			return 1.40
		elseif armor_type == "power_armor" then
			return 0.30
		elseif armor_type == "mk2" then
			return 0.24
		elseif armor_type == "contraption" then
			return 0.20
		elseif armor_type == "vehicle" then
			return 0.40
		end

	elseif attack_type == "flame" then
		if armor_type == "unarmored" then
			return 1.00
		elseif armor_type == "thick_skin" then
			return 1.00
		elseif armor_type == "power_armor" then
			return 0.15
		elseif armor_type == "mk2" then
			return 0.15
		elseif armor_type == "contraption" then
			return 0.10
		elseif armor_type == "vehicle" then
			return 0.05
		end

	elseif attack_type == "laser" then
		if armor_type == "unarmored" then
			return 1.00
		elseif armor_type == "thick_skin" then
			return 1.00
		elseif armor_type == "power_armor" then
			return 1.00
		elseif armor_type == "mk2" then
			return 0.80
		elseif armor_type == "contraption" then
			return 0.10
		elseif armor_type == "vehicle" then
			return 0.05
		end

	elseif attack_type == "explosion" then
		if armor_type == "unarmored" then
			return 1.00
		elseif armor_type == "thick_skin" then
			return 1.50
		elseif armor_type == "power_armor" then
			return 0.50
		elseif armor_type == "mk2" then
			return 0.40
		elseif armor_type == "contraption" then
			return 0.40
		elseif armor_type == "vehicle" then
			return 0.99
		end

	elseif attack_type == "melee1" then
		if armor_type == "unarmored" then
			return 1.00
		elseif armor_type == "thick_skin" then
			return 1.00
		elseif armor_type == "power_armor" then
			return 1.00
		elseif armor_type == "mk2" then
			return 0.60
		elseif armor_type == "contraption" then
			return 0.10
		elseif armor_type == "vehicle" then
			return 0.90
		end

	elseif attack_type == "melee2" then
		if armor_type == "unarmored" then
			return 1.00
		elseif armor_type == "thick_skin" then
			return 0.50
		elseif armor_type == "power_armor" then
			return 1.00
		elseif armor_type == "mk2" then
			return 0.66
		elseif armor_type == "contraption" then
			return 1.00
		elseif armor_type == "vehicle" then
			return 0.60
		end
	end
	return 1
end

-- Global item applier
function ApplyModifier( unit, modifier_name )
	local item = CreateItem("item_apply_modifiers", nil, nil)
	item:ApplyDataDrivenModifier(unit, unit, modifier_name, {})
	item:RemoveSelf()
end

-- This function applies the actual armor damage reduction
function GameMode:FilterDamage( filterTable )
   
   local multiplier = 1
   local damagetype = filterTable["damagetype_const"]
   print("damage type is:", damagetype)
   
	if damagetype == DAMAGE_TYPE_PHYSICAL then
		local victim_index = filterTable["entindex_victim_const"]
		local attacker_index = filterTable["entindex_attacker_const"]
	
		if not victim_index or not attacker_index then
			return true
		end
      
      -- Type conversion
      local victim = EntIndexToHScript( victim_index )
	   local attacker = EntIndexToHScript( attacker_index )
      
		local attack_type  = GetAttackType( attacker )
      print("attack type is: ", attack_type)
		local armor_type = GetArmorType( victim )
      print("armor type is: ", armor_type)
      
      if attack_type and armor_type then
         local multiplier = GetDamageForAttackAndArmor(attack_type, armor_type)
         print("multiplier is: ", multipler)
      end

		local damage = filterTable["damage"] * multiplier
	
		-- Reassign the new damage
		filterTable["damage"] = damage
		return true
	end
	return true
end