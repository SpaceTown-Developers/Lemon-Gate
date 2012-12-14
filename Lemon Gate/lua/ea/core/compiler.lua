/*==============================================================================================
	Expression Advanced: Lemon Gate Compiler.
	Purpose: Converts Instructions To Operators!
	Creditors: Rusketh
==============================================================================================*/

local E_A = LemonGate

local Compiler = E_A.Compiler
Compiler.__index = Compiler

local next = next
local type = type
local pcall = pcall
local error = error
local unpack = unpack
local setmetatable = setmetatable

local FormatStr = string.format -- Speed
local UpperStr = string.upper -- Speed
local LowerStr = string.lower -- Speed
local SubStr = string.sub -- Speed
local FindStr = string.find -- Speed
local LenStr = string.len -- Speed
local ConcatTbl = table.concat -- Speed
local RemoveTbl = table.remove -- Speed

local LimitString = E_A.LimitString
local GetLongType = E_A.GetLongType
local GetShortType = E_A.GetShortType

/*==============================================================================================
	Util Functions
==============================================================================================*/
local function UpcaseStr(Str)
	-- Purpose: Makes the first letter uppercase the rest wil be lowercased.
	
	return UpperStr(SubStr(Str, 1, 1)) .. LowerStr(SubStr(Str, 2))
end

/*==============================================================================================
	Compiler Processor
==============================================================================================*/
function Compiler.Execute(...)
	-- Purpose: Executes the Compiler.
	
	local Instance = setmetatable({}, Compiler)
	return pcall(Compiler.Run, Instance, ...)
end


function Compiler:Run(Instr)
	-- Purpose: Run the compiler
	self:InitScopes()
	
	self.Inputs = {}
	self.Outputs = {}
	
	self.VarIndex = 1
	self.VarTypes = {}
	self.VarData = {}
	
	self.Perf = 0
	self.ReturnTypes = {}
	self.Trace = {1, 1}
	
	return self:CompileInst(Instr), self
end

/********************************************************************************************************************/

function Compiler:Error(Message, Info, ...)
	-- Purpose: Create and push a syntax error.
	
	local Line, Char = 0, 0
	if self.Trace then
		Line = self.Trace[1]
		Char = self.Trace[2]
	end
	
	if Info then Message = FormatStr(Message, Info, ...) end
	error( FormatStr(Message .. " at line %i, char %i", Line, Char), 0)
end

/*==============================================================================================
	Section: Instruction Convershion
	Purpose: Functions to find instructions and convert them to operators.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:CompileInst(Inst)
	-- Purpose: Compiles an instuction.
	
	if !Inst then
		MsgN("Compiler recived invalid instruction " .. tostring(Inst))
		debug.Trace()
	end
	
	local Func = self["Instr_" .. UpperStr(Inst[1])]
	
	if Func then
		local Trace = Inst[2]; Trace[3] = Inst[1]
		local _Trace = self.Trace; self.Trace = Trace
		
		local Result, Type = Func(self, unpack(Inst[3]))
		self.Trace = _Trace; return Result, Type
	else
		self:Error("Compiler: Uknown Instruction '%s'", Inst[1])
	end
end

function Compiler:GetOperator(Name, sType, ...)
	-- Purpose: Grabs an operator.

	local tArgs = {...}
	local Types = GetShortType( sType or "" )
	
	if #tArgs > 0 then 
		for I = 1, #tArgs do
			Types = Types .. GetShortType( tArgs[I] )
		end
	end
	
	local Op = E_A.OperatorTable[ Name .. "(" .. Types .. ")" ]
	if !Op then return end
	
	return Op[1], Op[2], Op[3]
end

function Compiler:Operator(Op, Type, Perf, ...)
	-- Purpose: Creates an operation.
	
	local Trace, Type = self.Trace, GetShortType(Type)
	
	local Operator = { Op, Type, {...}, Trace }
	
	Operator[0] = (Perf or 0); Trace[4] = Operator
	
	return setmetatable(Operator, E_A.Operator), Type
end

/********************************************************************************************************************/

function Compiler:PushPerf(Perf)
	self.Perf = self.Perf + Perf
	-- TODO: Compiler perf exceed!
end

