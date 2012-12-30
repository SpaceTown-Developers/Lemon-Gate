/*==============================================================================================
	Expression Advanced: Matrixs.
	Purpose: Dam it Omicron, A is for you.
	Note: I just ripped A dorectly from E2.
==============================================================================================*/
local E_A = LemonGate

local GetLongType = E_A.GetLongType

local Round = 0.0000001000000

local ipairs = ipairs

/*==============================================================================================
	Util Functions
==============================================================================================*/

local function Clone( A )
	local Copy = {}
	for K,V in ipairs( A ) do Copy[K] = V end
	return Copy
end

/*==============================================================================================
	Matrix 2: Util Functions
==============================================================================================*/

local function Det2( A )
	return ( A[1] * A[4] - A[3] * A[2] )
end

local function Inverse2( A )
	local Det = Det2( A )
	if Det == 0 then return { 0, 0, 0, 0 } end
	return { A[4] / Det, -A[2] / Det, -A[3] / Det, A[1] / Det }
end

/*==============================================================================================
	Maxtrix 2: Class
==============================================================================================*/
E_A:RegisterClass("matrix2", "m2", { 0, 0, 0, 0 })

local function Input(self, Memory, Value)
	self.Memory[Memory] = Value
end

local function Output(self, Memory)
	return Clone( self.Memory[Memory] )
end

E_A:WireModClass("matrix2", "MATRIX2", Input, Output)

/*==============================================================================================
	Maxtrix 2: Creator Functions
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)


E_A:RegisterFunction("matrix2", "", "m2", function(self, Value)
	return { 0, 0, 0, 0 }
end)

E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("matrix2", "v2v2", "m2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1], B[1], A[2], B[2] }
end)

E_A:RegisterFunction("rowMatrix2", "v2v2", "m2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1], A[2], B[1], B[2] }
end)

E_A:RegisterFunction("matrix2", "nnnn", "m2", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, C, D = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	return { A, B, C, D }
end)

E_A:RegisterFunction("matrix2", "m", "m2", function(self, ValueA)
	local A = ValueA(self)
	return { A[1], A[2], A[4], A[5] }
end)

E_A:RegisterFunction("identity2", "", "m2", function(self)
	local A = ValueA(self)
	return { 1, 0, 0, 1 }
end)

/*==============================================================================================
	Maxtrix 2: Operators
==============================================================================================*/
E_A:RegisterOperator("assign", "m2", "", function(self, ValueOp, Memory)
	self.Delta[Memory] = self.Memory[Memory]
	
	self.Memory[Memory] = ValueOp(self)
	
	self.Click[Memory] = true
end)

E_A:RegisterOperator("variable", "m2", "m2", function(self, Memory)
	return self.Memory[Memory]
end)

/******************************************************************************/

E_A:RegisterOperator("is", "m2", "n", function(self, Value)
	local V = Value(self)
	
	if V[1] > Round or -V[1] > Round or
	   V[2] > Round or -V[2] > Round or
	   V[3] > Round or -V[3] > Round or
	   V[4] > Round or -V[4] > Round
	   then return 1 else return 0 end
end)

E_A:RegisterOperator("eq", "m2m2", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	
	if A[1] - B[1] <= Round and B[1] - A[1] <= Round and
	   A[2] - B[2] <= Round and B[2] - A[2] <= Round and
	   A[3] - B[3] <= Round and B[3] - A[3] <= Round and
	   A[4] - B[4] <= Round and B[4] - A[4] <= Round
	   then return 1 else return 0 end
end)

E_A:RegisterOperator("neq", "m2m2", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	
	if A[1] - B[1] > Round and B[1] - A[1] > Round and
	   A[2] - B[2] > Round and B[2] - A[2] > Round and
	   A[3] - B[3] > Round and B[3] - A[3] > Round and
	   A[4] - B[4] > Round and B[4] - A[4] > Round
	   then return 1 else return 0 end
end)

/******************************************************************************/

E_A:RegisterOperator("delta", "m2", "m2", function(self, Memory)
	local A, B = self.Memory[Memory], self.Delta[Memory] or { 0, 0, 0, 0 }
	return { A[1] - B[1], A[2] - B[2], A[3] - B[3], A[4] - B[4] }
end)

