-- Stores information relating to horrors and generic boss spawning information

Horror = {}


function Horror:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.chanceToSpawn = 0

    return o
end

-- Generic boss function for getting chance to spawn this boss
-- Should return a number. Higher numbers are *lower* chance for this boss
function Horror:rollToSpawn()
    if (g_RadiationManager.horrorRads == 0) and (RandomInt(0 - g_EnemySpawner.abomsCurrentlyAlive, 10 - (2 * math.max(0, g_RadiationManager.effectiveRadiation) + self.chanceToSpawn)) < 1) then
        return true
    else
        -- Increase our chance to spawn next time
        self.chanceToSpawn = (self.chanceToSpawn + 1) / 2
        return false
    end
end

-- Generic boss function for actually spawning the boss
-- Returns the created boss unit
function Horror:spawnBoss()
    print("Horror | TODO: Spawn Horror")
    -- TODO
end
