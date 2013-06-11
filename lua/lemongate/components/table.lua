/*==============================================================================================
	Expression Advanced: Component -> Tables.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local TableRemove = table.remove
local TableInsert = table.insert
local TableCopy = table.Copy

local setmetatable = setmetatable

/*==============================================================================================
	Table Base Object
==============================================================================================*/
local MAX = 512

local Table = { MaxSize = MAX }
Table.__index = Table

setmetatable( Table, Table )

function Table.__call( )
	return setmetatable( { Data = {}, Types = {}, Size = 0, Count = 0 }, Table )
end

function Table.Results( Data, Type )
	local Table = Table( )
	for I = 1, #Data do Table:Insert( nil, Type, Data[I] ) end
	return Table
end

function Table:Set( Index, Type, Value )
	local Data, Types = self.Data, self.Types
	local Size , Count = self.Size, self.Count
	local OldVal, OldTyp = Data[Index], Types[Index]

	if OldVal and OldTyp == "t" then
		Size = Size - OldVal.Size
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

function Table:Insert( Index, Type, Value )
	local Data, Types = self.Data, self.Types
	local Size , Count = self.Size, self.Count

	Index = Index or #self.Data + 1

	Size = Size + 1
	Count = Count + 1

	if Type == "t" then Size = Size + Value.Size end
	if Size > MAX then return false end -- Table is too big!

	TableInsert( Data, Index, Value )
	TableInsert( Types, Index, Type )

	self.Size = Size
	self.Count = Count

	return true
end

function Table:Remove( Index )
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

	-- return OldVal, OldTyp
end

function Table:Get( Index, Type )
	local Object = self.Data[Index]
	
	if Type == "?" and Object then
		return { self.Data[Index], self.Types[Index] }
	elseif Object and self.Types[Index] == Type then
		return Object
	end
end

local function Itor( Table, Key )
	local Data = Table.Data
	local Key = next( Data, Key )
	return Key, Table.Types[Key], Data[Key]
end

function Table:Itorate( )
	return Itor, self
end

/*==============================================================================================
	Table Component
==============================================================================================*/
local Component = API:NewComponent( "table", true )

Component:AddExternal( "Table", Table )

Component:AddException( "table" )

/*==============================================================================================
	Table Class
==============================================================================================*/
Component:NewClass( "t", "table" )

Component:SetPerf( LEMON_PERF_CHEAP )

-- Size Operators

Component:AddOperator( "#", "t", "n", "(#value %1.Data)" )

Component:AddFunction( "size", "t:", "n", "(value %1.Size)" )

Component:AddFunction( "count", "t:", "n", "(value %1.Count)" )

/*==============================================================================================
	General Functions
==============================================================================================*/
Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction( "copy", "t:", "t", "setmetatable( table.copy(value %1), %Table)" )

-- Remove:

Component:SetPerf( LEMON_PERF_ABNORMAL )

Component:AddFunction( "remove", "t:n", "", "value %1:Remove(value %2)" )

Component:AddFunction( "remove", "t:s", "", "value %1:Remove(value %2)" )

Component:AddFunction( "remove", "t:e", "", "value %1:Remove(value %2)" )

-- Type
Component:AddFunction( "type", "t:n", "s", "LongType(value %1.Types[value %2])" )

Component:AddFunction( "type", "t:s", "s", "LongType(value %1.Types[value %2])" )

Component:AddFunction( "type", "t:e", "s", "LongType(value %1.Types[value %2])" )

-- Exists
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction( "exists", "t:n", "b", "(value %1.Data[value %2] ~= nil)" )

Component:AddFunction( "exists", "t:s", "b", "(value %1.Data[value %2] ~= nil)" )

Component:AddFunction( "exists", "t:e", "b", "(value %1.Data[value %2] ~= nil)" )

/*==============================================================================================
	Variant Index Operators
==============================================================================================*/
Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddOperator( "[]=", "t,n,?", "",
	[[%prepare
	local %A = value %3
	if !value %1:Set( value %2, %A[2], %A[1] ) then
		%context:Throw( "table", "Maxamum table size reached" ) 
	end]], "" )

Component:AddOperator( "[]=", "t,s,?", "",
	[[%prepare
	local %A = value %3
	if !value %1:Set( value %2, %A[2], %A[1] ) then
		%context:Throw( "table", "Maxamum table size reached" ) 
	end]], "" )
	
Component:AddOperator( "[]=", "t,e,?", "",
	[[%prepare
	local %A = value %3
	if !value %1:Set( value %2, %A[2], %A[1] ) then
		%context:Throw( "table", "Maxamum table size reached" ) 
	end]], "" )