E_A:RegisterOperator("negative", "m2", "m2", function(self, Value)
	local V = Value(self)
	return { -V[1], -V[2], -V[3], -V[4] }
end)

E_A:RegisterOperator("addition", "m2m2", "m2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1] + B[1], A[2] + B[2], A[3] + B[3], A[4] + B[4] }
end)

E_A:RegisterOperator("subtraction", "m2m2", "m2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1] - B[1], A[2] - B[2], A[3] - B[3], A[4] - B[4] }
end)

E_A:RegisterOperator("multiply", "m2m2", "m2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1] * B[1], A[2] * B[2], A[3] * B[3], A[4] * B[4] }
end)

E_A:RegisterOperator("multiply", "m2n", "m2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1] * B, A[2] * B, A[3] * B, A[4] * B }
end)

E_A:RegisterOperator("multiply", "nm2", "m2", function(self, ValueV, ValueA)
	local A, B = ValueA(self), ValueB(self)
	return { A[1] * B, A[2] * B, A[3] * B, A[4] * B }
end) -- The top function with A & B reversed.

E_A:RegisterOperator("multiply", "m2v2", "v2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1] * B[1] + A[2] * B[2], A[3] * B[1] + A[4] * B[2] }
end)

E_A:RegisterOperator("division", "m2n", "m2", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1] / B, A[2] / B, A[3] / B, A[4] / B }
end)

E_A:RegisterOperator("exponent", "m2n", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self) 

	if B == -1 then
		return ( Inverse2(A) )
	elseif B == 0 then
		return { 1, 0, 0, 1 }
	elseif B == 1 then
		return A
	elseif B == 2 then
		return { A[1] * A[1] + A[2] * A[3],
				 A[1] * A[2] + A[2] * A[4],
				 A[3] * A[1] + A[4] * A[3],
				 A[3] * A[2] + A[4] * A[4] }
	else
		return { 0, 0, 0, 0 }
	end
end)

/*==============================================================================================
	Maxtrix 2: Functions
==============================================================================================*/

E_A:RegisterFunction("row", "m2:n", "v2", function(self, ValueA, ValueB)
	local A, B, C = ValueA(self), ValueB(self)

	if B < 1 then
		C = 1
	elseif B > 2 then
		C = 2
	else
		C = B - B % 1
	end

	return { A[C * 2 - 1], A[C * 2] }
end)

E_A:RegisterFunction("column", "m2:n", "v2", function(self, ValueA, ValueB)
	local A, B, C = ValueA(self), ValueB(self)

	if B < 1 then
		C = 1
	elseif B > 2 then
		C = 2
	else
		C = B - B % 1
	end

	return { A[C], A[C + 2] }
end)

E_A:RegisterFunction("setRow", "m2:nnn", "m2", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, C, D, E = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	
	if B < 1 then
		E = 2
	elseif B > 2 then
		E = 4
	else
		E = (B - B % 1) * 2
	end

	local F = Clone(A)
	F[E - 1] = C
	F[E] = D
	return F
end)


E_A:RegisterFunction("setRow", "m2:nv2", "m2", function(self, ValueA, ValueB, ValueC)
	local A, B, C, D = ValueA(self), ValueB(self), ValueC(self)

	if B < 1 then
		D = 2
	elseif B > 2 then
		D = 4
	else
		D = (B - B % 1) * 2
	end

	local E = Clone(A)
	E[D - 1] = C[1]
	E[D] = C[2]
	return E
end)

E_A:RegisterFunction("setColumn", "m2:nnn", "m2", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, C, D, E = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	
	if B < 1 then
		E = 1
	elseif B > 2 then
		E = 2
	else
		E = B - B % 1
	end

	local F = Clone(A)
	F[E] = C
	F[E + 2] = D
	return F
end)

E_A:RegisterFunction("setColumn", "m2:nv2", "m2", function(self, ValueA, ValueB, ValueC)
	local A, B, C, D = ValueA(self), ValueB(self), ValueC(self)

	if B < 1 then D = 1
	elseif B > 2 then D = 2
	else D = B - B % 1 end

	local F = Clone(A)
	F[D] = C[1]
	F[D + 2] = C[2]
	return F
end)

