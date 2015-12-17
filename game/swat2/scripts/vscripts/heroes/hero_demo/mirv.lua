--[[Author: NSEnigma
	Date: 2015.10.7
	]]
	
function PolarOffset(src, range, angle)
	return src + Vector( range * math.cos( angle ), range * math.sin( angle ))
end

function FixAngleDeg(angle)
	while (angle < 0.0 or angle >= 360 ) do
		angle = angle < 0 and (angle + 360) or (angle - 360)
	end
  return angle
end

function FixAngleRad(angle)
  while (angle < 0.0 or angle >= math.pi * 2 ) do
		angle = angle < 0 and (angle + math.pi * 2) or (angle - math.pi * 2)
	end
  return angle
end

function OnProjectileFinish( keys )
	-- Setup your source dist and initial trajectory if you don't already have them
    if not keys.dest then
		keys.dest = keys.target_points[1]
	end
	if not keys.nTrajectory then
		v = (keys.dest - keys.caster:GetAbsOrigin())
		keys.nTrajectory = math.atan2(v.y,v.x)
	end
	

	-- This thinker will explode OnCreate and then host the napalm (damage and armor redux) for the duration
	keys.ability:ApplyDataDrivenThinker(keys.caster, keys.dest, "modifier_demo_mirv_thinker", keys)

	-- If you have no more explosions left, then just stop
	keys.iMIRV = keys.iMIRV - 1
	if not keys.iMIRV or keys.iMIRV < 1 then return end
	
	-- Else pick a new location and recurse after a delay
	local castDistance = RandomInt( keys.minDistance, keys.maxDistance )
	print(math.deg(keys.nTrajectory))
  local angle = FixAngleRad( keys.nTrajectory + math.rad(math.random(-1 * keys.slop,keys.slop)))
	print(math.deg(angle))
	
  keys.dest = PolarOffset(keys.dest, castDistance, angle)
  Timers:CreateTimer( keys.delay, function()
		OnProjectileFinish( keys )
	end )
end

