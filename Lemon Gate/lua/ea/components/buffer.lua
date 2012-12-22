/*==============================================================================================
	Expression Advanced: Strings.
	Purpose: Strings and such.
	Note: Mostly just a conversion of E2's String Ext!
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API

API.NewComponent("buffer", true)

E_A:RegisterClass("buffer", "b", { T = { }, D = { }, R = 0, W = 0, L = false })

E_A:RegisterException("buffer")

/*==============================================================================================
	Section: Variable operators
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterOperator("assign", "b", "", function(self, Value, Memory)
	-- Purpose: Assigns a string to memory
	
	self.Memory[Memory] = Value(self)
end)

E_A:RegisterOperator("variable", "b", "b", function(self, Memory)
	-- Purpose: Assigns a string to memory
	
	return self.Memory[Memory]
end)

/*==============================================================================================
	Section: String Operators
==============================================================================================*/
E_A:RegisterOperator("length", "b", "n", function(self, Value)
	-- Purpose: Gets the length of a string
	
	return Value(self).W
end)

/*==============================================================================================
	Section: Functions
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("buffer", "", "b", function(self)
	return { T = { }, D = { }, R = 0, W = 0 }
end)

E_A:RegisterFunction("getType", "", "b", function(self, Value)
	local Buff = Value(self)
	
	local Pos = Buff.R + 1
	if Pos > Buff.W then
		return "void"
	else
		return E_A.GetLongType(Buff.T[Pos])
	end
end)

/*==============================================================================================
	Section: Read / Write
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

local Types = { "n", "s", "v", "a", "e" }

E_A.API.AddHook("BuildFunctions", function()
	
	local GetLongType = E_A.GetLongType
	
	for _, Short in pairs( Types ) do
		
		local Long = GetLongType(Short)
		Long = Long[1]:upper() .. Long:sub(2)
		
		E_A:RegisterFunction("write" .. Long, "b:" .. Short, "", function(self, ValueA, ValueB)
			local Buff = ValueA(self)
			
			local Pos = Buff.W + 1
			if Pos >= 512 then
				self:Throw("buffer", "maximum buffer size reached")
			end
			
			Buff.T[Pos] = Short
			Buff.D[Pos] = ValueB(self)
			Buff.W = Pos
		end)
		
		E_A:RegisterFunction("read" .. Long, "b:", Short, function(self, Value)
			local Buff = Value(self)
			
			local Pos = Buff.R + 1
			if Pos > Buff.W then
				self:Throw("buffer", "reached end of buffer")
			elseif Buff.T[Pos] ~= Short then
				self:Throw("buffer", "tried to read " .. GetLongType(Short) .. " from " .. GetLongType(Buff.T[Pos]) )
			end
			
			Buff.R = Pos
			return Buff.D[Pos]
		end)
	end
end)

/*==============================================================================================
	Section: Data Stream
==============================================================================================*/
API.NewComponent("datastream", true)

local Copy = table.Copy
local DataQue = {}

API.AddHook("GateCreate", function(Entity)
	DataQue[Entity] = { }
end)

API.AddHook("BuildContext", function(Entity)
	DataQue[Entity] = {}
end)

API.AddHook("GateRemove", function(Entity)
	DataQue[Entity] = { }
end)

API.AddHook("TriggerOutputs", function(Gate)
	local Que = DataQue[Gate]
	
	if Que then
		
		for I = 1, #Que do
			local Data = Que[I]
			local Target = Data.Target
			
			if Target and Target:IsValid() and Target.IsLemonGate then
				Target:CallEvent("receiveBuffer", Data.Name, Data.Caller, Data.Buffer)
			end
		end
		
		DataQue[Gate] = { }
	end
end)

function QueDataStream(Gate, Target, Name, Buffer)
	
	if Target and Target:IsValid() and Target.IsLemonGate and Gate != Target then
		
		local Buff = { R = 0, W = Buffer.W, T = Copy( Buffer.T ), D = Copy( Buffer.D ) }
		
		local Que = DataQue[Gate]
		
		Que[#Que + 1] = {
			Target = Target,
			Name = function() return Name, "s" end,
			Caller = function() return Gate, "e" end,
			Buffer = function() return Buff, "b" end
		} -- Que the stream!
		
	end
end

/******************************************************************************/

E_A:SetCost(EA_COST_EXPENSIVE)

E_A:RegisterEvent("receiveBuffer", "seb")

E_A:RegisterFunction("send", "b:se", "", function(self, ValueA, ValueB, ValueC)
	local Buff, String, Entity = ValueA(self), ValueB(self), ValueC(self)
	
	self:PushPerf( Buff.W * EA_COST_CHEAP )
	
	QueDataStream(self.Entity, Entity, String, Buff)
end)
