-- This class is used to tint units based on their abilities


-- Tints the unit for burninating
function tint_burninating(keys)
    keys.caster:SetRenderColor(133, 0, 0)
end

-- Tints the unit for toxic
function tint_toxic(keys)
    keys.caster:SetRenderColor(107, 142, 35)
end

-- Tints the unit for tnt
function tint_tnt(keys)
    keys.caster:SetRenderColor(240, 150, 150)
end

-- Tints the unit for radinating
function tint_radinating(keys)
    keys.caster:SetRenderColor(80, 255, 0)
end

-- Tints the unit for lightenating
function tint_lightenating(keys)
    keys.caster:SetRenderColor(255, 255, 0)
end