E_A:RegisterFunction("swapRows", "m2:", "m2", function(self, Value)
	local V = Value(self)

	return { V[3], V[4], V[1], V[2] }
end)

E_A:RegisterFunction("swapColumns", "m2:", "m2", function(self, Value)
	local V = Value(self)

	return { V[2], V[1], V[4], V[3] }
end)

E_A:RegisterFunction("element", "m2:nn", "n", function(self, ValueA, ValueB, ValueC)
	local A, B, C, D, E = ValueA(self), ValueB(self), ValueC(self)
	
	if B < 1 then
		D = 1
	elseif B > 2 then
		D = 2
	else
		D = B - B % 1
	end
	
	if C < 1 then
		E = 1
	elseif C > 2 then
		E = 2
	else
		E = C - C % 1
	end

	return A[D + (E - 1) * 2]
end)

E_A:RegisterFunction("setElement", "m2:nnn", "m2", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, C, D, E, F = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	
	if B < 1 then
		E = 1
	elseif B > 2 then
		E = 2
	else
		E = B - B % 1
	end
	
	if C < 1 then
		F = 1
	elseif C > 2 then
		F = 2
	else
		F = C - C % 1
	end

	local G = Clone(A)
	G[E + (F - 1) * 2] = D
	return G
end)

-- Ok A is where I get lazy, i shall stop reformating functions.
E_A:RegisterFunction("swapElements", "m2:nnnn", "m2", function(self, ValueA, ValueB, ValueC, ValueD, ValueE)
	local A, B, C, D, E = ValueA(self), ValueB(self), ValueC(self), ValueD(self), ValueE(self)
	
	local i1, j1, i2, j2

	if B < 1 then i1 = 1
	elseif B > 3 then i1 = 3
	else i1 = B - B % 1 end

	if C < 1 then j1 = 1
	elseif C > 3 then j1 = 3
	else j1 = C - C % 1 end

	if D < 1 then i2 = 1
	elseif D > 3 then i2 = 3
	else i2 = D - D % 1 end

	if E < 1 then j2 = 1
	elseif E > 3 then j2 = 3
	else j2 = E - E % 1 end

	local k1 = i1 + (j1 - 1) * 2
	local k2 = i2 + (j2 - 1) * 2
	local a = Clone(A)
	a[k1], a[k2] = A[k2], A[k1]
	return a
end)

/******************************************************************************/

E_A:RegisterFunction("diagonal", "m2", "v2", function(self, Value)
	local V = Value(self)
	return { V[1], V[4] }
end)

E_A:RegisterFunction("trace", "m2", "n", function(self, Value)
	local V = Value(self)
	return ( V[1] + V[4] )
end)

E_A:RegisterFunction("det", "m2", "n", function(self, Value)
	return Det2( Value(self) )
end)

E_A:RegisterFunction("transpose", "m2", "m2", function(self, Value)
	local V = Value(self)
	return { V[1], V[3], V[2], V[4] }
end)

E_A:RegisterFunction("adj", "m2", "m2", function(self, Value)
	local V = Value(self)
	return { V[4], -V[2], -V[3],  V[1] }
end)

/*==============================================================================================
	Maxtrix 3: Class
==============================================================================================*/
E_A:RegisterClass("matrix", "m3", { 0, 0, 0, 0, 0, 0, 0, 0, 0 })

local function Input(self, Memory, Value)
	self.Memory[Memory] = Value
end

local function Output(self, Memory)
	return Clone( self.Memory[Memory] )
end

E_A:WireModClass("matrix", "MATRIX", Input, Output)

/*==============================================================================================
	Matrix 3: Util Functions
==============================================================================================*/

local function Det3(A)
	return ( A[1] * (A[5] * A[9] - A[8] * A[6]) -
			 A[2] * (A[4] * A[9] - A[7] * A[6]) +
			 A[3] * (A[4] * A[8] - A[7] * A[5]) )
end

