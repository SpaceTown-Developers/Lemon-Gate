/*==============================================================================================
	Expression Advanced: Strings.
	Purpose: Strings and such.
	Note: Mostly just a convershion of E2's String Ext!
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local GetLongType = E_A.GetLongType
local GetShortType = E_A.GetShortType

local SubStr = string.sub -- Speed
local LowerStr = string.lower -- Speed
local UpperStr = string.upper -- Speed
local EplodeStr = string.Explode -- Speed
local RepStr = string.rep -- Speed
local TrimStr = string.Trim -- Speed
local MatchStr = string.match -- Speed
local GsubStr = string.gsub -- Speed

-- Sanitize input for use with Lua pattern functions
local function sanitize( str )
	return (gsub( str, "[%-%^%$%(%)%%%.%[%]%*%+%?]", "%%%1" ))
end

local tostring = tostring
local pcall = pcall

/*==============================================================================================
	Class & WireMod
==============================================================================================*/
E_A:RegisterClass("string", "s", "")

local function Input(self, Memory, Value)
	-- Purpose: Used to set Memory via a wired input.
	
	self.Memory[Memory] = Value
end

local function Output(self, Memory)
	-- Purpose: Used to get Memory for a wired output.
	
	return self.Memory[Memory]
end

E_A:WireModClass("string", "STRING", Input, Output)

/*==============================================================================================
	Section: Vairable operators
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterOperator("assign", "s", "", function(self, Value, Memory)
	-- Purpose: Assigns a string to memory
	
	self.Memory[Memory] = Value(self)
end)

E_A:RegisterOperator("variable", "s", "s", function(self, Memory)
	-- Purpose: Assigns a string to memory
	
	return self.Memory[Memory]
end)

/*==============================================================================================
	Section: String Operators
==============================================================================================*/

E_A:RegisterOperator("lenth", "s", "n", function(self, Value)
	-- Purpose: Gets the lengh of a string
	
	return #Value(self)
end)

E_A:RegisterOperator("get", "sn", "s", function(self, Value, Index)
	-- Purpose: Gets the lengh of a string
	
	local I = Index(self)

	return SubStr(Value(self), I, I)
end)

/*==============================================================================================
	Section: String Building
==============================================================================================*/
local function Operator(self, ValueA, ValueB)
	-- Purpose: Adds two strings together.
	return tostring( ValueA(self) ) .. tostring( ValueB(self) )
end

E_A:RegisterOperator("addition", "ss", "s", Operator)

E_A:RegisterOperator("addition", "ns", "s", Operator)

E_A:RegisterOperator("addition", "sn", "s", Operator)

/*==============================================================================================
	Section: Comparsion Operators
==============================================================================================*/
E_A:RegisterOperator("is", "s", "n", function(self, Value)
	-- Purpose: Is Valid
	
	if Value(self) != "" then return 1 else return 0 end
end)

E_A:RegisterOperator("not", "s", "n", function(self, Value)
	-- Purpose: Is Valid
	
	if Value(self) == "" then return 1 else return 0 end
end)

E_A:RegisterOperator("negeq", "ss", "n", function(self, ValueA, ValueB)
	-- Purpose: != Comparsion Operator
	
	if ValueA(self) ~= ValueB(self) then return 1 else return 0 end
end)

E_A:RegisterOperator("eq", "ss", "n", function(self, ValueA, ValueB)
	-- Purpose: == Comparsion Operator
	
	if ValueA(self) == ValueB(self) then return 1 else return 0 end
end)

