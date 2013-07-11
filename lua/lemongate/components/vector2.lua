/*==============================================================================================
	Expression Advanced: Component -> Core.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" )

require( "vector2" )
/*==============================================================================================
	Section: Vector 3
==============================================================================================*/
local Vector2 = Core:NewClass( "v2", "vector2" )

-- WireMod

Vector2:Wire_Name( "VECTOR2" )

function Vector3.Wire_Out( Context, Cell )
	local Val = Context.Memory[ Cell ] or Vector2( 0, 0 )
	return { Val.x, Val.y }
end

function Vector3.Wire_In( Context, Cell, Value )
	Context.Memory[ Cell ] = Vector2(Value[1], Value[2])
end

Core:AddOperator( "default", "v2", "v2", "Vector2.Zero:Clone()" )

-- Compare:

Core:AddOperator( "&&", "v2,v2", "b", "((value %1 > Vector2.Zero) and (value %2 > Vector2.Zero)" )

-- Or is default!

Core:AddOperator( "==", "v2,v2", "b", "(value %1 == value %2)" )
	   
Core:AddOperator( "!=", "v2,v2", "b", "(value %1 != value %2)" )
	   
-- Arithmatic:

Core:AddOperator( "+", "v2,v2", "v2", "(value %1 + value %2)" )

Core:AddOperator( "-", "v2,v2", "v2", "(value %1 - value %2)" )

Core:AddOperator( "*", "v2,v2", "v2", "(value %1 * value %2)" )

Core:AddOperator( "/", "v2,v2", "v2", "(value %1 / value %2)" )

Core:AddOperator( "%", "v2,v2", "v2", "(value %1 % value %2)" )

Core:AddOperator( "^", "v2,v2", "v2", "(value %1 ^ value %2)" )

-- Mumberic Arithmatic:

Core:AddOperator( "+", "v2,n", "v2", "(value %1 + Vector2(value %2, value %2))" )

Core:AddOperator( "-", "v2,n", "v2", "(value %1 - Vector2(value %2, value %2))" )

Core:AddOperator( "*", "v2,n", "v2", "(value %1 * Vector2(value %2, value %2))" )

Core:AddOperator( "/", "v2,n", "v2", "(value %1 / Vector2(value %2, value %2))" )

Core:AddOperator( "%", "v2,n", "v2", "(value %1 % Vector2(value %2, value %2))" )

Core:AddOperator( "^", "v2,n", "v2", "(value %1 ^ Vector2(value %2, value %2))" )

-- General:

Core:AddOperator( "is", "v2", "b", "(value %1 > Vector2.Zero)" )

Core:AddOperator( "not", "v2", "b", "(value %1 >= Vector2.Zero)" )

Core:AddOperator( "-", "v2", "v2", "(-value %1)" )

Core:AddOperator( "$", "v2", "v2", "((%delta[value %1] or Vector2(0, 0)) - (%memory[value %1] or Vector2.Zero))" )

-- Constructors:

Core:AddFunction("vec2", "n,n", "v2", "Vector2( value %1, value %2)", nil, "Creates a 2 dimentional vector." )

-- Co-ords:

Core:AddFunction("x", "v2:", "n", "value %1.x", nil, "Gets the X of a vector" )

Core:AddFunction("y", "v2:", "n", "value %1.y", nil, "Gets the Z of a vector" )


Core:AddFunction("setX", "v2:n", "v2", "Vector2(value %2, value %1.y)", "Sets the X of a vector" )

Core:AddFunction("setY", "v2:n", "v2", "Vector2(value %1.x, value %2)", "Sets the Y of a vector" )

Core:SetPerf( LEMON_PERF_ABNORMAL )

-- Casting:

Core:AddOperator( "string", "v2", "s", [[("<" .. tostring( value %1 ) .. ">")]] )

-- Assigment:

Core:AddOperator( "=", "v2", "", [[
local %Value = %memory[value %1] or Vector2.Zero
%delta[value %1] = %Value:Clone()
%memory[value %1] = value %2:Clone()
%click[value %1] = true
]], "" )

/*==============================================================================================
	length and Distance
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddOperator( "length", "v2", "n", "value %1:Length()" )

Core:AddFunction("length", "v2:", "n", "value %1:Length()", nil, "Get the lengh of a vector." )

Core:AddFunction( "distance", "v2:v", "n", "value %1:Distance( value %2 )", nil, "Get the distance between vectors." )

/**********************************************************************************************/

Core:AddFunction( "normalized", "v2:", "v2", "value %1:Normalize( )" )

Core:AddFunction( "dot", "v2:v", "n", "value %1:Dot( value %2 )" )

Core:AddFunction( "cross", "v2:v", "v2", "value %1:Cross( value %2 )" )