function Compiler:PushReturnType(Type)
	self.ReturnTypes[#self.ReturnTypes + 1] = Type
end

function Compiler:PopReturnType()
	self.ReturnTypes[#self.ReturnTypes] = nil
end

function Compiler:CheckReturnType()
end

/*==============================================================================================
	Section: Scopes
	Purpose: Handels the levels at witch Variables run.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:InitScopes()
	-- Purpose: Creates the inital scope enviroments.
	
	local Global, Current = {}, {}
	self.Scopes = {[0] = Global, [1] = Current}
	self.GlobalScope = Global
	self.Scope = Current
	self.ScopeID = 1
end

function Compiler:PushScope()
	-- Purpose: Pushes up one scope level.
	
	self.ScopeID = self.ScopeID + 1
	self.Scope = {}
	self.Scopes[self.ScopeID] = self.Scope
end

function Compiler:PopScope()
	-- Purpose: Pops down one scope level.
	
	local Removed = self.Scope
	self.Scopes[self.ScopeID] = nil
	self.ScopeID = self.ScopeID - 1
	self.Scope = self.Scopes[self.ScopeID]
	return Removed -- Return the removed scope.
end

/*==============================================================================================
	Section: Variable Handler
	Purpose: Assigns Variables to Scopes and Memory.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:LocalVar(Name, Type)
	-- Purpose: Checks the memory for a Variable or creates a new Variable.
	
	print("Local Var:", Name, Type)
	debug.Trace()
	
	Type = GetShortType(Type)
	
	local Cur = self.Scope[Name]
	if Cur then
		local CType = self.VarTypes[Cur]
		if CType != Type then -- Check to see if this value exists?
			self:Error("Variable %s already exists as %s, and can not be assigned to %s", Name, GetLongType(CType), GetLongType(Type))
		else
			return Curr -- Return the existing Var Index
		end
	end
	
	local VarID = self.VarIndex + 1
	self.VarIndex = VarID -- We move up in memory.
	
	self.Scope[Name] = VarID
	self.VarTypes[VarID] = Type
	
	return VarID, self.ScopeID
end

/********************************************************************************************************************/

function Compiler:SetVar(Name, Type, NoError)
	Type = GetShortType(Type, true)
	
	local Scopes = self.Scopes
	for I = self.ScopeID, 0, -1 do
		local Cur = Scopes[I][Name]
		if Cur then
			local CType = self.VarTypes[Cur]
			if CType != Type then
				self:Error("Variable %s already exists as %s, and can not be assigned to %s", Name, GetLongType(CType), GetLongType(Type))
			else
				return Cur, I
			end
		end
	end
	
	local VarID = self.VarIndex + 1
	self.VarIndex = VarID -- Nome: We move up in memory.
	
	self.GlobalScope[Name] = VarID
	self.VarTypes[VarID] = Type
	
	return VarID, 0
end

/********************************************************************************************************************/

function Compiler:GetVar(Name)
	local Scopes = self.Scopes
	for I = self.ScopeID, 0, -1 do
		local Cur = Scopes[I][Name]
		if Cur then return Cur, self.VarTypes[Cur] end
	end
end

/********************************************************************************************************************/

function Compiler:AssignVar(Type, Name, Special)
	-- Purpose: Handels variable assigments properly and sorts special cases.
	
	if !Special or Special == "local" then
		return self:LocalVar(Name, Type)
		
	elseif Special == "global" then
		return self:SetVar(Name, Type)
		
	elseif self.ScopeID != 1 then -- They can not be declaired here!
		self:Error("%s can not be declared outside of code body.", UpcaseStr(Special) .. "'s")
	
	else
		local VarID, Scope = self:SetVar(Name, Type)
		
		if Special != "input" and self.Inputs[VarID] then
			self:Error("Variable %s already exists as input, therefore can not be declared as %s", Name, Special)
		elseif Special != "output" and self.Outputs[VarID] then
			self:Error("Variable %s already exists as output, therefore can not be declared as %s", Name, Special)
		end
		
		if Special == "input" then
			self.Inputs[VarID] = Name
		elseif Special == "output" then
			self.Outputs[VarID] = Name
		end
		
		return VarID, Scope
	end
end

/*==============================================================================================
	Section: Sequence Instructions
	Purpose: Runs a sequence
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_SEQUENCE(Smts)
	local Statments = {}
	
	for I = 1, #Smts do
		Statments[I] = self:CompileInst(Smts[I])
	end
	
	local Operator, Return = self:GetOperator("sequence")
	return self:Operator(Operator, Return, 0, Statments, #Statments)
end

/*==============================================================================================
	Section: Raw value Instructions
	Purpose: Grabs raw data and converts to a value operator.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_NUMBER(Number)
	self:PushPerf(EA_COST_CHEAP)
	return self:Operator(function() return Number end, "n", EA_COST_CHEAP)
end

function Compiler:Instr_STRING(String)
	self:PushPerf(EA_COST_CHEAP)
	return self:Operator(function() return String end, "s", EA_COST_CHEAP)
end

/*==============================================================================================
	Section: Assigment Operators
	Purpose: Assigns Values to Variables
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_ASSIGN_DEFAULT(Name, Type, Special)
	-- Purpose: Assign a Variable with a default value.
	
	local Operator, Return, Perf = self:GetOperator("assign", Type)
	
	if !Operator then self:Error("Assigment operator (=) does not support '%s'", GetLongType(Type)) end
	
	local VarID, Scope = self:AssignVar(Type, Name, Special) -- Create the Var
	
	-- Note: Inputs can not be assigned so registering them is enogh.
	if self.Inputs[VarID] then return self:Operator(function() end) end
	
	self:PushPerf(Perf)
	
	local Default = E_A.TypeShorts[Type][3]
	if !Default then self:Error("Assigment operator (=) can not auto assign default value '%s'", GetLongType(Type)) end
	
	return self:Operator(Operator, Return, Perf, self:Operator(Default, Type, 0), VarID)
end

/********************************************************************************************************************/

function Compiler:Instr_ASSIGN_DECLARE(Name, Expr, Type, Special)
	-- Purpose: Declares a value
	
	local Operator, Return, Perf = self:GetOperator("assign", Type)
	if !Operator then self:Error("Assigment operator (=) does not support '%s'", GetLongType(Type)) end
	
	local Value, tValue = self:CompileInst(Expr, true)
	if tValue != Type and Type ~= "?" then
		if tValue == "?" then self:Error("Variable of type variant must be casted before assigning to %s", GetLongType(Type)) end
		self:Error("Variable %s of type %s, can not be assigned as '%s'", Name, GetLongType(Type), GetLongType(tValue))
	end
	
	local VarID, Scope = self:AssignVar(Type, Name, Special)
	
	if self.Inputs[VarID] then -- Note: You can not assign an input!
		self:Error("Assigment operator (=) does not support input Variables")
	end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Value, VarID)
end

/********************************************************************************************************************/

function Compiler:Instr_ASSIGN(Name, Expr)
	-- Purpose: Assign Default value.
	
	local VarID, Type = self:GetVar(Name)
	if !VarID then self:Error("variabel %s does not exist", Name) end
	
	if self.Inputs[VarID] then -- Note: You can not assign an input!
		self:Error("Assigment operator (=) does not support input Variables")
	end
	
	local Operator, Return, Perf = self:GetOperator("assign", Type)
	if !Operator then self:Error("Assigment operator (=) does not support '%s'", GetLongType(Type)) end
	
	local Value, tValue = self:CompileInst(Expr)
	if tValue != Type  and Type ~= "?" then
		if tValue == "?" then self:Error("Variable of type variant must be casted before assigning to %s", GetLongType(Type)) end
		self:Error("Variable %s of type %s, can not be assigned as '%s'", Name, GetLongType(Type), GetLongType(tValue))
	end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Value, VarID)
