/*==============================================================================================
	Expression Advanced: Lemon Gate Extension Loader.
	Purpose: Loads extensions
	Author: Oskar
	Creditors: The creator(s) of the E2 extloader
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API

/*==============================================================================================
	Register Main Types, so they can interact!
==============================================================================================*/
E_A:RegisterClass("number", "n", 0)
E_A:RegisterClass("string", "s", "")
E_A:RegisterClass("entity", "e", Entity)
E_A:RegisterClass("table", "t", {})

/*==============================================================================================
	Load the main Extenshions!
==============================================================================================*/
include("Core.lua")
include("Number.lua")
include("String.lua")
include("Entity.lua")
include("Table.lua")
include("SelfAware.lua")
include("Function.lua")
include("Event.lua")

AddCSLuaFile("Exts.lua")
AddCSLuaFile("Core.lua")
AddCSLuaFile("Number.lua")
AddCSLuaFile("String.lua")
AddCSLuaFile("Entity.lua")
AddCSLuaFile("Table.lua")
AddCSLuaFile("SelfAware.lua")
AddCSLuaFile("Function.lua")
AddCSLuaFile("Event.lua")

API.CallHook("PostLoadMain")

/*==============================================================================================
	Load the custom Extenshions!
==============================================================================================*/
API.CallHook("PreLoadCustom")

for _, File in pairs( file.Find( "ea/extensions/custom/*.lua", "LUA" ) ) do
	if fName:match( "^cl_" ) then
		if SERVER then AddCSLuaFile(File) else include(File) end
	elseif fName:match( "^sv_" ) then
		if SERVER then include(File) end
	else
		if SERVER then AddCSLuaFile(File) end
		include(File)
	end
end

API.CallHook("PostLoadCustom")