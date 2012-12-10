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
	
	AddCSLuaFile("lemongate.lua")
	AddCSLuaFile("ea/client.lua")
	
	AddCSLuaFile("ea/core/Tokenizer.lua")
	AddCSLuaFile("ea/core/Parser.lua")
	AddCSLuaFile("ea/core/Compiler.lua")
	
	AddCSLuaFile("ea/editor.lua")
	AddCSLuaFile("ea/uploader.lua")
end

/*==============================================================================================
	LOADER
==============================================================================================*/
function LemonGateLoad()
	LemonGate = nil
	
	if SERVER then
		include("ea/server.lua")
	else
		include("ea/client.lua")
		include("ea/editor.lua")
	end
	
	include("ea/core/tokenizer.lua")
	include("ea/core/parser.lua")
	include("ea/core/compiler.lua")
	include("ea/uploader.lua")
end; LemonGateLoad() -- Load it up!

/*==============================================================================================
	Reload Function
==============================================================================================*/
if CLIENT then return end

concommand.Add("lemon_reload", function()
	LemonGateLoad() -- Reload LemonGate!
	BroadcastLua("LemonGateLoad()")
end)