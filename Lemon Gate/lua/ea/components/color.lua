/*==============================================================================================
	Expression Advanced: Color Library
	Purpose: Colors!
==============================================================================================*/
local EA = LemonGate
local Round = 0.0000001000000

local HSVToColor = HSVToColor
local ColorToHSV = ColorToHSV

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

EA:RegisterFunction( "setR", "c:n", "c", function( self, ValueA, ValueB ) 
    local c = ValueA(self)
    local n = ValueB(self) 
    c[1] = n; return c
end )

EA:RegisterFunction( "setG", "c:n", "c", function( self, ValueA, ValueB ) 
    local c = ValueA(self)
    local n = ValueB(self) 
    c[2] = n; return c
end )

EA:RegisterFunction( "setB", "c:n", "c", function( self, ValueA, ValueB ) 
    local c = ValueA(self)
    local n = ValueB(self) 
    c[3] = n; return c
end )

EA:RegisterFunction( "setA", "c:n", "c", function( self, ValueA, ValueB ) 
    local c = ValueA(self)
    local n = ValueB(self) 
    c[4] = n; return c
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

EA:RegisterFunction( "hsv2rgb", "c:", "c", function( self, Value ) 
    local c = Value(self)
    local v = HSVToColor(c[1], c[2], c[3])
	return { v.r, v.g, v.b }
end )

EA:RegisterFunction( "hsv2rgb", "nnn", "c", function( self, ValueA, ValueB, ValueC ) 
    local v = HSVToColor(ValueA(self), ValueB(self), ValueC(self), nil)
	return { v.r, v.g, v.b }
end )

EA:RegisterFunction( "rgb2hsv", "c:", "c", function( self, Value ) 
    local c = Value(self)
	return { ColorToHSV(Color(c[1], c[2], c[3])) }
end )

EA:RegisterFunction( "rgb2hsv", "nnn", "c", function( self, ValueA, ValueB, ValueC ) 
    local v = ColorToHSV(Color(ValueA(self), ValueB(self), ValueC(self), nil))
	return { v.r, v.g, v.b }
end )
