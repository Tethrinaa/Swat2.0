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
var falloutLvl = null;

//Controls the radiation objective
function DisplayRad( table ) {
	radCount = table.radcount;
	radNeeded = table.radneeded;
	hazMats = table.hazmats;
	
	var rads = $( "#RadCount" );
	var safeRads = $( "#RadNeeded" );
	var hazMatIconOn = $( "#HazMatIconOn" );
	var hazMatIconOff = $( "#HazMatIconOff" );
	var radLight = $( "#RadLight" );
	var radLightIncomplete = $( "#RadLightIncomplete" );
	var radLightComplete = $( "#RadLightComplete" );
	var radLightPerfect = $( "#RadLightPerfect" );
	safeRads.text = $.Localize("/  "+radNeeded); 
	hazMatIconOn.style.opacity = "0";
	hazMatIconOff.style.opacity = "1";
	
	//Sets the obj light to off/on/perfect
	if (radCount > radNeeded) {
		rads.text = $.Localize(radCount);
		radLight.style.boxShadow = "-2px -2px 7px 5px red";
		radLightIncomplete.style.opacity = "1";
		radLightComplete.style.opacity = "0";
		radLightPerfect.style.opacity = "0";
	}
	else if (radCount > 0) {
		rads.text = $.Localize(radCount);
		radLight.style.boxShadow = "-2px -2px 7px 5px green";
		radLightIncomplete.style.opacity = "0";
		radLightComplete.style.opacity = "1";
		radLightPerfect.style.opacity = "0";
	}
	else {
		rads.text = $.Localize(radCount);
		
		if (hazMats != 0) {
			radLight.style.boxShadow = "-2px -2px 7px 5px green";
			radLightIncomplete.style.opacity = "0";
			radLightComplete.style.opacity = "1";
			radLightPerfect.style.opacity = "0";
		}
		
		else {
			radLight.style.boxShadow = "-2px -2px 7px 5px aqua";
			radLightIncomplete.style.opacity = "0";
			radLightComplete.style.opacity = "0";
			radLightPerfect.style.opacity = "1";
		}
		
	}
	
	//HazMat Icon turns on if all materials have been destroyed
	if (hazMats == 0) {
		hazMatIconOn.style.opacity = "1";
		hazMatIconOff.style.opacity = "0";
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

//TODO: Add following LUA code for fallout
//CustomGameEventManager:Send_ServerToAllClients("display_fallout", {falloutlvl = self.??})
( function () {
	GameEvents.Subscribe( "display_rad", DisplayRad);
	GameEvents.Subscribe( "display_fallout", DisplayFallout);
})();