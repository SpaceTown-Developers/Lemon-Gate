/*==============================================================================================
	Expression Advanced: Color Library
	Purpose: Colors!
==============================================================================================*/
local EA = LemonGate

local Round = 0.0000001000000

EA:RegisterClass( "color", "c", {0,0,0,0} )

EA:RegisterOperator("assign", "c", "", function(self, ValueOp, Memory)
	self.Memory[Memory] = ValueOp(self) 
	self.Click[Memory] = true 
end )

EA:RegisterOperator("variable", "c", "c", function(self, Memory)
	return self.Memory[Memory] 
end )

EA:RegisterOperator("is", "c", "n", function(self, Value)
	local V = Value(self)
	if V[1] > Round or -V[1] > Round or
	   V[2] > Round or -V[2] > Round or
	   V[3] > Round or -V[3] > Round or
	   V[4] > Round or -V[4] > Round then
	   return 1 else return 0 end
end )
