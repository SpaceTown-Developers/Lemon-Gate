/*==============================================================================================
	Expression Advanced: Entitys.
	Purpose: Entitys are stuffs.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local GetLongType = E_A.GetLongType

/*==============================================================================================
	Class & WireMod
==============================================================================================*/
local function Input(self, Memory, Value)
	-- Purpose: Used to set Memory via a wired input.
	
	self.Memory[Memory] = Value
end

local function Output(self, Memory)
	-- Purpose: Used to get Memory for a wired output.
	
	return self.Memory[Memory]
end

E_A:WireModClass("entity", "ENTITY", Input, Output)

/*==============================================================================================
	Var Operators
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterOperator("assign", "e", "", function(self, ValueOp, Memory)
	-- Purpose: Assigns a number to memory
	
	local Value, Type = ValueOp(self)
	if Type != "e" then self:Error("Attempt to assign %s to entity", GetLongType(Type)) end
	
	self.Memory[Memory] = Value
	
	self.Click[Memory] = true
end)

E_A:RegisterOperator("variabel", "e", "e", function(self, Memory)
	-- Purpose: Assigns a number to memory
	
	return self.Memory[Memory]
end)

/*==============================================================================================
	Section: Comparason Operators
	Purpose: If statments and stuff?
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_EXSPENSIVE)


E_A:RegisterOperator("negeq", "ee", "n", function(self, ValueA, ValueB)
	-- Purpose: != Comparason Operator
	
	return (ValueA(self) == ValueB(self)) and 0 or 1
end)

E_A:RegisterOperator("eq", "ee", "n", function(self, ValueA, ValueB)
	-- Purpose: == Comparason Operator
	
	return (ValueA(self) == ValueB(self)) and 1 or 0
end)

/*==============================================================================================
	Section: Conditonal Operators
	Purpose: And (&) and Or (|) Operators.
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

E_A:RegisterOperator("is", "e", "n", function(self, Value)
	-- Purpose: Is Valid
	
	local Entity = Value(self)
	return (Entity and Entity:IsValid()) and 1 or 0
end)

E_A:RegisterOperator("or", "ee", "e", function(self, ValueA, ValueB)
	-- Purpose: | Conditonal Operator
	
	local Entity = ValueA(self)
	return (Entity and Entity:IsValid()) and Entity or ValueB(self)
end)

E_A:RegisterOperator("and", "ee", "n", function(self, ValueA, ValueB)
	-- Purpose: & Conditonal Operator
	
	local A, B = ValueA(self), ValueB(self)
	return (A and B and A:IsValid() and B:IsValid()) and 1 or 0
end)

/*==============================================================================================
	Section: Casting and converting
	Purpose: these will be handy.
	Creditors: Rusketh
==============================================================================================*/
local tostring = tostring

E_A:RegisterFunction("toString", "e", "s", function(self, Value)
	return tostring( Value(self) )
end)

E_A:RegisterOperator("cast", "se", "s", function(self, Value, ConvertType)
	return tostring( Value(self) )
end)

/*==============================================================================================
	Section: 
	Purpose: 
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterFunction("isPlayer", "e:", "n", function(self, Value)
	local Entity = Value(self)
	return (Entity and Entity:IsValid() and Entity:IsPlayer()) and 1 or 0
end)

E_A:RegisterFunction("isNPC", "e:", "n", function(self, Value)
	local Entity = Value(self)
	return (Entity and Entity:IsValid() and Entity:IsNPC()) and 1 or 0
end)

E_A:RegisterFunction("name", "e:", "s", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() then return Entity:GetName() or "" end
	return ""
end)
