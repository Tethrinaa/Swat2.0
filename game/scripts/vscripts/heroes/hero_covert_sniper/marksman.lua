--[[Concussion Grenade
	Author: Dokuno
	Date: 17.09.2015.]]
-- Pre fetch damage delt and target location (before it gets deadz)
-- On kills with a pierce roll create a linear projectile at the dead location in a line between
-- the caster and corpse. Max projectile range = caster attack range. 
   
   
-- Gets target AbsOrigin before it dies.   
function getTargetLocation( params )
   target_abs_origin = params.target:GetAbsOrigin()
   --print ("Attack Landed. Target AbsOrigin = ", target_abs_origin)
   return target_abs_origin
end

-- Gets the damage delt (after damage mitigation)
function getDamageDealt( params )
   kill_damage = params.kill_damage
   --print("Kill Damage: ", kill_damage)
   return kill_damage
end

-- Create a linear projectile for the piecred shot
function Pierce( params )
   if (target_abs_origin == nil) then
      return 0
   end
   local target = params.target
   local caster = params.caster
   local shot_path = target_abs_origin - caster:GetAbsOrigin()
   if (kill_damage == nil) then
      kill_damage = caster:GetAttackDamage()
   end

   -- Info for a CreateLinearProjectile
   local info = 
   {
      Ability = params.ability,
      EffectName = "particles/units/heroes/hero_sniper/sniper_base_attack.vpcf",
      vSpawnOrigin = target_abs_origin, -- Projectile starts from dead target
      fDistance = caster:GetAttackRange() - shot_path:Length2D(), -- Max range is from the caster
      fStartRadius = 32,
      fEndRadius = 32,
      Source = caster,
      bHasFrontalCone = true,
      iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
      iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
      iUnitTargetType =  DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
      bDeleteOnHit = true,
      vVelocity = shot_path * (caster:GetProjectileSpeed()/shot_path:Length2D()),
      bProvidesVision = false
   }
   if ( info.fDistance > 0 ) then
      projectile = ProjectileManager:CreateLinearProjectile(info)
   end
   return 0
end

function PierceHit( params )
   if ( kill_damage == nil ) then
      print("No Damage Found")
      kill_damage = params.caster:GetAttackDamage()
   end
   
	local damage_table = {}
	damage_table.attacker = params.caster
	damage_table.victim = params.target
	damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
	damage_table.ability = params.ability   
   damage_table.damage = kill_damage
	ApplyDamage(damage_table)
end

-- Function not currently used.
function EndPierce( params )
   if (projectile == nil ) then
      return 0
   end
   ProjectileManager:DestroyLinearProjectile(projectile)
end
