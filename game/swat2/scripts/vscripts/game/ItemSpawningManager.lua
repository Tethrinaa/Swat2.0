-- This file is responsible for spawning the crates, exo suit, and other items that populate the map
-- as well as item drops when a crate it destroyed

-- The way the current system of crates works is we will figure out all of the items immediately
-- and attach an onDeathFunction to each crate that does the correct thing

-- The rate the clock should move during day and night respectively
ItemSpawningManager = {}

SHOW_ITEM_SPAWNING_LOGS = SHOW_GAME_SYSTEM_LOGS

ItemSpawningManager.CRATE_UNIT_NAME = "game_crate"

-- Models that can be used for basic crates
-- TODO: CACHE THESE
ItemSpawningManager.CRATE_MODELS_BASIC = {
    {model= "models/props_debris/barrel002.vmdl", scale=1.4}
    --, {model= "models/props_gameplay/red_box.vmdl", scale=2.0}
}

-- Models used for advanced crates
ItemSpawningManager.CRATE_MODELS_ADVANCED = {
    {model= "models/heroes/techies/fx_techies_remotebomb.vmdl", scale=1.8}
}

function ItemSpawningManager:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- Store the last atme so we don't respawn it
    self.lastAtme = nil

    -- Helps prevent too many of one type of item spawning
    self.itemBiasKevlarCombat = 15 -- Kevlar vs Combat
    self.itemBiasAdvancedCombats = 10 -- Combat 2 vs Combat 3
    self.itemBiasAdvancedRapids = 12 -- Rapid 2 vs Rapid 3
    self.itemBiasAdvancedStims = 12 -- Refined Stim vs Ultra Stim
    self.itemBiasCells = 8 -- Cell vs Duo Cell
    self.itemBiasVestRapid = 0 -- Vest vs Rapid

    return o
end

-- Uses the locations defined in Locations to spawn crates around the map
function ItemSpawningManager:spawnMapCrates()
    self:spawnCrate(Locations.lab, ItemSpawningManager.CRATE_MODELS_BASIC, ItemSpawningManager.createSpawnItemFunction("item_duo_cell"), 0, 1)
    self:spawnCrate(Locations.lab, ItemSpawningManager.CRATE_MODELS_BASIC, ItemSpawningManager.createSpawnItemFunction("item_duo_cell"), 0, 1)
    self:spawnCrate(Locations.lab, ItemSpawningManager.CRATE_MODELS_BASIC, ItemSpawningManager.createSpawnItemFunction("item_duo_cell"), 0, 1)

    -- Modifies the chance of how many crates will spawn
    local playerCountModifier = math.floor((g_PlayerManager.playerCount - 1) / 3)

    -- A.T.M.E Crates
    for _,room in pairs(Locations.atme_rooms) do
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getAtmeCrate(), 0, 1) -- Guarenteed ATME crate
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getAdvancedGear(), 1, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getAdvancedGear(), 3 - playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getCyberneticImplant(), 1, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getCyberneticImplant(), 1, 1)
    end

    -- Clothing (Fancy!)
    for _,room in pairs(Locations.clothing_rooms) do
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getFancyClothing(), 0, 1) -- Guarenteed ATME crate
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getAdvancedGear(), 1, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getAdvancedGear(), 3 - playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getCyberneticImplant(), 1, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getCyberneticImplant(), 1, 1)
    end

    -- Chemical Plants
    for _,room in pairs(Locations.chemical_plants) do
        -- Guarenteed
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getBasicConsumable(), 0, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getTraitItemConsumable(), 0, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getBasicGear(), 0, 1)

        -- Random (independent of player count)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getBasicConsumable(), 3, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getBasicConsumable(), 4, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getBasicGear(), 1, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getBasicGear(), 2, 1)

        -- Player Adjusted
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getBasicConsumable(), 2 - playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getBasicConsumable(), 3 - playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getBasicConsumable(), 4 - playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getBasicGear(), 3 - playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getBasicGear(), 5 - playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getBasicGear(), 5 - playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getTraitItemConsumable(), 2 - playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getTraitItemConsumable(), 3 - playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getTraitItemConsumable(), 4 - playerCountModifier, 1)
    end

    -- Armories
    for _,room in pairs(Locations.armories) do
        -- Guarenteed
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getCyberneticImplant(), 0, 1)

        -- Random (independent of player count)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getCyberneticImplant(), 4, 4)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getCyberneticImplant(), 4, 4)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getAdvancedGear(), 1, 1)

        -- Player Adjusted
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getAdvancedGear(), 3 - playerCountModifier, 1)
        self:spawnItem(room, "item_ammo_upgrade", 5 - playerCountModifier, 3)
        self:spawnItem(room, "item_ammo_upgrade", 5 - (2 * playerCountModifier), 3)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getBasicGear(), 2 - playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getBasicGear(), 3 - playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getBasicGear(), 5 - playerCountModifier, 4)

        if g_PlayerManager.playerCount > 3 then
            self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getBasicGear(), 2 - playerCountModifier, 1)
            self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getBasicGear(), 3 - playerCountModifier, 2)
            self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getBasicGear(), 89 - (40 * playerCountModifier), 10)
            self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getBasicGear(), 89 - (40 * playerCountModifier), 10)
            self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getAdvancedGear(), 89 - (40 * playerCountModifier), 10)
        end
    end

    -- Technology Centers
    for _,room in pairs(Locations.tech_centers) do
        -- Guarenteed
        self:spawnItem(room, "item_ammo_upgrade", 0, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getAdvancedGear(), 0, 1)

        -- Random (independent of player count)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getAdvancedConsumable(), 1, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getAdvancedConsumable(), 2, 1)

        -- Player Adjusted
        self:spawnItem(room, "item_ammo_upgrade", 2 - playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getAdvancedConsumable(), 4 - playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getAdvancedGear(), 2 - playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getAdvancedGear(), 4 - playerCountModifier, 3)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getAdvancedGear(), 5 - playerCountModifier, 3)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getAdvancedGear(), 7 - playerCountModifier, 3)

        if g_PlayerManager.playerCount > 3 then
            self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_ADVANCED, self:getAdvancedGear(), 2 - playerCountModifier, 1)
        end
    end

    -- Cybernetic Facilities
    for _,room in pairs(Locations.cybernetic_facilities) do
        -- Guarenteed
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getCyberneticImplant(), 0, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getCyberneticImplant(), 0, 1)

        -- Player Adjusted
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getCyberneticImplant(), 0 + playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getCyberneticImplant(), 0 + playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getCyberneticImplant(), 0 + playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getCyberneticImplant(), 0 + playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getCyberneticImplant(), 1 + playerCountModifier, 1)
        self:spawnCrate(room, ItemSpawningManager.CRATE_MODELS_BASIC, self:getCyberneticImplant(), 1 + playerCountModifier, 1)
    end
