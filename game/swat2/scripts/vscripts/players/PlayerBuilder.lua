-- System response for building player heroes

SHOW_PLAYER_BUILDER_LOGS = SHOW_PLAYER_LOGS

PLAYER_BUILDER_CONSTS = {}
   PLAYER_BUILDER_CONSTS.classes = {}
      PLAYER_BUILDER_CONSTS.classes.cyborg=       {strength = 30, strengthPerLevel=1.10, agility = 14, agilityPerLevel = 0.36, intellect = 105, intellectPerLevel = 0.62}
      PLAYER_BUILDER_CONSTS.classes.demo=         {strength = 22, strengthPerLevel=0.60, agility = 12, agilityPerLevel = 0.60, intellect = 105, intellectPerLevel = 0.42}
      PLAYER_BUILDER_CONSTS.classes.ho=           {strength = 25, strengthPerLevel=1.00, agility = 11, agilityPerLevel = 0.30, intellect = 100, intellectPerLevel = 0.31}
      PLAYER_BUILDER_CONSTS.classes.maverick=     {strength = 22, strengthPerLevel=0.70, agility = 12, agilityPerLevel = 0.60, intellect = 100, intellectPerLevel = 0.31}
      PLAYER_BUILDER_CONSTS.classes.medic=        {strength = 18, strengthPerLevel=0.20, agility = 11, agilityPerLevel = 0.36, intellect = 111, intellectPerLevel = 1.00}
      PLAYER_BUILDER_CONSTS.classes.psychologist= {strength = 18, strengthPerLevel=0.15, agility = 11, agilityPerLevel = 0.60, intellect = 111, intellectPerLevel = 0.80}
      PLAYER_BUILDER_CONSTS.classes.sniper=       {strength = 22, strengthPerLevel=0.60, agility = 12, agilityPerLevel = 0.60, intellect = 100, intellectPerLevel = 0.31}
      PLAYER_BUILDER_CONSTS.classes.tactician =   {strength = 20, strengthPerLevel=0.60, agility = 12, agilityPerLevel = 0.60, intellect = 110, intellectPerLevel = 0.72}
   PLAYER_BUILDER_CONSTS.weapons = {}
      PLAYER_BUILDER_CONSTS.weapons.assault_rifleI =      {bat= 1.860, damageMin =  90, damageMinUpgrade = 1, damageMax = 124, damageMaxUp = 18, range =  900, weaponSkill = "weapon_assault_rifleI"}
      PLAYER_BUILDER_CONSTS.weapons.assault_rifleII =     {bat= 1.691, damageMin =  90, damageMinUpgrade = 1, damageMax = 124, damageMaxUp = 18, range =  900, weaponSkill = "weapon_assault_rifleII"}
      PLAYER_BUILDER_CONSTS.weapons.assault_rifle_urban = {bat= 1.860, damageMin =  99, damageMinUpgrade = 1, damageMax = 156, damageMaxUp = 20, range =  900, weaponSkill = "weapon_assault_rifle_urban"}
      PLAYER_BUILDER_CONSTS.weapons.chaingunI =           {bat= 0.620, damageMin =  45, damageMinUpgrade = 1, damageMax =  52, damageMaxUp =  8, range =  550, weaponSkill = "weapon_chaingunI"}
      PLAYER_BUILDER_CONSTS.weapons.chaingunII =          {bat= 0.564, damageMin =  45, damageMinUpgrade = 1, damageMax =  52, damageMaxUp =  8, range =  625, weaponSkill = "weapon_chaingunII"}
      PLAYER_BUILDER_CONSTS.weapons.vindicator=           {bat= 0.760, damageMin =  55, damageMinUpgrade = 1, damageMax =  64, damageMaxUp = 10, range =  550, weaponSkill = "weapon_vindicator"}
      PLAYER_BUILDER_CONSTS.weapons.flamethrowerI=        {bat= 0.260, damageMin =   9, damageMinUpgrade = 1, damageMax =  11, damageMaxUp =  2, range =  700, weaponSkill = "weapon_flamethrower"}
      PLAYER_BUILDER_CONSTS.weapons.flamethrowerII=       {bat= 0.236, damageMin =   9, damageMinUpgrade = 1, damageMax =  11, damageMaxUp =  2, range =  700, weaponSkill = "weapon_flamethrower"}
      PLAYER_BUILDER_CONSTS.weapons.rocketI=              {bat= 3.100, damageMin =  94, damageMinUpgrade = 1, damageMax = 157, damageMaxUp = 22, range = 1500, weaponSkill = "weapon_rocketI"}
      PLAYER_BUILDER_CONSTS.weapons.rocketII=             {bat= 2.818, damageMin =  94, damageMinUpgrade = 1, damageMax = 157, damageMaxUp = 22, range = 1500, weaponSkill = "weapon_rocketII"}
      PLAYER_BUILDER_CONSTS.weapons.sniper_rifleI=        {bat= 2.570, damageMin = 200, damageMinUpgrade = 5, damageMax = 300, damageMaxUp = 25, range = 1200, weaponSkill = "weapon_sniper_rifleI"}
      PLAYER_BUILDER_CONSTS.weapons.sniper_rifleII=       {bat= 2.142, damageMin = 200, damageMinUpgrade = 5, damageMax = 300, damageMaxUp = 25, range = 1200, weaponSkill = "weapon_sniper_rifleII"}
   PLAYER_BUILDER_CONSTS.armors = {}
      PLAYER_BUILDER_CONSTS.armors.light    = {index = 0, moveSpeed = 290, absorption = 1.4, armor = 0, sprintSkill = 3, nanitesSkill = "nanites_compact"}
      PLAYER_BUILDER_CONSTS.armors.medium   = {index = 1, moveSpeed = 250, absorption = 2.1, armor = 0, sprintSkill = 2, nanitesSkill = "nanites_standard"}
      PLAYER_BUILDER_CONSTS.armors.heavy    = {index = 2, moveSpeed = 220, absorption = 2.8, armor = 0, sprintSkill = 1, nanitesSkill = "nanites_heavy"}
      PLAYER_BUILDER_CONSTS.armors.advanced = {index = 3, moveSpeed = 230, absorption = 2.8, armor = 1, sprintSkill = 0, nanitesSkill = "nanites_heavy"}
   PLAYER_BUILDER_CONSTS.traits = {}
   PLAYER_BUILDER_CONSTS.specs = {}

