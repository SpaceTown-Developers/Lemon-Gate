/*==============================================================================================
	Expression Advanced: Component -> Core.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" )

/*==============================================================================================
	Section: Externals
==============================================================================================*/

Core:AddExternal( "HSVToColor", HSVToColor )
Core:AddExternal( "ColorToHSV", ColorToHSV )
Core:AddExternal( "Color", Color )

/*==============================================================================================
	Class and Operators
==============================================================================================*/
local Class = Core:NewClass( "c", "color", { 255, 255, 255, 255 } )

-- Assign:

Core:AddOperator( "=", "c", "", [[
local %A, %B = value %2, %memory[value %1] or {255, 255, 255, 255 }
%delta[value %1] = %B
%memory[value %1] = %A
%click[value %1] = (%A[1] == %B[1] and %A[2] == %B[2] and %A[3] == %B[3] and %B[4] == %A[4])
]], "" )

Core:AddOperator( "~", "c", "b", "%click[value %1]" )

-- Compare:

Core:AddOperator( "&&", "c,c", "b", "local value %1, value %2 = value %1, value %2", "((value %1[1] >= 1 and value %1[2] >= 1 and value %1[3] >= 1 and value %1[4] >= 1) and (value %2[1] >= 1 and value %2[2] >= 1 and value %2[3] >= 1 and value %2[4] >= 1))" )

Core:AddOperator( "||", "c,c", "c", "((value %1[1] >= 1 and value %1[2] >= 1 and value %1[3] >= 1 and value %1[4] >= 1) and value %1 or value %2)" )

Core:AddOperator( "==", "c,c", "b", "(value %1[1] == value %2[1] and value %1[2] == value %2[2] and value %1[3] == value %2[3] and value %2[4] == value %1[4]) ")
	   
Core:AddOperator( "!=", "c,c", "b", "(value %1[1] - value %2[1] > %Round or value %2[1] - value %1[1] > %Round or value %1[2] - value %2[2] > %Round or value %2[2] - value %1[2] > %Round or value %1[3] - value %2[3] > %Round or value %2[3] - value %1[3] > %Round)" )
	   
-- Arithmatic:

Core:AddOperator( "+", "c,c", "c", "{math.Clamp(value %1[1] + value %2[1], 0, 255), math.Clamp(value %1[2] + value %2[2], 0, 255), 0, 255), math.Clamp(value %1[3] + value %2[3], 0, 255), 0, 255)}" )

Core:AddOperator( "-", "c,c", "c", "{math.Clamp(value %1[1] - value %2[1], 0, 255), math.Clamp(value %1[2] - value %2[2], 0, 255), 0, 255), math.Clamp(value %1[3] - value %2[3], 0, 255)}" )

Core:AddOperator( "*", "c,c", "c", "{math.Clamp(value %1[1] * value %2[1], 0, 255), math.Clamp(value %1[2] * value %2[2], 0, 255), math.Clamp(value %1[3] * value %2[3], 0, 255)}" )

Core:AddOperator( "/", "c,c", "c", "{math.Clamp(value %1[1] / value %2[1], 0, 255), math.Clamp(value %1[2] / value %2[2], 0, 255), math.Clamp(value %1[3] / value %2[3], 0, 255)}" )

Core:AddOperator( "%", "c,c", "c", "{math.Clamp(value %1[1] modulus value %2[1], 0, 255), math.Clamp(value %1[2] modulus value %2[2], 0, 255), math.Clamp(value %1[3] modulus value %2[3], 0, 255)}" )

Core:AddOperator( "^", "c,c", "c", "{math.Clamp(value %1[1] ^ value %2[1], 0, 255), math.Clamp(value %1[2] ^ value %2[2], 0, 255), math.Clamp(value %1[3] ^ value %2[3], 0, 255)}" )

-- Mumberic Arithmatic:

Core:AddOperator( "+", "c,n", "c", "{math.Clamp(value %1[1] + value %2, 0, 255), math.Clamp(value %1[2] + value %2, 0, 255), math.Clamp(value %1[3] + value %2, 0, 255)}" )

Core:AddOperator( "-", "c,n", "c", "{math.Clamp(value %1[1] - value %2, 0, 255), math.Clamp(value %1[2] - value %2, 0, 255), math.Clamp(value %1[3] - value %2, 0, 255)}" )

Core:AddOperator( "*", "c,n", "c", "{math.Clamp(value %1[1] * value %2, 0, 255), math.Clamp(value %1[2] * value %2, 0, 255), math.Clamp(value %1[3] * value %2, 0, 255)}" )

Core:AddOperator( "/", "c,n", "c",  "{math.Clamp(value %1[1] / value %2, 0, 255), math.Clamp(value %1[2] / value %2, 0, 255), math.Clamp(value %1[3] / value %2, 0, 255)}" )

Core:AddOperator( "%", "c,n", "c", "{math.Clamp(value %1[1] modulus value %2, 0, 255), math.Clamp(value %1[2] modulus value %2, 0, 255), math.Clamp(value %1[3] modulus value %2, 0, 255)}" )

