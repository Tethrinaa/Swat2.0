function AddMCBonus( keys )
	local xp_bonus = keys.experience_rate / 100
	keys.caster.sdata.mc_bonus = xp_bonus
	local player_id = keys.target:GetPlayerOwnerID()
	local playerInfo = PlayerManager:getPlayerInfoForPlayerId(player_id)
	print("Adding XP Rate:", xp_bonus)
	playerInfo.experienceSwiftLearnerModifier = playerInfo.experienceSwiftLearnerModifier + xp_bonus
	print("XP Rate now:", playerInfo.experienceSwiftLearnerModifier)
end

function RemoveMCBonus( keys )
	local xp_bonus = keys.caster.sdata.mc_bonus
	local player_id = keys.target:GetPlayerOwnerID()
	local playerInfo = PlayerManager:getPlayerInfoForPlayerId(player_id)
	print("Removing XP Rate:", xp_bonus)
	playerInfo.experienceSwiftLearnerModifier = playerInfo.experienceSwiftLearnerModifier - xp_bonus
	print("XP Rate now:", playerInfo.experienceSwiftLearnerModifier)
end