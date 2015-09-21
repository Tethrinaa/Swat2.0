--[[Sneak
	Author: Dokuno
	Date: 15.09.2015.]]
   
-- When sneak is toggled on start the fade_delay modifier
-- When sneak is toggled off remove all of the modifiers
function toggleSneak( keys )
   local caster = keys.caster
   local ability = keys.ability
   local toggle = ability:GetToggleState()
   print("Toggle State: ", toggle)
   if ( toggle == "MODIFIER_STATE_VALUE_ENABLED" )
      caster:AddNewModifier(caster, ability, "modifier_covert_sniper_revealed_datadriven")
      caster:AddNewModifier(caster, ability, "modifier_sneak_watcher")   
   else
      caster:RemoveModifierByName("modifier_covert_sniper_revealed_datadriven")
      caster:RemoveModifierByName("modifier_covert_sniper_fade_datadriven")
      caster:RemoveModifierByName("modifier_covert_sniper_invis_datadriven")
      caster:RemoveModifierByName("modifier_sneak_watcher")
   end
end

-- When and action is made with sneak toggled on reset to the fade_delay modifier
function actionMade( keys )
   local caster = keys.caster
   local ability = keys.ability
   local toggle = ability:GetToggleState()
   print("Toggle State: ", toggle)
   if ( toggle == "MODIFIER_STATE_VALUE_ENABLED" )
      caster:AddNewModifier(caster, ability, "modifier_covert_sniper_revealed_datadriven")
      caster:RemoveModifierByName("modifier_covert_sniper_fade_datadriven")
      caster:RemoveModifierByName("modifier_covert_sniper_invis_datadriven")
   end
end

