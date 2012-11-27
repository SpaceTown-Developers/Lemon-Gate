/*==============================================================================================
	Expression Advanced: Awkward Programable Interface.
	Purpose: Allows Exts to do some cool stuff, (Eventually).
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API

local CheckType = E_A.CheckType -- Speed

/*==============================================================================================
	Section: Entity Registry
	Purpose: Easily know what gates exist!.
	Creditors: Rusketh
==============================================================================================*/
if SERVER then
	local Entitys = {}
	
	API.Entitys = Entitys

	function API.AddGate(Entity) Entitys[ Entity:EntIndex() ] = Entity:EntIndex() end

	function API.RemoveGate(Entity) Entitys[ Entity:EntIndex() ] = nil end

	function API.GetGates() return Entitys end

/*==============================================================================================
	Section: API Event Caller.
	Purpose: Lets just randomly make some events.
	Creditors: Rusketh
==============================================================================================*/
	function API.CallEvent(Event, ...)
		CheckType(Event, "string", 1)
		
		for _, Indx in pairs( Entitys ) do
			local Entity = Entity(Indx)
			
			if Entity and Entity:IsValid() then
				Entity:CallEvent(Event, ...)
			end
		end
	end
end