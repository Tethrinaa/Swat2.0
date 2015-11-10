-- Some chat commands to help debugging

DEBUG_CHAT_COMMANDS_ARE_ENABLED = true

-- Function that registers game chat commands (if enabled)
function SetUpDebugGameChatCommands()
    if DEBUG_CHAT_COMMANDS_ARE_ENABLED then
        Convars:RegisterCommand( "swat_game_spawn_group", DebugGameChatCommand_SpawnGroup, "Chat Command | Spawn Wave", FCVAR_CHEAT )
        Convars:RegisterCommand( "swat_game_spawn_boss", DebugGameChatCommand_SpawnBoss, "Chat Command | Spawn Boss", FCVAR_CHEAT )
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
