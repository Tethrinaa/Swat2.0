foci_names = { "primary_psychologist_confidence", "primary_psychologist_self_motivation", "primary_psychologist_mental_clarity" }

function ClearFocii( target )
	for psy in pairs(target.sdata.focipsy) do
		ClearFocus(psy)
	end
end

function ClearFocus( caster )
	local focus_target = caster.sdata.focus_target
	local focus_name = caster.sdata.focus_name
	
	if not focus_target then return end
	
	local modifier_names = { "primary_psychologist_confidence_syn", "primary_psychologist_self_motivation_syn","primary_psychologist_mental_clarity_syn"}
	table.insert(modifier_names, focus_name)
	
	local self_suffix = (caster == focus_target) and "_self" or ""
	
	for _, name in pairs(modifier_names) do
		print("Removing:", name..self_suffix )
		focus_target:RemoveModifierByNameAndCaster(name..self_suffix, caster)
	end
	
	focus_target.sdata.focipsy[focus_name] = nil
	caster.sdata.focus_target = nil
	caster.sdata.focus_name = nil
end

function UpgradeFocus( keys )
	local caster = keys.caster
	ApplyFocus( caster, caster.sdata.focus_target, caster.sdata.focus_name )
end

function ApplyBuffAndSynergies( keys )
	ApplyFocus( keys.caster, keys.target, keys.ability:GetName() )
end

function Respecialize( keys )
	local caster = keys.caster
	local ability_points = 0
	
	ClearFocus(caster)
	
	for _, ability_name in pairs(foci_names) do
		print("Looking for ", ability_name)
		local ability = caster:FindAbilityByName(ability_name)
		ability_points = ability_points + ability:GetLevel()
		ability:SetLevel(0)
	end
	
	local int = caster:FindModifierByName("primary_psychologist_mental_clarity_intellect")
	
	if int then
		int:Destroy()
	end
	
	if ability_points < 1 then
		return
	end
	
	
	keys.ability:SetLevel(0)
	
	local wait_time = 2.564 + ability_points/2.2941 
	Timers:CreateTimer(wait_time, function()
		keys.ability:SetLevel(1)
		ability_points = ability_points + caster:GetAbilityPoints()
		caster:SetAbilityPoints(ability_points)
		-- TODO message the player to say mind is cleared
	end)
end

function ApplyFocus( caster, target, focus_name )
	ShallowPrintTable(keys)
	ClearFocus( caster )
	
	if not (caster and target and focus_name) then
		return
	end
	
	if not target.sdata.focipsy then
		target.sdata.focipsy = {}
	end
	
	if target.sdata.focipsy[focus_name] then
		-- a psy is already providing this buff, so fail please
		return
	end
	target.sdata.focipsy[focus_name] = caster
	
	local foci_names = { "primary_psychologist_confidence", "primary_psychologist_self_motivation", "primary_psychologist_mental_clarity" }
	print("focus_name", focus_name)
	local self_suffix = (caster == target) and "_self" or ""
	
	for _, name in pairs(foci_names) do
		local ability = caster:FindAbilityByName(name)
		print("Checking:", focus_name, name )
		if ability:GetLevel() > 0 then
			local modifier_name = (focus_name == name) and name or name.."_syn"
			modifier_name = modifier_name..self_suffix
			print("Adding:", modifier_name )
			ability:ApplyDataDrivenModifier(caster, target, modifier_name, {})
		end
	end
		
	caster.sdata.focus_target = target
	caster.sdata.focus_name = focus_name
end

