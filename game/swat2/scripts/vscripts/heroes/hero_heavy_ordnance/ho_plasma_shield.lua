--- Returns true only for innards.
-- @param unit The unit to check
-- @return true if the unit is an innard, false otherwise.
function ValidPlasmaShieldTarget(unit)
    return string.find(unit:GetUnitName(), "innard")
end

function BurnInnards(keys)
	local caster = keys.caster
	
	-- find the units in the phero radius
	local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, caster:GetAbsOrigin(), nil, keys.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,unit in ipairs(units) do
		-- if they are valid targets
		if unit ~= nil and ValidPlasmaShieldTarget(unit) then
			-- Deal the immolation damage
			print("burning "..unit:GetUnitName())
			local damage_table = {
				victim = unit,
				attacker = keys.caster,
				damage = keys.ability:GetAbilityDamage(),
				damage_type = keys.ability:GetAbilityDamageType(),
				ability = keys.ability
			}
			ShallowPrintTable(damage_table)
			ApplyDamage( damage_table )
		end
	end
end