PLAYER_BUILDER_CONSTS.classes.cyborg.abilities = {"primary_cyborg_cluster_rockets","primary_cyborg_xtreme_combat_mode","primary_cyborg_organic_replacement","cyborg_pheromones", "cyborg_pheromones_off","cyborg_emergency_power","cyborg_goliath_modification", "cyborg_forcefield", "cyborg_forcefield_off"}
PLAYER_BUILDER_CONSTS.classes.demo.abilities = {"primary_demo_mirv","primary_demo_place_c4","primary_demo_advanced_generator", "demo_biochemical_energy","demo_gear_mod","demo_mini_nuke","demo_sma"}
PLAYER_BUILDER_CONSTS.classes.ho.abilities = {"primary_ho_plasma_shield","primary_ho_storage_cells","ho_power_grid","ho_construct_droid","ho_xlr8","ho_recharge_battery"}
PLAYER_BUILDER_CONSTS.classes.maverick.abilities = {"primary_maverick_plasma_grenade","primary_maverick_robodog","primary_maverick_advanced_generator","maverick_nano_injection","maverick_reprogram"}
PLAYER_BUILDER_CONSTS.classes.medic.abilities  = {"primary_medic_nano_injection","primary_medic_mend_wounds","primary_medic_adrenaline_junkie","medic_adrenaline","medic_rapid_therapy","medic_mending_station","medic_revive"}
PLAYER_BUILDER_CONSTS.classes.psychologist.abilities = {"primary_psychologist_mental_clarity","primary_psychologist_confidence","primary_psychologist_self_motivation", "psychologist_mind_slay","psychologist_mind_rot","psychologist_clairvoyance"}
--TODO Figure out how to handle the sniper_critical_shot for the UI
PLAYER_BUILDER_CONSTS.classes.sniper.abilities = {"primary_sniper_concussion_grenade","primary_sniper_aim","primary_sniper_marksman","primary_sniper_critical_shot","sniper_item_teleport","sniper_construct_camera","sniper_sneak"}
PLAYER_BUILDER_CONSTS.classes.tactician.abilities = {"primary_tactician_weakpoint","primary_tactician_blitz","primary_tactician_endurance","tactician_pep_talk","tactician_ion_strike","tactician_recruit"}

