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
local InsertTbl = table.insert -- Speed

local LimitString = E_A.LimitString
local GetLongType = E_A.GetLongType
local GetShortType = E_A.GetShortType

/*==============================================================================================
	Util Functions
==============================================================================================*/
local function UpcaseStr(Str)
	-- Purpose: Makes the first letter uppercase the rest will be lowercased.
	
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
	self.IOPorts = { }
	
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

function Compiler:LuaError(Message, Info, ...)
	debug.Trace()
	if Info then Message = FormatStr(Message, Info, ...) end
	error( "LUA: " .. Message, 0)
end

/*==============================================================================================
	Section: Instruction Conversion
	Purpose: Functions to find instructions and convert them to operators.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:CompileInst(Inst)
	-- Purpose: Compiles an instruction.
	
	if !Inst then
		self:LuaError("Invalid instruction (type %s).", type( Inst ) )
	end
	
	local IName, ITrace = Inst[1], Inst[2]
	
	if !IName then
		self:LuaError("Invalid instruction (no name)." )
	elseif !ITrace then
		self:LuaError("Invalid instruction %s (no trace).", IName )
	end
	
	local Func = self["Instr_" .. UpperStr(IName)]
	
	if !Func then
		self:LuaError("Invalid instruction %s (unrecognised).", IName )
	end
	
	local Trace = self.Trace
	self.Trace = ITrace
	ITrace[3] = IName
	
	local Result, Type = Func(self, unpack(Inst[3]))
	
	self.Trace = Trace
	
	return Result, Type
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
	
	local Type = GetShortType(Type)
	local Operator = { [0] = (Perf or 0), Op, Type, {...}, Trace }
	self:InsertTrace( Operator )
	--Trace[4] = Operator
	
	return setmetatable(Operator, E_A.Operator), Type
end

function Compiler:InsertTrace( Operator )
	Operator[4] = self.Trace
	self.Trace[4] = Operator
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
	Purpose: Handel's the levels at witch Variables run.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:InitScopes()
	-- Purpose: Creates the initial scope environments.
	
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
	
	Type = GetShortType(Type)
	
	local Cur = self.Scope[Name]
	if Cur then
		local CType = self.VarTypes[Cur]
		if CType != Type then -- Check to see if this value exists?
			self:Error("Variable %s already exists as %s, and can not be assigned to %s", Name, GetLongType(CType), GetLongType(Type))
		else
			return Cur -- Return the existing Var Index
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
	self.VarIndex = VarID -- We move up in memory.
	
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

function Compiler:AssignVar(Type, Name, Special, AssignType)
	-- Purpose: Handel's variable assignments properly and sorts special cases.
	
	AssignType = AssignType or "varaible"
	
	if !Special or Special == "local" then
		return self:LocalVar(Name, Type)
		
	elseif Special == "global" then
		local Cell = self.GlobalScope[Name]
		
		if !Cell then
			local VarID = self.VarIndex + 1
			self.VarIndex = VarID
			
			if self.Scope[Name] then
				self:Error("%s %s can not redefine existing %s.", Special, Name, AssignType)
			end
			
			self.Scope[Name] = VarID
			self.VarTypes[VarID] = Type
			self.GlobalScope[Name] = VarID
			
			return VarID, self.ScopeID
		elseif self.VarTypes[Cell] != Type then
			self:Error("%s %s already exists as %s, and can not be assigned to %s", AssignType, Name, GetLongType(self.VarTypes[Cell]), GetLongType(Type))
		elseif self.Scope[Name] and self.Scope[Name] ~= Cell then
			self:Error("%s %s can not redefine existing %s.", Special, Name, AssignType)
		else
			self.Scope[Name] = Cell
			return Cell, self.ScopeID
		end
		
	elseif Special == "input" or Special == "output" then
		local Cell = self.IOPorts[Name]
		
		if !Cell then -- Create New!
			local VarID = self.VarIndex + 1
			self.VarIndex = VarID
			
			if self.Scope[Name] then
				self:Error("%s %s can not redefine existing %s.", Special, Name, AssignType)
			elseif Special == "input" then
				self.Inputs[VarID] = Name
			elseif Special == "output" then
				self.Outputs[VarID] = Name
			end
			
			self.Scope[Name] = VarID
			self.IOPorts[Name] = VarID
			self.VarTypes[VarID] = Type
			
			return VarID, self.ScopeID
			
		elseif Special == "input" and self.Outputs[Cell] then
			self:Error("%s %s already exists as output, therefore can not be declared as %s", AssignType, Name, Special)
		elseif Special == "output" and self.Inputs[Cell] then
			self:Error("%s %s already exists as input, therefore can not be declared as %s", AssignType, Name, Special)
		elseif self.VarTypes[Cell] != Type then
			self:Error("%s %s already exists as %s, and can not be assigned to %s", AssignType, Name, GetLongType(self.VarTypes[Cell]), GetLongType(Type))
		elseif self.Scope[Name] and self.Scope[Name] ~= Cell then
			self:Error("%s %s can not redefine existing %s.", Special, Name, AssignType)
		else
			self.Scope[Name] = Cell
			return Cell, self.ScopeID
		end
	else
		local VarID, Scope = self:SetVar(Name, Type)
		return VarID, Scope
	end
end

/*==============================================================================================
	Section: Sequence Instructions
	Purpose: Runs a sequence
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_SEQUENCE(Smts)
	local Statements = {}
	
	for I = 1, #Smts do
		Statements[I] = self:CompileInst(Smts[I])
	end
	
	local Operator, Return = self:GetOperator("sequence")
	return self:Operator(Operator, Return, 0, Statements, #Statements)
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
	Section: Assignment Operators
	Purpose: Assigns Values to Variables
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_ASSIGN_DEFAULT(Name, Type, Special)
	-- Purpose: Initalise a variable and assigns default if required.
	
	local Operator, Return, Perf = self:GetOperator("assign", Type)
	if !Operator then self:Error("Can not initalise Variable %s of %s", Name, GetLongType(Type)) end
	
	local VarID, Scope = self:AssignVar(Type, Name, Special) -- Create the Var
	if self.Inputs[VarID] then return self:Operator(function() end) end
	
	local Default = E_A.TypeShorts[Type][3]
	if !Default then self:Error("Can not initalise Variable %s of %s", Name, GetLongType(Type)) end
	
	local DefaultAsOp = self:Operator(Default, Type, 0)
	
	self:PushPerf(Perf)
	
	return self:Operator( function(self)
			if self.Memory[VarID] == nil then Operator(self, DefaultAsOp, VarID) end
		end, Return, Perf) -- Its simple, If it doesnt exist create it.
end

/********************************************************************************************************************/