/*==============================================================================================
	Section: General String Functions
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("lenth", "s:", "n", function(self, Value)
	return #Value(self)
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
	return SubStr(ValueA(self),V, V)
end)

E_A:RegisterFunction("left", "s:n", "s", function(self, ValueA, ValueB)
	return ValueA(self):Left( ValueB(self) )
end)

E_A:RegisterFunction("right", "s:n", "s", function(self, ValueA, ValueB)
	return ValueA(self):Right( ValueB(self) )
end)

/*==============================================================================================
	Section: Advanced String Functions
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

E_A:RegisterFunction("repeat", "s:n", "s", function(self, ValueA, ValueB)
	return RepStr( ValueA(self), ValueB(self) )
end)

E_A:RegisterFunction("trim", "s:", "s", function(self, Value)
	return TrimStr( Value(self) )
end)

E_A:RegisterFunction("trim", "s:s", "s", function(self, Value)
	return TrimStr( ValueA(self), sanitize(ValueB(self)) )
end)

local function trimLeft( str, char )
	return ( GsubStr( str, "^" .. char .. "*(.+)$", "%1" ) )
end

local function trimRight( str, char )
	return ( GsubStr( str, "^(.-)" .. (char or "%s") .. "*$", "%1" ) )
end

E_A:RegisterFunction("trimLeft", "s:", "s", function(self, Value)
	return trimLeft( Value(self) )
end)

E_A:RegisterFunction("trimLeft", "s:s", "s", function(self, Value)
	return trimLeft( ValueA(self), sanitize(ValueB(self)) )
end)

E_A:RegisterFunction("trimRight", "s:", "s", function(self, Value)
	return trimRight( Value(self) )
end)

E_A:RegisterFunction("trimRight", "s:s", "s", function(self, Value)
	return trimRight( ValueA(self), sanitize(ValueB(self)) )
end)

/*==============================================================================================
	Section: Char / Byte Functions
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
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

local ReplaceStr = string.Replace -- Speed
local FindStr = string.find -- Speed

E_A:RegisterFunction("find", "s:s", "n", function(self, ValueA, ValueB)
	return FindStr( ValueA(self), ValueB(self), 1, true) or 0
end)

E_A:RegisterFunction("find", "s:sn", "n", function(self, ValueA, ValueB, ValueC)
	return FindStr( ValueA(self), ValueB(self), ValueC(self), true) or 0
end)

E_A:RegisterFunction("replace", "s:ss", "s", function(self, ValueA, ValueB, ValueC)
	return ReplaceStr( ValueA(self), ValueB(self), ValueC(self) )
end)

E_A:SetCost(EA_COST_EXPENSIVE)

-- Regex functions
E_A:RegisterFunction("findPattern", "s:s", "n", function(self, ValueA, ValueB)
	local Ok, Return = pcall( FindStr, ValueA(self), ValueB(self) )
	if !Ok or !Return then self:Throw("string", "Invalid string pattern.") end
	return Return
end)

E_A:RegisterFunction("findPattern", "s:sn", "n", function(self, ValueA, ValueB, ValueC)
	local Ok, Return = pcall( FindStr, ValueA(self), ValueB(self), ValueC(self) )
	if !Ok or !Return then self:Throw("string", "Invalid string pattern.") end
	return Return
end)

E_A:RegisterFunction("replacePattern", "s:ss", "s", function(self, ValueA, ValueB, ValueC)
	local Ok, Return = pcall( GsubStr, ValueA(self), ValueB(self), ValueC(self) )
	if !Ok or !Return then self:Throw("string", "Invalid string pattern.") end
	return Return
end)

/*==============================================================================================
	Section: Explode / Matches
==============================================================================================*/
E_A:SetCost(EA_COST_EXPENSIVE)

E_A:RegisterException("string")

local RemoveTable = table.remove

E_A:RegisterFunction("explode", "s:s", "t", function(self, ValueA, ValueB)
	local String = ValueA(self)
	local Results = EplodeStr( ValueB(self), String )
	
	self.Perf = self.Perf - ((#Results * 0.5) + (#String * 0.2))
	return E_A.NewResultTable(Results, "s")
end)

E_A:RegisterFunction("explodePattern", "s:s", "t", function(self, ValueA, ValueB)
	local String = ValueA(self)
	local Results = EplodeStr( ValueB(self), String, true )
	
	self.Perf = self.Perf - ((#Results * 0.5) + (#String * 0.2))
	return E_A.NewResultTable(Results, "s")
end)

E_A:RegisterFunction("matchPattern", "s:s", "t", function(self, ValueA, ValueB)
	local Results = { pcall( MatchStr, ValueA(self), ValueB(self) ) }
	if !Results[1] then self:Throw("string", "Invalid string pattern.") end
	
	RemoveTable(Results, 1)
	return E_A.NewResultTable(Results, "s")
end)

E_A:RegisterFunction("matchPattern", "s:sn", "t", function(self, ValueA, ValueB, ValueC)
	local Results = { pcall( MatchStr, ValueA(self), ValueB(self), ValueC(self) ) }
	if !Results[1] then self:Throw("string", "Invalid string pattern.") end
	
	RemoveTable(Results, 1)
	return E_A.NewResultTable(Results, "s")
end)

E_A:RegisterFunction("matchFirst", "s:s", "s", function(self, ValueA, ValueB)
	local Ok, Return = pcall(MachStr, ValueA(self), ValueB(self))
	if !Ok or !Return then self:Throw("string", "Invalid string pattern.") end
	return Return
end)

E_A:RegisterFunction("matchFirst", "s:sn", "s", function(self, ValueA, ValueB, ValueC)
	local Ok, Return = pcall( MachStr, ValueA(self), ValueB(self), ValueC(self) )
	if !Ok or !Return then self:Throw("string", "Invalid string pattern.") end
	return Return
end)