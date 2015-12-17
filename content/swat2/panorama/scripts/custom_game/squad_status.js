"use strict";

//contains all created panels
var m_SquadPanels = [];

//contains all the player indices, sorted. The order of this list determines the order in which panels are displayed
var playerList = [];

var panelHeight = 50;
var panelSpacer = 13;
		
function UpdateSquadList( table )
{
	var squadMemberListPanel = $( "#squad_list" );
	
	//looks through all the tables sent
	for (var k in table)
	{
		var playerTable = table[k];
		var playerIndex = playerTable.playerindex;
		
		//If a new players information is given, make them a new panel and re-sort all panels
		if ( playerList.indexOf ( playerIndex ) < 0 )
		{
			//makes a new panel and updates it with the sent information
			var squadMemberPanel = $.CreatePanel( "Panel", squadMemberListPanel, "" );
			squadMemberPanel.BLoadLayout( "file://{resources}/layout/custom_game/squad_member.xml", false, false );
			squadMemberPanel.data().UpdateSquadMember( playerTable );
			
			//add the player to the list of all player indices and resorts it
			playerList.push( playerIndex );
			playerList.sort();
			m_SquadPanels.push( squadMemberPanel );
			squadMemberPanel.style.opacity = 1;			
			
			for ( var i = 0; i < m_SquadPanels.length; i++) 
			{
				var panelPlayerIndex = m_SquadPanels[i].data().GetPlayerIndex();
				var position = playerList.indexOf ( panelPlayerIndex );
				var margin = (position*panelHeight)+(position*panelSpacer);
				m_SquadPanels[i].style.marginTop = (margin+"px");
			}
		}

		//Otherwise just updates the appropriate panels
		else
		{
			var squadMemberPanel = m_SquadPanels[ playerList.indexOf(playerIndex) ];
			squadMemberPanel.style.opacity = 1;
			squadMemberPanel.data().UpdateSquadMember( playerTable );
			
			//for some reason when I don't resort here the panels go out of order D:
			for ( var i = 0; i < m_SquadPanels.length; i++) 
			{
				var panelPlayerIndex = m_SquadPanels[i].data().GetPlayerIndex();
				var position = playerList.indexOf ( panelPlayerIndex );
				var margin = (position*panelHeight)+(position*panelSpacer);
				m_SquadPanels[i].style.marginTop = (margin+"px");
			}
		}
	
	}	
}

(function()
{
	//add these into gamemode
	//CustomGameEventManager:Send_ServerToAllClients("squad_update", {{"1" , playerindex = 13, playerhealth = ?}})
	GameEvents.Subscribe( "squad_update", UpdateSquadList );
	UpdateSquadList(); // initial update
})();

