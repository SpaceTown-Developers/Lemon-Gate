/*============================================================================================================================================
	Expression-Advanced Syntax Highlighting
	Autor: Oskar
	Credits: The one that made the E2 syntax highlighter 
============================================================================================================================================*/

local table_concat = table.concat 
local string_sub = string.sub 
local string_gsub = string.gsub 
local string_gmatch = string.gmatch 

Syntax = {} 
local Syntax = {} 
local EA = LemonGate 

local function SetupFunctionTable( )
	if !LemonGate then return end 
	if !LemonGate.FunctionTable then 
		RunConsoleCommand( "lemon_sync" ) 
		timer.Simple( 0.5, function() 
			Syntax.FunctionTable = SetupFunctionTable( )
		end )
		return {}
	end 
	
	// TODO: Do in timer to prevent lagg?
	local FunctionTable = {} 
	for name, data in pairs( LemonGate.FunctionTable ) do 
		local funcName = name:match( "^[^%(]+" ) 
		FunctionTable[funcName] = true 
	end 
	return FunctionTable 
end
Syntax.FunctionTable = SetupFunctionTable() 
Syntax.UserFunctions = { } 

function Syntax:ResetTokenizer( Row )
	self.line = self.Editor.Rows[Row]
	self.position = 0
	self.char = ""
	self.tokendata = ""
	
	if Row == self.Editor.Scroll.x then

		self.blockcomment = nil
		self.multilinestring = nil
		local singlelinecomment = false

		local str = string_gsub( table_concat( self.Editor.Rows, "\n", 1, self.Editor.Scroll.x-1 ), "\r", "" )

		for before, char, after in string_gmatch( str, "()([/'\"\n])()" ) do
			local before = string_sub( str, before-1, before-1  )
			local after = string_sub( str, after, after )
			if not self.blockcomment and not self.multilinestring and not singlelinecomment then
				if char == '"' or char == "'" then
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

function Syntax:NextCharacter()
	if not self.char then return end

	self.tokendata = self.tokendata .. self.char
	self.position = self.position + 1

	if self.position <= self.line:len() then
		self.char = self.line:sub(self.position, self.position)
	else
		self.char = nil
	end
end

function Syntax:NextPattern( pattern, skip )
	if !self.char then return false end
	local startpos,endpos,text = self.line:find(pattern, self.position)
	
	if startpos ~= self.position then return false end
	local buf = self.line:sub(startpos, endpos)
	if not text then text = buf end
	
	if !skip then 
		self.tokendata = self.tokendata .. text
	end 
	
	self.position = endpos + 1
	if self.position <= #self.line then
		self.char = self.line:sub(self.position, self.position)
	else
		self.char = nil
	end
	if skip then return text 
	else return true 
	end 
end

local keywords = {
	-- keywords that can be followed by a "(":
	["if"]       = { true, true }, 
	["elseif"]   = { true, true }, 
	["while"]    = { true, true }, 
	["for"]      = { true, true }, 
	["foreach"]  = { true, true }, 
	["try"]      = { true, true }, 
	["catch"]    = { true, true }, 
	-- ["switch"] 	 = { true, true }, 
	-- ["case"]     = { true, true }, 
	-- ["default"]  = { true, true }, 

	-- keywords that cannot be followed by a "(":
	["else"]     = { true, false },
	["break"]    = { true, false },
	["continue"] = { true, false },
	["return"]   = { true, false },
	["local"]    = { true, false },
	["global"]   = { true, false },
	["input"]    = { true, false },
	["output"]   = { true, false },
	["event"]    = { true, false },
}

-- fallback for nonexistant entries:
setmetatable( keywords, { __index=function(tbl,index) return {} end } )

