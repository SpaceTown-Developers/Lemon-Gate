/*============================================================================================================================================
	Expression-Advanced Syntax Highlighting
	Autor: Oskar
	Credits: The authors of the E2 syntax highlighter 
============================================================================================================================================*/
local LEMON, API = LEMON, LEMON.API

/********************************************************************************************************************************************/

LEMON.Syntaxer = LEMON.Syntaxer or { First = true } 
local Syntaxer = LEMON.Syntaxer 

/********************************************************************************************************************************************/

local tonumber, pairs, Color = tonumber, pairs, Color 

local table_concat = table.concat 
local string_find = string.find 
local string_gmatch = string.gmatch 
local string_gsub = string.gsub 
local string_match = string.match 
local string_sub = string.sub 

-- local RawTokens = LEMON.Compiler.RawTokens

/*============================================================================================================================================
	Build Syntaxer Tables
============================================================================================================================================*/
function Syntaxer:BuildFunctionTable( )
	local Functions = { }
	
	for Name, Data in pairs( API.Functions ) do 
		local Func = string_match( Name, "^[^%(]+" ) 
		Functions[Func] = true 
	end 
	
	Functions["include"] = true 
	Functions["print"] = true 
	
	self.Functions = Functions
end

function Syntaxer:BuildEventsTable( )
	local Events = { }
	
	for Name, Data in pairs( API.Events ) do 
		local Func = string_match( Name, "^[^%(]+" ) 
		Events[Func] = true 
	end 
	
	self.Events = Events
end

