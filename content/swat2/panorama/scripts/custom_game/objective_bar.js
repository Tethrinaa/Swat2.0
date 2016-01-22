"use strict";

var civCount = 0;
var civNeeded = 0;
var powCount = 0;
var powNeeded = 0;


function DisplayCiv( table ) {
	civCount = table.civcount;
	civsNeeded = table.civneeded;
	
	var civ = $( "#CivCount" );
	var civReq = $( "#CivNeeded" );
	civ.text = $.Localize(civCount); 
	civReq.text = $.Localize("/   "+civNeeded); 
}

function DisplayPower( table ) {
	powCount = table.powcount;
	powNeeded = table.powneeded;

	var pow = $( "#PowCount" );
	var powReq = $( "#PowNeeded" );
	pow.text = $.Localize(powCount); 
	powReq.text = $.Localize("/   "+powNeeded);
}

//Gets current civ and pow objective info
//TODO: Add following LUA code for gold and valor
//CustomGameEventManager:Send_ServerToAllClients("display_civ", {civcount = self.?? ,civneeded = self.??})
//CustomGameEventManager:Send_ServerToAllClients("display_pow", {powcount = self.?? ,powneeded = self.??})
( function () {
	GameEvents.Subscribe( "display_civ", DisplayCiv);
	GameEvents.Subscribe( "display_pow", DisplayPower);
})();