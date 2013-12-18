/*==============================================================================================
	CLIENT RESORCES
==============================================================================================*/
if SERVER then
	resource.AddWorkshop( "161770512" ) 
	
	AddCSLuaFile( )
	
	AddCSLuaFile( "includes/modules/von.lua" )
	AddCSLuaFile( "includes/modules/vector2.lua" )
	
	AddCSLuaFile( "lemongate/uploader2.lua" )
	AddCSLuaFile( "lemongate/core.lua" )
	AddCSLuaFile( "lemongate/compiler/tokenizer.lua" )
	AddCSLuaFile( "lemongate/compiler/parser.lua" )
	AddCSLuaFile( "lemongate/compiler/compiler.lua" )
	AddCSLuaFile( "lemongate/compiler/debugger.lua" )
	AddCSLuaFile( "lemongate/compiler/init.lua" )
	
	AddCSLuaFile( "lemongate/editor/ea_button.lua" )
	AddCSLuaFile( "lemongate/editor/ea_browser.lua" )
	AddCSLuaFile( "lemongate/editor/ea_closebutton.lua" )
	AddCSLuaFile( "lemongate/editor/ea_editor.lua" )
	AddCSLuaFile( "lemongate/editor/ea_editorpanel.lua" )
	AddCSLuaFile( "lemongate/editor/ea_filenode.lua" )
	AddCSLuaFile( "lemongate/editor/ea_frame.lua" )
	AddCSLuaFile( "lemongate/editor/ea_helper.lua" )
	AddCSLuaFile( "lemongate/editor/ea_helperdata.lua" )
	AddCSLuaFile( "lemongate/editor/ea_hscrollbar.lua" )
	AddCSLuaFile( "lemongate/editor/ea_imagebutton.lua" )
	AddCSLuaFile( "lemongate/editor/ea_toolbar.lua" )
	AddCSLuaFile( "lemongate/editor/syntaxer.lua" )
	AddCSLuaFile( "lemongate/editor/pastebin.lua" )
	AddCSLuaFile( "lemongate/editor/ea_search.lua" )
	AddCSLuaFile( "lemongate/editor/repo.lua" )
	AddCSLuaFile( "ea_version.lua" )
	
	AddCSLuaFile( "lemongate/editor.lua" )
	AddCSLuaFile( "lemongate/components/cl_files.lua" )
end

include( "lemongate/core.lua" )
include( "lemongate/uploader2.lua" )


