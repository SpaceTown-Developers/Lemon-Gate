/*==============================================================================================
	Expression Advanced: Lemon Gate Tokenizer.
	Purpose: Converts Code To Tokens.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local E_A = LemonGate
local CheckType = E_A.CheckType

/*==============================================================================================
	Section: Token Functions!
==============================================================================================*/
local Tokens, OpTokens, SizeT = {}, {}, 1

function E_A:CreateToken(Patern, Tag,  Name)
	CheckType(Patern, "string", 1); CheckType(Tag, "string", 2); CheckType(Name, "string", 3)
	-- Purpose: Create a new token.
	
	Tokens[Name] = {Patern, Tag, Name or "Unknown Token"}
end

function E_A:CreateOpToken(Patern, Tag,  Name)
	CheckType(Patern, "string", 1); CheckType(Tag, "string", 2); CheckType(Name, "string", 3)
	-- Purpose: Create a new token.
		
	local Token = {Patern, Tag, Name or "Unknown Token"}
	Tokens[Name] = Token; OpTokens[SizeT] = Token; SizeT = SizeT + 1
end

/*==============================================================================================
	Section: Tokens
==============================================================================================*/

-- Number Tokens
E_A:CreateToken("^0x[%x]+", "num", "hex")
E_A:CreateToken("^0b[01]+", "num", "bin")
E_A:CreateToken("^%d+%.?%d*", "num", "real")

-- Function and variables
E_A:CreateToken("^%u[%a%d_]*", "var", "variable")
E_A:CreateToken("^%l[%a%d_]*", "fun", "function")
E_A:CreateToken("", "str", "string")

-- Keyword Tokens
E_A:CreateToken("if", "if", "if")
E_A:CreateToken("elseif", "eif", "else if")
E_A:CreateToken("else", "els", "else")
E_A:CreateToken("while", "whl", "while")
E_A:CreateToken("for", "for", "for")
E_A:CreateToken("foreach", "each", "foreach")
E_A:CreateToken("function", "func", "function constructor")
E_A:CreateToken("switch", "swh", "switch")
E_A:CreateToken("event", "evt", "event constructor")
E_A:CreateToken("try", "try", "try")
E_A:CreateToken("catch", "cth", "catch")

-- Sub KeyWords
E_A:CreateToken("break", "brk", "break")
E_A:CreateToken("continue", "cnt", "continue")
E_A:CreateToken("return", "ret", "return")
E_A:CreateToken("error", "err", "error")

-- Decleration KeyWords
E_A:CreateToken("global", "glob", "global")
E_A:CreateToken("input", "in", "input")
E_A:CreateToken("output", "out", "output")
E_A:CreateToken("persist", "per", "persist")

-- Maths
E_A:CreateOpToken("+", "add", "addition")
E_A:CreateOpToken("-", "sub", "subtract")
E_A:CreateOpToken("*", "mul", "multiplier")
E_A:CreateOpToken("/", "div", "division")
E_A:CreateOpToken("%", "mod", "modulus")
E_A:CreateOpToken("^", "exp", "power")
E_A:CreateOpToken("=", "ass", "assign")
E_A:CreateOpToken("+=", "aadd", "increase")
E_A:CreateOpToken("-=", "asub", "decrease")
E_A:CreateOpToken("*=", "amul", "multiplier")
E_A:CreateOpToken("/=", "adiv", "division")
E_A:CreateOpToken("++", "inc", "increment")
E_A:CreateOpToken("--", "dec", "decrement")

-- Comparison
E_A:CreateOpToken("==", "eq", "equal")
E_A:CreateOpToken("!=", "neq", "unequal")
E_A:CreateOpToken("<", "lth", "less")
E_A:CreateOpToken("<=", "leq", "less or equal")
E_A:CreateOpToken(">", "gth", "greater")
E_A:CreateOpToken(">=", "geq", "greater or equal")

-- Bitwise
E_A:CreateOpToken("&", "band", "and")
E_A:CreateOpToken("|", "bor", "or")
E_A:CreateOpToken("^^", "bxor", "or")
E_A:CreateOpToken(">>", "bshr", ">>")
E_A:CreateOpToken("<<", "bshl", "<<")

-- Condition
E_A:CreateOpToken("!", "not", "not")
E_A:CreateOpToken("&&", "and", "and")
E_A:CreateOpToken("||", "or", "or")

-- Symbols
E_A:CreateOpToken("?", "qsm", "?")
E_A:CreateOpToken(":", "col", "colon")
-- E_A:CreateToken("?:", "def", "?:")
E_A:CreateOpToken(",", "com", "comma")
E_A:CreateOpToken("$", "dlt", "delta")
E_A:CreateOpToken("#", "len", "length")

-- Brackets
E_A:CreateOpToken("(", "lpa", "left parenthesis")
E_A:CreateOpToken(")", "rpa", "right parenthesis")
E_A:CreateOpToken("{", "lcb", "left curly bracket")
E_A:CreateOpToken("}", "rcb", "right curly bracket")
E_A:CreateOpToken("[", "lsb", "left square bracket")
E_A:CreateOpToken("]", "rsb", "right square bracket")

E_A.API.CallHook("BuildTokens") -- Extensions can create there own tokens!

