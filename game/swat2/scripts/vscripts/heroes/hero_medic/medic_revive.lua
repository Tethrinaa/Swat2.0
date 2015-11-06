LinkLuaModifier( "modifier_medic_revive_rez_sickness_lua", "heroes/hero_medic/modifier_medic_revive_rez_sickness_lua", LUA_MODIFIER_MOTION_NONE )

function FindValidReviveTargets(location, radius)
    -- Grab all friendly units in the area
	local units = Entities:FindAllInSphere(location, radius)
    local corpses = {}
    for k, corpse in ipairs(units) do
		if corpse.GetUnitName then
			if IsCorpse(corpse) and corpse:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
				table.insert(corpses, corpse)
			end
		end
    end
    return corpses
end

function OnAbilityPhaseStart(keys)
    local caster = keys.caster
	local location = caster:GetAbsOrigin()
    local pID = caster:GetPlayerOwnerID()
	targets = FindValidReviveTargets(location, keys.ability:GetSpecialValueFor("radius"))

    -- if no targets are found then
    if #targets < 1 then
		caster:Interrupt()
		-- SendErrorMessage(pID, "#error_no_usable_corpses")
		
		local mana = caster:GetMana()
		Timers:CreateTimer(function() keys.ability:EndCooldown() end)		
		Timers:CreateTimer(function() caster:SetMana(mana) end)
    end
end

function TryRefreshRevive(caster, ability)
    local chance = ability:GetSpecialValueFor("recharge_chance")
    local cost = ability:GetSpecialValueFor("AbilityManaCost")
    
    if math.random(100) < chance then
        Timers:CreateTimer(function() ability:EndCooldown() end)
		Timers:CreateTimer(function() caster:SetMana(caster:GetMana() + (cost/2) ) end)
    end
end

function ApplyPowerArmorDamage(unit)
    -- TODO this needs to not apply to heros with the power armor trait
    if not unit:IsHero() then
        return
    end

    -- Try to grab the passive ability that does this
    local damaged_armor_abil = unit:FindAbilityByName("damaged_power_armor")
    
    -- Add the ability if you need to
    if not damaged_armor_abil then
        damaged_armor_abil = unit:AddAbility("damaged_power_armor")
    end
    
    -- Increase the level by 1 as long as that doesn't bring you over the max
    local damaged_armor_level = damaged_armor_abil:GetLevel()
    if damaged_armor_level < damaged_armor_abil:GetMaxLevel() then
        damaged_armor_abil:SetLevel(damaged_armor_level + 1)
    end
end

function ReviveUnit(corpse, ability, victimized)
    local unit = corpse.killedUnit
	
    -- sdata (SWAT data) doesn't follow a unit through respawn so we have to move it manually
    local sdata = unit.sdata
    	
	-- This was a standard unit that died, we'll have to recreate it from its sdata
	if unit:IsNull() or not unit:UnitCanRespawn() then
		local location = corpse:GetAbsOrigin()
		unit = CreateUnitByName(unit.sdata.unit_name, location, true, corpse, corpse, corpse:GetTeamNumber())
		FindClearSpaceForUnit(unit, location, false)
		unit.sdata = sdata
		if sdata.revive_energy then
			unit:SetMana(sdata.revive_energy)
		end
		corpse:RemoveSelf()
    elseif unit:UnitCanRespawn() then    
		unit:RespawnUnit()
		unit.sdata = sdata
        
        -- Move the unit to where the corpse was
		local location = corpse:GetAbsOrigin()
        FindClearSpaceForUnit(unit, location, false)
        corpse:RemoveSelf()
        
        -- As long as the player was neither a victim or noob, break armor and apply rez sick
        if not victimized then
            local armor_index = 0
            if unit.sdata.armor_index then
				armor_index = unit.sdata.armor_index
			end
        
            -- If this revive needs to apply rez_sickness to the target
            if unit:IsHero() then  
                -- Set the revive energy based on your armor type
                unit:SetMana(ability:GetLevelSpecialValueFor("revive_energy", armor_index))
                
                -- TODO This will need to get factored into the experience system
                local exp_bonus_percent = ability:GetSpecialValueFor("exp_bonus_percent")
                
                -- Apply the rez sickness itself
                local mod_keys = {}
                mod_keys.duration = ability:GetLevelSpecialValueFor("sickness_duration", armor_index)
                mod_keys.ms_bonus_percent = ability:GetLevelSpecialValueFor("ms_bonus_percent", armor_index)
                mod_keys.as_bonus_percent = ability:GetLevelSpecialValueFor("as_bonus_percent", armor_index)
				DeepPrintTable(mod_keys)
                Timers:CreateTimer(1, function() unit:AddNewModifier( ability:GetCaster(), ability, "modifier_medic_revive_rez_sickness_lua", mod_keys ) end)
            end
            
            -- If this revive needs to damage the unit's power armor
            if unit:IsHero() then -- TODO break power armor
                -- ApplyPowerArmorDamage(unit)
            end
        end
    else
		print("Should never have gotten here")
	end
end

function OnSpellStart(keys)
	local caster = keys.caster
	local location = caster:GetAbsOrigin()
	local targets = FindValidReviveTargets(location, keys.ability:GetSpecialValueFor("radius"))
	
    -- heroes get rezzed first
    -- cadets are next if there are any
    -- civs are last so they don't screw things ups
    local heroes = {}
    local cadets = {}
    local civs = {}
    
    for _,corpse in ipairs(targets) do
        -- if IsCadet(corpse.killedUnit) then
        --    table.insert(cadets, corpse.killedUnit)
        --elseif IsHero(corpse.killedUnit) then
		if corpse.killedUnit:IsNull() then
            table.insert(civs, corpse.killedUnit)
        else
            table.insert(heroes, corpse.killedUnit)
        end
    end
    
    for _,lists in ipairs({heroes,cadets,civs}) do
        for _,corpse in ipairs(targets) do
            ReviveUnit(corpse, keys.ability)
			return
        end
    end
    
    TryRefreshRevive(caster, keys.ability)
end