end

/********************************************************************************************************************/

function Compiler:Instr_VARIABEL(Name)
	-- Purpose: Retrive variabel.
	
	local VarID, Type = self:GetVar(Name)
	if !VarID then self:Error("variabel %s does not exist", Name) end
	
	local Operator, Return = self:GetOperator("variabel", Type)
	if !Operator then self:Error("Improbable Error: variabel operator does not support '%s'", Type) end
	
	self:PushPerf(EA_COST_CHEAP)
	
	return self:Operator(Operator, Return, EA_COST_CHEAP, VarID)
end

/*==============================================================================================
	Section: Mathmatical Operators
	Purpose: Does math stuffs?
	Creditors: Rusketh
==============================================================================================*/
for Name, Symbol in pairs({exponent = "^", multiply = "*", divide = "/", modulus = "%", addition = "+", subtraction = "-"}) do

	Compiler["Instr_" .. UpperStr(Name)] = function(self, InstA, InstB)
		
		local ValueA, TypeA = self:CompileInst(InstA)
		local ValueB, TypeB = self:CompileInst(InstB)
		
		local Operator, Return, Perf = self:GetOperator(Name, TypeA, TypeB)
		if !Operator then self:Error("%s operator (%s) does not support '%s %s %s'", Name, Symbol, GetLongType(TypeA), Symbol, GetLongType(TypeB)) end
		
		self:PushPerf(Perf)
		
		return self:Operator(Operator, Return, Perf, ValueA, ValueB)
	end
