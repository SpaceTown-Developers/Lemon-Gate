/*==============================================================================================
	Expression Advanced: Tables.
	Purpose: Strings and such.
	Note: Rusks genius idea!
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
local MAX = 512

local TableInsert = table.insert

local setmetatable = setmetatable

/*==============================================================================================
	Table Metacore
==============================================================================================*/
local Table = {}
Table.__index = Table

function E_A.NewTable()
	return setmetatable({
		Data = {}, Types = {},
		Size = 0, Count = 0
	}, Table)
end; local NewTable = E_A.NewTable

function Table:Set(Index, Type, Value)
	local Data, Types = self.Data, self.Types
	local Size , Count = self.Size, self.Count
	local OldVal, OldTyp = Data[Index], Types[Index]
	
	if OldVal and OldTyp == "t" then
		Size = Size - OldVal:GetSize()
	end -- Allows us to unallocate memory used up by old tables.
	
	if Type == "t" then
		Size = Size + Value.Size
	end
	
	if !OldVal then
		Size = Size + 1 -- Update the meory and index count!
		Count = Count + 1
	end
	
	if Size > MAX then return false end -- Table is too big!
	
	Data[Index] = Value
	Types[Index] = Type
	self.Size = Size
	self.Count = Count
	
	return true
end

function Table:Insert(Index, Type, Value)
	local Data, Types = self.Data, self.Types
	local Size , Count = self.Size, self.Count
	
	Index = Index or #self.Data + 1
	
	Size = Size + 1
	Count = Count + 1
	
	if Type == "t" then Size = Size + Value.Size end
	if Size > MAX then return false end -- Table is too big!
	
	TableInsert(Data, Index, Value)
	TableInsert(Types, Index, Type)
	
	self.Size = Size
	self.Count = Count
	
	return true
end

function Table:Remove(Index)
	local Data, Types, Size = self.Data, self.Types, self.Size
	local OldVal, OldTyp = Data[Index], Types[Index]
	
	if OldVal then
		Size = Size - 1
		self.Count = self.Count - 1
	end
	
	if OldVal and OldTyp == "t" then
		Size = Size - OldVal.Size
	end
	
	Data[Index] = nil
	Types[Index] = nil
	self.Size = Size
	
	return OldVal, OldTyp
end

/*==============================================================================================
	Section: Table Operators
	Purpose: Basic operations.
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterOperator("table", "", "t", function(self, Keys, Values)
	-- Purpose: Builds a table.
	
	local Table = NewTable()
	
	for I = 1, #Values do
		self.Perf = self.Perf + EA_COST_NORMAL
		local Value, Type = Values[I](self)
		local Key = Keys[I]
		
		if Key then
			Table:Set(Key(self), Type, Value)
		else
			Table:Insert(nil, Type, Value)
		end
	end
	
	return Table
end)

E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterOperator("assign", "t", "", function(self, ValueOp, Memory)
	-- Purpose: Assigns a string to memory
	
	self.Memory[Memory] = ValueOp(self)
end)

E_A:RegisterOperator("variabel", "", "t", function(self, Memory)
	-- Purpose: Assigns a string to memory
	
	return self.Memory[Memory]
end)

/*==============================================================================================
	Section: Table Operators
	Purpose: Basic operations.
	Creditors: Rusketh
==============================================================================================*/

