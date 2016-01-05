-- Author: NmdSnprEnigma

--- Sends the event that opens the SubMenu for the user
function OpenSubMenu(keys)
	CustomGameEventManager:Send_ServerToPlayer( keys.caster:GetPlayerOwner(), "OpenSubMenu", {name = "cells_and_droids"} )
end

--- Sends the event that opens the SubMenu for the user
function CloseSubMenu(keys)
	CustomGameEventManager:Send_ServerToPlayer( keys.caster:GetPlayerOwner(), "CloseSubMenu", {} ) -- TODO This needs to hide the box if it's not in use - at start there is a tiny square
end