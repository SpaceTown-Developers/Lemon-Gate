/*==============================================================================================
	Expression Advanced: Strings.
	Purpose: Numbers do maths and stuffs.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local GetLongType = E_A.GetLongType
local GetShortType = E_A.GetShortType

local LenStr = string.len -- Speed
local SubStr = string.sub -- Speed

local tostring = tostring

/*==============================================================================================
	Section: String Class
	Purpose: Its a string.
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterOperator("assign", "s", "", function(self, ValueOp, Memory)
	-- Purpose: Assigns a string to memory
	
	local Value, Type = ValueOp(self)
	if GetShortType(Type) != "s" then self:Error("Attempt to assign %s to string", GetLongType(Type)) end
	
	self.Memory[Memory] = Value
end)

E_A:RegisterOperator("variabel", "s", "s", function(self, Memory)
	-- Purpose: Assigns a string to memory
	
	return self.Memory[Memory]
end)

/*==============================================================================================
	Section: String Operators
	Purpose: Operators that work on strings.
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterOperator("lengh", "s", "n", function(self, Value)
	-- Purpose: Gets the lengh of a string
	
	return LenStr( Value(self) )
end)

E_A:RegisterOperator("get", "sn", "s", function(self, Value, Index)
	-- Purpose: Gets the lengh of a string
	
	local I = Index(self)

	return SubStr(Value(self), I, I)
end)

/*==============================================================================================
	Section: String Building
	Purpose: Combines strings?
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("addition", "ss", "s", function(self, ValueA, ValueB)
	-- Purpose: Adds two strings together.
	
	return ValueA(self) .. ValueB(self)
end)

E_A:RegisterOperator("addition", "ns", "s", function(self, ValueA, ValueB)
	-- Purpose: Adds two strings together.
	
	return ValueA(self) .. ValueB(self)
end)

E_A:RegisterOperator("addition", "sn", "s", function(self, ValueA, ValueB)
	-- Purpose: Adds two strings together.
	
	return ValueA(self) .. ValueB(self)
end)

/*==============================================================================================
	Section: Comparason Operators
	Purpose: If statments and stuff?
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("is", "s", "n", function(self, Value)
	-- Purpose: Is Valid
	
	if Value(self) != "" then return 1 else return 0 end
end)

/*==============================================================================================
	Section: String Functions
	Purpose: Common stuffs?
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterFunction("print", "s", "", function(self, Value)
	self.Player:PrintMessage( HUD_PRINTTALK, Value(self) )
end)

