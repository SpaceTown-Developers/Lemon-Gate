/*==============================================================================================
	Expression Advanced: Numbers.
	Purpose: Numbers do maths and stuffs.
	Note: Basically just E2's number ext converted over.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local GetLongType = E_A.GetLongType

local Round = 0.0000001000000

local math = math

/*==============================================================================================
	Class & WireMod
==============================================================================================*/
E_A:RegisterClass("number", "n", 0)

local function Input(self, Memory, Value)
	self.Delta[Memory] = self.Memory[Memory]
	self.Memory[Memory] = Value
end

local function Output(self, Memory)
	return self.Memory[Memory]
end

E_A:WireModClass("number", "NORMAL", Input, Output)

-- Note: With out Input function 'Number' would not be inputable, The same goes with Output.

/*==============================================================================================
	Var Operators
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterOperator("assign", "n", "", function(self, ValueOp, Memory)
	self.Delta[Memory] = self.Memory[Memory]
	self.Memory[Memory] = ValueOp(self)
	self.Click[Memory] = true
end)

E_A:RegisterOperator("variable", "n", "n", function(self, Memory)
	-- Purpose: Assigns a number to memory
	
	return self.Memory[Memory]
end)

/*==============================================================================================
	Section: Self Arithmetic Operators
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterOperator("increment", "n", "n", function(self, Memory)
	-- Purpose: ++ Math Operator
	
	self.Delta[Memory] = self.Memory[Memory]
	
	self.Memory[Memory] = self.Memory[Memory] + 1
	
	self.Click[Memory] = true
end)

E_A:RegisterOperator("decrement", "n", "n", function(self, Memory)
	-- Purpose: -- Math Operator
	
	self.Delta[Memory] = self.Memory[Memory]
	
	self.Memory[Memory] = self.Memory[Memory] - 1
	
	self.Click[Memory] = true
end)

E_A:RegisterOperator("delta", "n", "n", function(self, Memory)
	-- Purpose: ~ Delta Operator
	
	return self.Memory[Memory] - (self.Delta[Memory] or 0)
end)

/*==============================================================================================
	Section: Mathematical Operators
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterOperator("exponent", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: ^ Math Operator
	
	return ValueA(self) ^ ValueB(self)
end)

E_A:RegisterOperator("multiply", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: * Math Operator
	
	return ValueA(self) * ValueB(self)
end)

E_A:RegisterOperator("division", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: / Math Operator
	
	return ValueA(self) / ValueB(self)
end)

E_A:RegisterOperator("modulus", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: % Math Operator
	
	return ValueA(self) % ValueB(self)
end)

E_A:RegisterOperator("addition", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: + Math Operator
	
	return ValueA(self) + ValueB(self)
end)

E_A:RegisterOperator("subtraction", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: - Math Operator
	
	return ValueA(self) - ValueB(self)
end)

E_A:RegisterOperator("negative", "n", "n", function(self, Value)
	-- Purpose: Negation Operator
	
	return -Value(self)
end)

/*==============================================================================================
	Section: Comparison Operators
==============================================================================================*/
E_A:RegisterOperator("greater", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: > Comparison Operator
	
	local Res = ValueA(self) - ValueB(self)
	if Res > Round then
		return 1 else return 0
	end
end)

E_A:RegisterOperator("less", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: < Comparison Operator
	
	local Res = ValueA(self) - ValueB(self)
	if -Res > Round then
		return 1 else return 0
	end
end)

E_A:RegisterOperator("eqgreater", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: <= Comparison Operator
	
	local Res = ValueA(self) - ValueB(self)
	if -Res <= Round then
		return 1 else return 0
	end
end)

E_A:RegisterOperator("eqless", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: <= Comparison Operator
	
	local Res = ValueA(self) - ValueB(self)
	if Res <= Round then
		return 1 else return 0
	end
end)

E_A:RegisterOperator("negeq", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: != Comparison Operator
	
	local Res = ValueA(self) - ValueB(self)
	if Res > Round and -Res < Round then
		return 1 else return 0
	end
end)

E_A:RegisterOperator("eq", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: == Comparison Operator
	
	local Res = ValueA(self) - ValueB(self)
	if Res <= Round and -Res <= Round then
		return 1 else return 0
	end
end)

