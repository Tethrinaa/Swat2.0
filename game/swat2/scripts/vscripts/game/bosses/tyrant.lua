-- Stores information relating to tyrants

Tyrant = {}


function Tyrant:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.chanceToSpawn = 0

    return o
end

-- Generic boss function for actually spawning the boss
-- Returns the created boss unit
function Tyrant:spawnBoss()
    print("Tyrant | TODO: Spawn Tyrant")
    -- TODO
end
