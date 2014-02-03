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

Table.Click = false

function Table.__call( )
	return setmetatable( { Data = {}, Types = {}, Look = {}, Size = 0, Count = 0, Clk = true, MetaTable = false }, Table )
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
	
	if Type == "?" then
		Type = Value[2]
		Value = Value[1]
	end
	
	Data[Index] = Value
	self.Types[Index] = Type
	self.Look[Index] = Index 
	
	self.Clk = true
	self.Count = #Data
end

function Table:Insert( Index, Type, Value )
	local Data = self.Data
	local Index = Index or (#Data + 1)
	
	TableInsert( Data, Index, Value )
	TableInsert( self.Types, Index, Type )
	self.Look[Index] = Index 
	
	self.Clk = true
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
	self.Look[Index] = nil
	
	self.Clk = true
	self.Count = #Data
end

function Table:Shift( Index )
	local Data = self.Data

	if Data[Index] ~= nil then
		self.Size = self.Size - 1
	end
	
	TableRemove( Data, Index )
	TableRemove( self.Types, Index )
	TableRemove( self.Look, Index )
	
	self.Clk = true
	self.Count = #Data
end

function Table:Get( Index, Type )
	local Object = self.Data[Index]
	
	if Object == nil then
		return self:GetFromMeta( Index, Type )
	elseif Type == "?" then
		return { self.Data[Index], self.Types[Index] }
	elseif self.Types[Index] == Type then
		return Object
	end
end

function Table:GetFromMeta( Index, Type )
	local Searched = { [self] = true }
	
	while self.MetaTable do
		self = self.MetaTable
		
		if Searched[self] then return end
		Searched[self] = true -- Prevent inf loop!
		
		if self.Data[Index] ~= nil then
			return self:Get( Index, Type )
		end
	end
end

local next = next

local function Itor( Table, Key )
	local Data = Table.Data
	local Key = next( Data, Key )
	return Key, Table.Types[Key], Data[Key]
end

function Table:Itorate( )
	return Itor, self
end

function Table:Unpack( Index )
	local Object = self.Data[Index]
	
	if Object ~= nil then
		return { Object, self.Types[Index] }, self:Unpack( Index + 1 )
	end
end


function Table.__tostring( Table )
	local Default = Format( "table[%s/%s]", Table.Count, Table.Size )
	local Method = Table:Get( "operator_string", "f" )
	
	if !Method then return Default end
	
	local Val = Method( { Table, "t" } ) or { Default }
	return tostring( Val[1] )
end

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

Class:Wire_Name( "TABLE" ) -- ( "LTABLE" )

Class.OutClick = true

function Class.Wire_Out( Context, Cell ) 
	local Value = API.E2:ToE2( Context, "t", Context.Memory[ Cell ] or Table( ) )
	return Value
end

function Class.Wire_In( Context, Cell, Value )
	Context.Memory[ Cell ] = API.E2:ToLemon( Context, "t", Value )
end

Class:UsesMetaTable( Table )

Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddOperator( "default", "t", "t", "%Table()" )

-- Size Operators

Component:AddOperator( "#", "t", "n", "(value %1.Count)" )

Component:AddFunction( "size", "t:", "n", "(value %1.Size)" )

Component:AddFunction( "count", "t:", "n", "(value %1.Count)" )

-- Cast:

Component:AddOperator( "string", "t", "s", "tostring( value %1 )" )

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
local %Type = $type( %Key or 0 ):sub(1,1):lower( )
%util = { %Key or 0, %Type ~= "p" and %Type or "e" }
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

local %Type = $type( %Key or 0 ):sub(1,1):lower( )
%util = { %Key or 0, %Type ~= "p" and %Type or "e" }
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
	elseif %IType == "Entity" or %IType == "Player" then
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
		elseif %IType == "Entity" or %IType == "Player" then
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
	VarArg Support:
==============================================================================================*/
Component:AddOperator( "[]+", "t,...", "", [[
for _, Variant in pairs( { %... } ) do
	value %1:Insert( nil, Variant[2], Variant[1] )
end]], "" )

Component:AddFunction( "unpack", "t", "...", "value %1:Unpack( 1 )" )

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
Component:SetPerf( LEMON_PERF_NORMAL )

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
		
		if KeyType == "E" or KeyType == "P" then
			KeyType = "e"
		end
		
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

/* OLD SORT FUNCTION, REMOVED CUS ITS AWFUL!
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
		%context:Throw( %trace, "table", "sort function returned " .. LongType( Ret[2] ) .. " boolean expected." )
	elseif Ret then
		return Ret[1]
	end
end )

local %Sorted = %Table( )
for Key, Val in pairs( %New ) do
	Context.Perf = Context.Perf + 0.5
	
	%Sorted:Insert( Key, Val[2], Val[3] )
end]], "%Sorted" ) */

Component:AddFunction( "sort", "t:f", "t", [[
local %Sorted = %Table( )

do
	%context.Perf = %context.Perf + ( value %1.Size * 2 )
	%perf //Rebalance this?

	local Data = value %1.Data
	local Types = value %1.Types
	
	local Look = { }
	for _, V in pairs( value %1.Look ) do Look[V] = V end

	local Trace = %trace

	table.sort( Look, function( KeyA, KeyB )
		local Return = value %2( { Data[KeyA], Types[KeyA] }, { Data[KeyB], Types[KeyB] } )
		
		if !Return then
			return false
		elseif Return[2] == "b" then
			return Return[1]
		end
		
		%context:Throw( Trace, "table", "sort function returned " .. LongType( Return[2] ) .. " boolean expected." )
	end )
	
	local SData = %Sorted.Data
	local STypes = %Sorted.Types
	local SLook = %Sorted.Look
	
	for I, Value in pairs( Look ) do
		SData[ I ] = Data[ Value ]
		STypes[ I ] = Types[ Value ]
		SLook[ Value ] = Value
	end
	
	%Sorted.Count = #SData
	%Sorted.Size = value %1.Size
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
				Context.Player:ChatPrint( "(t) " .. Sep .. "-- {" )
				Prints = Value:Print( Context, Sep .. "    " , Prints, Tables )
				Context.Player:ChatPrint( "   " .. Sep .. "} --" )
			else
				Prints = Prints + 1
				Context.Perf = Context.Perf + 1
				Context.Player:ChatPrint( Format( Sep .. "(%s) %s = %s", Type, tostring( Key ), tostring( Value ) ) )
			end
		end
		
	end
	
	return Prints
end

Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction( "printTable", "t", "", "value %1:Print( %context )", "" )

/*==============================================================================================
	Methods
==============================================================================================*/
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction( "setMetaTable", "t,t", "t", [[
	value %1.MetaTable = value %2
]], "value %1" )

Component:AddFunction( "removeMetaTable", "t,t", "", "value %1.MetaTable = false", "" )


Component:AddOperator( "setmethod", "t,s,f", "", [[
	value %1:Set( value %3, "f", value %2 )
]], "" )

Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddOperator( "callmethod", "t,s,...", "?", [[
	%prepare
	local %Method = value %1:Get( value %2, "f" )
	
	if !%Method  then
		%context:Throw( %trace, "table", "Attempt to call void method '" .. value %2 .. "'" )
	end
	
	%util = %Method( {value %1, type %1}, %... ) or { 0, "n" }
]], "%util" )


-- Lets done some cool Meta Stuff!

Component:AddOperator( "call", "t,...", "?", [[
	%prepare
	local %Method = value %1:Get( "operator_call", "f" )
	
	if !%Method  then
		%context:Throw( %trace, "table", "Attempt to call void method 'operator_call'" )
	end
	%util = %Method( {value %1, type %1}, %... ) or { 0, "n" }
]], "%util" )

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

/*==============================================================================================
	Existing Meta Tables
==============================================================================================*/

-- function Component:CreateContext( Context )
	-- Context.MetaTables = {
		-- entity = Table( )
	-- } -- Meta Tables
-- end

-- Component:AddFunction( "getMetaTable", "s", "t", "(Context.MetaTables[value %1] or %Table( ))" )

-- Component:AddFunction( "getMetaTable", "s", "t", "(Context.MetaTables[value %1] or %Table( ))" )
