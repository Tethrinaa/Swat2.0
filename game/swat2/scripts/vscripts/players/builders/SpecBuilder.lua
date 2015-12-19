-- Helper Class for building specs
--

SHOW_SPEC_BUILDER_LOGS = SHOW_PLAYER_BUILDER_LOGS

SpecBuilder = {}
function SpecBuilder:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.methods = {}

    self.methods.weaponry = self.applyWeaponry
    self.methods.power_armor = self.applyPowerArmor
    self.methods.energy_cells = self.applyEnergyCells
    self.methods.cybernetics = self.applyCybernetics
    self.methods.triage = self.applyTriage
    self.methods.chemistry = self.applyChemistry
    self.methods.leadership = self.applyLeadership
    self.methods.robotics = self.applyRobotics
    self.methods.espionage = self.applyEspionage

    return o
end

-- PlayerBuilder will call this method to apply
-- the specName to the playerHero
function SpecBuilder:applySpec(playerHero, specName)
    if SHOW_SPEC_BUILDER_LOGS then
        print("SpecBuilder | Applying Spec: " .. specName)
    end
    self.methods[specName](self, playerHero)
end

-- Weaponry
function SpecBuilder:applyWeaponry(playerHero)
    -- TODO: Implement Weaponry
end

-- PowerArmor
function SpecBuilder:applyPowerArmor(playerHero)
    -- TODO: Implement PowerArmor
end

-- EnergyCells
function SpecBuilder:applyEnergyCells(playerHero)
    -- TODO: Implement EnergyCells
end

-- Cybernetics
function SpecBuilder:applyCybernetics(playerHero)
    -- TODO: Implement Cybernetics
end

-- Triage
function SpecBuilder:applyTriage(playerHero)
    -- TODO: Implement Triage
end

-- Chemistry
function SpecBuilder:applyChemistry(playerHero)
    -- TODO: Implement Chemistry
end

-- Leadership
function SpecBuilder:applyLeadership(playerHero)
    -- TODO: Implement Leadership
end

-- Robotics
function SpecBuilder:applyRobotics(playerHero)
    -- TODO: Implement Robotics
end

-- Espionage
function SpecBuilder:applyEspionage(playerHero)
    -- TODO: Implement Espionage
end

