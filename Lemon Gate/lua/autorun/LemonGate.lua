function LemonGate_Reload()
	MsgN( "Loading Expression-Advanced" )
	
	LemonGate = nil
	include("ea/core/Core.lua")
	include("ea/core/Tokenizer.lua")
	include("ea/core/Parser.lua")
	include("ea/core/Compiler.lua")
	include("ea/Core/API.lua")
	
	include("ea/Extensions/Exts.lua")
	
	include("ea/Util/Misc.lua")
	
	if CLIENT then include("ea/Editor.lua") end
	
	MsgN("E-A Loading Complete!")
end

if SERVER then
	
	AddCSLuaFile("LemonGate.lua")
	
	AddCSLuaFile("ea/core/Core.lua")
	AddCSLuaFile("ea/core/Tokenizer.lua")
	AddCSLuaFile("ea/core/Parser.lua")
	AddCSLuaFile("ea/core/Compiler.lua")
	AddCSLuaFile("ea/core/API.lua")
	
	AddCSLuaFile("ea/Editor.lua")
	AddCSLuaFile("ea/Util/Misc.lua")
	
	-- AddCSLuaFile("ea/Util/cl_Derma.lua")
	-- AddCSLuaFile("ea/Editor/EA_Button.lua")
	-- AddCSLuaFile("ea/Editor/EA_CloseButton.lua")
	-- AddCSLuaFile("ea/Editor/EA_Editor.lua")
	-- AddCSLuaFile("ea/Editor/EA_EditorPanel.lua")
	-- AddCSLuaFile("ea/Editor/EA_FileBrowser.lua")
	-- AddCSLuaFile("ea/Editor/EA_FileNode.lua")
	-- AddCSLuaFile("ea/Editor/EA_Frame.lua")
	-- AddCSLuaFile("ea/Editor/EA_Toolbar.lua")

	concommand.Add("lemongate_reload", LemonGate_Reload)
	
	-- Add Resources!
		resource.AddFile( "models/mandrac/wire/e3.mdl" )
		resource.AddFile( "materials/mandrac/wire/e3.2323.vmt" )
		resource.AddFile( "materials/mandrac/wire/e3.vmt" )
		resource.AddFile( "materials/fugue/blue-folder-horizontal.vmt" )
		resource.AddFile( "materials/fugue/magnifier.vmt" )
		resource.AddFile( "materials/fugue/minus-circle.vmt" )
		resource.AddFile( "materials/fugue/plus-circle.vmt" )
		resource.AddFile( "materials/fugue/script-text.vmt" )
		resource.AddFile( "materials/fugue/24/cross-circle.vmt" )
else 
	-- include("ea/Editor/EA_Button.lua")
	-- include("ea/Editor/EA_CloseButton.lua")
	-- include("ea/Editor/EA_Editor.lua")
	-- include("ea/Editor/EA_EditorPanel.lua")
	-- include("ea/Editor/EA_FileBrowser.lua")
	-- include("ea/Editor/EA_FileNode.lua")
	-- include("ea/Editor/EA_Frame.lua")
	-- include("ea/Editor/EA_Toolbar.lua")
	-- include("ea/Util/cl_Derma.lua")
end

LemonGate_Reload()function LemonGate_Reload()
	MsgN( "Loading Expression-Advanced" )
	
	LemonGate = nil
	include("ea/core/Core.lua")
	include("ea/core/Tokenizer.lua")
	include("ea/core/Parser.lua")
	include("ea/core/Compiler.lua")
	include("ea/Core/API.lua")
	
	include("ea/Extensions/Exts.lua")
	
	include("ea/Util/Misc.lua")
	
	if CLIENT then include("ea/Editor.lua") end
	
	MsgN("E-A Loading Complete!")
end

if SERVER then
	
	AddCSLuaFile("LemonGate.lua")
	
	AddCSLuaFile("ea/core/Core.lua")
	AddCSLuaFile("ea/core/Tokenizer.lua")
	AddCSLuaFile("ea/core/Parser.lua")
	AddCSLuaFile("ea/core/Compiler.lua")
	AddCSLuaFile("ea/core/API.lua")
	
	AddCSLuaFile("ea/Editor.lua")
	AddCSLuaFile("ea/Util/Misc.lua")
	
	-- AddCSLuaFile("ea/Util/cl_Derma.lua")
	-- AddCSLuaFile("ea/Editor/EA_Button.lua")
	-- AddCSLuaFile("ea/Editor/EA_CloseButton.lua")
	-- AddCSLuaFile("ea/Editor/EA_Editor.lua")
	-- AddCSLuaFile("ea/Editor/EA_EditorPanel.lua")
	-- AddCSLuaFile("ea/Editor/EA_FileBrowser.lua")
	-- AddCSLuaFile("ea/Editor/EA_FileNode.lua")
	-- AddCSLuaFile("ea/Editor/EA_Frame.lua")
	-- AddCSLuaFile("ea/Editor/EA_Toolbar.lua")

	concommand.Add("lemongate_reload", LemonGate_Reload)
	
	-- Add Resources!
		resource.AddFile( "models/mandrac/wire/e3.mdl" )
		resource.AddFile( "materials/mandrac/wire/e3.2323.vmt" )
		resource.AddFile( "materials/mandrac/wire/e3.vmt" )
		resource.AddFile( "materials/fugue/blue-folder-horizontal.vmt" )
		resource.AddFile( "materials/fugue/magnifier.vmt" )
		resource.AddFile( "materials/fugue/minus-circle.vmt" )
		resource.AddFile( "materials/fugue/plus-circle.vmt" )
		resource.AddFile( "materials/fugue/script-text.vmt" )
		resource.AddFile( "materials/fugue/24/cross-circle.vmt" )
else 
	-- include("ea/Editor/EA_Button.lua")
	-- include("ea/Editor/EA_CloseButton.lua")
	-- include("ea/Editor/EA_Editor.lua")
	-- include("ea/Editor/EA_EditorPanel.lua")
	-- include("ea/Editor/EA_FileBrowser.lua")
	-- include("ea/Editor/EA_FileNode.lua")
	-- include("ea/Editor/EA_Frame.lua")
	-- include("ea/Editor/EA_Toolbar.lua")
	-- include("ea/Util/cl_Derma.lua")
end

LemonGate_Reload()