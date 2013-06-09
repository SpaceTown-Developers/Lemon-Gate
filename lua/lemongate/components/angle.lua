/*==============================================================================================
	Expression Advanced: Component -> Core.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" )

/*==============================================================================================
	Section: Angle Class
==============================================================================================*/
local Class = Core:NewClass( "a", "angle", { 0, 0, 0 } )

-- WireMod

Class:Wire_Name( "ANGLE" )

function Class.Wire_Out( Context, Cell )
	local A = Context.Memory[ Cell ] or { 0, 0, 0 }
	return Angle( A[1], A[2], A[2] )
end

function Class.Wire_In( Context, Cell, Value )
	Context.Memory[ Cell ] = { Value.p, Value.y, Value.r }
end

-- Compare:

Core:AddOperator( "&&", "a,a", "b", "local %A, %B = value %1, value %2", "((%A[1] >= 1 and %A[2] >= 1 and %A[3] >= 1) and (%B[1] >= 1 and %B[2] >= 1 and %B[3] >= 1))" )

Core:AddOperator( "||", "a,a", "a", "local %A = value %1", "((%A[1] >= 1 and %A[2] >= 1 and %A[3] >= 1) and %A or value %2)" )

Core:AddOperator( "==", "a,a", "b", "local %A, %B = value %1, value %2", "(%A[1] - %B[1] <= %Round and %B[1] - %A[1] <= %Round and %A[2] - %B[2] <= %Round and %B[2] - %A[2] <= %Round and%A[3] - %B[3] <= %Round and %B[3] - %A[3] <= %Round)" )

Core:AddOperator( "!=", "a,a", "b", "local %A, %B = value %1, value %2", "(%A[1] - %B[1] > %Round or %B[1] - %A[1] > %Round or %A[2] - %B[2] > %Round or %B[2] - %A[2] > %Round or %A[3] - %B[3] > %Round or %B[3] - %A[3] > %Round)" )
	   
-- Arithmatic:

Core:AddOperator( "+", "a,a", "a", "local %A, %B = value %1, value %2", "{%A[1] + %B[1], %A[2] + %B[2], %A[3] + %B[3]}" )

Core:AddOperator( "-", "a,a", "a", "local %A, %B = value %1, value %2", "{%A[1] - %B[1], %A[2] - %B[2], %A[3] - %B[3]}" )

Core:AddOperator( "*", "a,a", "a", "local %A, %B = value %1, value %2", "{%A[1] * %B[1], %A[2] * %B[2], %A[3] * %B[3]}" )

Core:AddOperator( "/", "a,a", "a", "local %A, %B = value %1, value %2", "{%A[1] / %B[1], %A[2] / %B[2], %A[3] / %B[3]}" )

Core:AddOperator( "%", "a,a", "a", "local %A, %B = value %1, value %2", "{%A[1] % %B[1], %A[2] % %B[2], %A[3] % %B[3]}" )

Core:AddOperator( "^", "a,a", "a", "local %A, %B = value %1, value %2", "{%A[1] ^ %B[1], %A[2] ^ %B[2], %A[3] ^ %B[3]}" )

-- Mumberic Arithmatic:

Core:AddOperator( "+", "a,n", "a", "local %A, %B = value %1, value %2", "{%A[1] + %B, %A[2] + %B, %A[3] + %B}" )

Core:AddOperator( "-", "a,n", "a", "local %A, %B = value %1, value %2", "{%A[1] - %B, %A[2] - %B, %A[3] - %B}" )

Core:AddOperator( "*", "a,n", "a", "local %A, %B = value %1, value %2", "{%A[1] * %B, %A[2] * %B, %A[3] * %B}" )

Core:AddOperator( "/", "a,n", "a", "local %A, %B = value %1, value %2", "{%A[1] / %B, %A[2] / %B, %A[3] / %B}" )

Core:AddOperator( "%", "a,n", "a", "local %A, %B = value %1, value %2", "{%A[1] % %B, %A[2] % %B, %A[3] % %B}" )

Core:AddOperator( "^", "a,n", "a", "local %A, %B = value %1, value %2", "{%A[1] ^ %B, %A[2] ^ %B, %A[3] ^ %B}" )

-- General:

Core:AddOperator( "is", "a", "b", "local %A = value %1", "(%A[1] >= 1 and %A[2] >= 1 and %A[3] >= 1)" )

Core:AddOperator( "not", "a", "b", "local %A = value %1", "(%A[1] < 1 and %A[2] < 1 and %A[3] < 1)" )

Core:AddOperator( "-", "a", "a", "local %A = value %1", "{ -%A[1], -%A[2], -%A[3] }" )

Core:AddOperator( "$", "a", "a", "local %V, %D = %memory[value %1], %delta[value %1] or {0, 0, 0}", "{ %D[1] - %V[1], %D[2] - %V[2], %D[3] - %V[3] }" )

-- Constructors:

Core:AddFunction("ang", "n,n,n", "a", "{ value %1, value %2, value %3 }", nil, "Creates a angle" )

-- Co-ords:

Core:AddFunction("p", "a:", "n", "value %1[1]", nil, "Gets the pitch of a angle" )