function Compiler:Instr_ASSIGN_DECLARE(Name, Expr, Type, Special)
	-- Purpose: Declares a value
	
	local Operator, Return, Perf = self:GetOperator("assign", Type)
	if !Operator then self:Error("Assignment operator (=) does not support '%s'", GetLongType(Type)) end
	
	local Value, tValue = self:CompileInst(Expr, true)
	
	if tValue ~= Type or tValue == "***" then
		if tValue == "?" then
			local Operator, Return, Perf = self:GetOperator("cast", Type, "?")
			
			if !Operator then
				self:Error("Variable of type variant must be casted before assigning to %s", GetLongType(Type))
			end
			
			Value = self:Operator(Operator, Return, Perf, Value)
			
			self:PushPerf(Perf)
		else
			self:Error("Variable %s of type %s, can not be assigned as '%s'", Name, GetLongType(Type), GetLongType(tValue))
		end
	end
	
	local VarID, Scope = self:AssignVar(Type, Name, Special)
	
	if self.Inputs[VarID] then -- Note: You can not assign an input!
		self:Error("Assignment operator (=) does not support input Variables")
	end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Value, VarID)
end

/********************************************************************************************************************/

function Compiler:Instr_ASSIGN(Name, Expr)
	-- Purpose: Assign value.
	
	local VarID, Type = self:GetVar(Name)
	if !VarID then self:Error("variable %s does not exist", Name) end
	
	if self.Inputs[VarID] then -- Note: You can not assign an input!
		self:Error("Assignment operator (=) does not support input Variables")
	end
	
	local Operator, Return, Perf = self:GetOperator("assign", Type)
	
	if !Operator then
		self:Error("Assignment operator (=) does not support '%s'", GetLongType(Type))
	end
	
	local Value, tValue = self:CompileInst(Expr)
	
	if tValue ~= Type or tValue == "***" then
		if tValue == "?" then
			local Operator, Return, Perf = self:GetOperator("cast", Type, "?")
			
			if !Operator then
				self:Error("Variable of type variant must be casted before assigning to %s", GetLongType(Type))
			end
			
			Value = self:Operator(Operator, Return, Perf, Value)
			
			self:PushPerf(Perf)
		else
			self:Error("Variable %s of type %s, can not be assigned as '%s'", Name, GetLongType(Type), GetLongType(tValue))
		end
	end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Value, VarID)
