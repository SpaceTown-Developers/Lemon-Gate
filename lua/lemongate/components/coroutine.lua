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

Component:AddFunction( "getCoroutine", "", "cr", [[( $coroutine.running( ) or %context:Throw( %trace, "coroutine", "Used getCoroutine( ) outside coroutine." ) )]] )

Component:AddFunction( "yield", "", "", [[
if !$coroutine.running( ) then %context:Throw( %trace, "coroutine", "Used yield( ) outside coroutine." ) end
]], "$coroutine.yield( )" )

/*==============================================================================================
	Section: Sleep Function
==============================================================================================*/
Component:AddExternal( "sleep", function( Context, N )
	local CoRoutine = coroutine.running( )
	if !CoRoutine then Context:Throw( nil, "coroutine", "Used sleed( N ) outside coroutine." ) end

	timer.Simple( N, function( )
		if !IsValid( Context.Entity ) or !Context.Entity:IsRunning( ) then return end

		coroutine.resume( CoRoutine )
	end )

	coroutine.yield( )
end )

Component:AddFunction( "sleep", "n", "", "%sleep( %context, value %1 )", "" )

/*==============================================================================================
	Section: Wait Function
==============================================================================================*/
local NoWaitable = { keypress = true, keyrelease = true, use = true }

Component.Queue = { }

function Component:GetQueue( Name )
	if !self.Queue[Name] then self.Queue[Name] = { } end
	return self.Queue[Name]
end

function Component:PostEvent( Name )
	local Que = self:GetQueue( Name )
	self.Queue[Name] = nil

	for i = 1, #Que do
		Que[i]( )
	end
end

Component:AddExternal( "wait", function( Context, Name )
	local CoRoutine = coroutine.running( )
	if !CoRoutine then Context:Throw( nil, "coroutine", "Used wait( S ) outside coroutine." ) end

	if !API.Events[ Name ] or NoWaitable[ Name ] then
		Context:Throw( nil, "coroutine", "No such waitable event " .. Name )
	end

	local Que = Component:GetQueue( Name )

	Que[ #Que + 1 ] = function( )
		local Context, CoRoutine = Context, CoRoutine -- Cus of GC
		if IsValid( Context.Entity ) and Context.Entity:IsRunning( ) then
			coroutine.resume( CoRoutine )
		end
	end

	coroutine.yield( )
end )

Component:AddFunction( "wait", "s", "", "%wait( %context, value %1 )", "" )