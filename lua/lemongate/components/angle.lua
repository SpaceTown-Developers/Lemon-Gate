/*==============================================================================================
	Expression Advanced: Component -> Core.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" ) 

/*==============================================================================================
	Section: Angle Class
==============================================================================================*/
local Class = Core:NewClass( "a", "angle", "Angle(0, 0, 0)", true )

Class:UsesMetaTable( FindMetaTable( "Angle" ) )

-- WireMod

Class:Wire_Name( "ANGLE" )

function Class.Wire_Out( Context, Cell )
	return Context.Memory[ Cell ] or Angle(0, 0, 0)
end

function Class.Wire_In( Context, Cell, Value )
	Context.Memory[ Cell ] = Value
end

Core:SetPerf( LEMON_PERF_CHEAP )

-- Assign:

Core:AddOperator( "=", "a", "a", [[
local %Current = %memory[value %1] or Angle(0, 0, 0)
%memory[value %1] = Angle( value %2.p, value %2.y, value %2.r )
%delta[ value %1] = %Current
if !%trigger[value %1] then 
	%trigger[value %1] = %Current.p ~= value %2.p or %Current.y ~= value %2.y or %Current.r ~= value %2.r
end
]], "value %2" )

-- Changed:

Core:AddOperator( "~", "a", "b", [[
local %Memory = %memory[value %1]
local %Changed = (%click[value %1] == nil) or (%click[value %1] ~= %Memory)
%click[value %1] = %Memory 
]], "%Changed" )

//Core:AddOperator( "~", "a", "b", "%click[value %1]" )

-- Compare:

Core:AddOperator( "&&", "a,a", "b", "((value %1.p >= 1 and value %1.y >= 1 and value %1.r >= 1) and (value %2.p >= 1 and value %2.y >= 1 and value %2.r >= 1))" )

Core:AddOperator( "==", "a,a", "b", "(value %1 == value %2)" )

Core:AddOperator( "!=", "a,a", "b", "(value %1 != value %2)" )
	   
-- Arithmatic:

Core:AddOperator( "+", "a,a", "a", "(value %1 + value %2)", LEMON_INLINE_ONLY )

Core:AddOperator( "-", "a,a", "a", "(value %1 - value %2)", LEMON_INLINE_ONLY )

Core:AddOperator( "*", "a,a", "a", "Angle(value %1.p * value %2.p, value %1.y * value %2.y, value %1.r * value %2.r)", LEMON_INLINE_ONLY )

Core:AddOperator( "/", "a,a", "a", "Angle(value %1.p / value %2.p, value %1.y / value %2.y, value %1.r / value %2.r)", LEMON_INLINE_ONLY )

Core:AddOperator( "%", "a,a", "a", "Angle(value %1.p modulus value %2.p, value %1.y modulus value %2.y, value %1.r modulus value %2.r)", LEMON_INLINE_ONLY )

Core:AddOperator( "^", "a,a", "a", "Angle(value %1.p ^ value %2.p, value %1.y ^ value %2.y, value %1.r ^ value %2.r)", LEMON_INLINE_ONLY )

-- Mumberic Arithmatic:

Core:AddOperator( "+", "a,n", "a", "(value %1 + Angle(value %2, value %2, value %2))", LEMON_INLINE_ONLY )

Core:AddOperator( "-", "a,n", "a", "(value %1 - Angle(value %2, value %2, value %2))", LEMON_INLINE_ONLY )

Core:AddOperator( "*", "a,n", "a", "Angle(value %1.p * value %2, value %1.y * value %2, value %1.r * value %2)", LEMON_INLINE_ONLY )

Core:AddOperator( "/", "a,n", "a", "Angle(value %1.p / value %2, value %1.y / value %2, value %1.r / value %2)", LEMON_INLINE_ONLY )

Core:AddOperator( "%", "a,n", "a", "Angle(value %1.p modulus value %2, value %1.y modulus value %2, value %1.r modulus value %2)", LEMON_INLINE_ONLY )

