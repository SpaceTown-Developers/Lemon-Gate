/*==============================================================================================
	Expression Advanced: Strings.
	Purpose: Strings and such.
	Note: Mostly just a convershion of E2's String Ext!
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local GetLongType = E_A.GetLongType
local GetShortType = E_A.GetShortType

local LenStr = string.len -- Speed
local SubStr = string.sub -- Speed
local LowerStr = string.lower -- Speed
local UpperStr = string.upper -- Speed

local tostring = tostring
local pcall = pcall

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

E_A:RegisterOperator("notequal", "ss", "n", function(self, ValueA, ValueB)
	-- Purpose: != Comparason Operator
	
	if ValueA(self) ~= ValueB(self) return 1 else return 0 end
end)

E_A:RegisterOperator("equal", "ss", "n", function(self, ValueA, ValueB)
	-- Purpose: == Comparason Operator
	
	if ValueA(self) == ValueB(self) return 1 else return 0 end
end)

/*==============================================================================================
	Section: General String Functions
	Purpose: Common stuffs?
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("length", "s:", "n", function(self, Value)
	return LenStr( Value(self) )
end)

E_A:RegisterFunction("lower", "s:", "s", function(self, Value)
	return LowerStr( Value(self) )
end)

E_A:RegisterFunction("upper", "s:", "s", function(self, Value)
	return UpperStr( Value(self) )
end)


E_A:RegisterFunction("sub", "s:n", "s", function(self, ValueA, ValueB)
	return SubStr( ValueA(self), ValueB(self) )
end)

E_A:RegisterFunction("sub", "s:nn", "s", function(self, ValueA, ValueB, ValueC)
	return SubStr( ValueA(self), ValueB(self), ValueC(self) )
end)


E_A:RegisterFunction("index", "s:n", "s", function(self, ValueA, ValueB)
	local V = ValueB(self)
	return ValueA(self):sub(V, V)
end)

E_A:RegisterFunction("left", "s:n", "s", function(self, ValueA, ValueB)
	return ValueA(self):Left( ValueB(self) )
end)

E_A:RegisterFunction("right", "s:n", "s", function(self, ValueA, ValueB)
	return ValueA(self):Right( ValueB(self) )
end)

/*==============================================================================================
	Section: Advanced String Functions
	Purpose: Trimming.
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

local RepStr = string.rep -- Speed
local TrimStr = string.Trim -- Speed
local TrimRightStr = string.TrimRight -- Speed
local MatchStr = string.match -- Speed

E_A:RegisterFunction("repeat", "s:n", "s", function(self, ValueA, ValueB)
	return RepStr( ValueA(self), ValueB(self) )
end)

E_A:RegisterFunction("trim", "s:", "s", function(self, Value)
	return TrimStr( Value(self) )
end)

E_A:RegisterFunction("trimLeft", "s:", "s", function(self, Value)
	return MatchStr( Value(self), "^ *(.-)$") 
end)

E_A:RegisterFunction("trimRight", "s:", "s", function(self, Value)
	return TrimRightStr( Value(self) )
end)

/*==============================================================================================
	Section: Char / Byte Functions
	Purpose: Bite Bite, Nibble Nibble!
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

local CharStr = string.char -- Speed
local ByteStr = string.byte -- Speed

E_A:RegisterFunction("toChar", "n", "s", function(self, Value)
	local V = Value(self)
	if V < 1 then return "" end
	if V > 255 then return "" end
	return CharStr(V)
end)

E_A:RegisterFunction("toByte", "s", "n", function(self, Value)
	local V = Value(self)
	if V == "" then return -1 end
	return ByteStr(V)
end)

E_A:RegisterFunction("toByte", "sn", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	if B < 1 or B > LenStr(A) then return -1 end
	return ByteStr(A, B)
end)

/*==============================================================================================
	Section: Finding and Replacing
	Purpose: And other regex stuffs!
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

local ReplaceStr = string.Replace -- Speed
local GsubStr = string.gsub -- Speed
local FindStr = string.find -- Speed

E_A:RegisterFunction("find", "s:s", "n", function(self, ValueA, ValueB)
	return FindStr( ValueA(self), ValueB(self), 1, true) or 0
end)

E_A:RegisterFunction("find", "s:s", "n", function(self, ValueA, ValueB, ValueC)
	return FindStr( ValueA(self), ValueB(self), ValueC(self), true) or 0
end)

E_A:RegisterFunction("replace", "s:ss", "n", function(self, ValueA, ValueB, ValueC)
	return ReplaceStr( ValueA(self), ValueB(self), ValueC(self) )
end)

E_A:SetCost(EA_COST_EXSPENSIVE)

-- Regex functions
E_A:RegisterFunction("findPattern", "s:s", "n", function(self, ValueA, ValueB)
	local Ok, Return = pcall(FindStr, ValueA(self), ValueB(self))
	if !Ok or !Return then return 0 else return Return end
end) -- TODO: Make this throw an exception!

E_A:RegisterFunction("findPattern", "s:sn", "n", function(self, ValueA, ValueB, ValueC)
	local Ok, Return = pcall(FindStr, ValueA(self), ValueB(self), ValueC(self))
	if !Ok or !Return then return 0 else return Return end
end) -- TODO: Make this throw an exception!

E_A:RegisterFunction("replacePattern", "s:ss", "n", function(self, ValueA, ValueB, ValueC)
	local Ok, Return = pcall(GsubStr, ValueA(self), ValueB(self), ValueC(self))
	if !Ok or !Return then return "" else return Return end
end) -- TODO: Make this throw an exception!


/*==============================================================================================
	TODO: Explode / Matches
	We need array's first!
==============================================================================================*/