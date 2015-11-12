-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
Global_Fallout = 0
Global_Max_Player_Count = 0

Global_Player_Heroes = {}

g_PlayerManager = nil
g_GameManager = nil



-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false

-- SHOW_DEBUG_LOGS is used for SWAT code. If true, it will enable displaying most normal debug logs
SHOW_DEBUG_LOGS = true

if GameMode == nil then
    DebugPrint( '[BAREBONES] creating barebones game mode' )
    _G.GameMode = class({})
end

-- This library allow for easily delayed/timed actions
require('libraries/timers')
-- This library can be used for advancted physics/motion/collision of units.  See PhysicsReadme.txt for more information.
require('libraries/physics')
-- This library can be used for advanced 3D projectile systems.
require('libraries/projectiles')
-- This library can be used for sending panorama notifications to the UIs of players/teams/everyone
require('libraries/notifications')
-- This library can be used for starting customized animations on units from lua
require('libraries/animations')

-- Load utils
require('util/Utils')
require('util/Queue')

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')

-- Contains game logic and game systems (like spawning, radiation...etc)
require('game/GameManager')
-- Contains player control logic (like hero building, experience, item management...etc)
require('players/PlayerManager')

--[[
  This function should be used to set up Async precache calls at the beginning of the gameplay.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability#
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).

  This function should generally only be used if the Precache() function in addon_game_mode.lua is not working.
]]
function GameMode:PostLoadPrecache()
  DebugPrint("[BAREBONES] Performing Post-Load precache")
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  --PrecacheUnitByNameAsync("npc_dota_hero_viper", function(...) end)
  --PrecacheUnitByNameAsync("npc_dota_hero_enigma", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitGameMode() but needs to be done before everyone loads in.
]]
function GameMode:OnFirstPlayerLoaded()
  DebugPrint("[BAREBONES] First Player has loaded")

end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function GameMode:OnAllPlayersLoaded()
  DebugPrint("[BAREBONES] All Players have loaded into the game")
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())
end

-- This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
function GameMode:OnGameInProgress()
  g_GameManager:onGameStarted()
  g_PlayerManager:onGameStarted()
end

-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self

  --load item table
  self.ItemInfoKV = LoadKeyValues( "scripts/npc/item_info.txt" )

  -- Index the npc units and npc heroes values
  -- Note: To retrieve a value:
  --        local unit_value = GameMode.unit_infos[unit:GetUnitName()]
  --        unit_value["MyCustomKey"]
  GameMode.unit_infos = LoadKeyValues("scripts/npc/npc_units_custom.txt")
  for k, v in pairs(LoadKeyValues("scripts/npc/npc_heroes_custom.txt")) do
    GameMode.unit_infos[k] = v
  end

  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')

  -- Call the internal function to set up the rules/behaviors specified in constants.lua
  -- This also sets up event hooks for all event handlers in events.lua
  -- Check out internals/gamemode to see/modify the exact code
  GameMode:_InitGameMode()

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')

	--BDO what is this?  Didn't work after i switched us to barebones
   --GameMode:SetThink( "OnThink", self, "GlobalThink", 2 )

   -- Set time to Noon (game will start PRE_GAME_TIME seconds before noon)
   -- Not sure why this needs to be in a Timer but it not putting it in a timer means the game will ignore it
   Timers:CreateTimer(1, function()
       GameRules:SetTimeOfDay(0.5)

       -- Make 1 hour == 1 minute
       local cvar_name = "dota_time_of_day_rate"
       local cvar_value = 0.0006933333333 -- This is 1/3 the normal rate
       local current = cvar_getf(cvar_name)
       if SHOW_DEBUG_LOGS then
           print("Trying to slow time time | cvarname=" .. cvar_name .. "  |  " .. current .. " -> " .. cvar_value)
       end
       cvar_setf(cvar_name, cvar_value)
       if SHOW_DEBUG_LOGS then
           print("Successfully slowed down time")
       end
   end)

   -- Initialize the PlayerManager
   g_PlayerManager = PlayerManager:new()
   g_PlayerManager:onPreGameStarted()

   -- Initialize the GameManager (which will initialize more game systems like spawning, AI, upgrades..etc)
   g_GameManager = GameManager:new()
   g_GameManager:onPreGameStarted()

   -- TODO: Maybe set difficulty based on vote?
   g_GameManager:setDifficulty("insane")
   g_PlayerManager:setDifficulty("insane")

   -- Register chat commands
   SetUpDebugGameChatCommands()
end
