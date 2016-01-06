--- Remove the buff from all the HO's minis.
function RemoveModifierFromMinis( keys )
	local ho = keys.caster
	local minis = ho.sdata.minidroids
	if minis then
		for _, mini in pairs(minis) do
			mini:RemoveModifierByName( keys.ModifierName )
		end
	end
end


--- Add the buff to all the HO's minis within the radius.
function ApplyModifierToMinis( keys )
	local ho = keys.caster
	local minis = ho.sdata.minidroids
	if minis then
		for _, mini in pairs(minis) do
			if (ho:GetAbsOrigin() - mini:GetAbsOrigin()):Length() < keys.Radius then
				keys.ability:ApplyDataDrivenModifier( ho, mini, keys.ModifierName, {} )
			end
		end
	end
end