end

/********************************************************************************************************************/

function Compiler:Instr_INCREMET(Name)
	-- Purpose: ++ Math Operator.
	
	local Memory, Type = self:GetVar(Name)
	if !Memory then self:Error("Variable %s does not exist", Name) end
	
	if self.Inputs[Memory] then self:Error("incremet operator (--) will not accept input %s", Name) end
	
	local Operator, Return, Perf = self:GetOperator("incremet", Type)
	if !Operator then self:Error("incremet operator (++) does not support '%s++'", Type) end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Memory)
end

function Compiler:Instr_DECREMENT(Name)
	-- Purpose: -- Math Operator.
	
	local Memory, Type = self:GetVar(Name)
	if !Memory then self:Error("Variable %s does not exist", Name) end
	
	if self.Inputs[Memory] then self:Error("decremet operator (--) will not accept input %s", Name) end
	
	local Operator, Return, Perf = self:GetOperator("decremet", Type)
	if !Operator then self:Error("decremet operator (--) does not support '%s++'", Type) end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Memory)
end

/*==============================================================================================
	Section: Comparason Operators
	Purpose: Compare Values =D
	Creditors: Rusketh
==============================================================================================*/
for Name, Symbol in pairs({greater = ">", less = "<", eqgreater = ">=", eqless = ">=", negeq = "!=", eq = "=="}) do
	
	Compiler["Instr_" .. UpperStr(Name)] = function(self, InstA, InstB)
		local ValueA, TypeA = self:CompileInst(InstA)
		local ValueB, TypeB = self:CompileInst(InstB)
		
		local Operator, Return, Perf = self:GetOperator(Name, TypeA, TypeB)
		if !Operator then self:Error("comparason operator (%s) does not support '%s > %s'", Symbol, GetLongType(TypeA), GetLongType(TypeB)) end
		
		self:PushPerf(Perf)
		
		return self:Operator(Operator, Return, Perf, ValueA, ValueB)
	end
end

/*==============================================================================================
	Section: If Stamtment
	Purpose: If Condition Then Do This
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_IF(InstA, InstB, InstC)
	
	local Value, tValue = self:CompileInst(InstA) -- Condition
	local Operator, Return, aPerf = self:GetOperator("is", tValue)
	if !Operator or Return ~= "n" then self:Error("if stament conditions do not support '%s'", GetLongType(tValue)) end
	
	local Condition = self:Operator(Operator, Return, Perf, Value)
	
	self:PushScope()
	
	local Statments = self:CompileInst(InstB)
	
	self:PopScope()
	
	local Operator, Return, bPerf = self:GetOperator("if")
	
	self:PushPerf(aPerf + bPerf)
	
	if !InstC then -- No elseif or else statment
		return self:Operator(Operator, Retutrn, bPerf, Condition, Statments)
	end
	
	local Else = self:CompileInst(InstC)
	return self:Operator(Operator, Return, bPerf, Condition, Statments, Else)
end

/********************************************************************************************************************/

