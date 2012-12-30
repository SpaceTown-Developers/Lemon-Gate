/*==============================================================================================
	Expression Advanced: Lemon Gate Tokenizer.
	Purpose: Converts Code To Tokens.
	Creditors: Rusketh, Oskar94
==============================================================================================*/

local E_A = LemonGate
local Toker = E_A.Tokenizer
Toker.__index = Toker

local error = error
local pcall = pcall
local setmetatable = setmetatable

local FormatStr = string.format
local ExplodeStr = string.Explode

/***************************************************************/

local Tokens = {
	
	--MATH:
	
		{ "+", "add", "addition" },
		{ "-", "sub", "subtract" },
		{ "*", "mul", "multiplier" },
		{ "/", "div", "division" },
		{ "%", "mod", "modulus" },
		{ "^", "exp", "power" },
		{ "=", "ass", "assign" },
		{ "+=", "aadd", "increase" },
		{ "-=", "asub", "decrease" },
		{ "*=", "amul", "multiplier" },
		{ "/=", "adiv", "division" },
		{ "++", "inc", "increment" },
		{ "--", "dec", "decrement" },

	-- COMPARISON:
	
		{ "==", "eq", "equal" },
		{ "!=", "neq", "unequal" },
		{ "<", "lth", "less" },
		{ "<=", "leq", "less or equal" },
		{ ">", "gth", "greater" },
		{ ">=", "geq", "greater or equal" },

	-- BITWISE:
	
		{ "&", "band", "and" },
		{ "|", "bor", "or" },
		{ "^^", "bxor", "or" },
		{ ">>", "bshr", ">>" },
		{ "<<", "bshl", "<<" },

	-- CONDITION:
	
		{ "!", "not", "not" },
		{ "&&", "and", "and" },
		{ "||", "or", "or" },

	-- SYMBOLS:
	
		{ "?", "qsm", "?" },
		{ ":", "col", "colon" },
		{ ",", "com", "comma" },
		{ "$", "dlt", "delta" },
		{ "#", "len", "length" },

	-- BRACKETS:
	
		{ "(", "lpa", "left parenthesis" },
		{ ")", "rpa", "right parenthesis" },
		{ "{", "lcb", "left curly bracket" },
		{ "}", "rcb", "right curly bracket" },
		{ "[", "lsb", "left square bracket" },
		{ "]", "rsb", "right square bracket" }
}

E_A.API.CallHook( "BuildTokens", Tokens )

