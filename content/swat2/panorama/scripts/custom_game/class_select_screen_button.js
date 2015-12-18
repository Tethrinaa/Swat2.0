"use strict";

//this is the selection in the syntax needed for player builder
var key = "";
var type = "";

function SetClassButtonInfo( playerclass )
{
	key = playerclass;
	type = "classButton";
	var label;
	var url;
	
	if ( playerclass == "sniper" ) 
	{ 
		url = "url('file://{images}/class_icons/covert_sniper.png')"; 
		label = "Covert Sniper"; 
	}
	else if ( playerclass == "cyborg" ) 
	{ 
		url = "url('file://{images}/class_icons/cyborg.png')"; 
		label = "Cyborg"; 
	}
	else if ( playerclass == "demo" ) 
	{ 
		url = "url('file://{images}/class_icons/demolitions.png')"; 
		label = "Demolitions"; 
	}
	else if ( playerclass == "medic" ) 
	{ 
		url = "url('file://{images}/class_icons/field_medic.png')"; 
		label = "Field Medic"; 
	}
	else if ( playerclass == "ho" ) 
	{ 
		url = "url('file://{images}/class_icons/heavy_ord.png')"; 
		label = "Heavy Ordinance"; 
	}
	else if ( playerclass == "maverick" ) 
	{ 
		url = "url('file://{images}/class_icons/maverick.png')"; 
		label = "Maverick"; 
	}
	else if ( playerclass == "psychologist" ) 
	{ 
		url = "url('file://{images}/class_icons/psychologist.png')"; 
		label = "Psychologist"; 
	}
	else if ( playerclass == "pyrotechnician" ) 
	{ 
		url = "url('file://{images}/class_icons/pyrotechnician.png')"; 
		label = "Pyrotechnician";
	}
	else if ( playerclass == "tactician" ) 
	{ 
		url = "url('file://{images}/class_icons/tactician.png')"; 
		label = "Tactician"; 
	}
	else if ( playerclass == "techops" ) 
	{ 
		url = "url('file://{images}/class_icons/tech_ops.png')"; 
		label = "Tech Ops"; 
	}
	else if ( playerclass == "umbrella_clone" ) 
	{ 
		url = "url('file://{images}/class_icons/umbrella_clone.png')"; 
		label = "Umbrella Clone"; 
	}
	else if ( playerclass == "watchman" ) 
	{ 
		url = "url('file://{images}/class_icons/watchman.png')"; 
		label = "Watchman"; 
	}
	
	$("#ButtonLabel").text = label;
	$("#SelectionButton").style.backgroundImage = url;
}

function SetWeaponButtonInfo( weapon )
{
	key = weapon;
	type = "weaponButton";
	var label;
	var url;
	
	if ( weapon == "assault_rifle" ) 
	{ 
		url = "url('file://{images}/weapon_icons/assault_rifle.png')"; 
		label = "Assault Rifle"; 
	}
	else if ( weapon == "chaingun" ) 
	{ 
		url = "url('file://{images}/weapon_icons/chaingun.png')"; 
		label = "Chaingun"; 
	}
	else if ( weapon == "flamethrower" ) 
	{ 
		url = "url('file://{images}/weapon_icons/flamethrower.png')"; 
		label = "Flamethrower"; 
	}
	else if ( weapon == "rocket" ) 
	{ 
		url = "url('file://{images}/weapon_icons/rocket.png')"; 
		label = "Rocket Launcher"; 
	}
	else if ( weapon == "sniper_rifle" ) 
	{ 
		url = "url('file://{images}/weapon_icons/sniper_rifle.png')"; 
		label = "Sniper Rifle"; 
	}
	
	$("#ButtonLabel").text = label;
	$("#SelectionButton").style.backgroundImage = url;
}

function SetArmorButtonInfo( armor )
{
	key = armor;
	type = "armorButton";
	var label;
	var url;
	
	if ( armor == "light" ) 
	{ 
		url = "url('file://{images}/armor_icons/light_armor.png')"; 
		label = "Light"; 
	}
	else if ( armor == "medium" ) 
	{ 
		url = "url('file://{images}/armor_icons/med_armor.png')"; 
		label = "Medium";
	}
	else if ( armor == "heavy" ) 
	{ 
		url = "url('file://{images}/armor_icons/heavy_armor.png')"; 
		label = "Heavy"; 
	}
	else if ( armor == "advanced" ) 
	{ 
		url = "url('file://{images}/armor_icons/advanced_armor.png')"; 
		label = "Advanced"; 
	}
	
	$("#ButtonLabel").text = label;
	$("#SelectionButton").style.backgroundImage = url;
}

