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

E_A:RegisterFunction("addEvent", "snf", "", function(self, ValueA, ValueB, ValueC)
	local Event = ValueA(self)
	local Events = self.Events[Event]
	
	if !Events then
		Events = {}
		self.Events[Event] = Events
	end -- Note: If it did not have an events table then it does now.
	
	Events[ValueB(self)] = ValueC -- Note: We have added an Event =D
	print(Event,ValueC)
end)

E_A:RegisterFunction("removeEvent", "sn", "", function(self, ValueA, ValueB)
	local Events = self.Events[ValueA(self)]
	if Events then Events[ValueB(self)] = nil end
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

