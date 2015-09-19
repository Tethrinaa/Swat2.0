-- Credit mostly to MNoya for this, from his dotacraft project.
-- Custom Stat Values
HP_PER_STR = 0
HP_REGEN_PER_STR = 0.02
MANA_PER_INT = 0
MANA_REGEN_PER_INT = 0
ARMOR_PER_AGI = 0
ATKSPD_PER_AGI = 1
DAMAGE_PER_PRIMARY = 0

-- Default Dota Values
DEFAULT_HP_PER_STR = 19
DEFAULT_HP_REGEN_PER_STR = 0.03
DEFAULT_MANA_PER_INT = 13
DEFAULT_MANA_REGEN_PER_INT = 0.04
DEFAULT_ARMOR_PER_AGI = 0.14
DEFAULT_ATKSPD_PER_AGI = 1
DEFAULT_DAMAGE_PER_PRIMARY = 1

THINK_INTERVAL = 0.25

function GameMode:ModifyStatBonuses(unit)
	local hero = unit
	local applier = CreateItem("item_stat_modifier", nil, nil)

	local hp_adjustment = HP_PER_STR - DEFAULT_HP_PER_STR
	local hp_regen_adjustment = HP_REGEN_PER_STR - DEFAULT_HP_REGEN_PER_STR
	local mana_adjustment = MANA_PER_INT - DEFAULT_MANA_PER_INT
	local mana_regen_adjustment = MANA_REGEN_PER_INT - DEFAULT_MANA_REGEN_PER_INT
	local armor_adjustment = ARMOR_PER_AGI - DEFAULT_ARMOR_PER_AGI
	local attackspeed_adjustment = ATKSPD_PER_AGI - DEFAULT_ATKSPD_PER_AGI
	local damage_adjustment = DAMAGE_PER_PRIMARY  - DEFAULT_DAMAGE_PER_PRIMARY 

	print("Modifying Stats Bonus of hero "..hero:GetUnitName())

	Timers:CreateTimer(function()

		if not IsValidEntity(hero) then
         print("hero not valid")
			return
		end

		-- Initialize value tracking
		if not hero.custom_stats then
			hero.custom_stats = true
			hero.strength = 0
			hero.agility = 0
			hero.intellect = 0
		end

		-- Get player attribute values
		local strength = hero:GetStrength()
		local agility = hero:GetAgility()
		local intellect = hero:GetIntellect()
		
		-- Adjustments

		-- STR
		if strength ~= hero.strength then
			
			-- HP Bonus
			if not hero:HasModifier("modifier_health_bonus") then
				applier:ApplyDataDrivenModifier(hero, hero, "modifier_health_bonus", {})
			end

			local neg_health_stacks = -1 * strength * hp_adjustment
			hero:SetModifierStackCount("modifier_health_bonus", hero, neg_health_stacks)

			-- HP Regen Bonus
			if not hero:HasModifier("modifier_health_regen_constant") then
				applier:ApplyDataDrivenModifier(hero, hero, "modifier_health_regen_constant", {})
			end

			local neg_health_regen_stacks = -1 * strength * hp_regen_adjustment * 100
			hero:SetModifierStackCount("modifier_health_regen_constant", hero, neg_health_regen_stacks)


			-- Damage bonus, since strength is the primary attribute
			if not hero:HasModifier("modifier_damage_constant") then
				applier:ApplyDataDrivenModifier(hero, hero, "modifier_damage_constant", {})
			end

			local neg_damage_const = -1 * strength * damage_adjustment
			hero:SetModifierStackCount("modifier_damage_constant", hero, neg_damage_const )
		end

		-- AGI
		if agility ~= hero.agility then
			
			-- Base Armor Bonus
			local armor = agility * armor_adjustment
			hero:SetPhysicalArmorBaseValue(armor)
		end

		-- INT
		if intellect ~= hero.intellect then
			
			-- Mana Bonus
			if not hero:HasModifier("modifier_mana_bonus") then
				applier:ApplyDataDrivenModifier(hero, hero, "modifier_mana_bonus", {})
			end

			local neg_mana_stacks = -1 * intellect * mana_adjustment
			hero:SetModifierStackCount("modifier_mana_bonus", hero, neg_mana_stacks)

			-- Mana Regen Bonus
			if not hero:HasModifier("modifier_base_mana_regen") then
				applier:ApplyDataDrivenModifier(hero, hero, "modifier_base_mana_regen", {})
			end

			local neg_mana_regen_stacks = -1 * intellect * mana_regen_adjustment * 100
			hero:SetModifierStackCount("modifier_base_mana_regen", hero, neg_mana_regen_stacks)
		end

		-- Update the stored values for next timer cycle
		hero.strength = strength
		hero.agility = agility
		hero.intellect = intellect

		hero:CalculateStatBonus()
      
		return THINK_INTERVAL
	end)
end