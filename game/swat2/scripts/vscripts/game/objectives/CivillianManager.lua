-- Class that handles the civillians objective

SHOW_CIVILLIAN_MANAGER_LOGS = SHOW_GAME_SYSTEM_LOGS

CivillianManager = {}

-- CONSTANTS
CivillianManager.BLUE_ZOMBIE_MOVE_SPEED = 190
CivillianManager.APC_WAIT_TIME = 300 -- Number of seconds an APC waits (Survival waits twice as long)
CivillianManager.APC_WAITING_REFRESH_TIME = 10 -- Number of seconds to wait between text updates
CivillianManager.MAX_CIVS_IN_APC = 8 -- Number of civs that can fit in an APC
CivillianManager.TELEVAC_TELEPORT_COST = 250

CivillianManager.ANTIDOTE_ITEM_NAME = "item_antidotes"
CivillianManager.CIVILIAN_MALE_UNIT_NAME = "civillian_male"
CivillianManager.CIVILIAN_FEMALE_UNIT_NAME = "civillian_female"
CivillianManager.APC_UNIT_NAME = "automated_personal_carrier"
CivillianManager.TELEVAC_UNIT_NAME = "televac"

-- APCs go through a few modes
CivillianManager.APC_MODE_TO_BUNKER = 1 -- Mode where APC is heading to a bunker
CivillianManager.APC_MODE_WAITING_FOR_CIVS = 2 -- Mode where APC is sitting in a bunker waiting for civs
CivillianManager.APC_MODE_FULL = 3 -- APC is full and ready to leave the bunker
CivillianManager.APC_MODE_LEAVING_CITY = 4 -- APC is leaving the city

function CivillianManager:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.civsNeeded = 1

    self.civsRescued = 0
    self.swiftCivsReward = 0 -- We award bonus XP to swifties, but only up to a certain number of rescued civs

    self.civsMedalPoints = 0 -- Points towards medals for rescueing civs

    -- Chance of antidote eventually working (1000 == 100% chance)
    self.antidoteFailChance = 0

    -- Set to true when we start ioning rads periodically once civs all rescued
    self.ionRadsStarted = false

    -- Antidote Chance
    -- Chance of an antidote working - key == playerCount + 3 - difficultyValue - hasTriage
    self.antidoteChance = {}
    self.antidoteChance[0] = 3000 -- 1p, Normal, Triage
    self.antidoteChance[1] = 3000
    self.antidoteChance[2] = 3000
    self.antidoteChance[3] = 3000
    self.antidoteChance[4] = 1680
    self.antidoteChance[5] = 960
    self.antidoteChance[6] = 670
    self.antidoteChance[7] = 520
    self.antidoteChance[8] = 420
    self.antidoteChance[9] = 360
    self.antidoteChance[10] = 310
    self.antidoteChance[11] = 270 -- 9p, Ins+

    -- Super dotes increase the chance of inoculating zombies successfully
    -- The team only gets a limited number of these at the start (based on difficulty)
    -- They will also diminish as days progress
    self.superDotes = 0
    self.superDotesPrior = 0

    -- Will store all of the televacs once spawned
    self.televacs = {}

    return o
end

