/*==============================================================================================
	Expression Advanced: Server Side Gate Entity.
	Purpose: This is the entity that does everything!
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API

local Lemon = ENT

local ShortTypes = E_A.TypeShorts
local Operators = E_A.OperatorTable

local Tokenizer = E_A.Tokenizer
local Parser = E_A.Parser
local Compiler = E_A.Compiler

local CheckType = E_A.CheckType
local GetLongType = E_A.GetLongType
local GetShortType = E_A.GetShortType
local ValueToOp = E_A.ValueToOp

local UpperStr = string.upper -- Speed
local FormatStr = string.format -- Speed
local MathCeil = math.ceil -- Speed

local CurTime = CurTime -- Speed
local pairs = pairs -- Speed
local pcall = pcall -- Speed

local GoodColor = Color(255, 255, 255, 255)
local BadColor = Color(255, 0, 0, 0)

local MaxPerf = CreateConVar("lemongate_perf", "25000")

-- Other Files:
include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

/*==============================================================================================
	Expression Advanced: Gate Entity.
	Purpose: This is the entity that does everything!
	Creditors: Rusketh
==============================================================================================*/
function Lemon:Initialize()
	-- Purpose: Initializes the Gate with physics.
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	-- self:SetUseType( SIMPLE_USE ) -- Todo: use this
	
	WireLib.CreateInputs(self, {})
	WireLib.CreateOutputs(self, {})
	
	self.Name = "LemonGate"
	self.Errored = nil
	self.LastPerf = 0
	
	self:SetOverlayText("LemonGate\nExpresson Advanced\nOffline: 0%")
	
	API.AddGate(self) -- Let the api know this gate exists!
end

function Lemon:Think()
	-- Purpose: Makes the entity think?
	
	local Time = CurTime()
	
	if !self.Errored then
		local PerfTime = self.PerfTime
		if self.Context and (!PerfTime or PerfTime > Time) then
			self.PerfTime = Time + 1
			local _, _, Percent = self:CaculatePerf()
			self:UpdateOverlay("Online: %i%%", Percent)
		end
		
		self:CallEvent("think")
	end
	
	self.BaseClass.Think(self)
	
	self:NextThink(Time + 0.2)
	return true
end

function Lemon:OnRemove()
	self:CallEvent("final")
	API.RemoveGate(self) -- Update the api.
end

/*==============================================================================================
	Expression Advanced: Code Compiler.
	Purpose: This is the entity that does everything!
	Creditors: Rusketh
==============================================================================================*/
function Lemon:GetScript()
	return self.Script or ""
end

function Lemon:LoadScript(Script)
	-- Purpose: Compile script into an executable.
	
	self.Script = Script
	
	local Check, Tokens = Tokenizer.Execute(Script)
	if !Check then
		self:UpdateOverlay("Failed to compile.")
		return WireLib.ClientError(Tokens, self.Player)
	end
	
	local Check, Instructions = Parser.Execute(Tokens)
	if !Check then
		self:UpdateOverlay("Failed to compile.")
		return WireLib.ClientError(Instructions, self.Player)
	end
	
	local Check, Executable, Instance = Compiler.Execute(Instructions)
	if !Check then
		self:UpdateOverlay("Failed to compile.")
		return WireLib.ClientError(Executable, self.Player)
	end
	
	self:LoadInstance(Instance)
	
	self.Executable = Executable
end

function Lemon:LoadInstance(Instance)
	-- Purpose: Takes the important things from the instance.
	
	self.Events = {}
	self.Context = {
		Types = Instance.VarTypes,
		Memory = {}, Delta = {}, Click = {},
		Entity = self, Player = self.Player,
		Events = self.Events,
		Perf = MaxPerf:GetInt(),
	}
	
	setmetatable(self.Context, E_A.Context)
	
	self.InMemory = Instance.Inputs
	self.OutMemory = Instance.Outputs
	
	self:RefreshMemory()
end

/*==============================================================================================
	Section: Memory Handelers.
	Purpose: This is where we handel memory
	Creditors: Rusketh
==============================================================================================*/
function Lemon:RefreshMemory()
	-- Purpose: Clears and recreates the memory of the entire chip.
	
	local Context, PortLookUp = self.Context, {}
	local Memory, Delta, Types = Context.Memory, Context.Delta, Context.Types
	
	local InPuts, InTypes, I = {}, {}, 1 -- Header: Make the Inputs!
	for Cell, Name in pairs( self.InMemory ) do
		PortLookUp[Name] = Cell
		
		local Type = ShortTypes[Types[Cell]]
		local WireName = Type[4] -- Note: Get the wiremod name.
		
		if !WireName or !Type[5] then
			self:SetColor(BadColor)
			self:UpdateOverlay("Script Error")
			WireLib.ClientError("Type '" .. Type[1] .. "' may not be used as input.", self.Player)
			return
		end
		
		I = I + 1
		InPuts[I] = Name
		InTypes[I] = WireName
		
		Memory[Cell] = Type[3](Context)
	end
	
	WireLib.CreateInputs(self, InPuts, InTypes)
	
	local Outputs, OutTypes, I = {}, {}, 1 -- Header: Make the Outputs!
	for Cell, Name in pairs( self.OutMemory ) do
		PortLookUp[Name] = Cell
		
		local Type = ShortTypes[Types[Cell]]
		local WireName = Type[4] -- Note: Get the wiremod name.
		
		if !WireName or !Type[6] then
			self:SetColor(BadColor)
			self:UpdateOverlay("Script Error")
			WireLib.ClientError("Type '" .. Type[1] .. "' may not be used as output.", self.Player)
			return
		end
		
		I = I + 1
		Outputs[I] = Name
		OutTypes[I] = WireName
		
		Memory[Cell] = Type[3](Context)
	end
	
	WireLib.CreateOutputs(self, Outputs, OutTypes)
	self.PortLookUp = PortLookUp
	
	self.Name = "LemonGate"
	self.Errored = nil
	self.LastPerf = 0
