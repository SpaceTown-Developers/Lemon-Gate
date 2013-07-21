/*==============================================================================================
	Expression Advanced: Component -> Core.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" )

require( "vector3" )
/*==============================================================================================
	Section: Vector 3
==============================================================================================*/
local Vector3 = Core:NewClass( "v", "vector" )

Vector3:UsesMetaTable( FindMetaTable( "Vector3" ) )

-- WireMod

Vector3:Wire_Name( "VECTOR" )

function Vector3.Wire_Out( Context, Cell )
	local Val = Context.Memory[ Cell ] or Vector3( 0, 0, 0 )
	return Val:Garry( )
end

function Vector3.Wire_In( Context, Cell, Value )
	Context.Memory[ Cell ] = Vector3(Value)
end

Core:AddOperator( "default", "v", "v", "Vector3.Zero:Clone()" )

-- Compare:

Core:AddOperator( "&&", "v,v", "b", "((value %1 > Vector3.Zero) and (value %2 > Vector3.Zero))" )

-- Or is default!

Core:AddOperator( "==", "v,v", "b", "(value %1 == value %2)" )
	   
Core:AddOperator( "!=", "v,v", "b", "(value %1 != value %2)" )
	   
-- Arithmatic:

Core:AddOperator( "+", "v,v", "v", "(value %1 + value %2)" )

Core:AddOperator( "-", "v,v", "v", "(value %1 - value %2)" )

Core:AddOperator( "*", "v,v", "v", "(value %1 * value %2)" )

Core:AddOperator( "/", "v,v", "v", "(value %1 / value %2)" )

Core:AddOperator( "%", "v,v", "v", "(value %1 %% value %2)" )

Core:AddOperator( "^", "v,v", "v", "(value %1 ^ value %2)" )

-- Mumberic Arithmatic:

Core:AddOperator( "+", "v,n", "v", "(value %1 + Vector3(value %2, value %2, value %2))" )

Core:AddOperator( "-", "v,n", "v", "(value %1 - Vector3(value %2, value %2, value %2))" )

Core:AddOperator( "*", "v,n", "v", "(value %1 * Vector3(value %2, value %2, value %2))" )

Core:AddOperator( "/", "v,n", "v", "(value %1 / Vector3(value %2, value %2, value %2))" )

Core:AddOperator( "%", "v,n", "v", "(value %1 %% Vector3(value %2, value %2, value %2))" )

Core:AddOperator( "^", "v,n", "v", "(value %1 ^ Vector3(value %2, value %2, value %2))" )

-- General:

Core:AddOperator( "is", "v", "b", "(value %1 > Vector3.Zero)" )

Core:AddOperator( "not", "v", "b", "(value %1 <= Vector3.Zero)" )

Core:AddOperator( "-", "v", "v", "(-value %1)" )

Core:AddOperator( "$", "v", "v", "((%delta[value %1] or Vector3(0, 0, 0)) - (%memory[value %1] or Vector3.Zero))" )

-- Constructors:

Core:AddFunction("vec", "n,n,n", "v", "Vector3( value %1, value %2, value %3 )", nil, "Creates a 3 dimentional vector." )

-- Co-ords:

Core:AddFunction("x", "v:", "n", "value %1.x", nil, "Gets the X of a vector" )

Core:AddFunction("y", "v:", "n", "value %1.y", nil, "Gets the Z of a vector" )

Core:AddFunction("z", "v:", "n", "value %1.z", nil, "Gets the Z of a vector" )


Core:AddFunction("setX", "v:n", "v", "Vector3(value %2, value %1.y, value %1.z)", nil, "Sets the X of a vector" )

Core:AddFunction("setY", "v:n", "v", "Vector3(value %1.x, value %2, value %1.z)", nil, "Sets the Y of a vector" )

Core:AddFunction("setZ", "v:n", "v", "Vector3(value %1.x, value %1.y, value %2)", nil, "Sets the Z of a vector" )

Core:SetPerf( LEMON_PERF_ABNORMAL )

-- Casting:

Core:AddOperator( "string", "v", "s", [[("<" .. tostring( value %1 ) .. ">")]] )

-- Assigment:

