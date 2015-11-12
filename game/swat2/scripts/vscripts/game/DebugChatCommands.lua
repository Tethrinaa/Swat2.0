-- Some chat commands to help debugging

DEBUG_CHAT_COMMANDS_ARE_ENABLED = true

-- Function that registers game chat commands (if enabled)
function SetUpDebugGameChatCommands()
    if DEBUG_CHAT_COMMANDS_ARE_ENABLED then
        Convars:RegisterCommand( "swat_game_spawn_group", DebugGameChatCommand_SpawnGroup, "Chat Command | Spawn Wave", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_game_spawn_boss", DebugGameChatCommand_SpawnBoss, "Chat Command | Spawn Boss", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_game_kill_all_mobs", DebugGameChatCommand_KillAllEnemies, "Chat Command | Kill all mobs", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_game_award_xp", DebugGameChatCommand_AwardXP, "Chat Command | Award XP", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_game_level_up", DebugGameChatCommand_LevelUp, "Chat Command | Level Up", FCVAR_CHEAT )
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
            playerInfo.hero:HeroLevelUp(true)
        end
      end
    end
end
