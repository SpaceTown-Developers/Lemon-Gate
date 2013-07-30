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

local MaxPerf = CreateConVar( "lemongate_perf", "25000" )
local CaveJohnson = CreateConVar( "combustible_lemon", "0" )

/*==============================================================================================
	Includes
==============================================================================================*/
include( "shared.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )

/*==============================================================================================
	Context
==============================================================================================*/
local Context = { }
Context.__index = Context

function Context:Throw( Trace, Type, Message, Table )
	self.Exception = { Type = Type, Trace = Trace, Message = Message, Table = Table }
	error( "Exception", 0 )
end

function Context:Error( Trace, Message )
	self.ScriptError = Message
	self.ScriptTrace = Trace
	error( "Script", 0 )
end

function Context:PushPerf( Trace, Ammount )
	self.Perf = self.Perf + Ammount
	if self.Perf > self.MaxPerf then
		self:Error( Trace, "Maximum operations count exceeded." )
	end
end

/*==============================================================================================
	WireLinks
==============================================================================================*/
function Context:FromWL( Entity, Type, Name, Default )
	if IsValid( Entity ) and Entity.Outputs then
		local Output = Entity.Outputs[Name]
		if Output and Output.Type == Type then
			return Output.Value or Default
		end
	end; return Default
end

function Context:ToWL( Entity, Type, Name, Value)
	if IsValid( Entity ) and Entity.Inputs then
		local Input = Entity.Inputs[ Name ]
		if Input and Input.Type == Type then
			local Que = self.WLQueue[ Entity ]
			
			if !Que then
				Que = { }
				self.WLQueue[ Entity ] = Que
			end
			
			Que[Name] = Value
		end
	end
end

function Context:FlushWLQue( )
	for Entity, Que in pairs( self.WLQueue ) do
		if IsValid( Entity ) then
			for Key, Value in pairs( Que ) do
				WireLib.TriggerInput( Entity, Key, Value )
			end 
		end
	end; self.WLQueue = { }
end

/*==============================================================================================
	Script Handeling
==============================================================================================*/
function Lemon:BuildContext( )
	self.Context = setmetatable( { 
		Perf = 0, MaxPerf = MaxPerf:GetInt( ),
		Entity = self, Player = self.Player,
		Memory = { }, Delta = { }, Click = { },
		Data = { }, WLQueue = { },
	}, Context )
	
	LEMON.API:CallHook( "BuildContext", self )
	
	return self.Context
end

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
	
	Entity:Pcall( Instance.Execute, Entity.Context )
end

function Lemon:LoadScript( Script, Files )
	local Context = self:BuildContext( )
	
	if self:IsRunning( ) then
		self:ShutDown( )
	end
	
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

function Lemon:Update( )
	self:API( ):CallHook( "UpdateExecution", self )
	self:TriggerOutputs( )
	self:GarbageCollect( )
	self.Context.Click = { }
	self.Context:FlushWLQue( )
end

/*==============================================================================================
	Init
==============================================================================================*/
function Lemon:Initialize( )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self.Inputs = WireLib.CreateInputs( self, { } )
	self.Outputs = WireLib.CreateOutputs( self, { } )
	
	self.Overlay = "Offline"
	self.GateName = "LemonGate"
	self:UpdateOverLay( "Offline" )
	
	self:API( ):CallHook("Create", self )
end

function Lemon:Think( )
	local Time = CurTime( )
	
	if self:IsRunning( ) then
		local Context = self.Context
		
		if !Context.PerfTime or Context.PerfTime > Time then
			Context.PerfTime = Time + 1
			
			local Used = Context.Perf
			
			Context.LastPerf = Used
			Context.MaxPerf = MaxPerf:GetInt( )
			Context.Perf = 0
			
			local Per = math.ceil( ( Used / Context.MaxPerf ) * 100 )
			
			self:UpdateOverLay( "Online\n%d ops (%d%%)", Used, Per )
		end
		
		self:API( ):CallHook("GateThink", self )
	end
	
	self.BaseClass.Think( self )
	self:NextThink( Time + 0.01 )
	
	return true
end

function Lemon:OnRemove( ) 
	self:ShutDown( )
	
	self:CallEvent( "final" )
	self:API( ):CallHook("Remove", self )
	
	if CaveJohnson:GetBool( ) then
		local ED = EffectData( )
		ED:SetOrigin( self:GetPos( ) )
		util.Effect( "Explosion", ED )
	end
end

/*==============================================================================================
	Section: Stuff.
==============================================================================================*/
function Lemon:API( )
	return LEMON.API
end

function Lemon:SetGateName( Name )
	self.GateName = Name or "LemonGate"
	self:UpdateOverLay( self.Overlay )
end

function Lemon:UpdateOverLay( Status, A, ... )
	if A then Status = string.format( Status, A, ... ) end
	
	self.Overlay = Status
	self:SetOverlayText( Format( "%s\n%s", self.GateName, Status ) )
end

function Lemon:GetScript( )
	return self.Script or "", self.Files or { }
end

function Lemon:Reset( )
	if self.Script then
		self:LoadScript( self:GetScript( ) )
	end
end

function Lemon:Pcall( Func, ... )
	local Ok, Status, Value = pcall( Func, ... )
		
	if Ok or Status == "Exit" then
		self:Update( )
		return Ok, Status, Value
	elseif Status == "Script" then
		local Cont = self.Context
		return self:ScriptError( Cont.ScriptTrace, Cont.ScriptError )
	elseif Status == "Exception" then
		local Excpt = self.Context.Exception
		return self:ScriptError( Excpt.Trace, "uncatched exception '" .. Excpt.Type .. "' in main thread" )
	elseif Status == "Break" or Status == "Continue" then
		return self:ScriptError( nil, "unexpected use of " .. Status .. " in main thread." )
	else
		return self:LuaError( Status )
	end
end

function Lemon:IsRunning( )
	return self.Context ~= nil
end

function Lemon:ShutDown( )
	self:CallEvent( "final" )
	self:API( ):CallHook( "ShutDown", self, self.Context )
end

/*==============================================================================================
	Section: Events
==============================================================================================*/
function Lemon:CallEvent( Name, ... )
	if self:IsRunning( ) then
		local Event = self.Context["Event_" .. Name]
		
		if Event then
			local Ok, Status = pcall( Event, ... )
			
			if Ok and Status then
				self:Update( )
				return Status[1], self
			elseif Ok or Status == "Exit" then
				self:Update( )
			elseif Status == "Script" then
				local Cont = self.Context
				return self:ScriptError( Cont.ScriptTrace, Cont.ScriptError )
			elseif Status == "Exception" then
				local Excpt = self.Context.Exception
				return self:ScriptError( Excpt.Trace, "uncatched exception '" .. Excpt.Type .. "' in event " .. Name )
			elseif Status == "Break" or Status == "Continue" then
				return self:ScriptError( nil, "unexpected use of " .. Status .. " in event " .. Name )
			else
				return self:LuaError( Status )
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
	self:UpdateOverLay( "Lua Error" )
	
	WireLib.ClientError( "LemonGate: Suffered a LUA error" , self.Player )
	WireLib.ClientError( "LUA: " .. Message , self.Player )
end

function Lemon:ScriptError( Trace, Message )
	self.Context = nil -- Shut Down!
	self:SetColor( BadColor )
	self:SetNWBool( "Crashed", true )
	self:UpdateOverLay( "Script Error" )
	
	if Trace then
		Message = string.format( "%s at Line %d Char %d", Message or "Uknown Error", Trace[1], Trace[2] )
	else
		Message = Message or "Untrackable Error"
	end
	
	WireLib.ClientError( Message, self.Player )
end

function Lemon:Error( Message )
	self.Context = nil -- Shut Down!
	self:SetColor( BadColor )
	self:SetNWBool( "Crashed", true )
	self:UpdateOverLay( Message )
	
	WireLib.ClientError( Message, self.Player )
end

/*==============================================================================================
	Section: Duplication
==============================================================================================*/
function LEMON:BuildDupeInfo( )
	local DupeTable = self.BaseClass.BuildDupeInfo( self )
	
	DupeTable.Script = self.Script
	DupeTable.Files = self.Files
	
	self:API( ):CallHook( "BuildDupeInfo", self, self.Context, DupeTable )
	
	return DupeTable
end

function LEMON:ApplyDupeInfo( Player, Entity, DupeTable, FromID )
	self.Player = Player
	self:LoadScript( DupeTable.Script or "", DupeTable.Files )
	
	self.BaseClass.ApplyDupeInfo( self, Player, Entity, DupeTable, FromID )
	
	self:CallEvent( "dupePasted" )
	
	self:API( ):CallHook( "ApplyDupeInfo", self, self.Context, DupeTable, FromID )
end
