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
}

(function()
{
	$.GetContextPanel().data().SetClassButtonInfo = SetClassButtonInfo;
	$.GetContextPanel().data().SetWeaponButtonInfo = SetWeaponButtonInfo;
	$.GetContextPanel().data().SetArmorButtonInfo = SetArmorButtonInfo;
	$.GetContextPanel().data().GetKey = GetKey;
})();