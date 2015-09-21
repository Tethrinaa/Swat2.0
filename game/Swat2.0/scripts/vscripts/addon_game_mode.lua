-- Generated from template

require('libraries/timers')
require('internal/util')
require('gamemode')
require('stats')
inspect = require('inspect')

if GameMode == nil then
	GameMode = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
	
	PrecacheUnitByNameSync("npc_dota_creature_basic_zombie", context)
   PrecacheUnitByNameSync("npc_dota_create_rad_frag", context)
   PrecacheUnitByNameSync("npc_dota_hero_lina", context)
   PrecacheUnitByNameSync("npc_dota_hero_luna", context)
   PrecacheUnitByNameSync("npc_dota_hero_slardar", context)
   PrecacheUnitByNameSync("npc_power_core_damaged", context)
   PrecacheResource( "particle", "*.vpcf", context )
   PrecacheResource( "particle_folder", "particles/folder", context)
   PrecacheUnitByNameSync("npc_dota_hero_medusa", context)
   
end

-- Create the game mode when we activate
function Activate()
   GameRules.GameMode = GameMode()
	GameRules.GameMode:InitGameMode()
end

-- Evaluate the state of the game
function GameMode:OnThink()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end