function Compiler:Instr_OR(InstA, InstB)
	-- Purpose: || conditonal Operator.
	
	local ValueA, TypeA = self:CompileInst(InstA)
	local ValueB, TypeB = self:CompileInst(InstB)
	local Operator, Return, Perf = self:GetOperator("or", TypeA, TypeB)
	
	if !Operator and TypeA == TypeB then -- Lets see if we can default this?	
	
		local _Operator, _Return, _Perf = self:GetOperator("is", TypeA)
		if _Operator then -- Yep we will do 'is(A) or is(B)'
			
			local Operator, Return, Perf = self:GetOperator("or", aReturn, aReturn)
			
			self:PushPerf(Perf + _Perf + _Perf)
			
			local TestA = self:Operator(_Operator, _Return, _Perf, ValueA)
			local TestB = self:Operator(_Operator, _Return, _Perf, ValueB)
			
			return self:Operator(Operator, Return, Perf, TestA, TestB)
		end
		
		self:Error("or operator (||) does not support '%s || %s'", GetLongType(TypeA), GetLongType(TypeB))
	end
	
	-- Ooh Supported Or operators, Fancy!
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, ValueA, ValueB)
end

function Compiler:Instr_AND(InstA, InstB)
	-- Purpose: && conditonal Operator.
	
	local ValueA, TypeA = self:CompileInst(InstA)
	local ValueB, TypeB = self:CompileInst(InstB)
	
	local aOperator, aReturn, aPerf = self:GetOperator("is", TypeA)
	local bOperator, bReturn, bPerf = self:GetOperator("is", TypeA)
	
	if aOperator and bOperator then
		local Operator, Return, Perf = self:GetOperator("and", aReturn, bReturn)
		
		if Operator then
			
			local TestA = self:Operator(aOperator, aReturn, aPerf, ValueA)
			local TestB = self:Operator(bOperator, bReturn, bPerf, ValueB)
			
			self:PushPerf(Perf + aPerf + bPerf)
			
			return self:Operator(Operator, Return, Perf, TestA, TestB)
		end
	end
	
	self:Error("and operator (&&) does not support '%s && %s'", GetLongType(TypeA), GetLongType(TypeB))
end

/*==============================================================================================
	Section: Value Prefixes
	Purpose: These handel stuff like Delta, not and Neg
	Creditors: Rusketh
==============================================================================================*/
for Name, Symbol in pairs({negative = "-", ["not"] = "!", lenth = "#"}) do
	
	Compiler["Instr_" .. UpperStr(Name)] = function(self, Inst)
		
		local Value, tValue = self:CompileInst(Inst)
		
		local Operator, Return, Perf = self:GetOperator(Name, tValue)
		if !Operator then self:Error("%s operator (%s) does not support '%s%s'", Name, Symbol, Symbol, GetLongType(tValue)) end
		
		self:PushPerf(Perf)
		
		return self:Operator(Operator, Return, Perf, Value)
	end
end

function Compiler:Instr_DELTA(Name)
	-- Purpose: $Variable
	
	local Memory, Type = self:GetVar(Name)
	if !Memory then self:Error("Variable %s does not exist", Name) end
	
	local Operator, Return, Perf = self:GetOperator("delta", Type)
	if !Operator then self:Error("delta operator ($) does not support " .. GetLongType(Type)) end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Memory)
end

