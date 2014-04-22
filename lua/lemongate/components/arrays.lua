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

Component.ArrayClasses = { }

function Component:BuildClasses( )

	self:SetPerf( LEMON_PERF_CHEAP )

	for Name, Class in pairs( API.ClassLU ) do
		local ArrayClass = self:NewClass( Class.Short .. "*", Class.Name .. "[]", "{ }", true )
		self.ArrayClasses[ Class ] = ArrayClass
		ArrayClass.NoTableUse = true
	end

	self:SetPerf( LEMON_PERF_CHEAP )

	for Class, ArrayClass in pairs( self.ArrayClasses ) do

		local ArrayShort = ArrayClass.Short

		self:AddFunction( Class.Name:lower( ) .. "Array", "", ArrayShort, "{ }" )

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
		
		self:AddFunction( "toTable", ArrayShort .. ":", "t", "", [[%Table.Results( value %1, "]] .. Class.Short ..[[" )]] )
		
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