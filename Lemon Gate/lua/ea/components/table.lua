/*==============================================================================================
	Expression Advanced: Tables.
	Purpose: Strings and such.
	Note: Rusks genius idea!
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
local MAX = 512

local TableRemove = table.remove
local TableInsert = table.insert
local TableCopy = table.Copy

local setmetatable = setmetatable

/*==============================================================================================
	Table Builders
==============================================================================================*/
local Table = {}
Table.__index = Table

function E_A.NewTable()
	return setmetatable({ Data = {}, Types = {}, Size = 0, Count = 0 }, Table)
end

local NewTable = E_A.NewTable

function E_A.NewResultTable(Values, Type)
	local Result = NewTable()
	for _, Value in pairs( Values ) do Result:Insert(nil, Type, Value) end
	return Result
end

/*==============================================================================================
	Table Metacore
==============================================================================================*/

function Table:Set(Index, Type, Value)
	local Data, Types = self.Data, self.Types
	local Size , Count = self.Size, self.Count
	local OldVal, OldTyp = Data[Index], Types[Index]
	
	if OldVal and OldTyp == "t" then
		Size = Size - OldVal:GetSize()
	end -- Allows us to free memory used up by old tables.
	
	if Type == "t" then
		Size = Size + Value.Size
	end
	
	if !OldVal then
		Size = Size + 1 -- Update the memory and index count!
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
	Section: Class & WireMod
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterException("table")
E_A:RegisterClass("table", "t", NewTable )
E_A:RegisterOperator("assign", "t", "", E_A.AssignOperator)
E_A:RegisterOperator("variable", "t", "t", E_A.VariableOperator)

/*==============================================================================================
	Section: Core Operator
	Purpose: Support for the table syntax!
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterOperator("table", "", "t", function(self, Keys, Values)
	local Table = NewTable()
	for I = 1, #Values do
		self.Perf = self.Perf + EA_COST_NORMAL
		local Value, Type = Values[I](self)
		local Key = Keys[I]
		
		if Key then
			Table:Set(Key(self), Type, Value)
		elseif Type == "***" then
			for I = 1, #Value do
				local Value, Type = Value[I](self)
				Table:Insert(nil, Type, Value)
			end
		else
			Table:Insert(nil, Type, Value)
		end
	end
	
	return Table
end)

/*==============================================================================================
	Section: Table Operators
	Purpose: Basic operations.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("length", "t", "n", function(self, Value)
	-- Purpose: Gets the highest numeric index
	local Data = Value(self).Data
	if !Data then return 0 else return #Data end
end)

E_A:RegisterOperator("is", "t", "n", function(self, Value)
	-- Purpose: Gets the highest numeric index
	local Data = Value(self).Data
	if !Data or #Data == 0 then return 0 else return 1 end
end)

E_A:RegisterOperator("not", "t", "n", function(self, Value)
	-- Purpose: Gets the highest numeric index
	local Data = Value(self).Data
	if !Data or #Data == 0 then return 1 else return 0 end
end)

/*==============================================================================================
	Section: Table Functions
	Purpose: Basic operations.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterFunction("size", "t:", "n", function(self, Value)
	return Value(self).Size or 0
end)

E_A:RegisterFunction("count", "t:", "n", function(self, Value)
	return Value(self).Count or 0
end)

E_A:RegisterFunction("length", "t:", "n", function(self, Value)
	local Data = Value(self).Data
	if !Data then return 0 else return #Data end
end)

E_A:RegisterFunction("copy", "t:", "t", function(self, Value)
	local Table = Value(self)
	
	self.Perf = self.Perf - (Table.Size * 0.5)
	
	return setmetatable({
		Data = TableCopy( Table.Data ),
		Types = TableCopy( Table.Types ),
		Size = Table.Size, Count = Table.Count },
	Table) -- We copied the table!
end)

/***************************************************************************/

E_A:RegisterFunction("remove", "t:n", "", function(self, ValueA, ValueB)
	local Table, B = ValueA(self), ValueB(self)
	if Table and Table.Data then
		Table:Remove( B )
	end
end)

E_A:RegisterFunction("remove", "t:s", "", function(self, ValueA, ValueB)
	local Table, B = ValueA(self), ValueB(self)
	if Table and Table.Data then
		Table:Remove( B )
	end
end)

E_A:RegisterFunction("remove", "t:e", "", function(self, ValueA, ValueB)
	local Table, B = ValueA(self), ValueB(self)
	if Table and Table.Data then
		Table:Remove( B )
	end
end)

/***************************************************************************/

E_A:RegisterFunction("type", "t:n", "s", function(self, ValueA, ValueB)
	local Table, B = ValueA(self), ValueB(self)
	if Table and Table.Types then
		return E_A.GetLongType(Table.Types[B] or "")
	end; return "void"
end)

