/*==============================================================================================
	Expression Advanced: Component -> Core.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" )

/*==============================================================================================
	Section: Vector 3
==============================================================================================*/
local Vector3 = Core:NewClass( "v", "vector", { 0, 0, 0 } )

-- WireMod

Vector3:Wire_Name( "VECTOR" )

function Vector3.Wire_Out( Context, Cell )
	local A = Context.Memory[ Cell ] or { 0, 0, 0 }
	return Vector( A[1], A[2], A[2] )
end

function Vector3.Wire_In( Context, Cell, Value )
	Context.Memory[ Cell ] = { Value.x, Value.y, Value.z }
end

-- Compare:

Core:AddOperator( "&&", "v,v", "b", "local %A, %B = value %1, value %2", "((%A[1] >= 1 and %A[2] >= 1 and %A[3] >= 1) and (%B[1] >= 1 and %B[2] >= 1 and %B[3] >= 1))" )

Core:AddOperator( "||", "v,v", "v", "local %A = value %1", "(%A[1] - %B[1] <= %Round and %B[1] - %A[1] <= %Round and %A[2] - %B[2] <= %Round and %B[2] - %A[2] <= %Round and%A[3] - %B[3] <= %Round and %B[3] - %A[3] <= %Round)" )

Core:AddOperator( "==", "v,v", "b", "local %A, %B = value %1, value %2", "(%A[1] - %B[1] <= %Round && %B[1] - %A[1] <= %Round and %A[2] - %B[2] <= %Round && %B[2] - %A[2] <= %Round and %A[3] - %B[3] <= %Round && %B[3] - %A[3] <= %Round)" )
	   
Core:AddOperator( "!=", "v,v", "b", "local %A, %B = value %1, value %2", "(%A[1] - %B[1] > %Round or %B[1] - %A[1] > %Round or %A[2] - %B[2] > %Round or %B[2] - %A[2] > %Round or %A[3] - %B[3] > %Round or %B[3] - %A[3] > %Round)" )
	   
-- Arithmatic:

Core:AddOperator( "+", "v,v", "v", "local %A, %B = value %1, value %2", "{%A[1] + %B[1], %A[2] + %B[2], %A[3] + %B[3]}" )

Core:AddOperator( "-", "v,v", "v", "local %A, %B = value %1, value %2", "{%A[1] - %B[1], %A[2] - %B[2], %A[3] - %B[3]}" )

Core:AddOperator( "*", "v,v", "v", "local %A, %B = value %1, value %2", "{%A[1] * %B[1], %A[2] * %B[2], %A[3] * %B[3]}" )

Core:AddOperator( "/", "v,v", "v", "local %A, %B = value %1, value %2", "{%A[1] / %B[1], %A[2] / %B[2], %A[3] / %B[3]}" )

Core:AddOperator( "%", "v,v", "v", "local %A, %B = value %1, value %2", "{%A[1] % %B[1], %A[2] % %B[2], %A[3] % %B[3]}" )

Core:AddOperator( "^", "v,v", "v", "local %A, %B = value %1, value %2", "{%A[1] ^ %B[1], %A[2] ^ %B[2], %A[3] ^ %B[3]}" )

-- Mumberic Arithmatic:

Core:AddOperator( "+", "v,n", "v", "local %A, %B = value %1, value %2", "{%A[1] + %B, %A[2] + %B, %A[3] + %B}" )

Core:AddOperator( "-", "v,n", "v", "local %A, %B = value %1, value %2", "{%A[1] - %B, %A[2] - %B, %A[3] - %B}" )

Core:AddOperator( "*", "v,n", "v", "local %A, %B = value %1, value %2", "{%A[1] * %B, %A[2] * %B, %A[3] * %B}" )

Core:AddOperator( "/", "v,n", "v", "local %A, %B = value %1, value %2", "{%A[1] / %B, %A[2] / %B, %A[3] / %B}" )

Core:AddOperator( "%", "v,n", "v", "local %A, %B = value %1, value %2", "{%A[1] % %B, %A[2] % %B, %A[3] % %B}" )

Core:AddOperator( "^", "v,n", "v", "local %A, %B = value %1, value %2", "{%A[1] ^ %B, %A[2] ^ %B, %A[3] ^ %B}" )

-- General:

