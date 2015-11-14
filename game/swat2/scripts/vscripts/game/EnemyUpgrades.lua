-- Managers the upgrades, uber, tech...etc that benefits minions

SHOW_ENEMY_UPGRADES_LOGS = SHOW_GAME_SYSTEM_LOGS

EnemyUpgrades = {}

EnemyUpgrades.MAX_ZOMBIE_BONUS = 58.0

function EnemyUpgrades:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    -- Stores uber contributions for each player
    -- Players contribute different amounts of uber towards minions and boss upgrades
    self.playerMinionUber = {}
    self.playerBossUber = {}
    for i = 1,9 do
        self.playerMinionUber[i] = 0
        self.playerBossUber[i] = 0
    end

    -- Uber

    -- Uber upgrade for miniona
    self.minionUber = 3.0
    -- Uber upgrade for boss
    self.bossUber = 3.0
    -- Uber contributed by LADs
    self.ladUber = 0.0

    self.extUber = 0.0 -- (Some extra things contribute to uber in Ext, like # of power plants fixed)

    self.undeadUpgrade = 0 -- Upgrade, 0 for Normal and 1 otherwise

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

	-- Upgrades
	self.currentMobHealthBonus = 1.0 -- Stores the last bonus from upgradeMobs()
	self.currentBossHealthBonus = 1.0 -- Stores the last bonus from upgradeMobs()
	self.currentMobLevel = 1
	self.currentBossLevel = 1
	self.extinctionZombieHealthBonusLevel = 0 -- Level of a tech for extinction

    -- Bonuses are applied from things like Nightmare/Extinction being activated and from Midnight difficulty
    self.bonusMobAttackLevels = 0 -- Each point is 1 bonus attack level for mobs
    self.bonusMobHealthLevels = 0 -- Each point is 5% bonus health for mobs

    self.tempMobHealthLevel = 0 -- TODO remove
    self.tempMobLevel = 0 -- TODO remove


    return o
end

-- Should be called when the difficulty is set in GameManager
function EnemyUpgrades:onDifficultySet(difficulty)
    if difficulty == "normal" then
        -- Normal mode
        self.mobSpeedBase = -65
        self.collectionZombieBonus = 6
        self.undeadUpgrade = 0
    elseif difficulty == "hard" then
        -- Hard mode
        self.mobSpeedBase = -40
        self.collectionZombieBonus = 4
        self.undeadUpgrade = 1
    elseif difficulty == "insane" then
        -- Insane mode
        self.mobSpeedBase = -23
        self.collectionZombieBonus = 2
        self.undeadUpgrade = 1
        self.nightmareUpgrade = 1
        self.nightmareUpgrade2 = self.nightmareUpgrade2 + 1
    elseif difficulty == "survival" then
        -- Survival mode
        self.collectionZombieBonus = 5 -- this will change with every CollectEmUp call
        self.mobSpeedBase = -60
        self.undeadUpgrade = 1
    elseif difficulty == "nightmare" then
        -- Nightmare mode  (should be set after another difficulty was set)
    elseif difficulty == "extinction" then
        -- Extinction mode (should be set after another difficulty was set)
    else
        -- Unknown? Error! (Shouldn't happen)
        print("EnemyUpgrades | UNKNOWN DIFFICULTY SET!: '" .. difficulty .. "'")
    end

    self:startIncreaseMoveSpeedLoop()
end

-- Called when the horn blows and the game begins
function EnemyUpgrades:onGameStarted()
    -- Queue up the Midnight Difficulty Increase or survival
    Timers:CreateTimer(12 * 60, function() -- Wait 12 minutes
        self:onFirstMidnight()
    end)
end

-- Calculates what the movespeed should be for the given mob
-- @param mob(Entity) | the mob to calculate the speed for
-- @param zombieBonus(float) | Adds this to the returned value (has a max)
-- Returns back the value to set for the movespeed
function EnemyUpgrades:calculateMovespeed(mob, zombieBonus)
    local moveSpeed = GameMode.unit_infos[mob:GetUnitName()]["MovementSpeed"] or 0
    if moveSpeed == 0 then
        print("ERROR! | No Movementspeed value found for mob=" .. mob:GetUnitName())
    end

    local maxMobSpeedBonus = moveSpeed * 1.1
    if(moveSpeed + self.mobSpeedBase < maxMobSpeedBonus) then
        moveSpeed = moveSpeed + self.mobSpeedBase
    else
        moveSpeed = moveSpeed + maxMobSpeedBonus
    end

    if zombieBonus < EnemyUpgrades.MAX_ZOMBIE_BONUS then
        moveSpeed = moveSpeed + self.mobSpeed + zombieBonus
    else
        moveSpeed = moveSpeed + self.mobSpeed + EnemyUpgrades.MAX_ZOMBIE_BONUS
    end

    --print("DEBUG | CalculateMoveSpeed | " .. mob:GetUnitName() .. "  [base=" .. mob:GetBaseMoveSpeed() .. " set=" .. moveSpeed .. " , mobSpeedBase=" .. self.mobSpeedBase .. " , mobSpeed=" .. self.mobSpeed .. " , zombieBonus=" .. zombieBonus .. "]")

    return moveSpeed
end

-- Returns a zombie bonus value for the passed mob (generally used in the zombieBonus parameter of calculateMoveSpeed() )
function EnemyUpgrades:calculateZombieBonus(mob)
	if mob.zombieLives ~= nil then
		-- This unit is a zombie
		return (mob.zombieLives / self.collectionZombieBonus) * (9.00 / g_GameManager.difficultyBase)
	else
		return 0.0
	end
end

-- Every 30 seconds, move speed is increased (or decreased) based on the minion queue
function EnemyUpgrades:startIncreaseMoveSpeedLoop()
    Timers:CreateTimer(30, function()

        local bonusPenalty = 0.0
        if g_GameManager.isSurvival then
            bonusPenalty = 2.0
            self.mobSpeedBase = (-14.28 * (g_GameManager.difficultyBase + 0.75)) + g_GameManager.difficultyTime + (g_PlayerManager.playerCount * ( 2.5 - g_GameManager.difficultyBase ))
        else
            self.mobSpeedBase = (-14.28 * (g_GameManager.difficultyBase + 0.75)) + (g_GameManager.difficultyTime / (18.0 - (g_PlayerManager.playerCount / 3.0))) + (g_PlayerManager.playerCount * ( 2.5 - g_GameManager.difficultyBase ))
        end

        if g_EnemySpawner.minionQueue > 29 then
            self.mobSpeed = self.mobSpeed + 1.9 + bonusPenalty
        elseif g_EnemySpawner.minionQueue > 0 then
            self.mobSpeed = self.mobSpeed + 1.0 + bonusPenalty
        else
            self.mobSpeed = math.max(0, self.mobSpeed - 1.0 - bonusPenalty)
        end

        if SHOW_ENEMY_UPGRADES_LOGS then
            print("EnemyUpgrades | Increasing movespeed. [mobSpeedBase=" .. self.mobSpeedBase .. " , moveSpeed=" .. self.moveSpeed .. "]")
        end

        return 30
    end)
end

function EnemyUpgrades:upgradeMobs()
	local iBossHealth = 0
    local iMobHealthLevel = 0
    local i = 0
    if (not g_GameManager.isSurvival) then
      iBossHealth = math.floor(self.bossUber / 20)
      iMobHealthLevel = math.floor(self.minionUber / 48)
    elseif g_GameManager.survivalValue < 5 then
        iBossHealth = math.floor(self.bossUber / math.max(20 - math.floor(g_GameManager.survivalValue / 2), 12))
        iMobHealthLevel = math.floor(self.minionUber / math.max(50 - (2 * g_GameManager.survivalValue), 15))
    else
        iBossHealth = math.floor(self.bossUber / math.max(21 - g_GameManager.survivalValue, 12))
        iMobHealthLevel = math.floor(self.minionUber / math.max(58 - (4 * g_GameManager.survivalValue), 15))
    end
    iBossHealth = iBossHealth + self.undeadUpgrade + self.nightmareUpgrade
    print("EnemyUpgrades | iMobHealth=" .. iMobHealthLevel .. "  iBossHealth=" .. iBossHealth)

	-- Calculate the bonus health scale value for minions
	local newMobHealthScale = 1.0
	newMobHealthScale = newMobHealthScale + (( 0.08 ) * math.max(0, iMobHealthLevel + self.nightmareUpgrade3 - 1))
	if g_GameManager.difficultyValue < 2 then
		newMobHealthScale = newMobHealthScale + (( 0.04 ) * math.max(0, iMobHealthLevel + self.nightmareUpgrade - 1))
		if g_GameManager.nightmareValue > 0 then
			newMobHealthScale = newMobHealthScale + (( 0.02 ) * math.max(0, iMobHealthLevel + self.nightmareUpgrade2 - 1))
		end
	elseif g_GameManager.difficultyValue < 3 then
		newMobHealthScale = newMobHealthScale + (( 0.02 ) * math.max(0, iMobHealthLevel + self.nightmareUpgrade - 1))
	end
    newMobHealthScale = newMobHealthScale + (( 0.05 ) * self.bonusMobHealthLevels)

	-- Calculate the creature level of mobs
	local newMobLevel = 1 + math.floor(self.minionUber / 30) + self.undeadUpgrade + self.nightmareUpgrade + self.bonusMobAttackLevels

    -- Calculate new boss level
    local newBossLevel = 1 + math.floor(self.bossUber / 40) + self.nightmareUpgrade


    if newMobLevel ~= self.currentMobLevel
        or newMobHealthScale ~= self.currentMobHealthBonus
        or iBossHealth ~= self.currentBossHealthBonus
        or newBossLevel ~= self.currentBossLevel
        then
        -- Upgrade all existing mobs
        -- Calculation: (newMobHealth) = (oldMobHealth / oldMobHealthScaleBonus) * newMobHealthScaleBonus
        local mobConvertValue = (newMobHealthScale / self.currentMobHealthBonus) -- saves us doing this calculation over and over
        local mobLevelAdjust = newMobLevel - self.currentMobLevel
        if SHOW_ENEMY_UPGRADES_LOGS then
            print("EnemyUpgrades | Upgrading Mobs | MobLevel = " .. newMobLevel .. " HealthScale = " .. newMobHealthScale .. " | BossLevel = " .. newBossLevel .. "  iBossHealth=" .. iBossHealth)
        end
        local bossHealthAdjust = iBossHealth - self.currentBossHealthBonus

        local enemyUnits = g_EnemySpawner:getAllMobs()

        for _,unit in pairs(enemyUnits) do
            if unit.onUberChangesBoss ~= nil then
                -- This unit is a boss and will update itself
                unit.onUberChangesBoss(unit, newBossLevel, bossHealthAdjust)
            else
                -- Leveling up will set them to max health, so we need to store it before we level them up
                local mobHealth = unit:GetHealth()
                unit:CreatureLevelUp(mobLevelAdjust) -- NOTE: Sets to max health
                unit:SetMaxHealth(unit:GetMaxHealth() * mobConvertValue)
                unit:SetHealth(mobHealth * mobConvertValue)
            end
        end

        -- Update the current variables
        self.currentMobHealthBonus = newMobHealthScale
        self.currentMobLevel = newMobLevel
        self.currentBossHealthBonus = iBossHealth
        self.currentBossLevel = newBossLevel
    end
end

-- Upgrades a single mob (called when they are spawned, NOT when they are upgraded in upgradeMobs()
function EnemyUpgrades:upgradeMob(unit)
    local mobHealth = unit:GetHealth()
    unit:CreatureLevelUp(self.currentMobLevel)
	unit:SetMaxHealth(unit:GetMaxHealth() * self.currentMobHealthBonus)
    unit:SetHealth(mobHealth * self.currentMobHealthBonus)
end

function EnemyUpgrades:updateUber()
    local playerMinionUberSum = 0
    local playerBossUberSum = 0
    for i = 1,#self.playerMinionUber do
        playerMinionUberSum = playerMinionUberSum + self.playerMinionUber[i]
        playerBossUberSum = playerBossUberSum + self.playerBossUber[i]
    end

    self.bossUber = Round( playerBossUberSum / g_GameManager.difficultyBase ) + self.extUber

    -- Just following redscull's orders
    local newMinionUber = 0.0
    local i = 100
    while playerMinionUberSum > 100.0 do
        playerMinionUberSum = playerMinionUberSum - 100.0
        newMinionUber = newMinionUber + 100.0 * ( i / 100.0 )

        i = i - 8 + g_GameManager.nightmareValue
        if i < 1 then
            i = 1
        end
    end
    newMinionUber = newMinionUber + self.ladUber + playerMinionUberSum * ( i / 100.0 )
    self.minionUber = Round( newMinionUber / g_GameManager.difficultyBase ) + self.extUber

    -- Survival also takes into account the player's ranks
    if g_GameManager.isSurvival then
        -- TODO Sum up player's rank. For now, just setting it to one for each
        local playerRankSum = g_PlayerManager.playerCount
        self.minionUber = self.minionUber + playerRankSum
        self.bossUber = self.bossUber + playerRankSum
    end

    if SHOW_ENEMY_UPGRADES_LOGS then
        print("EnemyUpgrades | Updating Uber | minionUber=" .. self.minionUber .. " bossUber=" .. self.bossUber)
    end
    self:upgradeMobs()
end

-- Should be called when a player levels up
function EnemyUpgrades:onPlayerLevelUp(playerIndex, level)
    -- TODO: Player uber is reduced for swift learners
    --self.playerMinionUber = self.playerMinionUber + math.max(1 , math.floor(playerLevel / (12 + g_TraitManager.getSwiftValue(playerIndex)) )
    self.playerMinionUber[playerIndex] = self.playerMinionUber[playerIndex] + math.max(1, math.floor(level / 12))
    --self.playerbossUber = self.playerbossUber + math.max(1 , (playerLevel / (17 + g_TraitManager.getSwiftValue(playerIndex)) )
    self.playerBossUber[playerIndex] = self.playerBossUber[playerIndex] + math.max(1, math.floor(level / 17))

    self:updateUber()
end

-- Should be called when a player leaves the game (we need to remove his uber
function EnemyUpgrades:onPlayerLeavesGame(playerIndex)
    self.playerMinionUber[playerIndex] = 0
    self.playerBossUber[playerIndex] = 0
    self:updateUber()
end

-- 'Midnight' Difficulty
-- The harder difficulties will permanently boost enemy upgrades at certain times
function EnemyUpgrades:onFirstMidnight()
    -- Enable midnight difficulty!!
    if g_GameManager.nightmareValue > 1 then
        self:performExtinctionMidnightDifficulty()
    elseif g_GameManager.nightmareValue == 1 then
        self:performNightmareMidnightDifficulty()
    elseif g_GameManager.difficultyValue == 1 then
        self:performInsaneMidnightDifficulty()
    end
end

function EnemyUpgrades:performInsaneMidnightDifficulty()

    local waitTime = 0
    if g_PlayerManager.playerCount < 3 then
        waitTime = 12 * 60 -- Wait until noon
    else
        waitTime = 8 * 60 -- Wait until sunrise
    end

    -- Reduce experience game
    g_ExperienceManager.experienceModifierBase = g_ExperienceManager.experienceModifierBase * 0.90
    g_ExperienceManager:updateExperienceModifier()

    if SHOW_ENEMY_UPGRADES_LOGS then
        print("EnemyUpgrades | Midnight Difficult! [Insane] in " .. waitTime .. " seconds")
    end

    Timers:CreateTimer(waitTime, function()
        self.bonusMobAttackLevels = self.bonusMobAttackLevels + 4 -- Bonus 4 attack levels
        self.bonusMobHealthLevels = self.bonusMobHealthLevels + 2 -- Bonus 10% health
        if SHOW_ENEMY_UPGRADES_LOGS then
            print("EnemyUpgrades | Buffing Mobs. AttackBonus=" .. self.bonusMobAttackLevels .. " HealthBonus=" .. self.bonusMobHealthLevels)
        end
        self:upgradeMobs()
    end)
end

function EnemyUpgrades:performNightmareMidnightDifficulty()
    if SHOW_ENEMY_UPGRADES_LOGS then
        print("EnemyUpgrades | Midnight Difficult! [Nightmare]")
    end
end

function EnemyUpgrades:performExtinctionMidnightDifficulty()
    if SHOW_ENEMY_UPGRADES_LOGS then
        print("EnemyUpgrades | Midnight Difficult! [Extinction]")
    end
end

--- OTHER UTIL METHODS

-- Uses two abilities to give up to 400 armor to the supplied unit
function GiveUnitArmor(unit, armor)
    if armor > 400 then
        print("WARNING | Can't supply unit=" .. unit .. " with armor=" .. armor .. " (Over 400!)")
        armor = 400
    end

    local armor1 = armor % 20
    local armor2 = math.floor(armor / 20)

    local armorAbil1 = unit:FindAbilityByName("armor_upgrade_1")
    if armorAbil1 == nil then
        unit:AddAbility("armor_upgrade_1")
        armorAbil1 = unit:FindAbilityByName("armor_upgrade_1")
    end
    armorAbil1:SetLevel(armor1)

    local armorAbil2 = unit:FindAbilityByName("armor_upgrade_2")
    if armorAbil2 == nil then
        unit:AddAbility("armor_upgrade_2")
        armorAbil2 = unit:FindAbilityByName("armor_upgrade_2")
    end
    armorAbil2:SetLevel(armor2)
end
