/*==============================================================================================
	Expression Advanced: Lemon Gate Compiler.
	Purpose: Converts Instructions To Operators!
	Creditors: Rusketh
==============================================================================================*/

local E_A = LemonGate

local Compiler = E_A.Compiler
Compiler.__index = Compiler

local Operators = E_A.OperatorTable
local Functions = E_A.FunctionTable
local TypeShorts = E_A.TypeShorts
local Types = E_A.TypeTable

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
	self.Trace = {1, 1}
	
	return self:CompileInst(Instr), self
end

function Compiler:Error(Message, Info, ...)
	-- Purpose: Create and push a syntax error.
	
	if Info then Message = FormatStr(Message, Info, ...) end
	error( FormatStr(Message .. " at line %i, char %i", self.Trace[1] or 0, self.Trace[2] or 0), 0)
end

function Compiler:CompileInst(Inst, Castable)
	-- Purpose: Compiles an instuction.

	local Func = self["Instr_" .. UpperStr(Inst[1])]
	
	if Func then
		local Trace = self.Trace -- Trace of parent operator
		self.Trace = Inst[2] -- Trace for child Operator
		
		local Result, Type = Func(self, unpack(Inst[3]))
		self.Trace = Trace -- Return parent trace.
		
		-- if Type and Type == "?" and !Castable then
			-- self:Error(Trace, "casting operator ((type)), expected before '%s'", Inst[1])
		-- end
		
		return Result
	else
		self:Error("Compiler: Uknown Instruction '%s'", Inst[1])
	end
end

/*==============================================================================================
	Section: Instruction Operators
	Purpose: Runable operators.
	Creditors: Rusketh
==============================================================================================*/
local Operator = E_A.Operator

function Compiler:Operation(Op, Type, ...)
	-- Purpose: Creates an operation.
	
	if !Op then debug.Trace(); self:Error("Internal Error: missing operator function") end
	if !Type or Type == "" then Type = "void" end -- Nicer then nil!
	
	return setmetatable({Op, GetShortType(Type), {...}, self.Trace}, Operator), Type
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
	
	print("Built Local Var: ", Name, VarID, Type)
	return VarID, self.ScopeID
end

function Compiler:SetVar(Name, Type, NoError)
	Type = GetShortType(Type)
	
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

function Compiler:GetVar(Name)
	local Scopes = self.Scopes
	for I = self.ScopeID, 0, -1 do
		local Cur = Scopes[I][Name]
		if Cur then return Cur, self.VarTypes[Cur] end
	end
end

/*==============================================================================================
	Section: Operator Getters
	Purpose: 
	Creditors: Rusketh
==============================================================================================*/
function Compiler:GetOperator(Name, sType, ...)
	-- Purpose: Grabs an operator.

	local tArgs = {...}
	
	local Types = GetShortType( sType or "" ) or ""
	if #tArgs > 0 then 
		for i=1,#tArgs do
			Types = Types .. GetShortType( tArgs[i] )
		end
	end
	
	local Op = Operators[ Name .. "(" .. Types .. ")" ]
	if Op then return Op[1], Op[2], Op[3] end
end

/*==============================================================================================
	Section: Sequence Instructions
	Purpose: Runs a sequence
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_SEQUENCE(Statments)
	local Stmts = {}
	
	for I = 1, #Statments do
		Stmts[I] = self:CompileInst(Statments[I])
	end
	
	local Op, Ret = self:GetOperator("sequence")
	return self:Operation(Op, Ret, Stmts, #Stmts)
end

/*==============================================================================================
	Section: Raw Value Instructions
	Purpose: Runs a sequence
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_NUMBER(Number)
	self.Perf = self.Perf + EA_COST_CHEAP
	return self:Operation(function() return Number end, "number"):SetCost(EA_COST_CHEAP)
end

function Compiler:Instr_STRING(String)
	self.Perf = self.Perf + EA_COST_CHEAP
	return self:Operation(function() return String end, "string"):SetCost(EA_COST_CHEAP)
end

/*==============================================================================================
	Section: Assigment Operators
	Purpose: Assigns Values to Variables
	Creditors: Rusketh
==============================================================================================*/
function Compiler:AssignVar(Type, Name, Special)
	-- Purpose: Handels variable assigments properly and sorts special cases.
	
	if !Special then
		return self:SetVar(Name, Type)
		
	elseif Special == "local" then
		return self:LocalVar(Name, Type)
		
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