function Syntaxer:BuildTokensTable( ) 
	local Tokens = { } 
	
	for k,v in pairs( LEMON.Compiler.RawTokens ) do
		Tokens[#Tokens+1] = string_gsub( v[1], "[%-%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1" )
	end
	
	self.Tokens = Tokens 
end 

function Syntaxer.Rebuild( )
	if API.Initialized then
		Syntaxer:BuildFunctionTable( )
		Syntaxer:BuildEventsTable( )
		Syntaxer:BuildTokensTable( )
		Syntaxer.UserFunctions = { } 
		Syntaxer.Variables = { } 
		Syntaxer.MetaMethods = { } 
	end
end

Syntaxer.Rebuild( ) -- For the editor reload command
hook.Add( "LemonGate_PostInit", "LemonGate.Syntaxer", Syntaxer.Rebuild )

/*============================================================================================================================================
	Syntaxer Functions
============================================================================================================================================*/
function Syntaxer:ResetTokenizer( Row )
	self.line = self.Editor.Rows[Row]
	self.position = 0
	self.char = ""
	self.tokendata = ""
	
	if Row == self.Editor.Scroll.x then

		self.blockcomment = nil
		self.multilinestring = nil
		local singlelinecomment = false

		local str = string_gsub( table_concat( self.Editor.Rows, "\n", 1, self.Editor.Scroll.x - 1 ), "\r", "" )

		for before, char, after in string_gmatch( str, "()([/'\"\n])()" ) do
			local before = string_sub( str, before - 1, before - 1  )
			local after = string_sub( str, after, after )
			if not self.blockcomment and not self.multilinestring and not singlelinecomment then
				if before ~= "\\" and ( char == '"' or char == "'" ) then
					self.multilinestring = char
				elseif char == "/" then 
					if after == "*" then
						self.blockcomment = true
					elseif after == "/" then 
						singlelinecomment = true 
					end 
				end
			elseif self.multilinestring and self.multilinestring == char and before ~= "\\" then
				self.multilinestring = nil
			elseif self.blockcomment and char == "/" and before == "*" then
				self.blockcomment = nil
			elseif singlelinecomment and char == "\n" then
				singlelinecomment = false
			end
		end
	end
	
	for Function, Line in pairs( self.UserFunctions ) do
		if Line == Row then
			self.UserFunctions[Function] = nil
		end
	end
end

function Syntaxer:NextCharacter( )
	if not self.char then return end

	self.tokendata = self.tokendata .. self.char
	self.position = self.position + 1

	if self.position <= #self.line then
		self.char = string_sub( self.line, self.position, self.position)
	else
		self.char = nil
	end
end

function Syntaxer:NextPattern( pattern, skip )
	if !self.char then return false end
	local startpos, endpos, text = string_find( self.line, pattern, self.position )
	
	if startpos ~= self.position then return false end
	local buf = string_sub( self.line, startpos, endpos )
	text = text or buf
	
	if !skip then 
		self.tokendata = self.tokendata .. text
	end 
	
	self.position = endpos + 1
	if self.position <= #self.line then
		self.char = string_sub( self.line, self.position, self.position )
	else
		self.char = nil
	end
	
	return skip and text or true 
end

/*============================================================================================================================================
	Syntaxer Keywords
============================================================================================================================================*/

-- operator_<key>
local MetaMethods = {
	["addition"] = true, 
	["call"] = true, 
	["division"] = true, 
	["equal"] = true, 
	["exponent"] = true, 
	["greater"] = true, 
	["modulus"] = true, 
	["multiply"] = true, 
	["subtraction"] = true, 
}

local keywords = {
	-- keywords that can be followed by a "(":
	["if"]       = { true, true }, 
	["elseif"]   = { true, true }, 
	["while"]    = { true, true }, 
	["for"]      = { true, true }, 
	["foreach"]  = { true, true }, 
	["try"]      = { true, true }, 
	["catch"]    = { true, true }, 
	["final"]    = { true, true }, 
	-- ["switch"] 	 = { true, true }, 
	-- ["case"]     = { true, true }, 
	-- ["default"]  = { true, true }, 

	-- keywords that cannot be followed by a "(":
	["else"]     = { true, false },
	["break"]    = { true, false },
	["continue"] = { true, false },
	["return"]   = { true, false },
	["global"]   = { true, false },
	["static"]   = { true, false },
	["input"]    = { true, false },
	["output"]   = { true, false },
	["event"]    = { true, false },
	["true"]     = { true, false },
	["false"]    = { true, false },
	["method"]   = { true, false },
}

-- fallback for nonexistant entries:
setmetatable( keywords, { __index = function( tbl, index ) return { } end } )

/*============================================================================================================================================
	Default Color Configeration
============================================================================================================================================*/
/*
	"wire_expression2_editor_color_comment"			"128_128_128"
	"wire_expression2_editor_color_constant"		"140_200_50"
	"wire_expression2_editor_color_directive"		"100_200_255"
	"wire_expression2_editor_color_function"		"80_160_240"
	"wire_expression2_editor_color_keyword"			"0_120_240"
	"wire_expression2_editor_color_notfound"		"240_160_0"
	"wire_expression2_editor_color_number"			"0_200_0"
	"wire_expression2_editor_color_operator"		"255_0_0"
	"wire_expression2_editor_color_ppcommand"		"255_255_255"
	"wire_expression2_editor_color_string"			"100_50_200"
	"wire_expression2_editor_color_typename"		"80_160_240"
	"wire_expression2_editor_color_userfunction"	"102_122_102"
	"wire_expression2_editor_color_variable"		"0_180_80"


	wire_expression2_editor_color_comment 128_128_128;wire_expression2_editor_color_constant 140_200_50;wire_expression2_editor_color_directive 100_200_255;wire_expression2_editor_color_function 80_160_240;wire_expression2_editor_color_keyword 0_120_240;
	wire_expression2_editor_color_notfound 240_160_0;wire_expression2_editor_color_number 0_200_0;wire_expression2_editor_color_operator 255_0_0;wire_expression2_editor_color_ppcommand 255_255_255;wire_expression2_editor_color_string 100_50_200;
	wire_expression2_editor_color_typename 80_160_240;wire_expression2_editor_color_userfunction 102_122_102;wire_expression2_editor_color_variable 0_180_80
*/

/*============================================================================================================================================
	Syntaxer Colors
============================================================================================================================================*/
local colors = { 
	/* TODO: 
		Make propper color scheme 
		Add syntax color options 
	*/
	
	["comment"]      = Color(  128,  128,  128 ), 
	["event"]        = Color(   80,  160,  240 ), // TODO: Other color? 
	["exception"]    = Color(   80,  160,  240 ), // TODO: Other color? 
	["function"]     = Color(   80,  160,  240 ), 
	["keyword"]      = Color(    0,  120,  240 ), 
	["notfound"]     = Color(  240,  160,    0 ), 
	["number"]       = Color(    0,  200,    0 ), 
	["operator"]     = Color(  240,    0,    0 ), 
	["string"]       = Color(  188,  188,  188 ), 
	["typename"]     = Color(  140,  200,   50 ), 
	["userfunction"] = Color(  102,  122,  102 ), 
	["variable"]     = Color(    0,  180,   80 ), 
	["prediction"]   = Color( 0xe3, 0xb5, 0x2d ), 
	["metamethod"]   = Color( 0x00, 0xc8, 0xff ), 
}

-- fallback for nonexistant entries: 
setmetatable( colors, { __index = function( tbl, index ) return Color( 255, 255, 255 ) end } ) 

/*============================================================================================================================================
	Syntaxer Colors options.
============================================================================================================================================*/
local colors_defaults = { }
local colors_convars = { }

function Syntaxer:UpdateSyntaxColors( bNoUpdate )
	for k,v in pairs( colors_convars ) do
		local r, g, b = string_match( v:GetString( ), "(%d+)_(%d+)_(%d+)" )
		local def = colors_defaults[k]
		colors[k] = Color( tonumber( r ) or def.r, tonumber( g ) or def.g, tonumber( b ) or def.b )
	end 
	
	if !bNoUpdate and Syntaxer.Editor then 
		Syntaxer.Editor:UpdateSyntaxColors( ) 
	end 
end 

function Syntaxer.UpdateSyntaxColor( sCVar, sOld, sNew ) 
	local cvar = string_match( sCVar, ".+_(.+)$" ) 
	local r, g, b = string_match( sNew, "(%d+)_(%d+)_(%d+)" )
	local def = colors_defaults[cvar]
	colors[cvar] = Color( tonumber( r ) or def.r, tonumber( g ) or def.g, tonumber( b ) or def.b )
	
	if Syntaxer.Editor then 
		Syntaxer.Editor:UpdateSyntaxColors( ) 
	end 
end 

local norun = false 
function Syntaxer.ResetSyntaxColor( sCVar, sOld, sNew ) 
	if !norun and sNew ~= "0" then 
		norun = true
		RunConsoleCommand( "lemon_editor_resetcolors", "0" ) 
		norun = false
		
		if colors_defaults[sNew] then 
			RunConsoleCommand( "lemon_editor_color_" .. sNew, colors_defaults[sNew].r .. "_" .. colors_defaults[sNew].g .. "_" .. colors_defaults[sNew].b )
		else 
			for k, v in pairs( colors_defaults ) do
				RunConsoleCommand( "lemon_editor_color_" .. k, v.r .. "_" .. v.g .. "_" .. v.b )
			end 
		end 
		
		Syntaxer.UpdateSyntaxColors( ) 
	end 
end 

if Syntaxer.First then 
	table.Empty( cvars.GetConVarCallbacks( "lemon_editor_resetcolors", true ) ) 
	
	CreateClientConVar( "lemon_editor_resetcolors", "0", true, false ) 
	cvars.AddChangeCallback( "lemon_editor_resetcolors", function(...) Syntaxer.ResetSyntaxColor(...) end ) 
end 

for k,v in pairs( colors ) do 
	colors_defaults[k] = Color( v.r, v.g, v.b ) -- Copy to save defaults
	colors_convars[k] = CreateClientConVar( "lemon_editor_color_" .. k, v.r .. "_" .. v.g .. "_" .. v.b, true, false ) 
	
	if Syntaxer.First then 
		table.Empty( cvars.GetConVarCallbacks( "lemon_editor_color_" .. k, true ) ) 
		
		cvars.AddChangeCallback( "lemon_editor_color_" .. k, function(...) Syntaxer.UpdateSyntaxColor(...) end ) 
	end 
end 

Syntaxer.First = nil 

Syntaxer:UpdateSyntaxColors( true )
Syntaxer.ColorConvars = colors_convars

/*============================================================================================================================================
	Syntaxer Highlighting.
============================================================================================================================================*/
local cols, lastcol = { } 

local function addToken( tokenname, tokendata )
	local color = colors[tokenname]
	if lastcol and color == lastcol[2] then
		lastcol[1] = lastcol[1] .. tokendata
	else
		cols[#cols + 1] = { tokendata, color, tokenname }
		lastcol = cols[#cols]
	end
end

function Syntaxer:InfProtect( row )
	self.Loops = self.Loops + 1
	if SysTime( ) > self.Expire then 
		-- error( "Code on line " .. row .. " took to long to parse (" .. self.Loops .. ")" )
		ErrorNoHalt( "Code on line " .. row .. " took to long to parse (" .. self.Loops .. ")\n" )
		return false 
	end
	return true 
end

function Syntaxer:AddUserFunction( Row, Name ) 
	if self.Functions[Name] then return end  
	self.UserFunctions[Name] = Row
end 

function Syntaxer:CreateMethodFunction( nRow, sVarName, sFunctionName ) 
	self.MetaMethods[sVarName] = self.MetaMethods[sVarName] or {} 
	self.MetaMethods[sVarName][sFunctionName] = true 
end 

local function istype( word )
	return API.Classes[word] and true or false 
end

local function isvar( word )
	return Syntaxer.Variables[word] and true or false 
end

function Syntaxer:Parse( Row )
	cols, lastcol = {}, nil 
	
	self.Loops = 0 
	self.Expire = SysTime( ) + 0.1 
	
	self:ResetTokenizer( Row )
	self:NextCharacter( )
	
	if self:NextPattern( "^@return" ) then 
		addToken( "prediction", self.tokendata ) 
		self.tokendata = "" 
	elseif self:NextPattern( "^@model" ) then 
		addToken( "prediction", self.tokendata ) 
		self.tokendata = "" 
	end 

	if self.blockcomment then
		if self:NextPattern(".-%*/") then
			self.blockcomment = nil
		else
			self:NextPattern(".*")
		end
		
		addToken( "comment", self.tokendata )
	elseif self.multilinestring then
		while self.char do -- Find the ending " or '
			if self.char == self.multilinestring then
				self.multilinestring = nil
				self:NextCharacter()
				break
			end
			if self.char == "\\" then self:NextCharacter( ) end
			self:NextCharacter( )
		end
		
		addToken( "string", self.tokendata )
	end
	
	while self.char and self:InfProtect( Row ) do
		local tokenname = "" 
		self.tokendata = "" 
		
		local spaces = self:NextPattern( " *", true ) 
		if spaces then addToken( "operator", spaces ) end 
		if !self.char then break end 
		
		
		if self:NextPattern( "^[a-zA-Z][a-zA-Z0-9_]*" ) then 
			local word = self.tokendata 
			local keyword = ( self.char or "" ) != "(" 
				
			tokenname = "notfound" 
			-- tokenname = "variable" 
			
			if word == "function" then 
				self:NextPattern( " *" ) 
				
				if self.char == "]" then 
					addToken( "typename", self.tokendata ) 
					continue 
				elseif self.char == "(" then 
					addToken( "keyword", self.tokendata ) 
					continue 
				end 
				
				if string_match( self.line, "^[a-zA-Z][a-zA-Z0-9_]* *=", self.position ) then 
					addToken( "typename", self.tokendata ) 
					self.tokendata = ""
					self:NextPattern( "^[a-zA-Z][a-zA-Z0-9_]*" ) 
					addToken( "userfunction", self.tokendata )
					self:AddUserFunction( Row, self.tokendata )
					continue 
				end 
				
				addToken( "keyword", self.tokendata  ) 
				self.tokendata = ""
				
				if self:NextPattern( "^[a-zA-Z][a-zA-Z0-9_]*" ) then 
					self:AddUserFunction( Row, self.tokendata )
					addToken( "userfunction", self.tokendata ) 
				end 
				
				continue 
			end 
			
			if istype( word ) and keyword then 
				addToken( "typename", self.tokendata )
				self.tokendata = ""
				
				local varname = string_match( self.line, " *([a-zA-Z][a-zA-Z0-9_]*)", self.position ) 
				if varname then 
					self.Variables[varname] = Row
					
					for nStart, sText, nEnd in string_gmatch( string_sub( self.line, self.position ), "(), *([a-zA-Z][a-zA-Z0-9_]*)()" ) do 
						if not istype( sText ) then 
							self.Variables[sText] = Row 
						end 
					end 
				end 
				continue 
			end 
			
			if word == "event" then 
				self:NextPattern( " *" ) 
				addToken( "keyword", self.tokendata )
				self.tokendata = ""
				
				if self:NextPattern( "^[a-z][a-zA-Z0-9_]*" ) then 
					if self.Events[self.tokendata] then 
						addToken( "event", self.tokendata )
					else 
						addToken( "notfound", self.tokendata )
					end 
				end 
				
				continue 
			end 
			
			if word == "catch" then 
				self:NextPattern( " *" ) 
				addToken( "keyword", self.tokendata )
				self.tokendata = "" 
				
				if self:NextPattern( "%(" ) then 
					self:NextPattern( " *" ) 
					addToken( "operator", self.tokendata ) 
					self.tokendata = ""
					
					if self:NextPattern( "[a-z0-9]+" ) then 
						local exception = self.tokendata 
						self:NextPattern( " *" ) 
						
						if API.Exceptions[ exception ] then 
							addToken( "exception", self.tokendata )
						else 
							addToken( "notfound", self.tokendata )
						end 
						
						self.tokendata = ""
						self:NextPattern( "[a-zA-Z][a-zA-Z0-9_]*" ) 
						self.Variables[self.tokendata] = Row 
						addToken( "variable", self.tokendata ) 
					end 
				end 
				
				continue 
			end 
			
			if word == "method" then 
				self:NextPattern( " *" ) 
				addToken( "keyword", self.tokendata )
				self.tokendata = ""
				
				if self:NextPattern( "[a-zA-Z][a-zA-Z0-9_]*" ) then 
					if isvar( self.tokendata ) then 
						local MethodVar = self.tokendata 
						addToken( "variable", self.tokendata ) 
						self.tokendata = "" 
						
						self:NextPattern( " *: *" ) 
						addToken( "operator", self.tokendata ) 
						self.tokendata = "" 
						
						if self:NextPattern( "[a-zA-Z][a-zA-Z0-9_]*" ) then 
							if MetaMethods[string_match( self.tokendata, "operator_(.*)" )] then 
								addToken( "metamethod", self.tokendata ) 
							else 
								addToken( "userfunction", self.tokendata )
								self:CreateMethodFunction( Row, MethodVar, self.tokendata )
							end 
						end 
					else 
						addToken( "notfound", self.tokendata ) 
						self.tokendata = "" 
					end 
				end 
				
				continue
			end 
			
			if keywords[word][1] then 
				if keywords[word][2] then 
					addToken( "keyword", self.tokendata ) 
					continue 
				elseif keyword then 
					addToken( "keyword", self.tokendata ) 
					continue 
				end 
			end 
			
			if self.Functions[self.tokendata] then 
				addToken( "function", self.tokendata ) 
				continue 
			end 
			
			if self.UserFunctions[self.tokendata] and self.UserFunctions[self.tokendata] <= Row then 
				addToken( "userfunction", self.tokendata ) 
				continue 
			end 
			
			if isvar( word ) /*and self.Variables[word] <= Row*/ then 
				addToken( "variable", self.tokendata ) 
				self.tokendata = "" 
				
				if self:NextPattern( " *: *" ) then 
					addToken( "operator", self.tokendata ) 
					self.tokendata = "" 
					
					if string_match( self.line, "^[a-zA-Z][a-zA-Z0-9_]*", self.position ) then 
						local func = string_match( self.line, "^[a-zA-Z][a-zA-Z0-9_]*", self.position )
						if self.MetaMethods[word] and self.MetaMethods[word][func] then 
							self:NextPattern( "^[a-zA-Z][a-zA-Z0-9_]*" )
							addToken( "userfunction", self.tokendata )
						end 
					end 
				end
				continue 
			end 
		elseif self:NextPattern( "^0[xb][0-9A-F]+" ) then
			tokenname = "number"
		elseif self:NextPattern( "^[0-9][0-9.e]*" ) then
			tokenname = "number"
		elseif self.char == '"' or self.char == "'" then
			local sType = self.char 
			self:NextCharacter()
			while self.char do -- Find the ending " or '
				if self.char == sType then
					tokenname = "string"
					break
				end
				if self.char == "\\" then self:NextCharacter() end
				self:NextCharacter()
			end
			
			if tokenname == "" then 
				self.multilinestring = sType 
				tokenname = "string" 
			else 
				self:NextCharacter() 
			end 
		elseif self.char == "/" then
			self:NextCharacter()
			if self.char == "*" then // Multiline comment 
				while self.char do 
					if self.char == "*" then
						self:NextCharacter()
						if self.char == "/" then 
							tokenname = "comment"
							break
						end
					end
					self:NextCharacter()
				end
				if tokenname == "" then 
					self.blockcomment = true
					tokenname = "comment"
				else
					self:NextCharacter()
				end	
			elseif self.char == "/" then // Singleline comment
				self:NextPattern(".*")
				tokenname = "comment"
			else 
				tokenname = "operator"
			end
		else 
			local b = false
			for i = 1, #self.Tokens do 
				if self:NextPattern( self.Tokens[i] ) then 
					addToken( "operator", self.tokendata ) 
					b = true
					break
				end 
			end 
			if b then continue end 
			
			self:NextCharacter( )
			tokenname = "notfound"
		end
		
		addToken(tokenname, self.tokendata)
	end 
	
	return cols 
end

function LEMON.Highlight( Editor, Row )
	Syntaxer.Editor = Editor 
	return Syntaxer:Parse( Row )
end
