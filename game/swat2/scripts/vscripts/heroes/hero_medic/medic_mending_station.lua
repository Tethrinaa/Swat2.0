
-- Author: NSEnigma

function OnSpellStart(keys)
	local caster = keys.caster
	
	-- Create the mender at the target location
	local mender = CreateUnitByName("medic_mending_station", keys.target_points[1], false, caster, caster, caster:GetTeam())
	
	-- Make it owned by and controllable by the medic's player
	mender:SetOwner(caster)
	mender:SetControllableByPlayer(caster:GetPlayerID(), true)
	
	-- Grab the medic's level of mender
	local medic_abil_level = caster:FindAbilityByName("medic_mend_wounds"):GetLevel()

	-- Set the level of mend to be the same, but at least 1
	local mender_abil = mender:FindAbilityByName("mender_mend_wounds")
	mender_abil:SetLevel( medic_abil_level + 1 )
	
	-- Set the level of defense network to be the same as medic's mend wounds
	local defense_network_abil = mender:FindAbilityByName("mender_defense_network")
	defense_network_abil:SetLevel(math.max(medic_abil_level,0))
	
	-- Set the level of plating to half of the mend level
	local plating_abil = mender:FindAbilityByName("mender_contraption_plating")
	plating_abil:SetLevel(math.floor(math.max(medic_abil_level,0)/2))

	-- Increase the cost of the medic_mending_station ability to 500 by increasing the level
	local medic_mending_station_abil = caster:FindAbilityByName("medic_mending_station")
	medic_mending_station_abil:SetLevel(2)
	
	-- Turn on autocast for the mending station
	mender_abil:ToggleAutoCast()

	-- Save this mender as the last mender made by this medic so we can decrease the cost later
	caster.sdata.mender = mender
	
	-- Set a timed life for the mender so it shows a countdown timer and dies
	mender:AddNewModifier(caster, nil, "modifier_kill", {duration=20})
	
	-- 90 seconds later...
	Timers:CreateTimer(90, function()
		-- reduce the cost of medic_mending_station if the medic hasn't cast it again
		if caster.sdata.mender == mender then 
			medic_mending_station_abil:SetLevel(1)
		end
	end)
end