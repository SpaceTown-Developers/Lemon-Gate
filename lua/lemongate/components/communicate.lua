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
local Buffer = Component:NewClass( "b", "buffer", { Cells = { }, Types = { }, R = 0, W = 0 } )

Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction( "buffer", "", "b", "{ Cells = { }, Types = { }, R = 0, W = 0 }" )

-- Operators:

Component:AddOperator( "#", "b", "n", "(#value %1.Cells)" )

-- Write Functions:

Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddFunction( "writeNumber", "b:n", "", [[
local %Buffer = value %1
%Buffer.W = %Buffer.W + 1
%Buffer.Types[ %Buffer.W ] = "n"
%Buffer.Cells[ %Buffer.W ] = value %2
]], "" )

Component:AddFunction( "writeString", "b:s", "", [[
local %Buffer = value %1
%Buffer.W = %Buffer.W + 1
%Buffer.Types[ %Buffer.W ] = "s"
%Buffer.Cells[ %Buffer.W ] = value %2
]], "" )

Component:AddFunction( "writeEntity", "b:e", "", [[
local %Buffer = value %1
%Buffer.W = %Buffer.W + 1
%Buffer.Types[ %Buffer.W ] = "e"
%Buffer.Cells[ %Buffer.W ] = value %2
]], "" )

Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction( "writePos", "b", "n", "(value %1.W)" )

-- Read Functions:

Component:SetPerf( LEMON_PERF_ABNORMAL )

Component:AddFunction( "readNumber", "b:", "n", [[
local %Buffer, %Val = value %1
if !%Buffer.Cells[ %Buffer.R ] then
	%context:Throw( %trace, "buffer", "Reached end of buffer" )
elseif %Buffer.Types[ %Buffer.R ] != \"n\" then
	%context:Throw( %trace, "buffer", "Attempted to read number from " .. %LongType( %Buffer.Types[ %Buffer.R ] ) )
else
	%Val = Buffer.Cells[ %Buffer.R ]
	%Buffer.R = %Buffer.R + 1
end]], "%Val" )

Component:AddFunction( "readString", "b:", "s", [[
local %Buffer, %Val = value %1
if !%Buffer.Cells[ %Buffer.R ] then
	%context:Throw( %trace, "buffer", "Reached end of buffer" )
elseif %Buffer.Types[ %Buffer.R ] != \"s\" then
	%context:Throw( %trace, "buffer", "Attempted to read string from " .. %LongType( %Buffer.Types[ %Buffer.R ] ) )
else
	%Val = Buffer.Cells[ %Buffer.R ]
	%Buffer.R = %Buffer.R + 1
end]], "%Val" )

Component:AddFunction( "readEntity", "b:", "e", [[
local %Buffer, %Val = value %1
if !%Buffer.Cells[ %Buffer.R ] then
	%context:Throw( %trace, "buffer", "Reached end of buffer" )
elseif %Buffer.Types[ %Buffer.R ] != \"e\" then
	%context:Throw( %trace, "buffer", "Attempted to read entity from " .. %LongType( %Buffer.Types[ %Buffer.R ] ) )
else
	%Val = Buffer.Cells[ %Buffer.R ]
	%Buffer.R = %Buffer.R + 1
end]], "%Val" )

Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction( "readPos", "b", "n", "(value %1.R)" )

-- Misc:

Component:AddFunction( "type", "b:", "s", "local %Buffer = value %1", "%LongType( %Buffer.Types[ %Buffer.R ] )" )

Component:AddFunction( "type", "b:n", "s", "%LongType( value %1.Types[ value %2 ] )" )

Component:AddFunction( "skip", "b:", "", [[
local %Buffer = value %1
%Buffer.R = %Buffer.R + 1
]], "" )

/*==============================================================================================
	Section: Buffer Sending/Reciving
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddEvent( "receiveBuffer", "e,s,b", "" )

Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction( "send", "b:s,e", "", [[
local %Buffer, %Ent = value %1, value %3
if %Ent and %Ent:IsValid( ) and %Ent.IsLemonGate then
	table.insert( %data.BufferQue, {%Ent, value %2, { Cells = table.Copy( %Buffer.Cells ), Types = table.Copy( %Buffer.Types ), R = %Buffer.R, W = %Buffer.W} } )
end]] )

/*==============================================================================================
	Section: Saving and Loading
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddEvent( "saveToDupe", "", "b" )

Component:AddEvent( "LoadFromDupe", "b", "" )

/*==============================================================================================
	Section: API Hooks
==============================================================================================*/
function Component:BuildContext( Gate )
	Gate.Context.Data.BufferQue = { }
end

function Component:UpdateExecution( Gate )
	local Que = Gate.Context.Data.BufferQue
	for I = 1, #Que do
		local Data = Que[I]
		local Entity = Data[1]
		
		if Entity and Entity:IsValid( ) and Entity.IsLemonGate and Entity:IsRunning( ) then
			Entity:CallEvent( "receiveBuffer", Gate, Data[2], Data[3] )
		end
	end
	
	Gate.Context.Data.BufferQue = { }
end

function Component:BuildDupeInfo( Gate, Context, DupeTable )
	if self:IsRunning( ) then
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

function Component:ApplyDupeInfo( Player, Entity, DupeTable, FromID )
	local Buffer = DupeTable.Buffer
	
	if Buffer then
		for I = 1, Buffer.W do
			if Buffer.Types[I] == "e" then
				local Ent = FromID( Buffer.Cells[I] )
				
				if Ent and Ent:IsValid() then
					Buffer.Cells[I] = Ent
				else
					Buffer.Cells[I] = Entity(-1)
				end
			end
		end
		
		Gate:CallEvent( "LoadFromDupe", Buffer )
	end
end