end

/********************************************************************************************************************/

function Compiler:Instr_VARIABLE(Name)
	-- Purpose: Retrieve variable.
	
	local VarID, Type = self:GetVar(Name)
	if !VarID then self:Error("variable %s does not exist", Name) end
	
	local Operator, Return = self:GetOperator("variable", Type)
	if !Operator then self:Error("Improbable Error: variable operator does not support '%s'", Type) end
	
	self:PushPerf(EA_COST_CHEAP)
	
	return self:Operator(Operator, Return, EA_COST_CHEAP, VarID)
end

/*==============================================================================================
	Section: Mathematical Operators
	Purpose: Does math stuffs?
	Creditors: Rusketh
==============================================================================================*/
for Name, Symbol in pairs({exponent = "^", multiply = "*", division = "/", modulus = "%", addition = "+", subtraction = "-",
binary_shift_right = ">>", binary_shift_left = "<<", binary_xor = "^^", binary_and = "&&", binary_or = "||"}) do

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

function Compiler:Instr_INCREMENT(Name)
	-- Purpose: ++ Math Operator.
	
	local Memory, Type = self:GetVar(Name)
	if !Memory then self:Error("Variable %s does not exist", Name) end
	
	if self.Inputs[Memory] then self:Error("increment operator (--) will not accept input %s", Name) end
	
	local Operator, Return, Perf = self:GetOperator("increment", Type)
	if !Operator then self:Error("increment operator (++) does not support '%s++'", GetLongType(Type)) end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Memory)
end

function Compiler:Instr_DECREMENT(Name)
	-- Purpose: -- Math Operator.
	
	local Memory, Type = self:GetVar(Name)
	if !Memory then self:Error("Variable %s does not exist", Name) end
	
	if self.Inputs[Memory] then self:Error("decrement operator (--) will not accept input %s", Name) end
	
	local Operator, Return, Perf = self:GetOperator("decrement", Type)
	if !Operator then self:Error("decrement operator (--) does not support '%s++'", Type) end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Memory)
end

/********************************************************************************************************************/

function Compiler:Instr_CND(InstA, InstB, InstC)
	-- Purpose: ? Comparason Operator.
	
	local ValueA, TypeA = self:CompileInst(InstA)
	local ValueB, TypeB = self:CompileInst(InstB)
	local ValueC, TypeC = self:CompileInst(InstC)
	
	local Is, IsR, IsP = self:GetOperator("is", TypeA)
	
	if !Is or TypeB ~= TypeC then 
		self:Error("conditonal does not support '%s ? %s , %s'", GetLongType(TypeA), GetLongType(TypeB), GetLongType(TypeC) )
	end
	
	local Operator, Return, Perf = self:GetOperator("cnd")
	
	self:PushPerf(Perf + IsP)
	
	return self:Operator(Operator, TypeB, Perf, self:Operator(Is, IsR, IsP, ValueA), ValueB, ValueC)
end

/*==============================================================================================
	Section: Comparison Operators
	Purpose: Compare Values =D
	Creditors: Rusketh
==============================================================================================*/
for Name, Symbol in pairs({greater = ">", less = "<", eqgreater = ">=", eqless = ">=", negeq = "!=", eq = "=="}) do
	
	Compiler["Instr_" .. UpperStr(Name)] = function(self, InstA, InstB)
		local ValueA, TypeA = self:CompileInst(InstA)
		local ValueB, TypeB = self:CompileInst(InstB)
		
		local Operator, Return, Perf = self:GetOperator(Name, TypeA, TypeB)
		if !Operator then self:Error("Comparison operator (%s) does not support '%s > %s'", Symbol, GetLongType(TypeA), GetLongType(TypeB)) end
		
		self:PushPerf(Perf)
		
		return self:Operator(Operator, Return, Perf, ValueA, ValueB)
	end
end