/*==============================================================================================
	Section: Value Casting
	Purpose: Casting converts one type to another.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_CAST(Type, Inst)
	-- Purpose: (type) value casting
	
	local Value, tValue = self:CompileInst(Inst)
	local Operator, Return, Perf = self:GetOperator("cast", Type, tValue)
	
	if !Operator then self:Error("Can not cast from %s to %s", GetLongType(tValue), GetLongType(Type) ) end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Value)
end

/*==============================================================================================
	Section: Loops
	Purpose: for loops, while loops.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_LOOP_FOR(InstA, InstB, InstC, Stmts)
	-- Purpose: Runs a for loop.
	
	self:PushScope()
		
		local Variable, tVariable = self:CompileInst(InstA)
		local Condition, tCondition = self:CompileInst(InstB)
		
		local Operator, Return, Perf = self:GetOperator("is", tCondition)
		if !Operator or tCondition ~= "n" then self:Error("for loop conditions do not support '%s'", GetLongType(tCondition)) end
		
		local IsOperator = self:Operator(Operator, Return, Perf, Condition)
		
		local Step = self:CompileInst(InstC)
		local Statments = self:CompileInst(Stmts)
	
	self:PopScope()
	
	local Operator, Return, Perf = self:GetOperator("for")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Variable, IsOperator, Step, Statments)
end

function Compiler:Instr_LOOP_WHILE(Inst, Stmts)
	-- Purpose: Runs a while loop.
	
	self:PushScope()
		
		local Condition, tCondition = self:CompileInst(Inst)
		
		local Operator, Return, Perf = self:GetOperator("is", tCondition)
		if !Operator or tCondition ~= "n" then self:Error("for loop conditions do not support '%s'", GetLongType(tCondition)) end
		
		local IsOperator = self:Operator(Operator, Return, Perf, Condition)
		local Statments = self:CompileInst(Stmts)
		
	self:PopScope()	
		
	local Operator, Return, Perf = self:GetOperator("while")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, IsOperator, Statments)
end

function Compiler:Instr_LOOP_EACH(Var, Value, tValue, Stmts)
	
	local Variable, tVariable = self:CompileInst(Var)
	local ValueID = self:LocalVar(Value, tValue)
	
	self:PushScope()

		self:PushScope()
		
		local Statments = self:CompileInst(Stmts)
		
		self:PopScope()
		
	self:PopScope()
	
	local Operator, Return, Perf = self:GetOperator("foreach", tVariable, tValue)
	local vOperator = self:GetOperator("assign", tValue)
	
	if !Operator or !vOperator then
		self:Error("no such loop 'foreach(%s : %s)'", GetLongType(tValue), GetLongType(tVariable) )
	end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Variable, ValueID, vOperator, Statments)

end

function Compiler:Instr_LOOP_EACH2(Var, Key, tKey, Value, tValue, Stmts)
	
	local Variable, tVariable = self:CompileInst(Var)
	local ValueID = self:LocalVar(Value, tValue)
	local KeyID = self:LocalVar(Key, tKey)
	
	self:PushScope()

		self:PushScope()
		
		local Statments = self:CompileInst(Stmts)
		
		self:PopScope()
		
	self:PopScope()
	
	local Operator, Return, Perf = self:GetOperator("foreach", tVariable, tKey, tValue)
	local kOperator = self:GetOperator("assign", tKey)
	local vOperator = self:GetOperator("assign", tValue)
	
	if !Operator or !kOperator or !vOperator then
		self:Error("no such loop 'foreach(%s, %s : %s)'", GetLongType(tKey), GetLongType(tValue), GetLongType(tVariable) )
	end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Variable, KeyID, kOperator, ValueID, vOperator, Statments)
end

/********************************************************************************************************************/

function Compiler:Instr_BREAK(Depth)
	-- Purpose: Breaks a loop.
	
	return function(self) self:Throw("break", Depth or 0) end
end

function Compiler:Instr_CONTINUE(Depth)
	-- Purpose: Continues a loop.
	
	return function(self) self:Throw("continue", Depth or 0) end
end

/*==============================================================================================
	Section: Tables
	Purpose: Makes Tables.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_TABLE(InstK, InstV)
	-- Purpose: Creates a table.
	
	local Keys, Values = {}, {}
	
	for I = 1, #InstV do
		Values[I] = self:CompileInst(InstV[I])
		local Key = InstK[I]
		
		if Key then -- Adds a key!
			local Value, tValue = self:CompileInst(Key)
			Keys[I] = Value
			
			if tValue ~= "n" and tValue ~= "s" and tValue ~= "e" then
				self:Error("%s is not a valid table index", GetLongType(tValue))
			end
		end
	end
	
	local Operator, Return, Perf = self:GetOperator("table")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Keys, Values)
end

function Compiler:Instr_GET(InstA, InstB, Type)
	-- Purpose: [K,Y] Index Operator
	
	local Variable, tVariable = self:CompileInst(InstA)
	local Key, tKey = self:CompileInst(InstB)
	local Operator, Return, Perf
	
	if Type then
		Operator, Return, Perf = self:GetOperator("get", tVariable, tKey, Type)
		if !Operator then self:Error("%s does not support index operator ([%s, %s])", GetLongType(tVariable), GetLongType(tKey), GetLongType(Type)) end
	else
		Operator, Return, Perf = self:GetOperator("get", tVariable, tKey)
		if !Operator then self:Error("%s does not support index operator ([%s])", GetLongType(tVariable), GetLongType(tKey)) end
	end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Variable, Key)
end

function Compiler:Instr_SET(InstA, InstB, InstC, Type)
	-- Purpose: [K,Y] Index Operator
	
	local Variable, tVariable = self:CompileInst(InstA)
	local Key, tKey = self:CompileInst(InstB)
	local Value, tValue = self:CompileInst(InstC)
	
	if Type and Type ~= tValue then
		self:Error("%s can not be set to a %s index", GetLongType(tValue), GetLongType(Type))
	end
	
	local Operator, Return, Perf = self:GetOperator("set", tVariable, tKey, tValue)
	if !Operator then self:Error("%s does not support assignment index operator ([%s, %s])", GetLongType(tVariable), GetLongType(tKey), GetLongType(tValue)) end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Variable, Key, Value)
end

/*==============================================================================================
	Section: Inbuilt Functions and Methods
	Purpose: These function are built in =D
	Creditors: Rusketh
==============================================================================================*/
function Compiler:GenerateArguments(Insts, Method)
	-- Purpose: Compiles function arguments.
	
	local Total = #Insts
	if Total != 0 then
		local Value, Sig = self:CompileInst(Insts[1])
		local Values = {Value} 
		
		if Method then Sig = Sig .. ":" end
		
		for I = 2, Total do
			local Value, tValue = self:CompileInst(Insts[I])
			
			--Todo: Prevent nil values!
			
			Values[I] = Value
			Sig = Sig .. tValue
		end
		
		return Values, Sig
	end
	
	return {}, ""
