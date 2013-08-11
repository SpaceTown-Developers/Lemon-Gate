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

Class:UsesMetaTable( FindMetaTable( "Angle" ) )

-- WireMod

Class:Wire_Name( "ANGLE" )

function Class.Wire_Out( Context, Cell )
	return Context.Memory[ Cell ] or Angle(0, 0, 0)
end

function Class.Wire_In( Context, Cell, Value )
	Context.Memory[ Cell ] = Value
end

-- Compare:

Core:AddOperator( "&&", "a,a", "b", "((value %1.p >= 1 and value %1.y >= 1 and value %1.r >= 1) and (value %2.p >= 1 and value %2.y >= 1 and value %2.r >= 1))" )

Core:AddOperator( "==", "a,a", "b", "(value %1 == value %2)" )

Core:AddOperator( "!=", "a,a", "b", "(value %1 != value %2)" )
	   
-- Arithmatic:

Core:AddOperator( "+", "a,a", "a", "(value %1 + value %2)", LEMON_INLINE_ONLY )

Core:AddOperator( "-", "a,a", "a", "(value %1 - value %2)", LEMON_INLINE_ONLY )

Core:AddOperator( "*", "a,a", "a", "Angle(value %1.p * value %2.p, value %1.y * value %2.y, value %1.r * value %2.r)", LEMON_INLINE_ONLY )

Core:AddOperator( "/", "a,a", "a", "Angle(value %1.p / value %2.p, value %1.y / value %2.y, value %1.r / value %2.r)", LEMON_INLINE_ONLY )

Core:AddOperator( "%", "a,a", "a", "Angle(value %1.p % value %2.p, value %1.y % value %2.y, value %1.r % value %2.r)", LEMON_INLINE_ONLY )

Core:AddOperator( "^", "a,a", "a", "Angle(value %1.p ^ value %2.p, value %1.y ^ value %2.y, value %1.r ^ value %2.r)", LEMON_INLINE_ONLY )

-- Mumberic Arithmatic:

Core:AddOperator( "+", "a,n", "a", "(value %1 + Angle(value %2, value %2, value %2))", LEMON_INLINE_ONLY )

Core:AddOperator( "-", "a,n", "a", "(value %1 - Angle(value %2, value %2, value %2))", LEMON_INLINE_ONLY )

Core:AddOperator( "*", "a,n", "a", "Angle(value %1.p * value %2, value %1.y * value %2, value %1.r * value %2)", LEMON_INLINE_ONLY )

Core:AddOperator( "/", "a,n", "a", "Angle(value %1.p / value %2, value %1.y / value %2, value %1.r / value %2)", LEMON_INLINE_ONLY )

Core:AddOperator( "%", "a,n", "a", "Angle(value %1.p % value %2, value %1.y % value %2, value %1.r % value %2)", LEMON_INLINE_ONLY )

Core:AddOperator( "^", "a,n", "a", "Angle(value %1.p ^ value %2, value %1.y ^ value %2, value %1.r ^ value %2)", LEMON_INLINE_ONLY )


-- General:
Core:AddOperator( "is", "a", "b", "(value %1.p >= 1 and value %1.y >= 1 and value %1.r >= 1)" )

Core:AddOperator( "not", "a", "b", "(value %1.p < 1 and value %1.y < 1 and value %1.r < 1)" )

Core:AddOperator( "-", "a", "a", "(-value %1)" )

Core:AddOperator( "$", "a", "a", "((%delta[value %1] or Angle(0, 0, 0)) - (%memory[value %1]or Angle(0, 0, 0)))" )

-- Constructors:

Core:AddFunction( "ang", "n,n,n", "a", "Angle(value %1, value %2, value %3)", LEMON_INLINE_ONLY )

-- Co-ords:

Core:AddFunction( "p", "a:", "n", "value %1.p", LEMON_INLINE_ONLY )

Core:AddFunction( "y", "a:", "n", "value %1.y", LEMON_INLINE_ONLY )

Core:AddFunction( "r", "a:", "n", "value %1.r", LEMON_INLINE_ONLY )


Core:AddFunction( "setPitch", "a:n", "a", "Angle(value %2, value %1.y, value %1.r)", LEMON_INLINE_ONLY )

Core:AddFunction( "setYaw", "a:n", "a", "Angle(value %1.p, value %2, value %1.r)", LEMON_INLINE_ONLY )

Core:AddFunction( "setRoll", "a:n", "a", "Angle(value %1.p, value %1.y, value %2)", LEMON_INLINE_ONLY )

Core:SetPerf( LEMON_PERF_ABNORMAL )

-- Casting:

Core:AddOperator( "string", "a", "s", "tostring(value %1)", LEMON_INLINE_ONLY )

-- Assigment:

Core:AddOperator( "=", "a", "", [[
local %Value = %memory[value %1] or Angle(0, 0, 0)
local %Value2 = value %2
%delta[value %1] = Angle( %Value.p, %Value.y, %Value.r )
%memory[value %1] = Angle( %Value2.p, %Value2.y, %Value2.r )
%click[value %1] = true
]], LEMON_PREPARE_ONLY )

