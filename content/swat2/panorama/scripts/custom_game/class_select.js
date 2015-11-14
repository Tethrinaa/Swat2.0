"use strict";

// Scriptwide variables for selections
var playerClass = "";
var playerWeapon = "";
var playerArmor = "";
var playerTrait = "";
var playerSpec = "";

//Called when any button is pressed, routes the call to handlers based on panel (class\armor\weapon\trait\spec)
function Selected(selection, PanelSelected)
{
   var PanelSelected = $.GetContextPanel().FindChild(PanelSelected);
   switch (PanelSelected.id) {
      case "ClassesPanel":
         ClassSelected(selection, PanelSelected);
         PanelSelected.visible = false;
         break;
      case "WeaponsPanel":
         WeaponSelected(selection, PanelSelected);
         PanelSelected.visible = false;
		 break;
      case "ArmorPanel":
         ArmorSelected(selection, PanelSelected); 
         PanelSelected.visible = false;
		 break;
	  case "TraitPanel":
         TraitSelected(selection, PanelSelected); 
		 break;
	  case "TraitPanel2":
		 TraitSelected(selection, PanelSelected); 
		 break;
	  case "SpecPanel":
         playerSpec = selection; 
         PanelSelected.visible = false;
		 break;
      case "ConfirmResetPanel":
         ConfirmResetSelected(selection, PanelSelected);
   }
   $.Msg(selection);
	var iPlayerID = Players.GetLocalPlayer();
   return;
}

