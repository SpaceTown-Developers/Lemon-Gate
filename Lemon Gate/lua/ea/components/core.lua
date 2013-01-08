/*==============================================================================================
	Expression Advanced: Lemon Gate Core.
	Purpose: Expression Advanced Operators and Functions.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local Operators = E_A.OperatorTable
local Functions = E_A.FunctionTable

local LimitString = E_A.LimitString
local GetLongType = E_A.GetLongType
local GetShortType = E_A.GetShortType

local FormatStr = string.format -- Speed
local SubString = string.sub -- Speed
local StringLeft = string.Left

local MathCeil = math.ceil -- Speed

local GetConVarNumber = GetConVarNumber -- Speed
local unpack = unpack -- Speed
local tostring = tostring -- Speed

E_A:RegisterClass("varargs (...)", "***", {})

/*==============================================================================================
	Section: Base Operators
	Creditors: Rusketh
==============================================================================================*/
function E_A.AssignOperator(self, InValue, Cell)
	local Value, tValue = InValue(self)
	local CurValue = self.Memory[Cell]
	self.Memory[Cell] = Value
	
	local Compare = E_A.OperatorTable["eq(" .. tValue .. tValue .. ")"]
	if CurValue and Compare then
		local Eq = Compare[1](self, function() return Value, tValue end, function() return CurValue, tValue end)
		self.Click[Cell] = (Eq and Eq == 1)
	else
		self.Click[Cell] = true
	end
	
	local Delta = E_A.OperatorTable["delta(" .. tValue .. ")"]
	if Delta then
		self.Delta[Cell] = CurValue
	end
end

function E_A.VariableOperator(self, Cell)
	return self.Memory[Cell] 
end

function E_A.DeltaOperator(self, Cell)
	local tValue = self.Types[Cell]
	local Sub = E_A.OperatorTable["subtraction(" .. tValue .. tValue .. ")"]
	local Default = E_A.TypeShorts[tValue][3]
	
	if Sub then
		local Value = self.Memory[Cell] or Default(self)
		local Delta = self.Delta[Cell] or Default(self)
		
		return Sub[1](self,
			function() return Value, tValue end,
			function() return Delta, tValue end)
	end
	
	return Default(self)
end

