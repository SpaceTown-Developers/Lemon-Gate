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
	Section: Entity
==============================================================================================*/
function Lemon:Initialize()
	-- Purpose: Initializes the Gate with physics.
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
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
	
	self:NextThink(Time + 0.01)
	return true
end

function Lemon:OnRemove()
	self:CallEvent("final")
	API.RemoveGate(self) -- Update the api.
end

/*==============================================================================================
	Section: Code Compiler
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
	
	self.Context = {
		Types = Instance.VarTypes,
		Memory = {}, Delta = {}, Click = {},
		Entity = self, Player = self.Player,
		Events = {}, VariantTypes = {},
		Perf = MaxPerf:GetInt(),
	}
	
	setmetatable(self.Context, E_A.Context)
	
	self.InMemory = Instance.Inputs
	self.OutMemory = Instance.Outputs
	
	self:RefreshMemory()
end

/*==============================================================================================
	Section: Memory Handelers.
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
	Section: Wire Mod Stuff
==============================================================================================*/
function Lemon:TriggerInput(Key, Value)
	-- Purpose: Transfers an input to memory.
	
	local Context = self.Context
	
	if self.Errored or !Context then return end
	
	local Cell = self.PortLookUp[Key]
	
	if Cell then
	
		ShortTypes[ Context.Types[Cell] ][5](Context, Cell, Value)
		
		Context.Click[Cell] = true
		
		self:CallEvent("trigger", E_A.ValueToOp(Key, "s"))
		
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
	Section: Executions.
==============================================================================================*/
function Lemon:Restart()
	self:RefreshMemory()
	self:Execute()
end

local SafeCall = E_A.SafeCall

function Lemon:Execute()
	local Exe, Context = self.Executable, self.Context
	
	if !Exe or !Context then return end
	
	self:SetColor(GoodColor)
	
	self:UpdateOverlay("Online: 0%%")
		
	local Ok, Exception, Message = SafeCall(Exe, Context)
		
	if Ok or Exception == "exit" then
		self:TriggerOutputs()
	elseif Exception == "script" then
		return self:ScriptError(Message)
	elseif Exception == "return" or Exception == "break" or Exception == "continue" then
		return self:ScriptError("unexpected use of " .. Exception .. " reaching main execution")
	elseif Context.Exception and Context.Exception == Exception then
		return self:ScriptError("unexpected exception '" .. Exception .. "' reached main execution")
	else
		return self:LuaError(Exception, Message)
	end
end

function Lemon:CallEvent(Name, ...)
	local Context = self.Context
	
	if self.Errored or !Context then return end
	
	local Event = Context.Events[ Name ]
	
	if Event then
		
		local Params, Values = Event[1], {...}
		
		for I = 1, #Params do -- Push the parameters
			Params[I](Context, Value[I])
		end
		
		local Ok, Exception, Message = SafeCall(Event[2], Context)
		
		if Ok or Exception == "exit" or Exception == "return" then
			self:TriggerOutputs()
		
			if Exception == "return" and Message then
				return Message(Context)
			end -- Return values!
		
		elseif Exception == "script" then
			return self:ScriptError(Message)
		elseif Exception == "break" or Exception == "continue" then
			return self:ScriptError("unexpected use of " .. Exception .. " inside event " .. Name)
		elseif Context.Exception and Context.Exception == Exception then
			return self:ScriptError("unexpected exception '" .. Exception .. "' inside event " .. Name)
		else
			return self:LuaError(Exception, Message)
		end
	end
end

/*==============================================================================================
	Section: Erroring!
==============================================================================================*/
function Lemon:LuaError(Message, Info, ...)
	-- Purpose: Create and push an error.
	
	if Info then
		Message = FormatStr(Message, Info, ...)
	end
	
	self.Errored = true
	
	self:SetColor(BadColor)
	
	self:UpdateOverlay("LUA Error")
	
	WireLib.ClientError("LemonGate: Suffered a LUA error" , self.Player)
	
	MsgN("LemonGate LUA: " .. Message)
	
	self.Player:PrintMessage(HUD_PRINTCONSOLE, "LemonGate LUA: " .. Message)
end

function Lemon:ScriptError(Message)
	local Trace = self.Context.Trace
		
	if Trace then
		Message = Message .. " at Line " .. Trace[1] .. " Char " .. Trace[2]
	end
	
	self.Errored = true
	
	self:SetColor(BadColor)
	
	self:UpdateOverlay("Script Error")
	
	WireLib.ClientError(Message, self.Player)
end

/*==============================================================================================
	Section: Name and Overlay.
==============================================================================================*/
function Lemon:SetGateName(Name)
	self.Name = Name or "LemonGate"
end

function Lemon:UpdateOverlay(Status, Info, ...)
	if Info then Status = FormatStr(Status, Info, ...) end
	
	self:SetOverlayText(FormatStr("%s\n%s", self.Name, Status ))
end

/*==============================================================================================
	Section: Performance points
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

/*==============================================================================================
	Section: Duplication
==============================================================================================*/
-- TODO?