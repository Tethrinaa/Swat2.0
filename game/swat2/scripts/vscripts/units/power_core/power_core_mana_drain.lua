--[[Author: Pizzalol
	Date: 18.01.2015.
	Kills illusions, if its not an illusion then it moves the caster direction,
	checks the leash distance and drains mana from the target]]
function mana_drain( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	-- If its an illusion then kill it
	if target:IsIllusion() then
		target:ForceKill(true)
	else
		-- Location variables
		local caster_location = caster:GetAbsOrigin()
		local target_location = target:GetAbsOrigin()

		-- Distance variables
		local distance = (target_location - caster_location):Length2D()
		local break_distance = ability:GetLevelSpecialValueFor("break_distance", (ability:GetLevel() - 1))
		local direction = (target_location - caster_location):Normalized()

		-- If the leash is broken then stop the channel
		if distance >= break_distance then
			ability:OnChannelFinish(false)
			caster:Stop()
			return
		end

		-- Make sure that the caster always faces the target
		caster:SetForwardVector(direction)

		-- Mana calculation
		local mana_per_second = ability:GetLevelSpecialValueFor("mana_per_second", (ability:GetLevel() - 1))
		local tick_interval = ability:GetLevelSpecialValueFor("tick_interval", (ability:GetLevel() - 1))
		local mana_drain = mana_per_second / (1/tick_interval)

		local target_mana = target:GetMana()

		-- Mana drain part
		-- If the target has enough mana then drain the maximum amount
		-- otherwise drain whatever is left
		if target_mana >= mana_drain then
			target:ReduceMana(mana_drain)
			caster:GiveMana(mana_drain)
         if caster:GetMana() >= caster:GetMaxMana()-10 then
            ability:OnChannelFinish(false)
            caster:Stop()
            return
         end
		else
			target:ReduceMana(target_mana)
			caster:GiveMana(target_mana)
         ability:OnChannelFinish(true)
         caster:Stop()
         return
		end
	end
end

--[[
	Handles the AutoCast Logic
	Auto-Cast can interrupt current orders and forget the next queued command. Following queued commands are not forgotten
	Cannot occur while channeling a spell.
]]
function auto_cast( event )
	local caster = event.caster
	--local target = event.target
	local ability = event.ability
   -- pick up x nearest target heroes and create tracking projectile targeting the number of targets
	local targets = FindUnitsInRadius(
		caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, ability:GetCastRange(), ability:GetAbilityTargetTeam(),
      ability:GetAbilityTargetType(), ability:GetAbilityTargetFlags(), FIND_CLOSEST, false
	)
	-- Get if the ability is on autocast mode and cast the ability on the attacked target if it doesn't have the modifier
   if #targets > 0 then
      if not IsChanneling( caster ) then
         for k, v in pairs( targets ) do
            caster:CastAbilityOnTarget(v, ability, caster:GetPlayerOwnerID())
            break
         end
      end
	end
end
-- Auxiliar function that goes through every ability and item, checking for any ability being channelled
function IsChanneling ( unit )

	for abilitySlot=0,15 do
		local ability = unit:GetAbilityByIndex(abilitySlot)
		if ability ~= nil and ability:IsChanneling() then
			return true
		end
	end

	for itemSlot=0,5 do
		local item = unit:GetItemInSlot(itemSlot)
		if item ~= nil and item:IsChanneling() then
			return true
		end
	end

	return false
end

function PowerCheck( keys )
   local caster = keys.caster
   local ability = keys.ability
   if caster:GetMana() >= 2990 then
      caster.StatusManaRegen = "25"

      g_PowerManager:onPowerPlantFilled(caster, ability)

      caster:RemoveAbility(ability:GetAbilityName())
      caster:RemoveModifierByName("modifier_mana_drain_autocast")
      caster:RemoveModifierByName("modifier_swat_ability_power_core_degen")
   end
end

--[[Author: Pizzalol
	Date: 18.01.2015.
	Stops the sound from looping]]
function mana_drain_stop_sound( keys )
	local target = keys.target
	local sound = keys.sound

	StopSoundEvent(sound, target)
   PowerCheck( keys )
end
