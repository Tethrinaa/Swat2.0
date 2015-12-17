"use strict";

var healthBarWidth = 90;
var manaBarWidth = 90;

var playerMaxHealth = 500;
var playerHealth;
var playerMaxMana = 100;
var playerMana;
var playerClass;
var playerColor;
var playerName;
var playerIndex;
var playerRank;

function GetPlayerIndex()
{
	return playerIndex;
}

function SetBorderColor( index )
{
	if ( index == 1 ) { playerColor = "red"; }
	else if ( index == 2 ) { playerColor = "blue"; }
	else if ( index == 3 ) { playerColor = "teal"; }
	else if ( index == 4 ) { playerColor = "purple"; }
	else if ( index == 5 ) { playerColor = "yellow"; }
	else if ( index == 6 ) { playerColor = "orange"; }
	else if ( index == 7 ) { playerColor = "green"; }
	else if ( index == 8 ) { playerColor = "pink"; }
	else if ( index == 9 ) { playerColor = "grey"; }
	else if ( index == 10 ) { playerColor = "lightblue"; }
	else if ( index == 11 ) { playerColor = "darkgreen"; }
	else if ( index == 12 ) { playerColor = "brown"; }
	
	var classPortrait = $( "#ClassPortrait" );
	classPortrait.style.boxShadow = "-2px -2px 8px 5px "+playerColor;
}

function SetClassPortrait( name )
{
	var url;
	
	if ( name == "sniper" ) { url = "url('file://{images}/class_icons/covert_sniper.png')"; }
	else if ( name == "cyborg" ) { url = "url('file://{images}/class_icons/cyborg.png')"; }
	else if ( name == "demo" ) { url = "url('file://{images}/class_icons/demolitions.png')"; }
	else if ( name == "medic" ) { url = "url('file://{images}/class_icons/field_medic.png')"; }
	else if ( name == "ho" ) { url = "url('file://{images}/class_icons/heavy_ord.png')"; }
	else if ( name == "maverick" ) { url = "url('file://{images}/class_icons/maverick.png')"; }
	else if ( name == "psychologist" ) { url = "url('file://{images}/class_icons/psychologist.png')"; }
	else if ( name == "pyrotechnician" ) { url = "url('file://{images}/class_icons/pyrotechnician.png')"; }
	else if ( name == "tactician" ) { url = "url('file://{images}/class_icons/tactician.png')"; }
	else if ( name == "tech_ops" ) { url = "url('file://{images}/class_icons/tech_ops.png')"; }
	else if ( name == "umbrella_clone" ) { url = "url('file://{images}/class_icons/umbrella_clone.png')"; }
	else if ( name == "watchman" ) { url = "url('file://{images}/class_icons/watchman.png')"; }
	
	var classPortrait = $( "#ClassPortrait" );
	classPortrait.style.backgroundImage = url;
}

function SetRankIcon ( rank )
{
	var url;
	
	if ( rank == "captain" ) { url = "url('file://{images}/rank_icons/captain.png')"; }
	else if ( rank == "chief" ) { url = "url('file://{images}/rank_icons/chief.png')"; }
	else if ( rank == "commander" ) { url = "url('file://{images}/rank_icons/commander.png')"; }
	else if ( rank == "deputy_chief" ) { url = "url('file://{images}/rank_icons/deputy_chief.png')"; }
	else if ( rank == "detective" ) { url = "url('file://{images}/rank_icons/detective.png')"; }
	else if ( rank == "legendary_hero" ) { url = "url('file://{images}/rank_icons/legendary_hero.png')"; }
	else if ( rank == "lieutenant" ) { url = "url('file://{images}/rank_icons/lieutenant.png')"; }
	else if ( rank == "national_hero" ) { url = "url('file://{images}/rank_icons/national_hero.png')"; }
	else if ( rank == "officerI" ) { url = "url('file://{images}/rank_icons/officerI.png')"; }
	else if ( rank == "officerII" ) { url = "url('file://{images}/rank_icons/officerII.png')"; }
	else if ( rank == "officerIII" ) { url = "url('file://{images}/rank_icons/officerIII.png')"; }
	else if ( rank == "sergeant" ) { url = "url('file://{images}/rank_icons/sergeant.png')"; }
	
	var rankIcon = $( "#Rank" );
	rankIcon.style.backgroundImage = url;
}

function UpdateSquadMember( table )
{
	//table should ALWAYS contain the player index
	playerIndex = table.playerindex;
	
	//TODO REMOVE
	var index = $( "#Index" );
	//index.text = $.Localize(playerIndex);
	
	for (var k in table)
	{
		//handles health
		if ( k == "playermaxhealth" )
		{
			playerMaxHealth = table.playermaxhealth;
		}
			
		else if ( k == "playerhealth" )
		{
			//TODO: account for how to display health if background changes
			var healthbar = $( "#HealthBar" );
			playerHealth = table.playerhealth;
			var percentHealth = playerHealth/playerMaxHealth;
			var width = healthBarWidth*percentHealth;
			healthbar.style.width = (width+"px");	
			healthbar.style.backgroundColor = "gradient( radial, 50% -20%, 0% 0%, 80% 80%, from( #006500 ), to( #00C000 ) )"
			//If player health is critical, turns health bar red
			if ( playerHealth < 183 ) 
			{
					healthbar.style.backgroundColor = "gradient( radial, 50% -20%, 0% 0%, 80% 80%, from( #F90021 ), to( #A0000A ) )"
			}
		}
			
		//handles mana
		else if ( k == "playermaxmana" )
		{
			playerMaxMana = table.playermaxmana;
		}
			
		else if ( k == "playermana" )
		{
			//TODO: account for how to display mana if background changes
			var manabar = $( "#ManaBar" );
			playerMana = table.playermana;
			var percentMana = playerMana/playerMaxMana;
			var width = manaBarWidth*percentMana;
			manabar.style.width = (width+"px");	
		}
			
		//handles the name and border color
		else if ( k == "playername" )
		{
			var name = $( "#PlayerName" );
			playerName = table.playername;
			name.text = $.Localize(playerName);
			SetBorderColor( playerIndex );
		}
		
		//handles the class portrait
		else if ( k == "playerclass" )
		{
			playerClass = table.playerclass;
			SetClassPortrait( playerClass );
		}
		
		//handles the rank picture
		else if ( k == "playerrank" )
		{
			playerRank = table.playerrank;
			SetRankIcon( playerRank );
		}
	}
}

(function()
{
	$.GetContextPanel().data().UpdateSquadMember = UpdateSquadMember;
	$.GetContextPanel().data().GetPlayerIndex = GetPlayerIndex;
})();
