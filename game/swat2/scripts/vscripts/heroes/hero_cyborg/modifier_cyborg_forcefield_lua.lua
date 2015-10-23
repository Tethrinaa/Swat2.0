-- Author: NSEnigma

modifier_cyborg_forcefield_lua = class({})

--------------------------------------------------------------------------------

-- This is the tick which decrements the energy and periodically increases the penalty
function modifier_cyborg_forcefield_lua:OnIntervalThink()
	local caster = self:GetCaster()
	if caster:GetMana() < self.drain then
		self:Destroy()
	end
	
	-- decrease energy
	local mana = caster:GetMana() - self.drain
	caster:SetMana(mana)

	-- increase drain
	self.drain = self.drain + caster.forcefield*(1 + math.floor(self.ticks/8))
	
	-- incrase the penalty
	-- TODO - inclusion of nightmare to per actication penalty
	if self.ticks % (5) == 0 then -- + math.min(nightmare_upgrade,3) )
		self.penalty = self.penalty + .01
	end
	self.ticks = self.ticks + 1
end

--------------------------------------------------------------------------------

function modifier_cyborg_forcefield_lua:OnCreated(params)
	local caster = self:GetCaster()
	if not caster.forcefield then
		caster.forcefield = .42
	end
	
	-- initialize the drain
	self.drain = caster.forcefield * 50.0 - 7.0
	self.penalty = 0
	
	-- add the penalty just for activating it
	-- TODO - inclusion of nightmare to per activation penalty
	caster.forcefield = caster.forcefield + .08 -- ( - .01 * math.min(nightmare_upgrade,3)
	self.ticks = 1
	
	-- start the ticking on the buff
	if IsServer() then
		self:StartIntervalThink( 1 )
	end
end

--------------------------------------------------------------------------------

function modifier_cyborg_forcefield_lua:OnDestroy()
	local caster = self:GetCaster()
	
	-- increase the persistent penalty
	caster.forcefield = caster.forcefield + self.penalty
	
	-- Swap sub_ability
	local main_ability_name = self:GetAbility():GetAbilityName()
	local sub_ability_name = "cyborg_forcefield_off_lua_ability"

	caster:SwapAbilities( main_ability_name, sub_ability_name, true, false )
end

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
