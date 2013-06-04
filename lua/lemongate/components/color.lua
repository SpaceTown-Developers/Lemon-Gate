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
local Class = Core:NewClass( "c", "color", { 0, 0, 0, 0 } )

-- Compare:

Core:AddOperator( "&&", "c,c", "b", "local %A, %B = value %1, value %2", "local %A, %B = value %1, value %2", "((%A[1] >= 1 and %A[2] >= 1 and %A[3] >= 1 and %A[4] >= 1) and (%B[1] >= 1 and %B[2] >= 1 and %B[3] >= 1 and %B[4] >= 1))" )

Core:AddOperator( "||", "c,c", "c", "local %A = value %1", "((%A[1] >= 1 and %A[2] >= 1 and %A[3] >= 1 and %A[4] >= 1) and %A or value %2)" )

Core:AddOperator( "==", "c,c", "b", "local %A, %B = value %1, value %2", "(%A[1] - %B[1] <= %Round and %B[1] - %A[1] <= %Round and %A[2] - %B[2] <= %Round and %B[2] - %A[2] <= %Round and%A[3] - %B[3] <= %Round and %B[3] - %A[3] <= %Round and %A[4] - %B[4] <= %Round and %B[4] - %A[4] <= %Round) ")
	   
Core:AddOperator( "!=", "c,c", "b", "local %A, %B = value %1, value %2", "(%A[1] - %B[1] > %Round or %B[1] - %A[1] > %Round or %A[2] - %B[2] > %Round or %B[2] - %A[2] > %Round or %A[3] - %B[3] > %Round or %B[3] - %A[3] > %Round)" )
	   
-- Arithmatic:

Core:AddOperator( "+", "c,c", "c", "local %A, %B = value %1, value %2", "{math.Clamp(%A[1] + %B[1], 0, 255), math.Clamp(%A[2] + %B[2], 0, 255), 0, 255), math.Clamp(%A[3] + %B[3], 0, 255), 0, 255)}" )

Core:AddOperator( "-", "c,c", "c", "local %A, %B = value %1, value %2", "{math.Clamp(%A[1] - %B[1], 0, 255), math.Clamp(%A[2] - %B[2], 0, 255), 0, 255), math.Clamp(%A[3] - %B[3], 0, 255)}" )

Core:AddOperator( "*", "c,c", "c", "local %A, %B = value %1, value %2", "{math.Clamp(%A[1] * %B[1], 0, 255), math.Clamp(%A[2] * %B[2], 0, 255), math.Clamp(%A[3] * %B[3], 0, 255)}" )

Core:AddOperator( "/", "c,c", "c", "local %A, %B = value %1, value %2", "{math.Clamp(%A[1] / %B[1], 0, 255), math.Clamp(%A[2] / %B[2], 0, 255), math.Clamp(%A[3] / %B[3], 0, 255)}" )

Core:AddOperator( "%", "c,c", "c", "local %A, %B = value %1, value %2", "{math.Clamp(%A[1] % %B[1], 0, 255), math.Clamp(%A[2] % %B[2], 0, 255), math.Clamp(%A[3] % %B[3], 0, 255)}" )

Core:AddOperator( "^", "c,c", "c", "local %A, %B = value %1, value %2", "{math.Clamp(%A[1] ^ %B[1], 0, 255), math.Clamp(%A[2] ^ %B[2], 0, 255), math.Clamp(%A[3] ^ %B[3], 0, 255)}" )

-- Mumberic Arithmatic:

Core:AddOperator( "+", "c,n", "c", "local %A, %B = value %1, value %2", "{math.Clamp(%A[1] + %B, 0, 255), math.Clamp(%A[2] + %B, 0, 255), math.Clamp(%A[3] + %B, 0, 255)}" )

Core:AddOperator( "-", "c,n", "c", "local %A, %B = value %1, value %2", "{math.Clamp(%A[1] - %B, 0, 255), math.Clamp(%A[2] - %B, 0, 255), math.Clamp(%A[3] - %B, 0, 255)}" )