/********************************************************************************************************************/

function Compiler:Instr_ASSIGN_DEFAULT(Name, Type, Special)
	-- Purpose: Assign a Variable with a default value.
	
	local Op, Ret, Cost = self:GetOperator("assign", Type)
	if !Op then self:Error("Assigment operator (=) does not support '%s'", GetLongType(Type)) end
	
	local VarID, Scope = self:AssignVar(Type, Name, Special) -- Create the Var
	
	if self.Inputs[VarID] then -- Note: Inputs can not be assigned so registering them is enogh.
		return self:Operation(function() end)
	end
	
	self.Perf = self.Perf + Cost
	
	return self:Operation(Op, Ret, self:Operation(TypeShorts[Type][3], Type), VarID):SetCost(Cost)
end

function Compiler:Instr_ASSIGN_DECLARE(Name, Expr, Type, Special)
	-- Purpose: Declares a value
	
	local Op, Ret, Cost = self:GetOperator("assign", Type)
	if !Op then self:Error("Assigment operator (=) does not support '%s'", Type) end
	
	local ExprOp = self:CompileInst(Expr, true)
	local RType = ExprOp:ReturnType()
	if RType != Type then self:Error("Variable %s of type %s, can not be assigned as '%s'", Name, Type, ExprOp:ReturnType(true)) end
	
	local VarID, Scope = self:AssignVar(Type, Name, Special)
	
	if self.Inputs[VarID] then -- Note: You can not assign an input!
		self:Error("Assigment operator (=) does not support input Variables")
	end
	
	self.Perf = self.Perf + Cost
	
	return self:Operation(Op, Ret, ExprOp, VarID):SetCost(Cost)
end

function Compiler:Instr_ASSIGN(Name, Expr)
	-- Purpose: Assign Default value.
	
	local VarID, Type = self:GetVar(Name)
	if !VarID then self:Error("variabel %s does not exist", Name) end
	
	if self.Inputs[VarID] then -- Note: You can not assign an input!
		self:Error("Assigment operator (=) does not support input Variables")
	end
	
	local Op, Ret, Cost = self:GetOperator("assign", Type)
	if !Op then self:Error("Assigment operator (=) does not support '%s'", Type) end
	
	local ExprOp = self:CompileInst(Expr, true)
	local RType = ExprOp:ReturnType()
	if RType != Type then self:Error("Variable %s of type %s, can not be assigned as '%s'", Name, Type, ExprOp:ReturnType() ) end
	
	self.Perf = self.Perf + Cost
	
	return self:Operation(Op, Ret, ExprOp, VarID):SetCost(Cost)
end
		
function Compiler:Instr_VARIABEL(Name)
	-- Purpose: Retrive variabel.
	
	local VarID, Type = self:GetVar(Name)
	if !VarID then self:Error("variabel %s does not exist", Name) end
	
	local Op, Ret = self:GetOperator("variabel", Type)
	if !Op then self:Error("Improbable Error: variabel operator does not support '%s'", Type) end
	
	self.Perf = self.Perf + EA_COST_CHEAP
	
	return self:Operation(Op, Ret, VarID):SetCost(EA_COST_CHEAP)
end

