/*==============================================================================================
	Expression Advanced: Component -> Number.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" )

-- Core:AddException( "number" )


/*==============================================================================================
	Section: Class
==============================================================================================*/
local Number = Core:NewClass( "n", "number", 0 )

Number:Wire_Name( "NORMAL" )

function Number.Wire_Out( Context, Cell )
	return Context.Memory[ Cell ] or 0
end

function Number.Wire_In( Context, Cell, Value )
	Context.Memory[ Cell ] = Value
end


/*==============================================================================================
	Section: Operators
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

-- Assign:

Core:AddOperator( "=", "n", "", [[
%delta[value %1] = %memory[value %1]
%memory[value %1] = value %2
%click[value %1] = ( %click[value %1] or ( %memory[value %1] ~= %delta[value %1] ) )
]], "" )

Core:AddOperator( "~", "n", "b", "%click[value %1]" )

Core:SetPerf( LEMON_PERF_NORMAL )

-- Compare:

Core:AddOperator( "==", "n,n", "b", "(value %1 == value %2)" )

Core:AddOperator( "!=", "n,n", "b", "(value %1 != value %2)" )

Core:AddOperator( ">", "n,n", "b", "(value %1 > value %2)" )

Core:AddOperator( "<", "n,n", "b", "(value %1 < value %2)" )

Core:AddOperator( ">=", "n,n", "b", "(value %1 >= value %2)" )

Core:AddOperator( "<=", "n,n", "b", "(value %1 <= value %2)" )

Core:SetPerf( LEMON_PERF_CHEAP )

-- Arithmatic:

Core:AddOperator( "+", "n,n", "n", "(value %1 + value %2)" )

Core:AddOperator( "-", "n,n", "n", "(value %1 - value %2)" )

Core:AddOperator( "*", "n,n", "n", "(value %1 * value %2)" )

Core:AddOperator( "/", "n,n", "n", "(value %1 / value %2)" )

Core:AddOperator( "%", "n,n", "n", "(value %1 modulus value %2)" )

Core:AddOperator( "^", "n,n", "n", "(value %1 ^ value %2)" )

-- General:

Core:AddOperator( "is", "n", "b", "(value %1 >= 1)" )

Core:AddOperator( "not", "n", "b", "(value %1 < 1)" )

Core:AddOperator( "-", "n", "n", "(-value %1)" )

Core:AddOperator( "$", "n", "n", "((%memory[value %1] or 0) - (%delta[value %1] or 0))" )

Core:SetPerf( LEMON_PERF_NORMAL )

-- Casting:

Core:AddOperator( "boolean", "n", "b", "(value %1 > 1)" )

Core:AddOperator( "string", "n", "s", "$tostring(value %1)" )

Core:AddOperator( "number", "s", "n", "($tonumber(value %1) or 0)" )


/*==============================================================================================
	Section: Assigment Operators
==============================================================================================*/
Core:SetPerf( LEMON_PERF_ABNORMAL )

-- Assign Before
Core:AddOperator( "i++", "n", "n", [[
local %Value = %memory[value %1]
%delta[value %1] = %Value
%memory[value %1] = %Value + 1
%click[value %1] = true
]], "%Value" )

Core:AddOperator( "i--", "n", "n", [[
local %Value = %memory[value %1]
%delta[value %1] = %Value
%memory[value %1] = %Value - 1
%click[value %1] = true
]], "%Value" )

-- Assign After
Core:AddOperator( "++i", "n", "n", [[
local %Value = %memory[value %1]
%delta[value %1] = %Value
%memory[value %1] = %Value + 1
%click[value %1] = true
]], "(%Value + 1)" )

Core:AddOperator( "--i", "n", "n", [[
local %Value = %memory[value %1]
%delta[value %1] = %Value
%memory[value %1] = %Value - 1
%click[value %1] = true
]], "(%Value - 1)" )

