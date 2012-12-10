/*==============================================================================================
	Expression Advanced: WireLink.
	Purpose: Like wiring a thousands things at once.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local GetLongType = E_A.GetLongType

/*==============================================================================================
	Class & WireMod
==============================================================================================*/
E_A:RegisterClass("wirelink", "wl", function() return Entity(-1) end)

local function Input(self, Memory, Value)
	-- Purpose: Used to set Memory via a wired input.
	
	self.Memory[Memory] = Value
end

local function Output(self, Memory)
	-- Purpose: Used to get Memory for a wired output.
	
	return self.Memory[Memory]
end

E_A:WireModClass("wirelink", "WIRELINK", Input)

/*==============================================================================================
	Var Operators
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterOperator("assign", "wl", "", function(self, ValueOp, Memory)
	-- Purpose: Assigns a number to memory
	
	local Value, Type = ValueOp(self)
	if Type != "e" then self:Error("Attempt to assign %s to entity", GetLongType(Type)) end
	
	self.Memory[Memory] = Value
	
	self.Click[Memory] = true
end)

E_A:RegisterOperator("variabel", "wl", "wl", function(self, Memory)
	-- Purpose: Assigns a number to memory
	
	return self.Memory[Memory]
end)


/*==============================================================================================
	Section: Comparason Operators
==============================================================================================*/
E_A:SetCost(EA_COST_EXSPENSIVE)


E_A:RegisterOperator("negeq", "wlwl", "n", function(self, ValueA, ValueB)
	-- Purpose: != Comparason Operator
	
	return (ValueA(self) == ValueB(self)) and 0 or 1
end)

E_A:RegisterOperator("eq", "wlwl", "n", function(self, ValueA, ValueB)
	-- Purpose: == Comparason Operator
	
	return (ValueA(self) == ValueB(self)) and 1 or 0
end)

/*==============================================================================================
	Section: Conditonal Operators
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

E_A:RegisterOperator("is", "wl", "n", function(self, Value)
	-- Purpose: Is Valid
	
	local Entity = Value(self)
	return (Entity and Entity:IsValid()) and 1 or 0
end)
