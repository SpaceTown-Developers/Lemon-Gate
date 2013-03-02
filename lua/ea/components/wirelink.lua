/*==============================================================================================
	Expression Advanced: Wirelink.
	Purpose: Like wiring a thousands things at once.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API

/*==============================================================================================
	Class & WireMod
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterClass("wirelink", "wl", function() return Entity(-1) end)
E_A:RegisterOperator("assign", "wl", "", E_A.AssignOperator)
E_A:RegisterOperator("variable", "wl", "wl", E_A.VariableOperator)

local function Input(self, Memory, Value)
	self.Memory[Memory] = Value
end

local function Output(self, Memory)
	return self.Memory[Memory]
end

E_A:WireModClass("wirelink", "WIRELINK", Input)

/*==============================================================================================
	Section: Comparison Operators
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterOperator("negeq", "wlwl", "n", function(self, ValueA, ValueB)
	return (ValueA(self) == ValueB(self)) and 0 or 1
end)

E_A:RegisterOperator("eq", "wlwl", "n", function(self, ValueA, ValueB)
	return (ValueA(self) == ValueB(self)) and 1 or 0
end)

/*==============================================================================================
	Section: Conditional Operators
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterOperator("is", "wl", "n", function(self, Value)
	local Entity = Value(self)
	return (Entity and Entity:IsValid()) and 1 or 0
end)

/*==============================================================================================
	Numbers
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)
E_A:RegisterOperator("get", {"wirelink", "string", "number"} , "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return self:GetWL("NORMAL", A, B) or 0
end)

E_A:RegisterOperator("set", {"wirelink", "string", "number"}, "", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	self:SetWL("NORMAL", A, B, C)
end)

/*==============================================================================================
	String
==============================================================================================*/
E_A:RegisterOperator("get", {"wirelink", "string", "string"} , "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return self:GetWL("STRING", A, B) or ""
end)

E_A:RegisterOperator("set", {"wirelink", "string", "string"}, "", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	self:SetWL("STRING", A, B, C)
end)

/*==============================================================================================
	Entities
==============================================================================================*/
E_A:RegisterOperator("get", {"wirelink", "string", "entity"} , "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return self:GetWL("ENTITY", A, B) or Entity(-1)
end)

E_A:RegisterOperator("set", {"wirelink", "string", "entity"}, "", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	self:SetWL("ENTITY", A, B, C)
end)

/*==============================================================================================
	Entities
==============================================================================================*/
E_A:RegisterOperator("get", {"wirelink", "string", "vector"} , "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	local C = self:GetWL("VECTOR", A, B) or Vector(0, 0, 0)
	return {C.x, C.y, C.z}
end)

E_A:RegisterOperator("set", {"wirelink", "string", "vector"}, "", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	self:SetWL("VECTOR", A, B, Vector(C[1], C[2], C[3]))
end)

/*==============================================================================================
	WL Functions
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("entity", "wl:", "e", function(self, ValueA)
	local A = ValueA(self)
	return A
end)

E_A:RegisterFunction("hasInput", "wl:s", "n", function(self, ValueA, ValueB)
	local Entity, B = ValueA(self), ValueB(self)
	if !Entity or !Entity:IsValid() or !Entity.Inputs then return 0 end
	if !Entity.Inputs[B] then return 0 else return 1 end
end)

E_A:RegisterFunction("hasOutput", "wl:s", "n", function(self, ValueA, ValueB)
	local Entity, B = ValueA(self), ValueB(self)
	if !Entity or !Entity:IsValid() or !Entity.Outputs then return 0 end
	if !Entity.Outputs[B] then return 0 else return 1 end
end)

E_A:RegisterFunction("inputType", "wl:s", "s", function(self, ValueA, ValueB)
	local Entity, B = ValueA(self), ValueB(self)
	if !Entity or !Entity:IsValid() or !Entity.Inputs then return "" end
	
	local Input = Entity.Inputs[B]
	if !Input then return "" end
	return string.lower(Input.Type or "")
end)

E_A:RegisterFunction("outputType", "wl:s", "s", function(self, ValueA, ValueB)
	local Entity, B = ValueA(self), ValueB(self)
	if !Entity or !Entity:IsValid() or !Entity.Outputs then return "" end
	
	local Outputs = Entity.Outputs[B]
	if !Output then return "" end
	return string.lower(Outputs.Type or "")
end)

E_A:RegisterFunction("isHiSpeed", "wl:", "n", function(self, ValueA)
	local Entity, B = ValueA(self), ValueB(self)
	if !Entity or !Entity:IsValid() then return 0 end
	
	if Entity.WriteCell or Entity.ReadCell then return 1 else return 0 end
end)



/*==============================================================================================
	Cell Writing
==============================================================================================*/
E_A:SetCost(EA_COST_EXPENSIVE)