// Called when a class button is pressed, pass in the onActivate text and the class panel.  Brings up Weapon Selection
function ClassSelected(selection, PanelSelected)
{
   playerClass = selection;
   var RootPanel = PanelSelected.GetParent();
   var WeaponsPanel = RootPanel.FindChild("WeaponsPanel");
   WeaponsPanel.visible = true;
   //Set up the weapon panel based on the class selected.
      switch(selection) {
      case "sniper":
         HideAllWeapons(WeaponsPanel);
         WeaponsPanel.FindChild("SniperRifleButton").visible = true;
         break;
      //Silly cyborg has weird armor
      case "cyborg":
         HideAllWeapons(WeaponsPanel);
         $.Msg("1");
         WeaponsPanel.FindChild("VindicatorButton").visible = true;
         break;
      case "demo":
         HideAllWeapons(WeaponsPanel);
         WeaponsPanel.FindChild("RocketButton").visible = true;
         break;
      case "medic":
         HideAllWeapons(WeaponsPanel);
         WeaponsPanel.FindChild("AssaultRifleButton").visible = true;
         break;
      // Silly maverick can use all the weapons
      case "maverick":
         WeaponsPanel.FindChild("AssaultRifleButton").visible = true;
         WeaponsPanel.FindChild("ChaingunButton").visible = true;
         WeaponsPanel.FindChild("VindicatorButton").visible = false;
         WeaponsPanel.FindChild("FlamethrowerButton").visible = true;
         WeaponsPanel.FindChild("RocketButton").visible = true;
         WeaponsPanel.FindChild("SniperRifleButton").visible = true;
         break;
      case "ho":
         HideAllWeapons(WeaponsPanel);
         WeaponsPanel.FindChild("ChaingunButton").visible = true;
         break;
      case "psychologist":
         HideAllWeapons(WeaponsPanel);
         WeaponsPanel.FindChild("AssaultRifleButton").visible = true;
         break;
      case "tactician":
         HideAllWeapons(WeaponsPanel);
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

//Assigns correct weapon types and opens up armor selection
function WeaponSelected(selection, PanelSelected)
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
   
   var RootPanel = PanelSelected.GetParent();
   var ArmorPanel = RootPanel.FindChild("ArmorPanel");
   $.Msg(ArmorPanel);
   ArmorPanel.visible = true;
   
   switch(playerClass) {
      case "sniper":
         ShowStandardArmor(ArmorPanel);
         break;
      //Silly cyborg has weird armor
      case "cyborg":
         $.Msg("2")
         $.Msg(ArmorPanel);
         $.Msg(ArmorPanel.FindChild("LightArmorButton"));
         ArmorPanel.FindChild("HeavyArmorButton").visible = false;
         ArmorPanel.FindChild("AdvancedArmorButton").visible = true;
         break;
      case "demo":
         ShowStandardArmor(ArmorPanel);
         break;
      case "medic":
         ShowStandardArmor(ArmorPanel);
         break;
      // Silly maverick can use all the weapons
      case "maverick":
         ShowStandardArmor(ArmorPanel);
         break;
      case "ho":
         ShowStandardArmor(ArmorPanel);
         break;
      case "psychologist":
         ShowStandardArmor(ArmorPanel);
         break;
      case "tactician":
         ShowStandardArmor(ArmorPanel);
         break;
		}
		$.Msg(playerWeapon);
}

//Armor was selected so now open up the traits selection
function ArmorSelected(selection, PanelSelected) {
	
	playerArmor = selection;
	$.Msg(playerArmor);
	
   var RootPanel = PanelSelected.GetParent();
   var TraitPanel = RootPanel.FindChild("TraitPanel");
   var TraitPanel2 = RootPanel.FindChild("TraitPanel2");
   $.Msg(TraitPanel);
   
   TraitPanel.visible = true;
   TraitPanel2.visible = true;
   
   TraitPanel.FindChild("SkilledButton").visible = true;
   TraitPanel.FindChild("SurvivalistButton").visible = true;
   TraitPanel.FindChild("AcrobatButton").visible = true;
   TraitPanel.FindChild("HealerButton").visible = true;
   TraitPanel.FindChild("ChemreliantButton").visible = true;
   TraitPanel.FindChild("GadgeteerButton").visible = true;
   TraitPanel.FindChild("EnergizerButton").visible = true;
   TraitPanel.FindChild("EngineerButton").visible = true;
   TraitPanel2.FindChild("GiftedButton").visible = true;
   TraitPanel2.FindChild("DragoonButton").visible = true;
   TraitPanel2.FindChild("SwiftlearnerButton").visible = true;
   TraitPanel2.FindChild("FlowerchildButton").visible = true;
   TraitPanel2.FindChild("RadresistantButton").visible = true;
   TraitPanel2.FindChild("ProwlerButton").visible = true;
   TraitPanel2.FindChild("PackratButton").visible = true;
   TraitPanel2.FindChild("RecklessButton").visible = true;
}

//Trait was selected so now open up the Specs selection
function TraitSelected(selection, PanelSelected) {
	
	playerTrait = selection;
	$.Msg(playerTrait);
	
   var RootPanel = PanelSelected.GetParent();
   var SpecPanel = RootPanel.FindChild("SpecPanel");
   var TraitPanel = RootPanel.FindChild("TraitPanel");
   var TraitPanel2 = RootPanel.FindChild("TraitPanel2");
   TraitPanel.visible = false;
   TraitPanel2.visible = false;
   
   $.Msg(SpecPanel);
   
   SpecPanel.visible = true;
   
   SpecPanel.FindChild("WeaponryButton").visible = true;
   SpecPanel.FindChild("EnergyCellsButton").visible = true;
   SpecPanel.FindChild("TriageButton").visible = true;
   SpecPanel.FindChild("LeadershipButton").visible = true;
   SpecPanel.FindChild("PowerArmorButton").visible = true;
   SpecPanel.FindChild("CyberneticsButton").visible = true;
   SpecPanel.FindChild("ChemistryButton").visible = true;
   SpecPanel.FindChild("RoboticsButton").visible = true;
   
   //Check if sniper was selected
   switch(playerClass) {
	   
	   case "sniper":
	   SpecPanel.FindChild("Espionage2Button").visible = true;
	   SpecPanel.FindChild("EspionageButton").visible = false;
	   break;
	   default:
	   SpecPanel.FindChild("EspionageButton").visible = true;
	   SpecPanel.FindChild("Espionage2Button").visible = false;
	   break;
   }
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
		 RootPanel.FindChild("TraitPanel").visible = false;
		 RootPanel.FindChild("TraitPanel2").visible = false;
		 RootPanel.FindChild("SpecPanel").visible = false;
         break;
   }
}

//(function()
//{
//	
	//UpdateClassSelect(); // initial update
//})();
