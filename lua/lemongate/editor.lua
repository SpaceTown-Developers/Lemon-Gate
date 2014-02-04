/*---------------------------------------------------------------------------
	Expression Advanced: Editor.
	Purpose: Make the fancy EA editor.
	Author: Oskar 
---------------------------------------------------------------------------*/
local LEMON = LEMON

LEMON.Editor = { }
local Editor = LEMON.Editor

require( "vector2" )
/*---------------------------------------------------------------------------
	Custom fonts
---------------------------------------------------------------------------*/

timer.Simple( 0.5, function()
	surface.CreateFont( "Trebuchet22", {
		font 		= "Trebuchet MS",
		size 		= 22,
		weight 		= 900,
		blursize 	= 0,
		scanlines 	= 0,
		antialias 	= true,
		underline 	= false,
		italic 		= false,
		strikeout 	= false,
		symbol 		= false,
		rotary 		= false,
		shadow 		= false,
		additive 	= false,
		outline 	= false
	} )

	surface.CreateFont( "Trebuchet20", {
		font 		= "Trebuchet MS",
		size 		= 20,
		weight 		= 900,
		blursize 	= 0,
		scanlines 	= 0,
		antialias 	= false,
		underline 	= false,
		italic 		= false,
		strikeout 	= false,
		symbol 		= false,
		rotary 		= false,
		shadow 		= false,
		additive 	= false,
		outline 	= false
	} )
end ) 

/*---------------------------------------------------------------------------
	Home Screen
---------------------------------------------------------------------------*/
local HomeScreen = [[/*====================================================================
	Expression Advanced:
		* variables?
		* Con-commands added!
		* Trig functions fixed!
		* File functions are back!
		* Ops rebalance in progress.
		* Check out our new repo browser!
	
	Editor Changes:
		* New Open/Save menu.
		* Script Name Changer (not file name).
		* Find in code, *prototype* (ctrl + f).
		* Bookmark keys (f2 and ctrl + f2 )
		* Pastebin.com uploader.
		* You can now change editor font in the options menu.
		
	Check Out Video Tutorials:
		* https://www.youtube.com/watch?v=GzNsCWORiRw
		* http://www.youtube.com/watch?v=1fPyhSEa2EI
	
	Please Share Your Gates:
	 - http://www.wiremod.com/forum/wiremod-addons-coding/32173-lemon-gate-thread.html
	
	Check Our Wiki For Help:
	 - https://github.com/SpaceTown-Developers/Lemon-Gate/wiki
		
	Also Report Bugs:
	 - https://github.com/SpaceTown-Developers/Lemon-Gate/issues
	
	Credits: Rusketh, Oskar94, Divran, Syranide.
====================================================================*/
]]

/*---------------------------------------------------------------------------
	Syntax Highlighting
---------------------------------------------------------------------------*/
local function SyntaxColorLine( self, Row ) 
	local Tokens, Ok 
	
	Ok, Tokens = pcall( LEMON.Highlight, self, Row )
	
	if !Ok then 
		ErrorNoHalt( Tokens .. "\n" )
		Tokens = {{self.Rows[Row], Color(255,255,255)}} 
	end 
	
	return Tokens 
end


/*---------------------------------------------------------------------------
	Editor Functions
---------------------------------------------------------------------------*/ 
function Editor.Create( )
	if Editor.Instance then return end 
	
	file.CreateDir("lemongate")
	
	local Instance = vgui.Create( "EA_EditorPanel" ) 
	
	function Instance:OnTabCreated( Tab, Code, Path ) 
		if Code or Path then return false end 
		local Editor = Tab:GetPanel( ) 
		Editor:SetCode( HomeScreen ) 
		Editor.Caret = Vector2( #Editor.Rows, #Editor.Rows[#Editor.Rows] + 1 ) 
		Editor.Start = Vector2( 1, 1 ) 
		return true 
	end
	
	Instance:SetSyntaxColorLine( SyntaxColorLine ) 
	
	Instance:SetKeyBoardInputEnabled( true )
	Instance:SetVisible( false ) 
	
	Editor.Instance = Instance 
end

function Editor.Open( Code, NewTab )
	Editor.Create( ) 
	Editor.Instance:Open( Code, NewTab ) 
end

function Editor.NewTab( Script, FilePath )
	Editor.Create( ) 
	Editor.Instance:NewTab( Script, FilePath ) 
end

function Editor.GetCode( )
	if Editor.Instance then 
		return Editor.Instance:GetCode( ) 
	end 
end

function Editor.GetInstance( )
	Editor.Create( )
	return Editor.Instance
end

function Editor.ReciveDownload( Download )
	Editor.Create( ) 
	Editor.Instance:ReciveDownload( Download )
end

function Editor.Validate( Script )
	if Editor.Instance then
		return Editor.Instance:DoValidate( nil, nil, Script )
	end
end