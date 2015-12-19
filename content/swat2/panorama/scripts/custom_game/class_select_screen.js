"use strict";

//contains all created buttons
var m_ClassButtons = [];
var m_WeaponButtons = [];
var m_ArmorButtons = [];
var m_SpecButtons = [];
var m_TraitButtons = [];

//contain player selection info
var playerClass = "";
var playerWeapon = "";
var playerArmor = "";
var playerSpec = "";
var playerTrait = "";

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

//table of all available specs
var specs = [];
specs.push( "cybernetics" );
specs.push( "energy_cells" );
specs.push( "espionage") ;
specs.push( "leadership" );
specs.push( "power_armor" );
specs.push( "robotics" );
specs.push( "triage" );
specs.push( "weaponry" );

//table of all available traits
var traits = [];
traits.push( "acrobat" );	
traits.push( "chem_reliant" );
traits.push( "dragoon" );
traits.push( "energizer" );
traits.push( "engineer" );	
traits.push( "flower_child" );
traits.push( "gadgeteer" );
traits.push( "gifted" );
traits.push( "healer" );
traits.push( "pack_rat" );
traits.push( "prowler" );
traits.push( "rad_resistant" );
traits.push( "reckless" );
traits.push( "skilled" );
traits.push( "survivalist" );
traits.push( "swift_learner" );														
	
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
	var abilityList = $( "#ability_panel" );
	if ( !abilityList )
		return;
	var specButtonList = $( "#spec_button_list" );
	if ( !specButtonList )
		return;
	var traitButtonList = $( "#trait_button_list" );
	if ( !traitButtonList )
		return;
	
	//makes all class buttons
	for ( var i = 0; i<classes.length; ++i )
	{
		var classButton = $.CreatePanel( "Panel", classButtonList, "" );
		classButton.BLoadLayout( "file://{resources}/layout/custom_game/class_select_screen_button.xml", false, false );
		classButton.data().SetClassButtonInfo( classes[i] );
		m_ClassButtons.push( classButton );
		classButtonList.data().ClassSelected = ClassSelected;
		classButton.visible = true;
	}
	
	//makes all weapons buttons
	for ( var i = 0; i<weapons.length; ++i )
	{
		var weaponButton = $.CreatePanel( "Panel", weaponButtonList, "" );
		weaponButton.BLoadLayout( "file://{resources}/layout/custom_game/class_select_screen_button.xml", false, false );
		weaponButton.data().SetWeaponButtonInfo( weapons[i] );
		m_WeaponButtons.push( weaponButton );
		weaponButtonList.data().WeaponSelected = WeaponSelected;
		weaponButton.visible = true;
	}
	
	//makes all armor buttons
	for ( var i = 0; i<armor.length; ++i )
	{
		var armorButton = $.CreatePanel( "Panel", armorButtonList, "" );
		armorButton.BLoadLayout( "file://{resources}/layout/custom_game/class_select_screen_button.xml", false, false );
		armorButton.data().SetArmorButtonInfo( armor[i] );
		m_ArmorButtons.push( armorButton );
		armorButtonList.data().ArmorSelected = ArmorSelected;
		armorButton.visible = true;
	}
	
	//makes the ability panel
	var abilityPanel = $.CreatePanel( "Panel", abilityList, "" );
	abilityPanel.BLoadLayout( "file://{resources}/layout/custom_game/class_select_screen_ability_bar.xml", false, false );
	abilityPanel.data().SetWeaponAbility( "" );
	abilityPanel.data().SetArmorAbility( "" );
	abilityPanel.data().SetPlayerAbilities( "" );
	
	//makes all specialization buttons
	for ( var i = 0; i<specs.length; ++i )
	{
		var specButton = $.CreatePanel( "Panel", specButtonList, "" );
		specButton.BLoadLayout( "file://{resources}/layout/custom_game/class_select_screen_button.xml", false, false );
		specButton.data().SetSpecButtonInfo( specs[i] );
		m_SpecButtons.push( specButton );
		specButtonList.data().SpecSelected = SpecSelected;
		specButton.visible = true;
	}	
	
	//makes all trait buttons
	for ( var i = 0; i<traits.length; ++i )
	{
		var traitButton = $.CreatePanel( "Panel", traitButtonList, "" );
		traitButton.BLoadLayout( "file://{resources}/layout/custom_game/class_select_screen_button.xml", false, false );
		traitButton.data().SetTraitButtonInfo( traits[i] );
		m_TraitButtons.push( traitButton );
		traitButtonList.data().TraitSelected = TraitSelected;
		traitButton.visible = true;
	}	
}


