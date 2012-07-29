function LemonGate_Reload()
	MsgN( "Loading Expression-Advanced" )
	
	LemonGate = nil
	include("ea/core/Core.lua")
	include("ea/core/Tokenizer.lua")
	include("ea/core/Parser.lua")
	include("ea/core/Compiler.lua")

	include("ea/Util/ExtLoader.lua")
	include("ea/Util/Misc.lua")
	
	MsgN("E-A Loading Complete")
end

if SERVER then
	AddCSLuaFile("LemonGate.lua")
	
	AddCSLuaFile("ea/core/Core.lua")
	AddCSLuaFile("ea/core/Tokenizer.lua")
	AddCSLuaFile("ea/core/Parser.lua")
	AddCSLuaFile("ea/core/Compiler.lua")

	AddCSLuaFile("ea/Util/Misc.lua")
	
	concommand.Add("lemongate_reload", LemonGate_Reload)
end

LemonGate_Reload()