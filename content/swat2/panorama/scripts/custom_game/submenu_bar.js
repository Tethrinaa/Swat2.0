"use strict";

//TODO: Fix tooltips popping up from underneath, enemy ability bars not loading properly
//TODO: see if I can set up hotkeys


var m_SubmenuAbilityPanels = []; // created up to a high-water mark, but reused when selection changes

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

function OnOpenSubMenu( event_data )
{
	$.Msg( "OnOpenSubMenu: ", event_data );
	var submenuListPanel = $.GetContextPanel()
	$.Msg( "OnOpenSubMenu: ", submenuListPanel );
	submenuListPanel.visible = true;

}

function OnCloseSubMenu( event_data )
{
	$.Msg( "OnCloseSubMenu: ", event_data );
	var submenuListPanel = $.GetContextPanel()
	$.Msg( "OnCloseSubMenu: ", submenuListPanel );
	submenuListPanel.visible = false;
}

function OnAbilityLearnModeToggled( bEnabled )
{
	UpdateAbilityList();
}

function UpdateAbilityList()
{
	// make sure xml files are loaded before running function
	var submenuListPanel = $( "#submenu_list" );
	if ( !submenuListPanel )
		return;
	
	var queryUnit = Players.GetLocalPlayerPortraitUnit();

	// see if we can level up
	var nRemainingPoints = Entities.GetAbilityPoints( queryUnit );
	var bPointsToSpend = ( nRemainingPoints > 0 );
	var bControlsUnit = Entities.IsControllableByPlayer( queryUnit, Game.GetLocalPlayerID() );
	$.GetContextPanel().SetHasClass( "could_level_up", ( bControlsUnit && bPointsToSpend ) );

	// update all the panels
	var nUserSubmenuPanels = 0;
	var nMaxColumns = 4;
	
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


		if (ability_type == "sub") {
			if ( nUserSubmenuPanels >= m_SubmenuAbilityPanels.length )
			{
				// create a new panel
				var submenuAbilityPanel = $.CreatePanel( "Panel", submenuListPanel, "" );
				submenuAbilityPanel.BLoadLayout( "file://{resources}/layout/custom_game/action_bar_ability.xml", false, false );
				m_SubmenuAbilityPanels.push( submenuAbilityPanel );
			}

			// update the panel for the current unit / ability
			var submenuAbilityPanel = m_SubmenuAbilityPanels[ nUserSubmenuPanels ];
			submenuAbilityPanel.data().SetAbility( ability, queryUnit, Game.IsInAbilityLearnMode() );

			nUserSubmenuPanels++;
		}
		
		if (nUserSubmenuPanels >= nMaxColumns) {
			submenuListPanel = $( "#submenu2nd_list" );
		}
	}

	// clear any remaining panels
	for ( var i = nUserSubmenuPanels; i < m_SubmenuAbilityPanels.length; ++i )
	{
		var submenuAbilityPanel = m_SubmenuAbilityPanels[ i ];
		submenuAbilityPanel.data().SetAbility( -1, -1, false );
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
	GameEvents.Subscribe( "OpenSubMenu", OnOpenSubMenu );
	GameEvents.Subscribe( "CloseSubMenu", OnCloseSubMenu );

	UpdateAbilityList(); // initial update
})();

