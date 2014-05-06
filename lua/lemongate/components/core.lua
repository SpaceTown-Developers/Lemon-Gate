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
		5)  %cpu		-> A line that cpu usage.
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
%click[value %1] = true -- Defaq
]], "value %2" )

Core:AddOperator( "variable", "", "", "%memory[value %1]" )

Core:AddOperator( "||", "", "", "( value %1 or value %2 )" )

Core:AddOperator( "?", "", "", "( value %1 and value %2 or value %3 )" )

Core:AddOperator( "&&", "", "b", "( value %2 and value %2 )" )

/*==============================================================================================
	Section: Booleans
==============================================================================================*/
Core:NewClass( "b", "boolean", false )

-- Assign:

Core:AddOperator( "=", "b", "", [[
%delta[value %1] = %memory[value %1]
%memory[value %1] = value %2
%click[value %1] = %delta[value %1] ~= %memory[value %1]
]], "" )

Core:AddOperator( "~", "b", "b", "%click[value %1]" )

-- Compare:

Core:AddOperator( "&&", "b,b", "b", "(value %1 and value %2)" )

Core:AddOperator( "||", "b,b", "b", "(value %1 or value %2)" )

Core:AddOperator( "==", "b,b", "b", "(value %1 == value %2)" )

Core:AddOperator( "!=", "b,b", "b", "(value %1 != value %2)" )

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

Core:AddFunction( "type", "!:", "s", "(value %1.Type)", nil )

Core:AddFunction( "message", "!:", "s", "(value %1.Message)", nil )

