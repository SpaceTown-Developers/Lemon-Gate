/*==============================================================================================
	Expression Advanced: First Class Functions.
	Purpose: V2
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
E_A.API.NewComponent("Lambda", true)

/*==============================================================================================
	Expression Advanced: Variant Class.
	Purpose: Untyped containers.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterClass("variant", "?")
E_A:RegisterException("cast")

E_A:RegisterOperator("assign", "?", "",
	function(self, ValueOp, Memory)
		local Value, tValue = ValueOp(self)
		self.Memory[Memory] = Value
		self.VariantTypes[Memory] = tValue
		self.Click[Memory] = true
	end)

E_A:RegisterOperator("variable", "?", "?",
	function(self, Memory)
		return self.Memory[Memory], self.VariantTypes[Memory]
	end)

/*==============================================================================================
	Section: Casting
==============================================================================================*/
E_A.API.AddHook("BuildFunctions",
	function( )
		for Type, tTable in pairs( E_A.TypeShorts ) do
			
			E_A:RegisterOperator("cast", Type .. "?", Type,
				function(self, Value)
					local Value, tValue = Value(self)
					
					if !Value then
						tValue = "void"
					end
					
					if Type ~= tValue then
						self:Throw("cast", "Tried to cast a variant of " .. tValue .. " to a " .. Type)
					end
					
					return Value
				end)
			
			E_A:RegisterOperator("cast", "?" .. Type, "?",
				function(self, Value)
					return Value(self)
				end)
			
			E_A:RegisterFunction("type", Type, "s",
				function(self, Value)
					local Value, tValue = Value(self)
					return E_A.GetLongType(tValue)
				end)
			---
		end
	end)

/*==============================================================================================
	Expression Advanced: Lambda Class.
	Purpose: First Class Functions!.
	Creditors: Rusketh
==============================================================================================*/
local unpack, error, setmetatable = unpack, error, setmetatable

/*==============================================================================================
	Section: Base!
==============================================================================================*/
E_A.LAMBDA = { }

local LAMBDA = E_A.LAMBDA
LAMBDA.__index = LAMBDA

function LAMBDA.New( Signature, AssignPerams, Execution, Return )
	return setmetatable({ Signature = Signature or "",
						  AssignPerams = AssignPerams,
						  Execution = Execution,
						  Return = Return or ""
						}, LAMBDA)
end

function LAMBDA:__call( Context, Values )
	if !self or !self.Execution then
		Context:Thorw("invoke", "attempt to call void function")
	else
		self.AssignPerams( Context, Values )
		
		return self.Execution:SafeCall( Context )
	end
end

/*==============================================================================================
	Section: Class
==============================================================================================*/
E_A:RegisterClass("function", "f", LAMBDA.New)
E_A:RegisterException("invoke")

E_A:RegisterOperator("funcvar", "f", "f",
	function(self, Memory)
		return self.Memory[Memory]
	end)

E_A:RegisterOperator("funcass", "f", "",
	function(self, Value, Memory)
		self.Memory[Memory] = Value(self)
	end)

E_A:RegisterOperator("lambda", "", "f",
	function(self, Signature, AssignPerams, Execution, Return )
		return LAMBDA.New( Signature, AssignPerams, Execution, Return )
	end)

E_A:RegisterOperator("is", "f", "n",
	function(self, Value)
		local L = Value(self)
		return (L and L.Execution) and 1 or 0
	end)

E_A:RegisterOperator("call", "f", "?",
	function(self, Lambda, InputSignature, Values)
		self.ReturnValue = nil -- Kill it with fire =D
		
		local L = Lambda( self )
		local Ok, ExitCode = L( self, Values )
		
		if !Ok and ExitCode ~= "Return" then
			error( ExitCode, 0 ) -- Progress Excetion
		elseif self.ReturnValue then
			return self.ReturnValue( self )
		elseif L.Return and L.Return ~= "" then
			return E_A.TypeShorts[L.Return][3]( self )
		end
	end)