-- Manages giving out experience to players

SHOW_EXPERIENCE_LOGS = false -- these really don't need to be firing off unless you're testing it

EXPERIENCE_MANAGER_CYCLE_DELAY = 3 -- seconds between handing out experience
EXPERIENCE_MANAGER_CHUNK = 1999 -- Amount of XP to award at once

ExperienceManager = {}
function ExperienceManager:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.heroExperience = 0 -- amount of experience so far awarded
    self.experienceModifier = 1.0 -- Affects ALL experience coming in (Based on modifier Base and the player count)
    self.experienceModifierBase = 1.0 -- Affects ALL experience coming in (higher difficulties reduce this over time)

    return o
end

function ExperienceManager:onPreGameStarted()
    -- Technically, players can start killing at this point
    self:startExperienceCycle()
end

-- Should be called when the difficulty is set in GameManager
function ExperienceManager:onDifficultySet(difficulty)
    if difficulty == "normal" then
        -- Normal mode
        self.experienceModifierBase = 2.90
    elseif difficulty == "hard" then
        -- Hard mode
        self.experienceModifierBase = 1.50
    elseif difficulty == "insane" then
        -- Insane mode
        self.experienceModifierBase = 0.92
    elseif difficulty == "survival" then
        -- Survival mode
        self.experienceModifierBase = 1.10
    elseif difficulty == "nightmare" then
        -- Nightmare mode  (should be set after another difficulty was set)
        -- TODO
    elseif difficulty == "extinction" then
        -- Extinction mode (should be set after another difficulty was set)
        -- TODO
    else
        -- Unknown? Error! (Shouldn't happen)
        print("EnemyUpgrades | UNKNOWN DIFFICULTY SET!: '" .. difficulty .. "'")
    end

    self:updateExperienceModifier()
end

function ExperienceManager:awardExperience(experience)
    if SHOW_EXPERIENCE_LOGS then
        print("ExperienceManager | Awarded " .. experience .. " experience points | After Modifier = " .. (experience * self.experienceModifier))
    end
    self.heroExperience = self.heroExperience + (experience * self.experienceModifier)
end

function ExperienceManager:updateExperienceModifier()
    local playerCount = g_PlayerManager.playerCount

    if playerCount > 8 then
      self.experienceModifier = 40.0 * self.experienceModifierBase
    elseif playerCount > 7 then
      self.experienceModifier = 40.5 * self.experienceModifierBase
    elseif playerCount > 6 then
      self.experienceModifier = 41.0 * self.experienceModifierBase
    elseif playerCount > 5 then
      self.experienceModifier = 42.0 * self.experienceModifierBase
    elseif playerCount > 4 then
      self.experienceModifier = 43.0 * self.experienceModifierBase
    elseif playerCount > 3 then
      self.experienceModifier = 45.0 * self.experienceModifierBase
    elseif playerCount > 2 then
      self.experienceModifier = 47.0 * self.experienceModifierBase
    elseif playerCount > 1 then
      self.experienceModifier = 49.0 * self.experienceModifierBase
    else
      self.experienceModifier = 50.0 * self.experienceModifierBase
    end

    if SHOW_EXPERIENCE_LOGS then
        print("ExperienceManager | Experience Modifier Set to: " .. self.experienceModifier)
    end
end

function ExperienceManager:startExperienceCycle()
    Timers:CreateTimer(0, function()
        if self.heroExperience > 0 then
            self:divideExperience(self.heroExperience)
        end
        return EXPERIENCE_MANAGER_CYCLE_DELAY
    end)
end

-- Divides the experience to the players
-- Note:
function ExperienceManager:divideExperience(experience)
    -- Subtract the amount we awarded
    self.heroExperience = self.heroExperience - experience
    if SHOW_EXPERIENCE_LOGS then
        print("ExperienceManager | Giving out experience: " .. experience)
    end

    local exp = 0
    local isDone = false
    while not isDone do
        if experience >= EXPERIENCE_MANAGER_CHUNK then
            exp = EXPERIENCE_MANAGER_CHUNK
            experience = experience - EXPERIENCE_MANAGER_CHUNK
        else
            exp = experience
            isDone = true
        end

        for _,playerInfo in pairs(g_PlayerManager.playersInfo) do
            if playerInfo.experienceDisabled == 0 then
                playerInfo.hero:AddExperience(
                    exp * playerInfo.experienceEpicModifier * playerInfo.experienceRezModifier * playerInfo.experienceHurtModifier * playerInfo.experienceHurtModifier * playerInfo.experienceOverdoseModifier * playerInfo.experienceSwiftLearnerModifier
                    , 0
                    , false
                    , false)
            end
        end
    end
end

-- TODO: Add Swift Learner Bonus Experience
