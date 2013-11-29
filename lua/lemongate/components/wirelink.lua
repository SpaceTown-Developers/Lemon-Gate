/*==============================================================================================
	Expression Advanced: Entitys.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" )

/*==============================================================================================
	Section: Context
==============================================================================================*/
function Core:GenerateContext( Context )
	function Context:FromWL( Entity, Type, Name, Default )
		if IsValid( Entity ) and Entity.Outputs then
			local Output = Entity.Outputs[Name]
			if Output and Output.Type == Type then
				return Output.Value or Default
			end
		end
		
		return Default
	end

	function Context:ToWL( Entity, Type, Name, Value)
		if IsValid( Entity ) and Entity.Inputs then
			local Input = Entity.Inputs[ Name ]
			if Input and Input.Type == Type then
				local Que = self.Data.WLQueue[ Entity ]
				
				if !Que then
					Que = { }
					self.Data.WLQueue[ Entity ] = Que
				end
				
				Que[Name] = Value
			end
		end
	end
end

function Core:UpdateContext( Context )
	for Entity, Que in pairs( Context.Data.WLQueue ) do
		if IsValid( Entity ) then
			for Key, Value in pairs( Que ) do
				WireLib.TriggerInput( Entity, Key, Value )
			end 
		end
	end
	
	Context.Data.WLQueue = { }
end

function Core:CreateContext( Context )
	Context.Data.WLQueue = { }
end

/*==============================================================================================
	Section: Class and Operators
==============================================================================================*/
local WireLink = Core:NewClass( "wl", "wirelink" )

WireLink:Extends( "e" )

WireLink:Wire_Name( "WIRELINK" )

function WireLink.Wire_In( Context, Cell, Value ) Context.Memory[ Cell ] = Value end

Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddOperator( "default", "wl", "wl", "%NULL_ENTITY" )

-- Get Port Operators:

Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddOperator( "[]", "wl,s,n", "n", [[%context:FromWL( value %1, "NORMAL", value %2, 0 )]] )

Core:AddOperator( "[]", "wl,s,s", "s", [[%context:FromWL( value %1, "STRING", value %2, "" )]] )

Core:AddOperator( "[]", "wl,s,e", "e", [[%context:FromWL( value %1, "ENTITY", value %2, %NULL_ENTITY )]] )

Core:AddOperator( "[]", "wl,s,v", "v", [[Vector3( %context:FromWL( value %1, "VECTOR", value %2, Vector( 0, 0, 0) ) )]] )

Core:AddOperator( "[]", "wl,s,a", "a", [[%context:FromWL( value %1, "ANGLE", value %2, Angle( 0, 0,  0) )]] )

-- Set Port Operators:

Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddOperator( "[]=", "wl,s,n", "", [[%context:ToWL( value %1, "NORMAL", value %2, value %3 )]], "" )

Core:AddOperator( "[]=", "wl,s,s", "", [[%context:ToWL( value %1, "STRING", value %2, value %3 )]], "" )

Core:AddOperator( "[]=", "wl,s,e", "", [[%context:ToWL( value %1, "ENTITY", value %2, value %3 )]], "" )

Core:AddOperator( "[]=", "wl,s,v", "", [[%context:ToWL( value %1, "VECTOR", value %2, value %3:Garry() )]], "" )

Core:AddOperator( "[]=", "wl,s,a", "", [[%context:ToWL( value %1, "ANGLE", value %2, value %3 )]], "" )

