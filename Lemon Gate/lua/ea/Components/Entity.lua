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
E_A:RegisterClass("entity", "e", Entity)

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
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

E_A:RegisterOperator("is", "e", "n", function(self, Value)
	-- Purpose: Is Valid
	
	local Entity = Value(self)
	return (Entity and Entity:IsValid()) and 1 or 0
end)

E_A:RegisterOperator("is", "e", "n", function(self, Value)
	-- Purpose: Is Valid
	
	local Entity = Value(self)
	return (Entity and Entity:IsValid()) and 0 or 1
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
==============================================================================================*/
local tostring = tostring

E_A:RegisterFunction("toString", "e", "s", function(self, Value)
	return tostring( Value(self) )
end)

E_A:RegisterOperator("cast", "se", "s", function(self, Value, ConvertType)
	return tostring( Value(self) )
end)

/*==============================================================================================
	Section: Entity is somthing
==============================================================================================*/
E_A:RegisterFunction("isPlayer", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsPlayer() then return 1 end
	return 0
end)

E_A:RegisterFunction("isNPC", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsNPC() then return 1 end
	return 0
end)

E_A:RegisterFunction("isVehicle", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsVehicle() then return 1 end
	return 0
end)

E_A:RegisterFunction("isWorld", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsWorld() then return 1 end
	return 0
end)

E_A:RegisterFunction("isOnGround", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsOnGround() then return 1 end
	return 0
end)

E_A:RegisterFunction("isUnderWater", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:WaterLevel() > 0 then return 1 end
	return 0
end)

E_A:RegisterFunction("isValid", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() then return 1 end
	return 0
end)

/*==============================================================================================
	Section: Entity Info
==============================================================================================*/
E_A:RegisterFunction("class", "e:", "s", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return "" end
	
	return Entity:GetClass()
end)

E_A:RegisterFunction("model", "e:", "s", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return "" end
	
	return Entity:GetModel()
end)

E_A:RegisterFunction("name", "e:", "s", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return "" end
	
	return Entity:GetName() or Entity:Name()
end)

E_A:RegisterFunction("health", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return 0 end
	
	return Entity:Health()
end)

E_A:RegisterFunction("radius", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return 0 end
	
	return Entity:BoundingRadius()
end)

/*==============================================================================================
	Section: Force
==============================================================================================*/
E_A:RegisterFunction("applyForce", "e:v", "", function(self, ValueA, ValueB)
	local Entity, V = ValueA(self), ValueB(self)
	
	if !Entity or !Entity:IsValid() then return end
	
	if !E_A.IsOwner(self.Player, Entity) then return  end
	
	local Phys = Entity:GetPhysicsObject()
	
	if Phys then
		Phys:ApplyForceCenter(Vector(V[1], V[2], V[3]))
	end
end)

E_A:RegisterFunction("applyOffsetForce", "e:vv", "", function(self, ValueA, ValueB, ValueC)
	local Entity, B, C = ValueA(self), ValueB(self), ValueC(self)
	
	if !Entity or !Entity:IsValid() then return end
	
	if !E_A.IsOwner(self.Player, Entity) then return end
	
	local Phys = Entity:GetPhysicsObject()
	
	if Phys then
		Phys:ApplyForceOffset(Vector(B[1], B[2], B[3]), Vector(C[1], C[2], C[3]))
	end
end)

/*==============================================================================================
	Section: Casting and converting
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

local tostring = tostring

E_A:RegisterFunction("toString", "e", "s", function(self, Value)
	return tostring(Value(self))
end)

E_A:RegisterFunction("toString", "e:", "s", function(self, Value)
	return tostring(Value(self))
end)

E_A:RegisterOperator("cast", "se", "s", function(self, Value, ConvertType)
	return tostring(Value(self))
end)
