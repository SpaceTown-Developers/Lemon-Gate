/*==============================================================================================
	Expression Advanced: Entitys.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" )

/*==============================================================================================
	Section: Class and Operators
==============================================================================================*/
local WireLink = Core:NewClass( "wl", "wirelink" )

WireLink:Extends( "e" )

WireLink:Wire_Name( "WIRELINK" )

function WireLink.Wire_In( Context, Cell, Value ) Context.Memory[ Cell ] = Value end

-- Get Port Operators:

Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddOperator( "[]", "wl,s,n", "n", [[%context:FromWL( value %1, "NORMAL", value %2, 0 )]] )

Core:AddOperator( "[]", "wl,s,s", "s", [[%context:FromWL( value %1, "STRING", value %2, "" )]] )

Core:AddOperator( "[]", "wl,s,e", "e", [[%context:FromWL( value %1, "ENTITY", value %2, %NULL_ENTITY )]] )

Core:AddOperator( "[]", "wl,s,v", "v", [[local %Val = %context:FromWL( value %1, "VECTOR", value %2, {x = 0, y = 0, z = 0} )]], "{%Val.x, %Val.y, %Val.z}" )

Core:AddOperator( "[]", "wl,s,a", "a", [[local %Val = %context:FromWL( value %1, "ANGLE", value %2, {p = 0, y = 0, r = 0} )]], "{%Val.p, %Val.y, %Val.r}" )

-- Set Port Operators:

Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddOperator( "[]=", "wl,s,n", "", [[%context:FromWL( value %1, "NORMAL", value %2, value %3 )]], "" )

Core:AddOperator( "[]=", "wl,s,s", "", [[%context:FromWL( value %1, "STRING", value %2, value %3 )]], "" )

Core:AddOperator( "[]=", "wl,s,e", "", [[%context:FromWL( value %1, "ENTITY", value %2, value %3 )]], "" )

Core:AddOperator( "[]=", "wl,s,v", "", [[%context:FromWL( value %1, "VECTOR", value %2, value %3 )]], "" )

Core:AddOperator( "[]=", "wl,s,a", "", [[%context:FromWL( value %1, "ANGLE", value %2, value %3 )]], "" )

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
	%Val = { %WL:ReadCell( Cell ) or 0, %WL:ReadCell( Cell + 1 ) or 0, %WL:ReadCell( Cell + 2 ) or 0 }
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

Core:AddOperator( "[]=", "wl,n,n", "", [[
local %WL = value %1
if $IsValid(%WL) and %WL.WriteCell then
	%WL:WriteCell( value %2, value %3 )
end]], "" )

Core:AddOperator( "[]=", "wl,n,v", "", [[
local %WL = value %1
if $IsValid(%WL) and %WL.WriteCell then
	local %Cell, %Vec = value %2, value %3
	%WL:WriteCell( %Cell, %Vec[1] )
	%WL:WriteCell( %Cell + 1, %Vec[2] )
	%WL:WriteCell( %Cell + 2, %Vec[3] )
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

