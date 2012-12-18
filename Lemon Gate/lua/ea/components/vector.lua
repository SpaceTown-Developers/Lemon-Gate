/*==============================================================================================
	Expression Advanced: Vectors.
	Purpose: Vectors are 3d points in space.
	Note: Basicaly just E2's vector ext converted over.
	Creditors: Rusketh, E2's Authors.
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

E_A:RegisterClass("vector", "v", {0, 0, 0})

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

E_A:WireModClass("vector", "VECTOR", Input, Output)

/*==============================================================================================
	Var Operators
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterOperator("assign", "v", "", function(self, ValueOp, Memory)
	-- Purpose: Assigns a number to memory
	
	self.Delta[Memory] = self.Memory[Memory]
	
	self.Memory[Memory] = ValueOp(self)
	
	self.Click[Memory] = true
end)

E_A:RegisterOperator("variable", "v", "v", function(self, Memory)
	-- Purpose: Assigns a number to memory
	
	return self.Memory[Memory]
end)

E_A:RegisterOperator("delta", "v", "v", function(self, Memory)
	-- Purpose: ~ Delta Operator
	
	local V = self.Memory[Memory]
	
	local D = self.Delta[Memory]
	
	if !D then return V end
	
	return {V[1] - D[1], V[2] - D[2], V[3] - D[3]} 
end)

/*==============================================================================================
	Section: Comparison Operators
==============================================================================================*/
E_A:RegisterOperator("eq", "vv", "n", function(self, ValueA, ValueB)
	-- Purpose: Is Valid
	
	local A, B = ValueA(self), ValueB(self)
	
	if A[1] - B[1] <= Round && B[1] - A[1] <= Round &&
	   A[2] - B[2] <= Round && B[2] - A[2] <= Round &&
	   A[3] - B[3] <= Round && B[3] - A[3] <= Round
	   then return 1 else return 0 end
end)

E_A:RegisterOperator("negeq", "vv", "n", function(self, ValueA, ValueB)
	-- Purpose: Is Valid
	
	local A, B = ValueA(self), ValueB(self)
	
	if A[1] - B[1] > Round or B[1] - A[1] > Round or
	   A[2] - B[2] > Round or B[2] - A[2] > Round or
	   A[3] - B[3] > Round or B[3] - A[3] > Round
	   then return 1 else return 0 end
end)

/*==============================================================================================
	Section: Conditonal Operators
==============================================================================================*/
E_A:RegisterOperator("is", "v", "n", function(self, Value)
	-- Purpose: Is Valid
	
	local V = Value(self)
	
	if V[1] > Round or -V[1] > Round or
	   V[2] > Round or -V[2] > Round or
	   V[3] > Round or -V[3] > Round then
	   return 1 else return 0 end
end)

E_A:RegisterOperator("not", "v", "n", function(self, Value)
	-- Purpose: Is Valid
	
	local V = Value(self)
	
	if V[1] < Round or -V[1] < Round or
	   V[2] < Round or -V[2] < Round or
	   V[3] < Round or -V[3] < Round
	   then return 1 else return 0 end
end)

/*==============================================================================================
	Co-ords
==============================================================================================*/
E_A:RegisterFunction("vec", "nnn", "v", function(self, ValueA, ValueB, ValueC)
	return {ValueA(self), ValueB(self), ValueC(self)}
end)

/**********************************************************************************************/

E_A:RegisterFunction("x", "v:", "n", function(self, Value)
	return Value(self)[1]
end)

E_A:RegisterFunction("y", "v:", "n", function(self, Value)
	return Value(self)[2]
end)

E_A:RegisterFunction("z", "v:", "n", function(self, Value)
	return Value(self)[3]
end)

/**********************************************************************************************/

E_A:RegisterFunction("setX", "v:n", "", function(self, ValueA, ValueB)
	ValueA(self)[1] = ValueB(self)
end)

E_A:RegisterFunction("setY", "v:n", "", function(self, ValueA, ValueB)
	ValueA(self)[2] = ValueB(self)
end)

E_A:RegisterFunction("setZ", "v:n", "", function(self, ValueA, ValueB)
	ValueA(self)[3] = ValueB(self)
end)