-- Should be called when the difficulty is set in GameManager
function CivillianManager:onDifficultySet(difficulty)
    if difficulty == "normal" then
        -- Normal mode
        self.civsNeeded = 6
        self.superDotes = 18
    elseif difficulty == "hard" then
        -- Hard mode
        self.civsNeeded = 12
        self.superDotes = 22
    elseif difficulty == "insane" then
        -- Insane mode
        self.civsNeeded = 20
        self.superDotes = 36
    elseif difficulty == "survival" then
        -- Survival mode
        -- Doesn't need any civs
        self.civsNeeded = 0
        self.superDotes = 0
    elseif difficulty == "nightmare" then
        -- Nightmare mode  (should be set after another difficulty was set)
        -- TODO
        self.civsNeeded = 32
        self.superDotes = self.superDotes + 12
    elseif difficulty == "extinction" then
        -- Extinction mode (should be set after another difficulty was set)
        -- TODO
        self.civsNeeded = 32
        self.superDotes = self.superDotes + 12
    else
        -- Unknown? Error! (Shouldn't happen)
        print("PowerManager | UNKNOWN DIFFICULTY SET!: '" .. difficulty .. "'")
    end

    self.superDotesPrior = self.superDotes

    self:spawnTelevacs()
end

function CivillianManager:onNewDay()
    -- Update quantity of super dotes
    if self.superDotesPrior > 0 then
        if g_DayNightManager.currentDay == 2 then
            self.superDotes = self.superDotes - 8 + (math.min(self.superDotesPrior - self.superDotes, 14) / 2)
        else
            self.superDotes = self.superDotes - 20 + (math.min(self.superDotesPrior - self.superDotes, 38) / 2)
        end
        if self.superDotes < 0 then
            self.superDotes = 0
        end
    end
    self.superDotesPrior = self.superDotes
    if SHOW_CIVILLIAN_MANAGER_LOGS then
        print("CivillianManager | Updated Super Dotes Count: " .. self.superDotes)
    end
end

function CivillianManager:onPowerPlantFilled()
    if g_PowerManager.powerPlantsFilled == 6 then
        self:startPeriodicPowerSurgeCycle()
    end

    if g_PowerManager.powerPlantsFilled > g_PowerManager.powerPlantsNeeded then
        Timers:CreateTimer(RandomInt(1, 25), function()
            self:powerSurgeTelevac()
        end)
    elseif g_PowerManager.powerPlantsFilled == g_PowerManager.powerPlantsNeeded then
        -- Start general televac charging. A power surge will also happen soon after
        self:startTelevacNormalCharging()
    end
end



-- Called when one or civillians has been rescued (either through APCs or televac)
-- @param civilliansRescued | The number of civillians rescued
function CivillianManager:onCivilliansRescued(civilliansRescued)
    if SHOW_CIVILLIAN_MANAGER_LOGS then
        print("CivillianManager | Civillians Rescued: " .. civilliansRescued)
    end

    self.civsRescued = self.civsRescued + civilliansRescued

    -- Calculate points towards medals
    -- Faster they rescue civs, the more points they earn
    local minutesElapsed = 0 -- TODO
    if minutesElapsed > 52.9 then
        self.civsMedalPoints = self.civsMedalPoints + (10 * civilliansRescued)
    elseif minutesElapsed > 28.9 then
        self.civsMedalPoints = self.civsMedalPoints + (14 * civilliansRescued)
    else
        self.civsMedalPoints = self.civsMedalPoints + (21 * civilliansRescued)
    end

    -- Update antidote failure chance for NM
    if(g_GameManager.nightmareValue > 0 and self.civsRescued > 31) then
        self:calculateAntidoteFailureChance()
    end

    -- TODO: Display Hint to new players on normal diff
    -- call RedMsgAll("|r|cff00ff00HINT|r |cffffcc00Rescued civs increase your hazard pay and recognition.")

    if g_GameManager.survivalValue < 1 then
        -- Not survival mode:

        -- TODO: Award objective gold
        -- RedDivideGold( (175 + ( 25 * g_GameManager.difficultyValue ) - (10 * g_GameManager.nightmareOrSurvivalValue)) * civilliansRescued)

        -- TODO: Award Swifities objective experience
        if self.swiftCivsReward > 0 then
            if self.swiftCivsReward > civilliansRescued then
                -- TODO: awardSwiftExperience((300 - (75 * g_GameManager.nightmareOrSurvivalValue)) * civilliansRescued)
                self.swiftCivsReward = self.swiftCivsReward - civilliansRescued
            else
                -- TODO: awardSwiftExperience((300 - (75 * g_GameManager.nightmareOrSurvivalValue)) * self.swiftCivsReward)
                self.swiftCivsReward = 0
            end
        end

        if self.ionRadsStarted == false and self.civsRescued >= self.civsNeeded then
            -- Start ioning rads
            self:startPeriodicIonStrikes()
        end
    else
        -- Survival mode
        -- TODO:
        --call RedMsgAll( "Civilians rescued:|r |cffff8000" + I2S(udg_Rescued) )
        --call RedDivideGold( 300*iCivs, true )
        --call RedAwardSwiftExp(400*iCivs)
    end

    -- Alert UI
    self:updateCivillianDisplay()
end

-- Starts periodcially ioning rad fragments once enough civs rescued
function CivillianManager:startPeriodicIonStrikes()
    -- TODO: gg_trg_PeriodicIonStrike
    if SHOW_CIVILLIAN_MANAGER_LOGS then
        print("CivillianManager | Starting periodic ion strikes")
    end
    self.ionRadsStarted = true
end

function CivillianManager:updateCivillianDisplay()
    CustomGameEventManager:Send_ServerToAllClients("display_civ", {civcount = self.civsRescued , civsneeded = self.civsNeeded})
end


---------------------
--- Doting
---------------------


-- Called when a normal zombie is hit with an antidote (may convert the zombie to a blue zombie)
-- @param zombie | The zombie doted
-- @param doter | The unit that doted the zombie
function CivillianManager:onRegularZombieDoted(zombie, doter)
    -- TODO: Move to a hasSpec() method
    local hasTriageSpec = doter.playerInfo and doter.playerInfo.specName == "triage"
    -- There is a chance of this failing
    if zombie:IsAlive()
        and (hasTriageSpec or (RandomInt(0, 99) < (77 + (6 * g_GameManager.difficultyValue)))) then

        -- Successfully turned zombie into blue zombie
        zombie:SetTeam(doter:GetTeamNumber())
        zombie:SetOwner(doter)
        zombie:SetControllableByPlayer(doter:GetPlayerOwnerID(), true)
        zombie:SetBaseMoveSpeed(CivillianManager.BLUE_ZOMBIE_MOVE_SPEED)
        zombie.onDeathFunction = nil

        -- Check for Healer
        if doter.playerInfo and doter.playerInfo.traitName == "healer" then
            -- Healers fully heal the zombie
            zombie:SetHealth(zombie:GetMaxHealth())
        end

        -- Remove all of the zombies abilities
        local i = 0
        while true do
            local ability = zombie:GetAbilityByIndex(i)
            i = i + 1
            if ability then
                zombie:RemoveAbility(ability:GetAbilityName())
            else
                break
            end
        end

        -- Add Radiation Immunity
        zombie:AddAbility("common_magic_immune")
        zombie:FindAbilityByName("common_magic_immune"):SetLevel(1)

        -- Give "Inoculated" buff (which should change their color)
        zombie:AddAbility("civillian_innoculated")
        zombie:FindAbilityByName("civillian_innoculated"):SetLevel(1)

        if (( g_PlayerManager.playerCount > 1 ) or ( g_GameManager.nightmareValue > 0 )) and ( not g_GameManager.isSurvival ) and ( RandomInt( 1, g_GameManager.difficultyValue * g_GameManager.difficultyValue ) < 2 ) then
            -- Give "Partial Cure" Debuff (a.k.a. sparkly), which needs more antidotes
            zombie:AddAbility("civillian_partial_cure")
            zombie:FindAbilityByName("civillian_partial_cure"):SetLevel(1)
        end

        -- Make unit walk towards doter
        local position = doter:GetAbsOrigin()
        Timers:CreateTimer(0.3, function()
            ExecuteOrderFromTable({ UnitIndex = zombie:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION , Position = position, Queue = false})
        end)

        -- Start timer for innoculation end
        local innoculationTime = 0
        -- TODO: Check for healer
        if false then
            -- Healers cure zombies 33% faster
            innoculationTime = RandomInt(40, 46 + ((4 - g_GameManager.difficultyValue) * 13) - 20)
        else
            innoculationTime = RandomInt(60, 70 + ((4 - g_GameManager.difficultyValue) * 20) - 20)
        end

        -- Have the buff show the duration (TODO: Keep this?)
        zombie:FindModifierByName("modifier_civillian_innoculated"):SetDuration(innoculationTime, true)

        Timers:CreateTimer(innoculationTime, function()
            if zombie:IsNull() == false and zombie:IsAlive() then
                self:onZombieInoculationOver(zombie, doter)
            end
        end)
    else
        if SHOW_CIVILLIAN_MANAGER_LOGS then
            print("CivillianManager | Failed to convert zombie")
        end
    end
end

-- Called when a blue zombie is doted (attempt to remove "sparkliness")
function CivillianManager:onBlueZombieDoted(zombie, doter)
    local doterId = doter:GetPlayerOwnerID()
    local dotes = 3 -- Used when calculating how many super dotes are used

    -- First check to see if this blue zombie has already been re antidoted by this player
    -- (They're only allowed to readminister the antidote once)
    if zombie["doted_by_" .. doterId] then
        -- TODO: Show message
        --if udg_aRankExp[iP] < 9*udg_RXP then //hopefully this is shown to Rank 9 and lower
        --  call RedMsg(Player(iP), "|r|cff00ff00HINT|r |cffffcc00Only your first attempt to finish inoculizing a particular zombie can succeed.")
        --endif
        print("CivillianManager | Civ already re-doted by this player id: " .. tostring(doterId))
    else
        -- First time readministering dote
        zombie["doted_by_" .. doterId] = true -- Mark it so same user can't redote again

        if RandomInt(0, 999) < self.antidoteFailChance then
            -- We reduce the chance of success in NM/Ext after 32 civs have been rescued
            if SHOW_CIVILLIAN_MANAGER_LOGS then
                print("CivillianManager | Re-dote failed because of antidote fail chance")
            end
        else
            local triageBonus = 0
            if doter.playerInfo and doter.playerInfo.specName == "triage" then
                triageBonus = 1
            end

            -- Base chance of removing sparkly effect
            local chance = self.antidoteChance[g_PlayerManager.playerCount + 3 - g_GameManager.difficultyValue - triageBonus] + (50 * triageBonus)

            -- Apply a bonus to the chance for nearby allies with antidotes
            if g_GameManager.nightmareValue < 0 then
                chance = self:calculateAntidoteBonus(doter, 900, 0.15, chance)
            else
                chance = self:calculateAntidoteBonus(doter, 625, 0.05, chance)
            end

            -- Adjust chance
            if doterId == zombie:GetPlayerOwnerID() then
                -- Owner of zombie is redoting the zombie. Reduce the chance
                chance = chance / (2 + g_GameManager.nightmareOrSurvivalValue)
            elseif chance < 824 and self.superDotes > 0 then
                -- Use a super dote to increase the chance
                chance = chance + ((chance / 100) * (self.superDotes / 3)) + self.superDotes
                self.superDotes = self.superDotes - 1
                dotes = dotes - 1 -- Consume fewer super dotes later since we did this
            end

            print("CivillianManager | DEBUG | Partial Cure Removal Chance: " .. chance)
            -- Roll to see if inoculation succeeds
            if RandomInt(0, 999) < chance then
                if g_GameManager.nightmareValue == 0 or g_PlayerManager.playerCount < 3 then
                    -- Remove sparkly ability. Cured!
                    self:removePartialCure(zombie)
                else
                    -- Nightmare+ has a chance that for "double" sparkly
                    dotes = dotes - 1

                    -- Chance of double sparklied zombie (NM+)
                    if g_RadiationManager.hazmatContainers > 2 then
                        -- Hazmat containers over 2! Chance of non-double sparkly == 66-72% NM, 48-54% EXT
                        chance = 18 * (5 - g_GameManager.nightmareValue) - (2 * g_RadiationManager.hazmatContainers) + 6
                    else
                        -- Hazmat containers <= 2! Chance of non-double sparkly == 77,88,99% NM, 66,77,88% EXT
                        chance = 11 * (10 - g_GameManager.nightmareValue - g_RadiationManager.hazmatContainers)
                    end
                    -- Success! Cure the zombie (or undouble a double sparkly [NM+])
                    if zombie.curedBefore or (RandomInt(0, 99) < chance) then
                        -- Remove sparkly ability. Cured!
                        self:removePartialCure(zombie)
                    elseif self:attemptSuperInoculation(dotes) then
                        -- Remove sparkly ability. Cured using super dote!
                        self:removePartialCure(zombie)
                    else
                        -- Double sparkly :(
                        zombie.curedBefore = true

                        if SHOW_CIVILLIAN_MANAGER_LOGS then
                            print("CivillianManager | Zombie successfully cured but it was a double sparkly!")
                        end
                    end
                end
            elseif self:attemptSuperInoculation(dotes) then
                -- Remove sparkly ability. Cured using super dote!
                self:removePartialCure(zombie)
            else
                if SHOW_CIVILLIAN_MANAGER_LOGS then
                    print("CivillianManager | Zombie inoculation failed")
                end
            end


        end
    end
end

function CivillianManager:removePartialCure(unit)
    if SHOW_CIVILLIAN_MANAGER_LOGS then
        print("CivillianManager | Zombie fully cured!")
    end
    unit:RemoveAbility("civillian_partial_cure")
    unit:RemoveModifierByName("modifier_civillian_partial_cure")
end

-- Rolls to see if the zombie is inoculated successfully using super dotes
-- @param dotes | Number of super dotes consumed if successful
function CivillianManager:attemptSuperInoculation(dotes)
    if self.superDotes > 0 then
        local chance = math.pow(math.floor(self.superDotes / 4), 3)
        print("CivillianManager | SUPER DOTES (" .. self.superDotes .. ") CHANCE: " .. chance)

        if RandomInt(350 * g_GameManager.nightmareOrSurvivalValue, 499 + (350 * g_GameManager.nightmareOrSurvivalValue)) < chance then
            self.superDotes = self.superDotes - dotes
            if SHOW_CIVILLIAN_MANAGER_LOGS then
                print("CivillianManager | Successful Inoculation using super dotes! Super dotes = " .. self.superDotes)
            end
            return true
        end
    end
    return false
end

-- Called when the blue zombie's innoculation period is over
-- The zombie will not have sparkliness (it would have already died)
function CivillianManager:onZombieInoculationOver(zombie, doter)
    -- NM+ Only | Roll for chance of spiders
    if (g_GameManager.nightmareValue > 0) and (self.civsRescued > RandomInt(0, 32 * (6 - (2 * g_GameManager.nightmareValue)))) then
        -- Make a spider civ bomb
        -- TODO: NM+
    else
        local percentHealth = zombie:GetHealth() / zombie:GetMaxHealth()
        local position = zombie:GetAbsOrigin()

        zombie:AddNoDraw()
        zombie:ForceKill(true)

        -- Spawn a normal civ
        local unitName = (RandomInt(0, 1) == 0) and CivillianManager.CIVILIAN_MALE_UNIT_NAME or CivillianManager.CIVILIAN_FEMALE_UNIT_NAME
        local unit = CreateUnitByName( unitName, position, true, nil, nil, DOTA_TEAM_GOODGUYS )
        unit:AddAbility("common_no_auto_attack")
        unit:FindAbilityByName("common_no_auto_attack"):SetLevel(1)
        unit:SetOwner(doter)
        unit:SetControllableByPlayer(doter:GetPlayerOwnerID(), true)
        unit:SetHealth(percentHealth * unit:GetMaxHealth())
        -- TODO: Set its movespeed based on number of leadership players
        --unit:SetBaseMoveSpeed(unit:GetBaseMoveSpeed() * (2.0 - math.pow(0.9, numberOfLeadershipPlayers)))

    end
end

-- Calculates a bonus chance to remove the sparkly effect if nearby allies are around the doter
-- and they are carrying antidotes
-- @return integer | a new chance to convert
function CivillianManager:calculateAntidoteBonus(doter, radius, multiplier, originalChance)
    local newChance = originalChance

    local nearbyHeroes = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                                            doter:GetAbsOrigin(),
                                            doter,
                                            radius,
                                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                            DOTA_UNIT_TARGET_HERO,
                                            DOTA_UNIT_TARGET_FLAG_NONE,
                                            FIND_ANY_ORDER,
                                            false)
    for _,hero in pairs(nearbyHeroes) do
        if hero ~= doter and hero:HasItemInInventory(CivillianManager.ANTIDOTE_ITEM_NAME) then
            newChance = newChance + (multiplier * originalChance)
        end
    end

    return newChance
end

-- Nightmare Only
-- After 32 civs, there will be a greater and greater cance of civs not being possible to convert
-- This is called after every civ rescued starting with the 33rd civ rescued
function CivillianManager:calculateAntidoteFailureChance()
    local civs = self.civsRescued - 32
    local fail = 10 -- 1% chance to outright fail innoculation
    while civs > 0 do
        fail = math.floor(fail * 4 / 3)
        if fail > 950 then
            fail = 950 -- The max fail chance is 95% chance
        end
        civs = civs - 1
    end
end

---------------------
--- APCs
---------------------

-- Spawns an APC at a designated spawn point and tells it to go to a nearby bunker
function CivillianManager:spawnApc(delay)
    if SHOW_CIVILLIAN_MANAGER_LOGS then
        print("CivillianManager | Spawning APC in " .. tostring(delay) .. " seconds")
    end

    -- TODO: Send Message
    if delay > 0 then
        -- RedMsgAll( "A.P.C. en route to bomb shelter in " + I2S( iDelay ) + " seconds..." )
    else
        -- RedMsgAll( "A.P.C. en route to bomb shelter..." )
    end

    local startRegion = Locations.apc_spawns[RandomInt(1, #Locations.apc_spawns)]

    -- Pick between one of the two closest bunkers
    local closestBunker = nil
    local closestDistance = nil
    local secondClosestBunker = nil
    local secondClosestDistance = nil
    for _,bunker in pairs(Locations.bunkers) do
        local distance = distanceBetweenVectors(bunker:GetAbsOrigin(), startRegion:GetAbsOrigin())
        if closestDistance == nil or distance < closestDistance then
            secondClosestDistance = closestDistance
            secondClosestBunker = closestBunker
            closestBunker = bunker
            closestDistance = distance
        elseif secondClosestDistance == nil or distance < secondClosestDistance then
            secondClosestBunker = bunker
            secondClosestDistance = distance
        end
    end

    local targetBunker = nil
    if secondClosestBunker and RandomInt(1,2) < 2 then
        targetBunker = secondClosestBunker
    else
        targetBunker = closestBunker
    end

    -- TODO: Ping Target Bunker

    Timers:CreateTimer(delay, function()

        local position = GetCenterInRegion(startRegion)
        local unit = CreateUnitByName( CivillianManager.APC_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_GOODGUYS )
        unit.startRegion = startRegion -- Where to send the APC back
        unit.targetBunker = targetBunker
        unit.mode = CivillianManager.APC_MODE_TO_BUNKER
        unit.civsInside = 0

        unit.onDeathFunction = function(killedUnit, killerEntity, killerAbility)
            g_CivillianManager:onApcDestroyed(killedUnit)
        end

        Timers:CreateTimer(0.3, function()
            if not unit:IsNull() and unit:IsAlive() and unit.mode == CivillianManager.APC_MODE_TO_BUNKER then
                if SHOW_CIVILLIAN_MANAGER_LOGS then
                    print("CivillianManager | Ordering APC to move to bunker")
                end
                local position = GetCenterInRegion(unit.targetBunker)
                ExecuteOrderFromTable({ UnitIndex = unit:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION , Position = position, Queue = false})
                return 30 -- Check later and order it to move again (may have gotten stuck)
            end
        end)
    end)
end

-- Called when an APC enters a bunker
function CivillianManager:onApcEntersBunker(apc)
    -- APCs will wait 5 minutes in a bunker
    local waitTicks = math.floor(300 / CivillianManager.APC_WAITING_REFRESH_TIME)
    if g_GameManager.isSurvival then
        -- Survial waits twice as long
        waitTicks = waitTicks * 2
    end

    -- Make sure this is one heading to a bunker (and not an exiting APC re-entering bunker)
    if apc.mode == CivillianManager.APC_MODE_TO_BUNKER then
        apc.mode = CivillianManager.APC_MODE_WAITING_FOR_CIVS

        -- Give Invisibility/Ability that allows civs to enter
        apc:AddAbility("common_invisible")
        apc:FindAbilityByName("common_invisible"):SetLevel(1)
        apc:AddAbility("apc_civ_boarding")
        apc:FindAbilityByName("apc_civ_boarding"):SetLevel(1)

        -- Give it some time to settle in at the center
        Timers:CreateTimer(3, function()

            if not apc:IsNull() and apc:IsAlive() then
                if (apc.mode == CivillianManager.APC_MODE_WAITING_FOR_CIVS and waitTicks == 0)
                    or apc.mode == CivillianManager.APC_MODE_FULL then
                    -- Tell APC to leave the city
                    apc.mode = CivillianManager.APC_MODE_LEAVING_CITY

                    -- Remove invisibility and civ boarding aura
                    apc:RemoveAbility("common_invisible")
                    apc:RemoveModifierByName("common_invisible")
                    apc:RemoveAbility("apc_civ_boarding")
                    apc:RemoveModifierByName("modifier_apc_civ_boarding_aura")

                    -- TODO: Alert players APC is leaving
                    -- call RedMsgAll("A.P.C. leaving with " + I2S(GetUnitUserData(oAPC)) + " civilians inside.")
                    -- TODO: Ping map

                    -- Start a periodic instruction in case the unit gets stuck
                    Timers:CreateTimer(0, function()
                        if not apc:IsNull() and apc:IsAlive() then
                            if SHOW_CIVILLIAN_MANAGER_LOGS then
                                print("CivillianManager | Telling APC to return to start region")
                            end
                            local position = GetCenterInRegion(apc.startRegion)
                            ExecuteOrderFromTable({ UnitIndex = apc:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION , Position = position, Queue = false})

                            return 30
                        end
                    end)
                elseif apc.mode == CivillianManager.APC_MODE_WAITING_FOR_CIVS then
                    if waitTicks == 6 then
                        -- TODO: Alert players the APC will leave in 60 seconds and Ping
                        print("CivillianManager | DEBUG - APC Will leave in 60 seconds")
                    end

                    -- Display information
                    if g_PowerManager.powerRestored then
                        self:displayApcText(apc, waitTicks)
                    end

                    waitTicks = waitTicks - 1

                    return CivillianManager.APC_WAITING_REFRESH_TIME
                end
            end
        end)
    end
end

-- Called when Civ gets near an APC
function CivillianManager:onCivBoardsApc(apc, civ)
    if not civ.boardingApc then
        -- Mark the civ as boarding
        local owningPlayer = civ:GetPlayerOwnerID()
        --civ:SetControllableByPlayer(owningPlayer, false) -- TODO: Actually remove control. This doesn't do that
        civ.boardingApc = true

        -- Tell civ to move towards the APC (looks better when we remove it)
        local position = apc:GetAbsOrigin()
        ExecuteOrderFromTable({ UnitIndex = civ:GetEntityIndex(), OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION , Position = position, Queue = false})

        Timers:CreateTimer(2.5, function()
            if not civ:IsNull() and civ:IsAlive() then
                if not apc:IsNull() and apc:IsAlive() and apc.mode == CivillianManager.APC_MODE_WAITING_FOR_CIVS then
                    -- Have the civ enter the APC
                    apc.civsInside = apc.civsInside + 1
                    civ:AddNoDraw()
                    civ:ForceKill(true)

                    -- Prevent APC from receiving more civillians
                    if apc.civsInside == CivillianManager.MAX_CIVS_IN_APC then
                        apc.mode = CivillianManager.APC_MODE_FULL
                        apc:RemoveAbility("apc_civ_boarding")
                        apc:RemoveModifierByName("modifier_apc_civ_boarding_aura")
                    end
                else
                    -- APC can no longer receive this civ (it died or filled up. Give back control)
                    civ.boardingApc = nil
                    civ:SetControllableByPlayer(owningPlayer, true)
                end
            end
        end)
    end

end

-- Called when an APC enters a start region
function CivillianManager:onApcLeavesCity(apc)
    if apc.mode == CivillianManager.APC_MODE_LEAVING_CITY then
        -- Make sure a new APC is not reentering this region
        if SHOW_CIVILLIAN_MANAGER_LOGS then
            print("CivillianManager | APC has left the city")
        end

        if apc.civsInside > 0 then
            self:onCivilliansRescued(apc.civsInside)
        end

        apc.civsInside = -1 -- Prevent onApcDestroyed call
        apc:AddNoDraw()
        apc:ForceKill(true)
    end
end

-- Called when an APC is destroyed
function CivillianManager:onApcDestroyed(apc)
    if apc.civsInside > 0 then
        if apc.mode == CivillianManager.APC_MODE_LEAVING_CITY then
            -- TODO: Send message to players
            print("CivillianManager | A.P.C destroyed! Civillian casualties: " .. tostring(apc.civsInside - 1) .. ". One survivor!")
            self:onCivilliansRescued(1)
        else
            -- TODO: Send message to players
            print("CivillianManager | A.P.C destroyed! Civillian casualties: " .. tostring(apc.civsInside))
        end
    end
end

-- Displays text above the APC about its contents and time remaining
function CivillianManager:displayApcText(apc, waitTicksRemaining)
    -- TODO
    print("CivillianManager | DEBUG - Display APC Text: " .. tostring(apc.civsInside) .. " / 8 | Leaves in " .. tostring(waitTicksRemaining * CivillianManager.APC_WAITING_REFRESH_TIME) .. " seconds")
end

---------------------
--- Televacs
---------------------

-- Spawns the initial televacs
function CivillianManager:spawnTelevacs()
    for _,televac_spawn in pairs(Locations.televac_spawns) do
        local position = televac_spawn:GetAbsOrigin()
        local unit = CreateUnitByName( CivillianManager.TELEVAC_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_GOODGUYS )
        unit:SetMana(0)
        table.insert(self.televacs, unit)
    end

    -- Started right at the beginning (but if power isn't restored by the time it goes off they'll slowly lose energy)
    self:startPeriodicPowerSurgeCycle()
end

-- Tells the televacs that city power has been restored and then can start naturall recharging
function CivillianManager:startTelevacNormalCharging()
    if SHOW_CIVILLIAN_MANAGER_LOGS then
        print("CivillianManager | Televacs are being powered on")
    end

    -- Send message to new players that they can send civillians to APCs to save them
    -- TODO
    -- call RedMsg(Player(i), "|r|cff00ff00HINT|r |cffffcc00You can rescue a civ by sending it to a Televac that has at least 250 energy.")

    for _,televac in pairs(self.televacs) do
        televac:RemoveAbility("televac_unpowered")
        televac:RemoveModifierByName("modifier_televac_unpowered")
        televac:AddAbility("televac_powered")
        televac:FindAbilityByName("televac_powered"):SetLevel(1)
    end

    -- After a little bit of time, power surge the first televac
    Timers:CreateTimer(RandomInt(3, 20), function()
        -- Assign a random initial mana value now to randomize who will get the power surge
        for _,televac in pairs(self.televacs) do
            televac:SetMana(televac:GetMana() + RandomInt(1, 25))
        end
        self:powerSurgeTelevac()
    end)
end

-- Picks the lowest energy televac and gives ti a power surge buff temporarily
function CivillianManager:powerSurgeTelevac()
    if SHOW_CIVILLIAN_MANAGER_LOGS then
        print("CivillianManager | A televac is experiencing a power surge")
    end

    -- Get the lowest energy televac not currently receiving a power surge
    local lowestTelevac = nil
    local lowestEnergy = 100000
    for _,televac in pairs(self.televacs) do
        if not televac:FindAbilityByName("televac_power_surge")
            and televac:GetMana() < lowestEnergy then
            lowestTelevac = televac
            lowestEnergy = televac:GetMana()
        end
    end

    local televac = lowestTelevac

    -- TODO: Send message indicating a televac is expericing a power surge
    --call RedMsgAll("Televac experiencing a power surge.")
    -- TODO: Ping location of Televac

    -- Add power surge ability
    televac:AddAbility("televac_power_surge")
    televac:FindAbilityByName("televac_power_surge"):SetLevel(1)

    -- Remove power surge after some time
    Timers:CreateTimer(60 - (g_GameManager.nightmareValue * 10), function()
        televac:RemoveAbility("televac_power_surge")
        televac:RemoveModifierByName("modifier_televac_power_surge")
    end)
end

-- Starts a slow power surge cycle where every 20ish minutes a televac will power surge
-- This starts at the beginning of the game and also when all power plants have been finished
function CivillianManager:startPeriodicPowerSurgeCycle()
    if SHOW_CIVILLIAN_MANAGER_LOGS then
        print("CivillianManager | Starting Power Surge Cycle")
    end
    Timers:CreateTimer(RandomInt(1110, 1350), function()
        self:powerSurgeTelevac()
        return RandomInt(1110, 1350)
    end)
end

-- Called when a civ enters a televac region
function CivillianManager:onCivEntersTelevacTeleport(televac, civ)
    if televac:GetMana() > CivillianManager.TELEVAC_TELEPORT_COST and not civ.boardingApc then
        televac:SetMana(televac:GetMana() - CivillianManager.TELEVAC_TELEPORT_COST)
        civ:AddNoDraw()
        civ:ForceKill(true)
        self:onCivilliansRescued(1)

        -- TODO: Play some teleport effect and sound
    else
        if SHOW_CIVILLIAN_MANAGER_LOGS then
            print("CivillianManager | Civ entered telvac region but the televac does not have enough energy")
        end
    end
end
