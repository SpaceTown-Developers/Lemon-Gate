/*==============================================================================================
	Expression Advanced: Awkward Programable Interface.
	Purpose: Allows Exts to do some cool stuff, (Eventually).
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API

local CheckType = E_A.CheckType -- Speed

/*==============================================================================================
	Section: API Hook Caller.
	Purpose: These hooks are used for stuff!.
	Creditors: Rusketh
==============================================================================================*/
local HookTable = {}

function API.AddHook(Hook, ID, Function)
	CheckType(Hook, "string", 1); CheckType(ID, "string", 2); CheckType(Function, "function", 3)
	
	local Table = HookTable[Hook]
	if !Table then
		Table = {}
		HookTable[Hook] = Table
	end
	
	Table[ID] = Function
end

function API.RemoveHook(Hook, ID)
	CheckType(Hook, "string", 1); CheckType(ID, "string", 2); CheckType(Function, "string", 3)
	
	local Table = HookTable[Hook]
	if Table then Table[ID] = nil end
end

function API.CallHook(Hook, ...)
	local Table = HookTable[Hook]
	
	if Table then
		for _,Function in pairs(Table) do -- Hate unpack so we have a max 26 return values!
			local A, B, C, D, E, F, H, H, I, J, K, L, M, N, O, P, Q, R, S ,T, U, V, W, X, Y, Z = Function(...)
			if A != nil then return A, B, C, D, E, F, H, H, I, J, K, L, M, N, O, P, Q, R, S ,T, U, V, W, X, Y, Z end
		end
	end
end

/*==============================================================================================
	SERVER ONLY API STUFF!
==============================================================================================*/
if CLIENT then return end

/*==============================================================================================
	Section: Entity Registry
	Purpose: Easily know what gates exist!.
	Creditors: Rusketh
==============================================================================================*/
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

