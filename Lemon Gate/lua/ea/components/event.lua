/*==============================================================================================
	Expression Advanced: Event Manager.
	Purpose: Events make E-A Tick (literary).
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local API = E_A.API

local pairs = pairs
local Entity = Entity

/*==============================================================================================
	Section: Event Function.
	Purpose: Functions that Create and Remove events.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("event", "", "", function(self, Event, Arguments, Statements)
	-- Purpose: Builds a Function.
	
	self.Events[Event] = {Arguments, Statements}
end)

/*==============================================================================================
	Section: Entity events.
==============================================================================================*/
E_A:RegisterEvent("think")
E_A:RegisterEvent("final")
E_A:RegisterEvent("trigger", "s")

/*==============================================================================================
	Section: Tick Event
==============================================================================================*/
E_A:RegisterEvent("tick")

hook.Add("Tick", "LemonGate", function()
	for _, Entity in pairs( API.GetGates() ) do
		if Entity:IsValid() then
			Entity:CallEvent("tick")
		end
	end
end)

/*==============================================================================================
	Section: Player Join/Leave Event
==============================================================================================*/
E_A:RegisterEvent("playerJoin","e")

hook.Add("PlayerInitialSpawn", "LemonGate", function(Player)
	for _, Entity in pairs( API.GetGates() ) do
		if Entity:IsValid() then
			Entity:CallEvent("playerJoin", E_A.ValueToOp(Player, "e"))
		end
	end
end)

E_A:RegisterEvent("playerQuit","e")

hook.Add("PlayerDisconnected", "LemonGate", function(Player)
	for _, Entity in pairs( API.GetGates() ) do
		if Entity:IsValid() then
			Entity:CallEvent("playerQuit", E_A.ValueToOp(Player, "e"))
		end
	end
end)

/*==============================================================================================
	Section: Player Chat event.
==============================================================================================*/
E_A:RegisterEvent("playerChat","es","s")

hook.Add("PlayerSay", "LemonGate", function(Player, Text)
	for _, Entity in pairs( API.GetGates() ) do
		if Entity:IsValid() then
			local Result = Entity:CallEvent("playerChat", E_A.ValueToOp(Player, "e"), E_A.ValueToOp(Text, "s"))
			if Result and Player == Entity.Player then return Result end
		end
	end
end)

