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
local tostring = tostring

/*==============================================================================================
	Section: Functions
	Purpose: =D.
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterFunction("exit", "", "", function(self)
	self:Throw("exit")
end)

E_A:RegisterOperator("return", "", "", function(self, Value)
	local Value, Type = Value(self) -- We can error check the statement before using it!
	self:Throw("return", function() return Value, Type end)
end)

E_A:SetCost(EA_COST_ABNORMAL)

E_A:RegisterFunction("print", "...", "", function(self, ...)
	local Values, Message = { ... }, ""
	for I = 1, #Values do  Message = Message .. tostring( Values[I](self) )  end
	self.Player:PrintMessage( HUD_PRINTTALK, StringLeft(Message, 249) )
end)

/*==============================================================================================
	Section: Statement Executers
	Purpose: Runs statements.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("sequence", "", "", function(self, Statements, Count)
	-- Purpose: Runs a set of statements, know as a sequence.
	
	for I = 1, Count or #Statements do -- Note: Count is used for speed.
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
	
	Assign(self) -- Note: Run assignment
	
	while Condition(self) == 1 do -- Note: loop until condition is met.
		local Ok, Exception, Level = Block:SafeCall(self)
		Level = tonumber(Level or 0)
		
		if !Ok then
			if Exception == "break" then
				if Level <= 0 then break else self:Throw("break", Level - 1) end
			elseif Exception == "continue" then
				if Level <= 0 then Step(self) else self:Throw("continue", Level - 1) end
			else
				error(Exception, 0)
			end
		else	
			Step(self) -- Note: Next Step
		end
	end
end)

E_A:RegisterOperator("while", "", "", function(self, Condition, Block)
	-- Purpose: Runs a for loop
	
	while Condition(self) == 1 do -- Note: loop until condition is met.
		local Ok, Exception, Level = Block:SafeCall(self)
		Level = tonumber(Level or 0)
		
		if !Ok then
			if Exception == "break" then
				if Level <= 0 then break else self:Throw("break", Level - 1) end
			elseif Exception == "continue" then
				if Level <= 0 then Step(self) else self:Throw("continue", Level - 1) end
			else
				error(Exception, 0)
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
	-- Purpose: Safely run something.
	
	local Ok, Exception, Message = Block:SafeCall(self)
	
	if Ok or ( self.Exception and Catch(self) ) then
		self.Exception = nil
		self.ExceptionInfo = nil
		self.ExceptionTrace = nil
		return
	end
	
	error(Exception, 0)
end)

E_A:RegisterOperator("catch", "", "", function(self, Exceptions, Block, Catch)
	-- Purpose: Catch the exception.
	
	if Exceptions[ self.Exception ] then
		Block(self)
		
		return true
	elseif Catch then
		return Catch(self)
	end
	
	return false
end)

E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterFunction("exception", "", "s", function(self)
	return self.Exception or ""
end)

E_A:RegisterFunction("exceptionMsg", "", "s", function(self)
	if self.ExceptionInfo then
		return self.ExceptionInfo[1] or ""
	end
	
	return ""
end)

E_A:SetCost(EA_COST_ABNORMAL)

E_A:RegisterFunction("exceptionTrace", "n", "t", function(self, Value)
	local V, Table = Value(self), E_A.NewTable()
	if !self.ExceptionTrace or !self.ExceptionTrace[V] then
		return Table
	end
	
	local Trace = self.ExceptionTrace[V]
	
	Table:Set("line", "n", Trace[1])
	Table:Set("char", "n", Trace[2])
	Table:Set("instr", "s", Trace[3])
	
	return Table
end)

E_A:SetCost(EA_COST_EXPENSIVE)

E_A:RegisterFunction("exceptionTrace", "", "t", function(self)
	local Table = E_A.NewTable()
	local ExceptionTrace = self.ExceptionTrace
	
	if !ExceptionTrace or !ExceptionTrace[1] then
		return Table
	end
	
	local Start = #ExceptionTrace
	if Start > 10 then Start = 10 end
	
	for I = Start, 1, -1 do
		local Trace = ExceptionTrace[I]
		local sTable = E_A.NewTable()
		
		sTable:Set("line", "n", Trace[1])
		sTable:Set("char", "n", Trace[2])
		sTable:Set("instr", "s", Trace[3])
		
		Table:Insert(nil, "t", sTable)
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
