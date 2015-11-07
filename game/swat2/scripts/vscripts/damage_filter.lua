ATTACK_TYPES = {
	"bullets",
	"rockets",
	"flame",
	"laser",
	"explosion",
	"melee1",
	"melee2",
}

ARMOR_TYPES = {
	"unarmored",
	"thick_skin",
	"power_armor",
	"mk2",
	"contraption",
	"vehicle",
}

-- Returns a string with the swat damage type
function GetAttackType( unit )
   local unit_name = unit:GetUnitName()
   local attack_type = nil

   if unit_name == "npc_swat_hero_tactician" then
      attack_type = unit.AttackType
   elseif GameMode.unit_infos[unit_name] then
      attack_type = GameMode.unit_infos[unit_name].AttackType
   else
      print("ERROR, NO ATTACK TYPE FOR UNIT:", unit_name)
   end
   return attack_type
end

-- Returns a string with the swat armor type
function GetArmorType( unit )
   local unit_name = unit:GetUnitName()
   local armor_type = nil
   
   if GameMode.unit_infos[unit_name] then
      armor_type = GameMode.unit_infos[unit_name].ArmorType
   else
      print("ERROR, NO ARMOR TYPE FOR UNIT:", unit_name)
   end
   return armor_type
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

   --print("info inside getdamage", attack_type, armor_type)
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
   
   local multiplier = 1.00
   local damagetype = filterTable["damagetype_const"]
   local damage = nil
   local attack_type = nil
   local armor_type = nil
   local victim = nil
   local attacker = nil
   local victim_index = nil
   local attacker_index = nil
   --print("damage type is:", damagetype)
   
	if damagetype == DAMAGE_TYPE_PHYSICAL then
		victim_index = filterTable["entindex_victim_const"]
		attacker_index = filterTable["entindex_attacker_const"]
	
		if not victim_index or not attacker_index then
			return true
		end
      
      -- Type conversion
      victim = EntIndexToHScript( victim_index )
      --print("name of victim is", victim:GetUnitName())
	   attacker = EntIndexToHScript( attacker_index )
      --print("name of attacker is", attacker:GetUnitName())
      
		attack_type  = GetAttackType( attacker )
      --print("attack type is: ", attack_type)
		armor_type = GetArmorType( victim )
      --print("armor type is: ", armor_type)
      
      if attack_type and armor_type then
         multiplier = GetDamageForAttackAndArmor(attack_type, armor_type)
         --print("multiplier is: ", multiplier)
      end

		damage = filterTable["damage"] * multiplier
	
		-- Reassign the new damage
		filterTable["damage"] = damage
		return true
	end
	return true
end