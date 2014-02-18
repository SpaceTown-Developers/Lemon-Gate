/*==============================================================================================
	Expression Advanced: Component -> String.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" )

Core:AddException( "string" )

/*==============================================================================================
	Section: Class
==============================================================================================*/
local String = Core:NewClass( "s", "string", "" )

String:Wire_Name( "STRING" )

function String.Wire_Out( Context, Cell ) return Context.Memory[ Cell ] or 0 end

function String.Wire_In( Context, Cell, Value ) Context.Memory[ Cell ] = Value end

/*==============================================================================================
	Section: Operators
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

-- Assign:

Core:AddOperator( "=", "s", "s", [[
%delta[value %1] = %memory[value %1]
%memory[value %1] = value %2
%click[value %1] = %click[value %1] or ( %delta[value %1] ~= %memory[value %1] )
]], "value %2" )

Core:AddOperator( "~", "s", "b", "%click[value %1]" )


-- Compare:

Core:AddOperator( "==", "s,s", "b", "(value %1 == value %2)" )

Core:AddOperator( "!=", "s,s", "b", "(value %1 ~= value %2)" )

-- Arithmatic:

Core:AddOperator( "+", "s,s", "s", "(value %1 .. value %2)" )

Core:AddOperator( "+", "s,n", "s", "(value %1 .. value %2)" )

Core:AddOperator( "+", "n,s", "s", "(value %1 .. value %2)" )

Core:AddOperator( "#", "s", "n", "string.len(value %1)" )

-- General:

Core:AddOperator( "is", "s", "b", "(value %1 ~= \"\")" )

Core:AddOperator( "not", "s", "b", "(value %1 == \"\")" )

-- Index:

Core:AddOperator( "[]", "s,n", "s", "(value %1[value %2])" )

-- Casting:

Core:AddOperator( "number", "n", "s", "$tonumber(value %1)" )

/*==============================================================================================
	Section: General String Functions
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddFunction( "length", "s:", "n", "(#value %1)", nil )

Core:AddFunction( "lower", "s:", "s", "string.lower(value %1)" )

Core:AddFunction( "upper", "s:", "s", "string.upper(value %1)" )

Core:AddFunction( "sub", "s:n[,n]", "s", "string.sub(value %1, value %2, value %3)" )

Core:AddFunction( "index", "s:n", "s", "(value %1[ value %2])" )

Core:AddFunction( "left", "s:n", "s", "string.Left(value %1, value %2)" )

Core:AddFunction( "right", "s:n", "s", "string.Right(value %1, value %2)" )

/*==============================================================================================
	Section: General String Functions
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "repeat", "s:n", "s", "string.rep(value %1, value %2)" )

Core:AddFunction( "trim", "s:", "s", "string.Trim(value %1)" )

Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddFunction( "trim", "s:s", "s", "string.Trim(value %1, string.gsub(value %2, \"[%-%^%$%(%)%%%.%[%]%*%+%?]\", \"%%%1\"))" )

Core:AddFunction( "trimLeft", "s:s", "s", "string.gsub(value %1, \"^\" .. string.gsub(value %2, \"[%-%^%$%(%)%%%.%[%]%*%+%?]\", \"%%%1\") .. \"*(.+)$\", \"%1\" )" )

Core:AddFunction( "trimRight", "s:s", "s", "string.gsub(value %1, \"^(.-)\" .. string.gsub(value %2, \"[%-%^%$%(%)%%%.%[%]%*%+%?]\", \"%%%1\") .. \"*$\", \"%1\" )" )

/*==============================================================================================
	Section: Char / Byte Functions
==============================================================================================*/
Core:SetPerf( LEMON_PERF_ABNORMAL )

local CharStr = string.char

Core:AddExternal( "ToChar", function( Number )
	if Number < 1 then return "" end
	if Number > 255 then return "" end
	return CharStr( Number )
end )

Core:AddFunction( "toChar", "n", "s", "%ToChar(value %1)" )

local ByteStr = string.byte

Core:AddExternal( "ToByte", function( String )
	if String == "" then return -1 end
	return ByteStr( String )
end )

Core:AddFunction( "toByte", "s", "n", "%ToByte(value %1)" )

/*==============================================================================================
	Section: Finding and Replacing
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "find", "s:s", "n", "(string.find(value %1, value %2, 1, true) or 0)" )

Core:AddFunction( "find", "s:s,n", "n", "(string.find(value %1, value %2, value %3, true) or 0)" )

Core:AddFunction( "replace", "s:s,s", "s", "(string.Replace(value %1, value %2, value %3) or \"\")" )

/*==============================================================================================
	Section: Finding and Replacing with REGEX
==============================================================================================*/

Core:SetPerf( LEMON_PERF_EXPENSIVE)

Core:AddFunction( "findPattern", "s:s[,n]", "n", [[
	local %Ok, %Result = pcall(string.find, value %1, value %2, value %3)
	if !%Ok then %context:Throw(%trace,"string", "Invalid string pattern.") end
]], "(%Result or 0)" )

Core:AddFunction( "replacePattern", "s:s,s", "s", [[
	local %Ok, %Result = pcall(string.gsub, value %1, value %2, value %3)
	if !%Ok then %context:Throw(%trace,"string", "Invalid string pattern.") end
]], "(%Result or 0)" )

/*==============================================================================================
	Section: Explode / Matches
==============================================================================================*/
Core:SetPerf( LEMON_PERF_EXPENSIVE)

Core:AddFunction( "explode", "s:s", "t", "%Table.Results(string.Explode(value %2, value %1), \"s\")" )

Core:AddFunction( "explodePattern", "s:s", "t", [[
local %Ok, %Results = pcall(string.gsub, value %2, value %1, true)
if !%Ok or !Results then %context:Throw(%trace,"string", "Invalid string pattern.") end
]], "%Table.Results(%Results, \"s\")")

Core:AddFunction( "matchPattern", "s:s[,n]", "t",[[
local %Results = { pcall(string.match, value %1, value %2, value %3 or 0) }
if !table.remove(%Results,1) then %context:Throw("string", "Invalid string pattern.") end
]], "%Table.Results(%Results, \"s\")")

Core:AddFunction( "matchFirst", "s:s[,n]", "s",[[
local %Ok, %Result = pcall(string.match, value %1, value %2, value %3 or 0)
if !%Ok then %context:Throw("string", "Invalid string pattern.") end
]], "(%Result or \"\")")