function SetSpecButtonInfo( spec )
{
	key = spec;
	type = "specButton"
	var label;
	var url;
	
	if ( spec == "cybernetics" ) 
	{ 
		url = "url('file://{images}/spec_icons/cybernetics.png')"; 
		label = "Cybernetics"; 
	}
	else if ( spec == "energy_cells" ) 
	{ 
		url = "url('file://{images}/spec_icons/energy_cells.png')"; 
		label = "Energy Cells";
	}
	else if ( spec == "espionage" ) 
	{ 
		url = "url('file://{images}/spec_icons/espionage.png')"; 
		label = "Espionage";
	}
	else if ( spec == "leadership" ) 
	{ 
		url = "url('file://{images}/spec_icons/leadership.png')"; 
		label = "Leadership";
	}
	else if ( spec == "power_armor" ) 
	{ 
		url = "url('file://{images}/spec_icons/power_armor.png')"; 
		label = "Power Armor";
	}
	else if ( spec == "robotics" ) 
	{ 
		url = "url('file://{images}/spec_icons/robotics.png')"; 
		label = "Robotics";
	}
	else if ( spec == "triage" ) 
	{ 
		url = "url('file://{images}/spec_icons/triage.png')"; 
		label = "Triage";
	}
	else if ( spec == "weaponry" ) 
	{ 
		url = "url('file://{images}/spec_icons/weaponry.png')"; 
		label = "Weaponry";
	}
	
	$("#ButtonLabel").text = label;
	$("#SelectionButton").style.backgroundImage = url;
}

function SetTraitButtonInfo( trait )
{
	key = trait;
	type = "traitButton"
	var label;
	var url;
	
	if ( trait == "acrobat" ) 
	{ 
		url = "url('file://{images}/trait_icons/acrobat.png')"; 
		label = "Acrobat"; 
	}
	else if ( trait == "chem_reliant" ) 
	{ 
		url = "url('file://{images}/trait_icons/chem_reliant.png')"; 
		label = "Chem Reliant";
	}
	else if ( trait == "dragoon" ) 
	{ 
		url = "url('file://{images}/trait_icons/dragoon.png')"; 
		label = "Dragoon";
	}
	else if ( trait == "energizer" ) 
	{ 
		url = "url('file://{images}/trait_icons/energizer.png')"; 
		label = "Energizer";
	}
	else if ( trait == "engineer" ) 
	{ 
		url = "url('file://{images}/trait_icons/engineer.png')"; 
		label = "Engineer";
	}
	else if ( trait == "flower_child" ) 
	{ 
		url = "url('file://{images}/trait_icons/flower_child.png')"; 
		label = "Flower Child";
	}
	else if ( trait == "gadgeteer" ) 
	{ 
		url = "url('file://{images}/trait_icons/gadgeteer.png')"; 
		label = "Gadgeteer";
	}
	else if ( trait == "gifted" ) 
	{ 
		url = "url('file://{images}/trait_icons/gifted.png')"; 
		label = "Gifted";
	}
	else if ( trait == "healer" ) 
	{ 
		url = "url('file://{images}/trait_icons/healer.png')"; 
		label = "Healer";
	}
	else if ( trait == "pack_rat" ) 
	{ 
		url = "url('file://{images}/trait_icons/pack_rat.png')"; 
		label = "Pack Rat";
	}
	else if ( trait == "prowler" ) 
	{ 
		url = "url('file://{images}/trait_icons/prowler.png')"; 
		label = "Prowler";
	}
	else if ( trait == "rad_resistant" ) 
	{ 
		url = "url('file://{images}/trait_icons/rad_resistant.png')"; 
		label = "Rad Resistant";
	}
	else if ( trait == "reckless" ) 
	{ 
		url = "url('file://{images}/trait_icons/reckless.png')"; 
		label = "Reckless";
	}
	else if ( trait == "skilled" ) 
	{ 
		url = "url('file://{images}/trait_icons/skilled.png')"; 
		label = "Skilled";
	}
	else if ( trait == "survivalist" ) 
	{ 
		url = "url('file://{images}/trait_icons/survivalist.png')"; 
		label = "Survivalist";
	}
	else if ( trait == "swift_learner" ) 
	{ 
		url = "url('file://{images}/trait_icons/swift_learner.png')"; 
		label = "Swift Learner";
	}
	
	$("#ButtonLabel").text = label;
	$("#SelectionButton").style.backgroundImage = url;
}

function GetKey()
{
	return key;
}

function Selected()
{
	//sends the selected button key info to class_select_screen
	if ( type == "classButton" )
	{
		var charactername = $( "#ButtonLabel" ).text;
		var a = $.GetContextPanel();
		var b = a.GetParent();
		b.data().ClassSelected( key, charactername );
	}
	else if ( type == "weaponButton" )
	{
		var a = $.GetContextPanel();
		var b = a.GetParent();
		b.data().WeaponSelected( key );
	}
	else if ( type == "armorButton" )
	{
		var a = $.GetContextPanel();
		var b = a.GetParent();
		b.data().ArmorSelected( key );
	}
	else if ( type == "specButton" )
	{
		var a = $.GetContextPanel();
		var b = a.GetParent();
		b.data().SpecSelected( key );
	}
	else if ( type == "traitButton" )
	{
		var a = $.GetContextPanel();
		var b = a.GetParent();
		b.data().TraitSelected( key );
	}
}

(function()
{
	$.GetContextPanel().data().SetClassButtonInfo = SetClassButtonInfo;
	$.GetContextPanel().data().SetWeaponButtonInfo = SetWeaponButtonInfo;
	$.GetContextPanel().data().SetArmorButtonInfo = SetArmorButtonInfo;
	$.GetContextPanel().data().SetSpecButtonInfo = SetSpecButtonInfo;
	$.GetContextPanel().data().SetTraitButtonInfo = SetTraitButtonInfo;
	$.GetContextPanel().data().GetKey = GetKey;
})();