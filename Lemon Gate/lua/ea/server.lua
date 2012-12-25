/*==============================================================================================
	Expression Advanced: Lemon Gate Lib.
	Purpose: Creates the E_A framework.
	Creditors: Rusketh & Oskar94, Based on work by Syranide! (E2)
==============================================================================================*/
LemonGate = {
	Tokenizer = {},
	Parser = {},
	Compiler = {},
	API = {},
	
	Context = {},
	Operator ={},
} -- General Table Completed!

local E_A = LemonGate

local LowerStr = string.lower -- Speed
local FormatStr = string.format -- Speed
local UpperStr = string.upper -- Speed

/*==============================================================================================
************************************************************************************************
================================================================================================
									PRE LOADING
								WE CREATE NESICARY STUFFS
								LOAD COMPONENTS AND STUFF
================================================================================================
************************************************************************************************
==============================================================================================*/

MsgN("Expression Advanced: Pre Loading!")

/*==============================================================================================
	Section: Util Zone
==============================================================================================*/
local _type = type

local function type(Value)
	-- Purpose: Basically this replaces type but lowercased.
	
	return LowerStr( _type(Value) )
end

function E_A.CheckType(Value, Type, I, AllowNil)
	-- Purpose: Checks the type of a function parameter. This prevents bad code from breaking E_As core!
	
	if !(AllowNil and Value == nil) and type(Value) ~= Type then
		error( FormatStr("Invalid argument #%i (%s) expected got (%s)", I, Type, type(Value)),3)
	end
end

local CheckType = E_A.CheckType

/*==============================================================================================
	Section: Lua Builder
==============================================================================================*/
local Cache, SizeC, TableToLua = {}, 0
E_A.Cache = Cache -- Make it accessible!

function E_A.ValueToLua(Value, NoTables)
	if !Value then return "NULL" end
	
	local Type = type(Value)
	
	if Type == "number" then
		return Value
	elseif Type == "string" then
		return FormatStr("%q", Value)
	elseif Type == "boolean" then
		return Value and "true" or "false"
	elseif Type == "table" and !NoTables then
		return E_A.TableToLua(Value)
	elseif Type == "function" and !NoTables then
		SizeC = SizeC + 1; Cache[SizeC] = Value
		return "LemonGate.Cache[" .. SizeC .. "]"
	end
end

local ValueToLua = E_A.ValueToLua

function E_A.TableToLua(Table)
	-- Purpose: Turns a table into a string of lua to rebuild that table.
	-- Todo: String escaping, if required.
	 
	local Lua = "{"
	
	for Key, Value in pairs(Table) do
		local kLua = ValueToLua(Key, true)
		local vLua = ValueToLua(Value)
		
		if !kLua then
			error("TableToLua invalid Key of type " .. type(Key))
		elseif !vLua then
			error("TableToLua invalid Value of type " .. type(Value))
		end
		
		Lua = Lua .. "[" .. kLua .. "] = " .. vLua .. ", "
	end
	
	return Lua .. "}"
end

TableToLua = E_A.TableToLua

/*==============================================================================================
	Section: This is where we load the API!
==============================================================================================*/
include("core/api.lua")
AddCSLuaFile("core/api.lua")

local API = E_A.API

/*==============================================================================================
	Section: Token preload Functions!
==============================================================================================*/
local Tokens, OpTokens, SizeT -- Used by E_A.BuildTokens()

function E_A:CreateToken(Patern, Tag,  Name)
	CheckType(Patern, "string", 1); CheckType(Tag, "string", 2); CheckType(Name, "string", 3)
	-- Purpose: Create a new token.
	
	Tokens[Name] = {Patern, Tag, Name or "Unknown Token"}
end

function E_A:CreateOpToken(Patern, Tag,  Name)
	CheckType(Patern, "string", 1); CheckType(Tag, "string", 2); CheckType(Name, "string", 3)
	-- Purpose: Create a new token.
		
	local Token = {Patern, Tag, Name or "Unknown Token"}
	Tokens[Name] = Token; OpTokens[SizeT] = Token; SizeT = SizeT + 1