-- Insert
Component:AddOperator( "[]+", "t,?", "",
	[[%prepare
	local %A = value %2
	if !value %1:Set( nil, %A[2], %A[1] ) then
		%context:Throw( "table", "Maxamum table size reached" ) 
	end]], "" )
	
/*==============================================================================================
	Index Operators
==============================================================================================*/
function Component:BuildOperators( )
	for Name, Class in pairs( API.Classes ) do
		if !Class.NoTableUse then
			
			-- Get Operators:
				if Class.Default then -- Default returnable get
					Component:AddOperator( "[]", Format( "t,n,%s", Class.Short ), Class.Short,
						Format( "(value %%1:Get(value %%2, %q) or %s)", Class.Short, Class.Default ) )
					
					Component:AddOperator( "[]", Format( "t,s,%s", Class.Short ), Class.Short,
						Format( "(value %%1:Get(value %%2, %q) or %s)", Class.Short, Class.Default ) )
					
					Component:AddOperator( "[]", Format( "t,e,%s", Class.Short ), Class.Short,
						Format( "(value %%1:Get(value %%2, %q) or %s)", Class.Short, Class.Default ) )
			
				else -- Exception throwable get
					Component:AddOperator( "[]", Format( "t,n,%s", Class.Short ), Class.Short,
						Format( "(value %%1:Get(value %%2, %q) or %%context:Throw(%%trace, %q, %q))",
							Class.Short, "table", "Attempt to reach a void " .. Class.Name ) )
					
					Component:AddOperator( "[]", Format( "t,s,%s", Class.Short ), Class.Short,
						Format( "(value %%1:Get(value %%2, %q) or %%context:Throw(%%trace, %q, %q))",
							Class.Short, "table", "Attempt to reach a void " .. Class.Name ) )
					
					Component:AddOperator( "[]", Format( "t,e,%s", Class.Short ), Class.Short,
						Format( "(value %%1:Get(value %%2, %q) or %%context:Throw(%%trace, %q, %q))",
							Class.Short, "table", "Attempt to reach a void " .. Class.Name ) )
					
				end
			
			-- Set Operators:
				
				if Class.Short ~= "?" then
					Component:AddOperator( "[]=", Format( "t,n,%s", Class.Short ), "",
						[[%prepare
						if !value %1:Set( value %2, type %3, value %3 ) then
							%context:Throw( "table", "Maxamum table size reached" ) 
						end]], "" )
					
					Component:AddOperator( "[]=", Format( "t,s,%s", Class.Short ), "",
						[[%prepare
						if !value %1:Set( value %2, type %3, value %3 ) then
							%context:Throw( "table", "Maxamum table size reached" ) 
						end]], "" )
						
					Component:AddOperator( "[]=", Format( "t,e,%s", Class.Short ), "",
						[[%prepare
						if !value %1:Set( value %2, type %3, value %3 ) then
							%context:Throw( "table", "Maxamum table size reached" ) 
						end]], "" )
					
				-- Insert
					Component:AddOperator( "[]+", Format( "t,%s", Class.Short ), "",
						[[%prepare
						if !value %1:Insert( nil, type %2, value %2 ) then
							%context:Throw( "table", "Maxamum table size reached" ) 
						end]], "" )
				end
			
			-- Insert Function:
				Component:AddFunction( "insert", Format( "t:n,%s", Class.Short ), "",
					[[%prepare
					if !value %1:Insert( value %2, type %3, value %3 ) then
						%context:Throw( "table", "Maxamum table size reached" ) 
					end]], "" )
				
				Component:AddFunction( "insert", Format( "t:%s", Class.Short ), "",
					[[%prepare
					if !value %1:Insert( nil, type %2, value %2 ) then
						%context:Throw( "table", "Maxamum table size reached" ) 
					end]], "" )
		end
	end
end

/*==============================================================================================
	ForEach Loop
==============================================================================================*/
-- 1 Table, 2 KType
Component:AddOperator( "foreach", "t", "", [[
do
	%prepare
	
	local ExitDeph = ExitDeph or 0
	local VType, KType = value %2, value %3
	
	local Statments = function( )
		prepare %6
	end
	
	for Key, Type, Value in value %1:Itorate( ) do
		local KeyType = $type( Key )[1]
		
		if VType ~= Type and VType ~= "?" then
			continue
		elseif KType and ( KType ~= KeyType and KType ~= "?" ) then
			continue
		elseif KType then
			if KType == "?" then Key = { Key, KeyType } end
			prepare %5
		end
		
		if VType == "?" then Value = { Value, Type } end
			
		prepare %4
		
		%perf
		
		local Ok, Exit = pcall( Statments )
		
		if !Ok then
			if ExitDeph > 0 then
				ExitDeph = ExitDeph - 1
				error( Exit, 0 )
			elseif Exit ~= "Continue" then
				error( Exit, 0 )
			end
		end
	end
end]] , "" )