Core:AddOperator( "^", "c,n", "c",  "{math.Clamp(value %1[1] ^ value %2, 0, 255), math.Clamp(value %1[2] ^ value %2, 0, 255), math.Clamp(value %1[3] ^ value %2, 0, 255)}" )

-- General:

Core:AddOperator( "is", "c", "b", "(value %1[1] >= 1 and value %1[2] >= 1 and value %1[3] >= 1 and value %1[4] >= 1)" )

Core:AddOperator( "not", "c", "b", "(value %1[1] < 1 and value %1[2] < 1 and value %1[3] < 1 and value %1[4] < 1)" )

Core:AddOperator( "$", "c", "c", "local %V, %D = %memory[value %1], %delta[value %1] or {0, 0, 0, 0}", "{ math.Clamp(%D[1] - %V[1], 0, 255), math.Clamp(%D[2] - %V[2], 0, 255), math.Clamp(%D[3] - %V[3], 0, 255), math.Clamp(%D[4] - %V[4], 0, 255)}" )

-- Constructors:

Core:AddFunction("color", "n,n,n[,n]", "c", "{ value %1, value %2, value %3, value %4 or 255 }", nil )

-- Co-ords:

Core:AddFunction("red", "c:", "n", "value %1[1]", nil )

Core:AddFunction("green", "c:", "n", "value %1[2]", nil )

Core:AddFunction("blue", "c:", "n", "value %1[3]", nil )

Core:AddFunction("alpha", "c:", "n", "value %1[4]", nil )


Core:AddFunction("setRed", "c:n", "c", "{ math.Clamp(value %2, 0, 255), value %1[2], value %1[3], value %1[4] }", nil )

Core:AddFunction("setGreen", "c:n", "c", "{ value %1[1], math.Clamp(value %2, 0, 255), value %1[3], value %1[4] }", nil )

Core:AddFunction("setBlue", "c:n", "c",  "{ value %1[1], value %1[2], math.Clamp(value %2, 0, 255), value %1[4] }", nil )

Core:AddFunction("setAlpha", "c:n", "c", "{ value %1[1], value %1[2], value %1[3], math.Clamp(value %2, 0, 255) }", nil )

Core:SetPerf( LEMON_PERF_ABNORMAL )

-- Casting:

Core:AddOperator( "string", "c", "s", "\"<\" .. string.Implode( \",\", value %1 ) .. \">\"" )

Core:AddFunction("toString", "c:", "s", "\"<\" .. string.Implode( \",\", value %1 ) .. \">\"" )

-- Assigment:

Core:AddOperator( "=", "c", "", [[
%delta[value %1] = %memory[value %1]
%memory[value %1] = value %2
%click[value %1] = true
]], "" )

/*==============================================================================================
	General Functions
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "hsv2rgb", "c:", "c", "local %C = %HSVToColor(value %1[1], value %1[2], value %1[3])", "{ %C.r, %C.g, %C.b, 255 }" )

Core:AddFunction( "hsv2rgb", "n,n,n", "c", "local %C = %HSVToColor(value %1, value %2, value %3)", "{ %C.r, %C.g, %C.b }" )

Core:AddFunction( "rgb2hsv", "c:", "c", "local %R, %G, %B = %ColorToHSV( %Color(value %1[1], value %1[2], value %1[3])", "{%R, %G, %B, 255}" )

Core:AddFunction( "rgb2hsv", "n,n,n", "c", "local %C = %ColorToHSV( %Color(value %1, value %2, value %3) )", "{ %C.r, %C.g, %C.b, 255 }" )

Core:AddFunction( "rgb2dgi", "c:", "n", "math.Clamp( math.floor( math.Clamp( math.floor( value %1[1] / 28), 0, 9 ) ) * 100 + math.floor( math.Clamp( math.floor( value %1[2] / 28), 0, 9 ) ) * 10 + math.floor( math.Clamp( math.floor( value %1[3] / 28), 0, 9 ) ), 0, 999 )" )

Core:AddFunction( "rgb2dgi", "n,n,n", "n", "math.Clamp( math.floor( math.Clamp( math.floor( value %1 / 28), 0, 9 ) ) * 100 + math.floor( math.Clamp( math.floor( value %2 / 28), 0, 9 ) ) * 10 + math.floor( math.Clamp( math.floor( value %3 / 28), 0, 9 ) ), 0, 999 )" )

/*==============================================================================================
	Section: Constants
==============================================================================================*/
Core:AddConstant( "COLOR_WHITE", "c", "{255,255,255,255}" )

Core:AddConstant( "COLOR_BLACK", "c", "{0,0,0,255}" )

Core:AddConstant( "COLOR_RED", "c", "{255,0,0,255}" )

Core:AddConstant( "COLOR_GREEN", "c", "{0,255,0,255}" )

Core:AddConstant( "COLOR_BLUE", "c", "{0,0,255,255}" )

Core:AddConstant( "COLOR_YELLOW", "c", "{0,255,255,255}" )