/*==============================================================================================
	Section: Vector Mathmatical Operators
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterOperator("exponent", "vv", "v", function(self, ValueA, ValueB)
	-- Purpose: ^ Math Operator
	
	local A, B = ValueA(self), ValueB(self)
	return {A[1] ^ B[1], A[2] ^ B[2], A[3] ^ B[3]}
end)

E_A:RegisterOperator("multiply", "vv", "v", function(self, ValueA, ValueB)
	-- Purpose: * Math Operator
	
	local A, B = ValueA(self), ValueB(self)
	return {A[1] * B[1], A[2] * B[2], A[3] * B[3]}
end)

E_A:RegisterOperator("division", "vv", "v", function(self, ValueA, ValueB)
	-- Purpose: / Math Operator
	
	local A, B = ValueA(self), ValueB(self)
	return {A[1] / B[1], A[2] / B[2], A[3] / B[3]}
end)

E_A:RegisterOperator("modulus", "vv", "v", function(self, ValueA, ValueB)
	-- Purpose: % Math Operator
	
	local A, B = ValueA(self), ValueB(self)
	return {A[1] % B[1], A[2] % B[2], A[3] % B[3]}
end)

E_A:RegisterOperator("addition", "vv", "v", function(self, ValueA, ValueB)
	-- Purpose: + Math Operator
	
	local A, B = ValueA(self), ValueB(self)
	return {A[1] + B[1], A[2] + B[2], A[3] + B[3]}
end)

E_A:RegisterOperator("subtraction", "vv", "v", function(self, ValueA, ValueB)
	-- Purpose: - Math Operator
	
	local A, B = ValueA(self), ValueB(self)
	return {A[1] - B[1], A[2] - B[2], A[3] - B[3]}
end)

E_A:RegisterOperator("negative", "v", "v", function(self, Value)
	-- Purpose: Negation Operator
	
	local V = Value(self)
	
	return {-V[1], -V[2], -V[3]}
end)

/*==============================================================================================
	Section: Number Mathmatical Operators
==============================================================================================*/
E_A:RegisterOperator("exponent", "vn", "v", function(self, ValueA, ValueB)
	-- Purpose: ^ Math Operator
	
	local A, B = ValueA(self), ValueB(self)
	return {A[1] ^ B, A[2] ^ B, A[3] ^ B}
end)

E_A:RegisterOperator("multiply", "vn", "v", function(self, ValueA, ValueB)
	-- Purpose: * Math Operator
	
	local A, B = ValueA(self), ValueB(self)
	return {A[1] * B, A[2] * B, A[3] * B}
end)

E_A:RegisterOperator("division", "vn", "v", function(self, ValueA, ValueB)
	-- Purpose: / Math Operator
	
	local A, B = ValueA(self), ValueB(self)
	return {A[1] / B, A[2] / B, A[3] / B}
end)

E_A:RegisterOperator("modulus", "vn", "v", function(self, ValueA, ValueB)
	-- Purpose: % Math Operator
	
	local A, B = ValueA(self), ValueB(self)
	return {A[1] % B, A[2] % B, A[3] % B}
end)

E_A:RegisterOperator("addition", "vn", "v", function(self, ValueA, ValueB)
	-- Purpose: + Math Operator
	
	local A, B = ValueA(self), ValueB(self)
	return {A[1] + B, A[2] + B, A[3] + B}
end)

E_A:RegisterOperator("subtraction", "vn", "v", function(self, ValueA, ValueB)
	-- Purpose: - Math Operator
	
	local A, B = ValueA(self), ValueB(self)
	return {A[1] - B, A[2] - B, A[3] - B}
end)

/*==============================================================================================
	Lenth and Distance
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterOperator("lenth", "v", "n", function(self, Value)
	local V = Value(self)
	return (V[1] * V[1] + V[2] * V[2] + V[3] * V[3]) ^ 0.5
end)

E_A:RegisterFunction("lenth", "v:", "n", function(self, Value)
	local V = Value(self)
	return (V[1] * V[1] + V[2] * V[2] + V[3] * V[3]) ^ 0.5
end)

E_A:RegisterFunction("distance", "v:v", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	
	local CX, CY, CZ = A[1] - B[1], A[2] - B[2], A[3] - B[3]
	return (CX * CX + CY * CY + CZ * CZ) ^ 0.5
end)

E_A:RegisterFunction("length2", "v:", "n", function(self, Value)
	local V = Value(self)
	return (V[1] * V[1] + V[2] * V[2] + V[3] * V[3])
end)

E_A:RegisterFunction("distance2", "v:v", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	
	local CX, CY, CZ = A[1] - B[1], A[2] - B[2], A[3] - B[3]
	return (CX * CX + CY * CY + CZ * CZ)
end)

/**********************************************************************************************/

E_A:RegisterFunction("normalized", "v:", "v", function(self, Value)
	local V = Value(self)
	local Len = (V[1] * V[1] + V[2] * V[2] + V[3] * V[3]) ^ 0.5
	
	if Len > Round then
		return { V[1] / Len, V[2] / Len, V[3] / Len }
	else
		return { 0, 0, 0 }
	end
end)

E_A:RegisterFunction("dot", "v:v", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	
	return A[1] * B[1] + A[2] * B[2] + A[3] * B[3]
end)

E_A:RegisterFunction("cross", "v:v", "v", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	
	return {
		A[2] * B[3] - A[3] * B[2],
		A[3] * B[1] - A[1] * B[3],
		A[1] * B[2] - A[2] * B[1]
	}
end)

