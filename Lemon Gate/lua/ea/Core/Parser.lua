/*==============================================================================================
	Expression Advanced: Lemon Gate Parser.
	Purpose: Converts Tokens To Instructions.
	Creditors: Rusketh
==============================================================================================*/
/*
	(BNF) Syntax Grammar:
		Root:
			1: q1
		
		seQuencing:
			1: ""
			2: "s1 q1", "s1, q2"
		
		Statment:
			1: [input, output, global] type var[, ...] = e1[, ...]
			2: if e1 { q1 } i1
			3: var++, var--
			4: var = e1, var += e1, var -= e1, var *= e1, var /= e1
			5: var[e1,type] = e1, var[e1,type] += e1, var[e1,type] -= e1, var[e1,type] *= e1, var[e1,type] /= e1
		If
			1: elseif (e1) { q1 } i1
			2: else { q1 }

		Expression
			1: e1 | e2, e1 & e2
			2: e6 == e7, e6 != e7
			3: e6 < e7, e6 > e7, e6 <= e7, e6 >= e7
			4: e1 || e2, e1 && e1 -- Binary Logic
			5: e1 << e2, e1 >> e2, e1 ^^ e2 -- Binary Shift
			6: e6 + e7, e6 - e7
			7: e6 * e7, e6 / e7, e6 % e7
			8: e6 ^ e7
			19: +e11, -e11, !e10
			10: e11:fun([e1, ...]), e11[var,type]
			11: string, num, ~var
			12: var
			13: (e1)

				
*/

local E_A = LemonGate

local GetLongType = E_A.GetLongType
local GetShortType = E_A.GetShortType

local Parser = E_A.Parser
Parser.__index = Parser


function Parser.Execute(...)
	-- Purpose: Executes the Parser.
	
	local Instance = setmetatable({}, Parser)
	return pcall(Parser.Run, Instance, ...)
end

function Parser:Run(Tokens)
	--Purpose: Run the Parser.
	
	local Count = #Tokens
	if Count == 0 then -- No code lets just return a blank instruction.
		return self:Instruction("sequence", {1, 1}, {}, 0)
	end
	
	self.Tokens = Tokens
	self.TotalTokens = Count
	
	self.LoopDepth = 0
	
	self.Pos = -1
	self:NextToken()
	
	return self:GetStatments()
end

local FormatStr = string.format -- Speed

function Parser:Error(Message, Info, ...)
	-- Purpose: Create and push a syntax error.
	
	if Info then Message = FormatStr(Message, Info, ...) end
	error( FormatStr(Message .. " at line %i, char %i", self.TokenLine, self.TokenChar), 0)
end

function Parser:TokenError(Trace, Message, ...)
	-- Purpose: Create a syntax error at a given token.

	self.TokenLine = Trace[1]
	self.TokenChar = Trace[2]

	self:Error(Message, ...)
end

function Parser:NextToken()
	-- Purpose: Get the next token from the token list.
	
	local Pos = self.Pos + 1
	
	if Pos > 0 and Pos <= self.TotalTokens then
		self.Token = self.Tokens[Pos]
		self.TokenData = self.Token[2]
		self.TokenLine = self.Token[3]
		self.TokenChar = self.Token[4]
		self.TokenName = self.Token[1][3]
		
		local ReadToken = self.Tokens[Pos + 1]
		if ReadToken then -- Next token information.
			self.NextLine = ReadToken[3]
			
			ReadToken = ReadToken[1]
			self.NextTokenType = ReadToken[2]
			self.NextTokenName = ReadToken[3]
		end
		
	else
		self.Token = nil
		self.TokenData = nil
		self.ReadToken =  nil
		self.TokenName = "Null Token"
		
		if Pos > 0 then
			self.NextLine = nil
			self.NextTokenType = nil
			self.NextTokenName = nil
			
			self.TokenLine = 0
			self.TokenChar = 0
		else
			local ReadToken = self.Tokens[1]
			self.NextLine = ReadToken[3]
			
			ReadToken = ReadToken[1]
			self.NextTokenType = ReadToken[2]
			self.NextTokenName = ReadToken[3]
			
			self.TokenLine = 1
			self.TokenChar = 1
			self.NextLine = 2
			
			Pos = 0
		end
	end
	
	self.Pos = Pos
end

function Parser:PrevToken()
	-- Purpose: Move backwards one token on the token list.
	
	local OPos = self.Pos
	self.Pos = self.Pos - 2
	
	self:NextToken()
end

function Parser:HasTokens()
	-- Purpose: Checks to see of we have any tokens left.
	
	if self.Pos < self.TotalTokens then return true end
end

function Parser:TokenTrace()
	-- Purpose: Traces the Origin of a token.
	
	return {self.TokenLine, self.TokenChar, self.Pos}
end