function ClassSelected( playerclass, charactername )
{
	//set class
	playerClass = playerclass;
	
	$( "#CharacterName" ).text = charactername;
	SetPortrait( playerClass )
	
	for ( var i = 0; i < 10 ; ++i )
	{
		var classButton = m_ClassButtons[ i ];
		var className = classButton.data().GetKey();
		classButton.SetHasClass( "is_selected", false );
		if ( className == playerclass )
		{
			classButton.SetHasClass( "is_selected", true );
		}
	}
	
	//sees if current armor selections are valid
	//sets which armor buttons are available
	if ( playerClass == "cyborg" )
	{
		//selects advanced armor
		for ( var i = 0; i < 3; ++i )
		{
			var armorButton = m_ArmorButtons[ i ];
			armorButton.SetHasClass( "not_available", true );
			armorButton.SetHasClass( "is_selected", false );
		}
		var armorButton = m_ArmorButtons[ 3 ];
		armorButton.SetHasClass( "not_available", false );
		armorButton.SetHasClass( "is_selected", true );
		ArmorSelected( "advanced" );
		
		//selects vindicator
		for ( var i = 0; i < 5; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", true );
			weaponButton.SetHasClass( "is_selected", false );
		}
		var weaponButton = m_WeaponButtons[ 1 ];
		weaponButton.SetHasClass( "not_available", false );
		weaponButton.SetHasClass( "is_selected", true );
		WeaponSelected( "chaingun" );
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
		armorButton.SetHasClass( "is_selected", false );
	}
	//sees if current weapon selections are valid
	//sets which weapon buttons are available
	if ( playerClass == "sniper"  || playerClass == "techops")
	{
		for ( var i = 0; i < 4; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", true );
			weaponButton.SetHasClass( "is_selected", false );
		}
		var weaponButton = m_WeaponButtons[ 4 ];
		weaponButton.SetHasClass( "not_available", false );
		weaponButton.SetHasClass( "is_selected", true );
		WeaponSelected( "sniper_rifle");
	}
	else if ( playerClass == "ho" )
	{
		for ( var i = 0; i < 5; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", true );
			weaponButton.SetHasClass( "is_selected", false );
		}
		var weaponButton = m_WeaponButtons[ 1 ];
		weaponButton.SetHasClass( "not_available", false );
		weaponButton.SetHasClass( "is_selected", true );
		WeaponSelected( "chaingun" );
	}
	else if ( playerClass == "demo" )
	{
		for ( var i = 0; i < 5; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", true );
			weaponButton.SetHasClass( "is_selected", false );
		}
		var weaponButton = m_WeaponButtons[ 3 ];
		weaponButton.SetHasClass( "not_available", false );
		weaponButton.SetHasClass( "is_selected", true );
		WeaponSelected( "rocket" );
	}
	else if ( playerClass == "maverick" )
	{
		for ( var i = 0; i < 5; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", false );
			if ( weaponButton.BHasClass ( "is_selected" ) )
			{
				var weaponName = weaponButton.data().GetKey();
				WeaponSelected( weaponName );
			}
		}
	}
	else if ( playerClass == "pyrotechnician" )
	{
		for ( var i = 0; i < 5; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", true );
			weaponButton.SetHasClass( "is_selected", false );
		}
		var weaponButton = m_WeaponButtons[ 2 ];
		weaponButton.SetHasClass( "not_available", false );
		weaponButton.SetHasClass( "is_selected", true );
		WeaponSelected( "flamethrower" );
	}
	else if ( playerClass == "medic" )
	{
		for ( var i = 1; i < 5; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", true );
			weaponButton.SetHasClass( "is_selected", false );
		}
		var weaponButton = m_WeaponButtons[ 0 ];
		weaponButton.SetHasClass( "not_available", false );
		weaponButton.SetHasClass( "is_selected", true );
		WeaponSelected( "assault_rifle" );
	}
	else if ( playerClass == "tactician" || playerClass == "psychologist" )
	{
		for ( var i = 1; i < 5; ++i )
		{
			var weaponButton = m_WeaponButtons[ i ];
			weaponButton.SetHasClass( "not_available", true );
			weaponButton.SetHasClass( "is_selected", false );
		}
		var weaponButton = m_WeaponButtons[ 0 ];
		weaponButton.SetHasClass( "not_available", false );
		weaponButton.SetHasClass( "is_selected", true );
		WeaponSelected( "assault_rifle" );
	}
	
	var abilityPanel = $( "#ability_panel" ).GetChild( 0 );
	abilityPanel.data().SetWeaponAbility( playerWeapon );
	abilityPanel.data().SetArmorAbility( playerArmor );
	abilityPanel.data().SetPlayerAbilities( playerClass );
	PlayerReady();
}

