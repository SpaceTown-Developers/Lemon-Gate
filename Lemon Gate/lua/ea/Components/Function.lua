/*==============================================================================================
	Expression Advanced: Lambada Functions.
	Purpose: First Class Functions!.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local CallOp = E_A.CallOp

local unpack = unpack -- Speed
local error = error -- Speed


E_A.API.NewComponent("Lambda", true)

/*==============================================================================================
	Section: Variants
==============================================================================================*/
E_A:RegisterClass("variant", "?")

E_A:RegisterOperator("assign", "?", "", function(self, ValueOp, Memory)
	local Val, Type = ValueOp(self)
	
	self.Memory[Memory] = Val
	
	self.VariantTypes[Memory] = Type
	
	self.Click[Memory] = true
end)

E_A:RegisterOperator("variabel", "?", "?", function(self, Memory)
	return self.Memory[Memory], self.VariantTypes[Memory]
end)

E_A.API.AddHook("BuildFunctions", function()
	for Type, tTable in pairs(E_A.TypeShorts) do
		
			E_A:RegisterOperator("cast", Type .. "?", Type, function(self, Value)
				local Val, Typ = Value(self)
				
				if Type != Typ then
					self:Throw("variant", "Tryed to cast a variant of " .. Typ .. " to a " .. Type)
				end
				
				return Val
			end)
			
			E_A:RegisterFunction("type", Type, "s", function(self, Value)
				local Val, tVal = Value(self)
				
				Value[1] = function() return Val, tVal end
				
				return E_A.GetLongType(tVal) -- This should work =D
			end)
	end
end)

/*==============================================================================================
	Section: Lambada Functions!
==============================================================================================*/
E_A:RegisterClass("function", "f")

E_A:RegisterOperator("funcvar", "f", "f", function(self, Memory)
	-- Purpose: Returns a function.
	
	return self.Memory[Memory]
end)

E_A:RegisterOperator("funcass", "f", "", function(self, Value, Memory)
	-- Purpose: Stores a function.
	
	self.Memory[Memory] = Value(self)
end)

E_A:RegisterOperator("lambada", "", "f", function(self, Sig, Perams, Statments, Return)
	-- Purpose: Creates a lambada function.
	
	return {Sig, Perams, Statments, Return}
end)


E_A:RegisterOperator("call", "f", "?", function(self, Value, pSig, Values)
	-- Purpose: Calls a lambada function.
	
	local Lambada = Value(self)
	
	local Perams, Return = Lambada[2], Lambada[4]
	
	local tPerams = #Perams
	
	if tPerams != #Values then
		self:Throw("invoke", "Parameter missmatch (" .. Lambada[1] .. ") exspected got (" .. pSig .. ")")
	end
	
	for I = 1, tPerams do
		Perams[I](self, Values[I])
	end
	
	local Ok, Exception, RetValue = Lambada[3]:SafeCall(self)
	
	if (Ok and Return and Return ~= "") or (!Ok and Exception == "return") then
		if RetValue then
			return RetValue(self)
		else
			return E_A.ShortTypes[Return][3](self)
		end
	elseif !Ok then
		error(Exception, 0)
	end
	
end)