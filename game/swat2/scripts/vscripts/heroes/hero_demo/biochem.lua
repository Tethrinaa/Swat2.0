function OnSpellStart(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local efficiency = ability:GetSpecialValueFor("base_efficiency") -- TODO needs demo rank bonus
	local energyNeeded = caster:GetMaxMana() - caster:GetMana()
	local life = ability:GetSpecialValueFor("max_life_percent") * target:GetHealth()
	local resistant = 1.0
	local loss = ability:GetSpecialValueFor("base_loss")
	local loss_factor = ability:GetSpecialValueFor("loss_factor")
	
	if false then -- TODO remove fireflies as valid targets
		
	end
	
	if target:IsHero() or true then -- TODO add condition for enemy umbrellas
		-- TODO add nem resistant
		resistant = .5
	elseif false then
		-- TODO add miniboss resistant
	end
	
	if target == caster then
		efficiency = efficiency * 2.0
	end
	
	if energyNeeded < ability:GetCooldown(ability:GetLevel()) * ability:GetSpecialValueFor("min_eps") then
		-- TODO may need a lua ability to do custom validation messages - too little energyNeeded
		
	end
	
	if life * efficiency * resistant < 40 then 
		-- TODO may need a lua ability to do custom validation messages - too little health on target
	end	
	
	if true then -- TODO abort alice's KS and forcefields
		if life * efficiency > energyNeeded then
			life = energyNeeded / efficiency
		end
		target:ModifyHealth(target:GetHealth() - life * resistant, keys.ability, false, DOTA_DAMAGE_FLAG_NONE)
		
		energyNeeded = math.min(life, 1125) * efficiency
		life = life - 1125
		while life > 0 do
			efficiency = efficiency - loss
			loss = loss * loss_factor
			if efficiency < .01 then
				efficiency = .01
			end
			energyNeeded = energyNeeded + math.min(life, 125) * efficiency
			life = life - 125
		end
		
		caster:GiveMana(energyNeeded*resistant)
	end
end

--[[function Trig_BioChemEnergy_Actions takes nothing returns nothing
  local unit oHero = GetSpellAbilityUnit()
  local unit oUnit = GetSpellTargetUnit()
  local real nEfficiency = 0.35 + GetRandomReal(0.03*RedRankLevel(GetPlayerId(RedGetOwningPlayer(oHero))), 0.31)
  local real nEnergyNeeded = GetUnitState(oHero, UNIT_STATE_MAX_MANA) - GetUnitState(oHero, UNIT_STATE_MANA)
  local real nLife = 0.5*GetUnitState(oUnit, UNIT_STATE_LIFE)
  local real nResistant = 1.0
  local real nLoss = 0.01
  local lightning fx = null

  if GetUnitTypeId(oUnit) == 'u00B' then //fireflies will always fill up energy otherwise
    call RedMsg(RedGetOwningPlayer(oHero), "Transfer aborted. Invalid target.")
    call RedResetCooldown(oHero, 'A02C', 19, false)
    return
  endif

  if IsUnitType(oUnit, UNIT_TYPE_HERO) or (IsUnitType(oUnit, UNIT_TYPE_ANCIENT) and (GetPlayerId(RedGetOwningPlayer(oUnit)) > 9)) then
    if oUnit == udg_Nemesis then
      set nResistant = 0.25
    else
      set nResistant = 0.5
    endif
  elseif GetUnitAbilityLevel(oUnit, 'AIlz') > 0 then //miniboss
    set nResistant = 0.75
  endif

  if oHero == oUnit then //twice as efficient to beam self
    set nEfficiency = nEfficiency * 2.0
  endif

  //prevent draining nearly dead units so no div 0 error
  //also doesn't waste cooldown if energy gain would be less than 2eps
  if nEnergyNeeded < 40.0 then
    call RedMsg(RedGetOwningPlayer(oHero), "Transfer aborted. Energy level near capacity.")
    call RedResetCooldown(oHero, 'A02C', 19, false)
    return
  endif
  if (nLife*nEfficiency*nResistant) < 40.0 then 
    call RedMsg(RedGetOwningPlayer(oHero), "Transfer aborted. Target health insufficient.")
    call RedResetCooldown(oHero, 'A02C', 19, false)
    return
  endif

  if GetUnitAbilityLevel(oUnit, 'A09D') != 2 and GetUnitAbilityLevel(oUnit, 'A0S9') < 1 then //force field / KS not on
    if (nLife*nEfficiency) > nEnergyNeeded then
      set nLife = nEnergyNeeded/nEfficiency
    endif
    call SetUnitState(oUnit, UNIT_STATE_LIFE, GetUnitState(oUnit, UNIT_STATE_LIFE) - nLife*nResistant)

    //reduce the amount of energy received per hp for higher energy transfers. note that this doesn't reduce the hp lost by the target
    set nEnergyNeeded = RMinBJ(nLife, 1125.0)*nEfficiency
    set nLife = nLife - 1125.0
    loop
      exitwhen nLife < 1.0
      set nEfficiency = nEfficiency - nLoss
      set nLoss = nLoss + nLoss
      if nEfficiency < 0.01 then
        set nEfficiency = 0.01
      endif
      set nEnergyNeeded = nEnergyNeeded + RMinBJ(nLife, 125.0)*nEfficiency
      set nLife = nLife - 125.0
    endloop

    call SetUnitState(oHero, UNIT_STATE_MANA, GetUnitState(oHero, UNIT_STATE_MANA) + nEnergyNeeded*nResistant)
  endif

  if oHero != oUnit then
    set fx = AddLightningEx( "DRAM", true, GetUnitX(oHero), GetUnitY(oHero), 50, GetUnitX(oUnit), GetUnitY(oUnit), 50 )
    call SetLightningColor(fx, 1, 0.75, 0.75, 1)
    call TriggerSleepAction(0.1)
    call DestroyLightning(fx)
    set fx = null
  endif
endfunction]]