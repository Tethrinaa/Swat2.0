LinkLuaModifier( "modifier_medic_revive_rez_sickness_lua", "heroes/hero_medic/modifier_medic_revive_rez_sickness_lua", LUA_MODIFIER_MOTION_NONE )

function RushThink( keys )
	print("RushThink")
	for k, v in pairs(keys) do
		print(k, v)
	end
	
	for k, v in pairs(self) do
		print(k, v)
	end
	
	self.lastEnemiesKilled = g_EnemySpawner.minionsKilled
end

function OnSpellStart(keys)
	local caster = keys.caster
	local junkieLevel = caster:FindAbilityByName("medic_junkie"):GetLevel()
	
	-- If you're adrening someone else but you have junkie
	if keys.caster != keys.target and junkieLevel > 0 then
		if math.random(0, 99) < (60 + 5 * junkieLevel) then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_adrenaline", {duration = keys.ability:GetSpecialValueFor("rush_duration")} )
		end
	end
end