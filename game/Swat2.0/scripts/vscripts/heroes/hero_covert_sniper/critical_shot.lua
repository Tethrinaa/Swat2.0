--[[Critical Shot
	Author: Dokuno
	Date: 19.09.2015.]]
   
-- Function supports Critical Shot for the crit chance and damage changes
-- If Aim is being used, remove the regular crit mod and apply the aim crit mod instead.
function aimCheck( params )
   local caster = params.caster
   local ability = params.ability
   if (caster:FindModifierByName("modifier_aim") == nil) then
      return 0
   else
      --Remove modifier_crit
      caster:RemoveModifierByName("modifier_crit")
      --Add modifier_aim_crit
      ability:ApplyDataDrivenModifier(caster, caster, "modifier_aim_crit", nil)  
   end
end