/*==============================================================================================
	Port Functions
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction("entity", "wl:", "e", "value %1")

Core:AddFunction("hasInput", "wl:s", "b", "local %WL = value %1", "($IsValid( %WL ) and %WL.Inputs and %WL.Inputs[%value2])" )

Core:AddFunction("hasOutput", "wl:s", "b", "local %WL = value %1", "($IsValid( %WL ) and %WL.Outputs and %WL.Outputs[%value2])" )

Core:AddFunction("isHiSpeed", "wl:", "b", "local %WL = value %1", "($IsValid( %WL ) and (%WL.WriteCell or %WL.ReadCell))" )

Core:AddFunction("inputType", "wl:s", "s", [[
local %WL, %Val = value %1, "void"
if $IsValid(%WL) and %WL.Inputs then
	%Input = %WL.Inputs[value %2]
	%Val = (%Input ~= null and string.lower(%Input.Type) or "void")
end]], "%Val" )

Core:AddFunction("outputType", "wl:s", "s", [[
local %WL, %Val = value %1, "void"
if $IsValid(%WL) and %WL.Outputs then
	%Output = %WL.Outputs[value %2]
	%Val = (%Output ~= null and string.lower(%Output.Type) or "void")
end]], "%Val" )

/*==============================================================================================
	Cell Writing
==============================================================================================*/
Core:SetPerf( LEMON_PERF_EXPENSIVE )

Core:AddFunction("writeCell", "wl:n,n", "b", [[
local %WL, %Val = value %1, false
if $IsValid(%WL) and %WL.WriteCell then
	%Val = %WL:WriteCell(value %2, value %3) or false
end]], "%Val" )

Core:AddFunction("readCell", "wl:n", "n", [[
local %WL, %Val = value %1, 0
if $IsValid(%WL) and %WL.ReadCell then
	%Val = %WL:ReadCell(value %2) or 0
end]], "%Val" )

Core:AddFunction("readArray", "wl:n,n", "t", [[
local %WL, %Result = value %1, %Table()
if $IsValid(%WL) and %WL.ReadCell then
	local Start = value %2
	for I = Start, Start + value %3 do
		%Result:Insert( nil, "n", %WL:ReadCell(I) or 0 )
	end
end]], "%Result" )

/*==============================================================================================
	Indexing
==============================================================================================*/

-- Read Cell:

Core:AddOperator( "[]", "wl,n", "n", [[
local %WL, %Val = value %1, 0
if $IsValid( %WL ) and %WL.ReadCell then
	%Val = %WL:ReadCell( value %2 ) or 0
end]], "%Val" )

Core:AddOperator( "[]", "wl,n, n", "n", [[
local %WL, %Val = value %1, 0
if $IsValid( %WL ) and %WL.ReadCell then
	%Val = %WL:ReadCell( value %2 ) or 0
end]], "%Val" )

Core:AddOperator( "[]", "wl,n,v", "v", [[
local %WL, %Val = value %1, { 0, 0, 0 }
if $IsValid( %WL ) and %WL.ReadCell then
	local Cell = value %2
	%Val = Vector3( %WL:ReadCell( Cell ) or 0, %WL:ReadCell( Cell + 1 ) or 0, %WL:ReadCell( Cell + 2 ) or 0 )
end]], "%Val" )

Core:AddOperator( "[]", "wl,n,s", "s", [[
local %WL, %Val = value %1, ""
if $IsValid( %WL ) and %WL.ReadCell then
	local Cell= value %2
	
	for I = Cell, Cell + 16384 do
		local Byte = %WL:ReadCell(I, Byte)
		if !Byte then
			%Val = ""; break
		elseif Byte < 1 then
			break
		elseif byte >= 256 then
			%Val = %Val .. string.char( 32 )
		else
			%Val = %Val .. string.char( math.floor( Byte ) )
		end
	end
end]], "%Val" )

-- Set Cell:

Core:AddOperator( "[]=", "wl,n,b", "", [[
local %WL = value %1
if $IsValid(%WL) and %WL.WriteCell then
	%WL:WriteCell( value %2, value %3 and 1 or 0 )
end]], "" )

Core:AddOperator( "[]=", "wl,n,n", "", [[
local %WL = value %1
if $IsValid(%WL) and %WL.WriteCell then
	%WL:WriteCell( value %2, value %3 )
end]], "" )

Core:AddOperator( "[]=", "wl,n,v", "", [[
local %WL = value %1
if $IsValid(%WL) and %WL.WriteCell then
	local %Cell, %Vec = value %2, value %3
	%WL:WriteCell( %Cell, %Vec.x )
	%WL:WriteCell( %Cell + 1, %Vec.y )
	%WL:WriteCell( %Cell + 2, %Vec.z )
end]], "" )