/*==============================================================================================
	Section: Exit Statments.
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterFunction("exit", "", "", function(self)
	error("Exit", 0)
end)

E_A:RegisterOperator("return", "", "", function(self, Value)
	self.ReturnValue = Value
	error("Return", 0)
end)

E_A:RegisterOperator("break", "", "", function(self, Depth)
	self.ExitDeph = Depth or 0
	error("Break", 0)
end)

E_A:RegisterOperator("continue", "", "", function(self, Depth)
	self.ExitDeph = Depth or 0
	error("Continue", 0)
end)

/*==============================================================================================
	Section: Functions
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

E_A:RegisterFunction("print", "...", "", function(self, ...)
	local Values, Message = { ... }, ""
	
	for I = 1, #Values do 
		Message = Message .. " " .. Values[I]:toString(self)
	end
	
	self.Player:PrintMessage( HUD_PRINTTALK, StringLeft(Message, 249) )
end)

/*==============================================================================================
	Section: Statement Executers
	Purpose: Runs statements.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("sequence", "", "", function(self, Statements, Count)
	-- Purpose: Runs a set of statements, know as a sequence.
	
	for I = 1, Count or #Statements do -- Count is used for speed.
		Statements[I](self)
	end
end)

E_A:RegisterOperator("if", "", "", function(self, Condition, Statements, Else)
	-- Purpose: If statements are cool
	
	if Condition(self) > 0 then
		Statements(self)
		
	elseif Else then
		Else(self)
	end
end)

/*==============================================================================================
	Section: Loops
	Purpose: for loops, while loops.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("for", "", "", function(self, Assign, Condition, Step, Block)
	-- Purpose: Runs a for loop
	
	Assign(self) -- Run assignment
	
	while Condition(self) == 1 do -- loop until condition is met.
		self:PushPerf(EA_COST_CHEAP)
		
		local Ok, Exit = Block:SafeCall(self)
		
		if !Ok then
			local Depth = self.ExitDeph or 0
			if Exit == "Break" then
				if Depth > 0 then self.ExitDeph = Depth - 1; error("Break", 0) end
				break
			elseif Exit == "Continue" then
				if Depth > 0 then self.ExitDeph = Depth - 1; error("Continue", 0) end
				break
			else
				error(Exit, 0)
			end
		else	
			Step(self) -- Next Step
		end
	end
end)

E_A:RegisterOperator("while", "", "", function(self, Condition, Block)
	-- Purpose: Runs a for loop
	
	while Condition(self) == 1 do -- loop until condition is met.
		self:PushPerf(EA_COST_CHEAP)
		
		local Ok, Exit = Block:SafeCall(self)
		
		if !Ok then
			local Depth = self.ExitDeph or 0
			if Exit == "Break" then
				if Depth > 0 then self.ExitDeph = Depth - 1; error("Break", 0) end
				break
			elseif Exit == "Continue" then
				if Depth > 0 then self.ExitDeph = Depth - 1; error("Continue", 0) end
				break
			else
				error(Exit, 0)
			end
		end
	end
end)

/*==============================================================================================
	Section: Try / Catch
	Purpose: Exception related things.
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

E_A:RegisterOperator("try", "", "", function(self, Block, Catch)
	local Ok, Exit = Block:SafeCall(self)
	if !Ok and Exit == "Exception" and Catch(self) then
		self.Exception = nil
		return -- Clear the exception.
	elseif !Ok then
		error(Exit, 0)
	end
end)

E_A:RegisterOperator("catch", "", "", function(self, Exceptions, Memory, Block, Catch)
	local Exception = self.Exception
	
	if Exception and ( Exceptions[ Exception.Type ] or Exceptions["*"] ) then
		self.Memory[Memory] = self.Exception
		return true, Block(self)
	elseif Catch then
		return Catch(self)
	end
	
	return false
end)

/*==============================================================================================
	Section: Exception Class
	Purpose: Move Me!.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterClass("exception", "!")

E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterOperator("assign", "!", "", function(self, ValueOp, Memory)
	self.Memory[Memory] = ValueOp(self)
	self.Click[Memory] = true
end)

E_A:RegisterOperator("variable", "!", "!", function(self, Memory)
	return self.Memory[Memory]
end)

E_A:RegisterOperator("is", "!", "n", function(self, Value)
	local Exception = Value(self)
	if Exception and Exception.Type then
		return 1 else return 0
	end
end)

E_A:RegisterFunction("type", "!:", "s", function(self, Value)
	local Exception = Value(self)
	if Exception and Exception.Type then return Exception.Type else return "" end
end)

E_A:RegisterFunction("message", "!:", "s", function(self, Value)
	local Exception = Value(self)
	if Exception and Exception.Msg then return Exception.Msg else return "" end
end)

E_A:SetCost(EA_COST_ABNORMAL)

E_A:RegisterFunction("trace", "!:n", "t", function(self, ValueA, ValueB)
	local Exception, Index = ValueA(self), ValueB(self)
	local Table = E_A.NewTable()
	
	if Exception and Exception.Trace then
		local Trace = Exception.Trace[ Index ]
		if Trace then
			Table:Set("line", "n", Trace[1])
			Table:Set("char", "n", Trace[2])
			Table:Set("instr", "s", Trace[3])
		end
	end
	
	return Table
end)

E_A:SetCost(EA_COST_EXPENSIVE)

E_A:RegisterFunction("trace", "!:", "t", function(self, Value)
	local Exception = Value(self)
	local Table = E_A.NewTable()
	
	if Exception and Exception.Trace then
		local Start = #Exception.Trace
		if Start > 10 then Start = 10 end
	
		for I = Start, 1, -1 do
			local Trace = Exception.Trace[I]
			local sTable = E_A.NewTable()
			
			sTable:Set("line", "n", Trace[1])
			sTable:Set("char", "n", Trace[2])
			sTable:Set("instr", "s", Trace[3])
			
			Table:Insert(nil, "t", sTable)
		end
	end
	
	return Table
end)

/*==============================================================================================
	Section: Debug
	Purpose: functions good for debugging.
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

E_A:RegisterFunction("debugTrace", "n", "t", function(self, Value)
	local V, Table = Value(self), E_A.NewTable()
	if !self.StackTrace or !self.StackTrace[V] then
		return Table
	end
	
	local Trace = self.StackTrace[V]
	
	Table:Set("line", "n", Trace[1])
	Table:Set("char", "n", Trace[2])
	Table:Set("instr", "s", Trace[3])
	
	return Table
end)

E_A:SetCost(EA_COST_EXPENSIVE)

E_A:RegisterFunction("debugTrace", "", "t", function(self)
	local Table = E_A.NewTable()
	local StackTrace = self.StackTrace
	
	if !StackTrace or !StackTrace[1] then
		return Table
	end
	
	local Start = #StackTrace
	if Start > 10 then Start = 10 end
	
	for I = Start, 1, -1 do
		local Trace = StackTrace[I]
		local sTable = E_A.NewTable()
		
		sTable:Set("line", "n", Trace[1])
		sTable:Set("char", "n", Trace[2])
		sTable:Set("instr", "s", Trace[3])
		
		Table:Insert(nil, "t", sTable)
	end
	
	return Table
end)
