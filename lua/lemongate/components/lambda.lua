/*==============================================================================================
	Expression Advanced: Lambda.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core", true )

/*==============================================================================================
	Section: Lambda
==============================================================================================*/
Core:NewClass( "f", "function", function( ) end )

Core:AddOperator( "call", "f,...", "?", [[
	%prepare
	local %Value = %memory[ value %1 ]( %... ) or { 0, "n" }
]], "%Value" )

