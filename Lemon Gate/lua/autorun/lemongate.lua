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
	    
	AddCSLuaFile("lemongate.lua")
	AddCSLuaFile("ea/client.lua")
	
	AddCSLuaFile("ea/core/Tokenizer.lua")
	AddCSLuaFile("ea/core/Parser.lua")
	AddCSLuaFile("ea/core/Compiler.lua")
	
	AddCSLuaFile("ea/uploader.lua")
    
	AddCSLuaFile("ea/editor.lua")
    AddCSLuaFile("ea/editor/EA_Button.lua")
    AddCSLuaFile("ea/editor/EA_CloseButton.lua")
    AddCSLuaFile("ea/editor/EA_Editor.lua")
    AddCSLuaFile("ea/editor/EA_EditorPanel.lua")
    AddCSLuaFile("ea/editor/EA_FileNode.lua")
    AddCSLuaFile("ea/editor/EA_Frame.lua")
    AddCSLuaFile("ea/editor/EA_ImageButton.lua")
    AddCSLuaFile("ea/editor/EA_ToolBar.lua")
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
        
        include("ea/editor/EA_Button.lua")
        include("ea/editor/EA_CloseButton.lua")
        include("ea/editor/EA_Editor.lua")
        include("ea/editor/EA_EditorPanel.lua")
        include("ea/editor/EA_FileNode.lua")
        include("ea/editor/EA_Frame.lua")
        include("ea/editor/EA_ImageButton.lua")
        include("ea/editor/EA_ToolBar.lua")
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