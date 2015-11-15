"use strict";

// Scriptwide variables for selections
var playerClass = "";
var playerWeapon = "";
var playerArmor = "";

//Called when any button is pressed, routes the call to handlers based on panel (class\armor\weapon)
function Selected(selection, PanelSelected)
{
   if ( PanelSelected == "ClassesPanel" )
   {
		ClassSelected( selection );
   }
   else if ( PanelSelected == "WeaponsPanel" )
   {
		WeaponSelected( selection);
   }
   else if ( PanelSelected == "ArmorPanel" )
   {
	   playerArmor = selection;
   }
}

// Called when a class button is selected. Checks if selected weapon and armor are valid.
function ClassSelected( selection )
{
   playerClass = selection;
   
   //checks armor
   if ( playerClass == "cyborg" )
   {
	   if ( playerArmor != "advanced" )
	   {
		   playerArmor = "";
	   }
	   $.("#LightArmorButton").style.border = "2 px solid grey";
	   $.("#MediumArmorButton").style.border = "2 px solid grey";
	   $.("#HeavyArmorButton").style.border = "2 px solid grey";
   }
}

function WeaponSelected( selection )
{
   //checks to see if the selection is valid
   
   
   
   playerWeapon = selection;
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
   if (playerClass == "cyborg" && playerWeapon == "chaingun")
   {
	   playerWeapon= "vindicator";
   }
}


function ConfirmSelected()
{
	var playerId = Players.GetLocalPlayer();
	//$.( "#ClassSelectScreenRoot" ).style.visibility = "collapse";
	GameEvents.SendCustomGameEventToServer( "class_setup_complete", { playerId:playerId, class:playerClass, weapon:playerWeapon, armor:playerArmor, trait:"none", spec:"none" });
}