end

/*==============================================================================================
	Section: Class preload Functions!
==============================================================================================*/
LEMON_NATIVE = nil -- A value we need!
local Types, SizeT = {}, 1

function E_A:RegisterClass(Name, Short, Default)
	CheckType(Name, "string", 1); CheckType(Short, "string", 2)
	-- Purpose: Create a new class.
	
	
	Name = LowerStr(Name)
	local Type = {[0] = API.CurrentComponent(), Name, LowerStr(Short)}
	
	if type(Default) == "function" then
		Type[3] = Default
	else
		RunString("LEMON_NATIVE = function() return " .. ValueToLua(Default) .. " end")
		Type[3] = LEMON_NATIVE; LEMON_NATIVE = nil -- Default value is now a function!
	end
	
	Types[SizeT] = Type; SizeT = SizeT + 1
end

local WireTypes = {}

function E_A:WireModClass(Class, Name, In, Out)
	CheckType(Class, "string", 1); CheckType(Name, "string", 2); CheckType(In, "function", 3, true); CheckType(Out, "function", 4, true)
	-- Purpose: Makes a class compatible with wiremod.
	
	WireTypes[Class] = {UpperStr(Name), In, Out}
end

/*==============================================================================================
	Section: Function and Operator preload Functions!
==============================================================================================*/
EA_COST_CHEAP = 0.5
EA_COST_NORMAL = 1
EA_COST_ABNORMAL = 2.5
EA_COST_EXPENSIVE = 5

local COST = EA_COST_CHEAP

function E_A:SetCost(Value)
	CheckType(Value, "number", 1)
	COST = Value -- Sets the perf coast of the next functions and operators!
end

local Functions, SizeF = {}, 1

function E_A:RegisterFunction(Name, Params, Return, Function)
	CheckType(Name, "string", 1); CheckType(Return, "string", 3, true); CheckType(Function, "function", 4)
	-- Purpose: Creates a new E_A function.
	
	Functions[SizeF] = {[0] = API.CurrentComponent(), Name, Params or "", Return or "", Function, COST}
	SizeF = SizeF + 1
end

local Operators, SizeO = {}, 1

function E_A:RegisterOperator(Name, Params, Return, Function)
	CheckType(Name, "string", 1); CheckType(Return, "string", 3, true); CheckType(Function, "function", 4)
	-- Purpose: Creates a new E_A operator.
	
	Operators[SizeO] = {[0] = API.CurrentComponent(), Name, Params or "", Return or "", Function, COST}
	SizeO = SizeO + 1
end

/*==============================================================================================
	Section: Event preload Functions!
==============================================================================================*/
local Events, SizeE = {}, 1

function E_A:RegisterEvent(Name, Params, Return)
	CheckType(Name, "string", 1); CheckType(Return, "string", 3, true)
	-- Purpose: Creates a new E_A event.
	
	Events[SizeE] = {[0] = API.CurrentComponent(), Name, Params or "", Return or "", COST}
	SizeE = SizeE + 1
end

/*==============================================================================================
	Section: Exception!
==============================================================================================*/
E_A.Exceptions = {}

function E_A:RegisterException(Name)
	CheckType(Name, "string", 1)
	-- Purpose: Add an exception type.
	
	local Name = LowerStr(Name)
	E_A.Exceptions[Name] = Name
end

/*==============================================================================================
************************************************************************************************
================================================================================================
								PRE LOADING COMPLETE
							NOW EVERY THING MUST BE CHECKED
================================================================================================
************************************************************************************************
==============================================================================================*/

MsgN("Expression Advanced: Preloaded!")

API.LoadComponents()
	
API.CallHook("PreBuild")
	
