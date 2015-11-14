-- Class that handles the radiation fragments

SHOW_RADIATION_MANAGER_LOGS = SHOW_GAME_SYSTEM_LOGS

RadiationManager = {}

-- CONSTANTS
RAD_RESIST_TRAIT_BONUS = 4 -- The amount of bonus rad resistance provided by the rad resist trait (diminishing returns will apply)
RAD_RESISTANCE_REDUCTION_VALUE = 0.95
INITIAL_RAD_COUNT = 32
RAD_COUNT_LIMIT = 130

function RadiationManager:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.debugMode = true

    -- Total number of rad fragments / sources (not including modifiers like hazmat / rad resist players)
    self.radFragments = 0

    -- The "effective" radiation level is used to determine the radiation level
    -- It is based on the number of toxic waste canisters still in play and the number of RadResist traited heroes
    self.effectiveRadiation = 0

    -- The radiation level
    -- Radiation is broken into the following levels based on *effective* radiation count
    -- RadLevel | Effective Radiation Range
    -- -1 | 0-0   : No radiation. No damage to heroes or civilians. Zombies receive little mana recharge
    -- 0  | 1-20  : Small damage to civillians. Zombies receive little mana recharge
    -- 1  | 21-40 :
    -- 2  | 40-59 :
    -- 3  | 60-79 :
    -- 4  | 80-99 :
    -- 5  | 100+  :
    self.radiationLevel = -1

    -- The number of players with the Rad Resist trait
    self.radResistPlayers = 0

    -- The amount of radiation resistance provided by rad resist traited heroes
    self.radiationResistance = 0

    -- The amount of hazmat containers still in play
    self.hazmatContainers = 0

    -- Dummy aura units
    self.radHeroDamageAuraUnit = nil
    self.radCivillianDamageAuraUnit = nil
    self.radZombieManaBuffAuraUnit = nil
    self.radMutantBuffAuraUnit = nil

    -- Indicates that rads are spawning. Set to false to kill the loop
    self.spawningRads = false

    self.radSoftLimit = 100 -- determined by difficulty. Some things that spawn rads will not occur if above this
    self.radSafeLimit = 25 -- determined by difficulty. Some things that spawn rads will not occur if below this

    self.nukedRads = 0 -- count of nuked rads
    self.ionedRads = 0 -- count of ioned rads

    -- Popped rads are basically the number of killed rads since the last rad spawn
    -- They will *increase* the time before the next rad wave spawns
    -- This number increments by one for every rad destroyed with two exceptions:
    --      Rads killed by robodogs that are far from their master do not contribute to this
    --      Rads killed by nukes will *halve* the current count
    self.poppedRads = 0

    -- Horror rads - rads contributed by a currently alive horror
    self.horrorRads = 0

    ------------
    -- SETUP
    ------------

    -- Create dummy aura units
    --self.radHeroDamageAuraUnit = CreateUnitByName("npc_dummy_blank",Entities:FindByName( nil, "room_lab"):GetAbsOrigin(),true, nil, nil, DOTA_TEAM_BADGUYS)
    --self.radHeroDamageAuraUnit:AddAbility("global_radiation_damage")
    --self.radHeroDamageAuraUnit:AddAbility("swat_ability_invulnerable_object")

    -- TODO: Create more dummy aura units

    return o
end

---------------------------
-- 'PUBLIC' METHODS
---------------------------

-- Sets the difficulty of the game, which affects how rads are spawned
function RadiationManager:onDifficultySet()
    if SHOW_RADIATION_MANAGER_LOGS then
        print("RadManager | Setting difficulty to: " .. g_GameManager.difficultyName)
    end
    if g_GameManager.nightmareValue == 0 then
        self:spawnInitialDifficultyRads(g_GameManager.difficultyValue, g_GameManager.isSurvival)
    else
        -- TODO
        -- Do nightmare / extinction rad ramp up
    end

end

function RadiationManager:onPreGameStarted()
    self:spawnInitialRadFragments()
    self:startRadSpawner()
end

