LinkLuaModifier( "modifier_medic_revive_rez_sickness_lua", "heroes/hero_medic/modifier_medic_revive_rez_sickness_lua", LUA_MODIFIER_MOTION_NONE )


--- Interrupt the revive if there are no valid targets nearby
function OnAbilityPhaseStart(keys)
    local caster = keys.caster
	local location = caster:GetAbsOrigin()
    local pID = caster:GetPlayerOwnerID()
	
	-- grab all the eligible nearby revive targets
	targets = FindValidReviveTargets(location, keys.ability:GetSpecialValueFor("radius"), caster:GetTeamNumber())

    -- if no targets are found then
    if #targets < 1 then
		-- stop the cast
		caster:Interrupt()
		
		-- send an error the console
		SendErrorMessage(pID, "#error_no_usable_corpses")
		
		-- reset the cooldown and energy
		local mana = caster:GetMana()
		Timers:CreateTimer(function() keys.ability:EndCooldown() end)		
		Timers:CreateTimer(function() caster:SetMana(mana) end)
    end
end

--- Refresh the cooldown and refund half energy somtimes
-- @param caster The unit to refund the energy to
-- @param ability The ability to determine the chance
function TryRefreshRevive(caster, ability)
    local chance = ability:GetSpecialValueFor("recharge_chance")
    local cost = ability:GetSpecialValueFor("AbilityManaCost")
    
	-- if you roll under the chance
    if math.random(0,99) < chance then
	
		-- reset the cooldown and refund half the energy
        Timers:CreateTimer(function() ability:EndCooldown() end)
		Timers:CreateTimer(function() caster:SetMana(caster:GetMana() + (cost/2) ) end)
    end
end

function OnSpellStart(keys)
	local caster = keys.caster
	local location = caster:GetAbsOrigin()
	
	-- Grab the valid revive targets
	local targets = FindValidReviveTargets(location, keys.ability:GetSpecialValueFor("radius"), caster:GetTeamNumber())
	
    -- heroes get rezzed first
    -- cadets are next if there are any
    -- civs are last so they don't screw things ups
    local heroes = {}
    local cadets = {}
    local civs = {}
    
	-- sort all the units into different lists so we only need to run through it
	-- twice instead of three times
    for _,corpse in ipairs(targets) do
        -- TODO account for cadets
		if corpse.killedUnit:IsNull() then
            table.insert(civs, corpse.killedUnit)
        else
            table.insert(heroes, corpse.killedUnit)
        end
    end
    
	-- run through each list in order (if they have any) and revive the first one you find
    for _,lists in ipairs({heroes,cadets,civs}) do
        for _,corpse in ipairs(targets) do
            ReviveUnit(corpse, keys.ability)
			return
        end
    end
    
	-- roll the chance to reset the revive cooldown and refund half the energy
    TryRefreshRevive(caster, keys.ability)
end