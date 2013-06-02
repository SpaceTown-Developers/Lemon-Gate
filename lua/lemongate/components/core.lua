/*==============================================================================================
	Expression Advanced: Component -> Core.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

/*==================================================================================================
	API - Syntax:
			
		1)  prepare %N 	-> The preperation for Param N.
		2)  value %N	-> The result (inline) of Param N.
		3)  type %N		-> The short type of N (as string).
		
		4)  %prepare	-> The preperation for anything not effected by 1.
		5)  %perf		-> A line that does the perf calculation and exceed.
		6)  %trace		-> The trace of this function as a table.
		7)  %...		-> A list of variants from a vararg.
		
		8)  %memory		-> Gets the contexts memory table.
		9)  %delta		-> Gets the contexts delta table.
		10) %click		-> Gets the contexts click table.
		11) %data		-> Gets the contexts data table.
		
		12) local %word	-> Define a new local variable with a unique id.
		13) %word		-> Completes 12 using the variables unique id.
		14) %external	-> Uses an external.
		
		15) $variable	-> Imports somthing into the lua enviroment
		
		16)				-> 4 & 5 will pass to calling operator if not used.
		
====================================================================================================
	API - Helpers:
		
		Component = API:NewComponent( Name, Enabled )
		
			Class = Component:NewClass( Short, Name, Default Value )
				Class:Extends( Class To Extends )
				Class:Wire_Name( Name )
				Class.Wire_Out = function( Context, Cell )
				Class.Wire_In = function( Context, Cell, Value )
		
			Component:SetPerf( Perfomance Coast )
			
			Component:AddOperator( Operator, Params, Return, Inline )
			Component:AddOperator( Operator, Params, Return, Prepare, Inline )
			
			Component:AddFunction( Name, Params, Return, Inline )
			Component:AddFunction( Name, Params, Return, Prepare, Inline )
			
			Component:AddExternal( Name, External )
			
==================================================================================================*/

local Core = API:NewComponent( "core", true )

Core:AddExternal( "Round", 0.0000001000000 )

Core:AddExternal( "LongType", function( Short )
	if !Short or Short == "" then
		return "Void"
	else
		return API:GetClass( Short, true ).Name
	end
end )

/*==============================================================================================
	Section: Base Operators
==============================================================================================*/
Core:AddOperator( "=", "", "", [[
%memory[value %1] = value %2
%click[value %1] = true
]], "" )

Core:AddOperator( "variable", "", "", "%memory[value %1]" )

Core:AddOperator( "||", "", "", "local value %1 = value %2", "( value %4 and value %2 or value %3 )" )

Core:AddOperator( "&&", "", "b", "( value %2 and value %2 )" )

/*==============================================================================================
	Section: Booleans
==============================================================================================*/
Core:NewClass( "b", "boolean", false )

Core:SetPerf( LEMON_PERF_CHEAP )

-- Compare:

Core:AddOperator( "&&", "b,b", "b", "(value %1 and value %2)" )

Core:AddOperator( "||", "b,b", "b", "(value %1 or value %2)" )

-- General:

Core:AddOperator( "is", "b", "b", "value %1" )

Core:AddOperator( "not", "b", "b", "(not value %1)" )

-- Casting:

Core:AddOperator( "number", "b", "n", "(value %1 and 1 or 0)" )

Core:AddOperator( "string", "b", "s", "tostring(value %1)" )

/*==============================================================================================
	Section: Exceptions
==============================================================================================*/
local Exception = Core:NewClass( "!", "exception" )

Core:AddFunction( "type", "!:", "s", "(value %1.Class)", nil, "Returns the true type of an Exception" )

Core:AddFunction( "message", "!:", "s", "(value %1.Message)", nil, "Returns the current exceptions message" )

Core:SetPerf( LEMON_PERF_EXPENSIVE )

Core:AddFunction( "trace", "!:n", "t", [[
local %Result = %Table()
local %Trace, %Index = value %1, value %2

if %Trace.Stack or %Index == 1 then
	local %Stack = ((%Index == 1) and %Trace or %Trace.Stack[%Index - 1])
	if %Stack then
		%Result:Set( "line", "n", %Stack[1] )
		%Result:Set( "char", "n", %Stack[2] )
		%Result:Set( "scr", "n", %Stack.Location or "unkown" )
	end
end	
]], "%Result", "Returns a trace at stack position N" )

Core:AddFunction( "trace", "!:", "t", [[
local %Trace = value %1
local %Result, %First = %Table(), %Table()

%First:Set( "line", "n", %Trace[1] )
%First:Set( "char", "n", %Trace[2] )
%First:Set( "scr", "n", %Trace.Location or "unkown" )
%Result:Insert( nil, "t", %First )

if %Trace.Stack then
	for I = 1, #%Trace.Stack do
		local %Trace, %Next = %Trace.Stack[I], %Table()
		%Next:Set( "line", "n", %Trace[1] )
		%Next:Set( "char", "n", %Trace[2] )
		%Next:Set( "scr", "n", %Trace.Location or "unkown" )
		%Result:Insert( nil, "t", %Next )
	end
end
]], "%Result", "Returns a table of traces on the stack." )

