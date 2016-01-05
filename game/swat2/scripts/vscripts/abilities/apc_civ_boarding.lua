-- Called when a unit enters the boarding aura
function unit_enters_boarding_aura(keys)
    local unit = keys.target
    local unitName = unit:GetUnitName()
    local apc = keys.caster

    if unitName == "civillian_male" or unitName == "civillian_female" then
        -- Alert CivillianManager of civillians that walk into this aura
        g_CivillianManager:onCivBoardsApc(apc, unit)
    end
end
