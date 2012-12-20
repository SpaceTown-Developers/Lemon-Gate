/*==============================================================================================
	Expression Advanced: Color Library
	Purpose: Colors!
==============================================================================================*/
local EA = LemonGate
local Round = 0.0000001000000

local function clamp( color ) 
    return { math.Clamp( color[1], 0, 255 ), math.Clamp( color[2], 0, 255 ), math.Clamp( color[3], 0, 255 ), math.Clamp( color[4], 0, 255 ) }
end 

EA:RegisterClass( "color", "c", { 0, 0, 0, 255 } )

EA:RegisterOperator( "assign", "c", "", function( self, ValueOp, Memory )
	self.Memory[Memory] = ValueOp(self) 
	self.Click[Memory] = true 
end )

EA:RegisterOperator( "variable", "c", "c", function( self, Memory )
	return self.Memory[Memory] 
end )

EA:RegisterOperator( "is", "c", "n", function( self, Value )
	local V = Value(self)
	if V[1] > Round or -V[1] > Round or
	   V[2] > Round or -V[2] > Round or
	   V[3] > Round or -V[3] > Round or
	   V[4] > Round or -V[4] > Round then
	   return 1 else return 0 end
end )

EA:RegisterOperator( "get", "cn", "c", function( self, Value, Index )
    local C = Value(self)
	local I = Index(self)

	return C[I] 
end )

EA:RegisterOperator( "addition", "cc", "c", function( self, ValueA, ValueB )
	local c1 = ValueA(self)
	local c2 = ValueB(self)
    return clamp{ c1[1] + c2[1], c1[2] + c2[2], c1[3] + c2[3], c1[4] + c2[4] }
end )

EA:RegisterOperator( "subtraction", "cc", "c", function( self, ValueA, ValueB )
	local c1 = ValueA(self)
	local c2 = ValueB(self)
    return clamp{ c1[1] - c2[1], c1[2] - c2[2], c1[3] - c2[3], c1[4] - c2[4] }
end )

EA:RegisterFunction( "color", "nnn", "c", function( self, ValueA, ValueB, ValueC ) 
    return clamp{ ValueA(self), ValueB(self), ValueC(self), 255 }
end )

EA:RegisterFunction( "color", "nnnn", "c", function( self, ValueA, ValueB, ValueC, ValueD ) 
    return clamp{ ValueA(self), ValueB(self), ValueC(self), ValueD(self) }
end )

EA:RegisterFunction( "r", "c:n", "", function( self, ValueA, ValueB ) 
    local c = ValueA(self)
    local n = ValueB(self) 
    c[1] = n
end )

EA:RegisterFunction( "g", "c:n", "", function( self, ValueA, ValueB ) 
    local c = ValueA(self)
    local n = ValueB(self) 
    c[2] = n
end )

EA:RegisterFunction( "b", "c:n", "", function( self, ValueA, ValueB ) 
    local c = ValueA(self)
    local n = ValueB(self) 
    c[3] = n
end )

EA:RegisterFunction( "a", "c:n", "", function( self, ValueA, ValueB ) 
    local c = ValueA(self)
    local n = ValueB(self) 
    c[4] = n
end )

EA:RegisterFunction( "r", "c:", "n", function( self, Value ) 
    local n = Value(self)
    return n[1]
end )

EA:RegisterFunction( "g", "c:", "n", function( self, Value ) 
    local n = Value(self)
    return n[2]
end )

EA:RegisterFunction( "b", "c:", "n", function( self, Value ) 
    local n = Value(self)
    return n[3]
end )

EA:RegisterFunction( "a", "c:", "n", function( self, Value ) 
    local n = Value(self)
    return n[4]
end )