-- User Exceptions

Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddException( "user" )

Core:AddFunction( "throw", "s", "", "%context:Throw( %trace, \"user\", value %1 )", nil, "Throws a user exception with a message." )

/*==============================================================================================
	Section: Variants
==============================================================================================*/
Core:NewClass( "?", "variant" )

Core:AddFunction( "type", "?", "s", "%LongType(type %1)", nil, "Returns the true type of a Variant" )

/*==============================================================================================
	Section: Self Building Operators!
==============================================================================================*/

function Core:BuildOperators( )
	for Name, Class in pairs( API.Classes ) do
		
		-- Variants:
			Core:AddOperator( "variant", Class.Short, "?", "{value %1, type %1}" )
		
			Core:AddOperator( Name, "?", Class.Short, "(value %1[2] == " .. Class.Short .. " and value %1[1] or Context:Throw( %trace, \"cast\", \"Attempt to cast value\" .. %1[2] .. \" to " .. Name .. "\"")
		
		-- Functions:
			Core:AddFunction( "type", Class.Short, "s", "\"" .. Name .. "\"", nil, "A usless function that ways returns \"" .. Name .. "\"")
	end
end

/*==============================================================================================
	Section: Basic Functions
==============================================================================================*/
Core:SetPerf( LEMON_PERF_EXPENSIVE )

Core:AddFunction("print", "...", "", [[
local %Message = ""
for _, Peram in pairs( { %... } ) do
	%Message = %Message .. tostring( Peram[1] ) .. " "
end
Context.Player:PrintMessage( 3, string.Left( %Message, 249 ) )
]], "", "Prints to chat." )

/*==============================================================================================
	Section: Statments
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddOperator( "define", "", "", [[
if %memory[value %1] == nil then
	prepare %2
end
]], "" )

Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddOperator( "return", "", "", "return { value %1, type %1 }" )

/*==============================================================================================
	Section: Loops
==============================================================================================*/

Core:SetPerf( LEMON_PERF_EXPENSIVE )

-- 1:Ass, 2:Cnd, 3:Step, 4:Statment
Core:AddOperator( "for", "n", "", [[
do -- For Loop
	local ExitDeph = ExitDeph or 0
	
	prepare %1
	prepare %2
	
	local Step = function( )
		prepare %3
	end
	
	local Statments = function( )
		prepare %4
	end
	
	while ( value %2 ) do
		%perf
		
		local Ok, Exit = pcall( Statments )
		
		if Ok then
			Step( )
		elseif ExitDeph > 0 then
			ExitDeph = ExitDeph - 1
			error( Exit, 0 )
		elseif Exit == "Continue" then
			Step( )
		elseif Exit == "Break" then
			break
		else
			error( Exit, 0 )
		end
	end
end
]], "" )

/*==============================================================================================
	Section: Exiters
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddOperator( "break", "", "", [[
ExitDeph = value %1
error( "Break", 0 )
]], "" )

Core:AddOperator( "continue", "", "", [[
ExitDeph = value %1
error( "Continue", 0 )
]], "" )

/*==============================================================================================
	Section: Variable Args
==============================================================================================*/
Core:AddOperator( "vararg", "...", "...", "%..." )

/*==============================================================================================
	Section: Self Aware
==============================================================================================*/
Core:AddFunction( "self", "", "e", "%context.Entity", nil, "Gets the entity of the executing lemongate." )

Core:AddFunction( "owner", "", "e", "%context.Player", nil, "Gets the owner of the executing lemongate." )

Core:AddFunction( "selfDestruct", "", "e", "%context.Entity:Remove( )" )

/*==============================================================================================
	Section: Gate Name
==============================================================================================*/
Core:AddFunction( "gateName", "", "s", "%context.Entity.GateName" )

Core:AddFunction( "gateName", "s", "", "%context.Entity:SetGateName( value %1 )" )

/*==============================================================================================
	Section: Perf
==============================================================================================*/
Core:AddFunction( "perf", "", "n", "%context.Perf" )

Core:AddFunction( "perfAvailable", "", "n", "($GetConVarNumber(\"lemongate_perf\") - %context.Perf)" )

Core:AddFunction( "maxPerf", "", "n", "$GetConVarNumber(\"lemongate_perf\")" )

Core:AddFunction( "maxPerf", "", "n", [[
local %Perf, %MaxPerf, %Val = %context, $GetConVarNumber("lemongate_perf"), 0
if %Perf > 0 and %MaxPerf > 0 then
 %Val = math.ceil((%Perf / %MaxPerf) * 100)
end]], "%Val")

/*==============================================================================================
	Section: Things that have no place to go!
==============================================================================================*/
Core:AddFunction( "map", "", "s", "($game.GetMap( ) or \"\")" )