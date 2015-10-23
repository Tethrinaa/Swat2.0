function setActive(keys)
	DeepPrintTable(keys)
	keys.ability:SetActivated(true)
end

function OnSpellStart(keys)
	-- commies flee
	-- create laser
	
	-- .25 wait
	
	-- nuke flies up
	
	-- 2.75 (3.00)
	
	-- 1 second if over 2500 distance left
	-- 1 second if over 2500 distance left
	-- umbs FF
	-- wait remaining_distance/2500
	-- explode nuke

	local src = keys.caster:GetAbsOrigin()
	local dest = keys.target_points[1]
	local v = (dest - src)
	local dist = v:Length()
	keys.duration = 3 + dist/2500
	
	keys.ability:SetActivated(false)
	
	local params = {}
	
	params.duration = keys.duration
	params.inner_radius = keys.inner_radius
	params.outer_radius = keys.outer_radius
	params.inner_damage = math.max(keys.inner_damage - keys.outer_damage, 0)
	params.outer_damage = keys.outer_damage
	
	-- This thinker will wait then detonate
	keys.ability:ApplyDataDrivenThinker(keys.caster, keys.target_points[1], "modifier_demo_mini_nuke_thinker", params)
end