/*==============================================================================================
	Expression Advanced: Compiler -> Tokenizer.
	Purpose: The Tokenizing part of the compiler.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON = LEMON

local Compiler = LEMON.Compiler

/*==============================================================================================
	Section: Chars
==============================================================================================*/

function Compiler:SkipChar( )
	if self.Len >= self.Pos then
		if self.Char == "\n" then
			self.ReadLine = self.ReadLine + 1
			self.ReadChar = 1
		else
			self.ReadChar = self.ReadChar + 1
		end

		self.Pos = self.Pos + 1
		self.Char = self.Buffer:sub( self.Pos, self.Pos )
	else
		self.Char = nil
	end
end

function Compiler:NextChar( )
	self.ReadData = self.ReadData .. self.Char
	self:SkipChar( )
end

/*==============================================================================================
	Section: Patterns
==============================================================================================*/

function Compiler:NextPattern( Pattern, Exact )
	if self.Char then
		local Start, End, String = self.Buffer:find( Pattern, self.Pos, Exact )
		if Start == self.Pos then
			if !String then
				String = self.Buffer:sub( Start, End )
			end

			self.Pos = End + 1
			self.PatternMatch = String
			self.ReadData = self.ReadData .. String

			if self.Pos > self.Len then
				self.Char = nil
			else
				self.Char = self.Buffer[self.Pos]
			end

			local Lines = string.Explode( "\n", String )
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

function Compiler:ManualPattern( Pattern, Exact )
	local Char, ReadData = self.Char, self.ReadData

	local Result = self:NextPattern( Pattern, Exact )

	self.Char, self.ReadData = Char, ReadData

	return Result
end

function Compiler:SkipSpaces( )
	self:NextPattern( "^[%s\n]*" )

	self.ReadData = ""

	return self.PatternMatch
end

/*==============================================================================================
	Section: Next / Prev
==============================================================================================*/
function Compiler:GoToToken( I )
	local RealPos = self.TokenPos
	
	if I > 1 then
		self.TokenPos = I - 1
		self:NextToken( )
	end
	
	return RealPos
end

function Compiler:PrevToken( )
	self.TokenPos = self.TokenPos - 2
	self:NextToken( ) -- Cus i'm cool like that =D
end

function Compiler:NextToken( )
	local Pos = self.TokenPos + 1
	
	if Pos <= 0 then
		self.TokenPos = 0
		
		self.Token = nil
		self.TokenData = nil
		self.TokenType = nil
		self.TokenName = nil
		
		self.TokenLine = 0
		self.TokenChar = 0
		
		self.PrepToken = self.Tokens[ 1 ]
	
	else
	
		self.TokenPos = Pos
		
		self.Token = self.Tokens[ Pos ]
		
		if !self.Token then
			self.Token = self:GetNextToken( )
			self.Tokens[ Pos ] = self.Token
		end
		
		self.TokenData = self.Token[1]
		self.TokenType = self.Token[2]
		self.TokenName = self.Token[3]
		self.TokenLine = self.Token[4]
		self.TokenChar = self.Token[5]
		
		self.PrepToken = self.Tokens[ Pos + 1 ]
		
		if !self.PrepToken then
			self.PrepToken = self:GetNextToken( )
			self.Tokens[ Pos + 1 ] = self.PrepToken
		end	
	end
	
	if self.PrepToken then
		self.PrepTokenType = self.PrepToken[2]
		self.PrepTokenName = self.PrepToken[3]
		self.PrepTokenLine = self.PrepToken[4]
	end
	
end

function Compiler:PopToken( )
	self.Pos = self.TokenPos
	self.ReadChar = self.TokenChar
	self.ReadLine = self.TokenLine
	self.Tokens[ self.TokenPos ] = nil
	self:PrevToken( )
end

/*==============================================================================================
	Section: Build Tokens
==============================================================================================*/

function Compiler:NewToken( Type, Name )
	local Token = { self.ReadData, Type, Name, self.ReadLine, self.ReadChar, self.Pos }
	
	self.ReadData = ""
	
	return Token
end

/*==============================================================================================
	Section: Comments
==============================================================================================*/

function Compiler:SkipComments( )
	local Style

	if self:NextPattern( "//", true ) then
		Style = "\n"
	elseif self:NextPattern( "/*", true ) then
		Style = "*/"
	end

	if Style then
		while !self:NextPattern( Style, true ) do
			if !self.Char then 
				if Style == "*/" then
					self:Error( 0, "Un-terminated multi line comment (/*)", 0 )
				else 
					break 
				end 
			end

			self:SkipChar( )

			self:TimeCheck(  )
		end

		self.ReadData = ""

		self.SkipToken = true
	end
end

/*==============================================================================================
	Section: Generate Token
==============================================================================================*/

function Compiler:DataToken( )

	-- NUMBER:

	if self:NextPattern( "^0x[%x]+" ) then
		self.ReadData = tonumber( self.ReadData ) or self:Error( 0, "Invalid number format (%s)", 0, self.ReadData )
		return self:NewToken( "num", "hex" )

	elseif self:NextPattern( "^0b[01]+" ) then
		self.ReadData = tonumber( self.ReadData:sub(3), 2 ) or self:Error( 0, "Invalid number format (%s)", 0, self.ReadData )
		return self:NewToken( "num", "bin" )

	elseif self:NextPattern( "^%d+%.?%d*" ) then
		self.ReadData = tonumber( self.ReadData ) or self:Error( 0, "Invalid number format (%s)", 0, self.ReadData )
		return self:NewToken( "num", "real" )

	-- STRING:

	elseif self.Char == '"' then
		return self:StringToken( '"' )
	elseif self.Char == "'" then
		return self:StringToken( "'" )
	end

