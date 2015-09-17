--[[Concussion Grenade
	Author: Dokuno
	Date: 16.09.2015.]]
   
-- Concussion Grenade percent attackspeed slow effct
-- Dota 2 only has modifier properties for integer
-- Get the attack speed of a target, calculate the integer attackspeed slow to mimic the %
-- Apply stacks of the slow modifier equal to the constant attackspeed slow needed.
function slowAttackSpeed( params )
   local has_mod = params.target:FindModifierByName("modifier_concussion_grenade_attackspeed_slow_stack")
   local base_attackspeed = params.target:GetAttackSpeed()
   local slow_percent = params.ability:GetLevelSpecialValueFor("attack_slow", (params.ability:GetLevel() - 1))
   local attack_slow = base_attackspeed * (slow_percent/100.0)
   
   if has_mod == nil then
      params.ability:ApplyDataDrivenModifier(caster, target, "modifier_concussion_grenade_attackspeed_slow_stack", nil)
   end   
   params.target:FindModifierByName("modifier_concussion_grenade_attackspeed_slow_stack"):SetStackCount(attack_slow)
end



