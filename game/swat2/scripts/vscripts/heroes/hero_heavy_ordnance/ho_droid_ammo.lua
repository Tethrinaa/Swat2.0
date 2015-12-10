function UpdateDroids(keys)
	local ho = keys.caster
	local minidroids = ho.sdata.minidroids
	local ammo_buff_name = "modifier_minidroid_ammo"
	local ammo_ability_name = "primary_minidroid_ammo"
	local new_level = keys.ability:GetLevel()
	

    if minidroids then
        for _, minidroid in pairs(minidroids) do
            print("Removing "..ammo_buff_name.." buff")
            minidroid:RemoveModifierByName(ammo_buff_name)
            
            print("Updating "..ammo_ability_name.." level")
            local ammo_ability = minidroid:FindAbilityByName(ammo_ability_name)
            ammo_ability:SetLevel(new_level)
            
            print("Reapplying "..ammo_buff_name.." buff") -- TODO not sure if needed, testing without first
            ammo_ability:ApplyDataDrivenModifier(ho, minidroid, ammo_buff_name, {})
        end
    end
end