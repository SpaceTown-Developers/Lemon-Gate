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
--local MAX = 512
local Table = { }
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
	local Data = self.Data
	
	if Data[Index] == nil then
		self.Size = self.Size + 1
	end
	
	Data[Index] = Value
	self.Types[Index] = Type
	print( "SET:", Index, #Data )
	self.Count = #Data
end

function Table:Insert( Index, Type, Value )
	local Data = self.Data
	local Index = Index or (#Data + 1)
	
	TableInsert( Data, Index, Value )
	TableInsert( self.Types, Index, Type )
	
	self.Count = #Data
	self.Size = self.Size + 1
end

function Table:Remove( Index )
	local Data = self.Data

	if Data[Index] ~= nil then
		self.Size = self.Size - 1
	end
	
	Data[Index] = nil
	self.Types[Index] = nil
	
	self.Count = #Data
end

function Table:Get( Index, Type )
	local Object = self.Data[Index]
	
	if Type == "?" and Object ~= nil then
		return { self.Data[Index], self.Types[Index] }
	elseif Object ~= nil and self.Types[Index] == Type then
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

function Table.__tostring( Table )
	return string.Format( "table[%s/%s]", Table.Count, Table.Size )
end

/*==============================================================================================
	Convertor
==============================================================================================*/
local FromLua

function FromLua( LuaTable )
	local Data, Types = { }, { }
	local Size, Count = 0, 0
	
	for Key, Value in pairs( LuaTable ) do
		local Type = type( Value )
		
		if Type == "boolean" then
			Data[ Key ], Types[ Key ] = Value, "b"
			Size, Count = Size + 1, Count + 1
		elseif Type == "number" then
			Data[ Key ], Types[ Key ] = Value, "n"
			Size, Count = Size + 1, Count + 1
		elseif Type == "string" then
			Data[ Key ], Types[ Key ] = Value, "s"
			Size, Count = Size + 1, Count + 1
		elseif Type == "Vector" then
			Data[ Key ], Types[ Key ] = Vector3( Value.x, Value.y, Value.z ) , "v"
			Size, Count = Size + 1, Count + 1
		elseif Type == "Angle" then
			Data[ Key ], Types[ Key ] = Angle( Value.p, Value.y, Value.r ) , "a"
			Size, Count = Size + 1, Count + 1
		elseif IsValid( Value ) then
			Data[ Key ], Types[ Key ] = Value , "e"
			Size, Count = Size + 1, Count + 1
		elseif Type == "table" then
			Value = FromLua( Value )
			Data[ Key ], Types[ Key ] = Value , "t"
			Size, Count = Size + Value.Size, Count + 1
		end
	end
	
	return setmetatable( { Data = Data, Types = Types, Size = Size, Count = Count }, Table )
end; Table.From = FromLua

/*==============================================================================================
	Table Component
==============================================================================================*/
local Component = API:NewComponent( "table", true )

Component:AddExternal( "Table", Table )

Component:AddException( "table" )

function Component:GetMetaTable( )
	return Table
end

/*==============================================================================================
	Table Class
==============================================================================================*/
local Class = Component:NewClass( "t", "table" )

Class:UsesMetaTable( Table )

Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddOperator( "default", "t", "t", "%Table()" )

-- Size Operators

Component:AddOperator( "#", "t", "n", "(value %1.Count)" )

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
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddOperator( "[]=", "t,n,?", "", "value %1:Set( value %2, value %3[2], value %3[1] )" )

Component:AddOperator( "[]=", "t,s,?", "", "value %1:Set( value %2, value %3[2], value %3[1] )" ) 
	
Component:AddOperator( "[]=", "t,e,?", "", "value %1:Set( value %2, value %3[2], value %3[1] )" ) 

-- Insert
Component:AddOperator( "[]+", "t,?", "", "value %1:Set( nil, value %2[2],value %2[1] )" )
	
/*==============================================================================================
	Index Operators
==============================================================================================*/
function Component:BuildOperators( )
	
	self:SetPerf( LEMON_PERF_CHEAP )
	
	for Name, Class in pairs( API.Classes ) do
		if !Class.NoTableUse then
			
			-- Get Operators:
				if Class.Default and Class.Default ~= "nil" then -- Default returnable get
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
						"value %1:Set( value %2, type %3, value %3 )" )
					
					Component:AddOperator( "[]=", Format( "t,s,%s", Class.Short ), "",
						"value %1:Set( value %2, type %3, value %3 )" )
						
					Component:AddOperator( "[]=", Format( "t,e,%s", Class.Short ), "",
						"value %1:Set( value %2, type %3, value %3 )" )
					
				-- Insert
					Component:AddOperator( "[]+", Format( "t,%s", Class.Short ), "",
						"value %1:Insert( nil, type %2, value %2 )" )
				end
			
			-- Insert Function:
				Component:AddFunction( "insert", Format( "t:n,%s", Class.Short ), "",
					"value %1:Insert( value %2, type %3, value %3 )" )
				
				Component:AddFunction( "insert", Format( "t:%s", Class.Short ), "",
					"value %1:Insert( nil, type %2, value %2 )" )
		end
	end
end

/*==============================================================================================
	ForEach Loop
==============================================================================================*/
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddOperator( "foreach", "t", "", [[
do
	%prepare
	
	local ExitDeph = ExitDeph or 0
	local VType, KType = value %2, value %3
	
	local Statments = function( )
		prepare %6
	end
	
	for Key, Type, Value in value %1:Itorate( ) do
		%context:PushPerf( %trace, ]] .. LEMON_PERF_LOOPED .. [[ )
		
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
			
		%perf
		
		prepare %4
		
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

/*==============================================================================================
	ForEach Loop
==============================================================================================*/
Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction( "sort", "t:f", "t", [[
local %New, %Count = { }, 0

for Key, Type, Value in value %1:Itorate( ) do
	%Count = %Count + 1
	%New[%Count] = { Key, Type, Value }
end

table.sort( %New, function( A, B )
	%context:PushPerf( %trace, ]] .. LEMON_PERF_LOOPED .. [[ )
	
	local ValA = (A[2] ~= "?" and { A[3], A[2] } or A[3])
	local ValB = (B[2] ~= "?" and { B[3], B[2] } or B[3])
	
	local Ret = value %2( ValA, ValB )
	
	if Ret and Ret[2] ~= "b" then
		%context:Throw( %trace, "table", "sort function returned " .. LongType( Ret[2] ) .. " boolean exspected." )
	elseif Ret then
		return Ret[1]
	end
end )

local %Sorted = %Table( )
for Key, Val in pairs( %New ) do
	%Sorted:Insert( Key, Val[2], Val[3] )
end]], "%Sorted" )
