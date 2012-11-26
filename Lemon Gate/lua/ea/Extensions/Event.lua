/*==============================================================================================
	Expression Advanced: Event Manager.
	Purpose: Events make E-A Tick (litteraly).
	Creditors: Rusketh
==============================================================================================*/

local E_A = LemonGate

local CheckType = E_A.CheckType -- Speed

local pairs = pairs
local FindAll = ents.FindByClass

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
	Section: API Event Caller.
	Purpose: Lets just randomly make some events.
	Creditors: Rusketh
==============================================================================================*/
local API = E_A.API
function API.CallEvent(Name, ...)
	CheckType(Name, "string", 1)
	
	for _, Gate in pairs(FindAll("lemongate")) do
		Gate:CallEvent(Name, ...)
	end
end

/*==============================================================================================
	Section: Events.
	Purpose: Some cool events.
	Creditors: Rusketh
==============================================================================================*/
E_A:RegisterEvent("think")

-- Called by LemonGate entity!

/**********************************************************************************************/

E_A:RegisterEvent("playerJoin","e")

hook.Add("PlayerInitialSpawn", "LemonGate", function(Player)
	API.CallEvent("playerJoin", function() return Player, "e" end)
end)

/**********************************************************************************************/

E_A:RegisterEvent("playerQuit","e")

hook.Add("PlayerDisconnected", "LemonGate", function(Player)
	API.CallEvent("playerQuit", function() return Player, "e" end)
end)

/**********************************************************************************************/

E_A:RegisterEvent("playerChat","es")

hook.Add("OnPlayerChat", "LemonGate", function(Player, Text)
	API.CallEvent("playerChat",
		function() return Player, "e" end,
		function() return Text, "s" end)
end)

