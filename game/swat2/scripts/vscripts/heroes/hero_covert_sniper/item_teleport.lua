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
	local point = keys.target_points[1] -- Vector
   --print("Target_Points[1]: ", keys.target_points[1]) 

   -- Find the entities closest to the target point
   -- handle FindInSphere(handle startFrom, Vector origin, float maxRadius)
   -- Appears to notice items and heros. Rerturns nil when nothing is near the target point
   -- but returns a table when a hero or item is near. However the table appears to be empty...
   local targets = Entities:FindInSphere(nil, point, 128.0) -- Table or nil
   print("Sphere target:", targets)
   if ( not targets == nil ) then
      --for k,v in ipairs(targets) do
      --   print("Target k,v", k, v)
      --end
      for x in targets do
         print("Targets[x]", x)
      end
   end
   --if ( targets == nil ) then
      --handle FindByClassnameWithin(handle startFrom, string className, Vector origin, float maxRadius)
   -- -- NO RESPONSE TO ITEMS (dota or swat)
   -- targets = Entities:FindByClassnameWithin(nil, "item_datadriven", point, 128.0)
   -- print ("item_datadriven targets:", targets)
   -- if ( not targets == nil ) then
      -- for k,v in ipairs(targets) do
         -- print("Target k,v", k, v)
      -- end
   -- end
      --target = targets[1]
      --print("item_datadriven target:", target)
   --end 
   --if ( targets == nil ) then
   -- -- NO RESPONSE TO ITEMS (dota or swat)
   -- targets = Entities:FindByClassnameWithin(nil, "CDOTA_Item", point, 128.0)
   -- print ("CDOTA_Item targets:", targets)
   -- if ( not targets == nil ) then
      -- for k,v in ipairs(targets) do
         -- print("Target k,v", k, v)
      -- end
   -- end
      --target = targets[1]
      --print("CDOTA_Item target:", target)      
   --end

   -- Ability targeted ground. Set teleport_to to that spot
   if (targets == nil) then
      print("Setting Teleport To Location")
      teleport_to = point  
   -- Ability targeted an entity. Determine what kind
   elseif( targets[1] == nil ) then
      teleport_to = point
   else
      local target = targets[1]
      --local target = ipairs(targets)[1][2]
      for k,v in ipairs(targets) do
         print("Target k,v", k, v)
      end
      --Teleport(keys,caster) -- Self teleport for "testing"
      -- Determine what was targeted using:
      -- CBaseEntity:IsAlive()
      -- CDOTA_Item:IsItem()
      -- CDOTA_BaseNPC:IsRealHero()
      -- CDOTA_BaseNPC:HasInventory()  
   
      -- Ability targeted something. Hero, Item, ABM, Storage
      if( target.IsItem ) then
         print("Target has IsItem")
         Teleport(keys, target)
      elseif( target.IsRealHero ) then 
         if(target:IsRealHero() and target:IsAlive()) then
            -- Set target_to to follow that hero
            print("Target is RealHero,Alive")
         end
      elseif( target.HasInventory ) then
         if (target:HasInventory()) then
            -- Set target_to to that Storage
            print("Target is Storage")
         end
      else
         print("Target is AMB??")
         --Need a sell (and delete depending on how sell works) item function
      end
   end
end

-- Move the target item to the set destination.
function Teleport( keys, item )
   --if ( item is hazmat ) then
   --    return 0
   --end
   item:SetAbsOrigin(teleport_to)
   
   -- Spend the mana (mana spent only on item teleport)
   -- Always 90 for: drugs, implants, antidotes.
   -- Get item name, check agaist list for special mana cost
   --if (item name in cheapList) then
   --    mana = keys.ability:GetLevelSpecialValueFor("tele_small_cost", (keys.ability:GetLevel() - 1))
   --else
   local mana = keys.ability:GetLevelSpecialValueFor("tele_mana_cost", (keys.ability:GetLevel() - 1))
   --end
   -- CDOTA_BaseNPC:SpendMana(int nActivity)
   keys.caster:SpendMana(mana, keys.ability)
end
