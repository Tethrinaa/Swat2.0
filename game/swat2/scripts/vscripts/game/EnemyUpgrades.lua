-- Managers the upgrades, uber, tech...etc that benefits minions

EnemyUpgrades = {}

EnemyUpgrades.MAX_ZOMBIE_BONUS = 58.0

function EnemyUpgrades:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- Stores uber contributions for each player
    self.playerUber = {}
    for i = 1,9 do
        self.playerUber[i] = 0
    end

    -- Uber upgrade for miniona
    self.minionUber = 3.0
    -- Uber upgrade for boss
    self.bossUber = 3.0

    -- Nightmare scaling variables (used in caluclations)
    -- (Yes, red had 3 and they do different things)
    -- Some of these are used on Insane and Survival
    self.nightmareUpgrade = 0.0
    self.nightmareUpgrade2 = 0.0
    self.nightmareUpgrade3 = 0.0

    -- Move Speed
    -- mobSpeedBase is generally static and determined by the difficulty of the game
    self.mobSpeedBase = 0.0
    -- This value fluctuates up the longer a wave lasts and is reset when a new wave starts
    self.mobSpeed = 0.0
    -- This value affects the zombie bonus value for some zombies
    self.collectionZombieBonus = 0.0 -- incremented in EnemyCommander's CollectEmUp method (only changes in survival, though)

    return o
end

-- Should be called when the difficulty is set in GameManager
function EnemyUpgrades:onDifficultySet(difficulty)
    if difficulty == "normal" then
        -- Normal mode
        self.mobSpeedBase = -65
        self.collectionZombieBonus = 6
    elseif difficulty == "hard" then
        -- Hard mode
        self.mobSpeedBase = -40
        self.collectionZombieBonus = 4
    elseif difficulty == "insane" then
        -- Insane mode
        self.mobSpeedBase = -23
        self.collectionZombieBonus = 2
        self.nightmareUpgrade = 1
        self.nightmareUpgrade2 = self.nightmareUpgrade2 + 1
    elseif difficulty == "survival" then
        -- Survival mode
        self.collectionZombieBonus = 5 -- this will change with every CollectEmUp call
        self.mobSpeedBase = -60
    elseif difficulty == "nightmare" then
        -- Nightmare mode  (should be set after another difficulty was set)
    elseif difficulty == "extinction" then
        -- Extinction mode (should be set after another difficulty was set)
    else
        -- Unknown? Error! (Shouldn't happen)
        print("EnemyUpgrades | UNKNOWN DIFFICULTY SET!: '" .. difficulty .. "'")
    end
end

-- Calculates what the movespeed should be for the given mob
-- @param mob(Entity) | the mob to calculate the speed for
-- @param zombieBonus(float) | Adds this to the returned value (has a max)
-- Returns back the value to set for the movespeed
function EnemyUpgrades:calculateMovespeed(mob, zombieBonus)
    local moveSpeed = mob:GetBaseMoveSpeed()

    local maxMobSpeedBonus = self.mobSpeedBase * 1.1
    if(moveSpeed + self.mobSpeedBase < maxMobSpeedBonus) then
        moveSpeed = moveSpeed + self.mobSpeedBase
    else
        moveSpeed = maxMobSpeedBonus
    end

    if zombieBonus < EnemyUpgrades.MAX_ZOMBIE_BONUS then
        moveSpeed = moveSpeed + self.mobSpeed + zombieBonus
    else
        moveSpeed = moveSpeed + self.mobSpeed + EnemyUpgrades.MAX_ZOMBIE_BONUS
    end

    return moveSpeed
end

-- Returns a zombie bonus value for the passed mob (generally used in the zombieBonus parameter of calculateMoveSpeed() )
function EnemyUpgrades:calculateZombieBonus(mob)
    -- TODO: Check if unit is zombie
    --if GetUnitTypeId(oUnit) == 'n008' then
        --// GetUnitUserData() for a Zombie returns its number of lives)
      --return (GetUnitUserData(oUnit) / udg_CollectionZBonus)*(9.00/udg_nDifficulty)
    --else
      --return 0.0
    --endif
    return 0.0
end