function WeaponSelected( weapon )
{
	//finds the button for that weapon, sees if its available
	for ( var i = 0; i < 5; ++i )
	{
		var weaponButton = m_WeaponButtons[ i ];
		var weaponName = weaponButton.data().GetKey();
		weaponButton.SetHasClass( "is_selected", false );
		
		if ( weaponName == weapon )
		{
			//if the button is unavailable, do nothing
			if ( weaponButton.BHasClass( "not_available" ) )
			{
				playerWeapon = "";
			}
			
			//otherwise sets the correct player weapon
			else
			{
				playerWeapon = weapon;
				weaponButton.SetHasClass( "is_selected", true );
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
	var abilityPanel = $( "#ability_panel" ).GetChild( 0 );
	abilityPanel.data().SetWeaponAbility( playerWeapon );
	PlayerReady();
}

function ArmorSelected( armor )
{
	//finds the button for that armor, sees if its available
	for ( var i = 0; i < 4; ++i )
	{	
		var armorButton = m_ArmorButtons[ i ];
		var armorName = armorButton.data().GetKey();
		armorButton.SetHasClass( "is_selected", false );
		if ( armorName == armor )
		{
			//if the button is unavailable, do nothing
			if ( armorButton.BHasClass( "not_available" ) )
			{
				playerArmor = "";
			}
			
			else
			{
				armorButton.SetHasClass( "is_selected", true );
				playerArmor = armor;
			}
		}
	}
	var abilityPanel = $( "#ability_panel" ).GetChild( 0 );
	abilityPanel.data().SetArmorAbility( playerArmor );
	PlayerReady();
}

function SpecSelected( spec )
{
	//finds the button for that spec
	for ( var i = 0; i < 8; ++i )
	{	
		var specButton = m_SpecButtons[ i ];
		var specName = specButton.data().GetKey();
		specButton.SetHasClass( "is_selected", false );
		if ( specName == spec )
		{
			specButton.SetHasClass( "is_selected", true );
			playerSpec = spec;
		}
	}
	PlayerReady();
}

function TraitSelected( trait )
{
	//finds the button for that spec
	for ( var i = 0; i < 16; ++i )
	{	
		var traitButton = m_TraitButtons[ i ];
		var traitName = traitButton.data().GetKey();
		traitButton.SetHasClass( "is_selected", false );
		if ( traitName == trait )
		{
			traitButton.SetHasClass( "is_selected", true );
			playerTrait = trait;
		}
	}
	PlayerReady();
}

function SetPortrait( playerClass )
{
	$( "#PyroImage" ).visible = false;
	$( "#MedicImage" ).visible = false;
	$( "#HoImage" ).visible = false;
	$( "#TacticianImage" ).visible = false;
	$( "#CyborgImage" ).visible = false;
	$( "#MaverickImage" ).visible = false;
	$( "#SniperImage" ).visible = false;
	$( "#TechopsImage" ).visible = false;
	$( "#PsychImage" ).visible = false;
	$( "#DemoImage" ).visible = false;
	
	if ( playerClass == "sniper" )
	{
		$( "#SniperImage" ).visible = true;
	}
	else if ( playerClass == "cyborg" )
	{
		$( "#CyborgImage" ).visible = true;
	}
	else if ( playerClass == "demo" )
	{
		$( "#DemoImage" ).visible = true;
	}
	else if ( playerClass == "medic" )
	{
		$( "#MedicImage" ).visible = true;
	}
	else if ( playerClass == "maverick" )
	{
		$( "#MaverickImage" ).visible = true;
	}
	else if ( playerClass == "ho" )
	{
		$( "#HoImage" ).visible = true;
	}
	else if ( playerClass == "psychologist" )
	{
		$( "#PsychImage" ).visible = true;
	}
	else if ( playerClass == "tactician" )
	{
		$( "#TacticianImage" ).visible = true;
	}
	else if ( playerClass == "pyrotechnician" )
	{
		$( "#PyroImage" ).visible = true;
	}
	else if ( playerClass == "techops" )
	{
		$( "#TechopsImage" ).visible = true;
	}
}



//sees if the player has selected all options, if so show confirm button
function PlayerReady()
{
	if ( playerClass != "" && playerArmor != "" && playerWeapon != "" && playerSpec != "" && playerTrait != "" )
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
	GameEvents.SendCustomGameEventToServer( "class_setup_complete", { playerId:playerId, class:playerClass, weapon:playerWeapon, armor:playerArmor, trait:playerTrait, spec:playerSpec });
	//makes class select screen collapse
	$.GetContextPanel().visible = false;
	$.GetContextPanel().RemoveAndDeleteChildren();
}

(function()
{
	UpdateLists(); // initial update
})();