local function Inverse3(A)
	local det = det3(A)
	if det == 0 then
		return { 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	end
	
	return { (A[5] * A[9] - A[8] * A[6])/det,	(A[8] * A[3] - A[2] * A[9])/det,	(A[2] * A[6] - A[5] * A[3])/det,
			 (A[7] * A[6] - A[4] * A[9])/det,	(A[1] * A[9] - A[7] * A[3])/det,	(A[4] * A[3] - A[1] * A[6])/det,
			 (A[4] * A[8] - A[7] * A[5])/det,	(A[7] * A[2] - A[1] * A[8])/det,	(A[1] * A[5] - A[4] * A[2])/det }
end

/*==============================================================================================
	Matrix 3: Creator Functions
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterFunction("matrix", "", "m3", function(self)
	return { 0, 0, 0,
			 0, 0, 0,
			 0, 0, 0 }
end)

E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("matrix", "vvv", "m3", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	return { A[1], B[1], C[1],
			 A[2], B[2], C[2],
			 A[3], B[3], C[3] }
end)

E_A:RegisterFunction("rowMatrix", "vvv", "m3", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	return { A[1], A[2], A[3],
			 B[1], B[2], B[3],
			 C[1], C[2], C[3],}
end)

E_A:RegisterFunction("matrix", "nnnnnnnnn", "m3", function(self, A, B, C, D, E, F, G, H ,I)
	return { A(self), B(self), C(self),
			 D(self), E(self), F(self),
			 G(self), H(self), I(self), nil }
end) -- Holy Crap, 9 args!

E_A:RegisterFunction("matrix", "m2", "m3", function(self, Value)
	local V = Value( self )
	
	return { V[1], V[2], 0,
			 V[3], V[4], 0,
			 0,	0, 0 }
end)

E_A:RegisterFunction("identity", "", "m3", function(self)
	return { 1, 0, 0,
			 0, 1, 0,
			 0, 0, 1 }
end)

/*==============================================================================================
	Matrix 3: Operators
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterOperator("assign", "m3", "", function(self, Value, Memory)
	self.Delta[Memory] = self.Memory[Memory]
	
	self.Memory[Memory] = Value(self)
	
	self.Click[Memory] = true
end)

E_A:RegisterOperator("variable", "m3", "m3", function(self, Memory)
	return self.Memory[Memory]
end)

/******************************************************************************/

E_A:RegisterOperator("is", "m3", "n", function(self, Value)
	local A = Value(self)
	if A[1] > Round or -A[1] > Round or
	   A[2] > Round or -A[2] > Round or
	   A[3] > Round or -A[3] > Round or
	   A[4] > Round or -A[4] > Round or
	   A[5] > Round or -A[5] > Round or
	   A[6] > Round or -A[6] > Round or
	   A[7] > Round or -A[7] > Round or
	   A[8] > Round or -A[8] > Round or
	   A[9] > Round or -A[9] > Round
	   then return 1 else return 0 end
end)

E_A:RegisterOperator("eq", "m3m3", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	if A[1] - B[1] <= Round and B[1] - A[1] <= Round and
	   A[2] - B[2] <= Round and B[2] - A[2] <= Round and
	   A[3] - B[3] <= Round and B[3] - A[3] <= Round and
	   A[4] - B[4] <= Round and B[4] - A[4] <= Round and
	   A[5] - B[5] <= Round and B[5] - A[5] <= Round and
	   A[6] - B[6] <= Round and B[6] - A[6] <= Round and
	   A[7] - B[7] <= Round and B[7] - A[7] <= Round and
	   A[8] - B[8] <= Round and B[8] - A[8] <= Round and
	   A[9] - B[9] <= Round and B[9] - A[9] <= Round
	   then return 1 else return 0 end
end)

E_A:RegisterOperator("neg", "m3m3", "n", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	if A[1] - B[1] > Round and B[1] - A[1] > Round and
	   A[2] - B[2] > Round and B[2] - A[2] > Round and
	   A[3] - B[3] > Round and B[3] - A[3] > Round and
	   A[4] - B[4] > Round and B[4] - A[4] > Round and
	   A[5] - B[5] > Round and B[5] - A[5] > Round and
	   A[6] - B[6] > Round and B[6] - A[6] > Round and
	   A[7] - B[7] > Round and B[7] - A[7] > Round and
	   A[8] - B[8] > Round and B[8] - A[8] > Round and
	   A[9] - B[9] > Round and B[9] - A[9] > Round
	   then return 1 else return 0 end
end)

/******************************************************************************/

E_A:RegisterOperator("delta", "m3", "m3", function(self, Memory)
	local A, B = self.Memory[Memory], self.Delta[Memory] or { 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	
	return { A[1] - B[1], A[2] - B[2], A[3] - B[3],
			 A[4] - B[4], A[5] - B[5], A[6] - B[6],
			 A[7] - B[7], A[8] - B[8], A[9] - B[9]	}
end)

E_A:RegisterOperator("negative", "m3", "m3", function(self, ValueA)
	local A = ValueA(self)
	return { -A[1], -A[2], -A[3],
			 -A[4], -A[5], -A[6],
			 -A[7], -A[8], -A[9] }
end)

E_A:RegisterOperator("addition", "m3m3", "m3", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1] + B[1], A[2] + B[2], A[3] + B[3],
			 A[4] + B[4], A[5] + B[5], A[6] + B[6],
			 A[7] + B[7], A[8] + B[8], A[9] + B[9] }
end)

