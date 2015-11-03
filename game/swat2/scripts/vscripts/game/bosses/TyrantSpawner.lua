-- Stores information relating to tyrants

SHOW_TYRANT_LOGS = SHOW_BOSS_LOGS

TyrantSpawner = {}


function TyrantSpawner:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.chanceToSpawn = 0

    return o
end

-- Generic boss function for actually spawning the boss
-- Returns the created boss unit
function TyrantSpawner:spawnBoss()
    if SHOW_TYRANT_LOGS then
        print("TyrantSpawner | TODO: Spawn Tyrant")
    end
    -- TODO
end