/*==============================================================================================
	World and Local
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

E_A:RegisterFunction("toWorld", "vava", "v", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, B, C = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	
	local Av = Vector(A[1], A[2], A[3])
	local Bv = Angle(B[1], B[2], B[3])
	local Cv = Vector(C[1], C[2], C[3])
	local Dv = Angle(D[1], D[2], D[3])
	
	local V = LocalToWorld(Av, Ab, Ac, Ad)
	return {V.x, V.y, V.z}
end)

E_A:RegisterFunction("toWorldAngle", "vava", "v", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, B, C = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	
	local Av = Vector(A[1], A[2], A[3])
	local Bv = Angle(B[1], B[2], B[3])
	local Cv = Vector(C[1], C[2], C[3])
	local Dv = Angle(D[1], D[2], D[3])
	
	local _, V = LocalToWorld(Av, Ab, Ac, Ad)
	return {V.p, V.y, V.r}
end)

/**********************************************************************************************/

E_A:RegisterFunction("toLocal", "vava", "v", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, B, C = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	
	local Av = Vector(A[1], A[2], A[3])
	local Bv = Angle(B[1], B[2], B[3])
	local Cv = Vector(C[1], C[2], C[3])
	local Dv = Angle(D[1], D[2], D[3])
	
	local V = WorldToLocal(Av, Ab, Ac, Ad)
	return {V.x, V.y, V.z}
end)

E_A:RegisterFunction("toLocalAngle", "vava", "a", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, B, C = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	
	local Av = Vector(A[1], A[2], A[3])
	local Bv = Angle(B[1], B[2], B[3])
	local Cv = Vector(C[1], C[2], C[3])
	local Dv = Angle(D[1], D[2], D[3])
	
	local _, V = WorldToLocal(Av, Ab, Ac, Ad)
	return {V.p, V.y, V.r}
end)

/******************************************************************************/

E_A:RegisterFunction("bearing", "vav", "n", function(self, ValueA, ValueB, ValueC)
	local A, B, B = ValueA(self), ValueB(self), ValueC(self)
	
	local Av = Vector(A[1], A[2], A[3])
	local Bv = Angle(B[1], B[2], B[3])
	local Cv = Vector(C[1], C[2], C[3])
	
	local V = WorldToLocal(Cv, Angle(0,0,0), Av, Bv)
	local Len = V:Length()
	
	if (Len < Round) then return 0 end
	return Rad2Deg * Asin(V.z / Len)
end)

E_A:RegisterFunction("elevation", "vav", "n", function(self, ValueA, ValueB, ValueC)
	local A, B, B = ValueA(self), ValueB(self), ValueC(self)
	
	local Av = Vector(A[1], A[2], A[3])
	local Bv = Angle(B[1], B[2], B[3])
	local Cv = Vector(C[1], C[2], C[3])
	
	local V = WorldToLocal(Cv, Angle(0,0,0), Av, Bv)
	return Rad2Deg *- Atan2(V.y, V.x)
end)

E_A:RegisterFunction("heading", "vav", "n", function(self, ValueA, ValueB, ValueC)
	local A, B, B = ValueA(self), ValueB(self), ValueC(self)
	
	local Av = Vector(A[1], A[2], A[3])
	local Bv = Angle(B[1], B[2], B[3])
	local Cv = Vector(C[1], C[2], C[3])
	
	local V = WorldToLocal(Cv, Angle(0,0,0), Av, Bv)
	local Bearing = Rad2Deg *- Atan2(V.y, V.x)

	local Len = V:Length()
	if (Len < Round) then return { 0, Bearing, 0 } end
	return { Rad2Deg * Asin(V.z / Len), Bearing, 0 }
end)

/*==============================================================================================
	To Angle
==============================================================================================*/
E_A:RegisterOperator("cast", "av", "a", function(self, Value)
	local V = Value(self)
	local A = Vector(V[1], V[2], V[3]):Angle()
	return { A.p, A.y, A.r }
end)

E_A:RegisterFunction("toAngle", "v:", "a", function(self, Value)
	local V = Value(self)
	local A = Vector(V[1], V[2], V[3]):Angle()
	return { A.p, A.y, A.r }
end)

E_A:RegisterFunction("toAngle", "v:v", "a", function(self, ValueA, ValueB)
	local B, C = ValueA(self), ValueB(self)
	local A = Vector(B[1], B[2], B[3]):AngleEx(Vector(C[1], C[2], C[3]))
	return { A.p, A.y, A.r }
end)

/*==============================================================================================
	To String
==============================================================================================*/
local FormatStr = string.format

E_A:RegisterOperator("cast", "sv", "s", function(self, Value)
	local V = Value(self)
	return FormatStr("Vector(%i, %i, %i)", V[1], V[2], V[3])
end)

E_A:RegisterFunction("toString", "v:", "s", function(self, Value)
	local V = Value(self)
	return FormatStr("Vector(%i, %i, %i)", V[1], V[2], V[3])
end)

E_A:RegisterFunction("toString", "v", "s", function(self, Value)
	local V = Value(self)
	return FormatStr("Vector(%i, %i, %i)", V[1], V[2], V[3])
end)