function Parser:ThisToken(Name)
	-- Purpose: Checks the curent token.
	
	local Token = self.Token
	if !Token then return false end
	return Token[1][2] == Name
end

function Parser:AcceptToken(Name)
	-- Purpose: Is this token of this type.

	if !self.NextTokenType then return false end

	if self.NextTokenType == Name then
		self:NextToken()
		return true
	end
end

function Parser:CheckToken(Name)
	-- Purpose: Checks a token with out loading it.
	
	if !self.NextTokenType then return false end
	return self.NextTokenType == Name
end

function Parser:RequireToken(Name, Message, ...)
	-- Purpose: If this token is not acceptable then error.

	if !self:AcceptToken(Name) then
		self:Error(Message, ...)
	end
end

function Parser:ExcludeToken(Name, Message, ...)
	-- Purpose: Error if this token is avalible.

	if self:AcceptToken(Name) then
		self:Error(Message, ...)
	end
end

function Parser:Instruction(Name, Trace, ...)
	-- Purpose: Creates an instruction.
	
	return {Name, Trace, {...}}
end

/*==============================================================================================
	Section: Util Functions
	Purpose: These are here to make my life easyer.
	Creditors: Rusketh
==============================================================================================*/
local Types = E_A.TypeTable -- Lookup table of types.
local LimitString = E_A.LimitString -- Speed

function Parser:StrictType(Message)
	-- Purpose: Gets a variable type for use in function arguments and indexing operators
	
	if !self:AcceptToken("fun") and !self:AcceptToken("func") then
		if !Message then return end -- We didnt supply an error message we assume this is not needed.
		self:Error(Message)
	end
	
	local Type = Types[ self.TokenData ]
	if !Type then self:Error("Uknown variabel type (%s)", LimitString(self.TokenData, 10)) end
	
	return Type[2], Type
end

function Parser:IndexingList()
	
	if self:AcceptToken("lsb") then
		local Trace = self:TokenTrace()
		local Expression = self:Expression()

		if self:AcceptToken("com") then
			local Type = self:StrictType("variabel type expected after comma (,) in indexing operator, got (%s)")
			if !Type then
				self:Error("Indexing operator ([]) requires a lower case type [Index,type]")
			elseif !self:AcceptToken("rsb") then
				self:Error("Right square bracket (]) missing, to close indexing operator [Index,type]")
			end
			
			return {Expression, Type, Trace}, self:IndexingList()

		elseif self:AcceptToken("rsb") then
			return {exp, nil, Trace}
		else
			self:Error("Indexing operator ([]) must not be preceded by whitespace")
		end
	end
end

function Parser:SpoofToken(Token, Trace)
	-- Purpose: Tricks the compiler into thinking we are using a differnt token.
	
	self.RealToken = self.Token -- We Backs this up!
	
	self.Token = Token -- Note: Now we fake the token.
	self.ReadToken = Token[1]
	self.TokenData = Token[2]
	self.TokenName = self.ReadToken[3]
	
	if Trace then -- Note: We might want to fake the token location.
		self.TokenLine = Trace[1]
		self.TokenChar = Trace[2]
	else
		self.TokenLine = Token[3]
		self.TokenChar = Token[4]
	end
end

function Parser:UnspoofToken()
	-- Purpose: Untricks the compiler and restors the real token.
	
	local Token = self.RealToken
	
	if Token then
		self:SpoofToken(Token)
		self.RealToken = nil
	end
end

/*==============================================================================================
	Section: Expressions
	Purpose: Performs equations and logic.
	Creditors: Rusketh
==============================================================================================*/
function Parser:Expression()
	
	local Trace = self:TokenTrace()
	
	if !self:HasTokens() then
		return
		
	elseif self:AcceptToken("var") then
		-- Lets strip out bad operators
		
		self:ExcludeToken("ass", "Assigment operator (=), can't be part of Expression")
		self:ExcludeToken("aadd", "Additive assignment operator (+=), can't be part of Expression")
		self:ExcludeToken("asub", "Subtractive assignment operator (-=), can't be part of Expression")
		self:ExcludeToken("amul", "Multiplicative assignment operator (*=), can't be part of Expression")
		self:ExcludeToken("adiv", "Divisive assignment operator (/=), can't be part of Expression")
		
		self:ExcludeToken("inc", "Increment operator (++), can't be part of Expression")
		self:ExcludeToken("inc", "Decrement operator (--), can't be part of Expression")
		
		self:PrevToken()
	end
	
	if !self:AcceptToken("lpa") then
		
		local ParentTrace = self.ExprTrace
		self.ExprTrace = self:TokenTrace() -- The Child trace takes over!
		
		local Expression = self:Operators( self:ExpressionValue() ) -- Get a value
		
		self.ExprTrace = ParentTrace -- The parent trace returns.
		
		return Expression
	
	elseif self:AcceptToken("fun") or self:AcceptToken("func") then
		if self:CheckToken("rpa") then
			self:PrevToken() -- Note: Move back to the type token
			
			local Type = self:StrictType("type expected for casting operator ((type))")
			self:NextToken() -- Note: Skipp the rpa token or it will kill the next Expression.
			
			return self:Instruction("cast", Trace, Type, self:Expression())
		end
		
		self:PrevToken()
	end
	
	-- Note: Grouped ( grouped equation )
	
	local Trace = self:TokenTrace()
	local Expression = self:Expression()
	
	if !self:AcceptToken("rpa") then
		self:TokenError(Trace, "Right parenthesis ()) missing, to close grouped equation")
	end
	
	return self:Operators( Expression )
