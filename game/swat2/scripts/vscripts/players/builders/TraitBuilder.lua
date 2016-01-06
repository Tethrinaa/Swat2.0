-- Helper Class for building traits
--
SHOW_TRAIT_BUILDER_LOGS = SHOW_PLAYER_BUILDER_LOGS

TraitBuilder = {}
function TraitBuilder:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.methods = {}

    self.methods.skilled = self.applySkilled
    self.methods.gifted = self.applyGifted
    self.methods.survivalist = self.applySurvivalist
    self.methods.dragoon = self.applyDragoon
    self.methods.acrobat = self.applyAcrobat
    self.methods.swift_learner = self.applySwiftLearner
    self.methods.healer = self.applyHealer
    self.methods.flower_child = self.applyFlowerChild
    self.methods.chem_reliant = self.applyChemReliant
    self.methods.rad_resistant = self.applyRadResistant
    self.methods.gadgeteer = self.applyGadgeteer
    self.methods.prowler = self.applyProwler
    self.methods.energizer = self.applyEnergizer
    self.methods.pack_rat = self.applyPackRat
    self.methods.engineer = self.applyEngineer
    self.methods.reckless = self.applyReckless

    return o
end

-- PlayerBuilder will call this method to apply
-- the traitName to the playerHero
function TraitBuilder:applyTrait(playerHero, traitName)
    if SHOW_TRAIT_BUILDER_LOGS then
        print("TraitBuilder | Applying Trait: " .. traitName)
    end
    self.methods[traitName](self, playerHero)
end

-- Sets weapon, nanites, and all 3 primary skills to 1 level more than normal
-- TODO: Special setting for heavy ordinance and watchman
function TraitBuilder:applySkilled(playerHero)
    -- Add the dummy ability
    playerHero:AddAbility("trait_skilled")
    playerHero:FindAbilityByName("trait_skilled"):SetLevel(1)

    -- There isn't a good way to get ability count (GetAbilityCount() returns 16). Just loop through until we run out of abilities
    for i = 0,20 do
        local ability = playerHero:GetAbilityByIndex(i)
        if ability then
            local abilityName = ability:GetAbilityName()
            local abilityLevel = ability:GetLevel()

            if abilityLevel < ability:GetMaxLevel() then
                if string.find(abilityName, "weapon_")
                    or string.find(abilityName, "primary_")
                    or string.find(abilityName, "nanites_")
                    then
                    ability:SetLevel(abilityLevel + 1)
                end
            end
        else
            break
        end
    end
end

-- Gifted
function TraitBuilder:applyGifted(playerHero)
    -- TODO: Implement Gifted
	playerHero:AddAbility("trait_gifted")
    playerHero:FindAbilityByName("trait_gifted"):SetLevel(1)
	
end

-- Survivalist
function TraitBuilder:applySurvivalist(playerHero)
    -- TODO: Implement Survivalist
end

-- Dragoon
function TraitBuilder:applyDragoon(playerHero)
    -- TODO: Implement Dragoon
end

-- Acrobat
function TraitBuilder:applyAcrobat(playerHero)
    -- TODO: Implement Acrobat
end

-- SwiftLeaner
function TraitBuilder:applySwiftLeaner(playerHero)
    -- TODO: Implement SwiftLeaner
end

-- Healer
function TraitBuilder:applyHealer(playerHero)
    -- TODO: Implement Healer
end

-- FlowerChild
function TraitBuilder:applyFlowerChild(playerHero)
    -- TODO: Implement FlowerChild
end

-- ChemReliant
function TraitBuilder:applyChemReliant(playerHero)
    -- TODO: Implement ChemReliant
end

-- RadResistant
function TraitBuilder:applyRadResistant(playerHero)
    -- TODO: Implement RadResistant
end

-- Gadgeteer
function TraitBuilder:applyGadgeteer(playerHero)
    -- TODO: Implement Gadgeteer
end

-- Prowler
function TraitBuilder:applyProwler(playerHero)
    -- TODO: Implement Prowler
end

-- Energizer
function TraitBuilder:applyEnergizer(playerHero)
    -- TODO: Implement Energizer
	playerHero:AddAbility("trait_energizer")
    playerHero:FindAbilityByName("trait_energizer"):SetLevel(1)
	
end

-- PackRat
function TraitBuilder:applyPackRat(playerHero)
    -- TODO: Implement PackRat
end

-- Engineer
function TraitBuilder:applyEngineer(playerHero)
    -- TODO: Implement Engineer
end

-- Reckless
function TraitBuilder:applyReckless(playerHero)
    -- TODO: Implement Reckless
end
