/*==============================================================================================
	Expression Advanced: Lemon Gate Tokenizer.
	Purpose: Converts Code To Tokens.
	Creditors: Rusketh, Oskar94
==============================================================================================*/

local E_A = LemonGate
-- local API = E_A.API.Tokenizer -- Todo: This

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
			self:Error("Unknown syntax found (%s)", 0, E_A.LimitString(self.ReadData .. tostring(self.Char), 10))
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

local Tokens = E_A.TokenTable -- Speed

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

local Ops = E_A.OpTableIdx -- Speed

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
		
		-- local ErrorPos = self.ReadData:match("^0()[0-9]") or self.ReadData:find("%.$")
		
		-- if self:NextPattern("^[eE][+-]?[0-9][0-9]*") then
			-- ErrorPos = ErrorPos or self.ReadData:match("[eE][+-]?()0[0-9]")
		-- end
		
		-- self:NextPattern("^[ijk]")
		-- if self:NextPattern("^[a-zA-Z_]") then
			-- ErrorPos = ErrorPos or #self.ReadData
		-- end
		
		-- if ErrorPos then
			-- self:Error("Invalid number format (%s)", ErrorPos - 1, self.ReadData)
		-- end
	end
	
	if self.InfoToken then
		return self:AddToken()
	end
	
	
	-- KeyWords
	if self:IsToken("if", true) then
	elseif self:IsToken("else if", true) then
	elseif self:IsToken("else", true) then
	elseif self:IsToken("while", true) then
	elseif self:IsToken("for", true) then
	elseif self:IsToken("function constructor", true) then
	elseif self:IsToken("switch", true) then
	elseif self:IsToken("catch", true) then
	
	-- Sub KeyWord
	elseif self:IsToken("break", true) then
	elseif self:IsToken("continue", true) then
	elseif self:IsToken("return", true) then
	elseif self:IsToken("error", true) then
	
	-- Decleration Types
	elseif self:IsToken("local", true) then
	elseif self:IsToken("input", true) then
	elseif self:IsToken("output", true) then
	elseif self:IsToken("persistant", true) then
	
	-- Function / Variable
	elseif self:IsToken("function") then
	elseif self:IsToken("variable") then
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
	
	for I = 1, #Ops do
		if self:NextPattern(Ops[I][1], true) then
			return self:AddToken( Ops[I] )
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


