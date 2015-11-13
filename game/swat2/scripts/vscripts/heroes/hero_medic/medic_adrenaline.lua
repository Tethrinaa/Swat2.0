LinkLuaModifier( "modifier_medic_revive_rez_sickness_lua", "heroes/hero_medic/modifier_medic_revive_rez_sickness_lua", LUA_MODIFIER_MOTION_NONE )

function OnAbilityPhaseStart(keys)
	ValidateAbilityTarget(keys.ability, keys.target, IsOrganic, "#error_inorganic_target")
end

function RushThink( keys )
	-- TODO implement rushing correctly here
	keys.target:RemoveModifierByName("modifier_rush_thinker")
	if true then return end

	print("RushThink")
	for k, v in pairs(keys) do
		print(k, v)
	end
	
	local adren_buff = keys.target:FindModifierByName("modifier_adrenaline")
	
	if not adren_buff then
		keys.target:RemoveModifierByName("modifier_rush_thinker")
		return
	end
	for k, v in pairs(adren_buff) do
		print(k, v)
	end
	--if g_EnemySpawner.minionsKilled - adren_buff.prev_killed > adren_buff.kills_needed then
	adren_buff.prev_killed = g_EnemySpawner.minionsKilled
	if true then
		print("Setting new duration adn clearing thinker")
		adren_buff:SetDuration(keys.ability:GetSpecialValueFor("rush_duration"), true)
		keys.target:RemoveModifierByName("modifier_rush_thinker")
		return
	end
	
	
	
	
	--self.lastEnemiesKilled = g_EnemySpawner.minionsKilled
end

function OnSpellStart(keys)
	local caster = keys.caster
	local junkie_abil = caster:FindAbilityByName("primary_medic_adrenaline_junkie")
	local junkie_level = junkie_abil:GetLevel()
	
	-- If you're adrening someone else but you have junkie
	if keys.caster ~= keys.target and junkie_level > 0 then
		-- ... then check the chance to junkie from the ability
		if math.random(0, 99) < junkie_abil:GetSpecialValueFor("junkie_chance") then
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_adrenaline", {duration = keys.ability:GetSpecialValueFor("rush_duration")} )
			keys.ability:ApplyDataDrivenModifier(caster, caster, "modifier_rush_waiter", {duration = keys.ability:GetSpecialValueFor("rush_duration")} )
		end
	end
end