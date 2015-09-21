--[[Concussion Grenade
	Author: Dokuno
	Date: 17.09.2015.]]

-- Gets target AbsOrigin before it dies.   
function GetTargetLocation( params )
   target_abs_origin = params.target:GetAbsOrigin()
   print ("Attack Landed. Target AbsOrigin = ", target_abs_origin)
   return target_abs_origin
end

-- Create a linear projectile for the piecred shot
function Pierce( params )
   if ( target_abs_origin == nil ) then
      print("No Target AbsOrigin", target_abs_origin)
      return 0
   else
      print("Target Killed. AbsOrigin = ", target_abs_origin)
   end
   local target = params.target
   local caster = params.caster
   --local shot_path = target:GetAbsOrigin() - caster:GetAbsOrigin()
   local shot_path = target_abs_origin - caster:GetAbsOrigin()
   kill_damage = caster:GetAttackDamage()
   print("Kill Damage: ", kill_damage)
   
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
      bDeleteOnHit = false,
      vVelocity = shot_path,
      bProvidesVision = false
      --iMoveSpeed = caster:GetProjectileSpeed()
   }
   if ( info.fDistance > 0 ) then
      projectile = ProjectileManager:CreateLinearProjectile(info)
      print("Launch Projectile", projectile)
   end
   return 0
end

function PierceHit( params )
   if ( kill_damage == nil ) then
      print("No Damage Found")
      kill_damage = params.caster:GetAttackDamage()
   else  
      print("Killing Damage: ", kill_damage)
   end
   
	local damage_table = {}
	damage_table.attacker = params.caster
	damage_table.victim = params.target
	damage_table.damage_type = DAMAGE_TYPE_PHYSICAL
	damage_table.ability = params.ability   
   damage_table.damage = kill_damage
	ApplyDamage(damage_table)
end

--Creates a projectile that will travel 2000 units
function fire_arrow(args)
   print({})
	local caster = args.caster
	--A Liner Projectile must have a table with projectile info
	local info = 
	{
		Ability = args.ability,
      EffectName = "particles/units/heroes/hero_mirana/mirana_spell_arrow.vpcf",
      vSpawnOrigin = caster:GetAbsOrigin(),
      fDistance = 2000,
      fStartRadius = 64,
      fEndRadius = 64,
      Source = caster,
      bHasFrontalCone = false,
      bReplaceExisting = false,
      iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
      iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
      iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
      fExpireTime = GameRules:GetGameTime() + 10.0,
		bDeleteOnHit = true,
		vVelocity = caster:GetForwardVector() * 1800,
		bProvidesVision = true,
		iVisionRadius = 1000,
		iVisionTeamNumber = caster:GetTeamNumber()
	}
	projectile = ProjectileManager:CreateLinearProjectile(info)
end

arrowTable = arrowTable or {}
function LaunchArrow( keys )
	local caster = keys.caster
	local caster_location = caster:GetAbsOrigin()

	arrowTable[caster] = arrowTable[caster] or {}

	arrowTable[caster].location = caster_location
end