end

/********************************************************************************************************************/

function Parser:ExpressionValue()
	-- Purpose: Gets a value checking for prefixed operators.
	
	local Trace = self:TokenTrace()
	
	if self:AcceptToken("add") then -- add +Num
		if !self:HasTokens() then self:Error("Identity operator (+) must not be succeeded by whitespace") end
		return self:Expression()
		
	elseif self:AcceptToken("sub") then -- sub -Num
		if !self:HasTokens() then self:Error("Negation operator (-) must not be succeeded by whitespace") end
		return self:Instruction("negative", Trace, self:Expression())
	
	elseif self:AcceptToken("not") then -- not !Num
		if !self:HasTokens() then self:Error("Logical not operator (!) must not be succeeded by whitespace") end
		return self:Instruction("not", Trace, self:Expression())
		
	elseif self:AcceptToken("len") then -- len #String
		if !self:HasTokens() then self:Error("Lengh operator (#) must not be succeeded by whitespace") end
		return self:Instruction("lenth", Trace, self:Expression())
	
	elseif self:AcceptToken("dlt") then -- dlt ~Num
		if !self:HasTokens() then 
			self:Error("Delta operator (~) must not be succeeded by whitespace")
		elseif !self:AcceptToken("var") then
			self:Error("variabel expected, after Delta operator (~)")
		end
		
		return self:Instruction("delta", Trace, self.TokenData)
	end
	
	return self:GetValue()
end

/********************************************************************************************************************/

