-- Stores the locations in the game and has convenience methods for getting locations or points in locations
Locations = {}

SHOW_LOCATIONS_LOGS = SHOW_GAME_SYSTEM_LOGS

LOCATIONS_RANDOM_POINT_OFFSET = 80 -- to try and prevent things spawning inside/on walls or something

function Locations:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- includes power_plants, abms, and warehouses
    self.all_rooms = nil
    self.warehouses = {} -- all rooms that are not power plants or ABMs (crate rooms, ...etc are included!)
                         -- These rooms do not prevent XP and enemies can spawn in them

    -- Special rooms
    -- Generated once difficulty is set (as the number of these depends on difficulty)
    self.power_plants = {} -- NOTE: Not included in self.warehouses (as nothing spawns there)
    self.abms = {} -- NOTE: Not included in self.warehouses (as nothing spawns there)
    self.atme_rooms = {}
    self.clothing_rooms = {} -- "fake" ATME room
    self.chemical_plants = {} -- Brown Crate Room (spawns drugs and stuff)
    self.armories = {} -- Silver Crate Room (spawns weapons and armor)
    self.tech_centers = {} -- Silver Crate Room (spawns other passive items)
    self.cybernetic_facilities = {} -- Brown Crate Room (spawns permanent upgrades)
    self.empty_warehouses = {} -- A warehouse that has nothing


    self.bunkers = nil
    self.graveyard = nil -- there is only one graveyard region
    self.park_regions = nil -- there are multiple park regions
    self.lab = nil
    self.ground_zero = nil

    -- Randomize the rooms
    self.all_rooms = Entities:FindByName(nil, "room_spawn"):GetChildren()
    -- We'll randomize the order of the regions in each of the groups
    -- This is useful for anyone who wants to get a random subset of distinct regions in a group (then can just grab a contiguous series and it will be random)
    RandomizeList(self.all_rooms)

    for i = 1,#self.all_rooms do
        self.warehouses[i] = self.all_rooms[i]
    end

    -- Graveyard
    self.graveyard = Entities:FindByName(nil, "graveyard_spawn")

    -- Park
    self.park_regions = Entities:FindByName(nil, "park_spawn"):GetChildren()
    RandomizeList(self.park_regions)

    -- Bunkers
    self.bunkers = Entities:FindByName(nil, "bunker_spawn"):GetChildren()
    RandomizeList(self.bunkers)

    -- Lab
    self.lab = Entities:FindByName(nil, "lab_spawn")

    -- Ground Zero
    self.ground_zero = Entities:FindByName(nil, "ground_zero_spawn")

    return o
end

-- Needs to be called to initialize the global locations
-- Call after Entities exists!
function initializeGlobalLocations()
    Locations = Locations:new()
end

