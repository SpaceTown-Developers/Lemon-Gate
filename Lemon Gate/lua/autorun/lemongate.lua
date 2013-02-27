/*==============================================================================================
	CLIENT RESORCES
==============================================================================================*/
if SERVER then
	resource.AddFile( "models/mandrac/wire/e3.mdl" )
	resource.AddFile( "materials/mandrac/wire/e3.2323.vmt" )
	resource.AddFile( "materials/mandrac/wire/e3.vmt" )
	
    // Editor Textures
	resource.AddFile( "materials/fugue/blue-folder-horizontal-open.png" )
	resource.AddFile( "materials/fugue/blue-folder-horizontal.png" )
	resource.AddFile( "materials/fugue/cross-button.png" )
	resource.AddFile( "materials/fugue/disk.png" )
	resource.AddFile( "materials/fugue/disks.png" )
	resource.AddFile( "materials/fugue/gear.png" )
	resource.AddFile( "materials/fugue/question.png" )
	resource.AddFile( "materials/fugue/script--minus.png" )
	resource.AddFile( "materials/fugue/script--plus.png" )
	resource.AddFile( "materials/fugue/script-text.png" )
	resource.AddFile( "materials/fugue/toggle-small-expand.png" )
	resource.AddFile( "materials/fugue/toggle-small.png" )
	
	resource.AddFile( "materials/oskar/minus.png" )
	resource.AddFile( "materials/oskar/plus.png" )
	resource.AddFile( "materials/oskar/arrow-left.png" )
	resource.AddFile( "materials/oskar/arrow-right.png" )
	resource.AddFile( "materials/oskar/scrollthumb.png" )
	
	resource.AddFile( "material/spicol/arrow_sans_down_16.png" )
	resource.AddFile( "material/spicol/arrow_sans_up_16.png" )
	    
	AddCSLuaFile("lemongate.lua")
	AddCSLuaFile("ea/client.lua")
	
	AddCSLuaFile("ea/core/Tokenizer.lua")
	AddCSLuaFile("ea/core/Parser.lua")
	AddCSLuaFile("ea/core/Compiler.lua")
	
	AddCSLuaFile("ea/uploader.lua")
    
	AddCSLuaFile("ea/editor.lua")
	AddCSLuaFile("ea/editor/ea_button.lua")
	AddCSLuaFile("ea/editor/ea_closebutton.lua")
	AddCSLuaFile("ea/editor/ea_editor.lua")
	AddCSLuaFile("ea/editor/ea_editorpanel.lua")
	AddCSLuaFile("ea/editor/ea_filenode.lua")
	AddCSLuaFile("ea/editor/ea_frame.lua")
	AddCSLuaFile("ea/editor/ea_imagebutton.lua")
	AddCSLuaFile("ea/editor/ea_toolbar.lua")
	AddCSLuaFile("ea/editor/syntaxer.lua")
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
        
        include("ea/editor/ea_button.lua")
        include("ea/editor/ea_closebutton.lua")
        include("ea/editor/ea_editor.lua")
        include("ea/editor/ea_editorpanel.lua")
        include("ea/editor/ea_filenode.lua")
        include("ea/editor/ea_frame.lua")
        include("ea/editor/ea_imagebutton.lua")
        include("ea/editor/ea_toolbar.lua")
        include("ea/editor/syntaxer.lua")
        
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