/*

"wire_expression2_editor_color_comment"		"128_128_128"
"wire_expression2_editor_color_constant"		"140_200_50"
"wire_expression2_editor_color_directive"		"100_200_255"
"wire_expression2_editor_color_function"		"80_160_240"
"wire_expression2_editor_color_keyword"		"0_120_240"
"wire_expression2_editor_color_notfound"		"240_160_0"
"wire_expression2_editor_color_number"		"0_200_0"
"wire_expression2_editor_color_operator"		"255_0_0"
"wire_expression2_editor_color_ppcommand"		"255_255_255"
"wire_expression2_editor_color_string"		"100_50_200"
"wire_expression2_editor_color_typename"		"80_160_240"
"wire_expression2_editor_color_userfunction"		"102_122_102"
"wire_expression2_editor_color_variable"		"0_180_80"


wire_expression2_editor_color_comment 128_128_128;wire_expression2_editor_color_constant 140_200_50;wire_expression2_editor_color_directive 100_200_255;wire_expression2_editor_color_function 80_160_240;wire_expression2_editor_color_keyword 0_120_240;
wire_expression2_editor_color_notfound 240_160_0;wire_expression2_editor_color_number 0_200_0;wire_expression2_editor_color_operator 255_0_0;wire_expression2_editor_color_ppcommand 255_255_255;wire_expression2_editor_color_string 100_50_200;
wire_expression2_editor_color_typename 80_160_240;wire_expression2_editor_color_userfunction 102_122_102;wire_expression2_editor_color_variable 0_180_80

*/

local colors = {
	["comment"]      = Color( 128, 128, 128 ), 
	-- ["event"]        = Color( 240, 240, 240 ), 
	-- ["exception"]    = Color( 240, 240, 240 ), 
	["function"]     = Color(  80, 160, 240 ), 
	["keyword"]      = Color(   0, 120, 240 ), 
	["notfound"]     = Color( 240, 160,   0 ), 
	["number"]       = Color(   0, 200,   0 ), 
	["operator"]     = Color( 240,   0,   0 ),  
	["string"]       = Color( 100,  50, 200 ), 
	["typename"]     = Color( 255, 255,   0 ), 
	["userfunction"] = Color( 102, 122, 102 ), 
	["variable"]     = Color(   0, 180,  80 ), 
	
}

setmetatable( colors, { __index=function(tbl,index) return Color( 255, 255, 255 ) end } )