E_A:RegisterOperator("subtraction", "m3m3", "m3", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1] - B[1], A[2] - B[2], A[3] - B[3],
			 A[4] - B[4], A[5] - B[5], A[6] - B[6],
			 A[7] - B[7], A[8] - B[8], A[9] - B[9] }
end)

E_A:RegisterOperator("multiply", "nm3", "m3", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A * B[1], A * B[2], A * B[3],
			 A * B[4], A * B[5], A * B[6],
			 A * B[7], A * B[8], A * B[9] }
end)

E_A:RegisterOperator("multiply", "m3n", "m3", function(self, ValueB, ValueA)
	local A, B = ValueA(self), ValueB(self)
	return { A[1] * B, A[2] * B, A[3] * B,
			 A[4] * B, A[5] * B, A[6] * B,
			 A[7] * B, A[8] * B, A[9] * B }
end)

E_A:RegisterOperator("multiply", "m3v", "m3", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1] * B[1] + A[2] * B[2] + A[3] * B[3],
			 A[4] * B[1] + A[5] * B[2] + A[6] * B[3],
			 A[7] * B[1] + A[8] * B[2] + A[9] * B[3] }
end)

E_A:RegisterOperator("multiply", "m3m3", "m3", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1] * B[1] + A[2] * B[4] + A[3] * B[7],
			 A[1] * B[2] + A[2] * B[5] + A[3] * B[8],
			 A[1] * B[3] + A[2] * B[6] + A[3] * B[9],
			 A[4] * B[1] + A[5] * B[4] + A[6] * B[7],
			 A[4] * B[2] + A[5] * B[5] + A[6] * B[8],
			 A[4] * B[3] + A[5] * B[6] + A[6] * B[9],
			 A[7] * B[1] + A[8] * B[4] + A[9] * B[7],
			 A[7] * B[2] + A[8] * B[5] + A[9] * B[8],
			 A[7] * B[3] + A[8] * B[6] + A[9] * B[9] }
end)

E_A:RegisterOperator("division", "m3n", "m3", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { A[1] / B, A[2] / B, A[3] / B,
			 A[4] / B, A[5] / B, A[6] / B,
			 A[7] / B, A[8] / B, A[9] / B }
end)

