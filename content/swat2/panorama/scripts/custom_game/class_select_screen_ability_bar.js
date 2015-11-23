"use strict";

//table of classes and their abilities
var cyborg = ["primary_cyborg_cluster_rockets_lua_ability","primary_cyborg_xtreme_combat_mode","primary_cyborg_organic_replacement","cyborg_pheromones","cyborg_emergency_power","cyborg_goliath_modification", "cyborg_forcefield_lua_ability" ];
var demo = ["primary_demo_mirv","primary_demo_place_c4","primary_demo_advanced_generator", "demo_biochemical_energy","demo_gear_mod","demo_mini_nuke","demo_sma"];
var ho = ["primary_ho_plasma_shield","primary_ho_storage_cells","ho_power_grid","ho_construct_droid","ho_xlr8","ho_recharge_battery"];
var maverick = ["primary_maverick_plasma_grenade","primary_maverick_robodog","primary_maverick_advanced_generator","maverick_nano_injection","maverick_reprogram"];
var medic = ["primary_medic_nano_injection","primary_medic_mend_wounds","primary_medic_adrenaline_junkie","medic_adrenaline","medic_rapid_therapy","medic_mending_station","medic_revive"];
var psychologist = ["primary_psychologist_mental_clarity","primary_psychologist_confidence","primary_psychologist_self_motivation", "psychologist_mind_slay","psychologist_mind_rot","psychologist_clairvoyance"];
var sniper = ["primary_sniper_concussion_grenade","primary_sniper_aim","primary_sniper_marksman","primary_sniper_critical_shot","sniper_item_teleport","sniper_construct_camera","sniper_sneak"];
var tactician = ["primary_tactician_weakpoint","primary_tactician_blitz","primary_tactician_endurance","tactician_pep_talk","tactician_ion_strike","tactician_recruit"];
var techops = [ "" ];
var pyro = [ "" ];

var m_WeaponAbilityPanels = []; // created up to a high-water mark, but reused when selection changes
var m_AbilityPanels = []; // created up to a high-water mark, but reused when selection changes
var m_ArmorAbilityPanels = []; // created up to a high-water mark, but reused when selection changes


function SetWeaponAbility( weapon )
{
	var abilityListPanel = $( "#weapon_ability" );
	if ( !abilityListPanel )
		return;
	
	// update all the panels
	var nUsedPanels = 0;
	for ( var i = 0; i < 1; ++i )
	{
		var ability = m_WeaponAbilityPanels[i];
		if ( nUsedPanels >= m_WeaponAbilityPanels.length )
		{
			// create a new panel
			var abilityPanel = $.CreatePanel( "Panel", abilityListPanel, "" );
			abilityPanel.BLoadLayout( "file://{resources}/layout/custom_game/class_select_screen_ability.xml", false, false );
			m_WeaponAbilityPanels.push( abilityPanel );
		}
		
		// update the panel for the current ability
		var abilityPanel = m_WeaponAbilityPanels[ nUsedPanels ];
		var weaponSubstring = weapon.substring(0, 5);
		var weaponAbilityName = ""
	
		if ( weaponSubstring == "flame" )
		{
			weaponAbilityName = "weapon_flamethrower";
		}
		else 
		{
			weaponAbilityName = "weapon_"+weapon;
		}

		abilityPanel.data().SetAbility( weaponAbilityName );
		nUsedPanels++;
	}
	
	// clear any remaining panels
	for ( var i = nUsedPanels; i < m_WeaponAbilityPanels; ++i )
	{
		var abilityPanel = m_WeaponAbilityPanels[ i ];
		abilityPanel.data().SetAbility( -1, -1, false );
	}
}

function SetArmorAbility( armor )
{
	var abilityListPanel = $( "#armor_ability" );
	if ( !abilityListPanel )
		return;
	
	// update all the panels
	var nUsedPanels = 0;
	for ( var i = 0; i < 1; ++i )
	{
		var ability = m_ArmorAbilityPanels[i];
		if ( nUsedPanels >= m_ArmorAbilityPanels.length )
		{
			// create a new panel
			var abilityPanel = $.CreatePanel( "Panel", abilityListPanel, "" );
			abilityPanel.BLoadLayout( "file://{resources}/layout/custom_game/class_select_screen_ability.xml", false, false );
			m_ArmorAbilityPanels.push( abilityPanel );
		}
		
		// update the panel for the current ability
		var abilityPanel = m_ArmorAbilityPanels[ nUsedPanels ];
		if ( armor == "light" )
		{
			abilityPanel.data().SetAbility( "nanites_compact" );
		}
		else if ( armor == "medium" )
		{
			abilityPanel.data().SetAbility( "nanites_standard" );
		}
		else if ( armor == "heavy" || armor == "advanced")
		{
			abilityPanel.data().SetAbility( "nanites_heavy" );
		}
		else
		{
			abilityPanel.data().SetAbility( "" );
		}
		
		nUsedPanels++;
	}
	
	// clear any remaining panels
	for ( var i = nUsedPanels; i < m_ArmorAbilityPanels.length; ++i )
	{
		var abilityPanel = m_ArmorAbilityPanels.length[ i ];
		abilityPanel.data().SetAbility( "" );
	}
}

function SetPlayerAbilities( playerclass )
{
	var abilityList;
	if (playerclass == "cyborg" ) { abilityList = cyborg; }
	else if (playerclass == "demo" ) { abilityList = demo; }
	else if (playerclass == "ho" ) { abilityList = ho; }
	else if (playerclass == "maverick" ) { abilityList = maverick; }
	else if (playerclass == "medic" ) { abilityList = medic; }
	else if (playerclass == "psychologist" ) { abilityList = psychologist; }
	else if (playerclass == "sniper" ) { abilityList = sniper; }
	else if (playerclass == "tactician" ) { abilityList = tactician; }
	else if (playerclass == "techops" ) { abilityList = techops; }
	else if (playerclass == "pyro" ) { abilityList = pyro; }
	else { return; }
	
	var abilityListPanel = $( "#player_ability_list" );
	if ( !abilityListPanel )
		return;
	
	// update all the panels
	var nUsedPanels = 0;
	for ( var i = 0; i < abilityList.length; ++i )
	{
		var ability = abilityList[i];
		if ( nUsedPanels >= m_AbilityPanels.length )
		{
			// create a new panel
			var abilityPanel = $.CreatePanel( "Panel", abilityListPanel, "" );
			abilityPanel.BLoadLayout( "file://{resources}/layout/custom_game/class_select_screen_ability.xml", false, false );
			m_AbilityPanels.push( abilityPanel );
		}
		
		// update the panel for the current ability
		//TODO REMOVE
		var mssg = "setting panel "+i+" to "+ability;
		$.Msg( mssg );
		
		var abilityPanel = m_AbilityPanels[ nUsedPanels ];
		abilityPanel.visible = true;
		abilityPanel.data().SetAbility( ability );
		
		nUsedPanels++;
	}
	
	// clear any remaining panels
	for ( var i = nUsedPanels; i < m_AbilityPanels.length; ++i )
	{
		var mssg = "setting panel "+i+" to empty";
		$.Msg( mssg );
		var abilityPanel = m_AbilityPanels[ i ];
		abilityPanel.visible = false;
	}
}

(function()
{
	$.GetContextPanel().data().SetWeaponAbility = SetWeaponAbility;
	$.GetContextPanel().data().SetArmorAbility = SetArmorAbility;
	$.GetContextPanel().data().SetPlayerAbilities = SetPlayerAbilities;
})();

