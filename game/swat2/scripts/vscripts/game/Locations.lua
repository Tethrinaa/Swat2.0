-- Stores the locations in the game and has convenience methods for getting locations or points in locations
Locations = {}

LOCATIONS_RANDOM_POINT_OFFSET = 40 -- to try and prevent things spawning inside/on walls or something


function Locations:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- includes power_plants, abms, and warehouses
    self.all_rooms = nil
    self.power_plants = {}
    self.abms = {}
    self.warehouses = {} -- all rooms that are not power plants (ABMs are included!)

    self.bunkers = nil
    self.graveyard = nil -- there is only one graveyard region
    self.park_regions = nil -- there are multiple park regions
    self.lab = nil
    self.ground_zero = nil

    -- Randomize the rooms
    self.all_rooms = Entities:FindByName(nil, "room_spawn"):GetChildren()
    self:randomizeRegions(self.all_rooms)
    for i = 1,#self.all_rooms do
        self.warehouses[i] = self.all_rooms[i]
    end

    -- Graveyard
    self.graveyard = Entities:FindByName(nil, "graveyard_spawn")

    -- Park
    self.park_regions = Entities:FindByName(nil, "park_spawn"):GetChildren()
    self:randomizeRegions(self.park_regions)

    -- Bunkers
    self.bunkers = Entities:FindByName(nil, "bunker_spawn"):GetChildren()
    self:randomizeRegions(self.bunkers)

    -- Lab
    self.lab = Entities:FindByName(nil, "lab_spawn")

    -- Ground Zero
    self.ground_zero = Entities:FindByName(nil, "ground_zero_spawn")

    return o
end

-- We'll randomize the order of the regions in each of the groups
-- This is useful for anyone who wants to get a random subset of distinct regions in a group (then can just grab a contiguous series and it will be random)
function Locations:randomizeRegions(regions)
    for i = 1,#regions do
        local randNum = RandomInt(1,#regions)
        local temp = regions[randNum]
        regions[randNum] = regions[i]
        regions[i] = temp
    end
end

--function Locations:createPowerPlants(number)
    --for i = 1,number do
        --self.
--end

function GetRandomPointInRegion(region)
    local bounds = region:GetBounds()
    return region:GetAbsOrigin() + Vector(RandomFloat(bounds.Mins.x, bounds.Maxs.x - LOCATIONS_RANDOM_POINT_OFFSET), RandomFloat(bounds.Mins.y, bounds.Maxs.y - LOCATIONS_RANDOM_POINT_OFFSET), 0)
end

function GetRandomPointInRegionGroup(region_group)
    local region = region_group[RandomInt(1, #region_group)]
    local bounds = region:GetBounds()
    return region:GetAbsOrigin() + Vector(RandomFloat(bounds.Mins.x, bounds.Maxs.x - LOCATIONS_RANDOM_POINT_OFFSET), RandomFloat(bounds.Mins.y, bounds.Maxs.y - LOCATIONS_RANDOM_POINT_OFFSET), 0)
end

-- Returns a random warehouse entity (warehouses do not include power plants)
function GetRandomWarehouse()
    return Global_Locations.warehouses[RandomInt(1, #Global_Locations.warehouses)]
end

-- Returns a random point in a warehouse region (warehouses do not include power plants)
function GetRandomPointInWarehouse()
    return GetRandomPointInRegionGroup(Global_Locations.warehouses)
end

-- Returns the graveyard region
function GetGraveyard()
    return Global_Locations.graveyard
end

-- Returns a random vector of a location in the graveyard
function GetRandomPointInGraveyard()
    return GetRandomPointInRegion(Global_Locations.graveyard)
end

-- Returns a random park region
function GetRandomParkRegion()
    return Global_Locations.park_regions[RandomInt(1, #Global_Locations.park_regions)]
end

-- Returns a random point in the park
-- TODO: This is currently a bit biased as we park regions have different sizes. Fix this
function GetRandomPointInPark()
    return GetRandomPointInRegionGroup(Global_Locations.park_regions)
end

-- Returns the lab region
function GetLab()
    return Global_Locations.lab
end

-- Returns a random vector of a location in the lab
function GetRandomPointInLab()
    return GetRandomPointInRegion(Global_Locations.lab)
end

-- Returns the lab region
function GetGroundZero()
    return Global_Locations.ground_zero
end

-- Returns a random vector of a location in the lab
function GetRandomPointInGroundZero()
    return GetRandomPointInRegion(Global_Locations.ground_zero)
end