E_A:RegisterOperator("exponent", "m3n", "m3", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)

	if B == -1 then return ( inverse3(A) )

	elseif B == 0 then return { 1, 0, 0,
								  0, 1, 0,
								  0, 0, 1 }

	elseif B == 1 then return A

	elseif B == 2 then
		return { A[1] * A[1] + A[2] * A[4] + A[3] * A[7],
				 A[1] * A[2] + A[2] * A[5] + A[3] * A[8],
				 A[1] * A[3] + A[2] * A[6] + A[3] * A[9],
				 A[4] * A[1] + A[5] * A[4] + A[6] * A[7],
				 A[4] * A[2] + A[5] * A[5] + A[6] * A[8],
				 A[4] * A[3] + A[5] * A[6] + A[6] * A[9],
				 A[7] * A[1] + A[8] * A[4] + A[9] * A[7],
				 A[7] * A[2] + A[8] * A[5] + A[9] * A[8],
				 A[7] * A[3] + A[8] * A[6] + A[9] * A[9] }

	else return { 0, 0, 0,
				  0, 0, 0,
				  0, 0, 0 }
	end
end)

/*==============================================================================================
	Matrix 3: Functions
==============================================================================================*/

E_A:RegisterFunction("row", "m3:n", "v", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	local k

	if B < 1 then k = 3
	elseif B > 3 then k = 9
	else k = (B - B % 1)*3 end

	local x = A[k - 2]
	local y = A[k - 1]
	local z = A[k]
	return { x, y, z }
end)

E_A:RegisterFunction("column", "m3:n", "v", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	local k

	if B < 1 then k = 1
	elseif B > 3 then k = 3
	else k = B - B % 1 end

	local x = A[k]
	local y = A[k + 3]
	local z = A[k + 6]
	return { x, y, z }
end)

E_A:RegisterFunction("setRow", "m3:nnnn", "m3", function(self, ValueA, ValueB, ValueC, ValueD, ValueE)
	local A, B, C, D, E = ValueA(self), ValueB(self), ValueC(self), ValueD(self), ValueE(self)
	local k

	if B < 1 then k = 1
	elseif B > 3 then k = 3
	else k = B - B % 1 end

	local a = clone(A)
	a[k * 3 - 2] = C
	a[k * 3 - 1] = D
	a[k * 3] = E
	return a
end)

E_A:RegisterFunction("setRow", "m3:nv", "m3", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	local k

	if B < 1 then k = 1
	elseif B > 3 then k = 3
	else k = B - B % 1 end

	local a = clone(A)
	a[k * 3 - 2] = C[1]
	a[k * 3 - 1] = C[2]
	a[k * 3] = C[3]
	return a
end)

E_A:RegisterFunction("setColumn", "m3:nnnn", "m3", function(self, ValueA, ValueB, ValueC, ValueD, ValueE)
	local A, B, C, D, E = ValueA(self), ValueB(self), ValueC(self), ValueD(self), ValueE(self)
	local k

	if B < 1 then k = 1
	elseif B > 3 then k = 3
	else k = B - B % 1 end

	local a = clone(A)
	a[k] = C
	a[k + 3] = D
	a[k + 6] = E
	return a
end)

E_A:RegisterFunction("setColumn", "m3:nv", "m3", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	local k

	if B < 1 then k = 1
	elseif B > 3 then k = 3
	else k = B - B % 1 end

	local a = clone(A)
	a[k] = C[1]
	a[k + 3] = C[2]
	a[k + 6] = C[3]
	return a
end)

E_A:RegisterFunction("swapRows", "m3:nn", "m3", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	local r1, r2

	if B < 1 then r1 = 1
	elseif B > 3 then r1 = 3
	else r1 = B - B % 1 end
	if C < 1 then r2 = 1
	elseif C > 3 then r2 = 3
	else r2 = C - C % 1 end

	if r1 == r2 then return A
	elseif (r1 == 1 and r2 == 2) or (r1 == 2 and r2 == 1) then
		A = { A[4], A[5], A[6],
				A[1], A[2], A[3],
				A[7], A[8], A[9] }
	elseif (r1 == 2 and r2 == 3) or (r1 == 3 and r2 == 2) then
		A = { A[1], A[2], A[3],
				A[7], A[8], A[9],
				A[4], A[5], A[6] }
	elseif (r1 == 1 and r2 == 3) or (r1 == 3 and r2 == 1) then
		A = { A[7], A[8], A[9],
				A[4], A[5], A[6],
				A[1], A[2], A[3] }
	end
	return A
end)

