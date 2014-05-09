/*==============================================================================================
	Expression Advanced: Server Side Gate Entity.
	Purpose: This is the entity that does everything!
	Creditors: Rusketh
==============================================================================================*/
if WireLib and LEMON then
	include( "shared.lua" )
	AddCSLuaFile( "shared.lua" )
	AddCSLuaFile( "cl_init.lua" )
else
	return MsgN( "Skipping LemonGate Entity" )
end

/*==============================================================================================
	CPU Limits
==============================================================================================*/
LEMON.Tick_CPU = CreateConVar( "lemongate_tick_cpu", "16000", {FCVAR_REPLICATED} )
LEMON.Soft_CPU = CreateConVar( "lemongate_soft_cpu", "4000", {FCVAR_REPLICATED} )
LEMON.Hard_CPU = CreateConVar( "lemongate_hard_cpu", "50000", {FCVAR_REPLICATED} )

/*==============================================================================================
	NameSpaces
==============================================================================================*/
local string = string
local Str_Upper, Str_Format = string.upper, string.format
local CurTime, SysTime, pairs ,pcall = CurTime, SysTime, pairs ,pcall

/*==============================================================================================
	Section: Status!
==============================================================================================*/
-- 0 = Normal
-- 1 = Overload
-- 2 = TickExceed
-- 3 = Crashed

function ENT:SetStatus( Status )
	self:SetNWInt( "status", Status )
end

/*==============================================================================================
	Section: Erroring!
==============================================================================================*/
local CrashColor = Color( 255, 0, 0 )

function ENT:Crash( )
	self.Context = nil
	self:SetStatus( 3 )

	if self:GetModel( ) == "models/lemongate/lemongate.mdl" then return end
	
	self:SetColor( CrashColor )
end

function ENT:ScriptError( Trace, ErrorMsg, First, ... )
	ErrorMsg = ErrorMsg or "Unkown error"
	
	if Trace then ErrorMsg = Str_Format( "%s at Line %s Char %s", ErrorMsg, Trace[1], Trace[2] ) end
	
	if First then ErrorMsg = Str_Format( ErrorMsg, First, ... ) end
	
	self:Crash( )
	
	WireLib.ClientError( ErrorMsg, self.Player )
end

function ENT:ExceptionError( ExectionData, Location )
	self:ScriptError( ExectionData.Trace, "uncatched exception '" .. ExectionData.Type .. "' in " .. Location .. "." )	
	WireLib.ClientError( "Msg: " .. ExectionData.Message, self.Player )
end

function ENT:LuaError( ErrorMsg )
	self:Crash( )
	
	WireLib.ClientError( "LemonGate: Suffered a LUA error" , self.Player )
	WireLib.ClientError( "LUA: " .. ErrorMsg , self.Player )
end

function ENT:Error( ErrorType, ErrorMsg )
	self:Crash( )
	
	WireLib.ClientError( ErrorType, self.Player )
	
	if !ErrorMsg then return end
	
	WireLib.ClientError( ErrorMsg, self.Player )
end

/*==============================================================================================
	Execution
==============================================================================================*/
local Updates = { }

hook.Add( "Tick", "LemonGate.Update", function( )
	for _, Gate in pairs( LEMON.API:GetEntitys( ) ) do
		if !IsValid( Gate ) or !Gate.IsLemonGate then continue end
		if Updates[ Gate ] then Gate:Update( ) end
		
		Gate:UpdateCPUQuota( )
		Gate:UpdateAnimation( )
		Gate:UpdateOverlay( )

	end

	Updates = { }
end )

function ENT:Update( )
	local Context = self.Context
	if !Context then return end

	Context:Update( )
	self:TriggerOutputs( )
	self:GarbageCollect( )

	LEMON.API:CallHook( "UpdateEntity", self )
end

function ENT:UpdateCPUQuota( )
	local Context = self.Context
	if !Context then return end

	Context.cpu_prevtick = Context.cpu_tickquota

	local softTime = ( LEMON.Soft_CPU:GetInt( ) * ( engine.TickInterval( ) / 0.0303030303 ) / 1000000 )
	Context.cpu_softquota = Context.cpu_softquota + ( Context.cpu_tickquota - softTime )
	Context.cpu_average = Context.cpu_average * 0.95 + Context.cpu_tickquota * 0.05

	if Context.cpu_softquota < 0 then Context.cpu_softquota = 0 end

	if Context.cpu_softquota * 1000000 > LEMON.Hard_CPU:GetInt( ) then
		self:ScriptError( nil, "Hard quota exceeded." )
		self:SetStatus( 2 ) -- Set gate on fire!
	elseif Context.cpu_softquota * 1000000 > LEMON.Hard_CPU:GetInt( )  * 0.3 then
		self:SetStatus( 1 ) -- Make the gate spark!

	elseif self:GetStatus( ) ~= 0 then
		self:SetStatus( 0 ) -- Stop the gate from sparking.
	end

	Context.cpu_tickquota = 0
	Context.cpu_timemark = nil