end

/*==============================================================================================
	Section: Wire Mod Stuff.
	Purpose: Outputs and Inputs are handeled here.
	Creditors: Rusketh
==============================================================================================*/
function Lemon:TriggerInput(Key, Value)
	-- Purpose: Transfers an input to memory.
	
	local Cell = self.PortLookUp[Key]
	if Cell then
		local Context = self.Context
		
		ShortTypes[ self.Types[Cell] ][5](Context, Cell, Value)
		
		Context.Click[Cell] = true
		
		self:CallEvent("Trigger")
		
		Context.Click[Cell] = false
	end
end

function Lemon:TriggerOutputs()
	-- Purpose: Update all outputs from memory.
	
	local Context = self.Context
	-- if !Context then return end
	
	local Memory, Types, Click = Context.Memory, Context.Types, Context.Click
	
	for Cell, Name in pairs( self.OutMemory ) do
		if Click[Cell] then
			
			local Value = ShortTypes[Types[Cell]][6](Context, Cell)
			
			WireLib.TriggerOutput(self, Name, Value)
			
			Click[Cell] = false
		end
	end
end

/*==============================================================================================
	Section: Execute.
	Purpose: Executes the gate =D.
	Creditors: Rusketh
==============================================================================================*/
function Lemon:Restart()
	self:RefreshMemory()
	return self:Execute()
end

function Lemon:Execute()
	local Exe = self.Executable -- Note: This is E-A's root.
	
	if Exe then
		self:SetColor(GoodColor)
		
		self:UpdateOverlay("Online: 0%%")
		
		local Ok, Result, Type = self:RunOp(Exe)
		
		self:TriggerOutputs()
		
		return Ok, Result, Type
	end
end

local SafeCall = E_A.SafeCall

function Lemon:RunOp(Op, ...)
	if self.Errored then return true end -- Note: Code has errored so do not run.
	
	local Context = self.Context
	if !Context then return true end
	
	local Ok, Exception, Message = SafeCall(Op, Context, ...)
	
	if Ok or Exception == "exit" then
		return true, Exception, Message
	end
	
	if Exception == "script" then
		local Trace = Context.Trace
		if Trace then Message = Message .. " at Line " .. Trace[1] .. " Char " .. Trace[2] end
		
		self:SetColor(BadColor)
		self:UpdateOverlay("Script Error")
		WireLib.ClientError(Message, self.Player)
	
	else -- Lua Error!
		self:Error(Exception)
		return
	end
	
	self.Errored = Message or true
	return false, Exception, Message
end

function Lemon:CallEvent(Name, ...)
	if self.Errored or !self.Events then return true end
	
	local Event = self.Events[ Name ]
	if !Event then return true end
	
	local Ops, Values = Event[1], {...}
	for I = 1, #Ops do
		local Store, Value = Ops[I], Values[I]
		local Index, Op = Store[1], Store[2]
		
		self:RunOp(Op, Value, Index)
	end
	
	self:RunOp(Event[2])
	
	self:TriggerOutputs()
	
	return true
end

function Lemon:Error(Message, Info, ...)
	-- Purpose: Create and push an error.
	
	if Info then Message = FormatStr(Message, Info, ...) end
	
	self.Errored = Message
	
	self:SetColor(BadColor)
	self:UpdateOverlay("LUA Error")
	WireLib.ClientError("LemonGate: Suffered a LUA error" , self.Player)
	
	MsgN("LemonGate LUA: " .. Message)
	self.Player:PrintMessage(HUD_PRINTCONSOLE, "LemonGate LUA: " .. Message)
end

/*==============================================================================================
	Section: Name and Overlay.
	Purpose: Mainly Overlay and name stuff!
	Creditors: Rusketh
==============================================================================================*/
function Lemon:SetGateName(Name)
	self.Name = Name or "LemonGate"
end

function Lemon:UpdateOverlay(Status, Info, ...)
	if Info then Status = FormatStr(Status, Info, ...) end
	
	self:SetOverlayText(FormatStr("%s\nExpression Advanced\n%s", self.Name, Status ))
end

/*==============================================================================================
	Section: Perf stuffs.
	Purpose: Performance busting madnes.
	Creditors: Rusketh
==============================================================================================*/
function Lemon:CaculatePerf(NoUpdate)
	local Context = self.Context
	if Context then
		local Perf, MaxPerf, Percent = Context.Perf, MaxPerf:GetInt(), 0
		Perf = (MaxPerf - Perf)
		
		if !NoUpdate then 
			Context.Perf = MaxPerf
			self.LastPerf = Perf
		end
			
		if Perf ~= MaxPerf then
			Percent = MathCeil((Perf / MaxPerf) * 100)
		end
		
		return Perf, MaxPerf, Percent
	end
	
	return 0, 0, 0
end