E_A:RegisterFunction("writeCell", "wl:nn", "n", function(self, ValueA, ValueB, ValueC)
	local Entity, B, C = ValueA(self), ValueB(self), ValueC(self)
	if !Entity or !Entity:IsValid() or !Entity.WriteCell then return 0 end
	
	if Entity:WriteCell(B, C) then return 1 else return 0 end
end)

E_A:RegisterFunction("readCell", "wl:n", "n", function(self, ValueA, ValueB)
	local Entity, B = ValueA(self), ValueB(self)
	if !Entity or !Entity:IsValid() or !Entity.ReadCell then return 0 end
	
	return Entity:ReadCell(B) or 0
end)

E_A:RegisterFunction("readArray", "wl:nn", "t", function(self, ValueA, ValueB, ValueC)
	local Entity, B, C = ValueA(self), ValueB(self), ValueC(self)
	if !Entity or !Entity:IsValid() or !Entity.ReadCell then return 0 end
	
	self:PushPerf(EA_COST_CHEAP * C)
	
	local Table = E_A.NewTable( )
	
	for I = B, B + C do
		Table:Insert( nil, "n", Entity:ReadCell(B) or 0 )
	end
	
	return Table
end)

/*==============================================================================================
	Indexing
==============================================================================================*/

-- NUMBER
E_A:RegisterOperator("set", "wlnn", "", function(self, ValueA, ValueB, ValueC)
	local Entity, B, C = ValueA(self), ValueB(self), ValueC(self)
	if !Entity or !Entity:IsValid() or !Entity.WriteCell then return 0 end
	
	Entity:WriteCell(B, C)
end)

E_A:RegisterOperator("get", "wlnn", "n", function(self, ValueA, ValueB)
	local Entity, B = ValueA(self), ValueB(self)
	if !Entity or !Entity:IsValid() or !Entity.ReadCell then return 0 end
	
	return Entity:ReadCell(B) or 0
end)

E_A:RegisterOperator("get", "wln", "n", function(self, ValueA, ValueB)
	local Entity, B = ValueA(self), ValueB(self)
	if !Entity or !Entity:IsValid() or !Entity.ReadCell then return 0 end
	
	return Entity:ReadCell(B) or 0
end)

-- VECTOR
E_A:RegisterOperator("set", "wlnv", "", function(self, ValueA, ValueB, ValueC)
	local Entity, B, C = ValueA(self), ValueB(self), ValueC(self)
	if !Entity or !Entity:IsValid() or !Entity.WriteCell then return 0 end
	
	Entity:WriteCell(B, C[1])
	Entity:WriteCell(B + 1, C[2])
	Entity:WriteCell(B + 2, C[3])
end)

E_A:RegisterOperator("get", "wlnv", "v", function(self, ValueA, ValueB)
	local Entity, B = ValueA(self), ValueB(self)
	if !Entity or !Entity:IsValid() or !Entity.ReadCell then return 0 end
	
	return {
		Entity:ReadCell(B) or 0,
		Entity:ReadCell(B + 1) or 0,
		Entity:ReadCell(B + 2) or 0
	}
end)