E_A:RegisterFunction("type", "t:s", "s", function(self, ValueA, ValueB)
	local Table, B = ValueA(self), ValueB(self)
	if Table and Table.Types then
		return E_A.GetLongType(Table.Types[B] or "")
	end; return "void"
end)

E_A:RegisterFunction("type", "t:e", "s", function(self, ValueA, ValueB)
	local Table, B = ValueA(self), ValueB(self)
	if Table and Table.Types then
		return E_A.GetLongType(Table.Types[B] or "")
	end; return "void"
end)

/***************************************************************************/

E_A:RegisterFunction("exists", "t:n", "n", function(self, ValueA, ValueB)
	local Table, B = ValueA(self), ValueB(self)
	if Table and Table.Types then
		return (Table.Types[B] ~= nil and 1 or 0)
	end; return 0
end)

E_A:RegisterFunction("exists", "t:s", "n", function(self, ValueA, ValueB)
	local Table, B = ValueA(self), ValueB(self)
	if Table and Table.Types then
		return (Table.Types[B] ~= nil and 1 or 0)
	end; return 0
end)

E_A:RegisterFunction("exists", "t:e", "n", function(self, ValueA, ValueB)
	local Table, B = ValueA(self), ValueB(self)
	if Table and Table.Types then
		return (Table.Types[B] ~= nil and 1 or 0)
	end; return 0
end)