/*==============================================================================================
	Section: Mathmatical Operators
	Purpose: Does math stuffs?
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_EXPONENT(InstA, InstB)
	-- Purpose: ^ Math Operator.
	
	local OpA, OpB = self:CompileInst(InstA), self:CompileInst(InstB)
	local Op, Ret, Cost = self:GetOperator("exponent", OpA:ReturnType(), OpB:ReturnType())
	if !Op then self:Error("exponent operator (^) does not support '%s ^ %s'", OpA:ReturnType(true), GetLongType(OpB:ReturnType())) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, OpA, OpB):SetCost(Cost)
end

function Compiler:Instr_MULTIPLY(InstA, InstB)
	-- Purpose: * Math Operator.
	
	local OpA, OpB = self:CompileInst(InstA), self:CompileInst(InstB)
	local Op, Ret, Cost = self:GetOperator("multiply", OpA:ReturnType(), OpB:ReturnType())
	if !Op then self:Error("multiply operator (*) does not support '%s * %s'", OpA:ReturnType(true), OpB:ReturnType(true)) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, OpA, OpB):SetCost(Cost)
end

function Compiler:Instr_DIVIDE(InstA, InstB)
	-- Purpose: / Math Operator.
	
	local OpA, OpB = self:CompileInst(InstA), self:CompileInst(InstB)
	local Op, Ret, Cost = self:GetOperator("divide", OpA:ReturnType(), OpB:ReturnType())
	if !Op then self:Error("division operator (/) does not support '%s / %s'", OpA:ReturnType(true),OpB:ReturnType(true)) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, OpA, OpB):SetCost(Cost)
end

function Compiler:Instr_MODULUS(InstA, InstB)
	-- Purpose: % Math Operator.
	
	local OpA, OpB = self:CompileInst(InstA), self:CompileInst(InstB)
	local Op, Ret, Cost = self:GetOperator("modulus", OpA:ReturnType(), OpB:ReturnType())
	if !Op then self:Error("modulus operator (%) does not support '%s % %s'", OpA:ReturnType(true), OpB:ReturnType(true)) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, OpA, OpB):SetCost(Cost)
end

function Compiler:Instr_ADDITION(InstA, InstB)
	-- Purpose: + Math Operator.
	
	local OpA, OpB = self:CompileInst(InstA), self:CompileInst(InstB)
	local Op, Ret, Cost = self:GetOperator("addition", OpA:ReturnType(), OpB:ReturnType())
	if !Op then self:Error("addition operator (+) does not support '%s + %s'", OpA:ReturnType(true), OpB:ReturnType(true)) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, OpA, OpB):SetCost(Cost)
end

function Compiler:Instr_SUBTRACTION(InstA, InstB)
	-- Purpose: - Math Operator.
	
	local OpA, OpB = self:CompileInst(InstA), self:CompileInst(InstB)
	local Op, Ret, Cost = self:GetOperator("subtraction", OpA:ReturnType(), OpB:ReturnType())
	if !Op then self:Error("subtraction operator (-) does not support '%s - %s'", OpA:ReturnType(true), OpB:ReturnType(true)) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, OpA, OpB):SetCost(Cost)
end

function Compiler:Instr_INCREMET(Var)
	-- Purpose: ++ Math Operator.
	
	local Memory, Type = self:GetVar(Var)
	if !Memory then self:Error("Variable %s does not exist", Var) end
	
	if self.Inputs[Memory] then self:Error("incremet operator (--) can not accept inputs") end
	
	local Op, Ret, Cost = self:GetOperator("incremet", Type)
	if !Op then self:Error("incremet operator (++) does not support '%s++'", Type) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, Memory):SetCost(Cost)
end

function Compiler:Instr_DECREMET(Var)
	-- Purpose: -- Math Operator.
	
	local Memory, Type = self:GetVar(Var)
	if !Memory then self:Error("Variable %s does not exist", Var) end
	
	if self.Inputs[Memory] then self:Error("decremet operator (--) can not accept inputs") end
	
	local Op, Ret, Cost = self:GetOperator("incremet", Type)
	if !Op then self:Error("decremet operator (--) does not support '%s--'", Type) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, Memory):SetCost(Cost)
end

/*==============================================================================================
	Section: Comparason Operators
	Purpose: Compare Values =D
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_GREATER_THAN(InstA, InstB)
	-- Purpose: > Comparason Operator.
	
	local OpA, OpB = self:CompileInst(InstA), self:CompileInst(InstB)
	local Op, Ret, Cost = self:GetOperator("greater", OpA:ReturnType(), OpB:ReturnType())
	if !Op then self:Error("comparason operator (>) does not support '%s > %s'", OpA:ReturnType(true), OpB:ReturnType(true)) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, OpA, OpB):SetCost(Cost)
end

function Compiler:Instr_LESS_THAN(InstA, InstB)
	-- Purpose: < Comparason Operator.
	
	local OpA, OpB = self:CompileInst(InstA), self:CompileInst(InstB)
	local Op, Ret, Cost = self:GetOperator("less", OpA:ReturnType(), OpB:ReturnType())
	if !Op then self:Error("comparason operator (<) does not support '%s < %s'", OpA:ReturnType(true), OpB:ReturnType(true)) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, OpA, OpB):SetCost(Cost)
end

function Compiler:Instr_GREATER_EQUAL(InstA, InstB)
	-- Purpose: <= Comparason Operator.
	
	local OpA, OpB = self:CompileInst(InstA), self:CompileInst(InstB)
	local Op, Ret, Cost = self:GetOperator("greaterequal", OpA:ReturnType(), OpB:ReturnType())
	if !Op then self:Error("comparason operator (<=) does not support '%s <= %s'", OpA:ReturnType(true), OpB:ReturnType(true)) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, OpA, OpB):SetCost(Cost)
end

function Compiler:Instr_LESS_EQUAL(InstA, InstB)
	-- Purpose: >= Comparason Operator.
	
	local OpA, OpB = self:CompileInst(InstA), self:CompileInst(InstB)
	local Op, Ret, Cost = self:GetOperator("lessequal", OpA:ReturnType(), OpB:ReturnType())
	if !Op then self:Error("comparason operator (>=) does not support '%s >= %s'", OpA:ReturnType(true), OpB:ReturnType(true)) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, OpA, OpB):SetCost(Cost)
end

function Compiler:Instr_NOT_EQUAL(InstA, InstB)
	-- Purpose: != Comparason Operator.
	
	local OpA, OpB = self:CompileInst(InstA), self:CompileInst(InstB)
	local Op, Ret, Cost = self:GetOperator("notequal", OpA:ReturnType(), OpB:ReturnType())
	if !Op then self:Error("comparason operator (!=) does not support '%s != %s'", OpA:ReturnType(true), OpB:ReturnType(true)) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, OpA, OpB):SetCost(Cost)
end
	
function Compiler:Instr_EQUAL(InstA, InstB)
	-- Purpose: == Comparason Operator.
	
	local OpA, OpB = self:CompileInst(InstA), self:CompileInst(InstB)
	local Op, Ret, Cost = self:GetOperator("equal", OpA:ReturnType(), OpB:ReturnType())
	if !Op then self:Error("comparason operator (==) does not support '%s == %s'", OpA:ReturnType(true), OpB:ReturnType(true)) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, OpA, OpB):SetCost(Cost)
end
		
/*==============================================================================================
	Section: If Stamtment
	Purpose: If Condition Then Do This
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_IF(Conditon, Block, Else)
	
	local Con = self:CompileInst(Conditon)
	local OpC, RetC, CostC = self:GetOperator("is", Con:ReturnType())
	if !OpC or RetC ~= "n" then self:Error("if stament conditions do not support '%s'", Con:ReturnType()) end
	
	self:PushScope()
	local Op, Ret, Cost = self:GetOperator("if")
	local Statments = self:CompileInst(Block)
	self:PopScope()
	
	Cost = (Cost or EA_COST_CHEAP) + (CostC or EA_COST_CHEAP)
	self.Perf = self.Perf + Cost -- Note: Temp!
	
	if !Else then
		return self:Operation(Op, Ret, self:Operation(OpC, RetC, Con), Statments):SetCost(Cost)
	else
		local ElseOp = self:CompileInst(Else)
		return self:Operation(Op, Ret, self:Operation(OpC, RetC, Con), Statments, ElseOp):SetCost(Cost)
	end
end

function Compiler:Instr_OR(InstA, InstB)
	-- Purpose: || conditonal Operator.
	
	local OpA, OpB = self:CompileInst(InstA), self:CompileInst(InstB)
	local TypeA, TypeB = OpA:ReturnType(), OpB:ReturnType()
	local Op, Ret, Cost = self:GetOperator("or", TypeA, TypeB)
	
	if !Op then -- Note: Default Or Operators
		if TypeA == TypeB then
			local IOp, IRet, ICost = self:GetOperator("is", TypeA)
			if IOp then
				local Op, Ret, Cost = self:GetOperator("or", IRet, IRet)
				self.Perf = self.Perf + Cost + ICost + ICost
				
				return self:Operation(Op, Ret, self:Operation(IOp, IRet, OpA):SetCost(ICost), self:Operation(IOp, IRet, OpB):SetCost(ICost)):SetCost(Cost)
			end
		end
	end
	
	if !Op then self:Error("or (||) does not support '%s || %s'", TypeA, TypeB) end
	
	-- Note: Ooh Supported Or operators =D
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, OpA, OpB):SetCost(Cost)
end

function Compiler:Instr_AND(InstA, InstB)
	-- Purpose: && conditonal Operator.
	
	local OpA, OpB = self:CompileInst(InstA), self:CompileInst(InstB)
	local TypeA, TypeB = OpA:ReturnType(), OpB:ReturnType()
	
	local AOp, ARet, ACost = self:GetOperator("is", TypeA)
	local BOp, BRet, BCost = self:GetOperator("is", TypeB)
	if !AOp or !BOp then self:Error("and (&&) does not support '%s && %s'", TypeA, TypeB) end
	
	local Op, Ret, Cost = self:GetOperator("and", ARet, BRet)
	if !Op then self:Error("and (&&) does not support '%s && %s'", TypeA, TypeB) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, self:Operation(AOp, ARet, OpA):SetCost(ACost), self:Operation(BOp, BRet, OpB):SetCost(BCost)):SetCost(Cost)
end

/*==============================================================================================
	Section: Value Prefixes
	Purpose: These handel stuff like Delta, not and Neg
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_NEGATIVE(Inst)
	local Value = self:CompileInst(Inst)
	
	local Op, Ret, Cost = self:GetOperator("negative", Value:ReturnType())
	if !Op then self:Error("Negation operator (-) does not support '-%s'", Value:ReturnType()) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, Value):SetCost(Cost)
end

function Compiler:Instr_NOT(Inst)
	-- Purpose: ! Not Operator
	
	local Value = self:CompileInst(Inst)
	
	local Op, Ret, Cost = self:GetOperator("not", Value:ReturnType())
	if !Op then self:Error("Not operator (!) does not support '!%s'", Value:ReturnType()) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, Value):SetCost(Cost)
end

function Compiler:Instr_LENTH(Inst)
	-- Purpose: # Length Operator
	
	local Value = self:CompileInst(Inst)
	
	local Op, Ret, Cost = self:GetOperator("lenth", Value:ReturnType())
	if !Op then self:Error("Lenth operator (#) does not support '#%s'", Value:ReturnType()) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, Value):SetCost(Cost)
end

/*==============================================================================================
	Section: Delta
	Purpose: Differnce between new and old values.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_DELTA(Name)
	-- Purpose: ~ Delta Operator
	
	local VarID, Type = self:GetVar(Name)
	if !VarID then self:Error("variabel %s does not exist", Name) end

	local Op, Ret, Cost = self:GetOperator("delta", Type)
	if !Op then self:Error("Delta operator (~) does not support '~%s'", Type) end
	
	self.Perf = self.Perf + Cost
	return self:Operation(Op, Ret, VarID):SetCost(Cost)
end

/*==============================================================================================
	Section: Value Casting
	Purpose: Casting converts one type to another.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_CAST(Type, Expr)
	-- Purpose: (type) epresson casting
	
	local Value = self:CompileInst(Expr, true)
	local Convert = Value:ReturnType()
	
	-- Note: Lets see if we can cast at compile time.
	local Op, Ret, Cost = self:GetOperator("cast", Type, Convert)
	if !Op then self:Error("Can not cast from %q to %q", GetLongType(Convert), GetLongType(Type) ) end
	
	return self:Operation(Op, Type, Value, Type):SetCost(Cost)
end

/*==============================================================================================
	Section: Inbuilt Functions and Methods
	Purpose: These function are built in =D
	Creditors: Rusketh
==============================================================================================*/
function Compiler:GenerateArguments(Insts, Method)
	-- Purpose: Compiles function arguments.
	
	local Total = #Insts
	if Total == 0 then return {}, "" end
	
	local Op = self:CompileInst(Insts[1])
	local Ops, Sig = {Op}, Op:ReturnType()
	
	if Method then Sig = Sig .. ":" end
	
	for I = 2, Total do
		local Op = self:CompileInst(Insts[1])
		local Type = Op:ReturnType()
		
		Ops[I] = Op; Sig = Sig .. Type
	end
	
	MsgN("Gened: " .. Sig)
	
	return Ops, Sig