end

-- Rolls to spawn a Crate at the region specified. On its onDeathFunction will be called.
-- @param region | The region to spawn the crate in (will pick a random location within it)
-- @param onDeathFunction | Will be called when the crate dies
-- @param models | A list of tables in the form:
--          {
--              "model": "<string of model>"
--              "scale": <double representing the scale of the model>
--          }
--          | One random "model info" table will be used as the model for the crate
-- @param chanceRange | The range of values available for the roll
-- @param chance | The value that must be rolled UNDER for a crate to spawn
function ItemSpawningManager:spawnCrate(region, models, onDeathFunction, chanceRange, chanceHit)
    -- Roll for the crate
    if RandomInt(0, chanceRange) < chanceHit then
        local position = GetRandomPointInRegion(region)
        local unit = CreateUnitByName( ItemSpawningManager.CRATE_UNIT_NAME, position, true, nil, nil, DOTA_TEAM_BADGUYS )

        -- Set a model
        local modelInfo = models[RandomInt(1,#models)]
        unit:SetOriginalModel(modelInfo.model)
        unit:SetModelScale(modelInfo.scale)

        unit:SetForwardVector(RandomVector(1.0))

        unit.onDeathFunction = onDeathFunction
    end
end

-- Rolls to see if it should spawn an item in the region
function ItemSpawningManager:spawnItem(region, itemName, chanceRange, chanceHit)
    -- TODO: REMOVE THIS RETURN (ONLY HERE BECAUSE AMMO NOT IN)
    if true then
        return
    end

    -- Roll for the crate
    if RandomInt(0, chanceRange) < chanceHit then
        local position = GetRandomPointInRegion(region)
        local item = CreateItem(itemname, nil, nil)
        CreateItemOnPositionSync(position, item)
    end
end

------------------------
-- onDeathFunctions for crates
-- These are functions generally used by the Random Item Methods that are attached to the crates
-----------------------

-- Returns an onDeath function that will spawn the provided item
function ItemSpawningManager.createSpawnItemFunction(itemname)
    return function(crate, killerEntity, killerAbility)
        print("ItemSpawningManager | DEBUG - Spawning Item: " .. itemname)
        local item = CreateItem(itemname, nil, nil)
        CreateItemOnPositionSync(crate:GetAbsOrigin(), item)
    end
end

-- Returns an onDeath function that will spawn multiple drugs (itemname) at the location
-- (Specifically drugs because of the number of items spawned is specific to drugs)
function ItemSpawningManager.createSpawnMultiDrugsFunction(itemname)
    return function(crate, killerEntity, killerAbility)
        for i = 1,RandomInt(1, math.max(1, 4 - g_GameManager.survivalValue)) do
            local item = CreateItem(itemname, nil, nil)
            CreateItemOnPositionSync(crate:GetAbsOrigin() + RandomSizedVector(85), item)
        end
    end
end

-- Returns an onDeath function that will spawn a pack of batteries
-- (The number of charges for the battery is dependent on nightmare/ext, so we have to determine this later than at creation as that difficulty may not be set)
function ItemSpawningManager.createSpawnBatteriesFunction()
    return function(crate, killerEntity, killerAbility)
        local item = CreateItem("item_battery", nil, nil)
        CreateItemOnPositionSync(crate:GetAbsOrigin(), "item_battery")
        -- Charges based on difficulty
        if g_GameManager.nightmareValue > 1 then
            -- Extinction
            item:SetCurrentCharges(1)
        else
            item:SetCurrentCharges(3 - g_GameManager.nightmareOrSurvivalValue)
        end
    end
end

-- Used as an onDeathFunction for crates to spawn harmless rats at the location
function ItemSpawningManager.spawnCrateRats(crate, killerEntity, killerAbility)
    for i = 1,RandomInt(1,3) do
        g_EnemySpawner.ratSpawner:createRat(crate:GetAbsOrigin())
    end
end

-- Used as an onDeathFunction for crates to spawn a malfunctioning repair droid that attacks the killerEntity
function ItemSpawningManager.spawnMalfunctioningDroid(crate, killerEntity, killerAbility)
    -- TODO
end

-- Used as an onDeathFunction for crates to spawn a working repair droid
function ItemSpawningManager.spawnWorkingDroid(crate, killerEntity, killerAbility)
    -- TODO
end

------------------------
-- Random Item Methods
-- These item methods will return a function that should be run when the crate it destroyed
-----------------------

function ItemSpawningManager:getBasicConsumable()
    local rand = RandomInt(0, 99)
    if rand < 24 then
        -- Bandage 24%
    elseif rand < 49 then
        -- Battery 25%
        return ItemSpawningManager.createSpawnBatteriesFunction
    elseif rand < 63 then
        -- Claymore 14%
    elseif rand < 73 then
        -- Mentat 10%
    elseif rand < 83 then
        -- Buffout 10%
    elseif rand < 93 then
        -- Speed 10%
    elseif rand < 98 then
        -- Ammo Upgrade  5%
    else
        -- Rats 2%
        return ItemSpawningManager.spawnCrateRats
    end
end

function ItemSpawningManager:getAdvancedConsumable()
    local rand = RandomInt(0, 99)
    if rand < 22 then
        -- Stim Pack 22%
    elseif rand < 37 then
        -- Battery 15%
    elseif rand < 59 + self.itemBiasAdvancedStims then
        -- Refined Stim Pack 22%

        -- Update the item bias for refined
        self.itemBiasAdvancedStims = self.itemBiasAdvancedStims - 8
        if self.itemBiasAdvancedStims < -12 then
            self.itemBiasAdvancedStims = -12
        end
    elseif rand < 81 then
        -- Ultra Stim Pack 22%
    elseif rand < 84 then
        -- Flare Gun  3%
    elseif rand < 94 then
        -- Revive 10%
    elseif rand < 99 then
        -- Ammo Upgrade  5%
    else
        -- Rats 1%
        return ItemSpawningManager.spawnCrateRats()
    end
end

function ItemSpawningManager:getTraitItemConsumable()
    local rand = RandomInt(0, 99)
    if rand < 20 then
        --Bandage 20%
    elseif rand < 45 then
        --Mentat 25%
    elseif rand < 65 then
        --Buffout 20%
    elseif rand < 95 then
        --Speed 30%
    else
        --Revive 5%
    end
end

function ItemSpawningManager:getBasicGear()
    -- TODO: These have a chance to spawn Design Plans. (See: RedSpawnDesignPlans)
    local rand = RandomInt(0, 99)

    if rand < (10 + self.itemBiasKevlarCombat) then
        -- Kevlar Vest 10% (-bias)

        -- Update the item bias for rapid reloads
        self.itemBiasKevlarCombat = self.itemBiasKevlarCombat - 10
        if self.itemBiasKevlarCombat < -5 then
            self.itemBiasKevlarCombat = -5
        end
    elseif rand < (25+self.itemBiasVestRapid) then
        -- Combat Vest 15% (+bias)

        if self.itemBiasVestRapid > 0 then
            self.itemBiasVestRapid = 0
        else
            self.itemBiasVestRapid = -8
        end
    elseif rand < 37 then
        -- Rapid-Reload 12%

        self.itemBiasVestRapid = 11
    elseif rand < 70 then
        -- Generator 33%
    elseif rand < (90+self.itemBiasCells) then
        -- Storage Cell 20% (-bias)

        -- Update the item bias for rapid reloads
        self.itemBiasCells = self.itemBiasCells - 4
        if self.itemBiasCells < -6 then
            self.itemBiasCells = -6
        end
    elseif rand < 98 then
        -- Storage Duo-Cell  8% (+bias)
        return self:createSpawnItemFunction("item_duo_cell")
    else
        -- Malfunction Droid 2%
        return ItemSpawningManager.spawnMalfunctioningDroid
    end
end

function ItemSpawningManager:getAdvancedGear()
    -- TODO: These have a chance to spawn Design Plans. (See: RedSpawnDesignPlans)
    local rand = RandomInt(0, 99)

    if rand < 25 then
        --  Storage Duo-Cell 25%
        return self:createSpawnItemFunction("item_duo_cell")
    elseif rand < (40+self.itemBiasAdvancedCombats) then
        --  Combat Vest MkII 15% (-bias)

        -- Update the item bias for combats
        self.itemBiasAdvancedCombats = self.itemBiasAdvancedCombats - 9
        if self.itemBiasAdvancedCombats < -3 then
            self.itemBiasAdvancedCombats = -3
        end
    elseif rand < 50 then
        -- Combat Vest MkIII 10% (+bis)
    elseif rand < (62+self.itemBiasAdvancedRapids) then
        -- Rapid-Reload MkII 12% (-bias)

        -- Update the item bias for rapid reloads
        self.itemBiasAdvancedRapids = self.itemBiasAdvancedRapids - 8
        if self.itemBiasAdvancedRapids < -2 then
            self.itemBiasAdvancedRapids = -2
        end
    elseif rand < 74 then
        -- Rapid-Reload MkIII 12% (+bias)
    elseif rand < 99 then
        -- Generator+ 25%
    else
        -- Malfunction Droid 1%
        return ItemSpawningManager.spawnMalfunctioningDroid
    end
end

function ItemSpawningManager:getCyberneticImplant()
    local rand = RandomInt(0, 99)
    if rand < 49 then
        --Vitality 49%
        -- More than one of these spawns
        return function(crate, killerEntity, killerAbility)
            for i = 1,RandomInt(1, 2 + g_GameManager.nightmareValue) do
                local item = CreateItem(itemname, nil, nil)
                CreateItemOnPositionSync(crate:GetAbsOrigin() + RandomSizedVector(85), item)
            end
        end
    elseif rand < 79 then
        --Agility 30%
    elseif rand < 99 then
        --Intelligence 20%
    else
        --Health 1%
    end
end

function ItemSpawningManager:getFancyClothing()
    local rand = RandomInt(0, 99)
    if rand < 99 or g_GameManager.nightmareValue > 1 then
        --Clothing 99% (100% on Extinction)
    else
        --Repair Droid 1%
    end
end

function ItemSpawningManager:getAtmeCrate()
    local rand = RandomInt(0, 99)
    local itemName = nil
    if rand < 11 then
        -- SuperCell 11%
    elseif rand < 21 then
        -- Cyber-Net 10%
    elseif rand < 32 then
        -- Zeal-Mag. 11%
    elseif rand < 42 then
        -- Drug Rep. 10%
    elseif rand < 53 then
        -- Aegis Vest 11%
    elseif rand < 63 then
        -- Psycho Stim 10%
    elseif rand < 70 then
        -- Temporal Avatar 7%
    elseif rand < 80 then
        -- MegaGen 10%
    elseif rand < 90 then
        -- Energy Field 10%
    else
        -- Solar Battery 10%
    end

    if self.lastAtme and self.lastAtme == itemName then
        -- Same one rolled. Pick a new one
        if self.lastAtme == "item_atme_avatar" then
            -- Pick one of the energy ones
            rand = RandomInt(0, 2)
            if rand == 0 then
                -- MegaGen 10%
            elseif rand == 1 then
                -- Energy Field 10%
            else
                -- Solar Battery 10%
            end
        else
            -- Pick Avatar
        end
    end

    self.lastAtme = itemName

    -- Some atmes have extra things happen when they spawn
    if itemName == "item_atme_cybernet" then
        -- Cybernet spawns with multiple int implants
        return function(crate, killerEntity, killerAbility)
            for i = 1,math.floor(g_PlayerManager.playerCount / 2) do
                local item = CreateItem("item_int_implant", nil, nil)
                CreateItemOnPositionSync(crate:GetAbsOrigin() + RandomSizedVector(85), item)
            end

            local item = CreateItem("item_atme_cybernet", nil, nil)
            CreateItemOnPositionSync(crate:GetAbsOrigin(), item)
        end
    elseif itemName == "item_atme_drug_replicator" then
        -- TODO: Increase max pouch size for everyone
        return ItemSpawningManager.createSpawnItemFunction(itemName)
    else
        -- The rest of the items just spawn normally
        return ItemSpawningManager.createSpawnItemFunction(itemName)
    end
end
