"use strict";

//contains all created buttons
var m_ClassButtons = [];
var m_WeaponButtons = [];
var m_ArmorButtons = [];

//contain player selection info
var playerClass = "";
var playerWeapon = "";
var playerArmor = "";

//table of all available classes
var classes = [];
classes.push( "sniper" );
classes.push( "cyborg" );
classes.push( "demo" );
classes.push( "medic" );
classes.push( "maverick" );
classes.push( "ho" );
classes.push( "psychologist" );
classes.push( "tactician" );
classes.push( "pyrotechnician" );
classes.push( "techops" );

//table of all available weapons
var weapons = [];
weapons.push( "assault_rifle" );
weapons.push( "chaingun" );
weapons.push( "flamethrower" );
weapons.push( "rocket" );
weapons.push( "sniper_rifle" );

//table of all available armor
var armor = [];
armor.push( "light" );
armor.push( "medium" );
armor.push( "heavy" );
armor.push( "advanced" );
	
	
function UpdateLists()
{
	
	
	// make sure xml files are loaded before running function
	var classButtonList = $( "#class_button_list" );
	if ( !classButtonList )
		return;
	var weaponButtonList = $( "#weapons_button_list" );
	if ( !weaponButtonList )
		return;
	var armorButtonList = $( "#armor_button_list" );
	if ( !armorButtonList )
		return;
	
	//makes all class buttons
	for ( var i = 0; i<classes.length; ++i )
	{
		var classButton = $.CreatePanel( "Panel", classButtonList, "" );
		classButton.BLoadLayout( "file://{resources}/layout/custom_game/class_select_screen_button.xml", false, false );
		classButton.data().SetClassButtonInfo( classes[i] );
		m_ClassButtons.push( classButton );
		classButtonList.data().ClassSelected = ClassSelected;
	}
	
	//makes all weapons buttons
	for ( var i = 0; i<weapons.length; ++i )
	{
		var weaponButton = $.CreatePanel( "Panel", weaponButtonList, "" );
		weaponButton.BLoadLayout( "file://{resources}/layout/custom_game/class_select_screen_button.xml", false, false );
		weaponButton.data().SetWeaponButtonInfo( weapons[i] );
		m_WeaponButtons.push( weaponButton );
		weaponButtonList.data().WeaponSelected = WeaponSelected;
	}
	
	//makes all armor buttons
	for ( var i = 0; i<armor.length; ++i )
	{
		var armorButton = $.CreatePanel( "Panel", armorButtonList, "" );
		armorButton.BLoadLayout( "file://{resources}/layout/custom_game/class_select_screen_button.xml", false, false );
		armorButton.data().SetArmorButtonInfo( armor[i] );
		m_ArmorButtons.push( armorButton );
		armorButtonList.data().ArmorSelected = ArmorSelected;
	}
}


