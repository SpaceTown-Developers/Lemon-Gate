/*==============================================================================================
	Expression Advanced: Component -> Tables.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local TableRemove = table.remove
local TableInsert = table.insert
local TableCopy = table.Copy
local Format = string.format
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

function Table:Shift( Index )
	local Data = self.Data

	if Data[Index] ~= nil then
		self.Size = self.Size - 1
	end
	
	TableRemove( Data, Index )
	TableRemove( self.Types,Index )
	
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
	return Format( "table[%s/%s]", Table.Count, Table.Size )
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
	Register WireType
==============================================================================================*/
WireLib.DT.LTABLE = {
	Zero = setmetatable( { 
		Data = {},
		Types = {},
		Size = 0,
		Count = 0,
		Set = function( ) end,
		Insert = function( ) end
	}, Table )
} -- Table must not be writable.

/*==============================================================================================
	Table Class
==============================================================================================*/
local Class = Component:NewClass( "t", "table" )

Class:Wire_Name( "LTABLE" )

function Class.Wire_Out( Context, Cell ) return Context.Memory[ Cell ] or 0 end

function Class.Wire_In( Context, Cell, Value ) Context.Memory[ Cell ] = Value end

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

Component:AddFunction( "copy", "t:", "t", "$setmetatable( table.Copy(value %1), %Table)" )

-- Remove:

Component:SetPerf( LEMON_PERF_ABNORMAL )

Component:AddFunction( "remove", "t:n", "", "%Table.Remove(value %1, value %2)" )

Component:AddFunction( "remove", "t:s", "", "%Table.Remove(value %1, value %2)" )

Component:AddFunction( "remove", "t:e", "", "%Table.Remove(value %1, value %2)" )

-- Type
Component:AddFunction( "type", "t:n", "s", "LongType(value %1.Types[value %2])" )

Component:AddFunction( "type", "t:s", "s", "LongType(value %1.Types[value %2])" )

Component:AddFunction( "type", "t:e", "s", "LongType(value %1.Types[value %2])" )

-- Exists
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction( "exists", "t:n", "b", "(value %1.Data[value %2] ~= nil)" )

Component:AddFunction( "exists", "t:s", "b", "(value %1.Data[value %2] ~= nil)" )

Component:AddFunction( "exists", "t:e", "b", "(value %1.Data[value %2] ~= nil)" )

-- Array:
Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction( "pop", "t:", "", "%Table.Shift(value %1, value %1.Count)" )

Component:AddFunction( "shift", "t:", "", "%Table.Shift(value %1, 1)" )

Component:AddFunction( "shift", "t:n", "", "%Table.Shift(value %1, value %2)" )

-- Table:


Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction( "minIndex", "t:", "?", [[
local %Result, %Key

for Key, Type, Value in value %1:Itorate( ) do
	Context.Perf = Context.Perf + 0.5
	
	if Type == "n" and ( !%Result or Value < %Result ) then
		%Key = Key
		%Result = Value
	end
end

%util = { %Key or 0, $type( %Key or 0 ):sub(1,1):lower( ) }
]], "%util" )

Component:AddFunction( "maxIndex", "t:", "?", [[
local %Result, %Key

for Key, Type, Value in value %1:Itorate( ) do
	Context.Perf = Context.Perf + 0.5
	
	if Type == "n" and ( !%Result or Value > %Result ) then
		%Key = Key
		%Result = Value
	end
end

%util = { %Key or 0, $type( %Key or 0 ):sub(1,1):lower( ) }
]], "%util" )

Component:AddFunction( "keys", "t:", "t", [[
local %Result = %Table( )

for Key, Value in pairs( value %1.Types ) do
	Context.Perf = Context.Perf + 0.5
	
	local %IType = $type( Key )
		
	if %IType == "number" then
		%Result:Insert( nil, "n", Key )
	elseif %IType == "string" then
		%Result:Insert( nil, "s", Key )
	elseif %IType == "Entity" then
		%Result:Insert( nil, "e", Key )
	end
end
]], "%Result" )

Component:AddFunction( "values", "t:", "t", [[
local %Result = %Table( )

for Key, Type, Value in value %2:Itorate( ) do
	Context.Perf = Context.Perf + 0.5
	
	%Result:Insert( nil, Type, Value )
end
]], "%Result" )

Component:AddFunction( "invert", "t:", "t", [[
local %Result = %Table( )

for Key, Value in pairs( value %1.Types ) do
	Context.Perf = Context.Perf + 0.5
	
	if Value == "n" or Value == "s" or Value == "s" then
		local %IType = $type( Key )
		
		if %IType == "number" then
			%Result:Set( value %1.Data[ Key ], "n", Key )
		elseif %IType == "string" then
			%Result:Set( value %1.Data[ Key ], "s", Key )
		elseif %IType == "entity" then
			%Result:Set( value %1.Data[ Key ], "e", Key )
		end
	end
end
]], "%Result" )

Component:AddFunction( "merge", "t:t", "", [[
local %Tbl = value %1

for Key, Type, Value in value %2:Itorate( ) do
	Context.Perf = Context.Perf + 0.5
	
	%Tbl:Set( Key, Type, Value )
end
]], LEMON_PREPARE_ONLY )

Component:AddFunction( "add", "t:t", "", [[
local %Tbl = value %1 

for Key, Type, Value in value %2:Itorate( ) do
	Context.Perf = Context.Perf + 0.5
	
	if $type( Key ) == "number" then
		%Tbl:Insert( nil, Type, Value )
	elseif !Tbl.Types[ Key ] then
		%Tbl:Set( Key, Type, Value )
	end
end
]], LEMON_PREPARE_ONLY )