-- STRING
E_A:RegisterOperator("set", "wlns", "", function(self, ValueA, ValueB, ValueC)
	local Entity, B, C = ValueA(self), ValueB(self), ValueC(self)
	if !Entity or !Entity:IsValid() or !Entity.WriteCell then return 0 end
	
	if not Entity:WriteCell(B + #C, 0) then return 0 end

	for I = 1, #C do
		local Byte = string.byte(C, I)
		if not Entity:WriteCell(B + I - 1, Byte) then return 0 end
	end
end)

local Floor = math.floor
local Char = string.char

E_A:RegisterOperator("get", "wlns", "s", function(self, ValueA, ValueB)
	local Entity, B = ValueA(self), ValueB(self)
	if !Entity or !Entity:IsValid() or !Entity.ReadCell then return 0 end
	
	local Buffer, Byte = ""
	
	for I = B, B + 16384 do
		Byte = Entity:ReadCell(I, Byte)
		if !Byte then
			return ""
		elseif Byte < 1 then
			break
		elseif byte >= 256 then
			Byte = 32
		end
		
		Buffer = Buffer .. Char( Floor( Byte ) )
	end
	
	return Buffer
end)

/*==============================================================================================
	Console Screens
==============================================================================================*/
local Clamp = math.Clamp
local ToByte = string.byte

local function ToColor( Col )
	local R = Clamp( Floor(Col[1] / 28), 0, 9 )
	local G = Clamp( Floor(Col[2] / 28), 0, 9 )
	local B = Clamp( Floor(Col[3] / 28), 0, 9 )
	return Floor(R) * 100 + Floor(G) * 10 + Floor(B)
end

-- Function from E2
local function WriteString(self, ValueA, ValueB, ValueC, ValueD, ValueE, ValueF, ValueG)
	local Entity, String, X, Y = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	local Col, tCol, BG, tBG, Flash = 999, "n", 0, "n", 0
	
	if !Entity or !Entity:IsValid() then return end
	
	if ValueE then
		Col, tCol = ValueE(self)
		if tCol ~= "n" then Col = ToColor( Col ) end
		
		if ValueF then
			BG, tBG = ValueF(self)
			if tBG ~= "n" then BG = ToColor( BG ) end
			
			if ValueG then
				Flash = ValueG(self)
			end
		end
	end
	
	Col = Clamp( Floor( Col ), 0, 999 )
	BG = Clamp( Floor( BG ), 0, 999 )
	Flash = Flash >= 1 and 1 or 0
	
	local Params = Flash * 1000000 + BG * 1000 + Col

	local Xorig = X
	
	for I = 1, #String do
	
		local Byte = ToByte(String, I)
		
		if Byte == 10 then
			Y = Y + 1
			X = Xorig -- shouldn't this be 0 as well? would be more consistent.
		else
			if X >= 30 then
				X = 0
				Y = Y + 1
			end
			
			local Address = 2 * (Y * 30 + (X))
			X = X + 1 
			
			if Address >= 1080 or Address < 0 then return end
			
			Entity:WriteCell(Address, Byte)
			Entity:WriteCell(Address + 1, Params)
		end
	end
end

E_A:SetCost(EA_COST_EXPENSIVE * 1.5)

E_A:RegisterFunction("writeString", "wl:snn", "", WriteString)

E_A:RegisterFunction("writeString", "wl:snnn", "", WriteString)
E_A:RegisterFunction("writeString", "wl:snnc", "", WriteString)

E_A:RegisterFunction("writeString", "wl:snnnn", "", WriteString)
E_A:RegisterFunction("writeString", "wl:snncc", "", WriteString)
E_A:RegisterFunction("writeString", "wl:snncn", "", WriteString)
E_A:RegisterFunction("writeString", "wl:snnnc", "", WriteString)

E_A:RegisterFunction("writeString", "wl:snnnnn", "", WriteString)
E_A:RegisterFunction("writeString", "wl:snnccn", "", WriteString)
E_A:RegisterFunction("writeString", "wl:snncnn", "", WriteString)
E_A:RegisterFunction("writeString", "wl:snnncn", "", WriteString)

/*==============================================================================================
	Context Stuffs
==============================================================================================*/
function E_A.Context:SetWL(Type, Entity, Name, Value)
	if !Entity or !Entity:IsValid() or !Entity.Inputs then return end
	
	local Input = Entity.Inputs[Name]
	if !Input or Input.Type ~= Type then return end
	
	local Que = self.WireLinkQue[Entity]
	if !Que then
		Que = {}
		self.WireLinkQue[Entity] = Que
	end
	
	Que[Name] = Value
end

function E_A.Context:GetWL(Type, Entity, Name)
	if !Entity or !Entity:IsValid() or !Entity.Outputs then return end
	
	local Output = Entity.Outputs[Name]
	if !Output or Output.Type ~= Type then return end
	return Output.Value
end

local Trigger = WireLib.TriggerInput

API.AddHook("TriggerOutputs", function(Gate)
	for Entity, Que in pairs( Gate.Context.WireLinkQue ) do
		for Key, Value in pairs( Que ) do
			WireLib.TriggerInput(Entity, Key, Value)
		end
	end
end)