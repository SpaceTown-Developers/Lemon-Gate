/*==============================================================================================
	Expression Advanced: (UD) Functions.
	Purpose: User defined first class functions.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local Functions = E_A.FunctionTable
local Operators = E_A.OperatorTable

local SubStr = string.sub -- Speed
local MatchStr = string.match -- Speed

E_A:RegisterClass("function", "f", {})

E_A:RegisterOperator("assign", "f", "", function(self, UDF, Memory)
	-- Purpose: Assigns a function to memory
	
	self.Memory[Memory] = UDF(self)
end)

E_A:RegisterOperator("variabel", "f", "f", function(self, Memory)
	-- Purpose: Assigns a number to memory
	
	return self.Memory[Memory]
end)

E_A:RegisterOperator("udfunction", "", "f", function(self, Listed, Memory, Statments, Return)
	-- Purpose: Builds a Function Object
	
	return {Listed, Memory, Statments, Return}
end)

/*==============================================================================================
	Section: Common Operators
	Purpose: Just for certan things.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("call", "f", "?", function(self, Value, PList, ...)
	-- Purpose: Calls the function, Required by the events manager.
	
	local Func = Value(self)
	local Listed, Memory, Op, Return = Func[1], Func[2], Func[3], Func[4]
	
	local Valid = false -- Credits: Divran.
	if MatchStr(Listed, "%.%.%.$") then -- If it ends with "..."
		Valid = SubStr(Listed, 1, -4) == SubStr(PList, 1, #Listed - 3)
	else
		Valid = PList == Listed -- Only works if they're exactly the same
	end
	
	if !Valid then self:Error("Function perameter missmatch '%s' & '%s'", Listed, PList) end
	
	if Memory then
		local Perams = {...}
		
		for I = 1, #Memory do
			local Assign = Memory[I]
			Assign[2](self, Assign[1], Perams[I])
			-- Note: Assigning Vars to memory!
		end
		
		-- Todo: Vararg support.
		
		local Ret = Op(self) or self.ReturnValue
		self.ReturnValue = nil
		
		return Ret, Return
	end
	
	-- Note: No memory assigments so we can just try and run it.
	
	local Ret = Op(self, ...) or self.ReturnValue
	self.ReturnValue = nil 
	
	return Ret, Return -- Todo: This needs Perf!
	
end)

E_A:RegisterOperator("return", "", "", function(self, Value)
	self.ReturnValue = Value
end)

E_A:RegisterOperator("is", "f", "n", function(self, Value)
	-- Purpose: Is Valid
	
	local UDF = Value(self)
	if #UDF > 0 then return 1 else return 0 end
end)

/*==============================================================================================
	Section: Util Functions
	Purpose: These are rarly used but can be handy.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterFunction("getFunction", "ss", "f", function(self, ValueA, ValueB)
	-- Purpose: Allows moving existing functions to memory =D

	local Name, Perams = ValueA(self), ValueB
	local Listed = Name .. "(" .. Perams .. ")"
	
	if FindString(Listed, ":") then return {} end
	
	local Func = Functions[Listed]
	if !Func then return {} end
	
	return {Listed, nil, Func[1], Func[2]}
end)
