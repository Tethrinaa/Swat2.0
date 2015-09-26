--[[Item Teleport
	Author: Dokuno
	Date: 23.09.2015.]]
   
-- This will need a lot more work once Items, ABMs and Hazmat are in the game.

-- Initial destination will the entity 'room_lab'.
teleport_to = Entities:FindByName( nil, "room_lab"):GetAbsOrigin()
print("teleport_to: ", teleport_to)
 
-- When Item Teleport is cast this function determines the nature of the target:
-- If the target is a destination (location, ABM, Hero, Storage) then we call SetDestination.
-- If the target is an item we call Teleport. 
function pickAction( keys )
   local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[1]
   --print("Target_Points[1]: ", keys.target_points[1]) -- Vector
   
   -- Find the target closest to point
   local targets = FindUnitsInRadius(
      caster:GetTeam(), point, nil, 100.0, ability:GetAbilityTargetTeam(), --iTeamNumber--vPosition--hCacheUnit--flRadius--iTeamFilter 
      ability:GetAbilityTargetType(), --iTypeFilter
      ability:GetAbilityTargetFlags(), FIND_CLOSEST, false --iFlagFilter--iOrder--bCanGrowCache 
   )
   --print("targets: ", targets) -- Table
   for k,v in ipairs(targets) do
      print("Target k,v", k, v)
   end

   -- Determine what was targeted using:
   -- CBaseEntity:IsAlive()
   -- CDOTA_Item:IsItem()
   -- CDOTA_BaseNPC:IsRealHero()
   -- CDOTA_BaseNPC:HasInventory()  
   local target = targets[1]
   -- Ability targeted ground. Set teleport_to to that spot
   if (target == nil) then
      print("Setting Teleport To Location")
      teleport_to = point
      --Teleport(keys,caster) -- Self teleport for "testing"
   -- Ability targeted something. Hero, Item, ABM, Storage
   elseif( target.IsItem ) then
      print("Target has IsItem")
      Teleport(keys, target)
   elseif( target.IsRealHero ) then
      print("Target has .IsRealHero")  
      if(target:IsRealHero() and target:IsAlive()) then
         -- Set target_to to follow that hero
         print("Target is RealHero,Alive")
      elseif(target:HasInventory()) then
         -- Set target_to to that Storage
         print("Target is Storage/ABM")
      else
         print("AMB case?")
         --Need a sell (and delete depending on how sell works) item function
      end
   else
      print("No Matches") -- Or ABM case
   end 
end

-- Move the target item to the set destination.
function Teleport( keys, item )
   
   -- Teleport the item
   --if ( item is hazmat ) then
   --    return 0
   --end
   item:SetAbsOrigin(teleport_to)
   
   -- Spend the mana (mana spent only on item teleport)
   -- Always 90 for: drugs, implants, antidotes.
   -- CDOTA_BaseNPC:SpendMana(int nActivity)
   --Get item name, check agaist list for special mana cost
   --if (item name in cheapList) then
   --    mana = keys.ability:GetLevelSpecialValueFor("tele_small_cost", (keys.ability:GetLevel() - 1))
   --else
   mana = keys.ability:GetLevelSpecialValueFor("tele_mana_cost", (keys.ability:GetLevel() - 1))
   --end
   keys.caster:SpendMana(mana, keys.ability)
end