local cols = {} 
local lastcol 
local function addToken(tokenname, tokendata)
	local color = colors[tokenname]
	if lastcol and color == lastcol[2] then
		lastcol[1] = lastcol[1] .. tokendata
	else
		cols[#cols + 1] = { tokendata, color, tokenname }
		lastcol = cols[#cols]
	end
end

function Syntax:InfProtect( )
	self.Loops = self.Loops + 1
	if SysTime() > self.Expire then 
		error( "Code took to long to parse (" .. self.Loops .. ")" )
	end
end

function Syntax:AddUserfunction( Row, Name ) 
	if self.FunctionTable[Name] then return end  
	self.UserFunctions[Name] = Row
end 

local function istype( word )
	return EA.IsType( word ) and word ~= EA.GetShortType( word ) 
end

function Syntax:Parse( Row )
	cols, lastcol = {}, nil 
	
	self.Loops = 0 
	self.Expire = SysTime() + 0.1 
	
	self:ResetTokenizer(Row)
	self:NextCharacter()
	
	if self.blockcomment then
		if self:NextPattern(".-%*/") then
			self.blockcomment = nil
		else
			self:NextPattern(".*")
		end
		
		addToken( "comment", self.tokendata )
	elseif self.multilinestring then
		while self.char do -- Find the ending "
			if self.char == self.multilinestring then
				self.multilinestring = nil
				self:NextCharacter()
				break
			end
			if self.char == "\\" then self:NextCharacter() end
			self:NextCharacter()
		end
		
		addToken( "string", self.tokendata )
	end
	
	while self.char do
		self:InfProtect( )
		local tokenname = ""
		self.tokendata = ""
		
		local spaces = self:NextPattern( " *", true ) 
		if spaces then addToken( "operator", spaces ) end 
		if !self.char then break end 
		
		
		if self:NextPattern( "^[a-z][a-zA-Z0-9_]*" ) then 
			local word = self.tokendata 
			local keyword = ( self.char or "" ) != "(" 
				
			tokenname = "notfound" 
			
			if self:NextPattern( "^ *= " ) then 
				tokenname = self.FunctionTable[word] and "function" or "userfunction"
				self:AddUserfunction( Row, word ) 
				addToken( tokenname, word )
				tokenname = "operator"
				self.tokendata = self.tokendata:match( " *= " )
				addToken( tokenname, self.tokendata )
				continue 
			end 
			
			if self.FunctionTable[self.tokendata] then 
				tokenname = "function"
			end 
			
			if self.UserFunctions[self.tokendata] then 
				tokenname = "userfunction"
			end 
			
			if EA.IsType( word ) and keyword and word ~= EA.GetShortType( word ) then 
				tokenname = "typename" 
			end 
			
			if keywords[word][1] then 
				if keywords[word][2] then 
					tokenname = "keyword" 
				elseif keyword then 
					tokenname = "keyword" 
				end 
			end 
			
			if word == "function" then 
				tokenname = "keyword"
				self:NextPattern( " *" ) 
				if self.char == "]" then 
					addToken( "typename", word )
					continue 
				end 
				addToken( tokenname, self.tokendata )
				self.tokendata = ""
				
				if self:NextPattern( "^[a-z][a-zA-Z0-9_]*" ) then 
					if EA.IsType( self.tokendata ) and self.tokendata ~= EA.GetShortType( self.tokendata ) then 
						self:NextPattern( " *" ) 
						tokenname = "typename" 
						addToken( tokenname, self.tokendata )
						self.tokendata = "" 
						if !self:NextPattern( "^[a-z][a-zA-Z0-9_]*" ) then continue end 
					end 
					tokenname = "userfunction" 
					self:AddUserfunction( Row, self.tokendata ) 
					addToken( tokenname, self.tokendata )
				end 
				continue 
			end 
			
			if word == "event" then 
				tokenname = "keyword"
				self:NextPattern( " *" ) 
				addToken( tokenname, self.tokendata )
				self.tokendata = ""
				tokenname = ""
				
				if self:NextPattern( "^[a-z][a-zA-Z0-9_]*" ) then 
					if LemonGate.EventsTable[self.tokendata] then 
						tokenname = "event" 
					else 
						tokenname = "notfound"
					end 
					addToken(tokenname, self.tokendata)
				end 
				
				continue 
			end 
			
			if word == "catch" then 
				self:NextPattern( " *" ) 
				addToken( tokenname, self.tokendata )
				self.tokendata = ""
				tokenname = "" 
				
				if self:NextPattern( "%(" ) then 
					self:NextPattern( " *" ) 
					addToken( "operator", self.tokendata ) 
					self.tokendata = ""
					
					if self:NextPattern( "[a-z0-9]+" ) then 
						local exception = self.tokendata 
						self:NextPattern( " *" ) 
						
						if LemonGate.Exceptions[ exception ] then 
							addToken( "exception", self.tokendata )
						else 
							addToken( "notfound", self.tokendata )
						end  
					end 
				end 
				
				continue 
			end 
		elseif self:NextPattern("^0[xb][0-9A-F]+") then
			tokenname = "number"
		elseif self:NextPattern("^[0-9][0-9.e]*") then
			tokenname = "number"
		elseif self:NextPattern("^[A-Z][a-zA-Z0-9_]*") then
			tokenname = "variable"
		elseif self.char == '"' or self.char == "'" then
			local sType = self.char 
			self:NextCharacter()
			while self.char do -- Find the ending "
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
					if self.char == "\\" then self:NextCharacter() end
					self:NextCharacter()
				end
				if (tokenname == "") then 
					self.blockcomment = true
					tokenname = "comment"
				else
					self:NextCharacter()
				end	
			elseif self.char == "/" then // Singleline comment
				self:NextPattern(".*")
				tokenname = "comment"
			end
			
		else
			self:NextCharacter()
			tokenname = "operator"
		end
		
		addToken(tokenname, self.tokendata)
	end 
	
	return cols 
end


function _G.Syntax.Parse( Editor, Row )
	if not LemonGate or // true or 
		not LemonGate.TypeTable or 
		not LemonGate.FunctionTable or 
		not LemonGate.OperatorTable or 
		not LemonGate.EventsTable then 
		return { { Editor.Rows[Row], C_white } } 
	end
	Syntax.Editor = Editor 
	//Syntax.FunctionTable = Syntax.FunctionTable or {}
	return Syntax:Parse( Row )
end