/*==============================================================================================
	Section: If Statement
	Purpose: If Condition Then Do This
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_IF(InstA, InstB, InstC)
	
	local Value, tValue = self:CompileInst(InstA) -- Condition
	local Operator, Return, aPerf = self:GetOperator("is", tValue)
	if !Operator or Return ~= "n" then self:Error("if statement conditions do not support '%s'", GetLongType(tValue)) end
	
	local Condition = self:Operator(Operator, Return, Perf, Value)
	
	self:PushScope()
	
	local Statements = self:CompileInst(InstB)
	
	self:PopScope()
	
	local Operator, Return, bPerf = self:GetOperator("if")
	
	self:PushPerf(aPerf + bPerf)
	
	if !InstC then -- No elseif or else statement
		return self:Operator(Operator, Retutrn, bPerf, Condition, Statements)
	end
	
	local Else = self:CompileInst(InstC)
	return self:Operator(Operator, Return, bPerf, Condition, Statements, Else)
end

/********************************************************************************************************************/

function Compiler:Instr_OR(InstA, InstB)
	-- Purpose: || Conditional Operator.
	
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
	-- Purpose: && Conditional Operator.
	
	local ValueA, TypeA = self:CompileInst(InstA)
	local ValueB, TypeB = self:CompileInst(InstB)
	
	local aOperator, aReturn, aPerf = self:GetOperator("is", TypeA)
	local bOperator, bReturn, bPerf = self:GetOperator("is", TypeB)
	
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
	Purpose: These handle stuff like Delta, not and Neg
	Creditors: Rusketh
==============================================================================================*/
for Name, Symbol in pairs({negative = "-", ["not"] = "!", length = "#"}) do
	
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
	if !Operator then self:Error("Delta operator ($) does not support " .. GetLongType(Type)) end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Memory)
end

function Compiler:Instr_TRIGGER(Name)
	-- Purpose: $Variable
	
	local Memory, Type = self:GetVar(Name)
	if !Memory then self:Error("Variable %s does not exist", Name) end
	
	local Operator, Return, Perf = self:GetOperator("trigger", Type)
	if !Operator then self:Error("Trigger operator (~) does not support " .. GetLongType(Type)) end
	
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
	
	if !Operator then
		self:Error("Can not cast from %s to %s", GetLongType(tValue), GetLongType(Type) )
	end
	
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
		local Statements = self:CompileInst(Stmts)
	
	self:PopScope()
	
	local Operator, Return, Perf = self:GetOperator("for")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Variable, IsOperator, Step, Statements)
end

function Compiler:Instr_LOOP_WHILE(Inst, Stmts)
	-- Purpose: Runs a while loop.
	
	self:PushScope()
		
		local Condition, tCondition = self:CompileInst(Inst)
		
		local Operator, Return, Perf = self:GetOperator("is", tCondition)
		if !Operator or tCondition ~= "n" then self:Error("for loop conditions do not support '%s'", GetLongType(tCondition)) end
		
		local IsOperator = self:Operator(Operator, Return, Perf, Condition)
		local Statements = self:CompileInst(Stmts)
		
	self:PopScope()	
		
	local Operator, Return, Perf = self:GetOperator("while")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, IsOperator, Statements)
end

function Compiler:Instr_LOOP_EACH(Var, Value, tValue, Stmts)
	
	local Variable, tVariable = self:CompileInst(Var)
	local ValueID = self:LocalVar(Value, tValue)
	
	self:PushScope()

		self:PushScope()
		
		local Statements = self:CompileInst(Stmts)
		
		self:PopScope()
		
	self:PopScope()
	
	local Operator, Return, Perf = self:GetOperator("foreach", tVariable, tValue)
	local vOperator = self:GetOperator("assign", tValue)
	
	if !Operator or !vOperator then
		self:Error("no such loop 'foreach(%s : %s)'", GetLongType(tValue), GetLongType(tVariable) )
	end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Variable, ValueID, vOperator, Statements)

end

function Compiler:Instr_LOOP_EACH2(Var, Key, tKey, Value, tValue, Stmts)
	
	local Variable, tVariable = self:CompileInst(Var)
	local ValueID = self:LocalVar(Value, tValue)
	local KeyID = self:LocalVar(Key, tKey)
	
	self:PushScope()

		self:PushScope()
		
		local Statements = self:CompileInst(Stmts)
		
		self:PopScope()
		
	self:PopScope()
	
	local Operator, Return, Perf = self:GetOperator("foreach", tVariable, tKey, tValue)
	local kOperator = self:GetOperator("assign", tKey)
	local vOperator = self:GetOperator("assign", tValue)
	
	if !Operator or !kOperator or !vOperator then
		self:Error("no such loop 'foreach(%s, %s : %s)'", GetLongType(tKey), GetLongType(tValue), GetLongType(tVariable) )
	end
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Variable, KeyID, kOperator, ValueID, vOperator, Statements)
end

