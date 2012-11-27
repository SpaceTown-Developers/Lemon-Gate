/*==============================================================================================
	Expression Advanced: (UD) Functions.
	Purpose: User defined first class functions.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local LongType = E_A.GetLongType
local Types = E_A.TypeShorts

local unpack = unpack -- Speed
local error = error -- Speed

E_A:RegisterOperator("udfdef", "", "", function(self, VarID, Perams, Memory, Statments, ReturnType)
	-- Purpose: Builds a Function.
	
	self.Memory[VarID] = {Perams, Memory, Statments, ReturnType}
end)

E_A:RegisterOperator("udfcall", "", "", function(self, VarID, Values)
	-- Purpose: Builds a Function.
	
	local Data = self.Memory[VarID]
	local Perams, Ops, Statments, ReturnType = Data[1], Data[2], Data[3], Data[4]
	
	for I = 1, #Ops do
		local Store, Value = Ops[I], Values[I]
		local Index, Op = Store[1], Store[2]
		Op[1](Op, self, Value, Index)
	end
	
	local Ok, Exception, RetValue = Statments[1](Statments, self)
	
	if (Ok and ReturnType and ReturnType != "") or (!Ok and Exception == "return") then
		if RetValue then
			return RetValue(self)
		else
			return Types[ReturnType][3](self)
		end
	elseif !Ok then
		error(Exception, 0)
	end
	
end)

E_A:RegisterOperator("return", "", "", function(self, Value)
	self:Throw("return", Value)
end)
