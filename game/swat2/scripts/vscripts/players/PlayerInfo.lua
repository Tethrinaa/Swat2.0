-- Basic data class containing information related to a specific player and their hero

-- This stores a ton of information about the player and their hero is used by a wide variety of systems (generally Player systems)

PlayerInfo = {}
function PlayerInfo:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.playerId = -1 -- Player ID as assigned by Dota2
    self.playerIndex = -1  -- Player index. First player slot = 1, second player slot = 2.
    self.hero = nil -- The player's hero
	self.playerName = "<Unknown>"

    -- Hero customization options
    -- Customization names
    self.className = nil -- The hero's class's name
    self.weaponName = nil -- The hero's weapon name
    self.armorName = nil -- The hero's armor name
    self.traitName = nil -- The hero's trait name
    self.specName = nil -- The hero's spec name
    self.talentName = nil -- The hero's talent name
    -- TODO Set values if we even want to
    self.classValue = nil -- The hero's class's value
    self.weaponValue = nil -- The hero's weapon value
    self.armorValue = nil -- The hero's armor value
    self.traitValue = nil -- The hero's trait value
    self.specValue = nil -- The hero's spec value
    self.talentValue = nil -- The hero's talent value

    -- Player stats
    self.deathCount = 0.0 -- The number of times the hero has died

    -- Experience values
    -- These modifiers will be multiplied against all earned XP. 1.0 means it has no affect on earned XP
    self.experienceEpicModifier = 1.0 -- This will be reduced when the player reaches epic levels
    self.experienceRezModifier = 1.0 -- This will be reduced when the player dies (is higher based on how many times player has died)
    self.experienceHurtModifier = 1.0 -- This will be reduced when the player suffers certain injuries
    self.experienceHurtModifier = 1.0 -- This will be reduced when the player suffers certain injuries
    self.experienceOverdoseModifier = 1.0 -- This will be reduced when the player is overdosing on drugs (Winners don't do that)
    self.experienceSwiftLearnerModifier = 1.0 -- This will be *increased* if the player loads the swift learner trait
    self.experienceDisabled = 0 -- If greater than 1, no experience is earned (allows compounding sources to increment / decrement this value)

    return o
end