-- Checks to see if the rad level as changed since last called.
-- If it has, it will call the relevant methods that need to be updated on a rad level change
function RadiationManager:updateRadLevel()
    newRadLevel = self.radiationLevel
    if self.radFragments + self.hazmatContainers < 1 then
        newRadLevel = -1
    else
        newRadLevel = math.floor(( self.radFragments - ( 2 * self.radResistPlayers ) + self.hazmatContainers ) / 20)
        if newRadLevel < 0 then
            newRadLevel = 0
        elseif newRadLevel > 5 then
            newRadLevel = 5
        end
    end
    if newRadLevel ~= self.radiationLevel then
        -- The radiation level has changed!
        self.radiationLevel = newRadLevel
        if SHOW_RADIATION_MANAGER_LOGS then
            print("RadManager | The radiation level has changed to: " .. newRadLevel)
        end

        self:updateRadiationFog(newRadLevel)
        self:updateRadiationDamageAura(newRadLevel)
        self:updateRadiationBuffAura(newRadLevel)
        self:playRadLevelChangedSound(newRadLevel)
    end
end

-- Called to increment the rad count (the radiation level will be checked)
-- Should be called when rad fragments / rad zombies / horrors...etc are made
function RadiationManager:incrementRadCount(increment)
    increment = increment or 1
    self.radFragments = self.radFragments + increment
    self:updateRadiationDisplay(self.radFragments)
    self:updateRadLevel()
end

-- Called to increment the rad count (the radiation level will be checked)
-- Should be called when rad fragments / sources are destroyed
function RadiationManager:decrementRadCount(increment)
    increment = increment or 1
    self.radFragments = self.radFragments - increment
    self:updateRadiationDisplay(self.radFragments)
    self:updateRadLevel()
end

-- Spawns a rad somewhere on the map and increments the count
-- NOTE: Does not increment rad count
function RadiationManager:spawnRadFragment()
    local randomNum = RandomInt(1, 999)
    local point = nil
    if randomNum < 99 then
        -- Spawn rad in park
        point = GetRandomPointInPark()
    elseif randomNum < 150 then
        -- Spawn rad in graveyard
        point = GetRandomPointInGraveyard()
    elseif randomNum < 190 then
        -- Spawn rad in ground zero
        point = GetRandomPointInGraveyard()
    else
        -- Spawn rad in a random building
        point = GetRandomPointInWarehouse()
    end

    local rad_frag = CreateUnitByName( "npc_dota_creature_rad_frag", point, true, nil, nil, DOTA_TEAM_BADGUYS )
    -- Apply rad modifier to unit to reduce rad count on death and update bracket
    rad_frag:AddAbility("rad_frag_datadriven")
    rad_frag:FindAbilityByName("rad_frag_datadriven"):SetLevel(1)
    rad_frag:SetRenderColor(50,205,50)

    -- For Nightmare+, there is a chance the rad will be an exploding rad
    if g_GameManager.nightmareValue > 0 then
        if RandomInt(0, 999) < ( 177 * g_GameManager.nightmareValue ) - ( 10 * g_GameManager.nightmareValue * g_GameManager.currentDay * g_GameManager.currentDay) then
            rad_frag:AddAbility("rad_explosion")
            rad_frag:FindAbilityByName("rad_explosion"):SetLevel(1)
            rad_frag:SetRenderColor(255, 50, 0)
        end
    end

end

-- Called when a rad fragment is destroyed
-- TODO: Pass in more information, like what killed the rad and its location
function RadiationManager:onRadDestroyed(radPosition)
    self:decrementRadCount()

    if self.radFragments < 2
        or ( ( self.radFragments < 4 ) and ( self.hazmatContainers < 3) )
        or ( ( self.radFragments < 6 ) and ( self.hazmatContainers < 1) )
        then
            -- Don't spawn radlets as they're near the end
    else
        -- Spawn radlets
        self:spawnRadlets(radPosition, false)
    end

    -- TODO: If killed by nuke, half the popped rad count
    -- TODO: If killed by robodog far from master, don't increment popped rad count
    self.poppedRads = self.poppedRads + 1
end

