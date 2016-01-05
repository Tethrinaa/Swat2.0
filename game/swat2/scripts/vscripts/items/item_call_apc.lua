-- Called the Call APC item is bought
function call_apc(keys)
    -- Tell Civillian manager to spawn an APC
    g_CivillianManager:spawnApc()

    -- Remove the item too
    -- Why is this in a timer and why not just use SpendCharge {} in the item?
    -- Because there is a dumb bug in dota 2 where the stock of the shop does not go down
    -- if the item immediately disappears on pickup. So we have to wait just a tad
    Timers:CreateTimer(0.01, function()
        keys.caster:RemoveItem(keys.ability)
    end)
end
