-- Author: NmdSnprEnigma

--- Replicates the upgrade functionality from WC3
function UpdateDroids(keys)
	local ho = keys.caster
	local minidroids = ho.sdata.minidroids
	local ammo_buff_name = "modifier_minidroid_ammo"
	local ammo_ability_name = "minidroid_ammo"
	local new_level = keys.ability:GetLevel()
	
	-- Iterate over each mini
	-- if you don't, then the old buff keeps getting refreshed
    if minidroids then
        for _, minidroid in pairs(minidroids) do
			-- remove the buff so it doesn't get refreshed
            minidroid:RemoveModifierByName(ammo_buff_name)
            
			-- level the ability for each mini when the ho ability is leveled
            local ammo_ability = minidroid:FindAbilityByName(ammo_ability_name)
            ammo_ability:SetLevel(new_level)
            
			-- reapply the buff that we tok off, now that the level is right
            ammo_ability:ApplyDataDrivenModifier(ho, minidroid, ammo_buff_name, {})
        end
    end
end