modifier_medic_revive_rez_sickness_lua = class({})

-------------------------------------------------------------------------------
 
function modifier_medic_revive_rez_sickness_lua:IsDebuff()
	return true
end
 
--------------------------------------------------------------------------------
 
function modifier_medic_revive_rez_sickness_lua:GetEffectName()
	return "particles/units/heroes/hero_silencer/silencer_curse.vpcf"
end
 
--------------------------------------------------------------------------------
 
function modifier_medic_revive_rez_sickness_lua:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
 
--------------------------------------------------------------------------------

function modifier_medic_revive_rez_sickness_lua:GetModifierMoveSpeedBonus_Percentage( params )
	return self.params.ms_bonus_percent
end
 
--------------------------------------------------------------------------------

function modifier_medic_revive_rez_sickness_lua:GetModifierAttackSpeedBonus_Constant( params )
	return self.params.as_bonus_percent
end
 
--------------------------------------------------------------------------------

function modifier_medic_revive_rez_sickness_lua:OnCreated( params )
	if not self.params then
		self.params = {}
	end
	for k, v in pairs(params) do
		self.params[k] = v
	end
end
 
--------------------------------------------------------------------------------

function modifier_medic_revive_rez_sickness_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT, 
	}
 
	return funcs
end