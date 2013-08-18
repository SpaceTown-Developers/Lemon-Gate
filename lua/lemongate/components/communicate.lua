/*==============================================================================================
	Expression Advanced: Component -> Comunication.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Component = API:NewComponent( "communication", true )

Component:AddException( "buffer" )

/*==============================================================================================
	Section: Buffer Class
==============================================================================================*/
local Buffer = Component:NewClass( "bf", "buffer", { Cells = { }, Types = { }, R = 0, W = 0 } )

Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction( "buffer", "", "bf", "{ Cells = { }, Types = { }, R = 0, W = 0 }" )

-- Operators:

Component:AddOperator( "#", "bf", "n", "(#value %1.Cells)" )

-- Write Functions:

Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddFunction( "writeBool", "bf:b", "", [[
local %Buffer = value %1
%Buffer.W = %Buffer.W + 1
%Buffer.Types[ %Buffer.W ] = "b"
%Buffer.Cells[ %Buffer.W ] = value %2
]], "" )

Component:AddFunction( "writeNumber", "bf:n", "", [[
local %Buffer = value %1
%Buffer.W = %Buffer.W + 1
%Buffer.Types[ %Buffer.W ] = "n"
%Buffer.Cells[ %Buffer.W ] = value %2
]], "" )

Component:AddFunction( "writeString", "bf:s", "", [[
local %Buffer = value %1
%Buffer.W = %Buffer.W + 1
%Buffer.Types[ %Buffer.W ] = "s"
%Buffer.Cells[ %Buffer.W ] = value %2
]], "" )

Component:AddFunction( "writeEntity", "bf:e", "", [[
local %Buffer = value %1
%Buffer.W = %Buffer.W + 1
%Buffer.Types[ %Buffer.W ] = "e"
%Buffer.Cells[ %Buffer.W ] = value %2
]], "" )

Component:AddFunction( "writeAngle", "bf:a", "", [[
local %Buffer = value %1
%Buffer.W = %Buffer.W + 1
%Buffer.Types[ %Buffer.W ] = "a"
%Buffer.Cells[ %Buffer.W ] = value %2
]], "" )

Component:AddFunction( "writeVector", "bf:v", "", [[
local %Buffer = value %1
%Buffer.W = %Buffer.W + 1
%Buffer.Types[ %Buffer.W ] = "v"
%Buffer.Cells[ %Buffer.W ] = value %2
]], "" )

Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction( "writePos", "bf", "n", "(value %1.W)" )

-- Read Functions:

Component:SetPerf( LEMON_PERF_ABNORMAL )

Component:AddFunction( "readBool", "bf:", "b", [[
local %Buffer, %Val = value %1
if %Buffer.Cells[ %Buffer.R ] == nil then
	%context:Throw( %trace, "buffer", "Reached end of buffer" )
elseif %Buffer.Types[ %Buffer.R ] != "b" then
	%context:Throw( %trace, "buffer", "Attempted to read number from " .. %LongType( %Buffer.Types[ %Buffer.R ] ) )
else
	%Val = Buffer.Cells[ %Buffer.R ]
	%Buffer.R = %Buffer.R + 1
end]], "%Val" )

Component:AddFunction( "readNumber", "bf:", "n", [[
local %Buffer, %Val = value %1
if %Buffer.Cells[ %Buffer.R ] == nil then
	%context:Throw( %trace, "buffer", "Reached end of buffer" )
elseif %Buffer.Types[ %Buffer.R ] != "n" then
	%context:Throw( %trace, "buffer", "Attempted to read number from " .. %LongType( %Buffer.Types[ %Buffer.R ] ) )
else
	%Val = Buffer.Cells[ %Buffer.R ]
	%Buffer.R = %Buffer.R + 1
end]], "%Val" )