table.sort( Tokens, function( Token, Token2 ) return #Token[1] > #Token2[1] end )

/***************************************************************/

function Toker.Execute( ... )
	return pcall( Toker.Run, setmetatable( { }, Toker ), ... )
end

function Toker:InfProtect( )
	self.Loops = self.Loops + 1
	if SysTime() > self.Exspire then 
		self:Error( "Code took to long to Tokenize (" .. self.Loops .. ")" )
	end
end

function Toker:Run( Code )
	--Purpose: Tokenize the code.
	
	self.Tokens = { }
	self.Pos, self.ReadChar, self.ReadLine = 0, 0, 1
	self.Char, self.ReadData = "", "", ""
	self.Buffer, self.Len = Code, #Code
	
	self:NextChar()
	
	self.Loops = 0 -- I'm preventing inf loops, in case the API breaks somthing.
	self.Exspire = SysTime() + 5 -- You have 5 seconds to tokenize.
	
	while self.Char do
		
		self.SkipToken = false
		local Token = self:NextToken( )
		
		if Token then
			self.Tokens[#self.Tokens + 1] = Token
		end
		
		if self.Char == "" then
			self.Char = nil
		end
		
		if self.Char and !Token and !self.SkipToken then
			self:Error( "Unknown syntax found (%s)", 0, self.ReadData .. tostring(self.Char) )
		end
		
		self:InfProtect(  )
	end
	
	return self.Tokens
end

/***************************************************************/

function Toker:Error( Msg, Offset, Arg, ... )
	if Offset then self.ReadChar = self.ReadChar + Offset end
	if Arg then Msg = FormatStr( Msg, Arg, ... ) end
	
	Msg = FormatStr( "%s at line %i, char %i", Msg, self.ReadLine, self.ReadChar )
	MsgN( Msg )
	error( Msg, 0 )
end

/***************************************************************/

-- NEW FUNCTION!
function Toker:NextPattern( Pattern, Exact )
	if self.Char then
		local Start, End, String = self.Buffer:find(Pattern, self.Pos, Exact)
		if Start == self.Pos then
			if !String then
				String = self.Buffer:sub(Start, End)
			end
			
			self.Pos = End + 1
			self.PatternMatch = String
			self.ReadData = self.ReadData .. String
			
			if self.Pos > self.Len then
				self.Char = nil
			else
				self.Char = self.Buffer[self.Pos]
			end
			
			local Lines = ExplodeStr("\n", String)
			if #Lines > 1 then
				self.ReadLine = self.ReadLine + #Lines - 1
				self.ReadChar = #Lines[ #Lines ] + 1
			else
				self.ReadChar = self.ReadChar + #Lines[ #Lines ]
			end
			
			return true
		end
	end
	
	return false
end


function Toker:SkipSpaces()
	self:NextPattern("^[%s\n]*")
	
	self.ReadData = ""
	
	return self.PatternMatch
end

/***************************************************************/

function Toker:SkipChar()
	-- Purpose: Skip this Char
	
	if self.Len >= self.Pos then
		if self.Char == "\n" then
			-- New Line Char
			self.ReadLine = self.ReadLine + 1
			self.ReadChar = 1
			
		else
			self.ReadChar = self.ReadChar + 1
		end
		
		self.Pos = self.Pos + 1
		self.Char = self.Buffer:sub(self.Pos, self.Pos)
	else
		self.Char = nil
	end
end

function Toker:NextChar()
	-- Purpose: Move to the next char.
	
	self.ReadData = self.ReadData .. self.Char
	self:SkipChar()
end

function Toker:NewToken( Token, Desc )
	local Token = { { "", Token, Desc }, self.ReadData, self.ReadLine, self.ReadChar }
	self.ReadData = ""
	return Token
end

/***************************************************************/

function Toker:SkipComments( )

	-- COMMENTS:
		
		local Style
		
		if self:NextPattern( "//", true ) then
			Style = "\n"
		elseif self:NextPattern( "/*", true ) then
			Style = "*/"
		end
		
		if Style then
			while !self:NextPattern( Style , true) do
				
				-- TODO: Anitations =D
				
				if !self.Char and Style == "*/" then
					self:Error("Unterminated multiline comment (/*)", 0)
				end
				
				self:SkipChar()
				
				self:InfProtect(  )
			end
			
			self.ReadData = ""
			
			self.SkipToken = true
		end
end

/***************************************************************/

function Toker:DataToken( )
	
	-- NUMBER:
	
		if self:NextPattern( "^0x[%x]+" ) then
			self.ReadData = tonumber( self.ReadData ) or self:Error( "Invalid number format (%s)", 0, self.ReadData )
			return self:NewToken( "num", "hex" )
		
		elseif self:NextPattern( "^0b[01]+" ) then
			self.ReadData = tonumber( self.ReadData:sub(3), 2 ) or self:Error( "Invalid number format (%s)", 0, self.ReadData )
			return self:NewToken( "num", "bin" )
		
		elseif self:NextPattern( "^%d+%.?%d*" ) then
			self.ReadData = tonumber( self.ReadData ) or self:Error( "Invalid number format (%s)", 0, self.ReadData )
			return self:NewToken( "num", "real" )
		
	-- STRING:
	
		elseif self.Char == '"' then
			return self:StringToken( '"' )
		elseif self.Char == "'" then
			return self:StringToken( "'" )
		end
		
	-- Custom:
	
		return E_A.API.CallHook( "DataToken", self )
end

function Toker:StringToken( StrChar )
	local PrevChar = self:SkipChar()
	
	while self.Char do
		
		if self.Char == StrChar then -- and ( !PrevChar or PrevChar == "\\" ) then
			break
		else
			self:NextChar()
		end
		
		self:InfProtect(  )
	end

	if self.Char and self.Char == StrChar then
		self:SkipChar()
		
		return self:NewToken( "str", "String" )
	end
	
	
	local String = self.ReadData
		
	if #String > 10 then
		String = string.sub(self.ReadData, 0, 10) .. "..."
	end
	
	self:Error( "Unterminated string (\"%s)", 0, String, 10 )
end


/***************************************************************/

function Toker:WordToken( )
	if self:NextPattern( "^[a-zA-Z][a-zA-Z0-9_]*" ) then
		local RawData = self.ReadData
		
	-- KEYWORDS:
	
		if RawData == "if" then
			return self:NewToken( "if", "if" )
		elseif RawData == "elseif" then
			return self:NewToken( "eif", "else if" )
		elseif RawData == "else" then
			return self:NewToken( "els", "else" )
		elseif RawData == "while" then
			return self:NewToken( "whl", "while")
		elseif RawData == "for" then
			return self:NewToken( "for", "for")
		elseif RawData == "foreach" then
			return self:NewToken( "each", "foreach")
		elseif RawData == "function" then
			return self:NewToken( "func", "function constructor")
		-- elseif RawData == "switch" then
			-- return self:NewToken( "swh", "switch")
		elseif RawData == "event" then
			return self:NewToken( "evt", "event constructor")
		elseif RawData == "try" then
			return self:NewToken( "try", "try")
		elseif RawData == "catch" then
			return self:NewToken( "cth", "catch")
		
	
	-- SUB KEYWORDS:
	
		elseif RawData == "break" then
			return self:NewToken( "brk", "break" )
		elseif RawData == "continue" then
			return self:NewToken( "cnt", "continue" )
		elseif RawData == "return" then
			return self:NewToken( "ret", "return" )
		elseif RawData == "error" then
			return self:NewToken( "err", "error" )

	-- DECLERATION:
	
		elseif RawData == "global" then
			return self:NewToken( "glob", "global" )
		elseif RawData == "input" then
			return self:NewToken( "in", "input" )
		elseif RawData == "output" then
			return self:NewToken( "out", "output" )
		end

		local Token = E_A.API.CallHook( "WordToken", self )
		if Token then return Token end -- Custom syntax =D
		
		if RawData[1] == RawData[1]:upper( ) then
			return self:NewToken( "var", "variable" )
		end
		
		return self:NewToken( "fun", "function")
	end
end

function Toker:NextToken( )
	if self.Char then
		
		self:SkipSpaces( )
		
		self:SkipComments( )
		
		if !self.SkipToken then
		
			local Token = self:WordToken( ) or self:DataToken( )
			
			if Token then
				return Token
			else
			
				for I = 1, #Tokens do
					local Token = Tokens[I]
					
					if self:NextPattern( Token[1], true ) then
						return self:NewToken( Token[2], Token[3] )
					end
				end
				
				return E_A.API.CallHook( "NextToken", self )
			end
		end
	end
end

/***************************************************************/
