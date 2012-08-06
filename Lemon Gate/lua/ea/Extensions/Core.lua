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
	Section: RunTime Operators
	Purpose: These are slow but are needed.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("cast", "", "", function(self, Value, CastType)
	-- Purpose: Converts a value at runtime.
	
	Val, Type = Value(self)
	local Op = Operators["cast(" .. CastType .. Type .. ")"]
	
	if !Op then return self:Error("unable to cast to '%s' from '%s'", GetLongType(CastType), GetLongType(Type)) end
	
	self.Perf = self.Perf + (Op[3] or EA_COST_NORMAL)
	
	return Op[1](function() return Val, Type end), CastType
end)

E_A:RegisterOperator("call", "", "", function(self, Name, Sig, Ops)
	-- Purpose: Calls an upredictable function at runtime.
	
	local Perf = self.Perf + EA_COST_NORMAL
	local Values, Sig = {}, ""
	
	for I = 1, #Ops do
		local Value, Type = Ops[I](self)
		Sig = Sig .. Type
		Values[I] = function() return Value, Type end
	end
	
	local Func = Functions[Name .. "(" .. Sig .. ")"]
	if !Func then return self:Error("Uknown function %s(%s)", Name, Sig)
	
	self.Perf = Perf + (Func[3] or EA_COST_NORMAL)
	
	return Func[1](unpack(Values)), Func[2]
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