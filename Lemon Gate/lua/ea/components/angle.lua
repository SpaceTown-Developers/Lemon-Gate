/*==============================================================================================
	Expression Advanced: Angle.
	Purpose: Angles are vectors but no really.
	Note: Basicaly just E2's Angle ext converted over.
	Creditors: Rusketh, E2's Authors.
==============================================================================================*/
local E_A = LemonGate

local Round = 0.0000001000000

local function AngNum( N )
	return (N + 180) % 360 - 180
end

local function NewAng( P, Y, R )
	return { P, Y, R }
end

/*==============================================================================================
	Class & WireMod
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterClass("angle", "a", {0, 0, 0})
E_A:RegisterOperator("assign", "a", "", E_A.AssignOperator)
E_A:RegisterOperator("variable", "a", "a", E_A.VariableOperator)
E_A:RegisterOperator("delta", "a", "a", E_A.DeltaOperator)

local function Input(self, Memory, Value)
	self.Delta[Memory] = self.Memory[Memory]
	self.Memory[Memory] = NewAng(Value.p, Value.y, Value.r)
end

local function Output(self, Memory)
	local V = self.Memory[Memory]
	return Angle(V[1], V[2], V[3])
end

E_A:WireModClass("angle", "ANGLE", Input, Output)

/*==============================================================================================
	Section: Comparison Operators
==============================================================================================*/
E_A:RegisterOperator("eq", "aa", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	if A[1] - B[1] <= Round && B[1] - A[1] <= Round &&
	   A[2] - B[2] <= Round && B[2] - A[2] <= Round &&
	   A[3] - B[3] <= Round && B[3] - A[3] <= Round
	   then return 1 else return 0 end
end)

E_A:RegisterOperator("negeq", "aa", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	if A[1] - B[1] > Round or B[1] - A[1] > Round or
	   A[2] - B[2] > Round or B[2] - A[2] > Round or
	   A[3] - B[3] > Round or B[3] - A[3] > Round
	   then return 1 else return 0 end
end)

E_A:RegisterOperator("eqless", "aa", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	if B[1] - A[1] <= Round &&
	   B[2] - A[2] <= Round &&
	   B[3] - A[3] <= Round
	   then return 1 else return 0 end
end)

E_A:RegisterOperator("eqgreater", "aa", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	if A[1] - B[1] <= Round &&
	   A[2] - B[2] <= Round &&
	   A[3] - B[3] <= Round
	   then return 1 else return 0 end
end)

E_A:RegisterOperator("less", "aa", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	if B[1] - A[1] > Round &&
	   B[2] - A[2] > Round &&
	   B[3] - A[3] > Round
	   then return 1 else return 0 end
end)

E_A:RegisterOperator("greater", "aa", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	if A[1] - B[1] > Round &&
	   A[2] - B[2] > Round &&
	   A[3] - B[3] > Round
	   then return 1 else return 0 end
end)

/*==============================================================================================
	Section: Conditional Operators
==============================================================================================*/
E_A:RegisterOperator("is", "a", "n", function(self, Value)
	local V = Value(self)
	if V[1] > Round or -V[1] > Round or
	   V[2] > Round or -V[2] > Round or
	   V[3] > Round or -V[3] > Round then
	   return 1 else return 0 end
end)

E_A:RegisterOperator("not", "a", "n", function(self, Value)
	local V = Value(self)
	if V[1] < Round or -V[1] < Round or
	   V[2] < Round or -V[2] < Round or
	   V[3] < Round or -V[3] < Round
	   then return 1 else return 0 end
end)

/*==============================================================================================
	Angles
==============================================================================================*/
E_A:RegisterFunction("ang", "nnn", "a", function(self, ValueA, ValueB, ValueC)
	return {ValueA(self), ValueB(self), ValueC(self)}
end)

/**********************************************************************************************/

E_A:RegisterFunction("p", "a:", "n", function(self, Value)
	return Value(self)[1]
end)

E_A:RegisterFunction("y", "a:", "n", function(self, Value)
	return Value(self)[2]
end)

E_A:RegisterFunction("r", "a:", "n", function(self, Value)
	return Value(self)[3]
end)

/**********************************************************************************************/

E_A:RegisterFunction( "angnorm", "a", "a", function( self, ValueA ) 
	local Ang, tValueA = ValueA( self )
 
	return {(Ang[1] + 180) % 360 - 180,(Ang[2] + 180) % 360 - 180,(Ang[3] + 180) % 360 - 180}
end ) 

/**********************************************************************************************/

E_A:RegisterFunction("setP", "a:n", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { B, A[2], A[3] }
end)

E_A:RegisterFunction("setY", "a:n", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1], B, A[3] }
end)

E_A:RegisterFunction("setR", "a:n", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1], A[2], B }
end)

/*==============================================================================================
	Section: Directional
==============================================================================================*/
E_A:RegisterFunction("forward", "a:", "v", function(self, Value)
	local A = Value(self)
	local V = Angle(A[1], A[2], A[3]):Forward()
	return NewAng(V.x, V.y, V.z)
end)

E_A:RegisterFunction("right", "a:", "v", function(self, Value)
	local A = Value(self)
	local V = Angle(A[1], A[2], A[3]):Right()
	return NewAng(V.x, V.y, V.z)
end)

E_A:RegisterFunction("up", "a:", "v", function(self, Value)
	local A = Value(self)
	local V = Angle(A[1], A[2], A[3]):Up()
	return NewAng(V.x, V.y, V.z)
end)

