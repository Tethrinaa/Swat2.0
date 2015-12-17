"use strict";

var abilityName = "";
var abilityImage = $( "#AbilityImage" );

function SetAbility( ability )
{
	abilityName = ability;
	abilityImage.abilityname = ability;
}

function AbilityShowTooltip()
{

	$.DispatchEvent( "DOTAShowAbilityTooltip", abilityImage, abilityName);
}

function AbilityHideTooltip()
{
	$.DispatchEvent( "DOTAHideAbilityTooltip", abilityImage );
}

(function()
{
	$.GetContextPanel().data().SetAbility = SetAbility;
})();