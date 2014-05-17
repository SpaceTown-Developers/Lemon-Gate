/*==============================================================================================
	Expression Advanced: Component -> HTTP.
	Creditors: JerwuQu 
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Component = API:NewComponent( "http", true )

/*==============================================================================================
	Section: Functions
==============================================================================================*/
Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction( "httpRequest", "s,f,f", "", [[
%prepare

$http.Fetch( value %1,
	function( Body )
		%context.Entity:Pcall( "http success callback", value %2, { Body, "s" } )
	end, function( )
		%context.Entity:Pcall( "http fail callback", value %3 )
	end
)
]], "" )

Component:AddFunction( "httpPostRequest", "s,t,f,f", "", [[
%prepare

$http.Post( value %1, value %2.Data,
	function( Body )
		%context.Entity:Pcall( "http success callback", value %3, { Body, "s" } )
	end, function( )
		%context.Entity:Pcall( "http fail callback", value %4 )
	end
)
]], "" )