/*==============================================================================================
	Section: Indexing Operators
	Purpose: Getters and Setters.
	Creditors: Rusketh
==============================================================================================*/
E_A.API.AddHook("BuildFunctions", function()
	for Type, tTable in pairs(E_A.TypeShorts) do
		
		if Type == "***" then continue end
		
		local function Get(self, ValueA, ValueB)
			local Table, Index = ValueA(self), ValueB(self)
			
			if !Table.Data then
				self:Throw("table", "Attempt to index field " .. tostring(Index) .. " on void table.")
			end
			
			local tIndex = Table.Types[Index]
			
			if tIndex and tIndex == Type then
				return Table.Data[Index]
				
			elseif !tIndex and Type == "t" then
				self:Throw("table", "Attempt to reach void table at index " .. tostring(Index) .. ".")
			
			elseif !tIndex and Type == "f" then
				self:Throw("table", "Attempt to reach void function at index " .. tostring(Index) .. ".")
			
			else
				return tTable[3](self) -- Default value!
			end
		end
		
		E_A:RegisterOperator("get", "tn" .. Type, Type, Get)
		E_A:RegisterOperator("get", "ts" .. Type, Type, Get)
		E_A:RegisterOperator("get", "te" .. Type, Type, Get)
		
		/*****************************************************************************************************************************/
		
		local function Set(self, ValueA, ValueB, ValueC)
			local Table, Index = ValueA(self), ValueB(self)
			
			if !Table.Data then
				self:Throw("table", "Attempt to index field " .. tostring(Index) .. " on void table.")
			end
			
			if !Table:Set(Index, Type, ValueC(self)) then
				self:Error("Maximum table size exceeded.")
			end
		end
		
		E_A:RegisterOperator("set", "tn" .. Type, "", Set)
		E_A:RegisterOperator("set", "ts" .. Type, "", Set)
		E_A:RegisterOperator("set", "te" .. Type, "", Set)
		
		/*****************************************************************************************************************************/
		
		local function Insert(self, ValueA, ValueB, ValueC)
			local Table, Value, Type = ValueA(self), ValueB(self)
			local Index = nil
			
			if ValueC then
				Index = Index(self)
			end
			
			if !Table and !Table.Data then
				return -- Table is void, cba to throw anything.
			elseif !Table:Insert(Index, Type, Value) then
				self:Error("Maximum table size exceeded.")
			end
		end
		
		E_A:RegisterFunction("insert", "t:" .. Type, "", Insert)
		E_A:RegisterFunction("insert", "t:" .. Type .. "n" , "", Insert)
		E_A:RegisterFunction("insert", "t:" .. Type .. "s" , "", Insert)
		E_A:RegisterFunction("insert", "t:" .. Type .. "e" , "", Insert)
		
		/*****************************************************************************************************************************/
		
		E_A:RegisterOperator("foreach", "t" .. Type, "", function(self, Value, Memory, Assign, Block)
			local Table = Value(self)
			local Data = Table.Data
			
			if Table.Types then
				for Index, tValue in pairs( Table.Types ) do
					if tValue == Type or tValue == "?" then
						
						-- Assign the Value.
							Assign(self, function() return Data[Index], Type end, Memory) 
						
						local Ok, Exception, Level = Block:SafeCall(self)
						Level = tonumber(Level or 0)
						
						if !Ok then
							if Exception == "break" then
								if Level <= 0 then break else self:Throw("break", Level - 1) end
							elseif Exception == "continue" then
								if Level <= 0 then Step(self) else self:Throw("continue", Level - 1) end
							else
								error(Exception, 0)
							end
						end
					end
				end	
			end
		end)
		
		/*****************************************************************************************************************************/
		
		E_A:RegisterOperator("foreach", "tn" .. Type, "", function(self, Value, kMemory, kAssign, vMemory, vAssign, Block)
			local Table = Value(self)
			local Types, Data = Table.Types, Table.Data
			
			if Table.Types then
				for Index, tValue in pairs( Table.Types ) do
					if type(Index) == "number" and (tValue == Type or Type == "?") then
						
					-- Assign the Value.
							kAssign(self, function() return Index, Type end, kMemory) 
							vAssign(self, function() return Data[Index], Type end, vMemory) 
						
						local Ok, Exception, Level = Block:SafeCall(self)
						Level = tonumber(Level or 0)
						
						if !Ok then
							if Exception == "break" then
								if Level <= 0 then break else self:Throw("break", Level - 1) end
							elseif Exception == "continue" then
								if Level <= 0 then Step(self) else self:Throw("continue", Level - 1) end
							else
								error(Exception, 0)
							end
						end
					end
				end	
			end
		end)
		
		E_A:RegisterOperator("foreach", "ts" .. Type, "", function(self, Value, kMemory, kAssign, vMemory, vAssign, Block)
			local Table = Value(self)
			local Types, Data = Table.Types, Table.Data
			
			if Table.Types then
				for Index, tValue in pairs( Table.Types ) do
					if type(Index) == "string" and (tValue == Type or Type == "?") then
						
					-- Assign the Value.
							kAssign(self, function() return Index, Type end, kMemory) 
							vAssign(self, function() return Data[Index], Type end, vMemory) 
						
						local Ok, Exception, Level = Block:SafeCall(self)
						Level = tonumber(Level or 0)
						
						if !Ok then
							if Exception == "break" then
								if Level <= 0 then break else self:Throw("break", Level - 1) end
							elseif Exception == "continue" then
								if Level <= 0 then Step(self) else self:Throw("continue", Level - 1) end
							else
								error(Exception, 0)
							end
						end
					end
				end	
			end
		end)
		
		E_A:RegisterOperator("foreach", "te" .. Type, "", function(self, Value, kMemory, kAssign, vMemory, vAssign, Block)
			local Table = Value(self)
			local Types, Data = Table.Types, Table.Data
			
			if Table.Types then
				for Index, tValue in pairs( Table.Types ) do
					self:PushPerf(EA_COST_ABNORMAL)
					
					if type(Index) == "Entity" and (tValue == Type or Type == "?") then
						
					-- Assign the Value.
							kAssign(self, function() return Index, Type end, kMemory) 
							vAssign(self, function() return Data[Index], Type end, vMemory) 
						
						local Ok, Exception, Level = Block:SafeCall(self)
						Level = tonumber(Level or 0)
						
						if !Ok then
							if Exception == "break" then
								if Level <= 0 then break else self:Throw("break", Level - 1) end
							elseif Exception == "continue" then
								if Level <= 0 then Step(self) else self:Throw("continue", Level - 1) end
							else
								error(Exception, 0)
							end
						end
					end
				end	
			end
		end)
		
		E_A:RegisterOperator("foreach", "t?" .. Type, "", function(self, Value, kMemory, kAssign, vMemory, vAssign, Block)
			local Table = Value(self)
			local Types, Data = Table.Types, Table.Data
			
			if Table.Types then
				for Index, tValue in pairs( Table.Types ) do
					self:PushPerf(EA_COST_ABNORMAL)
					
					if tValue == Type or Type == "?" then
						
					-- Assign the Value.
							kAssign(self, function() return Index, Type end, kMemory) 
							vAssign(self, function() return Data[Index], Type end, vMemory) 
						
						local Ok, Exception, Level = Block:SafeCall(self)
						Level = tonumber(Level or 0)
						
						if !Ok then
							if Exception == "break" then
								if Level <= 0 then break else self:Throw("break", Level - 1) end
							elseif Exception == "continue" then
								if Level <= 0 then Step(self) else self:Throw("continue", Level - 1) end
							else
								error(Exception, 0)
							end
						end
					end
				end	
			end
		end)
	end
end)

/*==============================================================================================
	Section: Variant Indexing Operators
	Purpose: Getters and Setters.
	Creditors: Rusketh
==============================================================================================*/
local function GetVariant(self, ValueA, ValueB)
	local Table, Index = ValueA(self), ValueB(self)
	if !Table.Data then self:Throw("table", "Attempt to index field " .. tostring(Index) .. " on invalid table.") end
			
	if !Table.Types[Index] then self:Throw("table", "Attempt to index field " .. tostring(Index) .. " a void value.") end
	return Table.Data[Index]
end

E_A:RegisterOperator("get", "tn", "?", GetVariant)
E_A:RegisterOperator("get", "ts", "?", GetVariant)
E_A:RegisterOperator("get", "te", "?", GetVariant)
