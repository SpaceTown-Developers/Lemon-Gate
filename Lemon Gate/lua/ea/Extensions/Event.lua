/*==============================================================================================
	Expression Advanced: Event Manager.
	Purpose: Events make E-A Tick (litteraly).
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local CheckType = E_A.CheckType -- Speed
local ValueToOp = E_A.ValueToOp

local pairs = pairs

/*==============================================================================================
	Section: Event Function.
	Purpose: Functions that Create and Remove events.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterOperator("event", "", "", function(self, Event, Memory, Statments)
	-- Purpose: Builds a Function.
	
	MsgN("Event Built " .. Event)
	self.Events[Event] = {Memory, Statments}
end)

/*==============================================================================================
	Section: API Event Caller.
	Purpose: Lets just randomly make some events.
	Creditors: Rusketh
==============================================================================================*/
local API = E_A.API

function API.CallEvent(Event, ...)
	CheckType(Event, "string", 1)
	
	MsgN("Gates:")
	PrintTable(E_A.GateEntitys)
	
	for _, Gate in pairs( E_A.GateEntitys ) do
		if Gate and Gate:IsValid() then
			MsgN("Calling Event for " .. tostring(Gate))
			Gate:CallEvent(Event, ...)
		end
	end
end

/*==============================================================================================
	Section: Events.
	Purpose: Some cool events.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterEvent("think")
E_A:RegisterEvent("final")

-- Called by LemonGate entity!

/**********************************************************************************************/

E_A:RegisterEvent("playerJoin","e")

hook.Add("PlayerInitialSpawn", "LemonGate", function(Player)
	API.CallEvent("playerJoin",ValueToOp(Player, "e"))
end)

/**********************************************************************************************/

E_A:RegisterEvent("playerQuit","e")

hook.Add("PlayerDisconnected", "LemonGate", function(Player)
	API.CallEvent("playerQuit", ValueToOp(Player, "e"))
end)

/**********************************************************************************************/

E_A:RegisterEvent("playerChat","es")

hook.Add("OnPlayerChat", "LemonGate", function(Player, Text)
	API.CallEvent("playerChat", ValueToOp(Player, "e"), ValueToOp(Text, "s"))
end)