function Parser:Operators(Expr)
	-- Purpose: Get and use operators for arithmatic, comparason, binary.
	
	if self:AcceptToken("exp") then -- exp ^ Power
		return self:Instruction("exponent", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("mul") then -- mul * Multiply
		return self:Instruction("multiply", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("div") then -- div \ Divide
		return self:Instruction("divide", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("mod") then -- mod % Modulus
		return self:Instruction("modulus", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("add") then -- add % Addition
		return self:Instruction("addition", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("sub") then -- sub % Addition
		return self:Instruction("subtraction", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("bshr") then -- bshr >>
		return self:Instruction("binary_shift_right", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("bshl") then -- bshrl <<
		return self:Instruction("binary_shift_left", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("gth") then -- gth >
		return self:Instruction("greater_than", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("lth") then -- lth <
		return self:Instruction("less_than", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("geq") then -- geq >=
		return self:Instruction("greater_equal", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("leq") then -- leq <=
		return self:Instruction("less_equal", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("neq") then -- neq !=
		return self:Instruction("not_equal", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("eq") then -- eq ==
		return self:Instruction("equal", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("bxor") then -- bxor ^^
		return self:Instruction("binary_xor", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("band") then -- band &&
		return self:Instruction("binary_and", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("bor") then -- bor ||
		return self:Instruction("binary_or", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("and") then -- and &
		return self:Instruction("and", self:TokenTrace(), Expr, self:Expression())
		
	elseif self:AcceptToken("or") then -- or |
		return self:Instruction("or", self:TokenTrace(), Expr, self:Expression())
	end
	
	return Expr
end

/********************************************************************************************************************/
local type = type -- Speed
local Match = string.match -- Speed

function Parser:GetNumber(NoOp)
	if self:AcceptToken("num") then
		-- Section: Create a number from a number token.
		
		local Num = self.TokenData
		if type(Num) == "number" then
			if !NoOp then
				return self:Instruction("number", self:TokenTrace(), Num)
			else
				return Num
			end
		end
		
		local Num, Type = Match(Num, "^([-+e0-9.]*)(.*)$")
		
		if !NoOp then
			return self:Instruction("number" .. Type, self:TokenTrace(), Num)
		else
			return Num
		end
	end
end

function Parser:GetValue()
	-- Purpose: Gets a build up of instructions that will become a value.
	
	local Trace, Instr = self:TokenTrace()
	
	if self:CheckToken("num") then
		return self:GetNumber()
		
	elseif self:AcceptToken("str") then
		-- Section: Create a string from a string token.
		
		return self:Instruction("string", Trace, self.TokenData)
	
	elseif self:AcceptToken("var") then
		-- Section: Grabe a var from a var token.
		
		Instr = self:Instruction("variabel", Trace, self.TokenData)
		
	elseif self:AcceptToken("fun") then
		-- Section: We are going to getting a function.
		
		local Function = self.TokenData
		
		if self:AcceptToken("lpa") then
			-- Section: We are calling this function.
			
			local Permaters = {}
			
			if !self:CheckToken("rpa") then
				Permaters[1] = self:Expression() 
				local Index = 1 -- Note: Faster to do it here then use count.
				
				while self:AcceptToken("com") do
					Index = Index + 1
					Permaters[Index] = self:Expression()
				end
			end
			
			if !self:AcceptToken("rpa") then
				self:Error("Right parenthesis ()) missing, to close function perameters")
			end
			
			Instr = self:Instruction("function", Trace, Function, Permaters)
		end
	end
	
	if !Instr then self:ExpressionError() end
	
	while true do
		-- Note: Lets check for methods {{Value:method()}}.
		
		if self:AcceptToken("col") then
			local Trace = self:TokenTrace() 
			
			if !self:AcceptToken("fun") then self:Error("Method operator (:) must be followed by method name") end
			
			local Function = self.TokenData
			
			if !self:AcceptToken("lpa") then self:Error("Left parenthesis (() missing, after method name") end
	
			local Permaters = {Instr}
			
			if !self:CheckToken("rpa") then
				Permaters[2] = self:Expression() 
				local Index = 2 -- Note: Faster to do it here then use count.
				
				while self:AcceptToken("com") do
					Index = Index + 1
					Permaters[Index] = self:Expression()
				end
			end
			
			if !self:AcceptToken("rpa") then
				self:Error("Right parenthesis ()) missing, to close method perameters")
			end
			
			Instr = self:Instruction("method", Trace, Function, Permaters)
		
		-- Note: Now we check for Index operators {{Value[1, number]}}.
		elseif self:AcceptToken("lsb") then
			local Trace, Index = self:TokenTrace(), self:Expression()
			
			if self:AcceptToken("com") then
				local Type = self:StrictType("variabel type expected after comma (,) in indexing operator, got (%s)")
				if !Type then self:Error("Indexing operator ([]) requires a lower case type [Index,type]") end
				Instr = self:Instruction("get", Trace, Instr, Index, Type)
			else
				Instr = self:Instruction("get", Trace, Instr, Index)
			end
			
			if !self:AcceptToken("rsb") then self:Error("Right square bracket (]) missing, to close indexing operator [Index,type]") end
		
		-- Note: Now we check for the unlikly event of using a call operator {{Value()}}.
		elseif self:AcceptToken("lpa") then
			local Permaters = {}
			
			if !self:AcceptToken("rpa") then
				Permaters[1] = self:Expression() 
				local Index = 1 -- Note: Faster to do it here then use count.
				
				while self:AcceptToken("com") do
					Index = Index + 1
					Permaters[Index] = self:Expression()
				end
			end
			
			if !self:AcceptToken("rpa") then
				self:Error("Right parenthesis ()) missing, to close call perameters")
			end
			
			Instr = self:Instruction("call", Trace, Instr, Permaters)
		else
			
			-- Note: We leave this loop now!
			break
		end
	end
	
	return Instr
end

/********************************************************************************************************************/

function Parser:ExpressionError()
	-- Purpose: Reports Errors. Also taken from E2 because Rusketh is lazy =D
	
	if self:HasTokens() then
		self:ExcludeToken("add", "Addition operator (+) must be preceded by equation or value")
		self:ExcludeToken("sub", "Subtraction operator (-) must be preceded by equation or value")
		self:ExcludeToken("mul", "Multiplication operator (*) must be preceded by equation or value")
		self:ExcludeToken("div", "Division operator (/) must be preceded by equation or value")
		self:ExcludeToken("mod", "Modulo operator (%) must be preceded by equation or value")
		self:ExcludeToken("exp", "Exponentiation operator (^) must be preceded by equation or value")

		self:ExcludeToken("ass", "Assignment operator (=) must be preceded by variable")
		self:ExcludeToken("aadd", "Additive assignment operator (+=) must be preceded by variable")
		self:ExcludeToken("asub", "Subtractive assignment operator (-=) must be preceded by variable")
		self:ExcludeToken("amul", "Multiplicative assignment operator (*=) must be preceded by variable")
		self:ExcludeToken("adiv", "Divisive assignment operator (/=) must be preceded by variable")

		self:ExcludeToken("and", "Logical and operator (&&) must be preceded by equation or value")
		self:ExcludeToken("or", "Logical or operator (!|) must be preceded by equation or value")

		self:ExcludeToken("eq", "Equality operator (==) must be preceded by equation or value")
		self:ExcludeToken("neq", "Inequality operator (!=) must be preceded by equation or value")
		self:ExcludeToken("gth", "Greater than or equal to operator (>=) must be preceded by equation or value")
		self:ExcludeToken("lth", "Less than or equal to operator (<=) must be preceded by equation or value")
		self:ExcludeToken("geq", "Greater than operator (>) must be preceded by equation or value")
		self:ExcludeToken("leq", "Less than operator (<) must be preceded by equation or value")

		self:ExcludeToken("inc", "Increment operator (++) must be preceded by variable")
		self:ExcludeToken("dec", "Decrement operator (--) must be preceded by variable")

		self:ExcludeToken("rpa", "Right parenthesis ()) without matching left parenthesis")
		self:ExcludeToken("lcb", "Left curly bracket ({) must be part of an if/while/for-statement block")
		self:ExcludeToken("rcb", "Right curly bracket (}) without matching left curly bracket")
		self:ExcludeToken("lsb", "Left square bracket ([) must be preceded by variable")
		self:ExcludeToken("rsb", "Right square bracket (]) without matching left square bracket")

		self:ExcludeToken("com", "Comma (,) not expected here, missing an argument?")
		self:ExcludeToken("col", "Method operator (:) must not be preceded by whitespace")

		self:ExcludeToken("if", "If keyword (if) must not appear inside an equation")
		self:ExcludeToken("eif", "Else-if keyword (elseif) must be part of an if-statement")
		self:ExcludeToken("els", "Else keyword (else) must be part of an if-statement")

		self:Error("Unexpected token found (%s)", self.NextTokenName)
	else
		self:TokenError(self.ExprTrace, "Further input required at end of code, incomplete expression")
	end
end

/********************************************************************************************************************/

function Parser:Condition()
	if self:AcceptToken("lpa") then
		local Expression = self:Expression()
		if !self:AcceptToken("rpa") then self:Error("Right parenthesis ()) missing, to close condition") end
		return Expression
	else
		self:Error("Left parenthesis (() missing, to open condition")
	end
end

/*==============================================================================================
	Section: Statments
	Purpose: Statments do stuffs.
	Creditors: Rusketh
==============================================================================================*/
function Parser:GetStatments(ExitToken)
	local Statments, Index = {}, 0
	local Instruction = self:Instruction("sequence", self:TokenTrace(), Statments)

	if ExitToken and self:AcceptToken(ExitToken) then
		self:PrevToken()
		return Instruction
	elseif !self:HasTokens() then
		return Instruction
	end
	
	while true do
		if self:AcceptToken("com") then self:Error("Separator (,) must not appear twice.") end
	
		Index = Index + 1
		Statments[Index] = self:Statment() 
		
		if ExitToken and self:AcceptToken(ExitToken) then
			self:PrevToken()
			break -- Note: Exit because we have found out exit token
			
		elseif !self:HasTokens() then
			break -- Note: No tokens left so exit
			
		elseif !self:AcceptToken("com") and self.NextLine == self.TokenLine then
			self:Error("Statements must be separated by comma (,) or whitespace")
		end
	end
	
	return Instruction
end

function Parser:Statment()
	if self:AcceptToken("if") then
		return self:Instruction("if", self:TokenTrace(), self:Condition(), self:Block("if condition"), self:ElseIf())
	
	elseif self:CheckToken("for") then
		return self:ForLoop()
		
	elseif self:CheckToken("whl") then
		return self:WhileLoop()
	
	elseif self:CheckToken("brk") or self:CheckToken("cnt") or self:CheckToken("ret") then
		return self:ExitStatment()
	end
	
	return self:FunctionStatment() or self:EventStatment() or self:VariableStatment() or self:Expression()
end

/*==============================================================================================
	Section: Variable Declaration
	Purpose: We can declair variables here =D.
	Example: input number Var1, Var2, Var3 = 1, 2 -- Note: 3 is missing =D
	Creditors: Rusketh
==============================================================================================*/
function Parser:VariableDeclaration()
	local Trace, Special = self:TokenTrace()
	
	if self:AcceptToken("glob") then
		Special = "global" -- Global
	elseif self:AcceptToken("in") then
		Special = "input" -- Input
	elseif self:AcceptToken("out") then
		Special = "output" -- Output
	end
	
	self:NextToken() -- Note: Check ahead.
	local Predict = self:CheckToken("var")
	self:PrevToken()
	
	if Predict then
		local Type = self:StrictType()
		
		if Type then
			
			if Type == "function" then -- Functions are not variabels
				self:Error("assigment operator (=), does not support 'functions'")
			elseif !self:AcceptToken("var") then
				self:Error("Variable expected after type (%s), for variabel decleration", Type)
			end
			
			local Vars, Index = {self.TokenData}, 1

			while self:AcceptToken("com") do
				if !self:AcceptToken("var") then self:Error("Variable expected after comma (,)", Type) end
				Index = Index + 1
				Vars[Index] = self.TokenData
			end
			
			local Stmts, I = {}, 1

			if self:AcceptToken("ass") then
				while I <= Index do
					Stmts[I] = self:Instruction("assign_declare", Trace, Vars[I], self:Expression(), Type, Special)
					I = I + 1
					
					if !self:AcceptToken("com") then break end
				end
			end
			
			while I <= Index do
				Stmts[I] = self:Instruction("assign_default", Trace, Vars[I], Type, Special)
				I = I + 1
			end

			return self:Instruction("sequence", Trace, Stmts)
		end
	end
	
	if Special then
		self:Error("Variable type expected, after %s.", Special)
	end
end

/*==============================================================================================
	Section: Variable Statment
	Purpose: If we have an operator that is prefixed by a variable then we handel that here.
	Example: Var = 10, Var += 10, Var -= 10, Var++, var-- (etc)
	Creditors: Rusketh
==============================================================================================*/
local AssigmentInstructions = {aadd = "addition", asub = "subtraction", amul = "multiply", adiv = "divide"}

function Parser:VariableStatment(NoDec)
	if self:AcceptToken("var") then
		local Trace, Var = self:TokenTrace(), self.TokenData
		
		if self:AcceptToken("inc") then -- Increment operator
			return self:Instruction("incremet", Trace, Var)
			
		elseif self:AcceptToken("dec") then -- Decrement operator
			return self:Instruction("decrement", Trace, Var)
			
		elseif self:CheckToken("lsb") then -- Indexing operator
			self:PrevToken()
			return self:IndexedStatment()
		
		else
			
			local Stmts, Vars, Index = {}, {Var}, 1
			
			while self:AcceptToken("com") do
				if !self:AcceptToken("var") then
					self:Error("Variable expected after comma (,)", Type)
				else
					Index = Index + 1
					Vars[Index] = self.TokenData
				end
			end
			
			if self:AcceptToken("ass") then -- Assigmnet Operator
				for I = 1, Index do
					Stmts[I] = self:Instruction("assign", Trace, Vars[I], self:Expression())
					
					if I != Index and !self:AcceptToken("com") then self:Error("Assigment operator (=), value expected for variabel '%s'", Vars[I]) end
				end
				
			else
				local NextToken = self.NextTokenType
				if NextToken then
					local Instruction = AssigmentInstructions[NextToken]
					
					if Instruction then
						
						local Op, OpName = self.TokenData, self.TokenName
						self:NextToken()
						
						for I = 1, Index do
							local Var = Vars[I] -- Speed!
							Stmts[I] = self:Instruction("assign", Trace, Var, self:Instruction(Instruction, Trace, self:Instruction("variabel", Trace, Var), self:Expression()))
					
							if I != Index and !self:AcceptToken("com") then self:Error("%s (%s), value expected for variabel '%s'", OpName, Op, Var) end
						end
					end
				else
					self:TokenError(Trace, "Assigment operator (=) expected, after Variable")
				end
			end
			
			return self:Instruction("sequence", Trace, Stmts)
		end
		
		self:PrevToken()
	end
	
	if !NoDec then
		return self:VariableDeclaration()
	end
end

/*==============================================================================================
	Section: Indexed Statment
	Purpose: Allows us to run Assigment operators on array indexs =D
	Example: Array[i, number] = 10, Array[i, number] += 10
	Creditors: Rusketh
==============================================================================================*/
function Parser:IndexedStatment()
	if self:AcceptToken("var") then
		local Trace, Var = self:TokenTrace(), self.TokenData
		
		if self:AcceptToken("lsb") then
			self:PrevToken()
			
			local Indexs = { self:IndexingList() }
			local Count = #Indexs -- Speed
			
			local Get, Set = self:Instruction("variabel", Trace, Var)
			
			for I = 1, Count do
				local Index = Indexs[I]
				local Expression, Type, Trace = Index[1], Index[2], Index[3]
				
				if I == Count then
					Set = self:Instruction("set", Trace, Get, Expression, nil, Type) -- OMG: A nill value to be changed later.
				end
				
				Get = self:Instruction(trace, "get", Get, Expression, Type)
			end
			
			if self:AcceptToken("ass") then -- Assignment operator
				Set[5] = self:Expression()
				return Set
			elseif self:AcceptToken("aadd") then -- Additon Assignment operator
				Set[5] = self:Instruction("add", Trace, Get, self:Expression())
				return Set
			elseif self:AcceptToken("asub") then -- Subraction Assignment operator
				Set[5] = self:Instruction("subtract", Trace, Get, self:Expression())
				return Set
			elseif self:AcceptToken("amul") then -- Multiplication Assignment operator
				Set[5] = self:Instruction("multiply", Trace, Get, self:Expression())
				return Set
			elseif self:AcceptToken("adiv") then -- Divishion Assignment operator
				Set[5] = self:Instruction("dividie", Trace, Get, self:Expression())
				return Set
			end
		end
		
		self:PrevToken()
	end
end

/*==============================================================================================
	Section: If Statments
	Purpose: If this then do that.
	Creditors: Rusketh
==============================================================================================*/
function Parser:ElseIf()
	if self:AcceptToken("eif") then
		return self:Instruction("if", self:GetTokenTrace(), self:Condition(), self:Block("elseif condition"), self:ElseIf())
	elseif self:AcceptToken("els") then
		return self:Block("else")
	end
end

/********************************************************************************************************************/

function Parser:Block(Name)
	local Trace = self:TokenTrace()

	if !self:AcceptToken("lcb") then
		self:Error("Left curly bracket ({) expected after %s", Name or "condition")
	end

	local Stmts = self:GetStatments("rcb")
	
	if !self:AcceptToken("rcb") then
		self:Error("Right curly bracket (}) missing, to close %s", Name or "condition")
	end
	
	return Stmts
end

/*==============================================================================================
	Section: First Class Functions (User Defined Functions).
	Purpose: Functions, just 20% cooler!
	Creditors: Rusketh
==============================================================================================*/
function Parser:BuildPerams(BlockType)
	-- Purpose: Creates a UDFunction.
	
	if !self:AcceptToken("lpa") then
		self:Error("Left parenthesis (() missing, to start %s", BlockType or "peramaters")
	end

	local Perams, Types, Listed, Index = {}, {}, "", 0
	
	if self:AcceptToken("var") or self:AcceptToken("fun") then
		self:PrevToken()
		
		while true do
			if self:AcceptToken("com") then
				self:Error("perameter seperator (,) must not appear twice")
			elseif !self:HasTokens() then
				self:Error("perameter seperator (,) must not be succeeded by whitespace")
			end
			
			local Type
			
			if self:CheckToken("fun") then
				Type = self:StrictType()
				if !Type then self:Error("variabel expected, after perameter seperator (,)") end
				
				if !self:AcceptToken("var") then
					self:Error("variabel expected, after perameter type (%s)", GetLongType(Type))
				end
			else
				Type = "n"
				
				if !self:AcceptToken("var") then
					self:Error("variabel expected, after perameter seperator (,)")
				end
			end
			
			local Var = self.TokenData
			
			if Types[Var] then -- Note: Perameter conflict.
				self:Error("Perameter %s already exists, inside %s", BlockType or "peramaters")
			end
			
			Index = Index + 1
			Perams[Index] = Var
			Types[Var] = Type
			Listed = Listed .. Type
			
			if !self:AcceptToken("com") then break end -- Note: No more perameters lets exit loop
		
									-- if self:AcceptToken("com") then
										-- self:Error("perameter seperator (,) must not appear twice")
									
									-- elseif !self:HasTokens() then
										-- self:Error("perameter seperator (,) must not be succeeded by whitespace")
									
									-- elseif !self:AcceptToken("var") then
										-- self:Error("variabel expected, after perameter seperator (,)")

									-- else
										-- local Var, Type = self.TokenData, "n"
										
										-- if Types[Var] then -- Note: Perameter conflict.
											-- self:Error("Perameter %s already exists, inside %s", Type or "peramaters")
											
										-- elseif self:AcceptToken("col") then
											-- Type = self:StrictType()
											-- if !Type then self:Error("Perameter type expected, after colon (:)") end
										-- end
										
										-- Index = Index + 1
										-- Perams[Index] = Var
										-- Types[Var] = Type
										-- Listed = Listed .. Type
										
										-- if !self:AcceptToken("com") then break end -- Note: No more perameters lets exit loop
									-- end
		end
	end

	if !self:AcceptToken("rpa") then
		self:Error("Right parenthesis ()) missing, to close %s", BlockType or "peramaters")
	end
	
	return Perams, Types, Listed
end

/********************************************************************************************************************/

function Parser:FunctionStatment()
	local Global = self:AcceptToken("glob")
	
	if self:AcceptToken("func") then
		local Trace, Return, Name = self:TokenTrace()
		
		if !self:AcceptToken("fun") and !self:AcceptToken("func") then
			self:Error("function name expected, after (function)")
		end
		
		if self:AcceptToken("fun") then
			self:PrevToken(); self:PrevToken()
			Return = self:StrictType() -- Note: We go back and grab the type.
			self:NextToken()
		end
		
		Name = self.TokenData
		
		if Name == "function" then self:Error("Invalid function name, 'function'") end
		
			local Perams, Types, Listed = self:BuildPerams("function peramaters")
		
			local StillIn = self.InFunc
			self.InFunc = true -- Note: We make sure the parser knows we are inside a function.
			
			local Block = self:Block("function body")
			self.InFunc = StillIn -- Note: If we where in one before then the parser needs know.

			return self:Instruction("udfunction", Trace, Global, Name, Listed, Perams, Types, Block, Return)
	end
	
	if Global then self:PrevToken() end
end

/*==============================================================================================
	Section: Hooks or Event
	Purpose: Function Objects, just 20% cooler!
	Creditors: Rusketh
==============================================================================================*/
local ValidEvents = E_A.ValidEvents

function Parser:EventStatment()
	if self:AcceptToken("evt") then
		local Trace = self:TokenTrace()
		
		if !self:AcceptToken("fun") then
			self:Error("event name expected, after (event)")
		end
		
		local Event = self.TokenData
		
		local ValidEvent = ValidEvents[Event]
		if !ValidEvent then self:Error("invalid event %q", Event) end
		
		local Perams, Types, Listed = self:BuildPerams("event peramaters")
		
		if Listed != ValidEvent[1] then
			self:Error("perameter mismach for event %q", Event)
		end
		
		return self:Instruction("event", Trace, Event, Perams, Types, self:Block("event body"))
	end
end

/*==============================================================================================
	Section: Loops
	Purpose: for loops, while loops.
	Creditors: Rusketh
==============================================================================================*/
function Parser:ForLoop()
	-- Purpose: For loops will execute a body of code
	
	if self:AcceptToken("for") then
		
		local Trace = self:TokenTrace()
		
		if !self:AcceptToken("lpa") then
			self:Error("Left parenthesis (() missing, after 'for'")
		end
		
		if !self:AcceptToken("var") then
			self:Error("Varaible assigment expected, after left parenthesis (()")
		end
		
		local VarName, Ass = self.TokenData
		 
		if self:AcceptToken("ass") then -- Note: We allow a syntax for deafult vars.
			Ass = self:Instruction("assign_declare", Trace, VarName, self:Expression(), "n", "local")
		else
			Ass = self:Instruction("assign_default", Trace, VarName, "n", "local")

		end
		
		if !self:AcceptToken("com") then
			self:Error("Comma (,) expected, after for loop assigment.")
		end
		
		local Cond = self:Expression()
		
		if !Cond then
			self:Error("Condition expected, after (,) in for loop.")
		elseif !self:AcceptToken("com") then
			self:Error("Comma (,) expected, after for loop condition.")
		end
		
		local Step = self:VariableStatment(true)
		
		if !Step and self:AcceptToken("var") then
			self:Error("Inavlid step expression, after (,) in for loop.")
		elseif !Step then
			self:Error("Step expression expected, after (,) in for loop.")
		elseif !self:AcceptToken("rpa") then
			self:Error("Right parenthesis ()) missing, after loop step '%s'", self.NextTokenType) -- Todo: Make this error nicer.
		end
		
		self.LoopDepth = self.LoopDepth + 1
		
		local Block = self:Block("for loop")
		
		self.LoopDepth = self.LoopDepth - 1
		
		return self:Instruction("loop_for", Trace, Ass, Cond, Step, Block)
	end
end

function Parser:WhileLoop()
	-- Purpose: While loops will execute a body of code
	
	if self:AcceptToken("whl") then
		
		local Trace = self:TokenTrace()
		
		if !self:AcceptToken("lpa") then
			self:Error("Left parenthesis (() missing, after 'while'")
		end
		
		local Cond = self:Expression()
		if !self:AcceptToken("rpa") then
			self:Error("Right parenthesis ()) missing, after loop condition")
		end
		
		self.LoopDepth = self.LoopDepth + 1
		
		local Block = self:Block("for loop")
		
		self.LoopDepth = self.LoopDepth - 1
		
		return self:Instruction("loop_while", Trace, Cond, Block)
	end
		
end

function Parser:ExitStatment()
	local Depth, Level = self.LoopDepth
	
	if self:AcceptToken("brk") then
		Level = self:GetNumber(true)
		
		if Depth <= 0 then
			self:Error("break must not be used outside of loop")
		elseif Level and Level > Depth then
			self:Error("break depth is to deep")
		end
		
		return self:Instruction("break", self:TokenTrace(), Level)
	
	elseif self:AcceptToken("cnt") then
		Level = self:GetNumber(true)
		
		if Depth <= 0 then
			self:Error("continue must not be used outside of loop")
		elseif Level and Level > Depth then
			self:Error("continue depth is to deep")
		end
		
		return self:Instruction("continue", self:TokenTrace(), Level)
	
	elseif self:AcceptToken("ret") then
		
		if self:CheckToken("rcb") then
			return self:Instruction("return", self:TokenTrace())
		end
		
		return self:Instruction("return", self:TokenTrace(), self:Expression())
	end
end