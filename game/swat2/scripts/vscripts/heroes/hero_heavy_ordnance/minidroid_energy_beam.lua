function TransferEnergyKeys( keys )
	ShallowPrintTable( keys )
	TransferEnergy( keys.caster, keys.target, keys.ability:GetSpecialValueFor("energy_transferred") )
end

function TransferEnergy( caster, target, beam_max, reserve )
	print( caster, target, beam_max, reserve )
	local target_energy = reserve and (target:GetMana() - reserve) or target:GetMana()
	local energy_needed = caster:GetMaxMana() - caster:GetMana()
	print(target_energy, beam_max, energy_needed, 0)
	local energy_to_transfer = math.max(math.min(target_energy, beam_max, energy_needed) , 0)
	
	if energy_to_transfer > 0 then
		-- Visual effects go here
		print(energy_to_transfer)
		target:SetMana(target:GetMana() - energy_to_transfer)
		caster:SetMana(caster:GetMana() + energy_to_transfer)
	end
end