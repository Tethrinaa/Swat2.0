-- Class that handles the city power objective

SHOW_POWER_MANAGER_LOGS = SHOW_GAME_SYSTEM_LOGS

PowerManager = {}

PowerManager.POWER_PLANTS_FOR_CITY = 3

function PowerManager:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.powerPlantsFilled = 0
    self.powerPlantsNeeded = 0
    self.powerRestored = false

    return o
end

-- Should be called when the difficulty is set in GameManager
function PowerManager:onDifficultySet(difficulty)
    if difficulty == "normal" then
        -- Normal mode
        self.powerPlantsNeeded = 2
        self:spawnPower(3,2,1,false)
    elseif difficulty == "hard" then
        -- Hard mode
        self.powerPlantsNeeded = 3
        self:spawnPower(2,3,1,false)
    elseif difficulty == "insane" then
        -- Insane mode
        self.powerPlantsNeeded = 3
        self:spawnPower(1,3,2,true)
    elseif difficulty == "survival" then
        -- Survival mode
        -- Doesn't spawn tors
        self:onPowerRestored()
    elseif difficulty == "nightmare" then
        -- Nightmare mode  (should be set after another difficulty was set)
        -- TODO
        self.powerPlantsNeeded = 6
    elseif difficulty == "extinction" then
        -- Extinction mode (should be set after another difficulty was set)
        -- TODO
        self.powerPlantsNeeded = 6
    else
        -- Unknown? Error! (Shouldn't happen)
        print("PowerManager | UNKNOWN DIFFICULTY SET!: '" .. difficulty .. "'")
    end
end

function PowerManager:spawnPower(damagedCount, badlyCount, severeCount, hasHidden)
    if SHOW_POWER_MANAGER_LOGS then
        print("PowerManager | Creating power plants")
    end
    local powerPlantRooms = Locations.power_plants

    for i = 1,6 do
        -- Spawn a power plant
        local room = powerPlantRooms[i]
        local powerCore = CreateUnitByName("npc_power_core_damaged", room:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
        local degenAbility = nil
        if damagedCount > 0 then
            if SHOW_POWER_MANAGER_LOGS then
                print("PowerManager |     Damaged")
            end
            damagedCount = damagedCount - 1
            degenAbility = "swat_ability_power_core_damaged"
        elseif badlyCount > 0 then
            if SHOW_POWER_MANAGER_LOGS then
                print("PowerManager |     Badly")
            end
            badlyCount = badlyCount - 1
            degenAbility = "swat_ability_power_core_badly_damaged"
        elseif severeCount > 0 then
            if SHOW_POWER_MANAGER_LOGS then
                print("PowerManager |     Severe")
            end
            severeCount = severeCount - 1
            degenAbility = "swat_ability_power_core_severly_damaged"
        else
            print("PowerManager | Not enough tor counts??")
        end
        powerCore:AddAbility(degenAbility)
        powerCore:FindAbilityByName(degenAbility):SetLevel(1)
        powerCore:SetMana(0)

        if hasHidden and (i % 2 == 0) then
            -- TODO: Hide this tor
        else
            -- TODO: Reveal this tor
        end
    end

end

function PowerManager:onPowerPlantFilled(powerPlant, ability)
    self.powerPlantsFilled = self.powerPlantsFilled + 1
    if SHOW_POWER_MANAGER_LOGS then
        print("PowerManager | Power Plant Filled! (" .. self.powerPlantsFilled .. "/" .. self.powerPlantsNeeded ..")")
    end
    self:updatePowerDisplay()

    if (not self.powerRestored) and self.powerPlantsFilled >= self.powerPlantsNeeded then
        self:onPowerRestored()
    end
end

function PowerManager:onPowerRestored()
    if SHOW_POWER_MANAGER_LOGS then
        print("PowerManager | Power Restored!")
    end
    -- TODO
end

function PowerManager:updatePowerDisplay()
    CustomGameEventManager:Send_ServerToAllClients("display_pow", {powcount = self.powerPlantsFilled ,powneeded = self.powerPlantsNeeded})
end
