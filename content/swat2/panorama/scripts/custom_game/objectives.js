"use strict";

//TODO: put tooltips on all elements

var COLOUR_WHITE = "#FFFFFF";
var COLOUR_GREEN = "#4CFF00";
var COLOUR_YELLOW = "#FFD800";
var COLOUR_ORANGE = "#FF6A00";
var COLOUR_RED = "#DF161F";

var radCount = null;
var radNeeded = null;
var hazMats = null;
var civCount = null;
var civNeeded = null;
var powCount = null;
var powNeeded = null;
var falloutLvl = null;

//Controls the radiation objective
function DisplayRad( table ) {
	radCount = table.radcount;
	radNeeded = table.radneeded;
	hazMats = table.hazmats;
	
	var rads = $( "#RadCount" );
	var safeRads = $( "#RadNeeded" );
	var hazIconOn = $( "#HazMatIconOn" );
	var hazIconOff = $( "#HazMatIconOff" );
	var radObjFalse = $( "#RadObjFalse" );
	var radObjTrue = $( "#RadObjTrue" );
	var radObjPerfect = $( "#RadObjPerfect" );
	safeRads.text = $.Localize("/  "+radNeeded); 
	
	//Rad Count Display text changes color if it is over/below safe limit, sets the obj light to off/on/perfect
	if (radCount > radNeeded) {
		rads.style['color'] = COLOUR_RED;
		rads.text = $.Localize(radCount);
		radObjFalse.style.opacity = "1";
		radObjTrue.style.opacity = "0";
		radObjPerfect.style.opacity = "0";
	}
	else if (radCount > 0) {
		rads.style['color'] = COLOUR_WHITE;
		rads.text = $.Localize(radCount);
		radObjFalse.style.opacity = "0";
		radObjTrue.style.opacity = "1";
		radObjPerfect.style.opacity = "0";
	}
	else {
		rads.style['color'] = COLOUR_WHITE;
		rads.text = $.Localize(radCount);
		
		if (hazMats != 0) {
			radObjFalse.style.opacity = "0";
			radObjTrue.style.opacity = "1";
			radObjPerfect.style.opacity = "0";
		}
		
		else {
			radObjFalse.style.opacity = "0";
			radObjTrue.style.opacity = "0";
			radObjPerfect.style.opacity = "1";
		}
		
	}
	
	//HazMat Icon turns off if all materials have been destroyed
	if (hazMats == 0) {
		hazIconOff.style.opacity = "1";
		hazIconOn.style.opacity = "0";
		
	}
}

//Controls the civilians objective
function DisplayCiv( table ) {
	civCount = table.civcount;
	civNeeded = table.civneeded;
	
	var civ = $( "#CivCount" );
	var civReq = $( "#CivNeeded" );
	var civObjFalse = $( "#CivObjFalse" );
	var civObjTrue = $( "#CivObjTrue" );
	var civObjPerfect = $( "#CivObjPerfect" );
	civ.text = $.Localize(civCount); 
	civReq.text = $.Localize("/  "+civNeeded);
	
	//Sets the obj light to off/on/perfect
	if (civCount < civNeeded) {
		civObjFalse.style.opacity = "1";
		civObjTrue.style.opacity = "0";
		civObjPerfect.style.opacity = "0";
	}
	else if (civCount < 32) {
		civObjFalse.style.opacity = "0";
		civObjTrue.style.opacity = "1";
		civObjPerfect.style.opacity = "0";
	}
	else {
		civObjFalse.style.opacity = "0";
		civObjTrue.style.opacity = "0";
		civObjPerfect.style.opacity = "1";
	}
}

//Controls the civilians objective
function DisplayPower( table ) {
	powCount = table.powcount;
	powNeeded = table.powneeded;
	
	var pow = $( "#PowCount" );
	var powReq = $( "#PowNeeded" );
	var powObjFalse = $( "#PowObjFalse" );
	var powObjTrue = $( "#PowObjTrue" );
	var powObjPerfect = $( "#PowObjPerfect" );
	pow.text = $.Localize(powCount); 
	powReq.text = $.Localize("/  "+powNeeded);
	
	//Sets the obj light to off/on/perfect
	if (powCount < powNeeded) {
		powObjFalse.style.opacity = "1";
		powObjTrue.style.opacity = "0";
		powObjPerfect.style.opacity = "0";
	}
	else if (powCount < 6) {
		powObjFalse.style.opacity = "0";
		powObjTrue.style.opacity = "1";
		powObjPerfect.style.opacity = "0";
	}
	else {
		powObjFalse.style.opacity = "0";
		powObjTrue.style.opacity = "0";
		powObjPerfect.style.opacity = "1";
	}
}

//TODO: recode into an actual image
//Controls the fallout meter 
function DisplayFallout( table ) {
	falloutLvl = table.falloutlvl;
	var fallout = $( "#FalloutLvl" );
	var s = "";
	var i = 1;
	
	//Bar grows at rate dependent on fallout level: faster in the beginning, the slower as it gets higher
	//Changes color dependent on fallout level, white -> greem -> yellow -> orange -> red
	if ( falloutLvl < 5 ) {
		while ( i <= falloutLvl ) {
			s = s + "||||";
			i = i + 1;
		}
		fallout.style['color'] = COLOUR_WHITE;
		fallout.text = $.Localize(s);
	}
	else if ( falloutLvl < 10 ) {
		while ( i <= falloutLvl ) {
			s = s + "||||";
			i = i + 1;
		}
		fallout.style['color'] = COLOUR_GREEN;
		fallout.text = $.Localize(s);
	} 
	else if ( falloutLvl < 28 ) {
		s = s + "||||||||||||||||||||||||||||||||||||";
		i = 10;
		while ( i <= falloutLvl ) {
			s = s + "||||";
			i = i + 2;
		}
		fallout.style['color'] = COLOUR_YELLOW;
		fallout.text = $.Localize(s);
	}
	else if ( falloutLvl < 64 ) {
		s = s + "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||";
		i = 28;
		while ( i <= falloutLvl ) {
			s = s + "||||";
			i = i + 3;
		}
		fallout.style['color'] = COLOUR_ORANGE;
		fallout.text = $.Localize(s);
	} 	
	else {
		s = s + "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||";
		i = 64;
		while ( i <= falloutLvl ) {
			s = s + "||";
			i = i + 5;
		}
		fallout.style['color'] = COLOUR_RED;
		fallout.text = $.Localize(s);
	} 		
}

//TODO: Add following LUA code for civ, power, and fallout
//CustomGameEventManager:Send_ServerToAllClients("display_civ", {civcount = self.?? ,civneeded = self.??})
//CustomGameEventManager:Send_ServerToAllClients("display_pow", {powcount = self.?? ,powneeded = self.??})
//CustomGameEventManager:Send_ServerToAllClients("display_fallout", {falloutlvl = self.??})
( function () {
	GameEvents.Subscribe( "display_rad", DisplayRad);
	GameEvents.Subscribe( "display_civ", DisplayCiv);
	GameEvents.Subscribe( "display_pow", DisplayPower);
	GameEvents.Subscribe( "display_fallout", DisplayFallout);
})();