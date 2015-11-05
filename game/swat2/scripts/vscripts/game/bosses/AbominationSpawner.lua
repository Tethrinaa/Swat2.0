-- Stores information relating to abominations and generic boss spawning information

SHOW_ABOMINATION_LOGS = SHOW_BOSS_LOGS

AbominationSpawner = {}


function AbominationSpawner:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    return o
end

-- Generic boss function that will be called to see if we should spawn this boss
-- Should return a boolean of True to spawn it
function AbominationSpawner:rollToSpawn()
    -- Aboms always succeed
    return true
end

-- Generic boss function for actually spawning the boss
-- Returns the created boss unit
function AbominationSpawner:spawnBoss()
    if SHOW_ABOMINATION_LOGS then
        print("AbominationSpawner | Spawning abomination")
    end
    g_EnemySpawner.abomsCurrentlyAlive = g_EnemySpawner.abomsCurrentlyAlive + 1

    local warehouse = GetRandomWarehouse()
    local boss = CreateUnitByName( "npc_dota_creature_basic_abomination", GetCenterInRegion(warehouse), true, nil, nil, DOTA_TEAM_BADGUYS )

    -- TODO: Add more abilities and abomination types
    boss:SetBaseMoveSpeed(g_EnemyUpgrades:calculateMovespeed(boss, 0))

    -- Spawn a group of enemies to go with the boss
    self:spawnAbomMinionGroup(warehouse)

    -- Tell the boss where to go
    -- Issueing an order to a unit immediately after it spawns seems to not consistently work
    -- so we'll wait a second before telling the group where to go
    Timers:CreateTimer(1.0, function()
        g_EnemyCommander:doMobAction(boss, nil)
    end)

    -- TODO - Fix boss display message
    Notifications:TopToAll({text="Satellite recon just spotted a freakishly large creature!", duration=8, style={color="yellow"}})

    return boss
end

-- Abomination spawns with a few units of his own
function AbominationSpawner:spawnAbomMinionGroup(warehouse)
    local numberOfMinions = RandomInt(1, math.max(Round(g_EnemyUpgrades.minionUber / 10.0), 1))
    local warehouseCenter = warehouse:GetAbsOrigin()
    local spawnedUnits = {}
    for i = 1, numberOfMinions do
        local j = RandomInt(0, 9)
        local position = warehouseCenter + RandomSizedVector(270)
        local unit = nil
        if j < 1 then
            unit = g_EnemySpawner:spawnEnemy(EnemySpawner.ENEMY_CODE_BEAST, position, 0, true)
        elseif j < 2 then
            unit = g_EnemySpawner:spawnEnemy(EnemySpawner.ENEMY_CODE_GROTESQUE, position, 0, true)
        elseif j < 4 then
            unit = g_EnemySpawner:spawnEnemy(EnemySpawner.ENEMY_CODE_DOG, position, 0, true)
        else
            unit = g_EnemySpawner:spawnEnemy(EnemySpawner.ENEMY_CODE_ZOMBIE, position, 0, true)
        end
        if unit ~= nil then
            table.insert(spawnedUnits, unit)
        end
    end

    -- Tell the group where to go
    -- Issueing an order to a unit immediately after it spawns seems to not consistently work
    -- so we'll wait a second before telling the group where to go
    Timers:CreateTimer(1.0, function()
        for _,unit in pairs(spawnedUnits) do
            g_EnemyCommander:doMobAction(unit, nil)
        end
    end)

end