end

/********************************************************************************************************************/

function Compiler:CallFunction(Name, Operators, Sig)
	-- Purpose: Finds and calls a function!
	-- Todo: VarArg support!
	
	local Function = E_A.FunctionTable[Name .. "(" .. Sig .. ")"]
	
	if !Function then -- Lets look for a supporting vararg function!
		local Functions, Sig = E_A.FunctionTable, Sig -- Speed!, Copy the signature!
		
		for I = #Operators, 1, -1 do
			if Sig[#Sig] == ":" then
				break -- Hit the meta peramater, abort!
			else
				Sig = SubStr(Sig, 1, #Sig - #Operators[I][2])
				Function = Functions[Name .. "(" .. Sig .. "...)"]
				if Function then break end
			end
		end
	end
	
	if !Function then self:Error("No such function %s(%s)", Name, Sig) end
	
	self:PushPerf(Function[3] or 0)
	
	return self:Operator(Function[1], Function[2], Function[3], unpack(Operators))
end

function Compiler:Instr_FUNCTION(Name, Insts)
	-- Purpose: Finds and calls a function.
	
	local VarID, Type = self:GetVar(Name)
	
	if VarID then -- User Function needs to use Call Operator.
		return self:CallLambada(Name, VarID, Insts)
	end
	
	local Operators, Sig = self:GenerateArguments(Insts)
	return self:CallFunction(Name, Operators, Sig)
end

function Compiler:Instr_METHOD(Name, Insts)
	-- Purpose: Finds and calls a function.
	
	local Operators, Sig = self:GenerateArguments(Insts, true)
	return self:CallFunction(Name, Operators, Sig)
end



/*==============================================================================================
	Section: Lambada Functions.
	Purpose: Function Objects, just 20% cooler!
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_FUNCVAR(Name)
	-- Purpose: Grabe a function var.
	
	local VarID, Type = self:GetVar(Name)
	if !VarID then self:Error("function %s does not exist", Name) end
	if Type ~= "f" then self:Error("Impossible Error: variable %s is not a function.", Name) end
	
	local Operator, Return, Perf = self:GetOperator("funcvar", Type)
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, VarID)
end

function Compiler:Instr_FUNCASS(Global, Name, Inst)
	-- Purpose: Grabe a function var.
	
	local Function, tFunction = self:CompileInst(Insts[I])
	if tFunction ~= "f" then self:Error("Can not assign %q as 'function'", GetLongType(tFunction)) end
	
	local VarID, Scope
	
	if Global then
		VarID, Scope = self:SetVar(Name, "f")
	else
		VarID, Scope = self:LocalVar(Name, "f")
	end
	
	local Operator, Return, Perf = self:GetOperator("funcass", "f")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Function, VarID)
end

/***********************************************************************************************/

function Compiler:BuildFunction(Sig, Params, tParams, Stmts, Return)
	-- Purpose: This instruction Will create function variabels.
	
	self:PushReturnType(Return)
	
	self:PushScope()
		
		local Arguments = {}
		for I = 1, #Params do
			local Name = Params[I]
			local Type = tParams[Name]
			
			local Operator = E_A.OperatorTable["assign(" .. Type .. ")"]
			if !Operator then self:Error("type %s, can not be used in function parameters.", Type) end
			
			local VarID, Scope = self:LocalVar(Name, Type)
			
			Arguments[I] = function(self, Value)
				local Val, tVal = Value(self)
				
				if tVal ~= Type and Type ~= "?" then
					self:Throw("invoke", "Peramater missmatch #" .. I .. " " .. GetLongType(Type) .. " exspected got " .. GetLongType(tVal))
				end
				
				Operator[1](self, function() return Val, tVal end, VarID)
			end
		end
		
	
		self:PushScope()
		
			local Statments = self:CompileInst(Stmts)
		
		self:PopScope()
		
	self:PopScope()
	
	self:PopReturnType()
	
	return Arguments, Statments
end

function Compiler:Instr_LAMBADA(Sig, Params, tParams, Stmts, Return)
	local Arguments, Statments = self:BuildFunction(Sig, Params, tParams, Stmts, Return)
	
	local Operator, _Return, Perf = self:GetOperator("lambada")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, _Return, Perf, Sig, Arguments, Statments, Return)
end

/*==============================================================================================
	Section: Call Operator.
==============================================================================================*/
function Compiler:Instr_CALL(Inst, Insts)
	
	local Value, tValue = self:CompileInst(Inst)
	
	local Operator, Return, Perf = self:GetOperator("call", tValue)
	if !Operator then self:Error("Type %q can not be called" ,GetLongType(tValue)) end
	
	local Operators, Sig = self:GenerateArguments(Insts)
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Value, Sig, Operators)
end