E_A:RegisterFunction("swapColumns", "m3:nn", "m3", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	local r1, r2

	if B < 1 then r1 = 1
	elseif B > 3 then r1 = 3
	else r1 = B - B % 1 end
	if C < 1 then r2 = 1
	elseif C > 3 then r2 = 3
	else r2 = C - C % 1 end

	if r1 == r2 then return A
	elseif (r1 == 1 and r2 == 2) or (r1 == 2 and r2 == 1) then
		A = { A[2], A[1], A[3],
				A[5], A[4], A[6],
				A[8], A[7], A[9] }
	elseif (r1 == 2 and r2 == 3) or (r1 == 3 and r2 == 2) then
		A = { A[1], A[3], A[2],
				A[4], A[6], A[5],
				A[7], A[9], A[8] }
	elseif (r1 == 1 and r2 == 3) or (r1 == 3 and r2 == 1) then
		A = { A[3], A[2], A[1],
				A[6], A[5], A[4],
				A[9], A[8], A[7] }
	end
	return A
end)

E_A:RegisterFunction("element", "m3:nn", "n", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	local i, j

	if B < 1 then i = 1
	elseif B > 3 then i = 3
	else i = B - B % 1 end
	if C < 1 then j = 1
	elseif C > 3 then j = 3
	else j = C - C % 1 end

	local k = i + (j - 1) * 3
	return A[k]
end)

E_A:RegisterFunction("setElement", "m3:nnn", "m3", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, C, D = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	local i, j

	if B < 1 then i = 1
	elseif B > 3 then i = 3
	else i = B - B % 1 end
	if C < 1 then j = 1
	elseif C > 3 then j = 3
	else j = C - C % 1 end

	local a = clone(A)
	a[i + (j - 1) * 3] = D
	return a
end)

E_A:RegisterFunction("swapElements", "m3:nnnn", "m3", function(self, ValueA, ValueB, ValueC, ValueD, ValueE)
	local A, B, C, D, E = ValueA(self), ValueB(self), ValueC(self), ValueD(self), ValueE(self)
	local i1, j1, i2, j2

	if B < 1 then i1 = 1
	elseif B > 3 then i1 = 3
	else i1 = B - B % 1 end

	if C < 1 then j1 = 1
	elseif C > 3 then j1 = 3
	else j1 = C - C % 1 end

	if D < 1 then i2 = 1
	elseif D > 3 then i2 = 3
	else i2 = D - D % 1 end

	if E < 1 then j2 = 1
	elseif E > 3 then j2 = 3
	else j2 = E - E % 1 end

	local k1 = i1 + (j1 - 1) * 3
	local k2 = i2 + (j2 - 1) * 3
	local a = clone(A)
	a[k1], a[k2] = A[k2], A[k1]
	return a
end)

E_A:RegisterFunction("setDiagonal", "m3:v", "m3", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	return { B[1], A[4], A[7],
			 A[2], B[2], A[8],
			 A[3], A[6], B[3] }
end)

E_A:RegisterFunction("setDiagonal", "m3:nnn", "m3", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, C, D = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	return { B, A[4], A[7],
			 A[2], C, A[8],
			 A[3], A[6], D }
end)

/*==============================================================================================
	Matrix 3: Useful Functions
==============================================================================================*/
E_A:RegisterFunction("diagonal", "m3", "v", function(self, ValueA)
	local A = ValueA(self)
	return { A[1], A[5], A[9] }
end)

E_A:RegisterFunction("trace", "m3", "n", function(self, ValueA)
	local A = ValueA(self)
	return ( A[1] + A[5] + A[9] )
end)

E_A:RegisterFunction("det", "m3", "n", function(self, ValueA)
	local A = ValueA(self)
	return ( Det3(A) )
end)

E_A:RegisterFunction("transpose", "m3", "m3", function(self, ValueA)
	local A = ValueA(self)
	return { A[1], A[4], A[7],
			 A[2], A[5], A[8],
			 A[3], A[6], A[9] }
end)

