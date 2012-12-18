/*==============================================================================================
	Expression Advanced: Wirelink.
	Purpose: Like wiring a thousands things at once.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API

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
	
	self.Memory[Memory] = Value
	
	self.Click[Memory] = true
end)

E_A:RegisterOperator("variable", "wl", "wl", function(self, Memory)
	-- Purpose: Assigns a number to memory
	
	return self.Memory[Memory]
end)


/*==============================================================================================
	Section: Comparison Operators
==============================================================================================*/
E_A:SetCost(EA_COST_EXPENSIVE)


E_A:RegisterOperator("negeq", "wlwl", "n", function(self, ValueA, ValueB)
	-- Purpose: != Comparison Operator
	
	return (ValueA(self) == ValueB(self)) and 0 or 1
end)

E_A:RegisterOperator("eq", "wlwl", "n", function(self, ValueA, ValueB)
	-- Purpose: == Comparison Operator
	
	return (ValueA(self) == ValueB(self)) and 1 or 0
end)

/*==============================================================================================
	Section: Conditional Operators
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

E_A:RegisterOperator("is", "wl", "n", function(self, Value)
	-- Purpose: Is Valid
	
	local Entity = Value(self)
	return (Entity and Entity:IsValid()) and 1 or 0
end)

/*==============================================================================================
	Numbers
==============================================================================================*/
E_A:RegisterOperator("get", {"wirelink", "string", "number"} , "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return self:GetWL("NORMAL", A, B) or 0
end)

E_A:RegisterOperator("set", {"wirelink", "string", "number"}, "", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	self:SetWL("NORMAL", A, B, C)
end)

/*==============================================================================================
	String
==============================================================================================*/
E_A:RegisterOperator("get", {"wirelink", "string", "string"} , "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return self:GetWL("STRING", A, B) or ""
end)

E_A:RegisterOperator("set", {"wirelink", "string", "string"}, "", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	self:SetWL("STRING", A, B, C)
end)

/*==============================================================================================
	Entities
==============================================================================================*/
E_A:RegisterOperator("get", {"wirelink", "string", "entity"} , "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return self:GetWL("ENTITY", A, B) or Entity(-1)
end)

E_A:RegisterOperator("set", {"wirelink", "string", "entity"}, "", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	self:SetWL("ENTITY", A, B, C)
end)

/*==============================================================================================
	Entities
==============================================================================================*/
E_A:RegisterOperator("get", {"wirelink", "string", "vector"} , "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	local C = self:GetWL("VECTOR", A, B) or Vector(0, 0, 0)
	return {C.x, C.y, C.z}
end)

E_A:RegisterOperator("set", {"wirelink", "string", "vector"}, "", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	self:SetWL("VECTOR", A, B, Vector(C[1], C[2], C[3]))
end)

/*==============================================================================================
	WL Functions
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("entity", "wl:", "e", function(self, ValueA)
	local A = ValueA(self)
	return A
end)

E_A:RegisterFunction("hasInput", "wl:s", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	if !Entity or !Entity:IsValid() or !Entity.Inputs then return 0 end
	if !Entity.Inputs[B] then return 0 else return 1 end
end)

E_A:RegisterFunction("hasOutput", "wl:s", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	if !Entity or !Entity:IsValid() or !Entity.Outputs then return 0 end
	if !Entity.Outputs[B] then return 0 else return 1 end
end)

/*==============================================================================================
	Context Stuffs
==============================================================================================*/
function E_A.Context:SetWL(Type, Entity, Name, Value)
	if !Entity or !Entity:IsValid() or !Entity.Inputs then return end
	
	local Input = Entity.Inputs[Name]
	if !Input or Input.Type ~= Type then return end
	
	local Que = self.WireLinkQue[Entity]
	if !Que then
		Que = {}
		self.WireLinkQue[Entity] = Que
	end
	
	Que[Name] = Value
end

function E_A.Context:GetWL(Type, Entity, Name)
	if !Entity or !Entity:IsValid() or !Entity.Outputs then return end
	
	local Output = Entity.Outputs[Name]
	if !Output or Output.Type ~= Type then return end
	return Output.Value
end

local Trigger = WireLib.TriggerInput

API.AddHook("TriggerOutputs", function(Gate)
	for Entity, Que in pairs( Gate.Context.WireLinkQue ) do
		for Key, Value in pairs( Que ) do
			WireLib.TriggerInput(Entity, Key, Value)
		end
	end
end)