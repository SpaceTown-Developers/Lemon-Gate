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
	NameSpaces
==============================================================================================*/
local string = string
local Str_Upper, Str_Format = string.upper, string.format
local CurTime, SysTime, pairs ,pcall = CurTime, SysTime, pairs ,pcall

/*==============================================================================================
	Section: Erroring!
==============================================================================================*/
local CrashColor = Color( 255, 0, 0 )

function ENT:Crash( )
	self.Context = nil
	self:SetColor( CrashColor )
	self:SetNWBool( "Crashed", true )
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
	for Gate, _ in pairs( Updates ) do
		if IsValid( Gate ) then Gate:Update( ) end
	end; Updates = { }
end )

function ENT:Update( )
	if !self.Context then return end

	self:TriggerOutputs( )
	self.Context:Update( )
	self:GarbageCollect( )
	LEMON.API:CallHook( "UpdateEntity", self )
end

function ENT:Pcall( Location, Function, ... )
	if self.PreCall then self:PreCall( ) end
	
	local BenchMark = SysTime( )
	local Ok, Status = pcall( Function, ... )
	
	local Context = self.Context
	if !Context then return self:Error( "Context lost." ) end

	Context.Time = Context.Time + (SysTime( ) - BenchMark)
	
	if Ok or Status == "Exit" then
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
		self:SetNWBool( "Crashed", false )
		self:BuildScript( Instance )
	end
	
	if Instance.Directive_Model then
		self:SetModel( Instance.Directive_Model )
		self:PhysicsInit( SOLID_VPHYSICS )
	end

	self:LoadEffect( )
	
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
	
	self.Overlay = "Offline"
	self.GateName = "LemonGate"
	self:UpdateOverlay( true )

	LEMON.API:CallHook("Create", self )
end

function ENT:Think( )
	local Time = CurTime( )
	local Context = self.Context
	
	if Context then
		self.OpCount = Context.Perf
		Context.CPUTime = Context.CPUTime * 0.95 + Context.Time * 0.05
		
		Context.Time = 0
		Context.Perf = 0
	end
	
	self:UpdateOverlay( )

	self.BaseClass.Think( self )
	self:NextThink( Time )
	
	return true
end

function ENT:GetOverLayText( )
	local Status = "Offline: 0 ops, 0%"
	local Perf = self.OpCount or 0
	local Max = GetConVarNumber( "lemongate_perf" )

	if self:GetNWBool( "Crashed", false ) then
		Status = "Script Error"
	elseif Perf >= Max then
		Status = "Warning: " .. Perf .." ops, 100%"
	elseif Perf >= (Max * 0.9 ) then
		Status = "Warning: " .. string.format( "%s ops, %s%%", Perf, math.ceil((Perf / Max) * 100) )
	elseif Perf > 0 then
		Status = self.Overlay .. ": " .. string.format( "%s ops, %s%%", Perf, math.ceil((Perf / Max) * 100) ) 
	end
	
	return string.format( "%s\n%s\ncpu time: %ius", self.GateName, Status, math.Round( self.Context.CPUTime * 1000000, 4 ) )
end

function ENT:UpdateOverlay( Clear )
	if Clear or !self.Context then
		self:SetOverlayData( { name = "Lemon Gate", txt = "Offline", opcount = 0, cpubench = 0 } )
	else
		self:SetOverlayData( { name = self.GateName, txt = self:GetOverLayText( ), opcount = self.OpCount, cpubench = self.Context.CPUTime * 1000000 } )
	end	
end

local ExplodeOnRemove = CreateConVar( "combustible_lemon", "0" )

function ENT:OnRemove( ) 
	self:ShutDown( )
	LEMON.API:CallHook("Remove", self )
	
	if ExplodeOnRemove:GetBool( ) then
		local ED = EffectData( )
		ED:SetOrigin( self:GetPos( ) )
		util.Effect( "Explosion", ED )
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