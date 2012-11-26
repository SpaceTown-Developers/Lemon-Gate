/*==============================================================================================
	Expression Advanced: Lemon Gate Extension Loader.
	Purpose: Loads extensions
	Author: Oskar
	Creditors: The creator(s) of the E2 extloader
==============================================================================================*/
local format = string.format -- Speed
local lower = string.lower
local included_files = {}

local function E_A_include( Name )
	included_files[ #included_files + 1 ] = lower( Name )
end

local function E_A_include_finalize()
	for _,Name in ipairs(included_files) do
		MsgN( Name, "\t", "ea/extensions/" .. Name )
		include( "ea/extensions/" .. Name )
	end
end


local fPath = "ea/extensions/"
for _, fName in pairs( file.Find( fPath .. "/*.lua", "LUA" ) ) do
	-- MsgN( fName )
	
	-- TODO: Add AddCSLuaFile 

	if fName:match( "^cl_" ) then
		MsgN( format("TODO: Send %q to client",fName) )
	elseif fName:match( "^sh_" ) then
		MsgN( format("TODO: Send and include %q to client",fName) )
		E_A_include( fName )
	else
		E_A_include( fName )
	end
end

E_A_include_finalize()