/********************************************************************************************************************/

function Compiler:Instr_BREAK(Depth)
	local Operator, Return, Perf = self:GetOperator("break")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Depth or 0)
end

function Compiler:Instr_CONTINUE(Depth)
	local Operator, Return, Perf = self:GetOperator("continue")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Depth or 0)
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
		local Value, tValue = self:CompileInst(InstV[I])
		local Key = InstK[I]; Values[I] = Value
		
		if Key then -- Adds a key!
			local vKey, tKey = self:CompileInst(Key)
			Keys[I] = vKey
			
			if tKey ~= "n" and tKey ~= "s" and tKey ~= "e" then
				self:Error("%s is not a valid table index", GetLongType(tValue))
			elseif tValue == "***" then
				self:Error("can not set index for varargs (...)")
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
		local Values, Sig = { }, ""
		
		for I = 1, Total do
			local Value, tValue = self:CompileInst(Insts[I])
			
			if !tValue or tValue == "" then
				self:Error("argument #" .. I .. " is void")
			else
				Values[I] = Value
			end
			
			if I == 1 and Method then
				Sig = tValue .. ":"
			else
				Sig = Sig .. tValue
			end
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
				break -- Hit the meta parameter, abort!
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
	Section: LambdaFunctions.
	Purpose: Function Objects, just 20% cooler!
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_FUNCASS(Case, Name, Inst)
	--Purpose: define a function var.
	
	local Function, tFunction = self:CompileInst(Inst)
	
	if tFunction == "?" then
		local Operator, Return, Perf = self:GetOperator("cast", "f", tFunction)
		
		if !Operator then
			self:Error("Can not assign %q as 'function'", GetLongType(tFunction))
		end
	
		self:PushPerf(Perf)
	
		Function = self:Operator(Operator, Return, Perf, Function)
		
	elseif tFunction ~= "f" then
		self:Error("Can not assign %q as 'function'", GetLongType(tFunction))
	end
	
	local VarID, Scope = self:AssignVar("f", Name, Case, "function")
	
	local Operator, Return, Perf = self:GetOperator("funcass", "f")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Function, VarID)
end


function Compiler:Instr_FUNCVAR(Name)
	-- Purpose: Grab a function var.

	local VarID, Type = self:GetVar(Name)
	if !VarID then self:Error("function %s does not exist", Name) end
	if Type ~= "f" then self:Error("Impossible Error: variable %s is not a function.", Name) end

	local Operator, Return, Perf = self:GetOperator("funcvar", Type)

	self:PushPerf(Perf)

	return self:Operator(Operator, Return, Perf, VarID)
end

-- THE OLD CODE
-- function Compiler:Instr_FUNCASS(Global, Name, Inst)
	--Purpose: Grab a function var.

	-- local Function, tFunction = self:CompileInst(Inst)
	-- if tFunction ~= "f" then self:Error("Can not assign %q as 'function'", GetLongType(tFunction)) end

	-- local VarID, Scope

	-- if Global then
		-- VarID, Scope = self:SetVar(Name, "f") -- Todo: Actualy make this global instead of upscopped! (What i tried above).
	-- else
		-- VarID, Scope = self:LocalVar(Name, "f")
	-- end

	-- local Operator, Return, Perf = self:GetOperator("funcass", "f")

	-- self:PushPerf(Perf)

	-- return self:Operator(Operator, Return, Perf, Function, VarID)
-- end

/***********************************************************************************************/

