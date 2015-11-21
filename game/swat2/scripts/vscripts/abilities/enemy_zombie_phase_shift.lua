function HideCaster( event )
    event.caster:AddNoDraw()
end

function ShowCaster( event )
    event.caster:RemoveNoDraw()
end
