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
	local Value, tValue = ValueOp(self)
	self.Memory[Memory] = Value
	self.VariantTypes[Memory] = tValue
	self.Click[Memory] = true
end)

E_A:RegisterOperator("variable", "?", "?", function(self, Memory)
	return self.Memory[Memory], self.VariantTypes[Memory]
end)

E_A.API.AddHook("BuildFunctions", function()
	for Type, tTable in pairs(E_A.TypeShorts) do
		
		E_A:RegisterOperator("cast", Type .. "?", Type, function(self, Value)
			local Value, tValue = Value(self)
			
			if !Value then tValue = "void" end
			if Type ~= tValue then
				self:Throw("cast", "Tried to cast a variant of " .. tValue .. " to a " .. Type)
			end; return Value
		end)
		
		E_A:RegisterOperator("cast", "?" .. Type, "?", function(self, Value)
			return Value(self)
		end)
		
		E_A:RegisterFunction("type", Type, "s", function(self, Value)
			local Value, tValue = Value(self)
			return E_A.GetLongType(tValue)
		end)
		
	end
end)

/*==============================================================================================
	Section: Conditional!
==============================================================================================*/
E_A:RegisterOperator("is", "f", "n", function(self, Value)
	local V = Value(self)
	if V and V[1] and V[2] and V[3] then
		return 1 else return 0
	end
end)

/*==============================================================================================
	Section: LambdaFunctions!
==============================================================================================*/
E_A:RegisterClass("function", "f", {})

E_A:RegisterException("invoke")

E_A:RegisterOperator("funcvar", "f", "f", function(self, Memory)
	return self.Memory[Memory]
end)

E_A:RegisterOperator("funcass", "f", "", function(self, Value, Memory)
	self.Memory[Memory] = Value(self)
end)

E_A:RegisterOperator("lambda", "", "f", function(self, Sig, LoadPerams, Statements, Return)
	return {Sig, LoadPerams, Statements, Return}
end)


E_A:RegisterOperator("call", "f", "?", function(self, Value, pSig, Values)
	local Lambda, T = Value(self)
	self.ReturnValue = nil
	
	if !Lambda or !Lambda[3] then
		self:Throw("invoke", "tryed to call a void function")
	end
	
	Lambda[2](self, Values) -- Load perams!
	local Ok, Exit = Lambda[3]:SafeCall(self)
	
	if Ok or Exit == "Return" then 
		local Return = Lambda[4]
		
		if self.ReturnValue then
			return self.ReturnValue( self )
		elseif Return and Return ~= "" then
			return E_A.TypeShorts[Return][3]( self )
		else
			return
		end
	end
	
	error( Exit, 0 )
end)