/*==============================================================================================
	Section: Conditional Operators
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterOperator("is", "n", "n", function(self, Value)
	-- Purpose: Is Valid
	
	local V = Value(self)
	if V > Round or -V > Round then
		return 1 else return 0
	end
end)

E_A:RegisterOperator("not", "n", "n", function(self, Value)
	-- Purpose: Is Not Valid
	
	local V = Value(self)
	if V > Round or -V > Round then
		return 0 else return 1
	end
end)

E_A:RegisterOperator("or", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: | Conditional Operator
	
	local A, B = ValueA(self), ValueB(self)
	
	if A > Round or -A > Round then
		return A else return B
	end
end)

E_A:RegisterOperator("and", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: & Conditional Operator
	
	local A, B = ValueA(self), ValueB(self)
	if (A > Round or -A > Round) and (B > Round or -B > Round) then
		return 1 else return 0
	end
end)

/*==============================================================================================
	Section: Casting and converting
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

local tostring = tostring
local tonumber = tonumber

E_A:RegisterFunction("toString", "n", "s", function(self, Value)
	return tostring(Value(self))
end)

E_A:RegisterFunction("toString", "n:", "s", function(self, Value)
	return tostring(Value(self))
end)

E_A:RegisterOperator("cast", "sn", "s", function(self, Value)
	return tostring(Value(self), nil)
end)

/********************************************************************************/

E_A:RegisterFunction("toNumber", "s", "n", function(self, Value)
	return tonumber(Value(self), nil) or 0
end)

E_A:RegisterFunction("toNumber", "s:", "n", function(self, Value)
	return tonumber(Value(self), nil) or 0
end)

E_A:RegisterOperator("cast", "ns", "n", function(self, Value)
	return tonumber(Value(self), nil) or 0 -- The nil is required or the type of Value will become argument 2!
end)

/*==============================================================================================
	Section: Min Max Functions
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("min", "nn", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	if A < B then return A else return B end
end)

E_A:RegisterFunction("min", "nnn", "n", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	
	local V
	if A < B then V = A else v = B end
	if C < V then return C else return V end
end)

E_A:RegisterFunction("min", "nnnn", "n", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, C, D = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	
	local V
	if A < B then V = A else v = B end
	if C < V then V = A else v = B end
	if D < V then return D else return V end
end)

/**********************************************************************************************/

E_A:RegisterFunction("max", "nn", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	if A > B then return A else return B end
end)

E_A:RegisterFunction("max", "nnn", "n", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	
	local V
	if A > B then V = A else v = B end
	if C > V then return C else return V end
end)

E_A:RegisterFunction("max", "nnnn", "n", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, C, D = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	
	local V
	if A > B then V = A else v = B end
	if C > V then V = A else v = B end
	if D > V then return D else return V end
end)

/*==============================================================================================
	Section: General Math
==============================================================================================*/
local MathFloor = math.floor -- Speed

E_A:RegisterFunction("floor", "n", "n", function(self, Value)
	local V = Value(self)
	return MathFloor(V)
end)

E_A:RegisterFunction("abs", "n", "n", function(self, Value)
	local V = Value(self)
	if V >= 0 then return V else return -V end
end)

E_A:RegisterFunction("ceil", "n", "n", function(self, Value)
	local V = Value(self)
	return V - V % -1
end)

E_A:RegisterFunction("ceil", "nn", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	local Shift = 10 ^ MathFloor(B + 0.5)
	return A - ((A * Shift) % -1) / Shift
end)

E_A:RegisterFunction("round", "n", "n", function(self, Value)
	local V = Value(self)
	return V - (V + 0.5) % 1 + 0.5
end)

E_A:RegisterFunction("round", "nn", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	local Shift = 10 ^ MathFloor(B + 0.5)
	return MathFloor(A * Shift+0.5) / Shift
end)

E_A:RegisterFunction("int", "n", "n", function(self, Value)
	local V = Value(self)
	if V >= 0 then return V - V % 1 else return V - V % -1 end
end)

E_A:RegisterFunction("frac", "n", "n", function(self, Value)
	local V = Value(self)
	if V >= 0 then return V % 1 else return V % -1 end
end)