Core:AddOperator( "^", "a,n", "a", "Angle(value %1.p ^ value %2, value %1.y ^ value %2, value %1.r ^ value %2)", LEMON_INLINE_ONLY )


-- General:
Core:AddOperator( "is", "a", "b", "(value %1.p >= 1 and value %1.y >= 1 and value %1.r >= 1)" )

Core:AddOperator( "not", "a", "b", "(value %1.p < 1 and value %1.y < 1 and value %1.r < 1)" )

Core:AddOperator( "-", "a", "a", "(-value %1)" )

Core:AddOperator( "$", "a", "a", "((%memory[value %1]or Angle(0, 0, 0)) - (%delta[value %1] or Angle(0, 0, 0)))" )

-- Constructors:

Core:AddFunction( "ang", "n,n,n", "a", "Angle(value %1, value %2, value %3)", LEMON_INLINE_ONLY )

Core:AddFunction( "ang", "n", "a", "Angle(value %1, value %1, value %1)", LEMON_INLINE_ONLY )

Core:AddFunction( "ang", "", "a", "Angle(0, 0, 0)", LEMON_INLINE_ONLY )

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

/*==============================================================================================
	Section: General
==============================================================================================*/
Core:AddFunction( "angnorm", "a", "a", "Angle((value %1.p + 180) modulus 360 - 180,(value %1.y + 180) modulus 360 - 180,(value %1.r + 180) modulus 360 - 180)", LEMON_INLINE_ONLY ) 

Core:AddFunction( "shiftL", "a", "a", "Angle(value %1.y, value %1.r, value %1.p)", LEMON_INLINE_ONLY )

Core:AddFunction( "shiftR", "a", "a", "Angle(value %1.r, value %1.p, value %1.y)", LEMON_INLINE_ONLY )

Core:AddFunction( "rotateAroundAxis", "a:v,n", "a", [[
local %Ang = Angle( value %1.p, value %1.y, value %1.r )
%Ang:RotateAroundAxis( value %2:Garry(), value %3 )
]], "%Ang" )

/*==============================================================================================
	Section: Directional
==============================================================================================*/
Core:AddFunction( "forward", "a:", "v", "Vector3( value %1:Forward( ) )", LEMON_INLINE_ONLY )

Core:AddFunction( "right", "a:", "v", "Vector3( value %1:Right( ) )", LEMON_INLINE_ONLY )

Core:AddFunction( "up", "a:", "v", "Vector3( value %1:Up( ) )", LEMON_INLINE_ONLY )

/*==============================================================================================
	Section: Ceil / Floor / Round
==============================================================================================*/
Core:AddFunction( "ceil", "a", "a", "Angle(value %1.p - value %1.p modulus -1, value %1.y - value %1.y modulus -1, value %1.r - value %1.r modulus -1)", LEMON_INLINE_ONLY )

Core:AddFunction( "floor", "a", "a", "Angle(math.floor(value %1.p), math.floor(value %1.y), math.floor(value %1.r))", LEMON_INLINE_ONLY )

Core:AddFunction( "ceil", "a,n", "a", [[
local %A, %B = value %1, value %2
local %Shift = 10 ^ math.floor(%B + 0.5)
]], "Angle(%A.p - ((%A.p * %Shift) modulus -1) / %Shift, %A.y - ((%A.y * %Shift) modulus -1) / %Shift, %A.r - ((%A.r * %Shift) modulus -1) / %Shift)" )

Core:AddFunction( "round", "a", "a", "Angle( math.Round( value %1.p ), math.Round( value %1.y ), math.Round( value %1.r ) )" )

Core:AddFunction( "round", "a,n", "a", "Angle( math.Round( value %1.p, value %2 ), math.Round( value %1.y, value %2 ), math.Round( value %1.r, value %2 ) )" )

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
