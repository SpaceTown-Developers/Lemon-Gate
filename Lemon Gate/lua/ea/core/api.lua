/*==============================================================================================
	Expression Advanced: Awkward Programable Interface.
	Purpose: Allows Exts to do some cool stuff, (Eventually).
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API

local CheckType = E_A.CheckType

/*==============================================================================================
	Section: API Component Loader.
	Creditors: Rusketh
==============================================================================================*/
local LEMONGATE_COMPONENT = nil -- Needed!
local Comps = {}

function API.NewComponent(Name, Enabled)
	CheckType(Name, "string", 1); CheckType(Enabled, "boolean", 2)
	
	if Name == "" or Name == "core" then error("Invalid component name: " .. tostring(Name)) end
	Comps[Name] = Enabled; LEMONGATE_COMPONENT = Name
end

function API.Component(Name)
	return Comps[Name]
end

function API.CurrentComponent()
	if !LEMONGATE_COMPONENT then error("Expression Advanced: Uknown component\n\tHave you called API.NewComponent(Name) yet?") end
	return LEMONGATE_COMPONENT
end

/*==============================================================================================
	Section: API Hook Caller.
	Purpose: These hooks are used for stuff!.
	Creditors: Rusketh
==============================================================================================*/
local HookTable = {}

function API.AddHook(Hook, Function)
	CheckType(Hook, "string", 1); CheckType(Function, "function", 2)
	
	local Table = HookTable[Hook]
	if !Table then
		Table = {}
		HookTable[Hook] = Table
	end
	
	Table[LEMONGATE_COMPONENT] = Function
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
	Section: Component Loader
==============================================================================================*/
function API.LoadComponents()
	
	LEMONGATE_COMPONENT = "core" -- Prevents the core being modified
	Comps["core"] = true
	
	if SERVER then
		include("ea/components/core.lua")
		include("ea/components/number.lua")
		include("ea/components/string.lua")
		include("ea/components/vector.lua")
		include("ea/components/angle.lua")
		include("ea/components/entity.lua")
		include("ea/components/table.lua")
		include("ea/components/wirelink.lua")
		include("ea/components/selfaware.lua")
		include("ea/components/function.lua")
		include("ea/components/event.lua")
		include("ea/components/timers.lua")
	end
	
	MsgN("Expression Advanced: Loading Components!")
	
	API.CallHook("PreLoadComponents")

	for _, fName in pairs( file.Find( "ea/components/custom/*.lua", "LUA" ) ) do
		local File = "ea/components/" .. fName
		LEMONGATE_COMPONENT = nil
		
		if fName:match( "^cl_" ) then
			if SERVER then AddCSLuaFile(File) else include(File) end
		elseif fName:match( "^sh_" ) then
			if SERVER then AddCSLuaFile(File) end
			include(File)
		else
			if SERVER then include(File) end
		end
	end

	API.CallHook("PostLoadComponents")
	
	MsgN("Expression Advanced: Components Loaded!")
	
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

function API.AddGate(Entity)
	Entitys[ Entity ] = Entity
	API.CallHook("GateCreate", Entity)
end

function API.RemoveGate(Entity)
	Entitys[ Entity ] = nil
	API.CallHook("GateRemove", Entity)
end

function API.GetGates() return Entitys end

