"use strict";

var gold = null;
var valor = null;


function DisplayGold( table ) {
	gold = table.goldcount;
	
	var goldAmt = $( "#GoldCount" );
	goldAmt.text = $.Localize(gold); 
}

function DisplayValor( table ) {
	valor = table.valorcount;

	var valorAmt = $( "#ValorCount" );
	valorAmt.text = $.Localize(valor)
}

//Gets current gold and valor
//TODO: Add following LUA code for gold and valor
//CustomGameEventManager:Send_ServerToAllClients("display_gold", {goldcount = self.??})
//CustomGameEventManager:Send_ServerToAllClients("display_valor", {valorcount = self.??})
( function () {
	GameEvents.Subscribe( "display_gold", DisplayGold);
	GameEvents.Subscribe( "display_valor", DisplayValor);
})();