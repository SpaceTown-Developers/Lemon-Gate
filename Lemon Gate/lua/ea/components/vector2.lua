/*==============================================================================================
	Expression Advanced: 2D Vectors.
	Purpose: 2D Vectors
	Note: Basicaly just E2's vector ext converted over.
	Creditors: Oskar, Rusketh, E2's Authors.
==============================================================================================*/
local E_A = LemonGate

local Round = 0.0000001000000

local Vector = Vector
local Angle = Angle
local LocalToWorld = LocalToWorld
local WorldToLocal = WorldToLocal

local PI = math.pi
local Atan2 = math.atan2
local Asin = math.asin
local Rad2Deg = 180 / PI
local Deg2Rad = PI / 180

/*==============================================================================================
	Class & WireMod
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterClass("vector2", "v2", {0, 0})
E_A:RegisterOperator("assign", "v2", "", E_A.AssignOperator)
E_A:RegisterOperator("variable", "v2", "v2", E_A.VariableOperator)
E_A:RegisterOperator("delta", "v2", "v2", E_A.DeltaOperator)

/*
local function Input(self, Memory, Value)
	-- Purpose: Used to set Memory via a wired input.
	
	self.Delta[Memory] = self.Memory[Memory]
	
	self.Memory[Memory] = {Value.x, Value.y, Value.z}
end

local function Output(self, Memory)
	-- Purpose: Used to get Memory for a wired output.
	
	local V = self.Memory[Memory]
	
	return Vector(V[1], V[2], V[3])
end

E_A:WireModClass("vector2", "VECTOR2", Input, Output)*/

/*==============================================================================================
	Section: Comparison Operators
==============================================================================================*/
E_A:RegisterOperator("eq", "v2v2", "n", function(self, ValueA, ValueB)
	-- Purpose: Is Valid
	
	local A, B = ValueA(self), ValueB(self)
	
	if A[1] - B[1] <= Round && B[1] - A[1] <= Round &&
	   A[2] - B[2] <= Round && B[2] - A[2] <= Round
	   then return 1 else return 0 end
end)

E_A:RegisterOperator("negeq", "v2v2", "n", function(self, ValueA, ValueB)
	-- Purpose: Is Valid
	
	local A, B = ValueA(self), ValueB(self)
	
	if A[1] - B[1] > Round or B[1] - A[1] > Round or
	   A[2] - B[2] > Round or B[2] - A[2] > Round
	   then return 1 else return 0 end
end)

/*==============================================================================================
	Section: Conditional Operators
==============================================================================================*/
E_A:RegisterOperator("is", "v2", "n", function(self, Value)
	-- Purpose: Is Valid
	
	local V = Value(self)
	
	if V[1] > Round or -V[1] > Round or
	   V[2] > Round or -V[2] > Round then
	   return 1 else return 0 end
end)

E_A:RegisterOperator("not", "v2", "n", function(self, Value)
	-- Purpose: Is Valid
	
	local V = Value(self)
	
	if V[1] < Round or -V[1] < Round or
	   V[2] < Round or -V[2] < Round
	   then return 1 else return 0 end
end)

/*==============================================================================================
	Coordinates
==============================================================================================*/
E_A:RegisterFunction("vec2", "nn", "v2", function(self, ValueA, ValueB)
	return {ValueA(self), ValueB(self)}
end)

E_A:RegisterFunction("vec2", "v", "v2", function(self, ValueA)
    local V = ValueA(self)
	return {V[1], V[2]}
end)

E_A:RegisterOperator("cast", "vv2", "v", function(self, Value)
	local V = Value(self)
	return { V[1], V[2], 0 }
end)

E_A:RegisterOperator("cast", "v2v", "v2", function(self, Value)
	local V = Value(self)
	return { V[1], V[2] }
end)

/**********************************************************************************************/

E_A:RegisterFunction("x", "v2:", "n", function(self, Value)
	return Value(self)[1]
end)

E_A:RegisterFunction("y", "v2:", "n", function(self, Value)
	return Value(self)[2]
end)

/**********************************************************************************************/

E_A:RegisterFunction("setX", "v2:n", "", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { B, A[2] }
end)

E_A:RegisterFunction("setY", "v2:n", "", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1], B }
end)

