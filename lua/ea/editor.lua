/*---------------------------------------------------------------------------
	Expression Advanced: Editor.
	Purpose: Make the fancy EA editor.
	Author: Oskar 
---------------------------------------------------------------------------*/
local EA = LemonGate

EA.Editor = {}
local Editor = EA.Editor

timer.Simple( 0.5, function() 
	RunConsoleCommand( "lemon_sync" ) 
end )

/*---------------------------------------------------------------------------
Vector2 class
Author: Oskar
---------------------------------------------------------------------------*/
do  
	local meta = {} 
	meta.__index = meta 
 
	function meta:__add( other ) 
		return Vector2( self.x + other.x, self.y + other.y ) 
	end 
 
	function meta:__sub( other ) 
		return Vector2( self.x - other.x, self.y - other.y ) 
	end 
 
	function meta:__mul( other ) 
		return Vector2( self.x * other, self.y * other ) 
	end 

	function meta:__div( other ) 
		return Vector2( self.x / other, self.y / other ) 
	end 

	//__mod 
	//__pow 
 
	function meta:__unm( ) 
		return self * -1  
	end 
 
	function meta:__len( ) 
		return math.sqrt( self.x * self.x + self.y * self.y ) 
	end 
 
	function meta:__eq( other ) 
		return self.x == other.x and self.y == other.y 
	end 
 
	function meta:__lt( other ) 
		return self.x < other.x and self.y < other.y 
	end 
 
	function meta:__le( other ) 
		return self.x <= other.x and self.y <= other.y 
	end 
 
	function meta:__call( x, y ) 
		return self.x + (x or 0), self.y + (y or 0) 
	end 
 
	function meta:__tostring( ) 
		return "Vector2: " .. self.x .. " " .. self.y 
	end 
 
	function meta:Set( x, y ) 
		self.x = x 
		self.y = y 
		return self 
	end 

	function meta:Add( x, y ) 
		self.x = self.x + x 
		self.y = self.y + y 
		return self 
	end 
	
	function meta:Sub( x, y )
		self.x = self.x - x 
		self.y = self.y - y 
		return self 
	end 
	
	function meta:Clone( )
		return Vector2( self.x, self.y )
	end

	local setmetatable = setmetatable 
	local Vec2 = { Zero = { x = 0, y = 0 } } 
	Vec2.__index = Vec2 
 
	function Vec2:Dot( other ) 
		return self.x * other.x + self.y * other.y 
	end 

	function Vec2:Normalize( ) 
		return self * ( 1 / #self ) 
	end 

	function Vec2:Round( dec ) 
		return Vector2( math.Round( self.x, dec ), math.Round( self.y, dec ), math.Round( self.z, dec ) ) 
	end 

	function Vec2:Length( ) 
		return math.sqrt( self.x * self.x + self.y * self.y ) 
	end 

	function Vec2:__call( a, b ) 
		return setmetatable({x = a or 0, y = b or 0}, meta) 
	end 

	Vector2 = {} 
	setmetatable( Vector2, Vec2 ) 
end 

/*---------------------------------------------------------------------------
	Custom fonts
---------------------------------------------------------------------------*/

timer.Simple( 0.5, function()
	surface.CreateFont( "Fixedsys", {
        font 		= "Fixedsys",
        size 		= 13,
        weight 		= 400,
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
        outline 	= false, 
    } )
    
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
local HomeScreen = [[/*===================================================
    Expression Advanced Beta
    - Rusketh, Oskar94, Divran, Syranide, Jerwuqu
    
    For documentation and help visit out wiki.
    Wiki: https://github.com/SpaceTown-Developers/Lemon-Gate/wiki
    
    There are bugs you will find them, there are also ideas and you will have them.
    When you do please post them on your bug tracker to help development.
    Bug Tracker: https://github.com/SpaceTown-Developers/Lemon-Gate/issues
    
    Latest Updates:
    * Editor bookmarks ( ctrl+b to toggle, ctrl+shift+b to jump to next bookmark )
    * File library.
    * HTTP library.
    * Changed sound library.
    * Changed function decelerations.
    * Variants auto cast on assignment.
    
    Thank you for taking part in this Beta!
===================================================*/
]]

/*---------------------------------------------------------------------------
	Syntax Highlighting
---------------------------------------------------------------------------*/
local function SyntaxColorLine( self, Row ) 
	local Tokens, Ok 
	
	Ok, Tokens = pcall( Syntax.Parse, self, Row )
	
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
	
	-- Instance:SetSize( 1000, 800 )
	Instance:SetSize( math.min( 1000, ScrW() * 0.8 ), math.min( 800, ScrH() * 0.8 ) )
	Instance:Center()
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

function Editor.GetInstance()
	Editor.Create()
	return Editor.Instance
end

function Editor.Validate()
	if Editor.Instance then
		return Editor.Instance:Validate( Editor.Instance:GetCode( ), nil )
	end
end