Core:AddOperator( "is", "v", "b", "local %A = value %1", "(%A[1] >= 1 and %A[2] >= 1 and %A[3] >= 1)" )

Core:AddOperator( "not", "v", "b", "local %A = value %1", "(%A[1] < 1 and %A[2] < 1 and %A[3] < 1)" )

Core:AddOperator( "-", "v", "v", "local %A = value %1", "{ -%A[1], -%A[2], -%A[3] }" )

Core:AddOperator( "$", "v", "v", "local %V, %D = %memory[value %1], %delta[value %1] or {0, 0, 0}", "{ %D[1] - %V[1], %D[2] - %V[2], %D[3] - %V[3] }" )

-- Constructors:

Core:AddFunction("vec", "n,n,n", "v", "{ value %1, value %2, value %3 }", nil, "Creates a vector" )

-- Co-ords:

Core:AddFunction("x", "v:", "n", "value %1[1]", nil, "Gets the X of a vector" )

Core:AddFunction("y", "v:", "n", "value %1[2]", nil, "Gets the Z of a vector" )

Core:AddFunction("z", "v:", "n", "value %1[3]", nil, "Gets the Z of a vector" )


Core:AddFunction("setX", "v:n", "v", "local %A = value %1", "{ value %2, %A[2], %A[3] }", "Sets the X of a vector" )

Core:AddFunction("setY", "v:n", "v", "local %A = value %1", "{ %A[1], value %2, %A[3] }", "Sets the Y of a vector" )

Core:AddFunction("setZ", "v:n", "v", "local %A = value %1", "{ %A[1], %A[2], value %2 }", "Sets the Z of a vector" )

Core:SetPerf( LEMON_PERF_ABNORMAL )

-- Casting:

Core:AddOperator( "string", "v", "s", "\"<\" .. string.Implode( \",\", value %1 ) .. \">\"" )

Core:AddFunction("toString", "v:", "s", "\"<\" .. string.Implode( \",\", value %1 ) .. \">\"" )

-- Assigment:

Core:AddOperator( "=", "v", "", [[
%delta[value %1] = %memory[value %1]
%memory[value %1] = value %2
%click[value %1] = true
]], "" )

/*==============================================================================================
	Section: Externals
==============================================================================================*/
Core:AddExternal( "Rad2Deg", 180 / math.pi )
Core:AddExternal( "Deg2Rad", math.pi / 180 )

/*==============================================================================================
	length and Distance
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddOperator( "length", "v", "n", "local %V = value %1", "((%V[1] * %V[1] + %V[2] * %V[2] + %V[3] * %V[3]) ^ 0.5)" )

Core:AddFunction("length", "v:", "n", "local %V = value %1", "((%V[1] * %V[1] + %V[2] * %V[2] + %V[3] * %V[3]) ^ 0.5)" )

Core:AddFunction( "distance", "v:v", "n", [[
local A, B = value %1, value %2
local %CX, %CY, %CZ = %A[1] - %B[1], %A[2] - %B[2], %A[3] - %B[3]
]], "((%CX * %CX + %CY * %CY + %CZ * %CZ) ^ 0.5)" )

Core:AddFunction( "length2", "v:", "n", "local %V = value %1", "(%V[1] * %V[1] + %V[2] * %V[2] + %V[3] * %V[3])" )

Core:AddFunction( "distance2", "v:v", "n",[[
local A, B = value %1, value %2
local %CX, %CY, %CZ = %A[1] - %B[1], %A[2] - %B[2], %A[3] - %B[3]
]], "(%CX * %CX + %CY * %CY + %CZ * %CZ)" )

/**********************************************************************************************/

Core:AddFunction( "normalized", "v:", "v", [[
local %V = value %1
local %Len, %Val = (%V[1] * %V[1] + %V[2] * %V[2] + %V[3] * %V[3]) ^ 0.5

if %Len > %Round then
	%Val = { %V[1] / %Len, %V[2] / %Len, %V[3] / %Len }
else
	%Val = { 0, 0, 0 }
end]], "%Val" )

Core:AddFunction( "dot", "v:v", "n", "local A, B = value %1, value %2",
"%A[1] * %B[1] + %A[2] * %B[2] + %A[3] * %B[3]" )

