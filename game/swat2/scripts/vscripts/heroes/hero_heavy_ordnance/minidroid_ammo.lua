function AddBonusDamageDice(keys)
	local current_base_min = keys.caster:GetBaseDamageMin()
	local bonus_min = keys.ability:GetSpecialValueFor("damage_min")
	print("Adding min", bonus_min)
	keys.caster:SetBaseDamageMin(current_base_min + bonus_min )
	
	local current_base_max = keys.caster:GetBaseDamageMax()
	local bonus_max = keys.ability:GetSpecialValueFor("damage_max")
	print("Adding max", bonus_max)
	keys.caster:SetBaseDamageMax(current_base_max + bonus_max )
end

function RemoveBonusDamageDice(keys)
	local current_base_min = keys.caster:GetBaseDamageMin()
	local bonus_min = keys.ability:GetSpecialValueFor("damage_min")
	print("Removing min", bonus_min)
	keys.caster:SetBaseDamageMin(current_base_min - bonus_min )
	
	local current_base_max = keys.caster:GetBaseDamageMax()
	local bonus_max = keys.ability:GetSpecialValueFor("damage_max")
	print("Removing max", bonus_max)
	keys.caster:SetBaseDamageMax(current_base_max - bonus_max )
end

function AddAcquisitionRange(keys)
    local current_range = keys.caster:GetAcquisitionRange()
    local bonus_range = keys.ability:GetSpecialValueFor("range")
    print("Droid Ammo Range+", current_range, bonus_range)
    keys.caster:SetAcquisitionRange(current_range + bonus_range)
    local unit_info = GameMode.unit_infos[keys.caster:GetUnitName()]
    print("Defaults:", unit_info["AttackAcquisitionRange"], unit_info["AttackRange"])
    print("Currents:", keys.caster:GetAcquisitionRange(), keys.caster:GetAttackRange())
end

function RemoveAcquisitionRange(keys)
    local current_range = keys.caster:GetAcquisitionRange()
    local bonus_range = keys.ability:GetSpecialValueFor("range")
    print("Droid Ammo Range-", current_range, bonus_range)
    keys.caster:SetAcquisitionRange(current_range - bonus_range)
    local unit_info = GameMode.unit_infos[keys.caster:GetUnitName()]
    print("Defaults:", unit_info["AttackAcquisitionRange"], unit_info["AttackRange"])
    print("Currents:", keys.caster:GetAcquisitionRange(), keys.caster:GetAttackRange())
end