/*==============================================================================================
	Section: Min Max Functions
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "min", "n,n", "n", "math.min(value %1,value %2)" )
Core:AddFunction( "min", "n,n,n,", "n", "math.min(value %1,value %2,value %3)" )
Core:AddFunction( "min", "n,n,n,n", "n", "math.min(value %1,value %2,value %3,value %4)" )
Core:AddFunction( "min", "n,n,n,n,n", "n", "math.min(value %1,value %2,value %3,value %4,value %5)" )

Core:AddFunction( "max", "n,n", "n", "math.max(value %1,value %2)" )
Core:AddFunction( "max", "n,n,n,", "n", "math.max(value %1,value %2,value %3)" )
Core:AddFunction( "max", "n,n,n,n", "n", "math.max(value %1,value %2,value %3,value %4)" )
Core:AddFunction( "max", "n,n,n,n,n", "n", "math.max(value %1,value %2,value %3,value %4,value %5)" )

/*==============================================================================================
	Section: General Math
==============================================================================================*/
Core:AddFunction( "floor", "n", "n", "math.floor(value %1)" )

Core:AddFunction( "abs", "n", "n", "((value %1 >= 0) and value %1 or -value %1)" )

Core:AddFunction( "ceil", "n", "n", "(value %1 - value %1 modulus -1)" )

Core:AddFunction( "ceil", "n,n", "n", "local %B = 10 ^ math.floor(value %2 + 0.5)", "(value %1 - ((value %1 * %B) modulus -1) / %B)" )

Core:AddFunction( "round", "n", "n", "(value %1 - (value %1 + 0.5) modulus 1 + 0.5)" )

Core:AddFunction( "round", "n,n", "n", "local %A = 10 ^ math.floor(value %2 + 0.5)", "(math.floor(value %1 * %A + 0.5) / %A)" )

Core:AddFunction( "int", "n", "n", "((value %1 >= 0) and value %1 - value %1 modulus 1 or value %1 - value %1 modulus -1)" )

Core:AddFunction( "frac", "n", "n", "(value %1 >= 0 and value %1 modulus 1 or value %1 modulus -1)" )

Core:AddFunction( "clamp", "n,n,n", "n", "math.Clamp( value %1, value %2, value %3 )" )

Core:AddFunction( "inrange", "n,n,n", "n", "((value %1 < value %2 or value %1 > value %3) and 0 or 1)" )

Core:AddFunction( "sign", "n", "n", "(value %1 > %Round and 1 or (value %1 < -%Round and -1 or 0))" )


/*==============================================================================================
	Section: Random Numbers
==============================================================================================*/
Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddFunction( "random", "", "n", "math.random( )" )
Core:AddFunction( "random", "n", "n", "(math.random( ) * value %1)" )
Core:AddFunction( "random", "n,n", "n", "(value %1 + math.random( ) * (value %2 - value %1))" )

Core:AddFunction( "random", "n", "n", "math.random( value %1 )" )
Core:AddFunction( "random", "n,n", "n", "math.random( math.min( value %1, value %2 ), math.max( value %1, value %2 ) )" )


/*==============================================================================================
	Section: Advanced Math
==============================================================================================*/

Core:AddFunction( "sqrt", "n", "n", "(value %1 ^ (1 / 2))" )

Core:AddFunction( "cbrt", "n", "n", "(value %1 ^ (1 / 3))" )

Core:AddFunction( "root", "n,n", "n", "(value %1 ^ (1 / value %2))" )

Core:AddFunction( "exp", "n", "n", "(math.exp(value %1))" )


