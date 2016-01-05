sub_ho_storage_cells = class({})
LinkLuaModifier( "modifier_ho_storage_cells_regen", "heroes/hero_heavy_ordnance/modifier_ho_storage_cells_regen.lua", LUA_MODIFIER_MOTION_NONE )

--- Returns the passive modifier of this ability
function sub_ho_storage_cells:GetIntrinsicModifierName()
	return "modifier_ho_storage_cells_regen"
end