/*==============================================================================================
	CLIENT RESORCES
==============================================================================================*/
if SERVER then
	resource.AddWorkshop( "161770512" ) 
	
	resource.AddFile( "materials/mandrac/wire/e3.2323.vmt" )
	resource.AddFile( "materials/mandrac/wire/e3.vmt" )
	resource.AddFile( "models/mandrac/wire/e3.mdl" )
	
	resource.AddFile( "materials/omicron/lemongear.vmt" )
	resource.AddFile( "materials/omicron/lemongear.vtf" )
	resource.AddFile( "models/shadowscion/lemongate/gate.mdl" )
	
	// Editor Textures
	resource.AddFile( "materials/fugue/block.png" )
	resource.AddFile( "materials/fugue/blue-folder-horizontal-open.png" )
	resource.AddFile( "materials/fugue/blue-folder-horizontal.png" )
	resource.AddFile( "materials/fugue/cross-button.png" )
	resource.AddFile( "materials/fugue/disk.png" )
	resource.AddFile( "materials/fugue/disks.png" )
	resource.AddFile( "materials/fugue/gear.png" )
	resource.AddFile( "materials/fugue/home.png" )
	resource.AddFile( "materials/fugue/magnifier.png" )
	resource.AddFile( "materials/fugue/question.png" )
	resource.AddFile( "materials/fugue/script--minus.png" )
	resource.AddFile( "materials/fugue/script--plus.png" )
	resource.AddFile( "materials/fugue/script-text.png" )
	resource.AddFile( "materials/fugue/script.png" )
	resource.AddFile( "materials/fugue/toggle-small-expand.png" )
	resource.AddFile( "materials/fugue/toggle-small.png" )
	resource.AddFile( "materials/fugue/toggle-small.png" )
	
	resource.AddFile( "materials/diagona-icons/152.png" )
	
	resource.AddFile( "materials/oskar/minus.png" )
	resource.AddFile( "materials/oskar/plus.png" )
	resource.AddFile( "materials/oskar/arrow-left.png" )
	resource.AddFile( "materials/oskar/arrow-right.png" )
	resource.AddFile( "materials/oskar/scrollthumb.png" )
	
	resource.AddFile( "materials/picol/arrow_sans_down_16.png" )
	resource.AddFile( "materials/picol/arrow_sans_up_16.png" )
	
	resource.AddFile( "materials/github.png" )
	
		
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
	AddCSLuaFile( "lemongate/editor/repo.lua" )
	AddCSLuaFile( "ea_version.lua" )
	
	AddCSLuaFile( "lemongate/editor.lua" )
end

include( "lemongate/core.lua" )
include( "lemongate/uploader2.lua" )


