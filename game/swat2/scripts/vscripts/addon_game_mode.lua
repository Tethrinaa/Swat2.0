-- Generated from template

require('libraries/timers')
require('internal/util')
require('gamemode')
require('corpses')
require('util/SWATUtil')
require('stats')

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
    PrecacheUnitByNameSync("npc_dota_creature", context)

    -- Enemies
    PrecacheUnitByNameSync("enemy_boss_abomination", context)
    PrecacheUnitByNameSync("enemy_minion_beast", context)
    PrecacheResource( "particle", "particiles/items_fx/blink_dagger_start.vpcf", context )
    PrecacheResource( "particle", "particiles/items_fx/blink_dagger_end.vpcf", context )
    PrecacheUnitByNameSync("enemy_minion_dog", context)
    PrecacheUnitByNameSync("enemy_minion_grotesque", context)
    PrecacheUnitByNameSync("enemy_minion_innard_initial", context)
    PrecacheUnitByNameSync("enemy_minion_innard_reborn", context)
    PrecacheUnitByNameSync("enemy_minion_mutant", context)
    PrecacheUnitByNameSync("enemy_minion_zombie", context)
    PrecacheUnitByNameSync("enemy_minion_zombie_corpse", context)
    PrecacheUnitByNameSync("enemy_minion_zombie_radinating", context)
    PrecacheUnitByNameSync("enemy_minion_rat", context)
    PrecacheUnitByNameSync("enemy_minion_firefly", context)

    -- Crates
    PrecacheUnitByNameSync("game_crate", context)
    -- TODO: Match these to ItemSpawningManager
    PrecacheModel("models/props_debris/barrel002.vmdl", context)
    PrecacheModel("models/heroes/techies/fx_techies_remotebomb.vmdl", context)

    PrecacheUnitByNameSync("npc_dota_create_rad_frag", context)
    PrecacheUnitByNameSync("npc_dota_hero_lina", context)
    PrecacheUnitByNameSync("npc_dota_hero_techies", context)
    PrecacheUnitByNameSync("npc_dota_hero_slardar", context)
    PrecacheUnitByNameSync("npc_power_core_damaged", context)
    PrecacheResource( "particle", "*.vpcf", context )
    PrecacheResource( "particle_folder", "particles/folder", context)
    PrecacheUnitByNameSync("npc_dota_hero_medusa", context)
    PrecacheUnitByNameSync("npc_dota_hero_brewmaster", context)
    PrecacheUnitByNameSync("npc_dota_hero_keeper_of_the_light", context)
    PrecacheUnitByNameSync("npc_dota_hero_tinker", context)
    PrecacheUnitByNameSync("npc_dota_hero_omniknight", context)
    PrecacheUnitByNameSync("npc_dota_hero_abaddon", context)
    PrecacheUnitByNameSync("npc_dota_hero_wisp", context)
    PrecacheUnitByNameSync("npc_dota_hero_sven", context)
    PrecacheUnitByNameSync("npc_dota_hero_luna", context)
    PrecacheUnitByNameSync("npc_dota_hero_venomancer", context)
    PrecacheUnitByNameSync("npc_dota_hero_meepo", context)
    PrecacheUnitByNameSync("npc_dota_hero_batrider", context)
    PrecacheUnitByNameSync("npc_dota_hero_dark_seer", context)
    PrecacheUnitByNameSync("npc_dota_hero_vengefulspirit", context)
    PrecacheUnitByNameSync("npc_dota_hero_ursa", context)
    PrecacheUnitByNameSync("npc_dota_hero_storm_spirit", context)
    PrecacheUnitByNameSync("npc_dota_hero_invoker", context)

end

-- Create the game mode when we activate
function Activate()
	GameRules.GameMode = GameMode()
	GameRules.GameMode:InitGameMode()

	-- Disable respawning so you don't wind up in lab constantly
	GameRules:SetHeroRespawnEnabled(false)

	ListenToGameEvent( "dota_player_gained_level", HeroLeveledUp, self )
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

function HeroLeveledUp( keys )
	--print( "Somebody leveled up!" )
	local hero = PlayerResource:GetPlayer(keys.player-1):GetAssignedHero()
	ItemCheck(hero)
end


function ItemCheck( hero )
    for itemSlot = 0, 5, 1 do
	local Item = hero:GetItemInSlot( itemSlot )
	if (Item ~= nil) then
            local itemName = Item:GetAbilityName()
	    local itemTable = GameMode.ItemInfoKV[itemName]
	    if itemTable.intRequired then
		    if itemTable.intRequired > hero:GetIntellect() then
			DeepPrintTable(hero:FindModifierByName("itemTable.ModifiersRemove"))
			print("removing data driven modifier")
			Item:ApplyDataDrivenModifier( hero, hero, itemTable.ModifiersRemove, {duration=-1} )
		    else
			DeepPrintTable(hero:FindModifierByName("itemTable.ModifiersAdd"))
			print("applying data driven modifier")
			Item:ApplyDataDrivenModifier( hero, hero, itemTable.ModifiersAdd, {duration=-1} )
		    end
	    end
	end
    end
end