/*==============================================================================================
	Section: Angle Mathematical Operators
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterOperator("exponent", "aa", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return NewAng(A[1] ^ B[1], A[2] ^ B[2], A[3] ^ B[3])
end)

E_A:RegisterOperator("multiply", "aa", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return NewAng(A[1] * B[1], A[2] * B[2], A[3] * B[3])
end)

E_A:RegisterOperator("division", "aa", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return NewAng(A[1] / B[1], A[2] / B[2], A[3] / B[3])
end)

E_A:RegisterOperator("modulus", "aa", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return NewAng(A[1] % B[1], A[2] % B[2], A[3] % B[3])
end)

E_A:RegisterOperator("addition", "aa", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return NewAng(A[1] + B[1], A[2] + B[2], A[3] + B[3])
end)

E_A:RegisterOperator("subtraction", "aa", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return NewAng(A[1] - B[1], A[2] - B[2], A[3] - B[3])
end)

E_A:RegisterOperator("negative", "a", "a", function(self, Value)
	local V = Value(self)
	return NewAng(-V[1], -V[2], -V[3])
end)

/*==============================================================================================
	Section: Number Mathematical Operators
==============================================================================================*/
E_A:RegisterOperator("exponent", "an", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return NewAng(A[1] ^ B, A[2] ^ B, A[3] ^ B)
end)

E_A:RegisterOperator("multiply", "an", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return NewAng(A[1] * B, A[2] * B, A[3] * B)
end)

E_A:RegisterOperator("division", "an", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return NewAng(A[1] / B, A[2] / B, A[3] / B)
end)

E_A:RegisterOperator("modulus", "an", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return NewAng(A[1] % B, A[2] % B, A[3] % B)
end)

E_A:RegisterOperator("addition", "an", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return NewAng(A[1] + B, A[2] + B, A[3] + B)
end)

E_A:RegisterOperator("subtraction", "an", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return NewAng(A[1] - B, A[2] - B, A[3] - B)
end)

/*==============================================================================================
	Ceil / Floor / Round
==============================================================================================*/
local MathFloor = math.floor -- Speed

E_A:RegisterFunction("ceil", "a", "a", function(self, Value)
	local V = Value(self)
	return {V[1] - V[1] % -1, V[2] - V[2] % -1, V[3] - V[3] % -1}
end)

E_A:RegisterFunction("floor", "a", "a", function(self, Value)
	local V = Value(self)
	return { MathFloor(V[1]), MathFloor(V[2]), MathFloor(V[3]) }
end)

E_A:RegisterFunction("ceil", "an", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	local Shift = 10 ^ MathFloor(B + 0.5)
	return { A[1] - ((A[1] * Shift) % -1) / Shift,
			 A[2] - ((A[2] * Shift) % -1) / Shift,
			 A[3] - ((A[3] * Shift) % -1) / Shift }
end)

E_A:RegisterFunction("round", "a", "a", function(self, Value)
	local V = Value(self)
	return { V[1] - (V[1] + 0.5) % 1 + 0.5,
			 V[2] - (V[2] + 0.5) % 1 + 0.5,
			 V[3] - (V[3] + 0.5) % 1 + 0.5 }
end)

E_A:RegisterFunction("round", "an", "a", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	local Shift = 10 ^ MathFloor(B + 0.5)
	return { MathFloor(A[1] * Shift+0.5) / Shift,
			 MathFloor(A[2] * Shift+0.5) / Shift,
			 MathFloor(A[3] * Shift+0.5) / Shift }
end)

/*==============================================================================================
	Clamping and Inrange
==============================================================================================*/
local Clamp = math.Clamp

E_A:RegisterFunction("clamp", "aaa", "a", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	return { Clamp(A[1], B[1], C[1]), Clamp(A[2], B[2], C[2]), Clamp(A[3], B[3], C[3]) }
end)

E_A:RegisterFunction("inrange", "aaa", "n", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	if A[1] < B[1] or A[1] > C[1] then return 0
	elseif A[2] < B[2] or A[2] > C[2] then return 0
	elseif A[3] < B[3] or A[3] > C[3] then return 0
	else return 1 end
end)

/*==============================================================================================
	Entity Helpers
==============================================================================================*/
E_A:RegisterFunction("toWorld", "e:a", "a", function(self, ValueA, ValueB)
	local Entity, B = ValueA(self), ValueB(self)
	if !Entity or !Entity:IsValid() then return {0, 0, 0} end
	local Ang = Entity:LocalToWorldAngles( Angle( B[1], B[2], B[3] ) )
	return { Ang.p, Ang.y, Ang.r }
end)

E_A:RegisterFunction("toLocal", "e:a", "a", function(self, ValueA, ValueB)
	local Entity, B = ValueA(self), ValueB(self)
	if !Entity or !Entity:IsValid() then return {0, 0, 0} end
	local Ang = Entity:WorldToLocalAngles( Angle( B[1], B[2], B[3] ) )
	return { Ang.p, Ang.y, Ang.r }
end)

/*==============================================================================================
	To String
==============================================================================================*/
local FormatStr = string.format

E_A:RegisterOperator("cast", "sa", "s", function(self, Value)
	local V = Value(self)
	return FormatStr("Angle(%f, %f, %f)", V[1], V[2], V[3])
end)

E_A:RegisterFunction("toString", "a:", "s", function(self, Value)
	local V = Value(self)
	return FormatStr("Angle(%f, %f, %f)", V[1], V[2], V[3])
end)

E_A:RegisterFunction("toString", "a", "s", function(self, Value)
	local V = Value(self)
	return FormatStr("Angle(%f, %f, %f)", V[1], V[2], V[3])
end)


