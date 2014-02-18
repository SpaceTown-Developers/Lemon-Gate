/*==============================================================================================
	Expression Advanced: Entity.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Component = API:NewComponent( "coroutine", true )

Component:AddException( "coroutine" )

/*==============================================================================================
	Section: Class
==============================================================================================*/
local Class = Component:NewClass( "cr", "coroutine" )

-- Assign:

Component:AddOperator( "=", "cr", "cr", [[
%memory[value %1] = value %2
]], "value %2" )

Component:AddFunction( "coroutine", "f", "cr", [[
$coroutine.create( function( ... )
	%context.Entity:Pcall( "Coroutine", value %1, ... )
end )
]] )

Component:AddFunction( "resume", "cr:", "b", "$coroutine.resume( value %1 )" )

Component:AddFunction( "resume", "cr:...", "b", "$coroutine.resume( value %1, %... )" )

Component:AddFunction( "status", "cr:", "s", "$coroutine.status( value %1 )" )

Component:AddFunction( "getCoroutine", "", "cr", [[( $coroutine.running( ) or %context:Throw( "coroutine", "Used getCoroutine( ) outside coroutine." ) )]] )

Component:AddFunction( "yield", "", "", [[
if !$coroutine.running( ) then %context:Throw( "coroutine", "Used yield( ) outside coroutine." ) end
]], "$coroutine.yield( )" )

/*
Component:AddFunction( "sleep", "n", "", [[
local %Coroutine = $coroutine.running( ) or %context:Throw( "coroutine", "Used sleed( N ) outside coroutine." )
timer.Simple( value %2, function( ) coroutine.resume( Coroutine ) end)
]], "$coroutine.yield( )" )*/ -- TODO: FIX THIS!