/*==============================================================================================
	Expression Advanced: Event Manager.
	Purpose: Events make E-A Tick (litteraly).
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local ValueToOp = E_A.ValueToOp -- Speed

local pairs = pairs
local Entity = Entity

/*==============================================================================================
	Section: Events.
	Purpose: Register the avalible events.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterEvent("think")
E_A:RegisterEvent("tick")
E_A:RegisterEvent("final")
E_A:RegisterEvent("playerJoin","e")
E_A:RegisterEvent("playerQuit","e")
E_A:RegisterEvent("playerChat","es")

/*==============================================================================================
	Section: Event Function.
	Purpose: Functions that Create and Remove events.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("event", "", "", function(self, Event, Memory, Statments)
	-- Purpose: Builds a Function.
	
	self.Events[Event] = {Memory, Statments}
end)

/*==============================================================================================
	Section: Event Hooks.
	Purpose: Some cool events.
	Creditors: Rusketh
==============================================================================================*/
if CLIENT then return end
local API = E_A.API

hook.Add("Tick", "LemonGate", function(Player)
	API.CallEvent("tick")
end)

hook.Add("PlayerInitialSpawn", "LemonGate", function(Player)
	API.CallEvent("playerJoin",ValueToOp(Player, "e"))
end)

hook.Add("PlayerDisconnected", "LemonGate", function(Player)
	API.CallEvent("playerQuit", ValueToOp(Player, "e"))
end)

hook.Add("PlayerSay", "LemonGate", function(Player, Text)
	API.CallEvent("playerChat", ValueToOp(Player, "e"), ValueToOp(Text, "s"))
end)