Core:AddOperator( "[]=", "wl,n,s", "", [[
local %WL = value %1
if $IsValid(%WL) and %WL.WriteCell then
	local Cell, String = value %2, value %3
	if %WL:WriteCell( Cell + #String, 0 ) then
		for I = 1, #String do
			local Byte = string.byte(String, I)
			if !%WL:WriteCell(Cell + I - 1, Byte) then break end
		end
	end
end]], "" )

/*==============================================================================================
	Advanced HighSpeed
==============================================================================================*/
local String_Byte = string.byte
local String_Char = string.char
local Math_Floor = math.floor
local Table_Concat = table.concat
local ipairs, type = ipairs, type

local function WriteStringZero( Entity, Address, String )
        if ( Entity:WriteCell( Address+ #String, 0 ) ) then

        for I = 1, #String do
            if !Entity:WriteCell( Address + Index - 1, String_Byte( String, I ) ) then
				return 0
			end
        end
		
        return Address + #String + 1
	end
	
	return 0
end

local function ReadStringZero( Entity, Address )
        local Table = { }
        for I = Address, Address + 16384 do
                local Byte = Entity:ReadCell( I, Byte )
				
                if !Byte then
					return ""
				elseif Byte < 1 then
					break
                elseif Byte >= 256 then
					Byte = 32
				end
				
				Table[#Table + 1] = String_Char( Math_Floor( Byte ) )
        end
		
        return Table_Concat( Table )
end

local WA_Seralized = { }

local function WriteArray( Entity, Address, Data, Clear )
        if ( Entity:WriteCell( Address + #Data - 1, 0 ) ) then 

			Entity:WriteCell( Address + #Data, 0 )
			local Free_Address = Address + #Data + 1

			for I, Value in ipairs( Data ) do
					local Type = type( Value )
					
					if Type == "number" then
							if ( !Entity:WriteCell( Address + I - 1, Value ) ) then
								WA_Seralized = Clear and WA_Seralized or { }
								return 0
							end
							
					elseif Type == "string" then
							if ( !Entity:WriteCell( Address + I - 1, Free_Address ) ) then 
								WA_Seralized = Clear and WA_Seralized or { }
								return 0
							else
								Free_Address = WriteStringZero( Entity, Free_Address, Value )
								
								if ( Free_Address == 0 ) then
									WA_Seralized = Clear and WA_Seralized or { }
									return 0
								end
							end
					elseif Type == "table" then
							if ( Value.__Vector3 ) then
								if ( !Entity:WriteCell( Address + I - 1, Free_Address ) ) then
									WA_Seralized = Clear and WA_Seralized or { }
									return 0
								else
									Free_Address = WriteArray( Entity, Free_Address, { Value.x, Value.y, Value.z } )
								end
							elseif WA_Seralized[ Value ] then
									if ( !Entity:WriteCell( Address + I -1, WA_Seralized[ Value ] ) ) then
										WA_Seralized = Clear and WA_Seralized or { }
										return 0
									end
							else
									WA_Seralized[ Value ] = Free_Address
									if ( !Entity:WriteCell( Address + I - 1, Free_Address ) ) then
										WA_Seralized = Clear and WA_Seralized or { }
										return 0
									else
										Free_Address = WriteArray( Entity, Free_Address, Value )
									end
							end
					end
			end
			
			WA_Seralized = Clear and WA_Seralized or { }
			return Free_Address
	end
	
	WA_Seralized = Clear and WA_Seralized or { }
	return 0
end

Core:AddExternal( "WriteStringZero", WriteStringZero )
Core:AddExternal( "ReadStringZero", ReadStringZero )
Core:AddExternal( "WriteArray", WriteArray )

/************************************************************************/

Core:SetPerf( LEMON_PERF_EXPENSIVE )

Core:AddFunction("writeString", "wl:n,s", "n", [[
if $IsValid(value %1) and value %1.WriteCell then
	%util = %WriteStringZero(value %1, value %2, value %3 )
end]], "( %util or 0 )" )

Core:AddFunction("readString", "wl:n", "s", [[
if $IsValid(value %1) and value %1.WriteCell then
	%util = %ReadStringZero(value %1, value %2 )
end]], "( %util or \"\" )" )


/******************************************************************************/

Core:AddFunction("writeTable", "wl:n,t", "n", [[
if $IsValid(value %1) and value %1.WriteCell then
	%util = %WriteArray(value %1, value %2, value %3, true )
end]], "( %util or 0 )" )

/*==============================================================================================
	Console Screens: Just gona use an external to save time =D
==============================================================================================*/
local Clamp = math.Clamp
local ToByte = string.byte

local function ToColor( Col )
	local R = Clamp( Floor(Col[1] / 28), 0, 9 )
	local G = Clamp( Floor(Col[2] / 28), 0, 9 )
	local B = Clamp( Floor(Col[3] / 28), 0, 9 )
	return math.Clamp( Floor(R) * 100 + Floor(G) * 10 + Floor(B), 0, 999 )
end

Core:AddExternal( "WriteToScreen", function( Entity, String, X, Y, TextColor, BackGround, Flash )
	if IsValid( Entity ) and Entity.WriteCell then
		TextColor = ( Colour and ToColor( TextColor ) or 999 )
		BackGround = ( BackGround and ToColor( BackGround ) or 0 )
		Flash = Flash and 1 or 0
		
		local Peram, Xorig = Flash * 1000000 + BackGround * 1000 + TextColor, X
		
		for I = 1, #String do

			local Byte = ToByte(String, I)

			if Byte == 10 then
				Y = Y + 1
				X = Xorig
			else
				if X >= 30 then
					X = 0
					Y = Y + 1
				end

				local Address = 2 * (Y * 30 + X)
				X = X + 1 

				if Address >= 1080 or Address < 0 then return end

				Entity:WriteCell(Address, Byte)
				Entity:WriteCell(Address + 1, Peram)
			end
		end
	end
end )

Core:SetPerf( LEMON_PERF_EXPENSIVE * 2 )

Core:AddFunction("writeString", "wl:s,n,n", "", "%WriteToScreen( value %1, value %2, value %3, value %4, value %5, value %6 )", "" )

Core:AddFunction("writeString", "wl:s,n,n,n", "", "%WriteToScreen( value %1, value %2, value %3, value %4, value %5, value %6 )", "" )
Core:AddFunction("writeString", "wl:s,n,n,c", "", "%WriteToScreen( value %1, value %2, value %3, value %4, value %5, value %6 )", "" )

Core:AddFunction("writeString", "wl:s,n,n,n,n", "", "%WriteToScreen( value %1, value %2, value %3, value %4, value %5, value %6 )", "" )
Core:AddFunction("writeString", "wl:s,n,n,c,c", "", "%WriteToScreen( value %1, value %2, value %3, value %4, value %5, value %6 )", "" )
Core:AddFunction("writeString", "wl:s,n,n,c,n", "", "%WriteToScreen( value %1, value %2, value %3, value %4, value %5, value %6 )", "" )
Core:AddFunction("writeString", "wl:s,n,n,n,c", "", "%WriteToScreen( value %1, value %2, value %3, value %4, value %5, value %6 )", "" )

Core:AddFunction("writeString", "wl:s,n,n,n,n,b", "", "%WriteToScreen( value %1, value %2, value %3, value %4, value %5, value %6 )", "" )
Core:AddFunction("writeString", "wl:s,n,n,c,c,b", "", "%WriteToScreen( value %1, value %2, value %3, value %4, value %5, value %6 )", "" )
Core:AddFunction("writeString", "wl:s,n,n,c,n,b", "", "%WriteToScreen( value %1, value %2, value %3, value %4, value %5, value %6 )", "" )
Core:AddFunction("writeString", "wl:s,n,n,n,c,b", "", "%WriteToScreen( value %1, value %2, value %3, value %4, value %5, value %6 )", "" )