end

function Compiler:CallFunction(Name, Ops, Sig)
	local Functions = Functions -- Speed!
	local Func = Functions[Name .. "(" .. Sig .. ")"]
	
	if !Func then self:Error("Uknown function %s(%s)", Name, Sig) end
	
	local Cost = Func[3]
	self.Perf = self.Perf + Cost
	return self:Operation(Func[1], Func[2], unpack(Ops)):SetCost(Cost)
end

function Compiler:Instr_FUNCTION(Name, Insts)
	-- Purpose: Finds and calls a function.
	
	local VarID, Type = self:GetVar(Name)
	
	if VarID then -- User Function needs to use Call Operator
		return self:Call_UDFunction(Name, VarID, Insts)
	end
	
	local Ops, Sig = self:GenerateArguments(Insts)
	return self:CallFunction(Name, Ops, Sig)
end

function Compiler:Instr_METHOD(Name, Insts)
	-- Purpose: Finds and calls a function.
	
	local Ops, Sig, Unsure = self:GenerateArguments(Insts, true)
	return self:CallFunction(Name, Ops, Sig)
end

/*==============================================================================================
	Section: First Class Functions (User Defined Functions).
	Purpose: Function Objects, just 20% cooler!
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Call_UDFunction(Name, VarID, Insts)
	-- Purpose: Calls user function.
	
	local Data = self.VarData[ VarID ]
	local Perams, Return = Data[2], Data[1]
	
	local Ops, Sig = self:GenerateArguments(Insts)
	if Perams != Sig then self:Error("Peramater missmatch for user function %s() %q vs %q", Name, tostring(Perams), tostring(Sig)) end
	
	local Op, Ret, Cost = self:GetOperator("udfcall")
	self.Perf = self.Perf + Cost
	
	return self:Operation(Op, Return, VarID, Ops):SetCost(Cost)
end

function Compiler:Instr_UDFUNCTION(Local, Name, Listed, Perams, Types, Block, Return)
	-- Purpose: Define user function.
	
	local VarID, Type
	if !Local then -- Assign the function some memory.
		VarID, Type = self:SetVar(Name, "f")
	else
		VarID, Type = self:LocalVar(Name, "f")
	end
	
	local Current = self.VarData[ VarID ]
	MsgN("Defined: " .. Name .. " -> " .. VarID .. " -> " .. tostring(Current))
	
	if Current then -- Compare information as not to confuse the compiler!
		PrintTable(Current)
		
		if Current[2] ~= Listed then
			self:Error("Peramter missmach for function %q", Name)
		elseif Current[1] ~= Return then
			self:Error("Return type missmach for function %q exspected to be %q", Name, LongType(Current[1]))
		end
	else
		self.VarData[ VarID ] = {Return, Listed}
	end
	
	local Memory, Statments = self:BuildFunction(Listed, Perams, Types, Block, Return)
	
	local Op, Ret, Cost = self:GetOperator("udfdef")
	self.Perf = self.Perf + Cost
	
	return self:Operation(Op, Ret, VarID, Perams, Memory, Statments, Return):SetCost(Cost)
end

function Compiler:BuildFunction(Listed, Perams, Types, Block, Return)
	-- Purpose: This instruction Will create function variabels.
	
	local LastReturnType = self.ReturnType
	self.ReturnType = Return
	
	self:PushScope()
	
	local Memory, Ops = {}, Operators
	for I = 1, #Perams do
		local Var = Perams[I]
		local Type = Types[Var]
		
		local Op = Operators["assign(" .. Type .. ")"]
		if !Op then self:Error("type %s, can not be used in function perameters.", Type) end

		Memory[I] = {self:LocalVar(Var, Type), Op}
	end
	
	self:PushScope() -- Note: Allows us to overwrite perameters.
	
	local Statments = self:CompileInst(Block) -- Note: Function Body =D
	
	self:PopScope()
	self:PopScope()
	
	self.ReturnType = LastReturnType
	
	local Op, Ret, Cost = self:GetOperator("udfunction")

	return Memory, Statments
end

function Compiler:Instr_RETURN(Inst)
	local Return, Value = self.ReturnType
	
	if Inst then
		Value = self:CompileInst(Inst)
	
		if !Return then
			self:Error("Unable to return '%s', function return type is 'void'", Value:ReturnType(true))
			
		elseif Value:ReturnType() != Return then
			self:Error("Unable to return '%s', function return type is '%s'", Value:ReturnType(true), GetLongType(Return))
		end
		
	elseif Return then
		self:Error("Unable to return 'void', function return type is '%s'", GetLongType(Return))
	end
	
	local Op, Ret, Cost = self:GetOperator("return")
	return self:Operation(Op, Return, Value):SetCost(Cost)
end

/*==============================================================================================
	Section: Events
	Purpose: Events do stuff.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_EVENT(Event, Listed, Perams, Types, Block)
	-- Purpose: This instruction Will create function variabels.
	
	self:PushScope()
	
	local Memory, Ops = {}, Operators
	for I = 1, #Perams do
		local Var = Perams[I]
		local Type = Types[Var]
		
		local Op = Operators["assign(" .. Type .. ")"]
		if !Op then self:Error("type %s, can not be used in function perameters.", Type) end

		Memory[I] = {self:LocalVar(Var, Type), Op}
	end
	
	self:PushScope() -- Note: Allows us to overwrite perameters.
	
	local Statments = self:CompileInst(Block) -- Note: Event Body =D
	
	self:PopScope()
	self:PopScope()
	
	Op, Ret, Cost = self:GetOperator("event")

	return self:Operation(Op, Ret, Event, Memory, Statments):SetCost(Cost)
end
/*==============================================================================================
	Section: Loops
	Purpose: for loops, while loops.
	Creditors: Rusketh
==============================================================================================*/
function Compiler:Instr_LOOP_FOR(Assign, Condition, Step, Block)
	-- Purpose: Runs a for loop.
	
	local Op, Ret, Cost = self:GetOperator("for")
	
	self:PushScope()
	
	local Assign = self:CompileInst(Assign)
	
	local Cond = self:CompileInst(Condition) -- Note: Conditions need an is operator.
	local op, ret, cost = self:GetOperator("is", Cond:ReturnType())
	if !op or ret ~= "n" then self:Error("for loop conditions do not support '%s'", Cond:ReturnType()) end
	
	local Step = self:CompileInst(Step)

	local Block = self:CompileInst(Block)
	
	self:PopScope()
	
	return self:Operation(Op, Ret, Assign, self:Operation(op, ret, Cond):SetCost(cost), Step, Block):SetCost(Cost)
end

function Compiler:Instr_LOOP_WHILE(Condition, Block)
	-- Purpose: Runs a while loop.
	
	local Op, Ret, Cost = self:GetOperator("while")
	
	local Cond = self:CompileInst(Condition) -- Note: Conditions need an is operator.
	local op, ret, cost = self:GetOperator("is", Cond:ReturnType())
	if !op or ret ~= "n" then self:Error("for loop conditions do not support '%s'", Cond:ReturnType()) end
		
	self:PushScope()
	
	local Block = self:CompileInst(Block)
	
	self:PopScope()
		
	return self:Operation(Op, Ret, self:Operation(op, ret, Cond):SetCost(cost), Block):SetCost(Cost)
end

function Compiler:Instr_BREAK(Depth)
	-- Purpose: Breaks a loop.
	
	return function() error("brk:" .. (Depth or 0)) end
end

function Compiler:Instr_CONTINUE(Depth)
	-- Purpose: Continues a loop.
	
	return function() error("cnt:" .. (Depth or 0)) end
end