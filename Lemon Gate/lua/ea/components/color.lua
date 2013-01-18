/*==============================================================================================
	Expression Advanced: Color Library
	Purpose: Colors!
==============================================================================================*/
local E_A = LemonGate
local Round = 0.0000001000000

local HSVToColor = HSVToColor
local ColorToHSV = ColorToHSV
local MathClamp = math.Clamp

local function Clamp( Color ) 
    return { MathClamp( Color[1], 0, 255 ), MathClamp( Color[2], 0, 255 ), MathClamp( Color[3], 0, 255 ), MathClamp( Color[4], 0, 255 ) }
end 

/*==============================================================================================
	Class and Operators
==============================================================================================*/
E_A:RegisterClass( "color", "c", { 0, 0, 0, 255 } )
E_A:RegisterOperator( "assign", "c", "", E_A.AssignOperator)
E_A:RegisterOperator( "variable", "c", "c", E_A.VariableOperator)
E_A:RegisterOperator("delta", "c", "c", E_A.DeltaOperator)
E_A:RegisterOperator("trigger", "c", "n", E_A.TriggerOperator)

E_A:RegisterOperator( "is", "c", "n", function( self, Value )
	local V = Value(self)
	if V[1] > Round or -V[1] > Round or
	   V[2] > Round or -V[2] > Round or
	   V[3] > Round or -V[3] > Round or
	   V[4] > Round or -V[4] > Round then
	   return 1 else return 0 end
end )

E_A:RegisterOperator( "addition", "cc", "c", function( self, ValueA, ValueB )
	local A, B = ValueA(self), ValueB(self)
	return Clamp( { A[1] + B[1], A[2] + B[2], A[3] + B[3], A[4] + B[4] } )
end )

E_A:RegisterOperator( "subtraction", "cc", "c", function( self, ValueA, ValueB )
	local A, B = ValueA(self), ValueB(self)
    return Clamp( { A[1] - B[1], A[2] - B[2], A[3] - B[3], A[4] - B[4] } )
end )

E_A:RegisterFunction( "color", "nnn", "c", function( self, ValueA, ValueB, ValueC ) 
    local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	return Clamp( { A, B, C, 255 } )
end )

E_A:RegisterFunction( "color", "nnnn", "c", function( self, ValueA, ValueB, ValueC, ValueD ) 
    local A, B, C, D = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	return Clamp( { A, B, C, D } )
end )

E_A:RegisterFunction( "setR", "c:n", "c", function( self, ValueA, ValueB ) 
    local A, B = ValueA(self), ValueB(self)
	return Clamp( { B, A[2], A[3], A[4] } )
end )

E_A:RegisterFunction( "setG", "c:n", "c", function( self, ValueA, ValueB ) 
    local A, B = ValueA(self), ValueB(self)
	return Clamp( { A[1], B, A[3], A[4] } )
end )

E_A:RegisterFunction( "setB", "c:n", "c", function( self, ValueA, ValueB ) 
    local A, B = ValueA(self), ValueB(self)
	return Clamp( { A[1], A[2], B, A[4] } )
end )

E_A:RegisterFunction( "setA", "c:n", "c", function( self, ValueA, ValueB ) 
    local A, B = ValueA(self), ValueB(self)
	return Clamp( { A[1], A[2], A[3], B } )
end )

E_A:RegisterFunction( "r", "c:", "n", function( self, Value ) 
    local V = Value(self)
    return V[1]
end )

E_A:RegisterFunction( "g", "c:", "n", function( self, Value ) 
    local V = Value(self)
    return V[2]
end )

E_A:RegisterFunction( "b", "c:", "n", function( self, Value ) 
    local n = Value(self)
    return n[3]
end )

E_A:RegisterFunction( "a", "c:", "n", function( self, Value ) 
    local V = Value(self)
    return V[4]
end )

E_A:RegisterFunction( "hsv2rgb", "c:", "c", function( self, Value ) 
    local V = Value(self)
    local C = HSVToColor(V[1], V[2], V[3])
	return { C.r, C.g, C.b }
end )

E_A:RegisterFunction( "hsv2rgb", "nnn", "c", function( self, Value, ValueB, ValueC ) 
    local C = HSVToColor(Value(self), ValueB(self), ValueC(self), nil)
	return { C.r, C.g, C.b }
end )

E_A:RegisterFunction( "rgb2hsv", "c:", "c", function( self, Value ) 
    local V = Value(self)
	return { ColorToHSV( Color(V[1], V[2], V[3]) ) }
end )

E_A:RegisterFunction( "rgb2hsv", "nnn", "c", function( self, Value, ValueB, ValueC ) 
    local V = ColorToHSV( Color( Value(self), ValueB(self), ValueC(self), nil ) )
	return { V.r, V.g, V.b }
end )