Component:AddFunction( "readString", "bf:", "s", [[
local %Buffer, %Val = value %1
if %Buffer.Cells[ %Buffer.R ] == nil then
	%context:Throw( %trace, "buffer", "Reached end of buffer" )
elseif %Buffer.Types[ %Buffer.R ] != "s" then
	%context:Throw( %trace, "buffer", "Attempted to read string from " .. %LongType( %Buffer.Types[ %Buffer.R ] ) )
else
	%Val = Buffer.Cells[ %Buffer.R ]
	%Buffer.R = %Buffer.R + 1
end]], "%Val" )

Component:AddFunction( "readEntity", "bf:", "e", [[
local %Buffer, %Val = value %1
if %Buffer.Cells[ %Buffer.R ] == nil then
	%context:Throw( %trace, "buffer", "Reached end of buffer" )
elseif %Buffer.Types[ %Buffer.R ] != "e" then
	%context:Throw( %trace, "buffer", "Attempted to read entity from " .. %LongType( %Buffer.Types[ %Buffer.R ] ) )
else
	%Val = Buffer.Cells[ %Buffer.R ]
	%Buffer.R = %Buffer.R + 1
end]], "%Val" )

Component:AddFunction( "readAngle", "bf:", "a", [[
local %Buffer, %Val = value %1
if %Buffer.Cells[ %Buffer.R ] == nil then
	%context:Throw( %trace, "buffer", "Reached end of buffer" )
elseif %Buffer.Types[ %Buffer.R ] != "a" then
	%context:Throw( %trace, "buffer", "Attempted to read angle from " .. %LongType( %Buffer.Types[ %Buffer.R ] ) )
else
	%Val = Buffer.Cells[ %Buffer.R ]
	%Buffer.R = %Buffer.R + 1
end]], "%Val" )

Component:AddFunction( "readVector", "bf:", "v", [[
local %Buffer, %Val = value %1
if %Buffer.Cells[ %Buffer.R ] == nil then
	%context:Throw( %trace, "buffer", "Reached end of buffer" )
elseif %Buffer.Types[ %Buffer.R ] != "v" then
	%context:Throw( %trace, "buffer", "Attempted to read angle from " .. %LongType( %Buffer.Types[ %Buffer.R ] ) )
else
	%Val = Buffer.Cells[ %Buffer.R ]
	%Buffer.R = %Buffer.R + 1
end]], "%Val" )


Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction( "readPos", "bf", "n", "(value %1.R)" )

-- Misc:

Component:AddFunction( "type", "bf:", "s", "local %Buffer = value %1", "%LongType( %Buffer.Types[ %Buffer.R ] )" )

Component:AddFunction( "type", "bf:n", "s", "%LongType( value %1.Types[ value %2 ] )" )

Component:AddFunction( "skip", "bf:", "", [[
local %Buffer = value %1
%Buffer.R = %Buffer.R + 1
]], "" )

/*==============================================================================================
	Section: Buffer Sending/Reciving
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddEvent( "receiveBuffer", "s,e,bf", "" )

Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction( "send", "bf:s,e", "", [[
local %Buffer, %Ent = value %1, value %3
if %Ent and %Ent:IsValid( ) and %Ent.IsLemonGate then
	table.insert( %data.BufferQue, {%Ent, value %2, { Cells = table.Copy( %Buffer.Cells ), Types = table.Copy( %Buffer.Types ), R = %Buffer.R, W = %Buffer.W} } )
end]] )

/*==============================================================================================
	Section: Saving and Loading
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddEvent( "saveToDupe", "", "bf" )

Component:AddEvent( "loadFromDupe", "bf", "" )

/*==============================================================================================
	Section: API Hooks
==============================================================================================*/
function Component:CreateContext( Context )
	Context.Data.BufferQue = { }
end

function Component:UpdateContext( Context )
	local Que = Context.Data.BufferQue
	for I = 1, #Que do
		local Data = Que[I]
		local SendTo = Data[1]
		
		if IsValid( SendTo ) and SendTo.IsLemonGate and SendTo:IsRunning( ) then
			SendTo:CallEvent( "receiveBuffer", Data[2], Context.Entity, Data[3] )
		end
	end
	
	Context.Data.BufferQue = { }
