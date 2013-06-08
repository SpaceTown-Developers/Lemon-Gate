/*---------------------------------------------------------------------------
	Expression Advanced: Editor.
	Purpose: Make the fancy EA editor.
	Author: Oskar 
---------------------------------------------------------------------------*/
local EA = LEMON

EA.Editor = {}
local Editor = EA.Editor

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
	Expression Advanced:
		Running Tequila (alpha):
			* Single stage native Lua compiler.
			* Added booleans (true / false)
			* Added Include( String File, Boolean Scoped )
			* Added while loops.
		
	Docs: https://github.com/SpaceTown-Developers/Lemon-Gate/wiki (Out dated)
	Bug Reports: https://github.com/SpaceTown-Developers/Lemon-Gate/issues
		
	Credits: Rusketh, Oskar94, Divran, Syranide.
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