end

function ENT:Pcall( Location, Function, ... )
	local Context = self.Context
	
	if !Context then
		return self:Error( "Context lost." )
	elseif self.PreCall then
		self:PreCall( )
	end
	
	collectgarbage( "stop" )

	Context.cpu_timemark = SysTime( )

	local Ok, Status = pcall( Function, ... )

	Context.cpu_tickquota = Context.cpu_tickquota + ( SysTime( ) - Context.cpu_timemark )
	
	collectgarbage( "restart" )

	if Ok or Status == "Exit" then
		
		if Context.cpu_tickquota * 1000000 > LEMON.Tick_CPU:GetInt( ) then
			self:ScriptError( nil, "Tick quota exceeded." )
			self:SetStatus( 2 )
			return false, nil
		end

		Updates[self] = true
		return true, Status
	elseif Status == "Script" then
		self:ScriptError( Context.ScriptTrace, Context.ScriptError )
	elseif Status == "Exception" then
		self:ExceptionError( Context.Exception, Location )
	elseif Status == "Break" or Status == "Continue" then
		self:ScriptError( nil, "unexpected use of %s in %s.", Status, Location )
	else
		self:LuaError( Status )
	end
	
	return false, nil
end

function ENT:CallEvent( Name, ... )
	local Context = self.Context
	if !Context then return end
	
	local Event = Context["Event_" .. Name]
	if !Event then return end
	
	local Ok, Status = self:Pcall( "event " .. Name, Event, ... )
	
	if !Ok then return end
	if Status then return Status[1], self end
end

function ENT:GarbageCollect( )
	local Context = self.Context
	if !Context then return end
	
	local Memory, Delta = Context.Memory, Context.Delta
	if !Memory then return end
	
	for Reference, Cell in pairs( self.Cells ) do
		
		if Cell.NotGarbage then
			-- Do Nothing
		elseif Cell.Class.GarbageCollect then
			Cell.Class:GarbageCollect( self.Context, Reference )
		else
			Memory[Reference] = nil
			Delta[Reference] = nil
			--TODO: Garbage counter =D
		end
	end
end

/*==============================================================================================
	Compiling
==============================================================================================*/
function ENT:LoadScript( Script, Files, ScriptName )
	if self:IsRunning( ) then self:ShutDown( ) end
	
	local Context = LEMON:BuildContext( self, self.Player )
	
	self.Script = Script
	self.Files = Files or { }
	
	if ScriptName and ScriptName != "" and ScriptName != "generic" then
		self.ScriptName = ScriptName
		self.GateName = ScriptName
	end
	
	self:CompileScript( Script, Files )
end

local NormalColor = Color( 255, 255, 255 )

function ENT:CompileScript( Script, Files )
	local Ok, Instance = LEMON.Compiler.Execute( Script, Files )
	
	if !Ok then
		self:Error( "Compiler Error", Instance )
	elseif !Instance.Execute then
		self:Error( "Reload Required" )
	else
		self:SetColor( NormalColor )
		self:SetStatus( 0 )
		self:BuildScript( Instance )
	end

	self:LoadEffect( )

	self:SetStatus( 0 )
	self:UpdateOverlay( )

	self:Pcall( "main thread", Instance.Execute, self.Context )
end

function ENT:BuildScript( Instance )
	self.Cells = Instance.Cells
	
	self:BuildInputs( self.Cells, Instance.InPorts )
	self:BuildOutputs( self.Cells, Instance.OutPorts )
	self:LoadFromInputs( )
end

/*==============================================================================================
	Wire Functions
==============================================================================================*/
local function SortPorts( PortA, PortB )
	local TypeA = PortA[2] or "NORMAL"
	local TypeB = PortB[2] or "NORMAL"
	
	if TypeA ~= TypeB then
		if TypeA == "NORMAL" then
			return true
		elseif TypeB == "NORMAL" then
			return false
		end
		
		return TypeA < TypeB
	else
		return PortA[1] < PortB[1]
	end