end

function Component:BuildDupeInfo( Gate, DupeTable )
	if Gate:IsRunning( ) then
		local Buffer = Gate:CallEvent( "saveToDupe" )
		
		if Buffer then
			for I = 1, Buffer.W do
				if Buffer.Types[I] == "e" then
					local Entity = Buffer.Cells[I]
					
					if !Entity or !Entity:IsValid( ) then
						Buffer.Cells[I] = -1
					else
						Buffer.Cells[I] = Entity:EntIndex( )
					end
				end
			end

			DupeTable.Buffer = Buffer
		end
	end
end

function Component:ApplyDupeInfo( Gate, DupeTable, FromID )
	local Buffer = DupeTable.Buffer
	
	if Buffer and Gate:IsRunning( ) then
		for I = 1, Buffer.W do
			local Type = Buffer.Types[I]
			local Class = API:GetClass( Type, true )
			
			if Type == "e" then
				local Ent = FromID( Buffer.Cells[I] )
				
				if Ent and Ent:IsValid() then
					Buffer.Cells[I] = Ent
				else
					Buffer.Cells[I] = Entity(-1)
				end
			elseif Class and Class.__MetaTable then	
				setmetatable( Buffer.Cells[I], Class.__MetaTable )
			end
		end
		
		Gate:CallEvent( "LoadFromDupe", Buffer )
	end
end


/*==============================================================================================
	Section: Special Table function!
==============================================================================================*/
/* AN ATTEMPT TO GET TABLES INTO BUFFERS!
   FAILED DUE TO SPEED / KEY-ENTITYS!
   
local IsTable = { ["table"] = true, ["Vector"] = true, ["Angle"] = true }
local setmetatable, getmetatable = setmetatable, getmetatable
local CopyTable, ExportTable, ImportTable

function CopyTable( Table )
	local New = setmetatable( { }, getmetatable( Table ) )
	
	for Key, Value in pairs( Table ) do
		if IsTable[ type( Key ) ] then
			Key = CopyTable( Key )
		end
		
		if IsTable[ type( Value ) ] then
			Value = CopyTable( Value )
		end
		
		New[ Key ] = Value
	end
	
	return New
end

local function ExportBuffer( Buffer )
	Buffer.Data = Buffer.Cells
	ExportTable( Buffer )
	Buffer.Cells = Buffer.Data
	Buffer.Data = nil
end

function ExportTable( Table )
	for Index, Type in pairs( Table.Types ) do
		if Type == "e" then
			local Entity = Table.Data[ Index ]
			Table.Data[ Index ] = IsValid( Entity ) and Entity:EntIndex( ) or -1
		elseif Type == "t" then
			ExportTable( Table.Data[ Index ] )
		elseif Type == "bf" then
			ExportBuffer( Table.Data[ Index ] )
		end
		
		if type( Index ) == "Entity" then
			NewIndex = 
		end
	end
end

local function ImportBuffer( Buffer, FromID )
	Buffer.Data = Buffer.Cells
	ImportTable( Buffer, FromID )
	Buffer.Cells = Buffer.Data
	Buffer.Data = nil
end

function ImportTable( Table, FromID )
	for Index, Type in pairs( Table.Types ) do
		if Type == "e" then
			local Ent = FromID( Buffer.Cells[I] )
			
			if Ent and Ent:IsValid() then
				Buffer.Cells[I] = Ent
			else
				Buffer.Cells[I] = Entity(-1)
			end
		
		
			local Entity = Table.Data[ Index ]
			Table.Data[ Index ] = IsValid( Entity ) and Entity:EntIndex( ) or -1
		elseif Type == "t" then
			ExportTable( Table.Data[ Index ] )
		elseif Type == "bf" then
			ExportBuffer( Table.Data[ Index ] )
		end
	end
end */