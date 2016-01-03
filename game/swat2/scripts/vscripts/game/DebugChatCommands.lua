-- Some chat commands to help debugging

DEBUG_CHAT_COMMANDS_ARE_ENABLED = true

-- Function that registers game chat commands (if enabled)
function SetUpDebugGameChatCommands()
    if DEBUG_CHAT_COMMANDS_ARE_ENABLED then
        Convars:RegisterCommand( "swat_spawn_group", DebugGameChatCommand_SpawnGroup, "Chat Command | Spawn Wave", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_spawn_boss", DebugGameChatCommand_SpawnBoss, "Chat Command | Spawn Boss", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_kill_all_mobs", DebugGameChatCommand_KillAllEnemies, "Chat Command | Kill all mobs", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_award_xp", DebugGameChatCommand_AwardXP, "Chat Command | Award XP", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_level_up", DebugGameChatCommand_LevelUp, "Chat Command | Level Up", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_collect_em_up", DebugGameChatCommand_CollectEmUp, "Chat Command | Collect em up", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_spawn_rad", DebugGameChatCommand_SpawnRad, "Chat Command | Spawn Rad", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_kill_rad", DebugGameChatCommand_KillRad, "Chat Command | Kill Rad", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_spawn_all_enemy_types", DebugGameChatCommand_SpawnAllEnemyTypes, "Chat Command | Spawn All Enemy Types", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_city_power", DebugGameChatCommand_CityPower, "Chat Command | Turns on a random power plant", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_dotes", DebugGameChatCommand_Dotes, "Chat Command | Gives player dotes", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_apc", DebugGameChatCommand_SpawnApc, "Chat Command | Spawns an APC", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_power_surge", DebugGameChatCommand_PowerSurge, "Chat Command | Does a single power surge", FCVAR_CHEAT )
		Convars:RegisterCommand( "swat_distribute_gold", DebugGameChatCommand_DistributeGold, "Chat Command | Distribute Gold", FCVAR_CHEAT )
	end
end

-- This is an example console command
-- Here is the barebones example chat command
--Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )
--function GameMode:ExampleConsoleCommand()
  --print( '******* Example Console Command ***************' )
  --local cmdPlayer = Convars:GetCommandClient()
  --if cmdPlayer then
    --local playerID = cmdPlayer:GetPlayerID()
    --if playerID ~= nil and playerID ~= -1 then
      ---- Do something here for the player who called this command
      --PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    --end
  --end

  --print( '*********************************************' )
--end

function DebugGameChatCommand_SpawnGroup()
    print("DEBUG | Spawning Minion Group")
    g_EnemySpawner:spawnMinionGroup(GetRandomWarehouse(), false)
end

function DebugGameChatCommand_SpawnBoss()
    print("DEBUG | Spawning Boss")
    g_EnemySpawner:spawnBoss()
end

function DebugGameChatCommand_KillAllEnemies()
    print("DEBUG | Killing all enemies")
    local mobs = g_EnemySpawner:getAllMobs()
    for _,unit in pairs(mobs) do
        unit:ForceKill(true)
    end
end

function DebugGameChatCommand_AwardXP()
    print("DEBUG | Awarding XP to all players")
    g_ExperienceManager:awardExperience(10)
end

function DebugGameChatCommand_LevelUp()
    print("DEBUG | Leveling up hero")
    local cmdPlayer = Convars:GetCommandClient()
    if cmdPlayer then
      local playerID = cmdPlayer:GetPlayerID()
      if playerID ~= nil and playerID ~= -1 then
        -- Do something here for the player who called this command
        local playerInfo = g_PlayerManager:getPlayerInfoForPlayerId(playerID)
        if playerInfo then
            local exp = 1000 + math.max(0, playerInfo.hero:GetLevel() - 4) * 200
            playerInfo.hero:AddExperience(
                exp
                , 0
                , false
                , false)
        end
      end
    end
end

function DebugGameChatCommand_CollectEmUp()
    print("DEBUG | Calling CollectEmUp")
    g_EnemyCommander:collectEmUp()
end

function DebugGameChatCommand_SpawnRad()
    print("DEBUG | Calling SpawnRad")
    g_RadiationManager:spawnRadFragmentOnMap()
    g_RadiationManager:incrementRadCount()
