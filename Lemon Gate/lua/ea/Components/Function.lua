/*==============================================================================================
	Expression Advanced: (UD) Functions.
	Purpose: User defined first class functions.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local CallOp = E_A.CallOp
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
	local Perams, Memory, Statments, ReturnType = Data[1], Data[2], Data[3], Data[4]
	
	for I = 1, #Memory do
		local Store, Value = Memory[I], Values[I]
		local Index, Op = Store[1], Store[2]
		CallOp(Op, self, Value, Index)
	end
	
	local Ok, Exception, RetValue = Statments:SafeCall(self)
	
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
