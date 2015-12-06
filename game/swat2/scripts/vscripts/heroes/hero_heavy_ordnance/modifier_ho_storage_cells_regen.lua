modifier_ho_storage_cells_regen = class({})
require("util/SWATutil")
require("util/utils")

function modifier_ho_storage_cells_regen:OnCreated( keys )

	-- This doesn't change, but it would need to be moved if it became dynamic
	-- I set it here so it can be used by IsHidden on the "buff icon" version
	self.regen_threshhold = self:GetAbility():GetSpecialValueFor( "regen_threshhold" )
	
	-- This is an indicator that real values are coming in
	local new_storage = self:GetAbility():GetSpecialValueFor( "bonus_storage" ) or 0
	local storage = self.bonus_storage or 0
	
	-- only update if we have a new value and it's greater than the current and the create/refresh isn't 
	-- one of them fucked up fake versions that sends over a unit that doesn't have SetMana
	-- We need ensure that this is only run once for each level and we don't actually want to drop the unit's max mana in between.
	if new_storage > storage and self:GetParent().SetMana then
		-- Bump the energy down so that when the new bonus kicks, in, the value stays same instead of the %
		AdjustManaDownPre(self:GetParent(), new_storage - storage)
		
		-- Set the functional values of the ability so it grants the storage and regen under the threshhold
		self.bonus_regen = 		self:GetAbility():GetSpecialValueFor( "bonus_regen" )
		self.bonus_storage = 	self:GetAbility():GetSpecialValueFor( "bonus_storage" )
		
		-- Set the stack count of the modifier so it's easier to understand
		self:SetStackCount(self:GetAbility():GetLevel())
	end
end

--- Forward to the create method because we handle it all the same anyway
function modifier_ho_storage_cells_regen:OnRefresh( keys )
	self:OnCreated(keys)
end

function modifier_ho_storage_cells_regen:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_BONUS
	}
 
	return funcs
end

--- Returns the mana cap bonus for the modifier
function modifier_ho_storage_cells_regen:GetModifierManaBonus()
	return self.bonus_storage or 0
end

--- Returns the mana regen bonus for the modifier
function modifier_ho_storage_cells_regen:GetModifierConstantManaRegen()
	local threshhold = self.regen_threshhold or 0
	local regen = 0
	
	-- Only apply the regen bonus if you're under the threshhold
	-- This is the whole reason for the lua buff and ability.
	if (self:GetParent():GetMana() < threshhold and string.find(self:GetParent():GetUnitName(), "sniper")) then -- here, sniper is the main hero, so that minidroids don't get this
		regen = self.bonus_regen or 0
	end
	
	return regen
end

--- Hides the buff icon if energy is over the threshhold
function modifier_ho_storage_cells_regen:IsHidden()
	local threshhold = self.regen_threshhold or 0
	
	return not (self:GetParent():GetMana() < threshhold)
end
