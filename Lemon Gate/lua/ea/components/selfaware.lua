/*==============================================================================================
	Section: Self Aware
	Purpose: Basic operations.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local MathCeil = math.ceil
local GetConVarNumber = GetConVarNumber

/*==============================================================================================
	Section: Gate and Owner
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("gate", "", "e", function(self)
	return self.Entity
end)

E_A:RegisterFunction("owner", "", "e", function(self)
	return self.Player
end)

E_A:RegisterFunction("selfDestruct", "", "", function(self, Value)
	self.Entity:Remove()
end)

/*==============================================================================================
	Section: Gate Name
==============================================================================================*/

E_A:RegisterFunction("gateName", "", "s", function(self)
	return self.Entity.GateName
end)

E_A:RegisterFunction("gateName", "s", "", function(self, Value)
	self.Entity:SetGateName( Value(self) )
end)

/*==============================================================================================
	Section: Perf
==============================================================================================*/
E_A:RegisterFunction("perf", "", "n", function(self)
	return self.Perf
end)

E_A:RegisterFunction("perfAvailable", "", "n", function(self)
	return GetConVarNumber("lemongate_perf") - self.Perf
end)

E_A:RegisterFunction("maxPerf", "", "n", function(self)
	return GetConVarNumber("lemongate_perf")
end)

E_A:RegisterFunction("perfPer", "", "n", function(self)
	local Perf, MaxPerf = self.Perf, GetConVarNumber("lemongate_perf")
	
	if Perf <= 0 or MaxPerf <= 0 then return 0 end
	
	return MathCeil((Perf / MaxPerf) * 100)
end)

