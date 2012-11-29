/*==============================================================================================
	Expression Advanced: Lemon Gate Extension Loader.
	Purpose: Loads extensions
	Author: Oskar
	Creditors: The creator(s) of the E2 extloader
==============================================================================================*/
local E_A = LemonGate

-- Register the main types so exts can use them early!
E_A:RegisterClass("number", "n", 0)
E_A:RegisterClass("string", "s", "")
E_A:RegisterClass("entity", "e", Entity)
E_A:RegisterClass("table", "t", {})

-- Load the Exts!
include("Core.lua")
include("Number.lua")
include("String.lua")
include("Entity.lua")
include("Table.lua")
include("Function.lua")
include("Event.lua")

-- ClientSide the files!
AddCSLuaFile("Exts.lua")
AddCSLuaFile("Core.lua")
AddCSLuaFile("Number.lua")
AddCSLuaFile("String.lua")
AddCSLuaFile("Entity.lua")
AddCSLuaFile("Table.lua")
AddCSLuaFile("Function.lua")
AddCSLuaFile("Event.lua")

-- Load Custom Exts
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

-- Todo: API HOOK!