end

function Compiler:StringToken( StrChar )
	local Escape = false
	self:SkipChar( )

	while self.Char do
		if self.Char == "\n" then
			
			if StrChar == "'" then
				self:NextChar( )
			else
				break -- End of Line.
			end

		elseif !Escape then
			
			if self.Char == StrChar then
				break -- End of string.
			elseif self.Char == "\\" then
				Escape = true
				self:SkipChar( ) -- Escape Sequence.
			else
				self:NextChar( )
			end

		elseif self.Char == "\\" then
			Escape = false
			self:NextChar( )

		elseif self.Char == StrChar then
			Escape = false
			self:NextChar( )

		elseif self.Char == "n" then
			Escape = false
			self.Char = "\n"
			self:NextChar( )

		elseif self.Char == "t" then
			Escape = false
			self.Char = "\t"
			self:NextChar( )

		elseif self.Char == "r" then
			Escape = false
			self.Char = "\r"
			self:NextChar( )

		elseif self:ManualPattern( "^([0-9]+)" ) then
			
			local Num = tonumber( self.PatternMatch )
			if !Num or Num < 0 or Num > 255 then
				self:Error( 0, "Invalid char (%s)", Num or "?" )
			end

			Escape = false
			self.Pos = self.Pos - 1
			self.ReadData = self.ReadData .. string.char( Num )

			self:SkipChar( )
		else
			self:Error( 0, "Unfinished escape sequence (\\%s)", self.Char )
		end

		self:TimeCheck(  )
	end

	if self.Char and self.Char == StrChar then
		self:SkipChar( )
		return self:NewToken( "str", "String" )
	end


	local String = self.ReadData

	if #String > 10 then
		String = string.sub(self.ReadData, 0, 10) .. "..."
	end

	self:Error( 0, "Unterminated string (\"%s)", String )
end


/***************************************************************/

function Compiler:WordToken( )
	if self:NextPattern( "^[a-zA-Z][a-zA-Z0-9_]*" ) then
		local RawData = self.ReadData

	-- KEYWORDS:

		if RawData == "if" then
			return self:NewToken( "if", "if" )
		elseif RawData == "elseif" then
			return self:NewToken( "eif", "elseif" )
		elseif RawData == "else" then
			return self:NewToken( "els", "else" )
		elseif RawData == "while" then
			return self:NewToken( "whl", "while")
		elseif RawData == "for" then
			return self:NewToken( "for", "for")
		elseif RawData == "foreach" then
			return self:NewToken( "each", "foreach")
		elseif RawData == "function" then
			return self:NewToken( "func", "function")
		elseif RawData == "method" then
			return self:NewToken( "meth", "method")
		elseif RawData == "switch" then
			return self:NewToken( "swh", "switch")
		elseif RawData == "case" then
			return self:NewToken( "cse", "case")
		elseif RawData == "default" then
			return self:NewToken( "dft", "default")
		elseif RawData == "event" then
			return self:NewToken( "evt", "event")
		elseif RawData == "try" then
			return self:NewToken( "try", "try")
		elseif RawData == "catch" then
			return self:NewToken( "cth", "catch")
		elseif RawData == "final" then
			return self:NewToken( "fnl", "final")
			
	-- RAW DATA:
		
		elseif RawData == "true" then
			return self:NewToken( "tre", "true")
		elseif RawData == "false" then
			return self:NewToken( "fls", "false")
		-- elseif RawData == "null" then -- Removed because im lazy!
			-- return self:NewToken( "nll", "null")


	-- SUB KEYWORDS:

		elseif RawData == "break" then
			return self:NewToken( "brk", "break" )
		elseif RawData == "continue" then
			return self:NewToken( "cnt", "continue" )
		elseif RawData == "return" then
			return self:NewToken( "ret", "return" )
		-- elseif RawData == "error" then
			-- return self:NewToken( "err", "error" )

	-- DECLERATION:

		elseif RawData == "global" then
			return self:NewToken( "glo", "global" )
		elseif RawData == "input" then
			return self:NewToken( "in", "input" )
		elseif RawData == "output" then
			return self:NewToken( "out", "output" )
		elseif RawData == "static" then
			return self:NewToken( "stc", "static" )
	
	-- VARIABLE:
	
		elseif RawData[1] == RawData[1]:upper( ) then
			return self:NewToken( "var", "variable" )
		end
	
	-- FUNCTION:
	
		return self:NewToken( "fun", "function")
	end
end

/*==============================================================================================
	Section: Generate Token
==============================================================================================*/

function Compiler:GetNextToken( )
	if self.Char then

		self:SkipSpaces( )

		self:SkipComments( )
		
		if self.SkipToken then
			self.SkipToken = false
			return self:GetNextToken( )
		end
		
		local Token = self:WordToken( ) or self:DataToken( )
		
		if Token then
			return Token
		end
		
		for I = 1, #self.RawTokens do
			local Token = self.RawTokens[I]

			if self:NextPattern( Token[1], true ) then
				return self:NewToken( Token[2], Token[3] )
			end
		end
		
		if !self.Char or self.Char == "" then
			self.Char = nil
		else
			self:Error( 0, "Unknown syntax found (%s)", self.ReadData .. tostring(self.Char) )
		end
	end
end