function Compiler:BuildFunction(Sig, Params, Types, Stmts, Return)
	-- Purpose: This instruction Will create function variables.
	
	self:PushReturnType(Return)
	
	self:PushScope()
	
		local FuncParams = { }
		local TotalParams = #Params
		if TotalParams > 0 then
		
			for I = 1, TotalParams do
				
				local ArgName = Params[I]
				local ArgType = Types[ArgName]
				
				if ArgType ~= "***" then
					
					local VarID, Scope = self:LocalVar(ArgName, ArgType)
					local Operator = E_A.OperatorTable["assign(" .. ArgType .. ")"]
					
					if ArgType == "f" then
						Operator = E_A.OperatorTable["funcass(f)"]
					elseif !Operator then
						self:Error("type %s, can not be used in function parameters.", ArgType)
					end
					
						FuncParams[I] = function(self, Values)
							
							if !Values[I] then
								self:Throw("invoke", "Parameter mismatch #" .. I .. " " .. GetLongType(ArgType) .. " expected got void")
							end
							
							local Value, Type = Values[I](self)
							
							if Type == "***" then
								local Total = #Value
								if Total == 0 then
									FuncParams[I + 1](self, Values)
								else
									Values[I] = Value[1]
									
									if Total > 1 then
										for J = 2, Total do InsertTbl(Values, Value[J]) end
									end
									
									FuncParams[I](self, Values) -- Vararg replaced with vararg values, Reload from the varargs location.
								end
								
							elseif ArgType ~= Type and ArgType ~= "?" then
								self:Throw("invoke", "Parameter mismatch #" .. I .. " " .. GetLongType(ArgType) .. " expected got " .. GetLongType(Type))
							else
								Operator[1](self, function() return Value, Type end, VarID)
								FuncParams[I + 1](self, Values)
							end
						end
				else
					local VarID, Scope = self:LocalVar("...", "***")
					
						FuncParams[I] = function(self, Values)
							local VArgs = { }
							
							for K = I, #Values do
								local Value, Type = Values[K](self)
								if Type ~= "***" then
									VArgs[#VArgs + 1] = function() return Value, Type end
								else
									for I = 1, #Value do
										VArgs[#VArgs + 1] = Value[I]
									end
								end
							end
							
							self.Memory[VarID] = VArgs
							
							FuncParams[I + 1](self, Values)
						end
				end
			end
			
		end
	
		FuncParams[TotalParams + 1] = function(self, Values)
		end -- Just an empty function.
		
		self:PushScope()
		
			local Statements = self:CompileInst(Stmts)
		
		self:PopScope()
		
	self:PopScope()
	
	self:PopReturnType()
	
	return FuncParams[1], Statements
end

function Compiler:Instr_LAMBDA(Sig, Params, tParams, Stmts, Return)
	local Arguments, Statements = self:BuildFunction(Sig, Params, tParams, Stmts, Return)
	
	local Operator, _Return, Perf = self:GetOperator("lambda")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, _Return, Perf, Sig, Arguments, Statements, Return)
end

function Compiler:Instr_VARARGS()
	local VarID, Scope = self:GetVar("...")
	if !VarID then self:Error( "varargs (...) can not be used outside of vararg functions" ) end
	
	local Operator = function(self) return self.Memory[VarID] end
	return self:Operator(Operator , "***", EA_COST_NORMAL)
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
		
		local Lambda= self:Operator(Operator, Return, Perf, VarID)
	
	-- CALL.
	
		local Operator, Return, Perf = self:GetOperator("call", Return)
		
		local Operators, Sig = self:GenerateArguments(Insts)
		
		self:PushPerf(Perf)
		
	return self:Operator(Operator, Return, Perf, Lambda, Sig, Operators)
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
		local Default = E_A.TypeShorts[Return][3]
		if !Default then
			self:Error("Unable to return 'void', function return type is '%s'", GetLongType(Return))
		else
			Value = Default -- Default return value!
		end
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
function Compiler:Instr_EVENT(Name, Sig, Params, tParams, Stmts, Return, EventPerf)
	-- Purpose: This instruction Will create function variables.
	
	local Arguments, Statements = self:BuildFunction(Sig, Params, tParams, Stmts, Return)
	
	local Operator, _Return, Perf = self:GetOperator("event")
	
	Perf = Perf + EventPerf
	 
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Name, Arguments, Statements)
end

/*==============================================================================================
	Section: Try / Catch
	Purpose: Catches exceptions.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_TRY(Stmts, Inst)
	-- Purpose: Its like pcall for EA.
	
	local Statements = self:CompileInst(Stmts)
	local Catch = self:CompileInst(Inst)
	
	local Operator, Return, Perf = self:GetOperator("try")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Statements, Catch)
end

function Compiler:Instr_CATCH(Exceptions, Var, Stmts, Inst)
	-- Purpose: Catches exceptions.
	
	local VarID, Scope, Catch = self:LocalVar(Var, "!")
	
	local Statements = self:CompileInst(Stmts)
	
	if Inst then Catch = self:CompileInst(Inst) end
	
	local Operator, Return, Perf = self:GetOperator("catch")
	
	self:PushPerf(Perf)
	
	return self:Operator(Operator, Return, Perf, Exceptions, VarID, Statements, Catch)
end