end

function DebugGameChatCommand_KillRad()
    print("DEBUG | Calling KillRad")
    local enemyUnits = FindUnitsInRadius(DOTA_TEAM_BADGUYS,
                                            Vector(0, 0, 0),
                                            nil,
                                            FIND_UNITS_EVERYWHERE,
                                            DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                            DOTA_UNIT_TARGET_ALL,
                                            DOTA_UNIT_TARGET_FLAG_NONE,
                                            FIND_ANY_ORDER,
                                            false)

    for _,unit in pairs(enemyUnits) do
        if unit:GetUnitName() == "game_radiation_fragment" then
            -- This is a rad fragment
            unit:ForceKill(true)
            return
        end
    end
    print("DEBUG | KillRad | <None to kill>")

end

-- Debug command that picks a room and spawns ALL non boss enemy types in it for debugging of enemy types
-- Note: They will not move until a collectEmUp is called
function DebugGameChatCommand_SpawnAllEnemyTypes()
    local location = GetRandomWarehouse()
    local es = g_EnemySpawner

    -- Zombies
    es:spawnEnemy(es.zombieSpawner, es.zombieSpawner.createNormal, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    es:spawnEnemy(es.zombieSpawner, es.zombieSpawner.createBurninating, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    es:spawnEnemy(es.zombieSpawner, es.zombieSpawner.createToxic, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    es:spawnEnemy(es.zombieSpawner, es.zombieSpawner.createTnt, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    es:spawnEnemy(es.zombieSpawner, es.zombieSpawner.createLightenating, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    es:spawnEnemy(es.zombieSpawner, es.zombieSpawner.createRadinating, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    -- Beasts
    es:spawnEnemy(es.beastSpawner, es.beastSpawner.createNormal, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    es:spawnEnemy(es.beastSpawner, es.beastSpawner.createBurninating, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    es:spawnEnemy(es.beastSpawner, es.beastSpawner.createToxic, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    es:spawnEnemy(es.beastSpawner, es.beastSpawner.createTnt, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    es:spawnEnemy(es.beastSpawner, es.beastSpawner.createRadinating, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    -- Grotesque
    es:spawnEnemy(es.grotesqueSpawner, es.grotesqueSpawner.createNormal, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    es:spawnEnemy(es.grotesqueSpawner, es.grotesqueSpawner.createBurninating, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    es:spawnEnemy(es.grotesqueSpawner, es.grotesqueSpawner.createToxic, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    es:spawnEnemy(es.grotesqueSpawner, es.grotesqueSpawner.createRadinating, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    -- Dogs
    es:spawnEnemy(es.dogSpawner, es.dogSpawner.createNormal, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    es:spawnEnemy(es.dogSpawner, es.dogSpawner.createBurninating, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
    -- Mutants
    es:spawnEnemy(es.mutantSpawner, es.mutantSpawner.createNormal, GetRandomPointInRegion(location), shouldAddToMinionQueueIfFail)
end

function DebugGameChatCommand_CityPower()
    print("DEBUG | Cheat | Turning on a power plant")
    for _,powerPlant in pairs(g_PowerManager.powerPlants) do
        if powerPlant:GetMana() < powerPlant:GetMaxMana() then
            powerPlant:SetMana(powerPlant:GetMaxMana())
            g_PowerManager:onPowerPlantFilled(powerPlant)
            break
        end
    end
end

function DebugGameChatCommand_Dotes()
    local cmdPlayer = Convars:GetCommandClient()
    if cmdPlayer then
      local playerID = cmdPlayer:GetPlayerID()
      if playerID ~= nil and playerID ~= -1 then
        -- Do something here for the player who called this command
        local playerInfo = g_PlayerManager:getPlayerInfoForPlayerId(playerID)
        if playerInfo then
            playerInfo.hero:AddItemByName("item_antidotes")
        end
      end
    end
end

function DebugGameChatCommand_SpawnApc()
    g_CivillianManager:spawnApc(0)
end

function DebugGameChatCommand_PowerSurge()
    g_CivillianManager:powerSurgeTelevac()
end

function DebugGameChatCommand_DistributeGold()
	print("DEBUG | Calling DistributeGold")
	g_GoldManager:distributeGold(500, false)
end