-- Lets sort the tokens!
table.sort(OpTokens, function(Token, Token2) return #Token[1] > #Token2[1] end)
E_A.Tokens = Tokens
E_A.OpTable = OpTokens


/*==============================================================================================
	Section: Tokenizer
==============================================================================================*/
local Toker = E_A.Tokenizer
Toker.__index = Toker


function Toker.Execute(...)
	-- Purpose: Executes the Tokenizer.
	
	local Instance = setmetatable({}, Toker)
	return pcall(Toker.Run, Instance, ...)
end

function Toker:Run(Code)
	--Purpose: Tokenize the code.
	
	self.Tokens = {}
	
	self.Pos, self.ReadChar, self.ReadLine = 0, 0, 1
	self.Char, self.ReadData = "", "", ""
	self.Buffer, self.Len = Code, #Code
	
	self:NextChar()
	
	while self.Char do
	
		self.InfoToken = nil
		self.NoToken = nil

		self:SkipSpaces()
		
		self:NextToken()

		self:SkipSpaces()
		
		if self.Char == "" then self.Char = nil end
		
		if self.Char and !self.InfoToken and !self.NoToken then
			self:Error("Unknown syntax found (%s)", 0, self.ReadData .. tostring(self.Char))
		end
	end
	
	return self.Tokens
end

local FormatStr = string.format -- Speed

function Toker:Error(Message, Offset, ...)
	-- Purpose: Create and push a syntax error.
	
	Offset = Offset or 0
	error( FormatStr(Message .. " at line %i, char %i", ..., self.ReadLine, self.ReadChar + Offset), 0) 
end


function Toker:AddToken(Token)
	-- Purpose: Add a token to the tokens table
	
	Token = Token or self.InfoToken
	self.Tokens[#self.Tokens+1] = {Token , self.ReadData, self.ReadLine, self.ReadChar}
	self.ReadData = ""
	self.NoToken = self.InfoToken and false or true
end

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

local ExplodeStr = string.Explode -- Speed

function Toker:NextPattern(Pattern, Exact)
	-- Purpose: Finds the next pattern on the buffer.

	if !self.Char then return false end
	local Start, End, String = self.Buffer:find(Pattern, self.Pos, Exact)
	
	if Start ~= self.Pos then return false end
	if !String then String = self.Buffer:sub(Start, End) end
	
	self.ReadData = self.ReadData .. String
	self.Pos = End + 1
	
	if self.Len >= self.Pos then
		self.Char = self.Buffer:sub(self.Pos, self.Pos)
	else
		self.Char = nil
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

function Toker:SkipSpaces()
	-- Purpose: Skip spaces in the buffer.

--	self.ReadData = ""
	self:NextPattern("^[%s\n]*")
	self.ReadData = ""
	return self.ReadData
end


function Toker:IsToken(Name, Exact)
	-- Purpose: Check if data matches token
	
	local Token = Tokens[Name]
	if !Token then return false end
	
	if self:NextPattern(Token[1], Exact) then
		self.InfoToken = Token
		return true
	end
	
	self.InfoToken = nil
	return false
end

local pairs = pairs -- Speed

local LimitString = E_A.LimitString -- Speed

function Toker:NextToken()
	-- Get the next token from the buffer
	
	if !self.Char then return end
	
	-- Numbers
	if self:IsToken("hex") then
		self.ReadData = tonumber(self.ReadData) or self:Error("Invalid number format (%s)", 0, self.ReadData)
	
	elseif self:IsToken("bin") then
		self.ReadData = tonumber(self.ReadData:sub(3), 2) or self:Error("Invalid number format (%s)", 0, self.ReadData)
	
	elseif self:IsToken("real") then
		self.ReadData = tonumber(self.ReadData) or self:Error("Invalid number format (%s)", 0, self.ReadData)
	end
	
	if self.InfoToken then
		return self:AddToken()
	end
	
	
	-- KeyWords
	if self:IsToken("if", true) or
	   self:IsToken("else if", true) or
	   self:IsToken("else", true) or
	   self:IsToken("while", true) or
	   self:IsToken("foreach", true) or
	   self:IsToken("for", true) or
	   self:IsToken("function constructor", true) or
	   self:IsToken("switch", true) or
	   self:IsToken("catch", true) or
	   self:IsToken("try", true) or
	   self:IsToken("event constructor", true) then

	-- Sub KeyWord
	elseif self:IsToken("break", true) or
		   self:IsToken("continue", true) or
		   self:IsToken("return", true) or
		   self:IsToken("error", true) then
	
	-- Declaration Types
	elseif self:IsToken("global", true) or
		   self:IsToken("input", true) or
		   self:IsToken("output", true) then
	
	-- Function / Variable
	elseif self:IsToken("function") or
		   self:IsToken("variable") then
	end
	
	if self.InfoToken then
		return self:AddToken()
	end
	
	-- Comments
	local CommentStyle
	
	if self:NextPattern("//", true) then
		CommentStyle = "\n"
	elseif self:NextPattern("/*", true) then
		CommentStyle = "*/"
	end
	
	if CommentStyle then
		while !self:NextPattern(CommentStyle, true) do
			
			if !self.Char and CommentStyle == "*/" then
				self:Error("Unterminated multiline comment (/*%s)", 0, LimitString(self.ReadData, 10))
			end
			
			self:SkipChar()
		end
		
		self.ReadData = ""
		self.NoToken = true

		return
	end
	
	for I = 1, #OpTokens do
		if self:NextPattern(OpTokens[I][1], true) then
			return self:AddToken( OpTokens[I] )
		end
	end
	
	
	-- Strings
	local StringType
	
	if self.Char == "\"" then
		StringType = "\""
	elseif self.Char == "'" then
		StringType = "'"
	end
	
	if StringType then
		
		self:SkipChar()
		
		while self.Char do
			if self.Char == StringType then
				break
			else
				self:NextChar()
			end
		end

		if self.Char ~= StringType then
			self:Error("Unterminated string (\"%s)", 0, LimitString(self.ReadData, 10))
		end
		
		self:SkipChar()
		
		return self:AddToken( Tokens["string"] )
	end

	
end


