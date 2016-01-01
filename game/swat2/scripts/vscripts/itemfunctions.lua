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
    --DeepPrintTable(itemTable)

    -- if there is no subtable for this item, end this script
    if itemTable == nil then
        print("no subtable for this item!")
        return true
    end

    -- Check Int Restriction
    if itemTable.intRequired then
        --print("Name","int Req","Hero Int")
        --print(itemName,itemTable.intRequired,hero:GetIntellect())
        -- If the hero doesn't met the int required
        if itemTable.intRequired > hero:GetIntellect() then

        else
            print("applying data driven modifier")
            event.ability:ApplyDataDrivenModifier( hero, hero, itemTable.ModifiersAdd, {duration=-1} )
        end
    end
end

function RemoveItemModifierStats( event )
    local itemName = event.ability:GetAbilityName()
    local hero = EntIndexToHScript( event.caster_entindex )
    local itemTable = GameMode.ItemInfoKV[itemName]

    -- if there is no subtable for this item, end this script
    if itemTable == nil then
        print("no subtable for this item!")
        return true
    end

    -- Check Int Restriction
    if itemTable.intRequired then
        --print("Name","int Req","Hero Int")
        --print(itemName,itemTable.intRequired,hero:GetIntellect())
        -- If the hero doesn't met the int required, show message and disable item
        if itemTable.intRequired > hero:GetIntellect() then
            --FireGameEvent( 'custom_error_show', { player_ID = pID, _error = "You need int "..itemTable.intRequired.." to use this." } )
            --DropItem(Item, hero)
        else

            --Check if the item is stacking and that the hero is dead
            local modifier = hero:FindModifierByNameAndCaster(itemTable.ModifiersAdd, hero)
            if (hero:IsAlive() and itemName == "item_rapid_reload") then
                print("dropped item is potentially stacking")
                local duplicateItem = false

                --Check for duplicate item

                for itemSlot = 0, 5, 1 do
                    local itemInSlot = hero:GetItemInSlot( itemSlot )
                    if (itemInSlot ~= nil and itemName == itemInSlot:GetAbilityName()) then
                        duplicateItem = true
                        print("duplicate item detected")
                    end
                end

                if (duplicateItem == false) then
                    print("no duplicate detected")
                    print("removing data driven modifier")
                    modifier:Destroy()
                end

            else
                print("removing data driven modifier")
                modifier:Destroy()
            end
        end
    end
end


function HazmatCheck( event )
    local itemName = event.ability:GetAbilityName()
    local hero = EntIndexToHScript( event.caster_entindex )

    if (hero:IsHero()) then

        --Check not already carrying hazmat
        local hazmatNumber = 0

        for itemSlot = 0, 5, 1 do
            local itemInSlot = hero:GetItemInSlot( itemSlot )
            if (itemInSlot ~= nil and itemName == itemInSlot:GetAbilityName()) then
                hazmatNumber = (hazmatNumber + 1)
            end
        end

        if (hazmatNumber ~= 1) then
            local newItem = CreateItem(itemName, nil, nil)
            CreateItemOnPositionSync(hero:GetOrigin(), newItem)
            hero:RemoveItem(event.ability)
        end
    end
end
