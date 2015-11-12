"use strict";

// Scriptwide variables for selections
var playerClass = "";
var playerWeapon = "";
var playerArmor = "";

//Called when any button is pressed, routes the call to handlers based on panel (class\armor\weapon)
function Selected(selection, PanelSelected)
{
   var PanelSelected = $.GetContextPanel().FindChild(PanelSelected);
   switch (PanelSelected.id) {
      case "ClassesPanel":
         ClassSelected(selection, PanelSelected);
         PanelSelected.visible = false;
         break;
      case "WeaponsPanel":
         WeaponSelected(selection);
         PanelSelected.visible = false;
         break;
      case "ArmorPanel":
         playerArmor = selection; 
         PanelSelected.visible = false;
         break;
      case "ConfirmResetPanel":
         ConfirmResetSelected(selection, PanelSelected);
         break;
   }
   $.Msg(selection);
	var iPlayerID = Players.GetLocalPlayer();
   return;
}

// Called when a class button is pressed, pass in the onActivate text and the class panel.
function ClassSelected(selection, PanelSelected)
{
   playerClass = selection;
   var RootPanel = PanelSelected.GetParent();
   var WeaponsPanel = RootPanel.FindChild("WeaponsPanel");
   var ArmorPanel = RootPanel.FindChild("ArmorPanel");
   $.Msg(ArmorPanel);
   WeaponsPanel.visible = true;
   ArmorPanel.visible = true;
   //Set up the weapons and armor panels based on the class selected.
      switch(selection) {
      case "sniper":
         HideAllWeapons(WeaponsPanel);
         ShowStandardArmor(ArmorPanel);
         WeaponsPanel.FindChild("SniperRifleButton").visible = true;
         break;
      //Silly cyborg has weird armor
      case "cyborg":
         HideAllWeapons(WeaponsPanel);
         $.Msg("1");
         WeaponsPanel.FindChild("VindicatorButton").visible = true;
         ArmorPanel.FindChild("LightArmorButton").visible = false;
         ArmorPanel.FindChild("MediumArmorButton").visible = false;
         $.Msg("2")
         $.Msg(ArmorPanel);
         $.Msg(ArmorPanel.FindChild("LightArmorButton"));
         ArmorPanel.FindChild("HeavyArmorButton").visible = false;
         ArmorPanel.FindChild("AdvancedArmorButton").visible = true;
         break;
      case "demo":
         HideAllWeapons(WeaponsPanel);
         ShowStandardArmor(ArmorPanel);
         WeaponsPanel.FindChild("RocketButton").visible = true;
         break;
      case "medic":
         HideAllWeapons(WeaponsPanel);
         ShowStandardArmor(ArmorPanel);
         WeaponsPanel.FindChild("AssaultRifleButton").visible = true;
         break;
      // Silly maverick can use all the weapons
      case "maverick":
         ShowStandardArmor(ArmorPanel);
         WeaponsPanel.FindChild("AssaultRifleButton").visible = true;
         WeaponsPanel.FindChild("ChaingunButton").visible = true;
         WeaponsPanel.FindChild("VindicatorButton").visible = false;
         WeaponsPanel.FindChild("FlamethrowerButton").visible = true;
         WeaponsPanel.FindChild("RocketButton").visible = true;
         WeaponsPanel.FindChild("SniperRifleButton").visible = true;
         break;
      case "ho":
         HideAllWeapons(WeaponsPanel);
         ShowStandardArmor(ArmorPanel);
         WeaponsPanel.FindChild("ChaingunButton").visible = true;
         break;
      case "psychologist":
         HideAllWeapons(WeaponsPanel);
         ShowStandardArmor(ArmorPanel);
         WeaponsPanel.FindChild("AssaultRifleButton").visible = true;
         break;
      case "tactician":
         HideAllWeapons(WeaponsPanel);
         ShowStandardArmor(ArmorPanel);
         WeaponsPanel.FindChild("AssaultRifleButton").visible = true;
         break;
   }
   $.Msg(playerClass);
}

function HideAllWeapons(Panel)
{
   Panel.FindChild("AssaultRifleButton").visible = false;
   Panel.FindChild("ChaingunButton").visible = false;
   Panel.FindChild("VindicatorButton").visible = false;
   Panel.FindChild("FlamethrowerButton").visible = false;
   Panel.FindChild("RocketButton").visible = false;
   Panel.FindChild("SniperRifleButton").visible = false;
}

function WeaponSelected(selection)
{
   
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
   $.Msg(playerWeapon);
}

// Sets up the armor panel for everyone but the cyborg
function ShowStandardArmor(APanel)
{
   $.Msg("showing standard armor")
   $.Msg(APanel)
   APanel.FindChild("LightArmorButton").visible = true;
   APanel.FindChild("MediumArmorButton").visible = true;
   APanel.FindChild("HeavyArmorButton").visible = true;
   APanel.FindChild("AdvancedArmorButton").visible = false;
}

function ConfirmResetSelected(selection, Panel)
{
   switch (selection)
   {
      case "confirm":
         // verify the player has selected everything
         if ((playerClass != "" ) && (playerWeapon != "") && (playerArmor != ""))
         {
            GameEvents.SendCustomGameEventToServer( "class_setup_complete", { playerId: Players.GetLocalPlayer(), class: playerClass, weapon: playerWeapon, armor:playerArmor, trait:"none", spec:"none" });
            Panel.visible=false
            Panel.GetParent().enabled = false;
         }
         break;
      // User jacked it up, show them the class panel again, but hide weapons and armor
      case "reset":
         var RootPanel = Panel.GetParent();
         RootPanel.FindChild("ClassesPanel").visible = true;
         RootPanel.FindChild("WeaponsPanel").visible = false;
         RootPanel.FindChild("ArmorPanel").visible = false;
         break;
   }
}

//(function()
//{
//	
	//UpdateClassSelect(); // initial update
//})();
