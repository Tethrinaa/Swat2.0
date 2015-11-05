"use strict";

var COLOUR_NORMAL = "#00AB39";
var COLOUR_WARNING = "#DF161F";

var safeRadCount = null;
var radCount = null;
var hazMats = null;


function DisplayRad( table ) {
	radCount = table.radcount;
	safeRadCount = table.safelevel;
	hazMats = table.hazmat;
	
	var rads = $( "#RadCount" );
	var safeRads = $( "#SafeRadCount" );
	var hazIconOn = $( "#HazMatIconOn" );
	var hazIconOff = $( "#HazMatIconOff" );
	safeRads.text = $.Localize("/ "+safeRadCount); 
	
	//Rad Count Display changes color if it is over/below safe limit
	if (radCount > safeRadCount) {
		rads.style['color'] = COLOUR_WARNING;
		rads.text = $.Localize(radCount); 
	}
	else {
		rads.style['color'] = COLOUR_NORMAL;
		rads.text = $.Localize(radCount); 
	}
	
	//HazMat Icon turns off if all materials have been destroyed
	if (hazMats == 0) {
		hazIconOff.style.opacity = "1";
		hazIconOn.style.opacity = "0";
		
	}
}

//Gets current rad count and safe rad count from RadiationManager
( function () {
	GameEvents.Subscribe( "display_rad", DisplayRad);
})();