/*==============================================================================================
	CLIENT RESORCES
==============================================================================================*/
if SERVER then
	resource.AddFile( "models/mandrac/wire/e3.mdl" )
	resource.AddFile( "materials/mandrac/wire/e3.2323.vmt" )
	resource.AddFile( "materials/mandrac/wire/e3.vmt" )
	resource.AddFile( "materials/fugue/blue-folder-horizontal.vmt" )
	resource.AddFile( "materials/fugue/magnifier.vmt" )
	resource.AddFile( "materials/fugue/minus-circle.vmt" )
	resource.AddFile( "materials/fugue/plus-circle.vmt" )
	resource.AddFile( "materials/fugue/script-text.vmt" )
	resource.AddFile( "materials/fugue/24/cross-circle.vmt" )
	
	AddCSLuaFile("LemonGate.lua")
	AddCSLuaFile("ea/Client.lua")
	
	AddCSLuaFile("ea/core/Tokenizer.lua")
	AddCSLuaFile("ea/core/Parser.lua")
	AddCSLuaFile("ea/core/Compiler.lua")
	
	AddCSLuaFile("ea/Editor.lua")
	AddCSLuaFile("ea/Uploader.lua")
end

/*==============================================================================================
	LOADER
==============================================================================================*/
function LemonGateLoad()
	LemonGate = nil
	
	if SERVER then
		include("ea/Server.lua")
	else
		include("ea/Client.lua")
		include("ea/Editor.lua")
	end
	
	include("ea/core/Tokenizer.lua")
	include("ea/core/Parser.lua")
	include("ea/core/Compiler.lua")
	include("ea/Uploader.lua")
end; LemonGateLoad() -- Load it up!

/*==============================================================================================
	Reload Function
==============================================================================================*/
if CLIENT then return end

concommand.Add("lemon_reload", function()
	LemonGateLoad() -- Reload LemonGate!
	BroadcastLua("LemonGateLoad()")
end)