Core:AddFunction( "cross", "v:v", "v", "local A, B = value %1, value %2",
"{%A[2] * %B[3] - %A[3] * %B[2], %A[3] * %B[1] - %A[1] * %B[3], %A[1] * %B[2] - %A[2] * %B[1]}" )

/*==============================================================================================
	World and Local
==============================================================================================*/
Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddFunction( "toWorld", "v,a,v,a", "v", [[
local %A, %B, %C, %D = value %1, value %2, value %3, value %4 
local %Av = $Vector(%A[1], %A[2], %A[3])
local %Bv = $Angle(%B[1], %B[2], %B[3])
local %Cv = $Vector(%C[1], %C[2], %C[3])
local %Dv = $Angle(%D[1], %D[2], %D[3])
local %V = $LocalToWorld(%Av, %Ab, %Ac, %Ad)
]], "{%V.x, %V.y, %V.z}" )

Core:AddFunction("toWorldAngle", "v,a,v,a", "v", [[
local %A, %B, %C, %D = value %1, value %2, value %3, value %4 
local %Av = $Vector(%A[1], %A[2], %A[3])
local %Bv = $Angle(%B[1], %B[2], %B[3])
local %Cv = $Vector(%C[1], %C[2], %C[3])
local %Dv = $Angle(%D[1], %D[2], %D[3])
local _, %V = $LocalToWorld(%Av, %Ab, %Ac, %Ad)
]], "{%V.p, %V.y, %V.r}" )

/**********************************************************************************************/

Core:AddFunction("toLocal", "v,a,v,a", "v", [[
local %A, %B, %C, %D = value %1, value %2, value %3, value %4 
local %Av = $Vector(%A[1], %A[2], %A[3])
local %Bv = $Angle(%B[1], %B[2], %B[3])
local %Cv = $Vector(%C[1], %C[2], %C[3])
local %Dv = $Angle(%D[1], %D[2], %D[3])
local %V = $WorldToLocal(%Av, %Ab, %Ac, %Ad)
]], "{%V.x, %V.y, %V.z}" )

Core:AddFunction("toLocalAngle", "v,a,v,a", "a", [[
local %A, %B, %C, %D = value %1, value %2, value %3, value %4 
local %Av = $Vector(%A[1], %A[2], %A[3])
local %Bv = $Angle(%B[1], %B[2], %B[3])
local %Cv = $Vector(%C[1], %C[2], %C[3])
local %Dv = $Angle(%D[1], %D[2], %D[3])
local _, %V = $WorldToLocal(Av, Ab, Ac, Ad)
]], "{%V.p, %V.y, %V.r}" )

/******************************************************************************/

Core:AddFunction("bearing", "v,a,v", "n", [[
local %A, %B, %C = value %1, value %2, value %3
local %Av = $Vector(%A[1], %A[2], %A[3])
local %Bv = $Angle(%B[1], %B[2], %B[3])
local %Cv = $Vector(%C[1], %C[2], %C[3])
local %V = $WorldToLocal(%Cv, $Angle(0,0,0), %Av, %Bv)
local %Len, %Val = %V:Length(), 0

if (%Len >= %Round) then
	%Val = %Rad2Deg * math.asin(%V.z / %Len)
end]], "%Val" )

Core:AddFunction("elevation", "v,a,v", "n", [[
local %A, %B, %C = value %1, value %2, value %3
local %Av = $Vector(%A[1], %A[2], %A[3])
local %Bv = $Angle(%B[1], %B[2], %B[3])
local %Cv = $Vector(%C[1], %C[2], %C[3])
local %V = $WorldToLocal(%Cv, $Angle(0,0,0), %Av, %Bv)
]], "(%Rad2Deg *- math.atan2(%V.y, %V.x))" )

Core:AddFunction("heading", "v,a,v", "n", [[
local %A, %B, %C = value %1, value %2, value %3
local %Av = $Vector(%A[1], %A[2], %A[3])
local %Bv = $Angle(%B[1], %B[2], %B[3])
local %Cv = $Vector(%C[1], %C[2], %C[3])
local %V = $WorldToLocal(%Cv, $Angle(0,0,0), %Av, %Bv)
local %Bearing = %Rad2Deg *- math.atan2(%V.y, %V.x)
local %Len, %Val = %V:Length(), { 0, %Bearing, 0 }

if (%Len >= %Round) then
	%Val = { %Rad2Deg * math.asin(%V.z / %Len), %Bearing, 0 }
end]], "%Val" )

