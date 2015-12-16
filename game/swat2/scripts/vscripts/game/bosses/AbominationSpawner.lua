-- Stores information relating to abominations and generic boss spawning information

SHOW_ABOMINATION_LOGS = SHOW_BOSS_LOGS

AbominationSpawner = {}

AbominationSpawner.ABOMINATION_UNIT_NAME = "enemy_boss_abomination"

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
    local boss = CreateUnitByName( AbominationSpawner.ABOMINATION_UNIT_NAME, GetCenterInRegion(warehouse), true, nil, nil, DOTA_TEAM_BADGUYS )

    -- Apply upgrades
    onUberChangedAbom(boss, g_EnemyUpgrades.currentBossLevel, g_EnemyUpgrades.currentBossHealthBonus)
    -- Register for uber changes
    boss.onUberChangesBoss = onUberChangedAbom

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
            unit = g_EnemySpawner:spawnEnemy(g_EnemySpawner.beastSpawner, EnemySpawner.beastSpawner.createNormal, position, true)
        elseif j < 2 then
            unit = g_EnemySpawner:spawnEnemy(g_EnemySpawner.grotesqueSpawner, EnemySpawner.grotesqueSpawner.createNormal, position, true)
        elseif j < 4 then
            unit = g_EnemySpawner:spawnEnemy(g_EnemySpawner.dogSpawner, EnemySpawner.dogSpawner.createNormal, position, true)
        else
            unit = g_EnemySpawner:spawnEnemy(g_EnemySpawner.zombieSpawner, EnemySpawner.zombieSpawner.createNormal, position, true)
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

-- Called when the uber changes
-- Passes in the Abom unit and iBossHealth value for the uber (which should be used to update the units attributes)
-- @param bossLevelAdjust | The current level for attack (sets the aboms level)
-- @param bossHealthAdjust | The change in boss health value since the last update
function onUberChangedAbom(unit, bossLevel, bossHealthAdjust)
    print("Abomination | Upgrades: bossLevel=" .. bossLevel .. " | bossHealthAdjust=" .. bossHealthAdjust)
    local mobHealth = unit:GetHealth()
    local healthChange = bossHealthAdjust * 1500
    local currentLevel = unit:GetLevel() or 1
    unit:CreatureLevelUp(bossLevel - currentLevel)
    unit:SetMaxHealth(unit:GetMaxHealth() + healthChange)
    unit:SetHealth(mobHealth + healthChange)
    GiveUnitArmor(unit, bossLevel)
end
