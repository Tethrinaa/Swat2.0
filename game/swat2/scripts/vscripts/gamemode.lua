-- This is the primary barebones gamemode script and should be used to assist in initializing your game mode
Global_Fallout = 0
Global_Max_Player_Count = 0
--[[Global Uber will end up being a two dimensional array of [total players][2].  First element will be whether the player
    is connected.  If they are connected, it will be an integer value of 1, otherwise an integer value of 0.  This will allow
	us to turn their Uber off if the disconnect.  Second element is the player's uber contribution]]
Global_Uber = {}
Global_Max_Player_Count = 0
Global_Radiation_Manager = nil
Global_Locations = nil

function bit(p)
  return 2 ^ (p - 1)  -- 1-based indexing
end

-- Typical call:  if hasbit(x, bit(3)) then ...
function hasbit(x, p)
  return x % (p + p) >= p
end

Global_Consts = {}
   Global_Consts.classes = {}
      Global_Consts.classes.cyborg=       {strength = 30, strengthPerLevel=1.10, agility = 14, agilityPerLevel = 0.36, intellect = 105, intellectPerLevel = 0.62}
      Global_Consts.classes.demo=         {strength = 22, strengthPerLevel=0.60, agility = 12, agilityPerLevel = 0.60, intellect = 105, intellectPerLevel = 0.42}
      Global_Consts.classes.ho=           {strength = 25, strengthPerLevel=1.00, agility = 11, agilityPerLevel = 0.30, intellect = 100, intellectPerLevel = 0.31}
      Global_Consts.classes.maverick=     {strength = 22, strengthPerLevel=0.70, agility = 12, agilityPerLevel = 0.60, intellect = 100, intellectPerLevel = 0.31}
      Global_Consts.classes.medic=        {strength = 18, strengthPerLevel=0.20, agility = 11, agilityPerLevel = 0.36, intellect = 111, intellectPerLevel = 1.00}
      Global_Consts.classes.psychologist= {strength = 18, strengthPerLevel=0.15, agility = 11, agilityPerLevel = 0.60, intellect = 111, intellectPerLevel = 0.80}
      Global_Consts.classes.sniper=       {strength = 22, strengthPerLevel=0.60, agility = 12, agilityPerLevel = 0.60, intellect = 100, intellectPerLevel = 0.31}
      Global_Consts.classes.tactician =   {strength = 20, strengthPerLevel=0.60, agility = 12, agilityPerLevel = 0.60, intellect = 110, intellectPerLevel = 0.72}
   Global_Consts.weapons = {}
      Global_Consts.weapons.assault_rifleI =      {bat= 1.860, damageMin =  90, damageMinUpgrade = 1, damageMax = 124, damageMaxUp = 18, range =  900, weaponSkill = "assault_rifleI"}
      Global_Consts.weapons.assault_rifleII =     {bat= 1.691, damageMin =  90, damageMinUpgrade = 1, damageMax = 124, damageMaxUp = 18, range =  900, weaponSkill = "assault_rifleII"}
      Global_Consts.weapons.assault_rifle_urban = {bat= 1.860, damageMin =  99, damageMinUpgrade = 1, damageMax = 156, damageMaxUp = 20, range =  900, weaponSkill = "assault_rifle_urban"}
      Global_Consts.weapons.chaingunI =           {bat= 0.620, damageMin =  45, damageMinUpgrade = 1, damageMax =  52, damageMaxUp =  8, range =  550, weaponSkill = "chaingunI"}
      Global_Consts.weapons.chaingunII =          {bat= 0.564, damageMin =  45, damageMinUpgrade = 1, damageMax =  52, damageMaxUp =  8, range =  625, weaponSkill = "chaingunII"}
      Global_Consts.weapons.vindicator=           {bat= 0.760, damageMin =  55, damageMinUpgrade = 1, damageMax =  64, damageMaxUp = 10, range =  550, weaponSkill = "vindicator"}
      Global_Consts.weapons.flamethrowerI=        {bat= 0.260, damageMin =   9, damageMinUpgrade = 1, damageMax =  11, damageMaxUp =  2, range =  700, weaponSkill = "flamethrower"}
      Global_Consts.weapons.flamethrowerII=       {bat= 0.236, damageMin =   9, damageMinUpgrade = 1, damageMax =  11, damageMaxUp =  2, range =  700, weaponSkill = "flamethrower"}
      Global_Consts.weapons.rocketI=              {bat= 3.100, damageMin =  94, damageMinUpgrade = 1, damageMax = 157, damageMaxUp = 22, range = 1500, weaponSkill = "rocketI"}
      Global_Consts.weapons.rocketII=             {bat= 2.818, damageMin =  94, damageMinUpgrade = 1, damageMax = 157, damageMaxUp = 22, range = 1500, weaponSkill = "rocketII"}
      Global_Consts.weapons.sniper_rifleI=        {bat= 2.570, damageMin = 200, damageMinUpgrade = 5, damageMax = 300, damageMaxUp = 25, range = 1200, weaponSkill = "sniper_rifleI"}
      Global_Consts.weapons.sniper_rifleII=       {bat= 2.142, damageMin = 200, damageMinUpgrade = 5, damageMax = 300, damageMaxUp = 25, range = 1200, weaponSkill = "sniper_rifleII"}
   Global_Consts.armors = {}
      Global_Consts.armors.light    = {index = 0, moveSpeed = 290, absorption = 1.4, armor = 0, sprintSkill = 3, nanitesSkill = "nanites_compact"}
      Global_Consts.armors.medium   = {index = 1, moveSpeed = 250, absorption = 2.1, armor = 0, sprintSkill = 2, nanitesSkill = "nanites_standard"}
      Global_Consts.armors.heavy    = {index = 2, moveSpeed = 220, absorption = 2.8, armor = 0, sprintSkill = 1, nanitesSkill = "nanites_heavy"}
      Global_Consts.armors.advanced = {index = 3, moveSpeed = 230, absorption = 2.8, armor = 1, sprintSkill = 0, nanitesSkill = "nanites_heavy"}
   Global_Consts.traits = {}
   Global_Consts.specs = {}

Global_Consts.classes.cyborg.abilities = {"cyborg_cluster_rockets_lua_ability","cyborg_xtreme_combat_mode","cyborg_organic_replacement","cyborg_pheromones", "cyborg_pheromones_off","cyborg_emergency_power","cyborg_goliath_modification", "cyborg_forcefield_lua_ability", "cyborg_forcefield_off_lua_ability"}
Global_Consts.classes.demo.abilities = {"demo_mirv","demo_place_c4","demo_advanced_generator", "demo_biochemical_energy","demo_gear_mod","demo_mini_nuke","demo_sma"}
Global_Consts.classes.ho.abilities = {"ho_plasma_shield","ho_storage_cells","ho_power_grid","ho_construct_droid","ho_xlr8","ho_recharge_battery"}
Global_Consts.classes.maverick.abilities = {"maverick_plasma_grenade","maverick_robodog","maverick_advanced_generator","maverick_nano_injection","maverick_reprogram"}
Global_Consts.classes.medic.abilities  = {"medic_nano_injection","medic_mend_wounds","medic_adrenaline_junkie","medic_adrenaline","medic_rapid_therapy","medic_mending_station","medic_revive"}
Global_Consts.classes.psychologist.abilities = {"psychologist_mental_clarity","psychologist_confidence","psychologist_self_motivation", "psychologist_mind_slay","psychologist_mind_rot","psychologist_clairvoyance"}
Global_Consts.classes.sniper.abilities = {"sniper_concussion_grenade","sniper_aim","sniper_marksman","sniper_critical_shot","sniper_item_teleport","sniper_construct_camera","sniper_sneak"}
Global_Consts.classes.tactician.Abilities = {"tactician_weakpoint","tactician_blitz","tactician_endurance","tactician_pep_talk","tactician_ion_strike","tactician_recruit"}

Global_Consts.classes.psychologist.modifiers = {"modifier_awareness"}
Global_Consts.classes.medic.modifiers = {"modifier_anti_personnel_rounds"}


-- Set this to true if you want to see a complete debug output of all events/processes done by barebones
-- You can also change the cvar 'barebones_spew' at any time to 1 or 0 for output/no output
BAREBONES_DEBUG_SPEW = false

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

-- These internal libraries set up barebones's events and processes.  Feel free to inspect them/change them if you need to.
require('internal/gamemode')
require('internal/events')

-- settings.lua is where you can specify many different properties for your game mode and is one of the core barebones files.
require('settings')
-- events.lua is where you can specify the actions to be taken when any event occurs and is one of the core barebones files.
require('events')

--uber.lua contains most of the code relating to uber.
require('uber')
require('game/Locations')
-- This contains the radiation code
require('game/objectives/RadiationManager')


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
  
  --Initiates Radiation UI
  --TODO: Fix bug where there is delay in UI update
  Global_Radiation_Manager:updateRadiationDisplay()
end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function GameMode:OnHeroInGame(hero)
  DebugPrint("[BAREBONES] Hero spawned in game for first time -- " .. hero:GetUnitName())

  -- This line for example will set the starting gold of every hero to 500 unreliable gold
  hero:SetGold(500, false)

  -- These lines will create an item and add it to the player, effectively ensuring they start with the item
  local item = CreateItem("item_example_item", hero, hero)
  hero:AddItem(item)

  --[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
    --with the "example_ability" ability

  local abil = hero:GetAbilityByIndex(1)
  hero:RemoveAbility(abil:GetAbilityName())
  hero:AddAbility("example_ability")]]
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function GameMode:OnGameInProgress()
  DebugPrint("[BAREBONES] The game has officially begun")

  Timers:CreateTimer(30, -- Start this timer 30 game-time seconds later
    function()
      DebugPrint("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
      return 30.0 -- Rerun this timer every 30 game-time seconds
    end)
end



-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function GameMode:InitGameMode()
  GameMode = self

  DebugPrint('[BAREBONES] Starting to load Barebones gamemode...')

  -- Call the internal function to set up the rules/behaviors specified in constants.lua
  -- This also sets up event hooks for all event handlers in events.lua
  -- Check out internals/gamemode to see/modify the exact code
  GameMode:_InitGameMode()

  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  Convars:RegisterCommand( "command_example", Dynamic_Wrap(GameMode, 'ExampleConsoleCommand'), "A console command example", FCVAR_CHEAT )

  DebugPrint('[BAREBONES] Done loading Barebones gamemode!\n\n')

  	print( "Template addon is loaded." )
	--BDO what is this?  Didn't work after i switched us to barebones
   --GameMode:SetThink( "OnThink", self, "GlobalThink", 2 )
   spawnPower()
   local RoomToPass = getRandomRoom()
	spawnZombies(10, RoomToPass)

    Global_Locations = Locations:new()

    -- Initialize the radiation manager
    Global_Radiation_Manager = RadiationManager:new()
    Global_Radiation_Manager:setup() -- make sure this is called after rooms have been created

    Global_Radiation_Manager:setDifficulty(2, false) -- TODO: Call this when we actually set difficulty
	
   --load unit and item tables
   self.ItemInfoKV = LoadKeyValues( "scripts/npc/item_info.txt" )
   GameMode.unit_infos = LoadKeyValues("scripts/npc/npc_units_custom.txt")
   for k, v in pairs(LoadKeyValues("scripts/npc/npc_heroes_custom.txt")) do
	 GameMode.unit_infos[k] = v
   end
end

-- This is an example console command
function GameMode:ExampleConsoleCommand()
  print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  print( '*********************************************' )
end

function spawnPower()
   -- Note: need to match the distribution of damaged/badly/severly to the difficulty
   -- Get six random rooms and reassign their parent, removing them from the list of basic rooms.
   local powerParent = Entities:FindByName(nil, "power_room_parent")
   local degen = "swat_ability_power_core_damaged"
   for i = 1, 6 do
      local room = getRandomRoom()
      room:SetParent(powerParent, "power_room_parent")
      local powerCore = CreateUnitByName("npc_power_core_damaged", room:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
      powerCore:SetMana(0)
      -- Make two of each kind: damaged, badly damaged, and severly damaged.
      if i == 3 or i == 4 then
         degen = "swat_ability_power_core_badly_damaged"
      elseif i == 5 or i == 6 then
         degen = "swat_ability_power_core_severly_damaged"
      end
      powerCore:AddAbility(degen)
      powerCore:FindAbilityByName(degen):SetLevel(1)
   end
end

--This function spawns the selected number of zombies and sets them moving towards a random player
--NumberToSpawn - number of zombies to spawnZombies
--RoomToSpawn - room entity to spawn the zombies around
function spawnZombies(NumberToSpawn, RoomToSpawn)

    print("Spawning zombies!")
    local randomCreature =
    	{
			"basic_zombie"
	   }
	local r = randomCreature[RandomInt(1,#randomCreature)]
	if RoomToSpawn then
      for i = 1, NumberToSpawn do
         local unit = CreateUnitByName( "npc_dota_creature_" ..r , RoomToSpawn:GetAbsOrigin() + RandomVector( RandomFloat( 0, 600 ) ), true, nil, nil, DOTA_TEAM_NEUTRALS )

         if RandomEnemyHeroInRange ( unit, 500000) then
            ExecuteOrderFromTable({ UnitIndex = unit:entindex(),
		                              OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
								            TargetIndex = (RandomEnemyHeroInRange ( unit, 500000)):entindex(),
                                    queue = true})
         end
      end
   end
	-- Spawn more in 10 seconds
	Timers:CreateTimer( 10.0, function()
   refreshZombieOrders()
   local RoomToPass = getRandomRoom()
	spawnZombies(10, RoomToPass)
   --GameRules:GetGameModeEntity():SendCustomMessage
	end)
end

function getRandomRoom()
   local roomParent = Entities:FindByName( nil, "room_basic_parent")
   local rooms = roomParent:GetChildren()
   local room = rooms[RandomInt(1,#rooms)]
   return room
end

function refreshZombieOrders()
   -- Find all Dire units
   direUnits = FindUnitsInRadius(DOTA_TEAM_NEUTRALS,
                                 Vector(0, 0, 0),
                                 nil,
                                 FIND_UNITS_EVERYWHERE,
                                 DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                 DOTA_UNIT_TARGET_ALL,
                                 DOTA_UNIT_TARGET_FLAG_NONE,
                                 FIND_ANY_ORDER,
                                 false)

   -- Make the found units move to (0, 0, 0)
   for _,unit in pairs(direUnits) do
      if unit:HasAttackCapability() then
         if RandomEnemyHeroInRange ( unit, 500000) then
           ExecuteOrderFromTable({ UnitIndex = unit:entindex(),
		                             OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
								           TargetIndex = (RandomEnemyHeroInRange ( unit, 500000)):entindex(),
                                   queue = true})
         end
      end
   end


end

--[[
These are the valid orders, in case you want to use them (easier here than to find them in the C code):

DOTA_UNIT_ORDER_NONE
DOTA_UNIT_ORDER_MOVE_TO_POSITION
DOTA_UNIT_ORDER_MOVE_TO_TARGET
DOTA_UNIT_ORDER_ATTACK_MOVE
DOTA_UNIT_ORDER_ATTACK_TARGET
DOTA_UNIT_ORDER_CAST_POSITION
DOTA_UNIT_ORDER_CAST_TARGET
DOTA_UNIT_ORDER_CAST_TARGET_TREE
DOTA_UNIT_ORDER_CAST_NO_TARGET
DOTA_UNIT_ORDER_CAST_TOGGLE
DOTA_UNIT_ORDER_HOLD_POSITION
DOTA_UNIT_ORDER_TRAIN_ABILITY
DOTA_UNIT_ORDER_DROP_ITEM
DOTA_UNIT_ORDER_GIVE_ITEM
DOTA_UNIT_ORDER_PICKUP_ITEM
DOTA_UNIT_ORDER_PICKUP_RUNE
DOTA_UNIT_ORDER_PURCHASE_ITEM
DOTA_UNIT_ORDER_SELL_ITEM
DOTA_UNIT_ORDER_DISASSEMBLE_ITEM
DOTA_UNIT_ORDER_MOVE_ITEM
DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO
DOTA_UNIT_ORDER_STOP
DOTA_UNIT_ORDER_TAUNT
DOTA_UNIT_ORDER_BUYBACK
DOTA_UNIT_ORDER_GLYPH
DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH
DOTA_UNIT_ORDER_CAST_RUNE
]]

--BDO From holdout ai_core, need to move to own AI file probably
function RandomEnemyHeroInRange( entity, range )
	local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS,
                                     Vector(0, 0, 0),
                                     nil,
                                     FIND_UNITS_EVERYWHERE,
                                     DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                                     DOTA_UNIT_TARGET_ALL,
                                     DOTA_UNIT_TARGET_FLAG_NONE,
                                     FIND_ANY_ORDER,
                                     false)
	if #enemies > 0 then
		local index = RandomInt( 1, #enemies )
		return enemies[index]
	else
		return nil
	end
end


-- This function will rebuild the marine
-- The event must pass the following:
-- playerId - a handle for the player
-- class  - the class the player select
-- weapon - the weapon the player selected
-- armor  - the armor type the player selected
-- trait  - the trait the player selected
-- spec   - the specialty the player selected
function GameMode:BuildMarine( event )

   -- Get the player entity from the playerid
   local entIndex = event.playerId+1
   local ply = EntIndexToHScript(entIndex)

   -- Create the default hero
   --local hero = CreateHeroForPlayer("npc_dota_hero_sniper", ply)

   --Get hero instead TODO
   hero = ply:GetAssignedHero()

   --Clean the hero up first
   RemoveAllSkills(hero)
      

   
   -- set attributes - Why no SetBaseStrengthGain volvo?
   hero:SetBaseStrength(Global_Consts.classes[event.class].strength)
   hero.AttributeStrengthGain = Global_Consts.classes[event.class].strengthPerLevel
   hero:SetBaseAgility(Global_Consts.classes[event.class].agility)
   hero.AttributeAgilityGain = Global_Consts.classes[event.class].agilityPerLevel
   hero:SetBaseIntellect(Global_Consts.classes[event.class].intellect)
   hero.AttributeIntellectGain = Global_Consts.classes[event.class].intellectPerLevel
   hero:SetBaseManaRegen(6)
   hero:SetBaseHealthRegen(0)

   -- -- Set weapon stats -Why no SetAttackRange???
   hero:SetBaseAttackTime(Global_Consts.weapons[event.weapon].bat)
   hero:SetBaseDamageMin(Global_Consts.weapons[event.weapon].damageMin)
   hero:SetBaseDamageMax(Global_Consts.weapons[event.weapon].damageMax)
   hero:SetAcquisitionRange(Global_Consts.weapons[event.weapon].range) -- can't actually set range?  Doing this with weapon skills
   hero:AddAbility(Global_Consts.weapons[event.weapon].weaponSkill)
   hero:FindAbilityByName(Global_Consts.weapons[event.weapon].weaponSkill):SetLevel(1)
   --hero:FindAbilityByName(Global_Consts.weapons[event.weapon].weaponSkill).MaxLevel = 16
   print(hero:FindAbilityByName(Global_Consts.weapons[event.weapon].weaponSkill):GetMaxLevel())

   print(event.weapon)

   if ((event.weapon == "flamethrowerI") or (event.weapon == "flamethrowerII")) then
      hero:SetRangedProjectileName("particles/units/heroes/hero_lina/lina_base_attack.vpcf")
      if (event.class == "maverick") then
         hero:FindAbilityByName(Global_Consts.weapons[event.weapon].weaponSkill).MaxLevel = 19
      end
   end
   if ((event.weapon == "rocketI") or (event.weapon == "rocketII")) then
      hero:SetRangedProjectileName("particles/units/heroes/hero_techies/techies_base_attack.vpcf")
      print(hero:GetProjectileSpeed())
      print(hero.ProjectileSpeed)
      hero.ProjectileSpeed=200
      for k,v in pairs(hero) do
         print(k, v)
      end
      print(hero:GetProjectileSpeed())
   end

   --set armor stats
   hero.sdata.armor_index = Global_Consts.armors[event.armor].index
   hero:SetBaseMoveSpeed(Global_Consts.armors[event.armor].moveSpeed)
   print(hero:GetBaseMoveSpeed())
   hero:SetPhysicalArmorBaseValue(Global_Consts.armors[event.armor].armor)
   hero:SetBaseMagicalResistanceValue(0)

   -- else if cyborg, get rank and increase movespeed

   -- set abilities
   for i, abil in ipairs(Global_Consts.classes[event.class].abilities) do
		hero:AddAbility(abil)
		local ability = hero:FindAbilityByName(abil)
		if ability then
			if hasbit(ability:GetBehavior(), DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE) then
				ability:SetLevel(1)
			end
			if string.find(abil, "_off") then
				hero:SwapAbilities(abil,abil,false,false)
			end
		end
   end
   
   hero:AddAbility(Global_Consts.armors[event.armor].nanitesSkill)
   -- This will change based on rank and trait
   hero:FindAbilityByName(Global_Consts.armors[event.armor].nanitesSkill):SetLevel(1)

   -- Add the appropriate sprint
   if (event.class ~= "cyborg") then
      hero:AddAbility("sprint_datadriven")
      hero:FindAbilityByName("sprint_datadriven"):SetLevel(Global_Consts.armors[event.armor].sprintSkill)
   end

   hero:SetAbilityPoints(1) -- This will change based on rank

   GameMode:ModifyStatBonuses(hero)


  -- set trait TODO
      -- set maverick mutate TODO
   -- set spec TODO
   -- set maverick dog TODO
   -- set modifiers TODO

end

-- pass this a hero entity to remove all of that hero's skills
function RemoveAllSkills(hero)
  -- loop through hero's skills, fetch them, and remove them subtract one to 0 index
   for index = 0, hero:GetAbilityCount()-1 do
      -- Check if we get an ability, because GetAbilityCount likes to
      -- return 16 (max abilities a hero can have?) regardless
      if hero:GetAbilityByIndex(index) then
         hero:RemoveAbility(hero:GetAbilityByIndex(index):GetAbilityName())
      end
   end
end

--PlayerFirstSpawnUber is called every time a new hero is created at the start of the game
--This sets the inital uber value for the players, and creates the array.
function GameMode:PlayerFirstSpawnUber(event)
   --Set the correct indexed player ID.  The +1 is needed since the ID is being passed from javascript.  Requires a re-index
   local plyid = event.playerId+1
   Global_Uber[plyid] = {}
   Global_Uber[plyid][1] = 1
   Global_Uber[plyid][2] = 0
   Global_Max_Player_Count = Global_Max_Player_Count + 1
end

CustomGameEventManager:RegisterListener("class_setup_complete", Dynamic_Wrap(GameMode, 'BuildMarine'))
CustomGameEventManager:RegisterListener("class_setup_complete", Dynamic_Wrap(GameMode, 'PlayerFirstSpawnUber'))
