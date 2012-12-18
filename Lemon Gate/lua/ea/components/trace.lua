/*==============================================================================================
	Expression Advanced: Traces.
	Purpose: Entitys are stuffs.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local type = type
local pairs = pairs
local Vector = Vector

local TraceLine = util.TraceLine
local TraceHull = util.TraceHull

local NoVec = Vector(0, 0, 0)

/*==============================================================================================
	Section: Util
==============================================================================================*/
local function TraceToTable(Trace)
	local Table = E_A.NewTable()
	
	Table:Set("entity", "e", Trace.Entity)
	
	Table:Set("fraction", "n", Trace.Fraction)
	Table:Set("fractionsolid", "n", Trace.FractionLeftSolid)
	
	local Hit = Trace.Hit and 0 or 1
	local World = Trace.HitWorld and 0 or 1
	local HitSky = Trace.HitSky and 0 or 1
	
	Table:Set("hit", "n", Hit)
	Table:Set("hitworld", "n", World)
	Table:Set("hitsky", "n", HitSky)
	
	local Dir = Trace.Normal or NoVec
	local HitPos = Trace.HitPos or NoVec
	local Start = Trace.StartPos or NoVec
	local HitNormal = Trace.HitNormal or NoVec
	
	Table:Set("dir", "v", {Dir.x, Dir.y, Dir.z})
	Table:Set("start", "v", {Start.x, Start.y, Start.z})
	Table:Set("hitpos", "v", {HitPos.x, HitPos.y, HitPos.z})
	Table:Set("hitnormal", "v", {HitNormal.x, HitNormal.y, HitNormal.z})
	
	Table:Set("hittexture", "s", Trace.HitTexture or "")
	
	return Table
end

/*==============================================================================================
	Section: Player Trace
==============================================================================================*/
E_A:SetCost(EA_COST_EXPENSIVE)

E_A:RegisterFunction("eyeTrace", "e:", "t", function(self, Value)
	local Entity, Table = Value(self), E_A.NewTable()
	
	if Entity and Entity:IsValid() and Entity:IsPlayer() then
		return TraceToTable( Entity:GetEyeTraceNoCursor() )
	end
end)

/*==============================================================================================
	Section: Trace Stuff
==============================================================================================*/
-- Start, End
E_A:RegisterFunction("trace", "vv", "t", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	local S, E = Vector(A[1], A[2], A[3]), Vector(B[1], B[2], B[3])
	local Trace = TraceLine( { start = S, endpos = E })
	
	return TraceToTable(Trace)
end)

-- Start, End, HitWater
E_A:RegisterFunction("trace", "vvn", "t", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	local S, E, M = Vector(A[1], A[2], A[3]), Vector(B[1], B[2], B[3])
	
	if C > 0 then M = MASK_WATER end
	local Trace = TraceLine( { start = S, endpos = E, mask = M })
	
	return TraceToTable(Trace)
end)

-- Start, End, HitWater, Filter
E_A:RegisterFunction("trace", "vvnt", "t", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, C, D = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	local S, E, M = Vector(A[1], A[2], A[3]), Vector(B[1], B[2], B[3])
	
	local Filter = {}
	if D.Data then
		for Key, Type in pairs( D.Types ) do
			if Type == "e" then Filter[#Filter + 1] = D.Data[Key] end
		end
	end
	
	if C > 0 then M = MASK_WATER end
	local Trace = TraceLine( { start = S, endpos = E, mask = M, filter = Filter })
	
	return TraceToTable(Trace)
end)

/**********************************************************************************************/

-- Start, End, Size
E_A:RegisterFunction("traceHull", "vvv", "t", function(self, ValueA, ValueB, ValueC)
	local A, B, C = ValueA(self), ValueB(self), ValueC(self)
	local S, E, O = Vector(A[1], A[2], A[3]), Vector(B[1], B[2], B[3]), Vector(C[1], C[2], C[3])
	
	local Min, Max = O / 2, -(O / 2)
	local Trace = TraceHull( { start = S, endpos = E, mins = Min, maxs = Max })
	
	return TraceToTable(Trace)
end)


-- Start, End, Size, HitWater
E_A:RegisterFunction("trace", "vvvn", "t", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, C, D = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	local S, E, O = Vector(A[1], A[2], A[3]), Vector(B[1], B[2], B[3]), Vector(C[1], C[2], C[3])
	
	if D > 0 then M = MASK_WATER end
	local Min, Max = O / 2, -(O / 2)
	local Trace = TraceHull( { start = S, endpos = E, mins = Min, maxs = Max, mask = M })
	
	return TraceToTable(Trace)
end)

-- Start, End, Size, HitWater, Filter
E_A:RegisterFunction("trace", "vvvnt", "t", function(self, ValueA, ValueB, ValueC, ValueD, ValueE)
	local A, B, C, D, E = ValueA(self), ValueB(self), ValueC(self), ValueD(self), ValueE(self)
	local S, E, O = Vector(A[1], A[2], A[3]), Vector(B[1], B[2], B[3]), Vector(C[1], C[2], C[3])
	
	local Filter = {}
	if E.Data then
		for Key, Type in pairs( E.Types ) do
			if Type == "e" then Filter[#Filter + 1] = E.Data[Key] end
		end
	end
	
	if D > 0 then M = MASK_WATER end
	local Min, Max = O / 2, -(O / 2)
	local Trace = TraceHull( { start = S, endpos = E, mins = Min, maxs = Max, mask = M, filter = Filter })
	
	return TraceToTable(Trace)
end)



