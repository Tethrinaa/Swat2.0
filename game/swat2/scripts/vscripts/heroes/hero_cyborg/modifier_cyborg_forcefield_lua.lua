-- Author: NSEnigma

modifier_cyborg_forcefield_lua = class({})

--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
 
function modifier_cyborg_forcefield_lua:IsDebuff()
	return false
end
 
--------------------------------------------------------------------------------
 
function modifier_cyborg_forcefield_lua:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end
 
--------------------------------------------------------------------------------
 
function modifier_cyborg_forcefield_lua:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_cyborg_forcefield_lua:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_cyborg_forcefield_lua:GetAbsoluteNoDamageMagical()
	return 1
end
function modifier_cyborg_forcefield_lua:GetAbsoluteNoDamagePure()
	return 1
end 
--------------------------------------------------------------------------------
 
function modifier_cyborg_forcefield_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_MAGICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PURE
	}
 
	return funcs
end