Core:AddOperator( "=", "v", "", [[
local %Value = %memory[value %1] or Vector3.Zero
%delta[value %1] = %Value:Clone()
%memory[value %1] = value %2:Clone()
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

Core:AddOperator( "#", "v", "n", "value %1:Length()" )

Core:AddFunction("length", "v:", "n", "value %1:Length()", nil, "Get the lengh of a vector." )

Core:AddFunction( "distance", "v:v", "n", "value %1:Distance( value %2 )", nil, "Get the distance between vectors." )

Core:AddFunction( "length2", "v:", "n", "value %1:RawLength()" )

Core:AddFunction( "distance2", "v:v", "n","value %1:RawDistance( value %2 )" )

/**********************************************************************************************/

Core:AddFunction( "normalized", "v:", "v", "value %1:Normalize( )" )

Core:AddFunction( "dot", "v:v", "n", "value %1:Dot( value %2 )" )

Core:AddFunction( "cross", "v:v", "v", "value %1:Cross( value %2 )" )

/*==============================================================================================
	World and Local
==============================================================================================*/
Core:SetPerf( LEMON_PERF_ABNORMAL )
--TODO: Convert Angle lib =D

Core:AddFunction( "toWorld", "v,a,v,a", "v", "Vector3( $LocalToWorld(value %1:Garry( ), value %2, value %3:Garry( ), value %4) )" )

Core:AddFunction("toWorldAngle", "v,a,v,a", "v", "local _, %Value = $LocalToWorld(value %1:Garry( ), value %2, value %3:Garry( ), value %4) )", "%Value" )

/**********************************************************************************************/

Core:AddFunction( "toLocal", "v,a,v,a", "v", "Vector3( $WorldToLocal(value %1:Garry( ), value %2, value %3:Garry( ), value %4) )" )

Core:AddFunction("toLocalAngle", "v,a,v,a", "v", "local _, %Value = $WorldToLocal(value %1:Garry( ), value %2, value %3:Garry( ), value %4) )", "%Value" )

/******************************************************************************/

Core:AddFunction("bearing", "v,a,v", "n", "(value %1:Bearing(value %2, value %3))" )

Core:AddFunction("elevation", "v,a,v", "n", "(value %1:Elevation(value %2, value %3))" )

Core:AddFunction("heading", "v,a,v", "a", "(value %1:Heading(value %2, value %3))" )

/*==============================================================================================
	Entity Helpers
==============================================================================================*/

Core:AddFunction("toWorld", "e:v", "v", "Vector3( $IsValid( value %1 ) and value %1:LocalToWorld( value %2:Garry( ) ) or Vector(0, 0, 0) )" )

-- Core:AddFunction("toWorld", "e:v", "v", "($IsValid( value %1 ) and value %1:LocalToWorld( value %2:Garry( ) ) or Vector3.Zero)" )

Core:AddFunction("toLocal", "e:v", "v", "($IsValid( value %1 ) and value %1:WorldToLocal( value %2:Garry( ) ) or Vector3.Zero)" )

/*==============================================================================================
	To Angle
==============================================================================================*/
Core:AddOperator("angle", "v", "a", "value %1:Angle( )" )

Core:AddFunction("toAngle", "v:", "a", "value %1:Angle( )" )

Core:AddFunction("toAngle", "v:v", "a", "(value %1:Garry( ):AngleEx( value %2:Garry( ) ))" )

/*==============================================================================================
	Rotation
==============================================================================================*/
Core:AddFunction("rotate", "v:a", "v", "(value %1:Garry( ):Rotate( value %2 ))" )

/*==============================================================================================
	Ceil / Floor / Round
==============================================================================================*/
Core:AddFunction("ceil", "v", "v", "Vector3(value %1.x - value %1.x %% -1, value %1.y - value %1.y %% -1, value %1.z - value %1.z %% -1)" )

Core:AddFunction("floor", "v", "v", "Vector3(math.floor(value %1.x), math.floor(value %1.y), math.floor(value %1.z))" )

Core:AddFunction("ceil", "v,n", "v", [[
local %Shift = 10 ^ math.floor(value %2 + 0.5)
]], "Vector3(value %1.x - ((value %1.x * %Shift) %% -1) / %Shift, value %1.y - ((value %1.y * %Shift) %% -1) / %Shift, value %1.z - ((value %1.z * %Shift) %% -1) / %Shift)" )

Core:AddFunction("round", "v", "v",
"Vector3(V.x - (V.x + 0.5) %% 1 + 0.5, value %1.y - (value %1.y + 0.5) %% 1 + 0.5, value %1.z - (value %1.z + 0.5) %% 1 + 0.5)" )

Core:AddFunction("round", "v,n", "v", [[
local %Shift = 10 ^ math.floor(value %2 + 0.5)
]], "Vector3(math.floor(value %1.x * %Shift+0.5) / %Shift, math.floor(value %1.y * %Shift+0.5) / %Shift, math.floor(value %1.z * %Shift+0.5) / %Shift)" )

/*==============================================================================================
	math.Clamping and Inrange
==============================================================================================*/
Core:AddFunction("clamp", "v,v,v", "v",
"Vector3(math.Clamp(value %1.x, value %2.x, value %3.x), math.Clamp(value %1.y, value %2.y, value %3.y), math.Clamp(value %1.z, value %2.z, value %3.z))" )

Core:AddFunction("inrange", "v,v,v", "b",
"(!(value %1.x < value %2.x or value %1.x > value %3.x or value %1.y < value %2.y or value %1.y > value %3.y or value %1.z < value %2.z or value %1.z > value %3.z))" )

/*==============================================================================================
	Interpolation
==============================================================================================*/
Core:AddFunction("mix", "v,v,n", "v", "local %Shift = 1 - value %3",
"Vector3(value %1.x * value %3 + value %2.x * %Shift, value %1.y * value %3 + value %2.y * %Shift, value %1.z * value %3 + value %2.z * %Shift)",
"Linearly interpolate between two vectors" )