/*==============================================================================================
	Section: General
==============================================================================================*/
Core:AddFunction( "angnorm", "a", "a", "Angle((value %1.p + 180) % 360 - 180,(value %1.y + 180) % 360 - 180,(value %1.r + 180) % 360 - 180)", LEMON_INLINE_ONLY ) 

Core:AddFunction( "shiftL", "a", "a", "Angle(value %1.y, value %1.r, value %1.p)", LEMON_INLINE_ONLY )

Core:AddFunction( "shiftR", "a", "a", "Angle(value %1.r, value %1.p, value %1.y)", LEMON_INLINE_ONLY )

Core:AddFunction( "rotateAroundAxis", "a:v,n", "a", [[
local %Ang = Angle( value %1.p, value %1.y, value %1.r)
%Ang:RotateAroundAxis( value %2:Garry(), n )
]], "%Ang" )

/*==============================================================================================
	Section: Directional
==============================================================================================*/
Core:AddFunction( "forward", "a:", "v", "value %1:Forward( )", LEMON_INLINE_ONLY )

Core:AddFunction( "right", "a:", "v", "value %1:Right( )", LEMON_INLINE_ONLY )

Core:AddFunction( "up", "a:", "v", "value %1:Up( )", LEMON_INLINE_ONLY )

/*==============================================================================================
	Section: Ceil / Floor / Round
==============================================================================================*/
Core:AddFunction( "ceil", "a", "a", "Angle(value %1.p - value %1.p % -1, value %1.y - value %1.y % -1, value %1.r - value %1.r % -1)", LEMON_INLINE_ONLY )

Core:AddFunction( "floor", "a", "a", "Angle(math.floor(value %1.p), math.floor(value %1.y), math.floor(value %1.r))", LEMON_INLINE_ONLY )

Core:AddFunction( "ceil", "a,n", "a", [[
local %A, %B = value %1, value %2
local %Shift = 10 ^ math.floor(%B + 0.5)
]], "Angle(%A.p - ((%A.p * %Shift) % -1) / %Shift, %A.y - ((%A.y * %Shift) % -1) / %Shift, %A.r - ((%A.r * %Shift) % -1) / %Shift)" )

Core:AddFunction( "round", "a", "a", "Angle(value %1.p - (value %1.p + 0.5) % 1 + 0.5, value %1.y - (value %1.y + 0.5) % 1 + 0.5, value %1.r - (value %1.r + 0.5) % 1 + 0.5)" )

Core:AddFunction( "round", "a,n", "a", [[
local %Shift = 10 ^ math.floor(value %2 + 0.5)
]], "Angle(math.floor(value %1.p * %Shift+0.5) / %Shift, math.floor(value %1.y * %Shift+0.5) / %Shift, math.floor(value %1.r * %Shift+0.5) / %Shift)" )

/*==============================================================================================
	Section: Clamping and Inrange
==============================================================================================*/
Core:AddFunction( "clamp", "a,a,a", "a",
"Angle( math.Clamp(value %1.p, value %2.p, value %3.p), math.Clamp(value %1.y, value %2.y, value %3.y), math.Clamp(value %1.r, value %2.r, value %3.r) )", LEMON_INLINE_ONLY )

Core:AddFunction( "inrange", "a,a,a", "b",
"(!(value %1.p < value %2.p or value %1.p > value %3.p or value %1.y < value %2.y or value %1.y > value %3.y or value %1.r < value %2.r or value %1.r > value %3.r))", LEMON_INLINE_ONLY )

/*==============================================================================================
	Section: Interpolation
==============================================================================================*/
Core:AddFunction("mix", "a,a,n", "a", "local %Shift = 1 - value %3",
"Angle(value %1.p * value %3 + value %2.p * %Shift, value %1.y * value %3 + value %2.y * %Shift, value %1.r * value %3 + value %2.r * %Shift)" )

/*==============================================================================================
	Section: World and Local
==============================================================================================*/
Core:AddFunction( "toWorldAng", "v,a,v,a", "a", [[
	local %pos, %ang = $LocalToWorld(value %1:Garry(), value %2, value %3:Garry(), value %4)
]], "%ang" )

Core:AddFunction( "toLocalAng", "v,a,v,a", "a", [[
	local %pos, %ang = $WorldToLocal(value %1:Garry(), value %2, value %3:Garry(), value %4)
]], "%ang" )

/*==============================================================================================
	Section: Entity Helpers
==============================================================================================*/
Core:AddFunction( "toWorld", "e:a", "a", "( $IsValid( value %1 ) and value %1:LocalToWorldAngles( value %2 ) or Angle(0, 0, 0) )", LEMON_INLINE_ONLY )

Core:AddFunction( "toLocal", "e:a", "a", "( $IsValid( value %1 ) and value %1:WorldToLocalAngles( value %2 ) or Angle(0, 0, 0) )", LEMON_INLINE_ONLY )