E_A:RegisterFunction("clamp", "nnn", "n", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	if A < B then return B elseif A > C then return C else return A end
end)

E_A:RegisterFunction("inrange", "nnn", "n", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	if A < B or A > C then return 0 else return 1 end
end)

E_A:RegisterFunction("sign", "n", "n", function(self, Value)
	local V = Value(self)
	if V > Round then return 1 elseif V < -Round then return -1 else return 0 end
end)

/*==============================================================================================
	Section: Random Numbers
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

local MathRandom = math.random -- Speed

E_A:RegisterFunction("random", "", "n", MathRandom) -- Probably a good idea =D

E_A:RegisterFunction("random", "n", "n", function(self, Value)
	return MathRandom() * Value(self)
end)

E_A:RegisterFunction("random", "nn", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return A + MathRandom() * (B - A)
end)



E_A:RegisterFunction("randint", "n", "n", function(self, Value)
	return MathRandom( Value(self) )
end)

E_A:RegisterFunction("randint", "nn", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	
	local Temp = A
	if A > B then A = B; B = Temp end
	return MathRandom(A, B)
end)

/*==============================================================================================
	Section: Advanced Math
==============================================================================================*/
local MathExp = math.exp -- Speed

E_A:RegisterFunction("sqrt", "n", "n", function(self, Value)
	return Value(self) ^ (1 / 2)
end)

E_A:RegisterFunction("cbrt", "n", "n", function(self, Value)
	return Value(self) ^ (1 / 3)
end)

E_A:RegisterFunction("root", "nn", "n", function(self, ValueA, ValueB)
	return ValueA(self) ^ (1 / ValueB(self))
end)

E_A:RegisterFunction("exp", "n", "n", function(self, Value)
	return MathExp( Value(self) )
end)