-- Called once difficulty is set
-- This picks out all of the special buildings in the game
function Locations:createRooms()
    local diff = g_GameManager.difficultyValue
    local survival = g_GameManager.survivalValue
    -- A modifier based on player count ([0-3 == 0, 4-6 == 1, 7=9 == 2])
    local playerCountModifier = math.floor((g_PlayerManager.playerCount - 1) / 3)

    -- We'll use these variables to pick out rooms
    -- We obviously don't want to assign a room more than one type
    -- so, we'll keep an index and count of number of that type (relative to the current index)
    local i = #self.all_rooms -- the index of the current room
    local numOfType = 0 -- The number of rooms of a specific type

    -- PowerPlants (6min, 6max)
    numOfType = i - 6
    while i > numOfType do
        table.insert(self.power_plants, self.all_rooms[i])

        -- Don't allow things to spawn in power plants
        table.remove(self.warehouses, i)

        i = i - 1
    end

    -- ABMs (4min, 6max)
    numOfType = i - RandomInt(4, 6 - (3 - diff))
    while i > numOfType do
        table.insert(self.abms, self.all_rooms[i])

        -- Don't allow enemies to spawn in ABMs
        table.remove(self.warehouses, i)

        i = i - 1
    end

    -- atme (1min, 2max [only Insane+, Survival])
    numOfType = i - math.max(1, RandomInt(1, 3 - diff + (2 * survival)))
    while i > numOfType do
        table.insert(self.atme_rooms, self.all_rooms[i])
        i = i - 1
    end

    -- clothing (1min, 1max)
    numOfType = i - 1
    while i > numOfType do
        table.insert(self.clothing_rooms, self.all_rooms[i])
        i = i - 1
    end

    -- chemical plants (2-3min, 3-5max)
    numOfType = i - RandomInt(3 - survival, 3 + playerCountModifier)
    while i > numOfType do
        table.insert(self.chemical_plants, self.all_rooms[i])
        i = i - 1
    end

    -- armories (1-3min, 6max)
    numOfType = i - RandomInt(1 + playerCountModifier, 6 - diff)
    while i > numOfType do
        table.insert(self.armories, self.all_rooms[i])
        i = i - 1
    end

    -- technology centers (1-2min, 3max)
    numOfType = i - RandomInt(1 + ((playerCountModifier > 0) and 1 or 0), 3)
    while i > numOfType do
        table.insert(self.tech_centers, self.all_rooms[i])
        i = i - 1
    end

    -- cybernetic facilities (1-2min, 4max)
    numOfType = i - RandomInt(2 - survival, 5 - diff)
    while i > numOfType do
        table.insert(self.cybernetic_facilities, self.all_rooms[i])
        i = i - 1
    end

    -- empty warehouses (rest)
    while i > 0 do
        table.insert(self.empty_warehouses, self.all_rooms[i])
        i = i - 1
    end

    if SHOW_LOCATIONS_LOGS then
        print("Locations | Generated Building Types:")
        print("Locations | Power Plants       : " .. #self.power_plants)
        print("Locations | Black Markets      : " .. #self.abms)
        print("Locations | ATME Rooms         : " .. #self.atme_rooms)
        print("Locations | Clothing Room      : " .. #self.clothing_rooms)
        print("Locations | Chemical Plants    : " .. #self.chemical_plants)
        print("Locations | Armories           : " .. #self.armories)
        print("Locations | Tech Centers       : " .. #self.tech_centers)
        print("Locations | Cybernetics Facils : " .. #self.cybernetic_facilities)
        print("Locations | Empty Warehouses   : " .. #self.empty_warehouses)
    end
end

-- Returns true or false on whether the passed in region is a power plant
function Locations:isPowerPlant(region)
    local isPowerPlant = false
    for _,powerplant in pairs(self.power_plants) do
        if powerplant == region then
            isPowerPlant = true
            break
        end
    end
    return isPowerPlant
end

-- Returns true or false on whether the passed in region is a black market
function Locations:isBlackMark(region)
    local isAbm = false
    for _,abm in pairs(self.abms) do
        if abm == region then
            isAbm = true
            break
        end
    end
    return isAbm
end

function GetCenterInRegion(region)
    return region:GetCenter()
end

function GetRandomPointInRegion(region)
    local bounds = region:GetBounds()
    return region:GetOrigin() + Vector(RandomFloat(bounds.Mins.x + LOCATIONS_RANDOM_POINT_OFFSET, bounds.Maxs.x - LOCATIONS_RANDOM_POINT_OFFSET), RandomFloat(bounds.Mins.y + LOCATIONS_RANDOM_POINT_OFFSET, bounds.Maxs.y - LOCATIONS_RANDOM_POINT_OFFSET), 0)
end

function GetRandomPointInRegionGroup(region_group)
    local region = region_group[RandomInt(1, #region_group)]
    local bounds = region:GetBounds()
    return region:GetOrigin() + Vector(RandomFloat(bounds.Mins.x + LOCATIONS_RANDOM_POINT_OFFSET, bounds.Maxs.x - LOCATIONS_RANDOM_POINT_OFFSET), RandomFloat(bounds.Mins.y + LOCATIONS_RANDOM_POINT_OFFSET, bounds.Maxs.y - LOCATIONS_RANDOM_POINT_OFFSET), 0)
end

-- Returns a random warehouse entity (warehouses do not include power plants)
function GetRandomWarehouse()
    return Locations.warehouses[RandomInt(1, #Locations.warehouses)]
end

-- Returns a random point in a warehouse region (warehouses do not include power plants)
function GetRandomPointInWarehouse()
    return GetRandomPointInRegionGroup(Locations.warehouses)
end

-- Returns the graveyard region
function GetGraveyard()
    return Locations.graveyard
end

-- Returns a random vector of a location in the graveyard
function GetRandomPointInGraveyard()
    return GetRandomPointInRegion(Locations.graveyard)
end

-- Returns a random park region
function GetRandomParkRegion()
    return Locations.park_regions[RandomInt(1, #Locations.park_regions)]
end

-- Returns a random point in the park
-- TODO: This is currently a bit biased as we park regions have different sizes. Fix this
function GetRandomPointInPark()
    return GetRandomPointInRegionGroup(Locations.park_regions)
end

-- Returns the lab region
function GetLab()
    return Locations.lab
end

-- Returns a random vector of a location in the lab
function GetRandomPointInLab()
    return GetRandomPointInRegion(Locations.lab)
end

-- Returns the lab region
function GetGroundZero()
    return Locations.ground_zero
end

-- Returns a random vector of a location in the lab
function GetRandomPointInGroundZero()
    return GetRandomPointInRegion(Locations.ground_zero)
end