PLAYER_BUILDER_CONSTS.classes.psychologist.modifiers = {"modifier_awareness"}
PLAYER_BUILDER_CONSTS.classes.medic.modifiers = {"modifier_anti_personnel_rounds"}

if PlayerBuilder == nil then
    PlayerBuilder = class({})
end

PlayerBuilder = {}
function PlayerBuilder:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    PlayerBuilder = self

    return o
end

function PlayerBuilder:onPreGameStarted()
    -- Register for the player build event
    CustomGameEventManager:RegisterListener("class_setup_complete", Dynamic_Wrap(PlayerBuilder, "BuildMarine"))
end

-- This function will rebuild the marine
-- The event must pass the following:
-- playerId - a handle for the player
-- class  - the class the player select
-- weapon - the weapon the player selected
-- armor  - the armor type the player selected
-- trait  - the trait the player selected
-- spec   - the specialty the player selected
function PlayerBuilder:BuildMarine( event )
    local playerId = event.playerId
    print("PlayerBuilder | Building Marine for playerId= " .. playerId)
    local ply = PlayerResource:GetPlayer(playerId)
    print("PlayerBuilder | playerName= " .. (PlayerResource:GetPlayerName(playerId) or "Unknown"))

    -- Get the player entity from the playerid
    -- TODO: BUGGY? Replaced with above code
    --local entIndex = event.playerId+1
    --local ply = EntIndexToHScript(entIndex)

    -- Create the default hero
    --local hero = CreateHeroForPlayer("npc_dota_hero_sniper", ply)

    --Get hero instead TODO
    hero = ply:GetAssignedHero()
    hero:SetUnitName("npc_swat_hero_tactician")

    --Clean the hero up first
    RemoveAllSkills(hero)



    -- set attributes - Why no SetBaseStrengthGain volvo?
    hero:SetBaseStrength(PLAYER_BUILDER_CONSTS.classes[event.class].strength)
    hero.AttributeStrengthGain = PLAYER_BUILDER_CONSTS.classes[event.class].strengthPerLevel
    hero:SetBaseAgility(PLAYER_BUILDER_CONSTS.classes[event.class].agility)
    hero.AttributeAgilityGain = PLAYER_BUILDER_CONSTS.classes[event.class].agilityPerLevel
    hero:SetBaseIntellect(PLAYER_BUILDER_CONSTS.classes[event.class].intellect)
    hero.AttributeIntellectGain = PLAYER_BUILDER_CONSTS.classes[event.class].intellectPerLevel
    hero:SetBaseManaRegen(6)
    hero:SetBaseHealthRegen(0)

    -- -- Set weapon stats -Why no SetAttackRange???
    hero:SetBaseAttackTime(PLAYER_BUILDER_CONSTS.weapons[event.weapon].bat)
    hero:SetBaseDamageMin(PLAYER_BUILDER_CONSTS.weapons[event.weapon].damageMin)
    hero:SetBaseDamageMax(PLAYER_BUILDER_CONSTS.weapons[event.weapon].damageMax)
    hero:SetAcquisitionRange(PLAYER_BUILDER_CONSTS.weapons[event.weapon].range) -- can't actually set range?  Doing this with weapon skills
    hero:AddAbility(PLAYER_BUILDER_CONSTS.weapons[event.weapon].weaponSkill)
    hero:FindAbilityByName(PLAYER_BUILDER_CONSTS.weapons[event.weapon].weaponSkill):SetLevel(1)
    --hero:FindAbilityByName(PLAYER_BUILDER_CONSTS.weapons[event.weapon].weaponSkill).MaxLevel = 16
    print(hero:FindAbilityByName(PLAYER_BUILDER_CONSTS.weapons[event.weapon].weaponSkill):GetMaxLevel())

    print(event.weapon)

    if ((event.weapon == "flamethrowerI") or (event.weapon == "flamethrowerII")) then
       hero:SetRangedProjectileName("particles/units/heroes/hero_lina/lina_base_attack.vpcf")
       if (event.class == "maverick") then
          hero:FindAbilityByName(PLAYER_BUILDER_CONSTS.weapons[event.weapon].weaponSkill).MaxLevel = 19
          hero.AttackType = flame
       end
    elseif ((event.weapon == "rocketI") or (event.weapon == "rocketII")) then
       hero:SetRangedProjectileName("particles/units/heroes/hero_techies/techies_base_attack.vpcf")
       hero.AttackType = "rockets"
       print(hero:GetProjectileSpeed())
       print(hero.ProjectileSpeed)
       hero.ProjectileSpeed=200
       for k,v in pairs(hero) do
          print(k, v)
       end
       print(hero:GetProjectileSpeed())
    else
       hero.AttackType = "bullets"
    end

    --set armor stats
    hero.sdata.armor_index = PLAYER_BUILDER_CONSTS.armors[event.armor].index
    hero:SetBaseMoveSpeed(PLAYER_BUILDER_CONSTS.armors[event.armor].moveSpeed)
    print(hero:GetBaseMoveSpeed())
    hero:SetPhysicalArmorBaseValue(PLAYER_BUILDER_CONSTS.armors[event.armor].armor)
    hero:SetBaseMagicalResistanceValue(0)

    -- else if cyborg, get rank and increase movespeed

    -- set abilities
    for i, abil in ipairs(PLAYER_BUILDER_CONSTS.classes[event.class].abilities) do
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

    hero:AddAbility(PLAYER_BUILDER_CONSTS.armors[event.armor].nanitesSkill)
    -- This will change based on rank and trait
    hero:FindAbilityByName(PLAYER_BUILDER_CONSTS.armors[event.armor].nanitesSkill):SetLevel(1)

    -- Add the appropriate sprint
    if (event.class ~= "cyborg") then
       hero:AddAbility("sprint_datadriven")
       hero:FindAbilityByName("sprint_datadriven"):SetLevel(PLAYER_BUILDER_CONSTS.armors[event.armor].sprintSkill)
    end

    hero:SetAbilityPoints(1) -- This will change based on rank

    GameMode:ModifyStatBonuses(hero)

    -- set trait TODO
    -- set maverick mutate TODO
    -- set spec TODO
    -- set maverick dog TODO
    -- set modifiers TODO

    -----------------------------------------------------

    -- We'll store the information here in this player info object
    -- and pass that to PlayerManager so other systems can easily figure out information
    -- about the players
    local playerInfo = PlayerInfo:new()
    playerInfo.playerId = event.playerId
    playerInfo.playerIndex = event.playerId + 1
	playerInfo.playerName = PlayerResource:GetPlayerName(event.playerId) or "Unknown"
    playerInfo.hero = hero

    playerInfo.className = event.class
    playerInfo.weaponName = event.weapon
    playerInfo.armorName = event.armor

    playerInfo.armorValue = hero.sdata.armor_index

    g_PlayerManager:onPlayerLoadedSwatHero(playerInfo)
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

function bit(p)
    return 2 ^ (p - 1)  -- 1-based indexing
end

-- Typical call:  if hasbit(x, bit(3)) then ...
function hasbit(x, p)
    return x % (p + p) >= p
end