/*==============================================================================================
	Section: Trig
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

local Pi = math.pi -- Speed
local MathAcos = math.acos -- Speed
local MathAsin = math.asin -- Speed
local MathAtan = math.atan -- Speed
local MathAtan2 = math.atan2 -- Speed
local MathCos = math.cos -- Speed
local MathSin = math.sin -- Speed
local MathTan = math.tan -- Speed
local MathCosh = math.cosh -- Speed
local MathSinh = math.sinh -- Speed
local MathTanh = math.tanh -- Speed
local MathAcos = math.acos -- Speed
local MathAsin = math.asin -- Speed
local MathLog = math.log -- Speed
local MathLog10 = math.log10 -- Speed

local deg2rad = Pi / 180
local rad2deg = 180 / Pi
local const_invlog2 = 1 / MathLog(2)

E_A:RegisterFunction("pi", "", "n", function(self)
	return Pi
end)

E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("toRad", "n", "n", function(self, Value)
	return Value(self) * deg2rad
end)

E_A:RegisterFunction("toDeg", "n", "n", function(self, Value)
	return Value(self) * rad2deg
end)

E_A:SetCost(EA_COST_ABNORMAL)

E_A:RegisterFunction("acos", "n", "n", function(self, Value)
	return MathAcos( Value(self) ) * rad2deg
end)

E_A:RegisterFunction("asin", "n", "n", function(self, Value)
	return MathAsin( Value(self) ) * rad2deg
end)

E_A:RegisterFunction("atan", "n", "n", function(self, Value)
	return MathAtan( Value(self) ) * rad2deg
end)

E_A:RegisterFunction("atan", "nn", "n", function(self, ValueA, ValueB)
	return MathAtan2(ValueA(self), ValueB(self)) * rad2deg
end)

E_A:RegisterFunction("cos", "n", "n", function(self, Value)
	return MathCos(Value(self) * deg2rad)
end)

E_A:RegisterFunction("sec", "n", "n", function(self, Value)
	return 1 / MathCos(Value(self) * deg2rad)
end)

E_A:RegisterFunction("sin", "n", "n", function(self, Value)
	return MathSin(Value(self) * deg2rad)
end)

E_A:RegisterFunction("csc", "n", "n", function(self, Value)
	return 1 / MathSin(Value(self) * deg2rad)
end)

E_A:RegisterFunction("tan", "n", "n", function(self, Value)
	return MathTan(Value(self) * deg2rad)
end)

E_A:RegisterFunction("cot", "n", "n", function(self, Value)
	return 1 / MathTan(Value(self) * deg2rad)
end)

E_A:RegisterFunction("cosh", "n", "n", function(self, Value)
	return MathCosh(Value(self))
end)

E_A:RegisterFunction("sech", "n", "n", function(self, Value)
	return 1 / MathCosh(Value(self))
end)

E_A:RegisterFunction("sinh", "n", "n", function(self, Value)
	return MathSinh(Value(self))
end)

E_A:RegisterFunction("csch", "n", "n", function(self, Value)
	return 1 / MathSinh(Value(self))
end)

E_A:RegisterFunction("tanh", "n", "n", function(self, Value)
	return MathTanh(Value(self))
end)

E_A:RegisterFunction("coth", "n", "n", function(self, Value)
	return 1 / MathTanh(Value(self))
end)

E_A:RegisterFunction("acosr", "n", "n", function(self, Value)
	return MathAcos(Value(self))
end)

E_A:RegisterFunction("asinr", "n", "n", function(self, Value)
	return MathAsin(Value(self))
end)

E_A:RegisterFunction("atanr", "n", "n", function(self, Value)
	return MathAtan(Value(self))
end)

E_A:RegisterFunction("atanr", "nn", "n", function(self, ValueA, ValueB)
	return MathAtan2(ValueA(self), ValueB(self))
end)

E_A:RegisterFunction("cosr", "n", "n", function(self, Value)
	return MathCos( Value(self) )
end)

E_A:RegisterFunction("secr", "n", "n", function(self, Value)
	return 1 / MathCos(Value(self))
end)

E_A:RegisterFunction("sinr", "n", "n", function(self, Value)
	return MathSin(Value(self))
end)

E_A:RegisterFunction("cscr", "n", "n", function(self, Value)
	return 1 / MathSin(Value(self))
end)

E_A:RegisterFunction("tanr", "n", "n", function(self, Value)
	return MathTan(Value(self))
end)

E_A:RegisterFunction("cotr", "n", "n", function(self, Value)
	return 1 / MathTan(Value(self))
end)

E_A:RegisterFunction("coshr", "n", "n", function(self, Value)
	return MathCosh(Value(self))
end)

E_A:RegisterFunction("sechr", "n", "n", function(self, Value)
	return 1 / MathCosh(Value(self))
end)

E_A:RegisterFunction("sinhr", "n", "n", function(self, Value)
	return MathSinh(Value(self))
end)

E_A:RegisterFunction("cschr", "n", "n", function(self, Value)
	return 1 / MathSinh(Value(self))
end)

E_A:RegisterFunction("tanhr", "n", "n", function(self, Value)
	return MathTanh(Value(self))
end)

E_A:RegisterFunction("cothr", "n", "n", function(self, Value)
	return 1 / MathTanh(Value(self))
end)


E_A:RegisterFunction("ln", "n", "n", function(self, Value)
	return MathLog(Value(self))
end)


E_A:RegisterFunction("log2", "n", "n", function(self, Value)
	return MathLog(Value(self)) * const_invlog2
end)

E_A:RegisterFunction("log10", "n", "n", function(self, Value)
	return MathLog10(Value(self))
end)

E_A:RegisterFunction("log", "nn", "n", function(self, ValueA, ValueB)
	return MathLog(ValueA(self)) / MathLog(ValueB(self))
end)

/*==============================================================================================
	Section: BINARY
==============================================================================================*/
local rshift = bit.rshift
local rshift = bit.lshift
local bxor = bit.bxor
local band = bit.band
local bor = bit.bor

E_A:RegisterOperator("binary_shift_right", "nn", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return rshift(A, B)
end)

E_A:RegisterOperator("binary_shift_left", "nn", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return lshift(A, B)
end)

E_A:RegisterOperator("binary_xor", "nn", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return bxor(A, B)
end)

E_A:RegisterOperator("binary_and", "nn", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return band(A, B)
end)

E_A:RegisterOperator("binary_or", "nn", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return bor(A, B)
end)