end

function ENT:BuildInputs( Cells, Ports )
	local Unsorted = { }
	
	for Variable, Reference in pairs( Ports ) do
		local Cell = Cells[ Reference ]
		Unsorted[ #Unsorted + 1 ] = { Variable, Cell.Class.WireName }
	end
	
	table.sort( Unsorted, SortPorts )
	
	local Names = { }
	local Types = { }
	
	for I = 1, #Unsorted do
		local Port = Unsorted[I]
		Names[I] = Port[1]
		Types[I] = Port[2]
	end
	
	self.InPorts = Ports
	self.DupeInPorts = { Names, Types }
	self.Inputs = WireLib.AdjustSpecialInputs( self, Names, Types )
end


function ENT:BuildOutputs( Cells, Ports )
	local OutClick = { }
	local Unsorted = { }
	
	for Variable, Reference in pairs( Ports ) do
		local Cell = Cells[ Reference ]
		Unsorted[ #Unsorted + 1 ] = { Variable, Cell.Class.WireName }
		
		if Cell.Class.OutClick then
			OutClick[ Reference ] = Variable
		end
	end
	
	table.sort( Unsorted, SortPorts )
	
	local Names = { }
	local Types = { }
	
	for I = 1, #Unsorted do
		local Port = Unsorted[I]
		Names[I] = Port[1]
		Types[I] = Port[2]
	end
	
	self.OutPorts = Ports
	self.OutClick = OutClick
	self.DupeOutPorts = { Names, Types }
	self.Outputs = WireLib.AdjustSpecialOutputs( self, Names, Types )
end

function ENT:LoadFromInputs( )
	--Note: This will load inports into memory!
	local Cells = self.Cells
	
	for Variable, Port in pairs( self.Inputs ) do
		local Reference = self.InPorts[ Variable ]
		
		if Reference then
			local Cell = Cells[ Reference ]
			
			if Cell and Port.Type == Cell.Class.WireName then
				Cell.Class.Wire_In( self.Context, Reference, Port.Value )
			end
		end
	end
end

function ENT:TriggerInput( Key, Value )
	local Context = self.Context
	if !self.Context then return end
	
	local Reference = self.InPorts[ Key ]
	local Cell = self.Cells[ Reference ]
	
	if !Cell then return end
	
	Cell.Class.Wire_In( self.Context, Reference, Value )
	Context.Click[ Reference ] = true
			
	self:CallEvent( "trigger", Key, Cell.Class.Name )
			
	Context.Click[ Reference ] = false
end

function ENT:TriggerOutputs( )
	local Context = self.Context
	if !self.Context then return end
	
	local Cells = self.Cells
	
	for Name, Reference in pairs( self.OutPorts ) do
		local Class = Cells[ Reference ].Class
		
		if Context.Trigger[ Reference ] then
			local Value = Class.Wire_Out( Context, Reference )
			
			WireLib.TriggerOutput( self, Name, Value )
		elseif self.OutClick[ Reference ] then
			local Val = Context.Memory[ Reference ]
			
			if Val and Val.Click then
				Val.Click = nil
				local Value = Class.Wire_Out( Context, Reference )
				WireLib.TriggerOutput( self, Name, Value )
			end
		end
	end
end

/*==============================================================================================
	Lemon Stuff
==============================================================================================*/
function ENT:IsRunning( )
	return self.Context ~= nil
end

function ENT:SetGateName( Name )
	self.GateName = Name or "LemonGate"
end

function ENT:GetScript( )
	return self.Script or "", self.Files or { }
end

function ENT:Reset( )
	if self.Script then
		self:LoadScript( self:GetScript( ) )
	end
end

function ENT:ShutDown( )
	self:CallEvent( "shutdown" )
	LEMON.API:CallHook( "ShutDown", self, self.Context )
end

/*==============================================================================================
	Section: Duplication
==============================================================================================*/
function ENT:BuildDupeInfo( )
	local DupeTable = self.BaseClass.BuildDupeInfo( self )
	
	local Script, Files = self:GetScript( )
	
	DupeTable.ScriptName = self.ScriptName
	DupeTable.Script = Script
	DupeTable.Files = Files
	
	LEMON.API:CallHook( "BuildDupeInfo", self, DupeTable )
	
	return DupeTable
end

function ENT:ApplyDupeInfo( Player, Entity, DupeTable, FromID )
	self.Player = Player
	self.PlyID = Player:EntIndex( )
	
	self:LoadScript( DupeTable.Script, DupeTable.Files, DupeTable.ScriptName )
		
	self.BaseClass.ApplyDupeInfo( self, Player, Entity, DupeTable, FromID )
	
	if self.Context then self:CallEvent( "dupePasted" ) end
			
	LEMON.API:CallHook( "ApplyDupeInfo", self, DupeTable, FromID )
end

function ENT:ApplyDupePorts( InPorts, OutPorts )
	if InPorts then
		self.DupeInPorts = OutPorts
		self.Inputs = WireLib.AdjustSpecialInputs( self, InPorts[1], InPorts[2] )
	end
	
	if OutPorts then
		self.DupeOutPorts = OutPorts
		self.Outputs = WireLib.AdjustSpecialOutputs( self, OutPorts[1], OutPorts[2] )
	end
end

/*==============================================================================================
	Entity
==============================================================================================*/
function ENT:Initialize( )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self:SetUseType( SIMPLE_USE )
	
	self.Inputs = WireLib.CreateInputs( self, { } )
	self.Outputs = WireLib.CreateOutputs( self, { } )
	
	self.GateName = "LemonGate"
	self:UpdateOverlay( )

	LEMON.API:CallHook("Create", self )
end

function ENT:Think( )
	if self.Context then
		self:CallEvent( "think" )
	end

	self.BaseClass.Think( self )
	self:NextThink( CurTime() )
	
	return true
end

function ENT:UpdateOverlay( )
	
	local Context = self.Context

	if !Context or Context.cpu_tick == 0 then
		return self:SetOverlayText( self.GateName .. "\nOffline: 0us cpu, 0%" )
	end

	local cpu_tick = Context.cpu_prevtick * 1000000
	local cpu_soft = Context.cpu_softquota * 1000000
	local cpu_average = Context.cpu_average * 1000000
	
	local tickquota = LEMON.Tick_CPU:GetInt()
	local softquota = LEMON.Soft_CPU:GetInt() * ( engine.TickInterval( ) / 0.0303030303 )
	local hardquota = LEMON.Hard_CPU:GetInt()

	local Warning = cpu_soft > hardquota * 0.3
	local Str = Str_Format( "%s\nOnline: %ius cpu, %i%%\nAverage: %ius cpu, %i%%", self.GateName, cpu_tick, cpu_tick / tickquota * 100, cpu_average, cpu_average / softquota * 100 )

	if Warning then Str = Str .. "\nWARNING: +" .. tostring(math.Round(cpu_soft / hardquota * 100) ) .. "%" end
	
	self:SetOverlayText( Str )
end

function ENT:UpdateAnimation( )
	if self:GetModel( ) ~= "models/lemongate/lemongate.mdl" then return end
	
	if self.Context and self.Context.cpu_average ~= 0 then
		self.SpinSpeed = math.Clamp((self.Context.cpu_average * 1000000) / LEMON.Soft_CPU:GetInt() * 9 + 1,1,10)
	else
		self.SpinSpeed = math.Clamp((self.SpinSpeed or 0) - 0.05,0,10)
	end
	
	self:SetPlaybackRate( self.SpinSpeed )
	self:ResetSequence( self:LookupSequence( self.SpinSpeed <= 0 and "idle" or "spin" ) )
end

local ExplodeOnRemove = CreateConVar( "combustible_lemon", "0" )

function ENT:OnRemove( ) 
	self:ShutDown( )
	LEMON.API:CallHook("Remove", self )
	
	if ExplodeOnRemove:GetBool( ) then
		local ED = EffectData( )
		ED:SetOrigin( self:GetPos( ) )
		util.Effect( "Explosion", ED )

		self:Fire("break")
	end
end

function ENT:Use( Activator, Caller )
	self:CallEvent( "use", Activator or Caller )
end

function ENT:LoadEffect( )
	local Effect = EffectData( )
	Effect:SetEntity( self )
	util.Effect( "lemon_load", Effect )
end

/*==============================================================================================
	Section: No silly WorkShop dupes!
==============================================================================================*/
-- I Changed my mind, for now!

-- local RealSSE = gmsave.ShouldSaveEntity
-- function gmsave.ShouldSaveEntity( Ent, ... )
 	-- if Ent:GetClass( ) == "lemongate" then
 		-- return false
 	-- end

 	-- return RealSSE( Ent, ... )
-- end