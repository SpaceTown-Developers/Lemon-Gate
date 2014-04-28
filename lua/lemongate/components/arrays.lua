/*==============================================================================================
	Expression Advanced: Entity.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Component = API:NewComponent( "arrays", true )

/*==============================================================================================
	Section: Build Array Classes
==============================================================================================*/

Component:AddException( "array" )

local Types = { n = "number", s = "string", e = "entity", h = "hologram", v = "vector", xv2 = "vector2", a = "angle", q = "quaternion", c = "color", t = "table", wl = "wirelink" }

API:CallHook( "AddArrayClasses", Types ) -- Insert your class short and name here!

Component.ArrayClasses = { }

for Short, Name in pairs( Types ) do
	local ArrayClass = Component:NewClass( Short .. "*", Name .. "[]", "{ }", true )
	Component.ArrayClasses[ Name ] = ArrayClass
	ArrayClass.NoTableUse = true
end

function Component:BuildOperators( )

	self:SetPerf( LEMON_PERF_CHEAP )

	for ClassName, ArrayClass in pairs( self.ArrayClasses ) do

		local Class = API:GetClass( ClassName, true )
		
		if !Class then 
			MsgN( "Can't properly produce array " .. ClassName .. " the class does not exist." )
			continue
		end

		local ArrayShort = ArrayClass.Short

		self:SetPerf( LEMON_PERF_CHEAP )

		self:AddFunction( Class.Name:lower( ) .. "Array", "", ArrayShort, "{ }" )

		self:SetPerf( LEMON_PERF_ABNORMAL )

		self:AddFunction( Class.Name:lower( ) .. "Array", "...", ArrayShort, [[
			local %Array = { }

			for _, Obj in pairs( { %... } ) do
				if Obj[2] ~= "]] .. Class.Short ..[[" then
					%context:Throw( %trace, "array", "Attempted into insert " .. %LongType(Obj[2]) .. " to ]] .. Class.Name .. [[ array.")
				end; table.insert( %Array, Obj[1] )
			end
		]], "%Array" )  -- TODO: DOCUMENT!


		self:SetPerf( LEMON_PERF_CHEAP )

		self:AddOperator( "#", ArrayShort, "n", "#value %1" )

		if Class.Default and Class.Default ~= "nil" then
			self:AddFunction( "last", ArrayShort .. ":", Class.Short, "($rawget(value %1, #value %1) or " .. Class.Default .. ")" )

			self:AddOperator( "[]", ArrayShort .. ",n", Class.Short, "($rawget(value %1, value %2) or " ..  Class.Default .. ")" )
			
			self:AddFunction( "remove", ArrayShort .. ":n", Class.Short, "(table.remove(value %1, value %2) or " ..  Class.Default .. ")" )
		else
			self:AddFunction( "last", ArrayShort .. ":", Class.Short, "($rawget(value %1, #value %1) or " .. string.format( "%%context:Throw(%%trace, %q, %q))", "array", "Attempt to reach a void index." ) )

			self:AddOperator( "[]", ArrayShort .. ",n", Class.Short, "($rawget(value %1, value %2) or " .. string.format( "%%context:Throw(%%trace, %q, %q))", "array", "Attempt to reach a void index." ) )
		
			self:AddFunction( "remove", ArrayShort .. ":n", "", "table.remove(value %1, value %2)" )
		end

		self:AddOperator( "[]=", ArrayShort .. ",n," .. Class.Short, "", "$rawset( value %1,value %2, value %3)", "" )

		self:AddFunction( "insert", ArrayShort .. ":" .. Class.Short, "", "table.insert( value %1, value %2 )", "" )

		self:AddFunction( "insert", ArrayShort .. ":n," .. Class.Short, "", "table.insert( value %1, value %2, value %3 )", "" ) 

		self:AddFunction( "exists", ArrayShort .. ":n", "b", "(value %1[value %2] ~= nil)" ) -- TODO: DOCUMENT!

		self:SetPerf( LEMON_PERF_NORMAL )

		self:AddFunction( "count", ArrayShort, "n", "table.Count(value %1)" ) -- TODO: DOCUMENT!
		
		self:AddFunction( "clear", ArrayShort, "", "table.Empty(value %1)", "" ) -- TODO: DOCUMENT!

		-- Casting

		self:SetPerf( LEMON_PERF_ABNORMAL )

		self:AddFunction( "toTable", ArrayShort .. ":", "t", "", [[%Table.Results( value %1, "]] .. Class.Short ..[[" )]] )
		
		self:AddOperator( "table", ArrayShort, "t", "", [[%Table.Results( value %1, "]] .. Class.Short ..[[" )]] )

		self:SetPerf( LEMON_PERF_CHEAP )

		--Loops
		self:AddOperator( "foreach", ArrayShort, "", [[

				%prepare
				
				local VType, KType = value %2, value %3

				if VType ~= "]] .. Class.Short .. [[" then
					%context:Throw( %trace, "array", "Invalid foreach loop, value type missmatches array type.")
				elseif KType and KType ~= "n" then
					%context:Throw( %trace, "array", "Invalid foreach loop, index type must be number.")
				end

				for Key = 1, #value %1 do
					local Value = value %1[Key]

					%perf
					
					prepare %5
					
					prepare %4
					
					prepare %6
				end
		]] , "" )
	end 
end