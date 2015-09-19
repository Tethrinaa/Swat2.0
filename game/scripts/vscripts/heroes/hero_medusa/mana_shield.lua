
function ManaShield( event )
	local caster = event.caster
	local ability = event.ability
	local damage_per_mana = 1 / ability:GetLevelSpecialValueFor("efficiency", ability:GetLevel() - 1 )
	local absorption_percent = ability:GetLevelSpecialValueFor("absorption_tooltip", ability:GetLevel() - 1 ) * 0.01
	local damage = event.Damage
	local health = caster:GetHealth()
	local armor = caster:GetPhysicalArmorValue()
	local armor_percent = 1 - (100 / (100 + 6 * armor))
	local caster_mana = caster:GetMana()
	-- This ones tricky
	-- First term:  (damage / damage_per_mana) converts damage dealt to mana
	-- Second term: (1 / (1 - absorption_percent/100)) undoes the damage reduction given by the modifier in the datadriven, this prevents the hero from being DEAD before we 'undo' the damage
	-- Third term: (1 / (1 - armor_percent/100)) undoes the damage reduction from armor, since we remove mana first
	local mana_needed = (damage / damage_per_mana) * (1 / (1 - absorption_percent)) * (1 / (1 - armor_percent)) * absorption_percent

	-- We're ignoring armor absorption, need to do that later

	-- If it doesnt then do the HP calculation
	if health >= 1 then
		print("Damage taken "..damage.." | Mana needed: "..mana_needed.." | Current Mana: "..caster_mana.." | absorption %" ..absorption_percent.." | armor_percent "..armor_percent)

		-- If the caster has enough mana, remove the necessary mana
		if mana_needed <= caster_mana then
			caster:SpendMana(mana_needed, ability)

			-- No longer need to change health, since the modifier with damage reduction makes health already correct
			-- caster:SetHealth(oldHealth)
			
			-- Impact particle based on damage absorbed
			local particleName = "particles/units/heroes/hero_medusa/medusa_mana_shield_impact.vpcf"
			local particle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
			ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(particle, 1, Vector(mana_needed,0,0))
		else
			-- User doesn't have enough mana, remove all of their mana and damage them appropriately
			caster:SpendMana(caster_mana, ability)
			local hp_to_remove = (mana_needed - caster_mana) * damage_per_mana * (1 - armor_percent)
         print("hp to remove:" ..hp_to_remove,mana_needed,caster_mana,damage_per_mana,armor_percent)
			if hp_to_remove < health then
				local newHealth = health - hp_to_remove
				caster:SetHealth(newHealth)
			else
				caster:ForceKill(false)
			end
		end
	end	
end