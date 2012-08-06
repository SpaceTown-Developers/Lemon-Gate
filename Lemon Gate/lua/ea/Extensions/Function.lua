/*==============================================================================================
	Expression Advanced: (UD) Functions.
	Purpose: User defined first class functions.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local Functions = E_A.FunctionTable
local Operators = E_A.OperatorTable
local Types = E_A.TypeShorts

local SubStr = string.sub -- Speed
local MatchStr = string.match -- Speed

local error = error -- Speed

E_A:RegisterClass("function", "f", {})

E_A:RegisterOperator("assign", "f", "", function(self, UDF, Memory)
	-- Purpose: Assigns a function to memory
	
	self.Memory[Memory] = UDF(self)
end)

E_A:RegisterOperator("variabel", "f", "f", function(self, Memory)
	-- Purpose: Assigns a number to memory
	
	return self.Memory[Memory]
end)

E_A:RegisterOperator("udfunction", "", "f", function(self, Sig, Assigments, Statments, Return)
	-- Purpose: Builds a Function Object
	
	return {Sig, Assigments, Statments, Return}
end)

/*==============================================================================================
	Section: Common Operators
	Purpose: Just for certan things.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("call", "f", "?", function(self, Value, Ops)
	-- Purpose: Calls the function, Required by the events manager.
	
	local Function = Value(self)
	local Assigments, Sig, Total = Func[2], "", #Ops
	
	if Total == #Assigments then return self:Error("call operator perameter missmatch") end
	
	for I = 1, Total do
		local Value, Type = Ops[I](self)
		Store[I](self, function() return Value, Type end)
		Sig = Sig .. Type
	end
	
	if Sig != Func[1] then return self:Error("call operator perameter missmatch") end
	
	local ReturnType = Func[4]
	
	local Ok, Except, Level = Func[3]:Pcall() -- Note: Call the statments!
	
	local Ret = self.ReturnValue
	self.ReturnValue = nil
	
	if !Ok and (!Except or Except != "rtn") then
		error(Except .. ":" .. (Level or "")) -- This is not a return exception.
	
	elseif ReturnType and ReturnType != "" then
		if Ok or !Ret then -- Note: Default return value
			return Types[ReturnType][3], ReturnType
		else Ret then
			local Value, Type = Ret(self)
			if Type != ReturnType then return self:Error("return type missmatch, '%s' expected got '%s'", ReturnType, Type) end
			return function() return Value, Type end, Type -- Note: Valid return value
		end
	elseif Ret then
		return self:Error("return type missmatch, 'void' expected got '%s'", ReturnType, Type)
	end
end)

E_A:RegisterOperator("return", "", "", function(self, Value)
	self.ReturnValue = Value
	error("rtn:")
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



--[[ Just some code that we cant use yet =P
local Valid = false -- Credits: Divran, We dont support varags yet =P
if MatchStr(Listed, "%.%.%.$") then -- If it ends with "..."
	Valid = SubStr(Listed, 1, -4) == SubStr(PList, 1, #Listed - 3)
else
	Valid = PList == Listed -- Note: Only works if they're exactly the same
end

if !Valid then self:Error("Function perameter missmatch '%s' & '%s'", Listed, PList) end]]