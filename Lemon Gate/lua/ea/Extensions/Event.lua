/*==============================================================================================
	Expression Advanced: Event Manager.
	Purpose: Events make E-A Tick (litteraly).
	Creditors: Rusketh
==============================================================================================*/

local E_A = LemonGate

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
function E_A.API.CallEvent(Name, Perams, ...)
	CheckType(1, "string", Name); CheckType(2, "string", Perams, true)
	
	for _, Gate in pairs(FindAll("lemongate")) do
		Gate:CallEvent(Name, Perams, ...)
	end
end