function Compiler:CallLambada(Name, VarID, Insts)
	
	-- GET FROM MEMORY.
	
		local Operator, Return, Perf = self:GetOperator("funcvar", "f")
		
		self:PushPerf(Perf)
		
		local Lambada = self:Operator(Operator, Return, Perf, VarID)
	
	-- CALL.
	
		local Operator, Return, Perf = self:GetOperator("call", Return)
		
		local Operators, Sig = self:GenerateArguments(Insts)
		
		self:PushPerf(Perf)
		
	return self:Operator(Operator, Return, Perf, Lambada, Sig, Operators)
end

/*==============================================================================================
	Section: Return Operator.
==============================================================================================*/
function Compiler:Instr_RETURN(Inst)
	local Return, Value = self.ReturnTypes[#self.ReturnTypes]
	
	if Inst then
		Value, tValue = self:CompileInst(Inst)
	
		if !Return then
			self:Error("Unable to return '%s', function return type is 'void'", GetLongType(tValue))
		elseif Return != tValue and Return ~= "?" then
			self:Error("Unable to return '%s', function return type is '%s'", GetLongType(tValue), GetLongType(Return))
		end
		
	elseif Return then
		self:Error("Unable to return 'void', function return type is '%s'", GetLongType(Return))
	end
	
	local Operator, _R, Perf = self:GetOperator("return")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Value)
end

/*==============================================================================================
	Section: Events
	Purpose: Events do stuff.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_EVENT(Name, Sig, Params, tParams, Stmts, Return)
	-- Purpose: This instruction Will create function variabels.
	
	local Arguments, Statments = self:BuildFunction(Sig, Params, tParams, Stmts, Return)
	
	local Operator, _Return, Perf = self:GetOperator("event")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Name, Arguments, Statments)
end

/*==============================================================================================
	Section: Try / Catch
	Purpose: Catchs exceptions.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_TRY(Stmts, Inst)
	-- Purpose: Its like pcall for EA.
	
	local Statments = self:CompileInst(Stmts)
	local Catch = self:CompileInst(Inst)
	
	local Operator, Return, Perf = self:GetOperator("try")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Statments, Catch)
end

function Compiler:Instr_CATCH(Exceptions, Stmts, Inst)
	-- Purpose: Catches exceptions.
	
	local Statments = self:CompileInst(Stmts)
	local Catch
	
	if Inst then Catch = self:CompileInst(Inst) end
	
	local Operator, Return, Perf = self:GetOperator("catch")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Exceptions, Statments, Catch)
end
