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
         
function DropItemOnDeath(keys) -- keys is the information sent by the ability
	print( '[ItemFunctions] DropItemOnDeath Called' )
	local killedUnit = EntIndexToHScript( keys.caster_entindex ) -- EntIndexToHScript takes the keys.caster_entindex, which is the number assigned to the entity that ran the function from the ability, and finds the actual entity from it.
	local itemName = tostring(keys.ability:GetAbilityName()) -- In order to drop only the item that ran the ability, the name needs to be grabbed. keys.ability gets the actual ability and then GetAbilityName() gets the configname of that ability such as juggernaut_blade_dance.
	if killedUnit:IsHero() or killedUnit:HasInventory() then -- In order to make sure that the unit that died actually has items, it checks if it is either a hero or if it has an inventory.
		for itemSlot = 0, 5, 1 do --a For loop is needed to loop through each slot and check if it is the item that it needs to drop
	        	if killedUnit ~= nil then --checks to make sure the killed unit is not nonexistent.
                		local Item = killedUnit:GetItemInSlot( itemSlot ) -- uses a variable which gets the actual item in the slot specified starting at 0, 1st slot, and ending at 5,the 6th slot.
                		if Item ~= nil and Item:GetName() == itemName then -- makes sure that the item exists and making sure it is the correct item
                			local newItem = CreateItem(itemName, nil, nil) -- creates a new variable which recreates the item we want to drop and then sets it to have no owner
                    			CreateItemOnPositionSync(killedUnit:GetOrigin(), newItem) -- takes the newItem variable and creates the physical item at the killed unit's location
                    			killedUnit:RemoveItem(Item) -- finally, the item is removed from the original units inventory.
                		end
	        	end
		end
	end
end


function ItemCheck( event )
    local itemName = event.ability:GetAbilityName()
    local hero = EntIndexToHScript( event.caster_entindex )
    local itemTable = GameMode.ItemInfoKV[itemName]
    print("Checking Restrictions for "..itemName)
    DeepPrintTable(itemTable)

    -- if there is no subtable for this item, end this script
    if itemTable == nil then
		print("no subtable for this item!")
        return true
    end

    -- This timer is needed because OnEquip triggers before the item actually being in inventory
    Timers:CreateTimer(0.1,function()
        -- Go through every item slot
        for itemSlot = 0, 5, 1 do 
            local Item = hero:GetItemInSlot( itemSlot )
            -- When we find the item we want to check
            if Item ~= nil and itemName == Item:GetName() then
                DeepPrintTable(Item)

                -- Check Int Restriction
                if itemTable.intRequired then
                    print("Name","int Req","Hero Level")
                    print(itemName,itemTable.intRequired,hero:GetLevel())
                    -- If the hero doesn't met the level required, show message and disable item
                    if itemTable.intRequired > hero:GetIntellect() then
                        FireGameEvent( 'custom_error_show', { player_ID = pID, _error = "You need level "..itemTable.intRequired.." to use this." } )
                        --DropItem(Item, hero) //need to disable item instead
                    end 
                end
                
            end
        end
    end)
end

function DropItem( item, hero )
    -- Error Sound
    EmitSoundOnClient("General.CastFail_InvalidTarget_Hero", hero:GetPlayerOwner())

    -- Create a new empty item
    local newItem = CreateItem( item:GetName(), nil, nil )
    newItem:SetPurchaseTime( 0 )

    -- This is needed if you are working with items with charges, uncomment it if so.
    -- newItem:SetCurrentCharges( goldToDrop )

    -- Make a new item and launch it near the hero
    local spawnPoint = Vector( 0, 0, 0 )
    spawnPoint = hero:GetAbsOrigin()
    local drop = CreateItemOnPositionSync( spawnPoint, newItem )
    newItem:LaunchLoot( false, 200, 0.75, spawnPoint + RandomVector( RandomFloat( 50, 150 ) ) )

    --finally, remove the item
    hero:RemoveItem(item)
end
