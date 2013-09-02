/*==============================================================================================
	Expression Advanced: Server Side Gate Entity.
	Purpose: This is the entity that does everything!
	Creditors: Rusketh
==============================================================================================*/
if !WireLib or !LEMON then return end

local Lemon = ENT

Lemon.IsLemonGate = true 

/*==============================================================================================
	Speed Increases
==============================================================================================*/
local UpperStr = string.upper -- Speed
local FormatStr = string.format -- Speed
local MathCeil = math.ceil -- Speed

local CurTime = CurTime -- Speed
local pairs = pairs -- Speed
local pcall = pcall -- Speed

local GoodColor = Color( 255, 255, 255, 255 )
local BadColor = Color( 255, 0, 0, 0 )

local CaveJohnson = CreateConVar( "combustible_lemon", "0" )

/*==============================================================================================
	Includes
==============================================================================================*/
include( "shared.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

/*==============================================================================================
	Script Handeling
==============================================================================================*/

local function CompileSoftly( Entity, Script, Files )
	local Ok, Instance = LEMON.Compiler.Execute( Script, Files )
	
	if !Ok then
		Entity:Error( "Compiler Error" )
		WireLib.ClientError( Instance, Entity.Player )
	elseif !Instance.Execute then
		Entity:Error( "Reload Required" )
	else
		Entity:SetColor( GoodColor )
		Entity:SetNWBool( "Crashed", false )
		Entity:LoadInstance( Instance )
	end
	
	if Entity:Pcall( "main thread", Instance.Execute, Entity.Context ) then
		Entity:Update( )
	end
end

function Lemon:LoadScript( Script, Files )
	if self:IsRunning( ) then self:ShutDown( ) end
	
	local Context = LEMON:BuildContext( self )
	
	self.Script = Script
	self.Files = Files or { }
	
	coroutine.resume( coroutine.create( CompileSoftly ), self, Script, Files )
end

function Lemon:LoadInstance( Inst )
	local _Inputs = self.Inputs
	local _Outputs = self.OutPuts
	
	local INames, ITypes, I = { }, { }, 1
	for Variable, Ref in pairs( Inst.InPorts ) do
		local Cell = Inst.Cells[ Ref ]
		INames[ I ] = Variable
		ITypes[ I ] = Cell.Class.WireName
		I = I + 1
	end
	
	local ONames, OTypes, I = { }, { }, 1
	for Variable, Ref in pairs( Inst.OutPorts ) do
		local Cell = Inst.Cells[ Ref ]
		ONames[ I ] = Variable
		OTypes[ I ] = Cell.Class.WireName
		I = I + 1
	end
	
	self.Inputs  = WireLib.AdjustSpecialInputs( self, INames, ITypes )
	self.Outputs = WireLib.AdjustSpecialOutputs( self, ONames, OTypes )
	
	self.InPorts   = Inst.InPorts
	self.OutPorts  = Inst.OutPorts
	self.Cells     = Inst.Cells
	
	for Variable, Port in pairs( self.Inputs ) do
		local Ref = self.InPorts[ Variable ]
		
		if Ref then
			local Cell = self.Cells[ Ref ]
			if Cell and Port.Type == Cell.Class.WireName then
				Cell.Class.Wire_In( self.Context, Ref, Port.Value )
			end
		end
	end
end

function Lemon:GarbageCollect( )
	if self.Context then
		local Memory, Delta = self.Context.Memory, self.Context.Delta
		
		if Memory then
			for Ref, Cell in pairs( self.Cells ) do
				if Cell.NotGarbage then
					-- Do Nothing
				elseif Cell.Class.GarbageCollect then
					Cell.Class:GarbageCollect( self.Context, Ref )
				else
					Memory[Ref] = nil
					Delta[Ref] = nil
				end
			end
		end
	end
end -- Woot custom garbage collection =D

local Updates = { }

hook.Add( "Tick", "LemonGate.Update", function( )
	Updates = { } -- Only allow gates to update once per Tick!
end )

function Lemon:Update( )
	if !Updates[ self ] then
		Updates[ self ] = true
		self:TriggerOutputs( )
		self.Context:Update( )
		self:GarbageCollect( )
		self:API( ):CallHook( "UpdateEntity", self )
	end
end

/*==============================================================================================
	Init
==============================================================================================*/
function Lemon:Initialize( )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self:SetUseType( USE_TOGGLE  ) 
	
	self.Inputs = WireLib.CreateInputs( self, { } )
	self.Outputs = WireLib.CreateOutputs( self, { } )
	
	self.Overlay = "Offline"
	self.GateName = "LemonGate"
	
	self:API( ):CallHook("Create", self )
end

function Lemon:Think( )
	local Time = CurTime( )
	
	if self:IsRunning( ) then
		local Context = self.Context
		
		Context.CPUTime = Context.CPUTime * 0.95 + Context.Time * 0.05
		self:SetNWInt( "GateTime", Context.CPUTime * 1000000 )
		
		self:SetNWFloat( "GatePerf", Context.Perf )
		self:SetNWString( "GateName", self.GateName )
		
		Context.Time = 0
		Context.Perf = 0
	end
	
	self.BaseClass.Think( self )
	self:NextThink( Time )
	
	return true
end

function Lemon:OnRemove( ) 
	self:ShutDown( )
	self:API( ):CallHook("Remove", self )
	
	if CaveJohnson:GetBool( ) then
		local ED = EffectData( )
		ED:SetOrigin( self:GetPos( ) )
		util.Effect( "Explosion", ED )
	end
end

function Lemon:Use( Activator, Caller )
	self:CallEvent( "use", Activator or Caller )
end

/*==============================================================================================
	Section: Stuff.
==============================================================================================*/
local pcall, SysTime = pcall, SysTime

function Lemon:API( )
	return LEMON.API
end

function Lemon:SetGateName( Name )
	self.GateName = Name or "LemonGate"
end

function Lemon:GetScript( )
	return self.Script or "", self.Files or { }
end

function Lemon:Reset( )
	if self.Script then
		self:LoadScript( self:GetScript( ) )
	end
end

function Lemon:Pcall( Location, Func, ... )
	local Bench = SysTime( )
	local Context = self.Context
	local Ok, Status = pcall( Func, ... )
	
	Context.Time = Context.Time + (SysTime( ) - Bench)
	
	if Ok or Status == "Exit" then
		return Ok, Status
	end
	
	if Status == "Script" then
		self:ScriptError( Context.ScriptTrace, Context.ScriptError )
	elseif Status == "Exception" then
		local Excption = Context.Exception
		self:ScriptError( Excption.Trace, "uncatched exception '" .. Excption.Type .. "' in " .. Location .. "." )
	elseif Status == "Break" or Status == "Continue" then
		self:ScriptError( nil, "unexpected use of " .. Status .. " in " .. Location .. "." )
	else
		self:LuaError( Status )
	end
	
	return false, nil, nil
end

function Lemon:IsRunning( )
	return self.Context ~= nil
end

function Lemon:ShutDown( )
	self:CallEvent( "shutdown" )
	self:API( ):CallHook( "ShutDown", self, self.Context )
end

/*==============================================================================================
	Section: Events
==============================================================================================*/
function Lemon:CallEvent( Name, ... )
	if self:IsRunning( ) then
		local Event = self.Context["Event_" .. Name]
		
		if Event then
			local Ok, Status, Value = self:Pcall( "event " .. Name, Event, ... )
			
			if Ok then
				self:Update( )
				
				if Status then 
					return Status[1], self
				end
			end
		end
	end
end

/*==============================================================================================
	Section: Wire Mod Stuff
==============================================================================================*/
function Lemon:TriggerInput( Key, Value )
	if self:IsRunning( ) then
		local Ref = self.InPorts[ Key ]
		local Cell = self.Cells[ Ref ]
		
		if Cell then
			Cell.Class.Wire_In( self.Context, Ref, Value )
			self.Context.Click[ Ref ] = true
			
			self:CallEvent( "trigger", Key )
			
			self.Context.Click[ Ref ] = false
		end
	end
end

function Lemon:TriggerOutputs( )
	if self:IsRunning( ) then
		local Context = self.Context
		
		for Name, Ref in pairs( self.OutPorts ) do
			if Context.Click[ Ref ] then
				local Value = self.Cells[ Ref ].Class.Wire_Out( Context, Ref )
				WireLib.TriggerOutput( self, Name, Value )
			end
		end
	end
end

/*==============================================================================================
	Section: Erroring!
==============================================================================================*/
function Lemon:LuaError( Message )
	self.Context = nil -- Shut Down!
	self:SetColor( BadColor )
	self:SetNWBool( "Crashed", true )
	
	WireLib.ClientError( "LemonGate: Suffered a LUA error" , self.Player )
	WireLib.ClientError( "LUA: " .. Message , self.Player )
end

function Lemon:ScriptError( Trace, Message )
	self.Context = nil -- Shut Down!
	self:SetColor( BadColor )
	self:SetNWBool( "Crashed", true )
	
	if Trace then
		Message = string.format( "%s at Line %s Char %s", Message or "Uknown Error", Trace[1], Trace[2] )
	else
		Message = Message or "Untrackable Error"
	end
	
	WireLib.ClientError( Message, self.Player )
end

function Lemon:Error( Message )
	self.Context = nil -- Shut Down!
	self:SetColor( BadColor )
	self:SetNWBool( "Crashed", true )
	
	WireLib.ClientError( Message, self.Player )
end

/*==============================================================================================
	Section: Duplication
==============================================================================================*/
function Lemon:BuildDupeInfo( )
	local DupeTable = self.BaseClass.BuildDupeInfo( self )
	
	local Script, Files = self:GetScript( )
	
	DupeTable.Script = Script
	DupeTable.Files = Files
	
	self:API( ):CallHook( "BuildDupeInfo", self, DupeTable )
	
	return DupeTable
end

function CompileDuped( self, Player, Entity, DupeTable, FromID )
	self.Player = Player
	self.Script = DupeTable.Script
	self.Files = DupeTable.Files or { }
	
	local Context = LEMON:BuildContext( self, Player )
	
	if self.Script and self.Script != "" then
		CompileSoftly( self, self.Script, self.Files )
	end
	
	self.BaseClass.ApplyDupeInfo( self, Player, Entity, DupeTable, FromID )
	
	if self:IsRunning( ) then
		self:CallEvent( "dupePasted" )
	end
	
	self:API( ):CallHook( "ApplyDupeInfo", self, DupeTable, FromID )
end

function Lemon:ApplyDupeInfo( Player, Entity, DupeTable, FromID )
	coroutine.resume( coroutine.create( CompileDuped ), self, Player, Entity, DupeTable, FromID )
end