/*==============================================================================================
	Section: Build Classes!
		Info:
		  1 - Name
		  2 - ShortName
		  3 - Default
		  4 - WM Name
		  5 - WM Input
		  6 - WM Output
==============================================================================================*/
E_A.TypeTable, E_A.TypeShorts = {}, {}
local TypeTable, TypeShorts = E_A.TypeTable, E_A.TypeShorts

API.CallHook("BuildClasses")

for I = 1, SizeT - 1 do
	local Type = Types[I]
	
	if API.Component(Type[0]) then -- Component enabled?
		local WM = WireTypes[ Type[1] ]
		if WM then  Type[4] = WM[1]; Type[5] = WM[2]; Type[6] = WM[3]  end
		
		TypeTable[ Type[1] ] = Type
		TypeShorts[ Type[2] ] = Type
	end
end

/*==============================================================================================
	Section: Class Util Functions
==============================================================================================*/
function E_A.IsType( Type )
	CheckType( Type, "string", 1 ); Type = LowerStr( Type or "" )

	local Out = E_A.TypeTable[Type] or E_A.TypeShorts[Type] or nil 
	return Out and true or false
end

function E_A.GetShortType( Type )
	CheckType( Type, "string", 1, true )
	
	if !Type or Type == "" or Type == "void" then return "" end
	
	Type = LowerStr( Type )
	local Out = E_A.TypeTable[Type] or E_A.TypeShorts[Type] or nil 
	
	if Out then return Out[2] end
end

function E_A.GetLongType( Type )
	CheckType( Type, "string", 1, true )
	
	if !Type or Type == "" or Type == "void" then return "" end
	Type = LowerStr( Type )
	
	local Out = E_A.TypeTable[Type] or E_A.TypeShorts[Type] or nil 
	
	if Out then return Out[1] end
end

local IsType = E_A.IsType
local GetLongType = E_A.GetLongType
local GetShortType = E_A.GetShortType

/*==============================================================================================
	Section: Build Functions!
==============================================================================================*/
E_A.FunctionTable = {}
local FunctionTable = E_A.FunctionTable

API.CallHook("BuildFunctions")

for I = 1, SizeF - 1 do
	local Function = Functions[I]
	
	if API.Component(Function[0]) then -- Component enabled?
		
		local Return = GetShortType( Function[3] )
		
		if !Return then
			MsgN("Expression Advanced Skipping function '" .. tostring(Function[1]) .. " in component " .. tostring(Function[0]))
			MsgN("Return type " .. tostring(Function[3]) .. " does not exist!")
			continue -- GM 13, Hell yes!
		end
		
		local Perams = Function[2]
		local Signature, Valid = Perams, true
		
		if type(Perams) == "table" then
			Signature = ""
			for I = 1, #Perams do
				local Short = GetShortType( Perams[I] )
				
				if !Short then
					MsgN("Expression Advanced Skipping function '" .. Function[1] .. " in component " .. Function[0])
					MsgN("Parameter type " .. tostring(Perams[I]) .. " does not exist!")
					Valid = false; break
				else
					Signature = Signature .. Short
				end
			end
		end
		
		if Valid then FunctionTable[ Function[1] .. "(" .. Signature .. ")" ] = {Function[4], Return, Function[5]} end
	end
end

/*==============================================================================================
	Section: Build Operators!
==============================================================================================*/

E_A.OperatorTable = {}
local OperatorTable = E_A.OperatorTable

API.CallHook("BuildOperators")