/*==============================================================================================
	Entity Helpers
==============================================================================================*/
Core:AddFunction("toWorld", "e:v", "v", [[
local %Ent, %A, = value %1, value %2
local %Val = (%Ent and %Ent:IsValid( )) and %Ent:LocalToWorld( $Vector( %A[1], %A[2], %A[3] ) ) or {0, 0, 0 }
]], "%Val" )

Core:AddFunction("toLocal", "e:v", "v", [[
local %Ent, %A, = value %1, value %2
local %Val = (%Ent and %Ent:IsValid( )) and %Ent:WorldToLocal( $Vector( %A[1], %A[2], %A[3] ) ) or {0, 0, 0 }
]], "%Val" )

/*==============================================================================================
	To Angle
==============================================================================================*/
Core:AddOperator("angle", "v", "a", [[
local %V = value %1
local %A = $Vector(%V[1], %V[2], %V[3]):Angle( )
]], "{ %A.p, %A.y, %A.r }" )

Core:AddFunction("toAngle", "v:", "a", [[
local %V = value %1
local %A = $Vector(%V[1], %V[2], %V[3]):Angle( )
]], "{%A.p, %A.y, %A.r }" )

Core:AddFunction("toAngle", "v:v", "a", [[
local %B, %C = value %1, value %2
local %A = $Vector(%B[1], %B[2], %B[3]):AngleEx($Vector(%C[1], %C[2], %C[3]))
]], "{ %A.p, %A.y, %A.r }" )

/*==============================================================================================
	Rotation
==============================================================================================*/
Core:AddFunction("rotate", "v:a", "v", [[
local %A, %B = value %1, value %2
local %C = $Vector(%A[1], %A[2], %A[3])
%C:Rotate( $Angle(%B[1], %B[2], %B[3]) )
]], "{ %C.x, %C.y, %C.z }" )

/*==============================================================================================
	Ceil / Floor / Round
==============================================================================================*/
Core:AddFunction("ceil", "v", "v", "local %V = value %1", "{%V[1] - %V[1] % -1, %V[2] - %V[2] % -1, %V[3] - %V[3] % -1}" )

Core:AddFunction("floor", "v", "v", "local %V = value %1", "{ math.floor(%V[1]), math.floor(%V[2]), math.floor(%V[3]) }" )

Core:AddFunction("ceil", "v,n", "v", [[
local %A, %B = value %1, value %2
local %Shift = 10 ^ math.floor(%B + 0.5)
]], "{ %A[1] - ((%A[1] * %Shift) % -1) / %Shift, %A[2] - ((%A[2] * %Shift) % -1) / %Shift, %A[3] - ((%A[3] * %Shift) % -1) / %Shift }" )

Core:AddFunction("round", "v", "v", "local %V = value %1",
"{ V[1] - (V[1] + 0.5) % 1 + 0.5, %V[2] - (%V[2] + 0.5) % 1 + 0.5, %V[3] - (%V[3] + 0.5) % 1 + 0.5 }" )

Core:AddFunction("round", "v,n", "v", [[
local %A, %B = value %1, value %2
local %Shift = 10 ^ math.floor(%B + 0.5)
]], "{ math.floor(%A[1] * %Shift+0.5) / %Shift, math.floor(%A[2] * %Shift+0.5) / %Shift, math.floor(%A[3] * %Shift+0.5) / %Shift }" )

/*==============================================================================================
	math.Clamping and Inrange
==============================================================================================*/
Core:AddFunction("math.Clamp", "v,v,v", "v", "local %A, %B, %C = value %1, value %2, value %3",
"{ math.Clamp(%A[1], %B[1], %C[1]), math.Clamp(%A[2], %B[2], %C[2]), math.Clamp(%A[3], %B[3], %C[3]) }" )

Core:AddFunction("inrange", "v,v,v", "b", "local %A, %B, %C = value %1, value %2, value %3",
"(!(%A[1] < %B[1] or %A[1] > %C[1] or %A[2] < %B[2] or %A[2] > %C[2] or %A[3] < %B[3] or %A[3] > %C[3]))" )