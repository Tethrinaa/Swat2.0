modifier_ho_plasma_shield_aura = class({})

--------------------------------------------------------------------------------

function modifier_ho_plasma_shield_aura:IsAura()
	return true
end

--------------------------------------------------------------------------------

function modifier_ho_plasma_shield_aura:GetModifierAura()
    print("Grabbing modifier")
	return "modifier_ho_plasma_shield_burn"
end

--------------------------------------------------------------------------------

function modifier_ho_plasma_shield_aura:GetAuraSearchTeam()
    print("Searching")
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_ho_plasma_shield_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_TYPE_BASIC
end

--------------------------------------------------------------------------------

function modifier_ho_plasma_shield_aura:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("aura_radius")
end

-- --------------------------------------------------------------------------------

-- function modifier_ho_plasma_shield_aura:GetAuraEntityReject( hEntity )
    -- print("Checking a unit for aura")
	-- return string.find(hEntity:GetUnitName(), "innard" )
-- end

--------------------------------------------------------------------------------

function modifier_ho_plasma_shield_aura:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_EVASION_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_ho_plasma_shield_aura:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("eps_cost")
end

--------------------------------------------------------------------------------

function modifier_ho_plasma_shield_aura:GetModifierEvasion_Constant()
	return self:GetAbility():GetSpecialValueFor("bonus_evasion")
end

--------------------------------------------------------------------------------
