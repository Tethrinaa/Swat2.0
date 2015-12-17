
--- Adds bonus dice.
-- This should be used with RunScript from the OnCreated of a modifier.
-- It should be undone by RemoveBonusDamageDice.
-- It exists because modifiers don't support adding a random range of values
-- The modifier is removed, the level increased and the modifier reapplied to get the values right

function AddBonusDamageDice(keys)
	local current_base_min = keys.caster:GetBaseDamageMin()
	local bonus_min = keys.ability:GetSpecialValueFor("damage_min")
	keys.caster:SetBaseDamageMin(current_base_min + bonus_min )
	
	local current_base_max = keys.caster:GetBaseDamageMax()
	local bonus_max = keys.ability:GetSpecialValueFor("damage_max")
	keys.caster:SetBaseDamageMax(current_base_max + bonus_max )
end

function RemoveBonusDamageDice(keys)
	local current_base_min = keys.caster:GetBaseDamageMin()
	local bonus_min = keys.ability:GetSpecialValueFor("damage_min")
	keys.caster:SetBaseDamageMin(current_base_min - bonus_min )
	
	local current_base_max = keys.caster:GetBaseDamageMax()
	local bonus_max = keys.ability:GetSpecialValueFor("damage_max")
	keys.caster:SetBaseDamageMax(current_base_max - bonus_max )
end

--- Adds acquisition range.
-- This should be used with RunScript from the OnCreated of a modifier.
-- It should be undone by RemoveAcquisitionRange.
-- It exists because modifiers don't support bonus acquisition range.
-- The modifier is removed, the level increased and the modifier reapplied to get the values right

function AddAcquisitionRange(keys)
    local current_range = keys.caster:GetAcquisitionRange()
    local bonus_range = keys.ability:GetSpecialValueFor("range")
    keys.caster:SetAcquisitionRange(current_range + bonus_range)
    local unit_info = GameMode.unit_infos[keys.caster:GetUnitName()]
end

function RemoveAcquisitionRange(keys)
    local current_range = keys.caster:GetAcquisitionRange()
    local bonus_range = keys.ability:GetSpecialValueFor("range")
    keys.caster:SetAcquisitionRange(current_range - bonus_range)
    local unit_info = GameMode.unit_infos[keys.caster:GetUnitName()]
end