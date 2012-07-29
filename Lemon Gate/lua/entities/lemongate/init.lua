/*==============================================================================================
	Expression Advanced: Server Side Gate Entity.
	Purpose: This is the entity that does everything!
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local ShortTypes = E_A.TypeShorts
local Operators = E_A.OperatorTable

local Tokenizer = E_A.Tokenizer
local Parser = E_A.Parser
local Compiler = E_A.Compiler

local CheckType = E_A.CheckType
local GetLongType = E_A.GetLongType
local GetShortType = E_A.GetShortType

local UpperStr = string.upper -- Speed
local FormatStr = string.format -- Speed

local CurTime = CurTime -- Speed
local pairs = pairs -- Speed
local pcall = pcall -- Speed

local Lemon = ENT

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
	
	self:SetModel("models/mandrac/wire/e3.mdl")
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	WireLib.CreateInputs(self, {})
	WireLib.CreateOutputs(self, {})
	
	self.Name = "LemonGate"
	self.Errored = nil
	self.LastPerf = 0
	
	self:SetOverlayText("LemonGate\nExpresson Advanced\nOffline: 0%")
end

function Lemon:Think()
	-- Purpose: Makes the entity think?
	
	local Time = CurTime()
	
	if !self.Errored then
		
		local Context, PerfTime = self.Context, self.PerfTime
		if Context then
			
			if !PerfTime or PerfTime > Time then
				PerfTime = Time + 1
				
				local Perf, MaxPerf = Context.Perf, MaxPerf:GetInt()
				if Perf == MaxPerf then
					self:UpdateOverlay("Paused")
					self.LastPerf = 0
				else
					Perf = (MaxPerf - Perf)
					self.LastPerf = Perf
					Context.Perf = MaxPerf
					
					self:UpdateOverlay("Online: %s%%", math.ceil((Perf / MaxPerf) * 100))
				end
			end
			
			self:CallEvent("Think")
		end
	end
	
	self.BaseClass.Think(self)
	
	self:NextThink(Time)
	return true
end

function Lemon:OnRemove()
	self:CallEvent("Final")
end

function Lemon:Use(Player)
	-- self:CallEvent("Use", "e", E_A:Class("e", Player))
end

/*==============================================================================================
	Expression Advanced: Code Compiler.
	Purpose: This is the entity that does everything!
	Creditors: Rusketh
==============================================================================================*/
function Lemon:LoadScript(Script)
	-- Purpose: Compile script into an executable.
	
	self.Script = Script
	
	local Check, Tokens = Tokenizer.Execute(Script)
	if !Check then
		self:UpdateOverlay("Tokenizer Error")
		return MsgN("E-A: Tokenizer Error, " .. Tokens)
	end
	
	local Check, Instructions = Parser.Execute(Tokens)
	if !Check then
		self:UpdateOverlay("Parser Error")
		return MsgN("E-A: Parser Error, " .. Instructions)
	end
	
	local Check, Executable, Instance = Compiler.Execute(Instructions)
	if !Check then
		self:UpdateOverlay("Tokenizer Error")
		return MsgN("E-A: PArser Error, " .. Executable)
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
		Entity = self, Events = self.Events,
		
		Perf = MaxPerf:GetInt(),
		Error = function(Context, Message, ...) return self:Error(Message, ...) end,
	}
	
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
			self:UpdateOverlay("Script Error")
			return MsgN(FormatStr("E-A: type '%s' may not be used as input", Type[1]))
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
			self:UpdateOverlay("Script Error")
			return MsgN(FormatStr("E-A: type '%s' may not be used as output", Type[1]))
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
function Lemon:ReStart()
	self:RefreshMemory()
	return self:Execute()
end

function Lemon:Execute()
	local Exe = self.Executable -- Note: This is E-A's root.
	
	if Exe then
		self:SetColor(255, 255, 255, 255)
		
		self:UpdateOverlay("Online: 0%%")
		
		local Ok, Result, Type = self:RunOp(Exe)
		
		self:TriggerOutputs()
		
		return Ok, Result, Type
	end
end

function Lemon:RunOp(Op, ...)
	if self.Errored then return true end -- Note: Code has errored so do not run.
	
	local Context = self.Context
	if !Context then return true end
	
	local Ok, Return, Type = Op:Pcall(Context, ...)
	
	if Ok then
		return true, Return, Type
	
	elseif Return == "spt" then
		self:SetColor(255, 0, 0, 255)
		self:UpdateOverlay("Script Error")
		
		MsgN("E-A: Script Error, " .. Type)
		
	elseif Return == "int" then
		self:SetColor(255, 0, 0, 255)
		self:UpdateOverlay("Lua Error")
		
		MsgN("E-A: Lua Error, " .. Type)
		
	elseif Return == "exit" then
		return true -- This is normal.
	
	elseif Return[4] == ":" then
		-- Note: Should never happen
		
		self:UpdateOverlay("Script Error")
		MsgN("E-A: Strange Error, RunOp got '" .. Return .. "' exception.")
	
	else
		self:UpdateOverlay("Lua Error")
		MsgN("E-A: Strange Error:")
		MsgN(Return)
	end
	
	self.Errored = true
	return false, Result, Type
end

function Lemon:CallEvent(Name, Perams, ...)
	if self.Errored then return true end
	
	local EventTable = self.Events
	if !EventTable then return true end
	
	local Events = EventTable[Name]
	if !Events then return true end
	
	local Op = Operators["call(f)"][1]
	
	for Index, CallBack in pairs(Events) do
	local Ok, Result, Result2 = self:RunOp(Op, CallBack, Perams or "", ...)
	if !Sucess then return false, Result, Result2 end
	end
	
	self:TriggerOutputs()
	
	return true
end

/*==============================================================================================
	Section: Name and Overlay.
	Purpose: Mainly Overlay and name stuff!
	Creditors: Rusketh
==============================================================================================*/
function Lemon:SetName(Name)
	self.Name = Name or "LemonGate"
end

function Lemon:UpdateOverlay(Status, Info, ...)
	if Info then Status = FormatStr(Status, Info, ...) end
	
	self:SetOverlayText(FormatStr("%s\nExpression Advanced\n%s", self.Name, Status ))
end

/*==============================================================================================
	Section: Execute.
	Purpose: Executes the gate =D.
	Creditors: Rusketh
==============================================================================================*/
function Lemon:Error(Message, Info, ...)
	-- Purpose: Create and push an error.
	
	if Info then Message = FormatStr(Message, Info, ...) end
	
	self.Errored = Message
	
	self:UpdateOverlay("Script Error")
	
	MsgN("E-A: Script Error, " .. Message)
end