-- Potentially spawns radlets at the location specified.
-- The chance increases if ioned is true
function RadiationManager:spawnRadlets(radPosition, ioned)
    local randomVal = RandomInt(0, 6 * g_GameManager.difficultyValue * g_GameManager.difficultyValue - 2 * g_GameManager.nightmareValue )
    local randomCheck = (ioned and 4 or 3) -- 4 if ioned, 3 elsewise
    if randomVal < randomCheck then
        -- Spawn radlets!
        local ionPenalty = 3 * self.ionedRads + ( ioned and 30 or 0 )
        local radletsToSpawn = RandomInt( 1 + g_GameManager.nightmareOrSurvivalValue, 2 + g_GameManager.nightmareValue + ( ioned and 2 or 0 ) )
        if SHOW_RADIATION_MANAGER_LOGS then
            print("RadManager | Spawning " .. radletsToSpawn .. " radlets!")
        end

        for i = 1, radletsToSpawn do
            if self:canSpawnRadFragment() then
                local radlet = CreateUnitByName( "npc_dota_creature_rad_frag", radPosition + RandomSizedVector(160), true, nil, nil, DOTA_TEAM_BADGUYS )

                -- Generate a random "size"
                local size = RandomInt( 40 + ionPenalty - self.radResistPlayers, 80 + (3 * ionPenalty) - (3 * self.radResistPlayers))
                if g_GameManager.nightmareValue > 1 then -- Extinction
                    size = size + (self.radResistPlayers / 2) -- "because fuck rad resist players in extinction, right?" -redscull
                end

                radlet:SetRenderColor(152, 251, 152)
                radlet:SetModelScale(size / 100.0)

                radlet:AddAbility("invulnerable_unselectable")
                radlet:FindAbilityByName("invulnerable_unselectable"):SetLevel(1)

                -- Kill the radlet after size seconds
                Timers:CreateTimer(size, function()
                    if SHOW_RADIATION_MANAGER_LOGS then
                            print("RadManager | Radlet Died")
                        end
                        radlet:ForceKill(false)
                        self:decrementRadCount()
                    end
                )
            end
        end
        self:incrementRadCount(radletsToSpawn)
    end
end

-- Returns whether or not we have reached the rad limit
function RadiationManager:canSpawnRadFragment()
    return self.radFragments < RAD_COUNT_LIMIT
end

-- Spawns the initial amount of rad fragments around the map
-- This needs to be called after map initialization!
-- This will spawn INITIA_RAD_COUNT rad fragments in 32 random rooms (no park or graveyard)
-- no rad will be spawned in the same room
function RadiationManager:spawnInitialRadFragments()
    if SHOW_RADIATION_MANAGER_LOGS then
        print("RadManager | Spawning initial rad fragments")
    end
    -- The warehouses should already be in a random order in the locations
    local rooms = Locations.warehouses

    -- Spawn a guarenteed normal rad in the rooms
    for i = 1,INITIAL_RAD_COUNT do
        local room = rooms[i]
        local rad_frag = CreateUnitByName( "npc_dota_creature_rad_frag", room:GetAbsOrigin() + RandomSizedVector(480), true, nil, nil, DOTA_TEAM_BADGUYS )
        -- Apply rad modifier to unit to reduce rad count on death and update bracket

        if (rad_frag) then
            rad_frag:AddAbility("rad_frag_datadriven")
            rad_frag:FindAbilityByName("rad_frag_datadriven"):SetLevel(1)
            rad_frag:SetRenderColor(50,205,50)
        end
    end
    self:incrementRadCount(INITIAL_RAD_COUNT)
end

-- Spawns more initial rads based on the difficulty selected
-- (This occurs once difficulty is selected)
function RadiationManager:spawnInitialDifficultyRads(difficultyValue, isSurvival)
    local initialRads = 0
    if isSurvival then
        initialRads = 6
    else
        initialRads = RandomInt(4-difficultyValue, 5-difficultyValue)
    end

    if SHOW_RADIATION_MANAGER_LOGS then
        print("RadManager | Spawning initial difficulty rads: " .. initialRads)
    end

    for i = 1,initialRads do
        self:spawnRadFragment()
    end
    self:incrementRadCount(initialRads)
end