/*==============================================================================================
	Section: Vector Mathematical Operators
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterOperator("exponent", "v2v2", "v2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return {A[1] ^ B[1], A[2] ^ B[2]}
end)

E_A:RegisterOperator("multiply", "v2v2", "v2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return {A[1] * B[1], A[2] * B[2]}
end)

E_A:RegisterOperator("division", "v2v2", "v2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return {A[1] / B[1], A[2] / B[2]}
end)

E_A:RegisterOperator("modulus", "v2v2", "v2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return {A[1] % B[1], A[2] % B[2]}
end)

E_A:RegisterOperator("addition", "v2v2", "v2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return {A[1] + B[1], A[2] + B[2]}
end)

E_A:RegisterOperator("subtraction", "v2v2", "v2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return {A[1] - B[1], A[2] - B[2]}
end)

E_A:RegisterOperator("negative", "v2", "v2", function(self, Value)
	local V = Value(self)
	return {-V[1], -V[2]}
end)

/*==============================================================================================
	Section: Number Mathematical Operators
==============================================================================================*/
E_A:RegisterOperator("exponent", "v2n", "v2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return {A[1] ^ B, A[2] ^ B}
end)

E_A:RegisterOperator("multiply", "v2n", "v2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return {A[1] * B, A[2] * B}
end)

E_A:RegisterOperator("division", "v2n", "v2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return {A[1] / B, A[2] / B}
end)

E_A:RegisterOperator("modulus", "v2n", "v2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return {A[1] % B, A[2] % B}
end)

E_A:RegisterOperator("addition", "v2n", "v2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return {A[1] + B, A[2] + B}
end)

E_A:RegisterOperator("subtraction", "v2n", "v2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return {A[1] - B, A[2] - B}
end)

/*==============================================================================================
	length and Distance
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterOperator("length", "v2", "n", function(self, Value)
	local V = Value(self)
	return (V[1] * V[1] + V[2] * V[2]) ^ 0.5
end)

E_A:RegisterFunction("length", "v2:", "n", function(self, Value)
	local V = Value(self)
	return (V[1] * V[1] + V[2] * V[2]) ^ 0.5
end)

E_A:RegisterFunction("distance", "v2:v2", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	local CX, CY = A[1] - B[1], A[2] - B[2]
	return (CX * CX + CY * CY) ^ 0.5
end)

E_A:RegisterFunction("length2", "v2:", "n", function(self, Value)
	local V = Value(self)
	return (V[1] * V[1] + V[2] * V[2])
end)

E_A:RegisterFunction("distance2", "v2:v2", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	local CX, CY = A[1] - B[1], A[2] - B[2]
	return (CX * CX + CY * CY)
end)

/**********************************************************************************************/

E_A:RegisterFunction("normalized", "v2:", "v2", function(self, Value)
	local V = Value(self)
	local Len = (V[1] * V[1] + V[2] * V[2]) ^ 0.5
	
	if Len > Round then
		return { V[1] / Len, V[2] / Len}
	else
		return { 0, 0 }
	end
end)

E_A:RegisterFunction("dot", "v2:v2", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return A[1] * B[1] + A[2] * B[2]
end)

E_A:RegisterFunction("cross", "v2:v2", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return A[1] * B[2] - A[2] * B[1]
end)

/*==============================================================================================
	To Angle
==============================================================================================*/
E_A:RegisterOperator("cast", "av2", "a", function(self, Value)
	local V = Value(self)
	local A = Vector(V[1], V[2], 0):Angle()
	return { A.p, A.y }
end)

E_A:RegisterFunction("toAngle", "v2:", "n", function(self, Value)
	local V = Value(self)
	return math.atan2( V[2], V[1] ) * 180 / pi
end)

/*==============================================================================================
	To String
==============================================================================================*/
local FormatStr = string.format

E_A:RegisterOperator("cast", "sv2", "s", function(self, Value)
	local V = Value(self)
	return FormatStr("Vector2(%i, %i)", V[1], V[2])
end)

E_A:RegisterFunction("toString", "v2:", "s", function(self, Value)
	local V = Value(self)
	return FormatStr("Vector2(%i, %i)", V[1], V[2])
end)

E_A:RegisterFunction("toString", "v2", "s", function(self, Value)
	local V = Value(self)
	return FormatStr("Vector2(%i, %i)", V[1], V[2])
end)