E_A:RegisterFunction("adj", "m3", "m3", function(self, ValueA)
	local A = ValueA(self)
	return { A[5] * A[9] - A[8] * A[6],	A[8] * A[3] - A[2] * A[9],	A[2] * A[6] - A[5] * A[3],
			 A[7] * A[6] - A[4] * A[9],	A[1] * A[9] - A[7] * A[3],	A[4] * A[3] - A[1] * A[6],
			 A[4] * A[8] - A[7] * A[5],	A[7] * A[2] - A[1] * A[8],	A[1] * A[5] - A[4] * A[2] }
end)

/*==============================================================================================
	Matrix 3: Extra Functions
==============================================================================================*/

E_A:RegisterFunction("matrix", "e", "m3", function(self, ValueA)
	local A = ValueA(self)
	
	if !IsValid(A)  then
		return { 0, 0, 0,
				 0, 0, 0,
				 0, 0, 0 }
	end
	local factor = 10000
	local pos = A:GetPos()
	local x = A:LocalToWorld(Vector(factor,0,0)) - pos
	local y = A:LocalToWorld(Vector(0,factor,0)) - pos
	local z = A:LocalToWorld(Vector(0,0,factor)) - pos
	return { x.x/factor, y.x/factor, z.x/factor,
			 x.y/factor, y.y/factor, z.y/factor,
			 x.z/factor, y.z/factor, z.z/factor }
end)

E_A:RegisterFunction("x", "m3:", "v", function(self, ValueA)
	local A = ValueA(self)
	return { A[1], A[4], A[7] }
end)

E_A:RegisterFunction("y", "m3:", "v", function(self, ValueA)
	local A = ValueA(self)
	return { A[2], A[5], A[8] }
end)

E_A:RegisterFunction("z", "m3:", "v", function(self, ValueA)
	local A = ValueA(self)
	return { A[3], A[6], A[9] }
end)

// Returns a 3x3 reference frame matrix as described by the angle <ang>. Multiplying by A matrix will be the same as rotating by the given angle.
E_A:RegisterFunction("matrix", "a", "m3", function(self, ValueA)
	local A = ValueA(self)
	
	ang = Angle(ang[1], ang[2], ang[3])
	local x = ang:Forward()
	local y = ang:Right() * -1
	local z = ang:Up()
	return {
		x.x, y.x, z.x,
		x.y, y.y, z.y,
		x.z, y.z, z.z
	}
end)

// Converts a rotation matrix to angle form (assumes matrix is orthogonal)
local rad2deg = 180 / math.pi

E_A:RegisterFunction("toAngle", "m3:", "a", function(self, ValueA)
	local A = ValueA(self)
	
	local pitch = math.asin( -A[7] ) * rad2deg
	local yaw = math.atan2( A[4], A[1] ) * rad2deg
	local roll = math.atan2( A[8], A[9] ) * rad2deg
	return { pitch, yaw, roll }
end)

// Create a rotation matrix in the format (v,n) where v is the axis direction vector and n is degrees (right-handed rotation)
E_A:RegisterFunction("mRotation", "vn", "m3", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)

	local vec
	local len = (A[1] * A[1] + A[2] * A[2] + A[3] * A[3]) ^ 0.5
	if len == 1 then vec = A
	elseif len > Round then vec = { A[1] / len, A[2] / len, A[3] / len }
	else return { 0, 0, 0,
				  0, 0, 0,
				  0, 0, 0 }
	end

	local vec2 = { vec[1] * vec[1], vec[2] * vec[2], vec[3] * vec[3] }
	local a = B * 3.14159265 / 180
	local cos = math.cos(a)
	local sin = math.sin(a)
	local cosmin = 1 - cos
	return { vec2[1] + (1 - vec2[1]) * cos,
			 vec[1] * vec[2] * cosmin - vec[3] * sin,
			 vec[1] * vec[3] * cosmin + vec[2] * sin,
			 vec[1] * vec[2] * cosmin + vec[3] * sin,
			 vec2[2] + (1 - vec2[2]) * cos,
			 vec[2] * vec[3] * cosmin - vec[1] * sin,
			 vec[1] * vec[3] * cosmin - vec[2] * sin,
			 vec[2] * vec[3] * cosmin + vec[1] * sin,
			 vec2[3] + (1 - vec2[3]) * cos }
end)
