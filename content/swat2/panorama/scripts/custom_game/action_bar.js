"use strict";

var m_NaniteAbilityPanels = []; // created up to a high-water mark, but reused when selection changes
var m_WeaponAbilityPanels = []; // created up to a high-water mark, but reused when selection changes
var m_PrimaryAbilityPanels = []; // created up to a high-water mark, but reused when selection changes
var m_SecondaryAbilityPanels = []; // created up to a high-water mark, but reused when selection changes

function OnLevelUpClicked()
{
	if ( Game.IsInAbilityLearnMode() )
	{
		Game.EndAbilityLearnMode();
	}
	else
	{
		Game.EnterAbilityLearnMode();
	}
}

function OnAbilityLearnModeToggled( bEnabled )
{
	UpdateAbilityList();
}

function UpdateAbilityList()
{
	// make sure xml files are loaded before running function
	var naniteListPanel = $( "#nanite_list" );
	if ( !naniteListPanel )
		return;
	var weaponListPanel = $( "#weapon_list" );
	if ( !weaponListPanel )
		return;
	var primaryAbilityListPanel = $( "#primary_ability_list" );
	if ( !primaryAbilityListPanel )
		return;
	var secondaryAbilityListPanel = $( "#secondary_ability_list" );
	if ( !secondaryAbilityListPanel )
		return;
	
	var queryUnit = Players.GetLocalPlayerPortraitUnit();

	// see if we can level up
	var nRemainingPoints = Entities.GetAbilityPoints( queryUnit );
	var bPointsToSpend = ( nRemainingPoints > 0 );
	var bControlsUnit = Entities.IsControllableByPlayer( queryUnit, Game.GetLocalPlayerID() );
	$.GetContextPanel().SetHasClass( "could_level_up", ( bControlsUnit && bPointsToSpend ) );

	// update all the panels 
	var nUsedNanitePanels = 0;
	var nUsedWeaponPanels = 0;
	var nUsedPrimaryPanels = 0;
	var nUsedSecondaryPanels = 0;
	for ( var i = 0; i < Entities.GetAbilityCount( queryUnit ); ++i )
	{
		var ability = Entities.GetAbility( queryUnit, i );
		var ability_name = Abilities.GetAbilityName( ability );
		var index = ability_name.indexOf("_");
		var ability_type = ability_name.substring(0, index);
		
		if ( ability == -1 )
			continue;

		if ( !Abilities.IsDisplayedAbility(ability) )
			continue;
		
		
		if (ability_type == "nanites") {
			if ( nUsedNanitePanels >= m_NaniteAbilityPanels.length )
			{
				// create a new panel
				var naniteAbilityPanel = $.CreatePanel( "Panel", naniteListPanel, "" );
				naniteAbilityPanel.BLoadLayout( "file://{resources}/layout/custom_game/action_bar_ability.xml", false, false );
				m_NaniteAbilityPanels.push( naniteAbilityPanel );
			}

			// update the panel for the current unit / ability
			var naniteAbilityPanel = m_NaniteAbilityPanels[ nUsedNanitePanels ];
			naniteAbilityPanel.data().SetAbility( ability, queryUnit, Game.IsInAbilityLearnMode() );
		
			nUsedNanitePanels++;	
		}
		
		else if (ability_type == "weapon") {
			if ( nUsedWeaponPanels >= m_WeaponAbilityPanels.length )
			{
				// create a new panel
				var weaponAbilityPanel = $.CreatePanel( "Panel", weaponListPanel, "" );
				weaponAbilityPanel.BLoadLayout( "file://{resources}/layout/custom_game/action_bar_ability.xml", false, false );
				m_WeaponAbilityPanels.push( weaponAbilityPanel );
			}

			// update the panel for the current unit / ability
			var weaponAbilityPanel = m_WeaponAbilityPanels[ nUsedWeaponPanels ];
			weaponAbilityPanel.data().SetAbility( ability, queryUnit, Game.IsInAbilityLearnMode() );
		
			nUsedWeaponPanels++;
	
		}
		
		else if (ability_type == "primary") {
			if ( nUsedPrimaryPanels >= m_PrimaryAbilityPanels.length )
			{
				// create a new panel
				var primaryAbilityPanel = $.CreatePanel( "Panel", primaryAbilityListPanel, "" );
				primaryAbilityPanel.BLoadLayout( "file://{resources}/layout/custom_game/action_bar_ability.xml", false, false );
				m_PrimaryAbilityPanels.push( primaryAbilityPanel );
			}

			// update the panel for the current unit / ability
			var primaryAbilityPanel = m_PrimaryAbilityPanels[ nUsedPrimaryPanels ];
			primaryAbilityPanel.data().SetAbility( ability, queryUnit, Game.IsInAbilityLearnMode() );
		
			nUsedPrimaryPanels++;	
		}
		
		else {
			if ( nUsedSecondaryPanels >= m_SecondaryAbilityPanels.length )
			{
				// create a new panel
				var secondaryAbilityPanel = $.CreatePanel( "Panel", secondaryAbilityListPanel, "" );
				secondaryAbilityPanel.BLoadLayout( "file://{resources}/layout/custom_game/action_bar_ability.xml", false, false );
				m_SecondaryAbilityPanels.push( secondaryAbilityPanel );
			}

			// update the panel for the current unit / ability
			var secondaryAbilityPanel = m_SecondaryAbilityPanels[ nUsedSecondaryPanels ];
			secondaryAbilityPanel.data().SetAbility( ability, queryUnit, Game.IsInAbilityLearnMode() );
		
			nUsedSecondaryPanels++;	
		}
	}

	// clear any remaining panels
	for ( var i = nUsedNanitePanels; i < m_NaniteAbilityPanels.length; ++i )
	{
		var naniteAbilityPanel = m_NaniteAbilityPanels[ i ];
		naniteAbilityPanel.data().SetAbility( -1, -1, false );
	}
	
	for ( var i = nUsedWeaponPanels; i < m_WeaponAbilityPanels.length; ++i )
	{
		var weaponAbilityPanel = m_WeaponAbilityPanels[ i ];
		weaponAbilityPanel.data().SetAbility( -1, -1, false );
	}
	
	for ( var i = nUsedPrimaryPanels; i < m_PrimaryAbilityPanels; ++i )
	{
		var primaryAbilityPanel = m_PrimaryAbilityPanels[ i ];
		primaryAbilityPanel.data().SetAbility( -1, -1, false );
	}
	
	for ( var i = nUsedSecondaryPanels; i < m_SecondaryAbilityPanels; ++i )
	{
		var secondaryAbilityPanel = m_SecondaryAbilityPanels[ i ];
		secondaryAbilityPanel.data().SetAbility( -1, -1, false );
	}
}

(function()
{
    $.RegisterForUnhandledEvent( "DOTAAbility_LearnModeToggled", OnAbilityLearnModeToggled);

	GameEvents.Subscribe( "dota_portrait_ability_layout_changed", UpdateAbilityList );
	GameEvents.Subscribe( "dota_player_update_selected_unit", UpdateAbilityList );
	GameEvents.Subscribe( "dota_player_update_query_unit", UpdateAbilityList );
	GameEvents.Subscribe( "dota_ability_changed", UpdateAbilityList );
	GameEvents.Subscribe( "dota_hero_ability_points_changed", UpdateAbilityList );
	
	UpdateAbilityList(); // initial update
})();