/*==============================================================================================
	Section: Trig
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )
Core:AddFunction( "pi", "", "n", "math.pi" )

Core:AddExternal( "deg2rad", math.pi / 180 )
Core:AddExternal( "rad2deg", 180 / math.pi )

Core:SetPerf( LEMON_PERF_NORMAL )
Core:AddFunction( "toRad", "n", "n", "(value %1 * %deg2rad)" )
Core:AddFunction( "toDeg", "n", "n", "(value %1 * %rad2deg)" )

Core:SetPerf( LEMON_PERF_ABNORMAL ) -- Arent these a little expensive?

Core:AddFunction( "acos", "n", "n", "(math.acos(value %1) * %rad2deg)" )
Core:AddFunction( "asin", "n", "n", "(math.asin(value %1) * %rad2deg)" )
Core:AddFunction( "atan", "n", "n", "(math.atan(value %1) * %rad2deg)" )
Core:AddFunction( "atan", "n,n", "n", "(math.atan(value %1, value %2) * %rad2deg)" )

Core:AddFunction( "cos", "n", "n", "math.cos(value %1 * %deg2rad)" )
Core:AddFunction( "sec", "n", "n", "(1 / math.cos(value %1 * %deg2rad))" )

Core:AddFunction( "sin", "n", "n", "math.sin(value %1 * %deg2rad)" )
Core:AddFunction( "csc", "n", "n", "(1 / math.sin(value %1 * %deg2rad))" )

Core:AddFunction( "tan", "n", "n", "math.tan(value %1 * %deg2rad)" )
Core:AddFunction( "cot", "n", "n", "(1 / math.tan(value %1 * %deg2rad))" )

Core:AddFunction( "cosh", "n", "n", "math.cosh(value %1)" )
Core:AddFunction( "sech", "n", "n", "(1 / math.cosh(value %1))" )

Core:AddFunction( "sinh", "n", "n", "math.sinh(value %1)" )
Core:AddFunction( "csch", "n", "n", "(1 / math.sinh(value %1))" )

Core:AddFunction( "tanh", "n", "n", "math.tanh(value %1)" )
Core:AddFunction( "coth", "n", "n", "(1 / math.tanh(value %1))" )

Core:AddFunction( "acosr", "n", "n", "math.acos(value %1)" )
Core:AddFunction( "asinr", "n", "n", "math.asin(value %1)" )
Core:AddFunction( "atanr", "n", "n", "math.atan(value %1)" ) 
Core:AddFunction( "atanr", "n,n", "n", "math.atan(value %1, value %2)" )

Core:AddFunction( "cosr", "n", "n", "math.cos(value %1)" )
Core:AddFunction( "secr", "n", "n", "(1 / math.cos(value %1))" )

Core:AddFunction( "sinr", "n", "n", "math.sin(value %1)" )
Core:AddFunction( "cscr", "n", "n", "(1 / math.sin(value %1))" )

Core:AddFunction( "tanr", "n", "n", "math.tan(value %1)" )
Core:AddFunction( "cotr", "n", "n", "(1 / math.tan(value %1))" )

Core:AddFunction( "coshr", "n", "n", "math.cosh(value %1)" )
Core:AddFunction( "sechr", "n", "n", "(1 / math.cosh(value %1))" )

Core:AddFunction( "sinhr", "n", "n", "math.sinh(value %1)" )
Core:AddFunction( "cschr", "n", "n", "(1 / math.sinh(value %1))" )

Core:AddFunction( "tanhr", "n", "n", "math.tanh(value %1)" )
Core:AddFunction( "cothr", "n", "n", "(1 / math.tanh(value %1))" ) 

Core:AddFunction( "ln", "n", "n", "math.log(value %1)" ) 

Core:AddFunction( "log2", "n", "n", "(math.log(value %1) * (1 / math.log(2)))" )

Core:AddFunction( "log10", "n", "n", "math.log10(value %1)" )

Core:AddFunction( "log", "n,n", "n", "(math.log(value %1) / math.log(value %2))" )

Core:AddFunction("mix", "n,n,n", "n", "(value %1 * value %3 + value %2 * (1 - value %3))" )

/*==============================================================================================
	Section: BINARY
==============================================================================================*/

Core:AddOperator( "&" , "n,n", "n", "bit.band(value %1, value %2)" )
Core:AddOperator( "|" , "n,n", "n", "bit.bor(value %1, value %2)" )
Core:AddOperator( "^^", "n,n", "n", "bit.bxor(value %1, value %2)" )
Core:AddOperator( ">>", "n,n", "n", "bit.rshift(value %1, value %2)" )
Core:AddOperator( "<<", "n,n", "n", "bit.lshift(value %1, value %2)" )


/*==============================================================================================
	Section: CONSTANTS
==============================================================================================*/
Core:AddConstant( "PI", "n", "math.pi" )
Core:AddConstant( "PHI", "n", "((1 + math.sqrt(5)) / 2)" )
Core:AddConstant( "E", "n", "math.exp(1)" )