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
	return Context.Memory[ Cell ] or Angle(0, 0, 0)
end

function Class.Wire_In( Context, Cell, Value )
	Context.Memory[ Cell ] = Value
end

-- Compare:

Core:AddOperator( "&&", "a,a", "b", "local %A, %B = value %1, value %2", "((%A.p >= 1 and %A.y >= 1 and %A.r >= 1) and (%B.p >= 1 and %B.y >= 1 and %B.r >= 1))" )

-- Core:AddOperator( "||", "a,a", "a", "local %A = value %1", "((%A[1] >= 1 and %A[2] >= 1 and %A[3] >= 1) and %A or value %2)" )

Core:AddOperator( "==", "a,a", "b", "(value %1 == value %2)" )

Core:AddOperator( "!=", "a,a", "b", "(value %1 != value %2)" )
	   
-- Arithmatic:

Core:AddOperator( "+", "a,a", "a", "(value %1 + value %2)" )

Core:AddOperator( "-", "a,a", "a", "(value %1 - value %2)" )

Core:AddOperator( "*", "a,a", "a", "(value %1 * value %2)" )

Core:AddOperator( "/", "a,a", "a", "(value %1 / value %2)" )

Core:AddOperator( "%", "a,a", "a", "(value %1 % value %2)" )

Core:AddOperator( "^", "a,a", "a", "(value %1 ^ value %2)" )

-- Mumberic Arithmatic:

Core:AddOperator( "+", "a,n", "a", "local %Value = value %2", "(value %1 + Angle(%Value, %Value, %Value))" )

Core:AddOperator( "-", "a,n", "a", "local %Value = value %2", "(value %1 - Angle(%Value, %Value, %Value))" )

Core:AddOperator( "*", "a,n", "a", "local %Value = value %2", "(value %1 * Angle(%Value, %Value, %Value))" )

Core:AddOperator( "/", "a,n", "a", "local %Value = value %2", "(value %1 / Angle(%Value, %Value, %Value))" )

Core:AddOperator( "%", "a,n", "a", "local %Value = value %2", "(value %1 % Angle(%Value, %Value, %Value))" )

Core:AddOperator( "^", "a,n", "a", "local %Value = value %2", "(value %1 ^ Angle(%Value, %Value, %Value))" )


-- General:
Core:AddOperator( "is", "a", "b", "local %A = value %1", "(%A.p >= 1 and %A.y >= 1 and %A.r >= 1)" )

Core:AddOperator( "not", "a", "b", "local %A = value %1", "(%A.p < 1 and %A.y < 1 and %A.r < 1)" )

Core:AddOperator( "-", "a", "a", "(-value %1)" )

Core:AddOperator( "$", "a", "a", "((%delta[value %1] or Angle(0, 0, 0)) - (%memory[value %1]or Angle(0, 0, 0)))" )

-- Constructors:

Core:AddFunction("ang", "n,n,n", "a", "Angle(value %1, value %2, value %3)", nil, "Creates a angle" )

-- Co-ords:

Core:AddFunction("p", "a:", "n", "value %1.p", nil, "Gets the pitch of a angle" )

Core:AddFunction("y", "a:", "n", "value %1.y", nil, "Gets the yaw of a angle" )

Core:AddFunction("r", "a:", "n", "value %1.r", nil, "Gets the roll of a angle" )


Core:AddFunction("setPitch", "a:n", "a", "Angle(value %2, value %1.y, value %1.r)", nil, "Sets the pitch of a angle" )

Core:AddFunction("setYaw", "a:n", "a", "Angle(value %1.x, value %2, value %1.r)", nil, "Sets the yaw of a angle" )

Core:AddFunction("setRoll", "a:n", "a", "Angle(value %1.x, value %1.y, value %2)", nil, "Sets the roll of a angle" )

Core:SetPerf( LEMON_PERF_ABNORMAL )

-- Casting:

Core:AddOperator( "string", "a", "s", "tostring(value %1)" )

-- Assigment:

Core:AddOperator( "=", "a", "", [[
local %Value = %memory[value %1] or Angle(0, 0, 0)
local %Value2 = value %1
%delta[value %1] = Angle( %Value.p, %Value.y, %Value.r )
%memory[value %1] = Angle( %Value2.p, %Value2.y, %Value2.r )
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
Core:AddFunction("forward", "a:", "a", "value %1:Forward( )" )

Core:AddFunction("right", "a:", "a", "value %1:Right( )" )

Core:AddFunction("up", "a:", "a", "value %1:Up( )" )

/*==============================================================================================
	Ceil / Floor / Round
==============================================================================================*/
Core:AddFunction("ceil", "v", "v", "local %V = value %1", "Angle(%V.p - %V.p % -1, %V.y - %V.y % -1, %V.r - %V.r % -1)" )

Core:AddFunction("floor", "v", "v", "local %V = value %1", "Angle(math.floor(%V.p), math.floor(%V.y), math.floor(%V.r))" )

Core:AddFunction("ceil", "v,n", "v", [[
local %A, %B = value %1, value %2
local %Shift = 10 ^ math.floor(%B + 0.5)
]], "Angle(%A.p - ((%A.p * %Shift) % -1) / %Shift, %A.y - ((%A.y * %Shift) % -1) / %Shift, %A.r - ((%A.r * %Shift) % -1) / %Shift)" )

Core:AddFunction("round", "v", "v", "local %V = value %1",
"Angle(V.p - (V.p + 0.5) % 1 + 0.5, %V.y - (%V.y + 0.5) % 1 + 0.5, %V.r - (%V.r + 0.5) % 1 + 0.5)" )

Core:AddFunction("round", "v,n", "v", [[
local %A, %B = value %1, value %2
local %Shift = 10 ^ math.floor(%B + 0.5)
]], "Angle(math.floor(%A.p * %Shift+0.5) / %Shift, math.floor(%A.y * %Shift+0.5) / %Shift, math.floor(%A.r * %Shift+0.5) / %Shift)" )

/*==============================================================================================
	math.Clamping and Inrange
==============================================================================================*/
Core:AddFunction("math.Clamp", "a,a,a", "a", "local %A, %B, %C = value %1, value %2, value %3",
"Angle( math.Clamp(%A.p, %B.p, %C.p), math.Clamp(%A.y, %B.y, %C.y), math.Clamp(%A.r, %B.r, %C.r) )" )

Core:AddFunction("inrange", "a,a,a", "b", "local %A, %B, %C = value %1, value %2, value %3",
"(!(%A.p < %B.p or %A.p > %C.p or %A.y < %B.y or %A.y > %C.y or %A.r < %B.r or %A.r > %C.r))" )

/*==============================================================================================
	Entity Helpers
==============================================================================================*/
Core:AddFunction("toWorld", "e:a", "a", "( $IsValid( value %1 ) and value %1:LocalToWorldAngles( value %2 ) or Angle(0, 0, 0) )" )

Core:AddFunction("toLocal", "e:a", "a", "( $IsValid( value %1 ) and value %1:WorldToLocalAngles( value %2 ) or Angle(0, 0, 0) )" )