for I = 1, SizeO - 1 do
	local Operator = Operators[I]
	
	if API.Component(Operator[0]) then -- Component enabled?
		
		local Return = GetShortType( Operator[3] )
		
		if !Return then
			MsgN("Expression Advanced Skipping function '" .. Operator[1] .. " in component " .. Operator[0])
			MsgN("Return type " .. tostring(Operator[3]) .. " does not exist!")
			continue -- GM 13, Hell yes!
		end
		
		local Perams = Operator[2]
		local Signature, Valid = Perams, true
		
		if type(Perams) == "table" then
			Signature = ""
			for I = 1, #Perams do
				local Short = GetShortType( Perams[I] )
				
				if !Short then
					MsgN("Expression Advanced Skipping operator '" .. Operator[1] .. " in component " .. Operator[0])
					MsgN("Parameter type " .. tostring(Perams[I]) .. " does not exist!")
					Valid = false; break
				else
					Signature = Signature .. Short
				end
			end
		end
		
		if Valid then OperatorTable[ Operator[1] .. "(" .. Signature .. ")" ] = {Operator[4], Return, Operator[5]} end
	end
end

/*==============================================================================================
	Section: Build Events!
==============================================================================================*/

E_A.EventsTable = {}
local EventsTable = E_A.EventsTable

API.CallHook("BuildEvents")

for I = 1, SizeE - 1 do
	local Event = Events[I]
	
	if API.Component(Event[0]) then -- Component enabled?
		
		local Return = GetShortType( Event[3] )
		
		if !Return then
			MsgN("Expression Advanced Ignoring event '" .. Event[1] .. " in component " .. Event[0])
			MsgN("Return type " .. tostring(Event[3]) " .. does not exist!")
			continue -- GM 13, Hell yes!
		end
		
		local Perams = Event[2]
		local Signature, Valid = Perams, true
		
		if type(Perams) == "table" then
			Signature = ""
			for I = 1, #Perams do
				local Short = GetShortType( Perams[I] )
				
				if !Short then
					MsgN("Expression Advanced Ignoring event '" .. Event[1] .. " in component " .. Event[0])
					MsgN("Parameter type " .. tostring(Perams[I]) " .. does not exist!")
					Valid = false; break
				else
					Signature = Signature .. Short
				end
			end
		end
		
		if Valid then
			EventsTable[ Event[1] ] = {Signature, Return, Event[4]}
			
			MsgN( Event[1] )
			PrintTable( {Signature, Return, Event[4]} )
		end
	end
end

API.CallHook("PostBuild")
	
MsgN("Expression Advanced: Loaded!")

/*==============================================================================================
	Section: GARBAGE COLLECT!
==============================================================================================*/
-- Just clean out what little memory we no longer need!
Types = nil
WireTypes = nil
Functions = nil
Operators = nil
Events = nil

/*==============================================================================================
	Section: Sync Client
==============================================================================================*/
util.AddNetworkString( "lemon_types" )
util.AddNetworkString( "lemon_functions" )
util.AddNetworkString( "lemon_operators" )
util.AddNetworkString( "lemon_events" )
util.AddNetworkString( "lemon_exceptions" )

function E_A.SyncClient(Player)
	net.Start( "lemon_types" )
		for _, Class in pairs( E_A.TypeTable ) do
			net.WriteString( Class[1] )
			net.WriteString( Class[2] )
			net.WriteBit( Class[3] ~= nil)
			net.WriteBit( Class[5] ~= nil)
			net.WriteBit( Class[6] ~= nil)
		end
		net.WriteString( "" )
	net.Send( Player )
	
	net.Start( "lemon_functions" )
		for Name, Data in pairs( E_A.FunctionTable ) do
			net.WriteString( Name )
			net.WriteString( Data[2] )
			net.WriteFloat( Data[3] )
		end
		net.WriteString( "" )
	net.Send( Player )
	
	net.Start( "lemon_operators" )
		for Name, Data in pairs( E_A.OperatorTable ) do
			net.WriteString( Name )
			net.WriteString( Data[2] )
			net.WriteFloat( Data[3] )
		end
		net.WriteString( "" )
	net.Send( Player )
	
	net.Start( "lemon_events" )
		for Name, Data in pairs( E_A.EventsTable ) do
			net.WriteString( Name )
			net.WriteString( Data[1] )
			net.WriteString( Data[2] )
		end
		net.WriteString( "" )
	net.Send( Player )
	
	net.Start( "lemon_exceptions" )
		for _, Name in pairs( E_A.Exceptions ) do
			net.WriteString(  Name )
		end
		net.WriteString( "" )
	net.Send( Player )
