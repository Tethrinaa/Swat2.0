
--- 
-- This is unused for now because non-hero mana requires the creature to level up
function AdjustManaDown( keys )
	-- Grab the previous level if you can, otherwise, it was 0
	local level = keys.ability:GetLevel()
	local storage = level > 1 and keys.ability:GetLevelSpecialValueFor("storage", level - 1) or 0
	local new_storage = keys.ability:GetSpecialValueFor("storage")
	
	
	-- Bump the energy down so that when the new bonus kicks in, the value stays same instead of the %
	print(level, storage, new_storage)
	AdjustManaDownPre(keys.caster, new_storage - storage)
end