-- This function contains the rad spawning code
-- It will create 3 timers that call into each other (1 -> 2 -> 3 -> 1 -> 2 ... etc)
--  because I couldn't figure out how to do a "wait()"
function RadiationManager:startRadSpawner()

    if self.spawningRads then
        print("RadManager | Warning - not starting rad spawner as rads already spawning")
    else
        if SHOW_RADIATION_MANAGER_LOGS then
            print("RadManager | Starting Rad Spawner")
        end
        self.spawningRads = true

        -- So this process is emulating the old swat code for spawning rads continuously
        -- But the old system could wait(), this one can not, so instead, we have separate wait functions
        -- and the functions call each other.
        --
        -- Current process:
        --      spawnRadsFunction (spawns the rads)
        --          |- (If it didn't spawn rads, just delay calls itself after 60 seconds)
        --          |- (if it did spawn rads, it delay calls second wait function)
        --      secondWaitFunction (just waits)
        --          |- always waits a set period of time based on current rad count and ioned rads and stuff then calls radsPoppedWait
        --      radPoppedWaitFunction (waits based on number of popped rads)
        --          |- If there are popped rads, it delay calls itself
        --          |- if no popped rads, it just immediately calls spawnRads

        local spawnRadsFunction = nil
        local secondWaitFunction = nil
        local radPoppedWaitFunction = nil

        -- This function represents the wait periods in the rad spawning process caused by the rads popped count
        -- It basically waits based on number of popped rads, then waits more if more rads were popped in the meantime
        -- If no rads are popped, we move on to the spawning rads portion!
        -- @param timesWaited | The number of times this method has been called. Initially set to 0, it increments by 1 each time it calls itself. Affects delay time
        local timesWaitedForRadsPopped = 0 -- increments by one each time it recursively calls itself
        radPoppedWaitFunction = function()
            if self.poppedRads == 0 then
                -- No popped rads. Go spawn some rads
                if SHOW_RADIATION_MANAGER_LOGS then
                    print("RadManager | radPoppedWaitFunction() - no popped rads.")
                end
                timesWaitedForRadsPopped = 0
                Timers:CreateTimer( 0, spawnRadsFunction)
            else
                -- Some popped rads, calculate a wait period
                local delayTime = 0
                if g_GameManager.isSurvival then
                    delayTime = 1.7 + ( self.radResistPlayers / 2.0 )
                elseif timesWaitedForRadsPopped > 0 then
                    -- We have already waited for popped rads once, the second time this based delay value is slightly less
                    delayTime = 2.0
                else
                    -- First time waiting for popped rads, delayTime is slightly higher
                    delayTime = 4.5
                end
                timesWaitedForRadsPopped = timesWaitedForRadsPopped + 1
                delayTime = (delayTime + (self.poppedRads * 1.1)) * (1.03 - 0.02 * g_PlayerManager.playerCount)
                local waitTime = delayTime * delayTime

                if SHOW_RADIATION_MANAGER_LOGS then
                    print("RadManager | radPoppedWaitFunction() - [ " .. self.poppedRads .. " popped rads] Waiting: " .. waitTime)
                end

                self.poppedRads = 0

                -- Wait and then check for more popped rads
                return waitTime -- this will make the time restart and wait this long again
            end
        end

        -- This function will wait a certain amount of time based on rads nuked and ioned
        -- This function represents the second "wait" call in the original swat source formula
        secondWaitFunction = function()
            local waitTime = 0
            if g_GameManager.isSurvival then
                waitTime = math.max(math.max(10.0 - math.floor(self.nukedRads / 5) - self.ionedRads, 4), 74.0 - 0.66 * (self.radFragments + self.hazmatContainers * 2 + self.nukedRads + 2 * self.ionedRads * (self.ionedRads -1) - self.radiationResistance))
            else
                waitTime = math.max(math.max(15.0 - math.floor(self.nukedRads / 5) - self.ionedRads, 5), 79.0 - 0.60 * (self.radFragments + self.hazmatContainers * 2 + self.nukedRads + 2 * self.ionedRads * (self.ionedRads -1) - self.radiationResistance))
            end

            -- Now call the rads popped function after waiting
            if SHOW_RADIATION_MANAGER_LOGS then
                print("RadManager | secondWaitFunction() - waiting " .. waitTime)
            end
            Timers:CreateTimer( waitTime, radPoppedWaitFunction)
        end

        -- This function will actually spawn the rads for the wave
        spawnRadsFunction = function()
            -- Only spawns rad fragments if above the safe limit or we're in "penalty" mode (players nuked/ioned a rad)
            if (self.radFragments > self.radSafeLimit or self.nukedRads > 0 or self.ionedRads > 0) then
                -- Make sure we're under the soft cap (or fuck that if the players have nuked recently. We'll go all the way to hardcap then!
                if self.radFragments < self.radSoftLimit or self.nukedRads > 0 then
                    -- Spawn rads
                    local radsToSpawn = RandomInt(1, 1 + math.max(0, math.floor((self.nukedRads + self.ionedRads) / 5))) -- Nuking / Ioning (more than 5 rads) rads causes a change for extra ones to spawn
                    if SHOW_RADIATION_MANAGER_LOGS then
                        print("RadManager | Spawning " .. radsToSpawn .. " Rad(s)!")
                    end
                    -- TODO Call SetRadNuke
                    -- TODO: Update nuke rad penalty if extra rads were spawned
                    for i = 1,radsToSpawn do
                        if self:canSpawnRadFragment() then
                            self:spawnRadFragment()
                            self:incrementRadCount()
                        end
                    end
                end

                -- Now we wait a set amount of time before calling the next function
                -- Damn redscull liked weird formulas for this...(and of course its different in survival for some reason)
                local waitTime = 0
                if g_GameManager.isSurvival then
                    waitTime = math.max(math.max(10.0 - math.floor(self.nukedRads / 10) - self.ionedRads, 8), 74.0 - 0.76 * (self.radFragments + self.hazmatContainers * 2 + self.nukedRads - self.radiationResistance))
                else
                    waitTime = math.max(math.max(15.0 - math.floor(self.nukedRads / 10) - self.ionedRads, 10), 79.0 - 0.60 * (self.radFragments + self.hazmatContainers * 2 + self.nukedRads + - self.radiationResistance))
                end
                self.ionedRads = 0

                -- Now we call the next function with this wait time
                if SHOW_RADIATION_MANAGER_LOGS then
                    print("RadManager | spawnRadsFunctio() - waiting " .. waitTime)
                end
                Timers:CreateTimer( waitTime, secondWaitFunction)

            else
                -- Rads are in safe level and not in penalty mode
                if SHOW_RADIATION_MANAGER_LOGS then
                    print("RadManager | Rads safe. Waiting 60 seconds to check again")
                end
                return 60 -- Makes this timer start again in 60 seconds
            end
        end

        -- Begin with the spawn rads
        Timers:CreateTimer( 0.0, spawnRadsFunction)
    end
end

-- Updates the radiation UI display based on radiation count
function RadiationManager:updateRadiationDisplay()
	CustomGameEventManager:Send_ServerToAllClients("display_rad", {radcount = self.radFragments ,radneeded = self.radSafeLimit, hazmats = self.hazmatContainers})
	
	-- TODO REMOVE
    --local count = 2
    --local pause = 5
    local names = {}
    table.insert(names, "Tyler")
    table.insert(names, "Hannah")
    table.insert(names, "Pabu")
    table.insert(names, "Xu Li")
	local indices = {}
	table.insert(indices, 4)
	table.insert(indices, 7)
	table.insert(indices, 1)
	table.insert(indices, 5)
	local healths = {}
	table.insert(healths, 400)
	table.insert(healths, 500)
	table.insert(healths, 111)
	table.insert(healths, 50)
	local manas = {}
	table.insert(manas, 100)
	table.insert(manas, 70)
	table.insert(manas, 11)
	table.insert(manas, 50)
	local classes = {}
	table.insert(classes, "covert_sniper")
	table.insert(classes, "cyborg")
	table.insert(classes, "field_medic")
	table.insert(classes, "demolitions")
	local ranks = {}
	table.insert(ranks, "legendary_hero")
	table.insert(ranks, "officerI")
	table.insert(ranks, "chief")
	table.insert(ranks, "deputy_chief")
	local tables = {}
	for i = 1,4 do
		local name = names[i]
		local index = indices[i]
		local health = healths[i]
		local mana = manas[i]
		local class = classes[i]
		local rank = ranks[i]
		table.insert(tables, {playerindex=index, playerhealth = health, playermana=mana, playername=name, playerclass=class, playerrank=rank})
	end
	CustomGameEventManager:Send_ServerToAllClients("squad_update", tables )
    --Timers:CreateTimer(10, function()
    --    if pause == 0 then
    --        count = count + 1
    --        if count > 4 then
    --          count = 1
    --        end
    --        pause = 5
    --    end
    --    pause = pause - 1
    --    local tables = {}
    --    for i = 1,count do
    --       local isDead = false
	
    --       local index = indices[i]
    --       local name = names[i]
    --       local rank = i
    --       local health = isDead and 0 or RandomInt(1, 1000)
    --       local mana = isDead and 0 or RandomInt(1, 1000)
    --       local maxMana = RandomInt(1,5) * 500 + 1000
   --        table.insert(tables, {playerindex=index, playerhealth = health, playermana=mana, playermaxmana=maxMana, playername=name, playerrank=rank})
	--	end
	--	CustomGameEventManager:Send_ServerToAllClients("squad_update", tables )
    --    return 3
    --end)
end

-- TODO
-- Updates the radiation damage aura (for heroes and civillians) based on the current radiation level
function RadiationManager:updateRadiationDamageAura(radLevel)
    if SHOW_RADIATION_MANAGER_LOGS then
        print("RadManager | Updating radiation damage aura for radLevel = " .. radLevel)
    end
    --self.radHeroDamageAuraUnit:FindAbilityByName("global_radiation_damage"):SetLevel(radLevel)
end

-- TODO
-- Updates the radiation buff aura (for zombies) based on the current radiation level
function RadiationManager:updateRadiationBuffAura(radLevel)
    if SHOW_RADIATION_MANAGER_LOGS then
        print("RadManager | TODO: update radiation buff for radLevel = " .. radLevel)
    end
end


-- TODO
-- Updates the radiation fog of the map based on the current radiation level.
function RadiationManager:updateRadiationFog(radLevel)
    if SHOW_RADIATION_MANAGER_LOGS then
        print("RadManager | TODO: update radiation fog for radLevel = " .. radLevel)
    end
end

-- TODO
-- Plays a sound based on the radLevel
function RadiationManager:playRadLevelChangedSound(radLevel)
    if SHOW_RADIATION_MANAGER_LOGS then
        print("RadManager | TODO: Play sound for radLevel = " .. radLevel)
    end
end

-- Should be called when a rad resist player has loaded in the game
function RadiationManager:addRadResistPlayer()
    if SHOW_RADIATION_MANAGER_LOGS then
        print("RadManager | Adding Rad Resist player")
    end
    self.radResistPlayers = self.radResistPlayers + 1

    self:calculateRadiationResistance(self.radResistPlayers)
end

-- Should be called when a rad resist player has left the game
function RadiationManager:removeRadResistPlayer()
    if SHOW_RADIATION_MANAGER_LOGS then
        print("RadManager | Removing Rad Resist player")
    end
    if self.radResistPlayers > 0 then
        self.radResistPlayers = self.radResistPlayers - 1

        self:calculateRadiationResistance(self.radResistPlayers)
    end
end

-- Calculates the radiation resist based on the player count
-- The first RR player will add RAD_RESIST_TRAIT_BONUS
-- The second will add RAD_RESIST_TRAIT_BONUS - 1
-- ..etc
-- A player will always contribute at least one resistance though
function RadiationManager:calculateRadiationResistance(radResistPlayersCount)
    self.radiationResistance = 0
    for i = 0,(radResistPlayersCount - 1) do
        if i < RAD_RESIST_TRAIT_BONUS then
            self.radiationResistance = self.radiationResistance + RAD_RESIST_TRAIT_BONUS - i
        else
            self.radiationResistance = self.radiationResistance + 1
        end
    end
    if SHOW_RADIATION_MANAGER_LOGS then
        print("RadManager | Setting Radiation Resistance = " .. self.radiationResistance)
    end
end

-- Applies a radiation resistance amount to the passed value based on the number
-- of RadResist players. Used for calculations relating to Nukes
function RadiationManager:getNukeRadiationResistance(double)
    local retval = double
    for i = 1, self.radResistPlayers do
        retval = retval * RAD_RESISTANCE_REDUCTION_VALUE
    end
    return retval
end
