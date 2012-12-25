/*==============================================================================================
	Expression Advanced: Lambda Functions.
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

E_A:RegisterException("cast")

E_A:RegisterOperator("assign", "?", "", function(self, ValueOp, Memory)
	local Val, Type = ValueOp(self)
	
	self.Memory[Memory] = Val
	
	self.VariantTypes[Memory] = Type
	
	self.Click[Memory] = true
end)

E_A:RegisterOperator("variable", "?", "?", function(self, Memory)
	return self.Memory[Memory], self.VariantTypes[Memory]
end)

E_A.API.AddHook("BuildFunctions", function()
	for Type, tTable in pairs(E_A.TypeShorts) do
		
			E_A:RegisterOperator("cast", Type .. "?", Type, function(self, Value)
				local Val, Typ = Value(self)
				
				if Type != Typ then
					self:Throw("cast", "Tried to cast a variant of " .. Typ .. " to a " .. Type)
				end
				
				return Val
			end)
			
			E_A:RegisterOperator("cast", "?" .. Type, "?", function(self, Value)
				return Value(self)
			end)
			
			E_A:RegisterFunction("type", Type, "s", function(self, Value)
				local Val, tVal = Value(self)
				
				Value[1] = function() return Val, tVal end
				
				return E_A.GetLongType(tVal) -- This should work =D
			end)
	end
end)

/*==============================================================================================
	Section: Conditional!
==============================================================================================*/
E_A:RegisterOperator("is", "f", "n", function(self, Value)
	-- Purpose: Does a function exist.
	
	local V = Value(self)
	if V and V[1] and V[2] and V[3] then
		return 1 else return 0
	end
end)

/*==============================================================================================
	Section: LambdaFunctions!
==============================================================================================*/
E_A:RegisterClass("function", "f")

E_A:RegisterException("invoke")

E_A:RegisterOperator("funcvar", "f", "f", function(self, Memory)
	-- Purpose: Returns a function.
	
	return self.Memory[Memory]
end)

E_A:RegisterOperator("funcass", "f", "", function(self, Value, Memory)
	-- Purpose: Stores a function.
	
	self.Memory[Memory] = Value(self)
end)

E_A:RegisterOperator("lambda", "", "f", function(self, Sig, Perams, Statements, Return)
	-- Purpose: Creates a lambda function.
	
	return {Sig, Perams, Statements, Return}
end)


E_A:RegisterOperator("call", "f", "?", function(self, Value, pSig, Values)
	-- Purpose: Calls a lambda function.
	
	local Lambda = Value(self)
	
	local Perams, Return = Lambda[2], Lambda[4]
	
	local tPerams = #Perams
	
	if tPerams != #Values then
		self:Throw("invoke", "Parameter mismatch (" .. Lambda[1] .. ") expected got (" .. pSig .. ")")
	end
	
	for I = 1, tPerams do
		Perams[I](self, Values[I])
	end
	
	local Ok, Exception, RetValue = Lambda[3]:SafeCall(self)
	
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