Component:AddFunction( "concat", "t:s", "s", [[
local %Result = { }

for Key, Type, Value in value %1:Itorate( ) do
	Context.Perf = Context.Perf + 0.1
	table.insert( %Result, tostring( Value ) )
end
]], "string.Implode( value %2, %Result )" )
/*==============================================================================================
	Variant Index Operators
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddOperator( "[]=", "t,n,?", "", "value %1:Set( value %2, value %3[2], value %3[1] )" )

Component:AddOperator( "[]=", "t,s,?", "", "value %1:Set( value %2, value %3[2], value %3[1] )" ) 
	
Component:AddOperator( "[]=", "t,e,?", "", "value %1:Set( value %2, value %3[2], value %3[1] )" ) 

-- Insert
Component:AddOperator( "[]+", "t,?", "", "value %1:Set( nil, value %2[2], value %2[1] )" )

/*==============================================================================================
	Misc
==============================================================================================*/
Component:AddOperator( "[]", "t,n", "?", [[( value %1:Get( value %2, "?") or %context:Throw(%trace, "table", "Attempt to reach a void value") )]] )

Component:AddOperator( "[]", "t,s", "?", [[( value %1:Get( value %2, "?") or %context:Throw(%trace, "table", "Attempt to reach a void value") )]] )

Component:AddOperator( "[]", "t,e", "?", [[( value %1:Get( value %2, "?") or %context:Throw(%trace, "table", "Attempt to reach a void value") )]] )

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
						"%Table.Set( value %1, value %2, type %3, value %3 )" )
					
					Component:AddOperator( "[]=", Format( "t,s,%s", Class.Short ), "",
						"%Table.Set( value %1, value %2, type %3, value %3 )" )
						
					Component:AddOperator( "[]=", Format( "t,e,%s", Class.Short ), "",
						"%Table.Set( value %1, value %2, type %3, value %3 )" )
					
				-- Insert
					Component:AddOperator( "[]+", Format( "t,%s", Class.Short ), "",
						"%Table.Insert( value %1, nil, type %2, value %2 )" )
				end
			
			-- Insert Function:
				Component:AddFunction( "insert", Format( "t:n,%s", Class.Short ), "",
					"%Table.Insert( value %1, value %2, type %3, value %3 )" )
				
				Component:AddFunction( "insert", Format( "t:%s", Class.Short ), "",
					"%Table.Insert( value %1, nil, type %2, value %2 )" )
			
			-- Array:
				Component:AddFunction( "push", Format( "t:%s", Class.Short ), "",
					"%Table.Insert( value %1, nil, type %2, value %2 )" )
					
				Component:AddFunction( "unshift", Format( "t:%s", Class.Short ), "",
					"%Table.Insert( value %1, 1, type %2, value %2 )" )
				
				Component:AddFunction( "unshift", Format( "t:n,%s", Class.Short ), "",
					"%Table.Insert( value %1, value %2, type %3, value %3 )" )
		end
	end
end

/*==============================================================================================
	ForEach Loop
==============================================================================================*/
Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddOperator( "foreach", "t", "", [[
do
	%prepare
	
	local ExitDeph = ExitDeph or 0
	local VType, KType = value %2, value %3
	
	local Statments = function( )
		prepare %6
	end
	
	for Key, Type, Value in value %1:Itorate( ) do
		%context:PushPerf( %trace, ]] .. LEMON_PERF_ABNORMAL .. [[ )
		
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
			elseif Exit == "Break" then
				break
			elseif Exit ~= "Continue" then
				error( Exit, 0 )
			end
		elseif Exit ~= nil then
			return Exit
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
	Context.Perf = Context.Perf + 0.5
	
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
	Context.Perf = Context.Perf + 0.5
	
	%Sorted:Insert( Key, Val[2], Val[3] )
end]], "%Sorted" )

/*==============================================================================================
	Print Table
==============================================================================================*/
function Table:Print( Context, Sep, Prints, Tables )
	Sep = Sep or ""
	Prints = Prints or 0
	Tables = Tables or { }
	
	if !Tables[self] then
		Tables[self] = true
		
		for Key, Type, Value in self:Itorate( ) do
			if Prints == 100 then
				break
			elseif Type == "t" then
				Prints = Value:Print( Context, Sep .. "  " , Prints, Tables )
			else
				Prints = Prints + 1
				Context.Perf = Context.Perf + 1
				Context.Player:ChatPrint( Format( "(%s)" .. Sep .. " %s = %s", Type, tostring( Key ), tostring( Value ) ) )
			end
		end
		
	end
	
	return Prints
end

Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction( "printTable", "t", "", "value %1:Print( %context )", "" )


/*==============================================================================================
	Shared Tables
==============================================================================================*/
local Component = API:NewComponent( "stable", true )

Component:AddExternal( "STable", { } )

Component:SetPerf( LEMON_PERF_ABNORMAL )

Component:AddFunction( "getSTable", "s", "t", [[
local %Shared = %STable[ value %1 ]
if ( !%Shared ) then
	%Shared = %Table( )
	%STable[ value %1 ] = %Shared
end
]], "%Shared" )

Component:AddFunction( "setSTable", "s,t", "", "%STable[ value %1 ] = value %2" )

Component:AddFunction( "removeSTable", "s", "", "%STable[ value %1 ] = nil" )