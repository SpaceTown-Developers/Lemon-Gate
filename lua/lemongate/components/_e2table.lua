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

local MAXSIZE = 1024*1024
local DEFAULT = { n = { }, ntypes = { }, s = { }, stypes = { }, e = { }, etypes = { }, size = { } }

/*==============================================================================================
	Table Component
==============================================================================================*/
local Component = API:NewComponent( "table", true )

Component:AddException( "table" )

/*==============================================================================================
	Table Class
==============================================================================================*/
local Class = Component:NewClass( "t", "table" )

Class:Wire_Name( "TABLE" )

--TODO: Add entity support onto input tables.

-- function Class.Wire_Out( Context, Cell ) return Context.Memory[ Cell ] or TableCopy( DEFAULT ) end

-- function Class.Wire_In( Context, Cell, Value ) Context.Memory[ Cell ] = Value end

/*==============================================================================================
	Index Operators
==============================================================================================*/
function Component:BuildOperators( )
	
	-- Auto Generated:
		self:SetPerf( LEMON_PERF_CHEAP )
		
		for Name, Class in pairs( API.Classes ) do
			if !Class.NoTableUse then
			
				-- Basic Set:
					Component:AddOperator( "[]=", "t,n," .. Class.Short, "", [[
					if ( value %1.size < ]] .. MAXSIZE .. [[ ) then
						if !value %1.n[value %2] then
							value %1.size = value %1.size + 1
						end
						
						value %1.n[value %2] = value %3
						value %1.ntypes[value %2] = type %3
					else
						%context:Throw( %trace, "table", "Max table size reached." )
					end
					]], LEMON_PREPARE_ONLY )
					
					Component:AddOperator( "[]=", "t,s," .. Class.Short, "", [[
					if ( value %1.size < ]] .. MAXSIZE .. [[ ) then
						if !value %1.s[value %2] then
							value %1.size = value %1.size + 1
						end
						
						value %1.s[value %2] = value %3
						value %1.stypes[value %2] = type %3
					else
						%context:Throw( %trace, "table", "Max table size reached." )
					end
					]], LEMON_PREPARE_ONLY )
					
					Component:AddOperator( "[]=", "t,e," .. Class.Short, "", [[
					if ( value %1.size < ]] .. MAXSIZE .. [[ ) then
						if !value %1.e[value %2] then
							value %1.size = value %1.size + 1
						end
						
						value %1.e[value %2] = value %3
						value %1.etypes[value %2] = type %3
					else
						%context:Throw( %trace, "table", "Max table size reached." )
					end
					]], LEMON_PREPARE_ONLY )
					
				-- Basic Insert:
					Component:AddFunction( "insert", "t:n," .. Class.Short, "", [[
					if ( value %1.size < ]] .. MAXSIZE .. [[ ) then
						value %1.size = value %1.size + 1
						
						table.insert( value %1.n, value %2, value %3 )
						table.insert( value %1.ntypes, value %2, type %3 )
					else
						%context:Throw( %trace, "table", "Max table size reached." )
					end
					]], LEMON_PREPARE_ONLY )
					
					Component:AddFunction( "push", "t:n," .. Class.Short, "", [[
					if ( value %1.size < ]] .. MAXSIZE .. [[ ) then
						local %Index = #value %1.n
						value %1.size = value %1.size + 1
						
						table.insert( value %1.n, %Index, value %2 )
						table.insert( value %1.ntypes, %Index, type %2 )
					else
						%context:Throw( %trace, "table", "Max table size reached." )
					end
					]], LEMON_PREPARE_ONLY )
					
					Component:AddFunction( "unshift", "t:n," .. Class.Short, "", [[
					if ( value %1.size < ]] .. MAXSIZE .. [[ ) then
						value %1.size = value %1.size + 1
						
						table.insert( value %1.n, 1, value %2 )
						table.insert( value %1.ntypes, 1, type %2 )
					else
						%context:Throw( %trace, "table", "Max table size reached." )
					end
					]], LEMON_PREPARE_ONLY )
					
				-- Basic Get:
					if Class.Default and Class.Default ~= "nil" then
						-- Default Value Compatible.
						
						Component:AddOperator( "[]", "t,n," .. Class.Short, "",
						"(!(value %1.ntypes[value %2] ~= " .. Class.Short .. ") and value %1.n[value %2] or " .. Class.Default .. ")",
						LEMON_INLINE_ONLY )
						
						Component:AddOperator( "[]", "t,s," .. Class.Short, "",
						"(!(value %1.stypes[value %2] ~= " .. Class.Short .. ") and value %1.s[value %2] or " .. Class.Default .. ")",
						LEMON_INLINE_ONLY )
						
						Component:AddOperator( "[]", "t,e," .. Class.Short, "",
						"(!(value %1.etypes[value %2] ~= " .. Class.Short .. ") and value %1.e[value %2] or " .. Class.Default .. ")",
						LEMON_INLINE_ONLY )
						
					else
						-- No default value.
						
						Component:AddOperator( "[]", "t,n," .. Class.Short, Class.Short, [[
						if ( value %1.ntypes[value %2] ~= ]] .. Class.Short .. [[ ) then
							%context:Throw( %trace, "table", "Attempt to reach void ]] .. Class.Name .. [[ on table." 
						end]], "value %1.n[value %2]" )
						
						Component:AddOperator( "[]", "t,s," .. Class.Short, Class.Short, [[
						if ( value %1.stypes[value %2] ~= ]] .. Class.Short .. [[ ) then
							%context:Throw( %trace, "table", "Attempt to reach void ]] .. Class.Name .. [[ on table." 
						end]], "value %1.s[value %2]" )
						
						Component:AddOperator( "[]", "t,e," .. Class.Short, Class.Short, [[
						if ( value %1.etypes[value %2] ~= ]] .. Class.Short .. [[ ) then
							%context:Throw( %trace, "table", "Attempt to reach void ]] .. Class.Name .. [[ on table." 
						end]], "value %1.e[value %2]" )
						
					end
			end
		end
	
	-- Variant Functions!
	
		-- Basic Set:
			Component:AddOperator( "[]=", "t,n,?", "", [[
			if ( value %1.size < ]] .. MAXSIZE .. [[ ) then
				if !value %1.n[value %2] then
					value %1.size = value %1.size + 1
				end
				
				value %1.n[value %2] = value %3[2]
				value %1.ntypes[value %2] = value %3[1]
			else
				%context:Throw( %trace, "table", "Max table size reached." )
			end
			]], LEMON_PREPARE_ONLY )
			
			Component:AddOperator( "[]=", "t,s,?", "", [[
			if ( value %1.size < ]] .. MAXSIZE .. [[ ) then
				if !value %1.s[value %2] then
					value %1.size = value %1.size + 1
				end
				
				value %1.s[value %2] = value %3[2]
				value %1.stypes[value %2] = value %3[1]
			else
				%context:Throw( %trace, "table", "Max table size reached." )
			end
			]], LEMON_PREPARE_ONLY )
			
			Component:AddOperator( "[]=", "t,e,?", "", [[
			if ( value %1.size < ]] .. MAXSIZE .. [[ ) then
				if !value %1.e[value %2] then
					value %1.size = value %1.size + 1
				end
				
				value %1.e[value %2] = value %3[2]
				value %1.etypes[value %2] = value %3[1]
			else
				%context:Throw( %trace, "table", "Max table size reached." )
			end
			]], LEMON_PREPARE_ONLY )
		
		-- Basic Get:
			
			Component:AddOperator( "[]", "t,n,?", "?", [[
			if ( value %1.ntypes[value %2] == nil ) then
				%context:Throw( %trace, "table", "Attempt to reach void index on table." 
			end]], "{ value %1.n[value %2], value %1.ntypes[value %2] }" )
			
			Component:AddOperator( "[]", "t,s,?", "?", [[
			if ( value %1.stypes[value %2] == nil ) then
				%context:Throw( %trace, "table", "Attempt to reach void index on table." 
			end]], "{ value %1.s[value %2], value %1.stypes[value %2] }" )
			
			Component:AddOperator( "[]", "t,e,?", "?", [[
			if ( value %1.etypes[value %2] == nil ) then
				%context:Throw( %trace, "table", "Attempt to reach void index on table." 
			end]], "{ value %1.e[value %2], value %1.etypes[value %2] }" )
			
	//TODO: Vector, Vector2, Angle manually because of native e2 types.
end

/*==============================================================================================
	Basic Functions
==============================================================================================*/
Component:SetPerf( LEMON_PERF_CHEAP )

-- Size / Count:
	Component:AddOperator( "#", "t", "n", "#value %1.n" )

	Component:AddFunction( "size", "t:", "n", "value %1.size" )

	Component:AddFunction( "count", "t:", "n", "value %1.size", LEMON_INLINE_ONLY )

-- Exists:
	Component:AddFunction( "exists", "t:n", "b", "(value %1.n[value %2] ~= nil)", LEMON_INLINE_ONLY )
	
	Component:AddFunction( "exists", "t:s", "b", "(value %1.s[value %2] ~= nil)", LEMON_INLINE_ONLY )
	
	Component:AddFunction( "exists", "t:e", "b", "(value %1.e[value %2] ~= nil)", LEMON_INLINE_ONLY )

-- Remove:
	
	Component:AddFunction( "remove", "t:n", "", [[
		if value %1.n[ value %2 ] then
			table.remove( value %1.n, value %2 )
			table.remove( value %1.ntypes, value %2 )
			value %1.size = value %1.size - 1
		end
	]], LEMON_PREPARE_ONLY )

	Component:AddFunction( "remove", "t:s", "", [[
		if value %1.s[ value %2 ] then
			value %1.s[ value %2 ] = nil
			value %1.stypes[ value %2 ] = nil
			value %1.size = value %1.size - 1
		end
	]], LEMON_PREPARE_ONLY )

	Component:AddFunction( "remove", "t:e", "", [[
		if value %1.e[ value %2 ] then
			value %1.e[ value %2 ] = nil
			value %1.etypes[ value %2 ] = nil
			value %1.size = value %1.size - 1
		end
	]], LEMON_PREPARE_ONLY )
	
Component:SetPerf( LEMON_PERF_EXPENSIVE )

-- Clear:
	
	Component:AddFunction( "clear", "t:", "", [[
	value %1.ntypes = { }
	table.Empty( value %1.n )
	value %1.stypes = { }
	table.Empty( value %1.s )
	value %1.etypes = { }
	table.Empty( value %1.e )
	]], LEMON_PREPARE_ONLY )

-- Clone:
	
	Component:AddFunction( "clone", "t:", "t", "table.Copy( value %1)", LEMON_INLINE_ONLY )
	
-- TypeIDS:

	Component:AddFunction( "typeids", "t:", "t", [[
	local %New = { n = { }, ntypes = { }, s = { }, stypes = { }, e = { }, etypes = { }, size = { } }
	
	%New.n = table.Copy( value %1.ntypes )
	for Key, Value in pairs( %New.n ) do
		%New.ntypes[Key] = "s"
	end
	
	%New.s = table.Copy( value %1.stypes )
	for Key, Value in pairs( %New.s ) do
		%New.stypes[Key] = "s"
	end
	
	%New.e = table.Copy( value %1.etypes )
	for Key, Value in pairs( %New.e ) do
		%New.etypes[Key] = "s"
	end
	]], "%New" )
	