end

concommand.Add("lemon_sync", E_A.SyncClient)

/*==============================================================================================
	Section: Prop Friending
==============================================================================================*/

function E_A.IsOwner(Player, Entity)
	local Owner = Entity:GetOwner()
	if Entity.Player then Owner = Entity.Player end
	if CPPI then Owner = Entity:CPPIGetOwner() end
	
	if !Owner then return false end
	return Player == Owner
end

function E_A.IsFriend(Owner, Player)
	if CPPI then
		local Friends = Owner:CPPIGetFriends()
		if type(Friends) == "table" then
			for _, Friend in pairs(Friends) do
				if Friend == Player then return true end
			end
		end
	end
	
	return Owner == Player
end

/*==============================================================================================
	Section: Script Context
==============================================================================================*/
local Context = E_A.Context
Context.__index = Context

function Context:Throw(Exeption, ...)
	self.Exception = Exeption
	self.ExceptionInfo = {...}
	self.ExceptionTrace = self.StackTrace
	error("Exception", 0)
end

function Context:Error(Message, Info, ...)
	if Info then Message = FormatStr(Message, Info, ...) end
	self:Throw("script", Message)
end

function Context:PushPerf(Perf)
	local Perf = self.Perf - Perf; self.Perf = Perf
	if Perf < 0 then self:Throw("script", "Execution Limit Reached") end
end

/*==============================================================================================
	Section: Instruction Operators
==============================================================================================*/
local Operator = E_A.Operator
Operator.__index = Operator

local setmetatable = setmetatable
local unpack = unpack
local pcall = pcall

function E_A.CallOp(Op, self, Arg, ...)
	-- Purpose: Makes Operators callable and handles runtime perf.
	
	-- Performance Points.
	self:PushPerf(Op[0] or EA_COST_NORMAL)
	
	-- Update Stack Trace
	local StackTrace = self.StackTrace
	StackTrace[#StackTrace + 1] = Op[4]
	
	-- Parameters
	local Perams = Op[3]
	if Arg then Perams = {Arg, ...} end
	
	local Res, Type -- Call the operator.
		if !Perams or #Perams == 0 then
			Res, Type = Op[1](self)
		elseif #Perams < 20 then -- Unpack is slow so lets avoid it!
			Res, Type = Op[1](self, Perams[1], Perams[2], Perams[3], Perams[4], Perams[5], Perams[6], Perams[7], Perams[8], Perams[9], Perams[10], Perams[11], Perams[12], Perams[13], Perams[14], Perams[15], Perams[16], Perams[17], Perams[18], Perams[19], Perams[20])
		else
			Res, Type = Op[1](self, unpack(Perams)) -- More then 20 parameters!
		end
	
	-- Reset Stack Trace
	StackTrace[#StackTrace] = nil
	
	return Res, (Type or Op[2])
end 

local CallOp = E_A.CallOp
Operator.__call = E_A.CallOp

function E_A.SafeCall(Op, self, ...)
	-- Purpose: Calls the operator safely and handles exceptions.
	
	local StackTrace = self.StackTrace -- Back up trace!
	self.StackTrace = { StackTrace[#StackTrace] }
	
	local Ok, Result, Type = pcall(CallOp, Op, self, ...)
	self.StackTrace = StackTrace -- Restore last trace!
	
	if !Ok and Result == "Exception" then
		return false, self.Exception, unpack(self.ExceptionInfo)
	end
	
	return Ok, Result, Type
end

function E_A.ValueToOp(Value, Type)
	-- Purpose: Can instantly convert values to operator values.
	
	return setmetatable({function() return Value, Type end, [2] = Type}, Operator)
end

Operator.SafeCall = E_A.SafeCall