Core:AddFunction("y", "a:", "n", "value %1[2]", nil, "Gets the yaw of a angle" )

Core:AddFunction("r", "a:", "n", "value %1[3]", nil, "Gets the roll of a angle" )


Core:AddFunction("setPitch", "a:n", "a", "local %A = value %1", "{ value %2, %A[2], %A[3] }", "Sets the pitch of a angle" )

Core:AddFunction("setYaw", "a:n", "a", "local %A = value %1", "{ %A[1], value %2, %A[3] }", "Sets the yaw of a angle" )

Core:AddFunction("setRoll", "a:n", "a", "local %A = value %1", "{ %A[1], %A[2], value %2 }", "Sets the roll of a angle" )

Core:SetPerf( LEMON_PERF_ABNORMAL )

-- Casting:

Core:AddOperator( "string", "a", "s", "\"<\" .. string.Implode( \",\", value %1 ) .. \">\"" )

Core:AddFunction("toString", "a:", "s", "\"<\" .. string.Implode( \",\", value %1 ) .. \">\"" )

-- Assigment:

Core:AddOperator( "=", "a", "", [[
%delta[value %1] = %memory[value %1]
%memory[value %1] = value %2
%click[value %1] = true
]], "" )

/*==============================================================================================
	Section: General
==============================================================================================*/
Core:AddFunction( "angnorm", "a", "a", "local %A = value %1",
"{(%A[1] + 180) % 360 - 180,(%A[2] + 180) % 360 - 180,(%A[3] + 180) % 360 - 180}" ) 


/*==============================================================================================
	Section: Directional
==============================================================================================*/
Core:AddFunction("forward", "a:", "a", [[
local %A = value %1
local %V = $Angle(%A[1], %A[2], %A[3]):Forward( )
]], "{%V.x, %V.y, %V.z}" )

Core:AddFunction("right", "a:", "a", [[
local %A = value %1
local %V = $Angle(%A[1], %A[2], %A[3]):Right( )
]], "{%V.x, %V.y, %V.z}" )

Core:AddFunction("up", "a:", "a", [[
local %A = value %1
local %V = $Angle(%A[1], %A[2], %A[3]):Up( )
]], "{%V.x, %V.y, %V.z}" )

/*==============================================================================================
	Ceil / Floor / Round
==============================================================================================*/
Core:AddFunction("ceil", "a", "a", "local %V = value %1", "{%V[1] - %V[1] % -1, %V[2] - %V[2] % -1, %V[3] - %V[3] % -1}" )

Core:AddFunction("floor", "a", "a", "local %V = value %1", "{ math.floor(%V[1]), math.floor(%V[2]), math.floor(%V[3]) }" )

Core:AddFunction("ceil", "v,n", "a", [[
local %A, %B = value %1, value %2
local %Shift = 10 ^ math.floor(%B + 0.5)
]], "{ %A[1] - ((%A[1] * %Shift) % -1) / %Shift, %A[2] - ((%A[2] * %Shift) % -1) / %Shift, %A[3] - ((%A[3] * %Shift) % -1) / %Shift }" )

Core:AddFunction("round", "a", "a", "local %V = value %1",
"{ V[1] - (V[1] + 0.5) % 1 + 0.5, %V[2] - (%V[2] + 0.5) % 1 + 0.5, %V[3] - (%V[3] + 0.5) % 1 + 0.5 }" )

Core:AddFunction("round", "v,n", "a", [[
local %A, %B = value %1, value %2
local %Shift = 10 ^ math.floor(%B + 0.5)
]], "{ math.floor(%A[1] * %Shift+0.5) / %Shift, math.floor(%A[2] * %Shift+0.5) / %Shift, math.floor(%A[3] * %Shift+0.5) / %Shift }" )

/*==============================================================================================
	math.Clamping and Inrange
==============================================================================================*/
Core:AddFunction("math.Clamp", "a,a,a", "a", "local %A, %B, %C = value %1, value %2, value %3",
"{ math.Clamp(%A[1], %B[1], %C[1]), math.Clamp(%A[2], %B[2], %C[2]), math.Clamp(%A[3], %B[3], %C[3]) }" )

Core:AddFunction("inrange", "a,a,a", "b", "local %A, %B, %C = value %1, value %2, value %3",
"(!(%A[1] < %B[1] or %A[1] > %C[1] or %A[2] < %B[2] or %A[2] > %C[2] or %A[3] < %B[3] or %A[3] > %C[3]))" )

/*==============================================================================================
	Entity Helpers
==============================================================================================*/
Core:AddFunction("toWorld", "e:v", "v", [[
local %Ent, %A = value %1, value %2
local %Val = (%Ent and %Ent:IsValid( )) and %Ent:LocalToWorldAngles( $Angle( %A[1], %A[2], %A[3] ) ) or {0, 0, 0 }
]], "%Val" )

Core:AddFunction("toLocal", "e:v", "v", [[
local %Ent, %A = value %1, value %2
local %Val = (%Ent and %Ent:IsValid( )) and %Ent:WorldToLocalAngles( $Angle( %A[1], %A[2], %A[3] ) ) or {0, 0, 0 }
]], "%Val" )