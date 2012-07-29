/*==============================================================================================
	Expression Advanced: Numbers.
	Purpose: Numbers do maths and stuffs.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

/*==============================================================================================
	Class & WireMod
==============================================================================================*/
local function Input(self, Memory, Value)
	-- Purpose: Used to set Memory via a wired input.
	
	self.Delta[Memory] = self.Memory[Memory]
	
	self.Memory[Memory] = Value
end

local function Output(self, Memory)
	-- Purpose: Used to get Memory for a wired output.
	
	return self.Memory[Memory]
end

E_A:RegisterClass("number", "n", 0)

E_A:WireModClass("number", "NORMAL", Input, Output)

-- Note: With out Input function 'Number' would not be inputable, The same goes with Output.

/*==============================================================================================
	Var Operators
==============================================================================================*/
E_A:RegisterOperator("assign", "n", "", function(self, ValueOp, Memory)
	-- Purpose: Assigns a number to memory
	
	local Value, Type = ValueOp(self)
	if E_A.GetShortType(Type) != "n" then self:Error("Attempt to assign %s to number variabel", Type) end
	
	self.Delta[Memory] = self.Memory[Memory]
	
	self.Memory[Memory] = Value
	
	self.Click[Memory] = true
end)

E_A:RegisterOperator("variabel", "n", "n", function(self, Memory)
	-- Purpose: Assigns a number to memory
	
	return self.Memory[Memory]
end)

E_A:RegisterOperator("delta", "n", "n", function(self, Memory)
	-- Purpose: ~ Delta Operator
	
	return self.Memory[Memory] - (self.Delta[Memory] or 0)
end)

/*==============================================================================================
	Section: Mathmatical Operators
	Purpose: Does math stuffs?
	Creditors: Rusketh
==============================================================================================*/

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

E_A:RegisterOperator("incremet", "n", "n", function(self, Memory)
	-- Purpose: ++ Math Operator
	
	self.Memory[Memory] = self.Memory[Memory] + 1
end)

E_A:RegisterOperator("decremet", "n", "n", function(self, Memory)
	-- Purpose: -- Math Operator
	
	self.Memory[Memory] = self.Memory[Memory] - 1
end)

E_A:RegisterOperator("negative", "n", "n", function(self, Value)
	-- Purpose: Negation Operator
	
	return -Value(self)
end)

/*==============================================================================================
	Section: Comparason Operators
	Purpose: If statments and stuff?
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("greater", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: > Comparason Operator
	
	if ValueA(self) > ValueB(self) then return 1 else return 0 end
end)

E_A:RegisterOperator("less", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: < Comparason Operator
	
	if ValueA(self) < ValueB(self) then return 1 else return 0 end
end)

E_A:RegisterOperator("greaterequal", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: <= Comparason Operator
	
	if ValueA(self) <= ValueB(self) then return 1 else return 0 end
end)

E_A:RegisterOperator("lessequal", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: <= Comparason Operator
	
	if ValueA(self) <= ValueB(self) then return 1 else return 0 end
end)

E_A:RegisterOperator("notequal", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: != Comparason Operator
	
	if ValueA(self) != ValueB(self) then return 1 else return 0 end
end)

E_A:RegisterOperator("equal", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: == Comparason Operator
	
	if ValueA(self) == ValueB(self) then return 1 else return 0 end
end)

/*==============================================================================================
	Section: Conditonal Operators
	Purpose: And (&) and Or (|) Operators.
	Warning: Do not remove these, as they become default operators.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("is", "n", "n", function(self, Value)
	-- Purpose: Is Valid
	
	if Value(self) > 0 then return 1 else return 0 end
end)

E_A:RegisterOperator("or", "nn", "", function(self, ValueA, ValueB)
	-- Purpose: | Conditonal Operator
	
	local A = ValueA(self)
	if A > 0 then return A else return ValueB(self) end
end)

E_A:RegisterOperator("and", "nn", "n", function(self, ValueA, ValueB)
	-- Purpose: & Conditonal Operator
	
	local A, B = ValueA(self), ValueB(self)
	if A > 0 and B > 0 then return 1 else return 0 end
end)

/*==============================================================================================
	Section: Test Functions
	Purpose: These are tempory for the purpose of testing.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterFunction("min", "nn...", "n", function(self, Value, ...)
	local Numbers = {...}
	
	local Min = Value(self)
	for I = 1, #Numbers do
		local Value = Numbers[I](self)
		if Value < Min then Min = Value end
	end
	
	return Min
end)

E_A:RegisterFunction("max", "nn...", "n", function(self, Value, ...)
	local Numbers = {...}
	
	local Max = Value(self)
	for I = 1, #Numbers do
		local Value = Numbers[I](self)
		if Value > Max then Max = Value end
	end
	
	return Max
end)