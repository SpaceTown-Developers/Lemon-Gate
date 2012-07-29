local E_A = LemonGate

local Operators = E_A.OperatorTable

local LimitString = E_A.LimitString
local GetLongType = E_A.GetLongType
local GetShortType = E_A.GetShortType

local FormatStr = string.format -- Speed
local SubString = string.sub

/*==============================================================================================
	Section: RunTime Casting
	Purpose: Cast Value from type to type.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("cast", "", "", function(self, Value, CastType)
	-- Purpose: Converts a value at runtime.
	
	Val, Type = Value(self)
	local Op = Operators["cast(" .. CastType .. Type .. ")"]
	
	if !Op then return self:Error("unable to cast to '%s' from '%s'", GetLongType(CastType), GetLongType(Type)) end
	
	self.Perf = self.Perf + (Op[3] or 0) -- Note: We charge for the op.
	
	return Op[1](function() return Val, Type end) -- Note: We fake the operator so that it does not get called twice.
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
		local Ok, Except, Level = Block:Pcall(self)
		
		if !Ok then
			if Except == "brk" then
				if Level <= 0 then break else error("brk:" .. (Level - 1), 0) end
			elseif Except == "cnt" then
				if Level <= 0 then Step(self) else error("cnt:" .. (Level - 1), 0) end
			else
				error(Except .. ":" .. (Level or ""), 0)
			end
		else	
			Step(self) -- Note: Next Step
		end
	end
end)

E_A:RegisterOperator("while", "", "", function(self, Condition, Block)
	-- Purpose: Runs a for loop
	
	while Condition(self) == 1 do -- Note: loop untill condition is met.
		local Ok, Except, Level = Block:Pcall(self)
		
		if !Ok then
			if Except == "brk" then
				if Level <= 0 then break else error("brk:" .. (Level - 1), 0) end
			elseif Except == "cnt" then
				if Level >= 0 then error("cnt:" .. (Level - 1), 0) end
			else
				error(Except .. ":" .. (Level or ""), 0)
			end
		end
	end
end)