Core:AddFunction( "trace", "!:n", "t", [[
local %Result = %Table()
local %Trace, %Index = value %1.Trace, value %2

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
local %Trace = value %1.Trace
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

Core:AddFunction( "getTable", "!:", "t", "(value %1.Table or %Table())", nil )

-- User Exceptions

Core:AddException( "user" )

Core:AddFunction( "throw", "s", "", "%context:Throw( %trace, \"user\", value %1 )", nil )

Core:AddFunction( "throw", "s,t", "", "%context:Throw( %trace, \"user\", value %1, value %2 )", nil )

/*==============================================================================================
	Section: Variants
==============================================================================================*/
Core:NewClass( "?", "variant" )

Core:AddFunction( "type", "?", "s", "local %Val = value %1", "%LongType(%Val[2])", "Returns the true type of a Variant" )

Core:AddFunction( "tostring", "?", "s", "( tostring(value %1[1]) .. \" -> \" .. %LongType(value %1[2]) )" )

/*==============================================================================================
	Section: Self Building Operators!
==============================================================================================*/

function Core:BuildOperators( )
	
	for Name, Class in pairs( API.Classes ) do
		
		-- Variants:
			Core:AddOperator( "variant", Class.Short, "?", "{value %1, type %1}" )
		
			Core:AddOperator( Name, "?", Class.Short, Format( [[
			if value %%1[2] ~= %q then
				%%context:Throw( %%trace, "cast", "Attempt to cast value " .. LongType(value %%1[2]) .. " to %s ")
			end]], Class.Short, Name ), "value %1[1]" )
			
		-- Functions:
			if !Name == "variant" then
				Core:AddFunction( "type", Class.Short, "s", "\"" .. Name .. "\"", nil)
			end
	end
end

/*==============================================================================================
	Section: Statments
==============================================================================================*/

Core:AddOperator( "static", "", "", [[
if %memory[value %1] == nil then
	prepare %2
end
]], "" )

Core:AddOperator( "return", "", "", "if true then return value %1 end" ) -- Yes, its hacky!

Core:AddOperator( "exit", "", "", "error( 'Exit', 0 )" )

/*==============================================================================================
	Section: Connect Operators
==============================================================================================*/

Core:AddOperator( "->i", "", "b", [[(%context.Entity.Inputs["value %1"].Src ~= nil)]] )

Core:AddOperator( "->o", "", "b", [[(#%context.Entity.Outputs["value %1"].Connected > 0)]] )

/*==============================================================================================
	Section: Loops
==============================================================================================*/
-- 1:Ass, 2:Cnd, 3:Step, 4:Statment
Core:AddOperator( "for", "n", "", [[
	prepare %1

	prepare %2

	prepare %3

	while ( value %2 ) do
		%cpu

		prepare %4

		value %3
	end
]], "" )

Core:AddOperator( "while", "", "", [[
	
	while ( value %1 ) do
		%cpu
		
		prepare %2
	end
]], "" )

/*==============================================================================================
	Section: Exiters
==============================================================================================*/

Core:AddOperator( "break", "", "", "if true then break end" )

Core:AddOperator( "continue", "", "", "if true then continue end" )

/*==============================================================================================
	Section: Variable Args
==============================================================================================*/
Core:AddOperator( "vararg", "...", "...", "%..." )

/*==============================================================================================
	Section: Self Aware
==============================================================================================*/
Core:AddFunction( "self", "", "e", "%context.Entity", nil )

Core:AddFunction( "owner", "", "e", "%context.Player", nil )

Core:AddFunction( "selfDestruct", "", "", "%context.Entity:Remove( ); error( 'Exit', 0 )" )

Core:AddFunction( "exit", "", "", "error( 'Exit', 0 )" )

/*==============================================================================================
	Section: Gate Name
==============================================================================================*/
Core:AddFunction( "gateName", "", "s", "%context.Entity.GateName" )

Core:AddFunction( "gateName", "s", "", "%context.Entity:SetGateName( value %1 )" )

/*==============================================================================================
	Section: CPU time usage!
==============================================================================================*/

-- Returns the amount of cpu time used so far in the current execution in microseconds
Core:AddFunction( "cpuTime", "", "n", "( $SysTime( ) - %context.cpu_tick ) * 1000000" )

-- Returns the amount of cpu time used on average in microseconds
Core:AddFunction( "cpuAverage", "", "n", "%context.cpu_average * 1000000" )

-- Returns the size of the tick quota in microseconds
Core:AddFunction( "tickQuota", "", "n", "$GetConVarNumber(\"lemongate_tick_cpu\", 0)" )

-- Returns the size of the soft quota in microseconds
Core:AddFunction( "softQuota", "", "n", "$GetConVarNumber(\"lemongate_soft_cpu\", 0)" )

-- Returns the size of the hard quota in microseconds
Core:AddFunction( "hardQuota", "", "n", "$GetConVarNumber(\"lemongate_hard_cpu\", 0)" )

/*==============================================================================================
	Section: Engine
==============================================================================================*/
Core:AddFunction( "map", "", "s", "($game.GetMap( ) or \"\")" )

Core:AddFunction( "hostName", "", "s", "$GetConVar(\"hostname\"):GetString()" )

Core:AddFunction( "isSinglePlayer", "", "b", "$game.SinglePlayer()" )

Core:AddFunction( "isDedicated", "", "b", "$game.IsDedicated()" )

Core:AddFunction( "numPlayers", "", "n", "(#player.GetAll())" )

Core:AddFunction( "maxPlayers", "", "n", "$game.MaxPlayers()" )

Core:AddFunction( "gravity", "", "n", "$GetConVar(\"sv_gravity\"):GetFloat()" )

Core:AddFunction( "propGravity", "", "v", "Vector3( $physenv.GetGravity() )" )

Core:AddFunction( "airDensity", "", "n", "$physenv.GetAirDensity()" )

Core:AddFunction( "maxFrictionMass", "", "n", "($physenv.GetPerformanceSettings()[\"MaxFrictionMass\"])" )

Core:AddFunction( "minFrictionMass", "", "n", "($physenv.GetPerformanceSettings()[\"MinFrictionMass\"])" )

Core:AddFunction( "speedLimit", "", "n", "($physenv.GetPerformanceSettings()[\"MaxVelocity\"])" )

Core:AddFunction( "angSpeedLimit", "", "n", "($physenv.GetPerformanceSettings()[\"MaxAngularVelocity\"])" )

/*==============================================================================================
	Section: Do not exist functions (Compiler operators)
==============================================================================================*/
Core:AddFunction( "print", "...", "", "" )
Core:AddFunction( "include", "s", "", "" )
Core:AddFunction( "include", "s,b", "", "" )
