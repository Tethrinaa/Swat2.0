-- Author: NSEnigma
LinkLuaModifier( "modifier_cyborg_forcefield_lua", "heroes/hero_cyborg/modifier_cyborg_forcefield_lua", LUA_MODIFIER_MOTION_NONE )

function SwapInDeactivate(keys)
	local caster = keys.ability:GetCaster()
	
	-- Swap sub_ability
	local sub_ability_name = "cyborg_forcefield_off"
	local main_ability_name = "cyborg_forcefield"

	caster:SwapAbilities( main_ability_name, sub_ability_name, false, true )
end

function SwapOutDeactivate(keys)
	local caster = keys.ability:GetCaster()
	
	-- Swap sub_ability
	local main_ability_name = "cyborg_forcefield"
	local sub_ability_name = "cyborg_forcefield_off"

	caster:SwapAbilities( main_ability_name, sub_ability_name, true, false )
end


-- This is the tick which decrements the energy and periodically increases the penalty
function ForcefieldThink(keys)
	local caster = keys.caster
	local buff = caster.sdata.ff_buff
	
	-- stop forcefield if the borg doesn't have enough for the next tick
	if caster:GetMana() < buff.drain then
		buff:Destroy()
	end
	
	-- decrease energy
	local mana = caster:GetMana() - buff.drain
	caster:SetMana(mana)

	-- increase drain
	buff.drain = buff.drain + caster.sdata.forcefield*(1 + math.floor(buff.ticks/8))
	
	-- incrase the penalty
	-- TODO - inclusion of nightmare to per actication penalty
	if buff.ticks % (5) == 0 then -- + math.min(nightmare_upgrade,3) )
		buff.penalty = buff.penalty + .01
	end
	buff.ticks = buff.ticks + 1
end

--------------------------------------------------------------------------------

function ForcefieldCreate(keys)
	local caster = keys.caster
	local buff = caster:FindModifierByName("modifier_cyborg_forcefield")
	
	-- TODO this may be resetting the efficiency when a borg dies - need to debug but hard in a solo
	if not caster.sdata.forcefield then
		caster.sdata.forcefield = .42
	end
	print("Forcefield efficiency",caster.sdata.forcefield)
	
	-- save this persistently so we can find it onDestroy or if the borg dies with FF on
	caster.sdata.ff_buff = buff
	
	-- initialize the drain
	buff.drain = caster.sdata.forcefield * 50.0 - 7.0
	buff.penalty = 0
	
	-- add the penalty just for activating it
	-- TODO - inclusion of nightmare to per activation penalty
	caster.sdata.forcefield = caster.sdata.forcefield + .08 -- ( - .01 * math.min(nightmare_upgrade,3)
	buff.ticks = 1
end

--------------------------------------------------------------------------------

function ForcefieldDestroy(keys)
	local caster = keys.caster
	local buff = caster.sdata.ff_buff
	
	-- increase the persistent penalty
	caster.sdata.forcefield = caster.sdata.forcefield + buff.penalty
end