Core:AddOperator( "*", "c,n", "c", "local %A, %B = value %1, value %2", "{math.Clamp(%A[1] * %B, 0, 255), math.Clamp(%A[2] * %B, 0, 255), math.Clamp(%A[3] * %B, 0, 255)}" )

Core:AddOperator( "/", "c,n", "c", "local %A, %B = value %1, value %2", "{math.Clamp(%A[1] / %B, 0, 255), math.Clamp(%A[2] / %B, 0, 255), math.Clamp(%A[3] / %B, 0, 255)}" )

Core:AddOperator( "%", "c,n", "c", "local %A, %B = value %1, value %2", "{math.Clamp(%A[1] % %B, 0, 255), math.Clamp(%A[2] % %B, 0, 255), math.Clamp(%A[3] % %B, 0, 255)}" )

Core:AddOperator( "^", "c,n", "c", "local %A, %B = value %1, value %2", "{math.Clamp(%A[1] ^ %B, 0, 255), math.Clamp(%A[2] ^ %B, 0, 255), math.Clamp(%A[3] ^ %B, 0, 255)}" )

-- General:

Core:AddOperator( "is", "c", "b", "local %A = value %1", "(%A[1] >= 1 and %A[2] >= 1 and %A[3] >= 1 and %A[4] >= 1)" )

Core:AddOperator( "not", "c", "b", "local %A = value %1", "(%A[1] < 1 and %A[2] < 1 and %A[3] < 1 and %A[4] < 1)" )

Core:AddOperator( "$", "c", "c", "local %V, %D = %memory[value %1], %delta[value %1] or {0, 0, 0, 0}", "{ math.Clamp(%D[1] - %V[1], 0, 255), math.Clamp(%D[2] - %V[2], 0, 255), math.Clamp(%D[3] - %V[3], 0, 255), math.Clamp(%D[4] - %V[4], 0, 255)}" )

-- Constructors:

Core:AddFunction("color", "n,n,n,[n]", "c", "{ value %1, value %2, value %3, value %4 or 255 }", nil, "Creates a angle" )

-- Co-ords:

Core:AddFunction("red", "c:", "n", "value %1[1]", nil, "Gets the red of a angle" )

Core:AddFunction("green", "c:", "n", "value %1[2]", nil, "Gets the green of a angle" )

Core:AddFunction("blue", "c:", "n", "value %1[3]", nil, "Gets the blue of a angle" )

Core:AddFunction("alpha", "c:", "n", "value %1[4]", nil, "Gets the alpha of a angle" )


Core:AddFunction("setRed", "c:n", "c", "local %A = value %1", "{ math.Clamp(value %2, 0, 255), %A[2], %A[3], %A[4] }", "Sets the red of a angle" )

Core:AddFunction("setGreen", "c:n", "c", "local %A = value %1", "{ %A[1], math.Clamp(value %2, 0, 255), %A[3], %A[4] }", "Sets the green of a angle" )

Core:AddFunction("setBlue", "c:n", "c", "local %A = value %1", "{ %A[1], %A[2], math.Clamp(value %2, 0, 255), %A[4] }", "Sets the blue of a angle" )

Core:AddFunction("setAlpha", "c:n", "c", "local %A = value %1", "{ %A[1], %A[2], %A[3], math.Clamp(value %2, 0, 255) }", "Sets the alpha of a angle" )

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

Core:AddFunction( "hsv2rgb", "c:", "c", [[
local %V = value %1
local %C = %HSVToColor(%V[1], %V[2], %V[3])
]], "{ %C.r, %C.g, %C.b, 255 }" )

Core:AddFunction( "hsv2rgb", "n,n,n", "c", "local %C = %HSVToColor(%value 1, %value 2, %value 3)", "{ %C.r, %C.g, %C.b }" )

Core:AddFunction( "rgb2hsv", "c:", "c", [[
local %V = value %1"
local %R, %G, %B = %ColorToHSV( %Color(%V[1], %V[2], %V[3])
]], "{%R, %G, %B, 255}" )

Core:AddFunction( "rgb2hsv", "n,n,n", "c", "local %C = %ColorToHSV( %Color(%value 1, %value 2, %value 3) )", "{ %C.r, %C.g, %C.b, 255 }" )