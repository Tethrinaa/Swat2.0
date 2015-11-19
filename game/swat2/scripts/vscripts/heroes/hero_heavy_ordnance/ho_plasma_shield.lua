LinkLuaModifier( "modifier_ho_plasma_shield_aura", "heroes/hero_heavy_ordnance/modifier_ho_plasma_shield_aura", LUA_MODIFIER_MOTION_NONE )

function ApplyAura(keys)
    keys.caster:AddNewModifier(keys.caster, keys.ability, "modifier_ho_plasma_shield_aura", {})
end