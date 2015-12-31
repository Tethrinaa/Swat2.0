if itemFunctions == nil then
	print ( '[ItemFunctions] creating itemFunctions' )
	itemFunctions = {} -- Creates an array to let us beable to index itemFunctions when creating new functions
	itemFunctions.__index = itemFunctions
end
 
function itemFunctions:new() -- Creates the new class
	print ( '[ItemFunctions] itemFunctions:new' )
	o = o or {}
	setmetatable( o, itemFunctions )
	return o
end
 
function itemFunctions:start() -- Runs whenever the itemFunctions.lua is ran
	print('[ItemFunctions] itemFunctions started!')
end
         
function DropItemOnDeath( event )
	print( '[ItemFunctions] DropItemOnDeath Called' )
	local hero = event.caster
	local item = event.ability
	hero:DropItemAtPositionImmediate(item, hero:GetOrigin())
end

-- Intelligence check when item is picked up
function ItemCheck( event )
    local itemName = event.ability:GetAbilityName()
    local hero = event.caster
    local itemTable = GameMode.ItemInfoKV[itemName]
	
    -- if there is no subtable for this item, end this script
    if itemTable == nil then
        return true
    end
	
	-- Check Int Restriction
	if itemTable.intRequired then

		-- If the hero doesn't meet the int required
		if itemTable.intRequired > hero:GetIntellect() then
		
		-- Hero has enough intelligence, so modifier should be added			
		else
			event.ability:ApplyDataDrivenModifier( hero, hero, itemTable.Modifier, {duration=-1} )
		end
	end 
end

-- When item is dropped, remove modifier
function RemoveItemModifierStats( event )
    local itemName = event.ability:GetAbilityName()
    local hero = event.caster
    local itemTable = GameMode.ItemInfoKV[itemName]
	
    -- if there is no subtable for this item, end this script
    if itemTable == nil then
        return true
    end	
	
    -- Check Int Restriction
	  if itemTable.intRequired then
		    
		    -- If the hero meets the intelligence requirement, modifier needs to be removed
		    if itemTable.intRequired <= hero:GetIntellect() then
		  
            -- If modifier is unique, a check for a duplicate of the item needs to be done to prevent removing the modifier
            local modifier = hero:FindModifierByNameAndCaster(itemTable.Modifier, hero)
            if (itemName == "item_rapid_reload" or itemName == "item_battery") then
		            local duplicateItem = false
		     
		            -- Go through inventory for item with same name   
			          for itemSlot = 0, 5, 1 do
                    local itemInSlot = hero:GetItemInSlot( itemSlot )
                    if (itemInSlot ~= nil and itemName == itemInSlot:GetAbilityName()) then
                        duplicateItem = true
        	          end
		            end
		    
		            -- If a duplicate is not found, destroy modifier as normal
                if (duplicateItem == false) then  
                    modifier:Destroy()
                end
		     
		        -- In normal circumstances, destroy the modifier
            else		
			         modifier:Destroy()
            end
        end
    end
end

function BatteryAutoUse ( event )
    local hero = event.caster
    local battery = event.ability
    print("mana used")
    
    if (hero:GetMana() < 250) then
    print("less than 250 mana")
         
        -- Take off a charge and add 500 mana
        battery:SetCurrentCharges(battery:GetCurrentCharges() - 1)
        hero:GiveMana(500)
            
        -- Remove item if no charges are left
        if (battery:GetCurrentCharges() == 0) then
            hero:RemoveItem(battery)
        end
    end
end

function BatteryUse ( event )
    local hero = event.caster
    local battery = event.ability
  
    -- Check that owner has over 100 intelligence and isn't on maximum mana
    if (hero:GetIntellect() >= 100) and (hero:GetMana() < hero:GetMaxMana()) then
  
        -- Take off a charge and add 500 mana
        battery:SetCurrentCharges(battery:GetCurrentCharges() - 1)
        hero:GiveMana(500)
        
        -- Remove item if no charges are left
        if (battery:GetCurrentCharges() == 0) then
            hero:RemoveItem(battery)
        end
    end
end	