function ClassSelected( playerclass, charactername )
{
	//set class
	playerClass = playerclass;
	
	$( "#CharacterName" ).text = charactername;

	//if a weapon has been selected before a class, sets the correct weapon version
	if ( playerWeapon != "" )
	{
		WeaponSelected( playerWeapon );
	}
	
	//sees if current armor selections are valid
	//sets which armor buttons are available
	if ( playerClass == "cyborg" )
	{
		if ( playerArmor != "advanced" )
		{
			playerArmor = "";
		}
		for ( var i = 0; i < 3; ++i )
		{
			var armorButton = m_ArmorButtons[ i ];
			armorButton.SetHasClass( "not_available", true );
		}
		var armorButton = m_ArmorButtons[ 3 ];
		armorButton.SetHasClass( "not_available", false );
		if ( playerWeapon != "vindicator" )
		{
			playerWeapon = "";
		}
		for ( var i = 0; i < 5; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", true );
		}
		var weaponButton = m_WeaponButtons[ 1 ];
		weaponButton.SetHasClass( "not_available", false );
	}
	if ( playerClass != "cyborg" )
	{
		if ( playerArmor == "advanced" )
		{
			playerArmor = "";
		}
		for ( var i = 0; i < 3; ++i )
		{
			var armorButton = m_ArmorButtons[ i ];
			armorButton.SetHasClass( "not_available", false );
		}
		var armorButton = m_ArmorButtons[ 3 ];
		armorButton.SetHasClass( "not_available", true );
	}
	//sees if current weapon selections are valid
	//sets which weapon buttons are available
	if ( playerClass == "sniper"  || playerClass == "techops")
	{
		if ( playerWeapon != "sniper_rifleI" )
		{
			playerWeapon = "";
		}
		for ( var i = 0; i < 4; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", true );
		}
		var weaponButton = m_WeaponButtons[ 4 ];
		weaponButton.SetHasClass( "not_available", false );
	}
	else if ( playerClass == "ho" )
	{
		if ( playerWeapon != "chaingunI" )
		{
			playerWeapon = "";
		}
		for ( var i = 0; i < 5; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", true );
		}
		var weaponButton = m_WeaponButtons[ 1 ];
		weaponButton.SetHasClass( "not_available", false );
	}
	else if ( playerClass == "demo" )
	{
		if ( playerWeapon != "rocketI" )
		{
			playerWeapon = "";
		}
		for ( var i = 0; i < 5; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", true );
		}
		var weaponButton = m_WeaponButtons[ 3 ];
		weaponButton.SetHasClass( "not_available", false );
	}
	else if ( playerClass == "maverick" )
	{
		for ( var i = 0; i < 5; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", false );
		}
	}
	else if ( playerClass == "pyrotechnician" )
	{
		if ( playerWeapon != "flamethrowerI" )
		{
			playerWeapon = "";
		}
		for ( var i = 0; i < 5; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", true );
		}
		var weaponButton = m_WeaponButtons[ 2 ];
		weaponButton.SetHasClass( "not_available", false );
	}
	else if ( playerClass == "medic" )
	{
		if ( playerWeapon != "assault_rifle_urban" )
		{
			playerWeapon = "";
		}
		for ( var i = 1; i < 5; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", true );
		}
		var weaponButton = m_WeaponButtons[ 0 ];
		weaponButton.SetHasClass( "not_available", false );
	}
	else if ( playerClass == "tactician" || playerClass == "psychologist" )
	{
		if ( playerWeapon != "assault_rifleI" )
		{
			playerWeapon = "";
		}
		for ( var i = 1; i < 5; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", true );
		}
		var weaponButton = m_WeaponButtons[ 0 ];
		weaponButton.SetHasClass( "not_available", false );
	}
	$.Msg( playerClass );
	
	PlayerReady();
}

function WeaponSelected( weapon )
{
	//finds the button for that weapon, sees if its available
	for ( var i = 0; i < 5; ++i )
	{
		var weaponButton = m_WeaponButtons[ i ];
		var weaponName = weaponButton.data().GetKey();
		
		if ( weaponName == weapon )
		{
			//if the button is unavailable, do nothing
			if ( weaponButton.BHasClass( "not_available" ) )
			{
				return;
			}
			
			//otherwise sets the correct player weapon
			else
			{
				playerWeapon = weapon;
				//Cyborg weapon has no versions
				if (playerClass != "cyborg")
				{
					playerWeapon = playerWeapon + "I";
				}
				// Maverick gets mark 2 weapons
				if (playerClass == "maverick")
				{
				playerWeapon = playerWeapon + "I";
				}
				// Medic gets this goofy thing
				if (playerClass == "medic")
				{
				playerWeapon = "assault_rifle_urban";
				}
				if (playerClass == "cyborg")
				{
				playerWeapon = "vindicator"	
				}
			}
		}	
	}
	$.Msg ( playerWeapon );
	PlayerReady();
}

function ArmorSelected( armor )
{
	//finds the button for that armor, sees if its available
	for ( var i = 0; i < 4; ++i )
	{
		var armorButton = m_ArmorButtons[ i ];
		var armorName = armorButton.data().GetKey();
		if ( armorName == armor )
		{
			//if the button is unavailable, do nothing
			if ( armorButton.BHasClass( "not_available" ) )
			{
				return;
			}
			
			else
			{
				playerArmor = armor;
			}
		}
	}
	$.Msg ( playerArmor );
	PlayerReady();
}

//sees if the player has selected all options, if so show confirm button
function PlayerReady()
{
	if ( playerClass != "" && playerArmor != "" && playerWeapon != "" )
	{
		$("#ConfirmSelections").visible = true;
	}
	else {
		$("#ConfirmSelections").visible = false;
	}
}


function ConfirmSelected()
{
	var playerId = Players.GetLocalPlayer();
	//$.( "#ClassSelectScreenRoot" ).style.visibility = "collapse";
	GameEvents.SendCustomGameEventToServer( "class_setup_complete", { playerId:playerId, class:playerClass, weapon:playerWeapon, armor:playerArmor, trait:"none", spec:"none" });
}

(function()
{
	UpdateLists(); // initial update
})();


