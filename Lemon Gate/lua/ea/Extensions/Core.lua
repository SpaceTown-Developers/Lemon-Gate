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

local unpack = unpack -- Speed

/*==============================================================================================
	Section: RunTime Operators / functions
	Purpose: These are slow but are needed.
	Creditors: Rusketh
==============================================================================================*/

/*==============================================================================================
	Section: Functions
	Purpose: =D.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterFunction("exit", "", "", function(self)
	self:Throw("exit")
end)

/*==============================================================================================
	Section: Statment Executers
	Purpose: Runs statments.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("sequence", "", "", function(self, Statments, Count)
	-- Purpose: Runs a set of statments, know as a sequence.
	
	for I = 1, Count or #Statments do -- Note: Count is used for speed.
		Statments[I](self)
	end
end)

E_A:RegisterOperator("if", "", "", function(self, Condition, Statments, Else)
	-- Purpose: If statments are cool
	
	if Condition(self) then -- Note: Op returns a bool =D
		Statments(self)
		
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
	
	Assign(self) -- Note: Run assigment
	
	while Condition(self) == 1 do -- Note: loop untill condition is met.
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
	
	while Condition(self) == 1 do -- Note: loop untill condition is met.
		local Ok, Exception, Level = Block:SafeCall(self)
		Level = tonumber(Level or 0)
		
		if !Ok then
			if Except == "break" then
				if Level <= 0 then break else self:Throw("break", Level - 1) end
			elseif Except == "continue" then
				if Level <= 0 then Step(self) else self:Throw("continue", Level - 1) end
			else
				error(Exception, 0)
			end
		end
	end
end)