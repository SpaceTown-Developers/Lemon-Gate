/*==============================================================================================
	Expression Advanced: Lemon Gate Lib.
	Purpose: Creates the E_A framework.
	Creditors: Rusketh
==============================================================================================*/
LemonGate = {
	Tokenizer = {},
	Parser = {},
	Compiler = {},
	API = {},
}

local E_A = LemonGate

EA_COST_CHEAP = 0.5
EA_COST_NORMAL = 1
EA_COST_ABNORMAL = 2.5
EA_COST_EXPENSIVE = 5

/*==============================================================================================
	Section: Util Zone
==============================================================================================*/
local _type = type
local LowerStr = string.lower -- Speed
local FormatStr = string.format -- Speed

local function type(Value)
	-- Purpose: Basicaly this replaces type but lowercased.
	
	return LowerStr( _type(Value) )
end

function E_A.CheckType(Value, Type, I, AllowNil)
	-- Purpose: Checks the type of a function peramater. This prevents bad code from breaking E_As core!
	
	if !(AllowNil and Value == nil) and type(Value) ~= Type then
		error( FormatStr("Invalid argument #%i (%s) expected got (%s)", I, Type, type(Value)),3)
	end
end

local CheckType = E_A.CheckType

/*==============================================================================================
	Section: Sync Clinet
==============================================================================================*/
net.Receive( "lemon_types", function()
	E_A.TypeTable = {}; E_A.TypeShorts = {}
	local Name = net.ReadString()
	
	while Name ~= "" do
		local Short = net.ReadString()
		local Type = {Name, Short, net.ReadBit() == 1, true, net.ReadBit() == 1, net.ReadBit() == 1}
		E_A.TypeTable[Name] = Type
		E_A.TypeShorts[Short] = Type
		
		Name = net.ReadString()
	end
end)

net.Receive( "lemon_functions", function()
	E_A.FunctionTable = {}
	local Name = net.ReadString()
	
	while Name ~= "" do
		E_A.FunctionTable[Name] = {true, net.ReadString(), net.ReadFloat()}
		Name = net.ReadString()
	end
end)

net.Receive( "lemon_operators", function()
	E_A.OperatorTable = {}
	local Name = net.ReadString()
	
	while Name ~= "" do
		E_A.OperatorTable[Name] = {true, net.ReadString(), net.ReadFloat()}
		Name = net.ReadString()
	end
end)

net.Receive( "lemon_events", function()
	E_A.EventsTable = {}
	local Name = net.ReadString()
	
	while Name ~= "" do
		E_A.EventsTable[Name] = {net.ReadString(), net.ReadString()}
		Name = net.ReadString()
	end
end)

net.Receive( "lemon_exceptions", function()
	E_A.Exceptions = {}
	local Name = net.ReadString()
	
	while Name ~= "" do
		E_A.Exceptions[Name] = Name
		Name = net.ReadString()
	end
end)

/*==============================================================================================
	Section: Class Check Functions!
==============================================================================================*/
function E_A.IsType( Type )
	CheckType( Type, "string", 1 ); Type = LowerStr( Type or "" )

	local Out = E_A.TypeTable[Type] or E_A.TypeShorts[Type] or nil 
	return Out and true or false
end

function E_A.GetShortType( Type )
	CheckType( Type, "string", 1, true)
	
	if !Type or Type == "" or Type == "void" then return "" end
	Type = LowerStr( Type or "" )
	
	local Out = E_A.TypeTable[Type] or E_A.TypeShorts[Type] or nil 
	
	if Out then return Out[2] end
end

function E_A.GetLongType( Type )
	CheckType( Type, "string", 1, true )
	
	if !Type or Type == "" or Type == "void" then return "void" end
	Type = LowerStr( Type )
	
	local Out = E_A.TypeTable[Type] or E_A.TypeShorts[Type] or nil 
	
	if Out then return Out[1] end
end

/*==============================================================================================
	Section: Dud Functions!
==============================================================================================*/
function E_A:RegisterClass() end
function E_A:WireModClass() end
function E_A:SetCost() end
function E_A:RegisterFunction() end
function E_A:RegisterOperator() end

/*==============================================================================================
	Section: API!
==============================================================================================*/
include("Core/API.lua")
E_A.API.LoadComponents()