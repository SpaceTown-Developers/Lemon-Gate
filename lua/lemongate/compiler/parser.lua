/*==============================================================================================
	Expression Advanced: Compiler -> Parser.
	Purpose: The Parser part of the compiler.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON = LEMON

local API = LEMON.API

local Compiler = LEMON.Compiler

/*==============================================================================================
	Section: Token Managment
==============================================================================================*/

function Compiler:HasTokens( )
	return self.PrepToken ~= nil
end

function Compiler:CurrentToken( Type )
	return ( self.Token and ( self.TokenType == Type ) )
end

function Compiler:AcceptToken( Type, Type2, ... )
	if self.PrepToken and ( self.PrepTokenType == Type ) then
		self:NextToken( )
		return true
	elseif Type2 then
		return self:AcceptToken( Type2, ... )
	end
	
	return false
end

function Compiler:CheckToken( Type, Type2, ... )
	if self.PrepToken and ( self.PrepTokenType == Type ) then
		return true
	elseif Type2 then
		return self:CheckToken( Type2, ... )
	end
	
	return false
end

function Compiler:RequireToken( Type, Message, ... )
	if !self:AcceptToken( Type ) then
		self:TokenError( Message, ... )
	end
end

function Compiler:ExcludeToken( Type, Message, ... )
	if self:AcceptToken( Type ) then
		self:TokenError( Message, ... )
	end
end

function Compiler:ExcludeWhiteSpace( Type, ... )
	if !self:HasTokens( ) then 
		self:TokenError( Message, ... )
	end
end

function Compiler:ExcludeVarArg( )
	self:ExcludeToken( "varg", "Invalid use of vararg (...)" )
end

/*==============================================================================================
	Section: Seperator Handeler
==============================================================================================*/

function Compiler:AcceptSeperator( )
	if self:AcceptToken( "sep" ) then
		self.LastSeperator = true
		
		while self:AcceptToken( "sep" ) do
			-- Nom all these seperators!
		end
	end

	return self.LastSeperator
end

/*==============================================================================================
	Section: Trace
==============================================================================================*/

function Compiler:TokenTrace( Root )
	local Trace = { self.TokenLine, self.TokenChar, Stack = { } }
	
	if Root then
		Trace.Stack[1] = { Root[1], Root[2], Location = Root.Location }
		
		for I = 1, 5 do
			Trace.Stack[I + 1] = Root.Stack[I]
		end
	end
	
	return Trace
end

/*==============================================================================================
	Section: Expression
==============================================================================================*/

function Compiler:GetExpression( RootTrace, IgnoreAss )
	
	if !self:HasTokens( ) then
		return -- No tokens!
		
	elseif self:AcceptToken( "var" ) then
		-- Lets strip out bad operators

		self:ExcludeToken( "aadd", "Additive assignment operator (+=), can't be part of Expression" )
		self:ExcludeToken( "asub", "Subtractive assignment operator (-=), can't be part of Expression" )
		self:ExcludeToken( "amul", "Multiplicative assignment operator (*=), can't be part of Expression" )
		self:ExcludeToken( "adiv", "Divisive assignment operator (/=), can't be part of Expression" )
		
		if !IgnoreAss then
			self:ExcludeToken( "ass", "Assignment operator (=), can't be part of Expression" )
		end
		
		self:PrevToken( )
	end
	
	local Trace = self:TokenTrace( RootTrace )
	
	self:PushFlag( "ExprTrace", Trace )
	
	-- Operators
	
	local Expression = self:GetTokenOperator(
		"or", "and",
		"bor", "band", "bxor",
		"eq", "neq", "gth", "lth", "geq", "leq",
		"bshr", "bshl",
		"add", "sub", "mul", "div",
		"mod", "exp"
	) -- Compile primary Operators in order of prority!

	self:PopFlag( "ExprTrace" )
	
	return self:PostExpression( Trace, Expression )
end

/*==============================================================================================
	Section: Expression Operators
==============================================================================================*/

Compiler.TokenOperators = {

	-- Conditional
		["or"] = { "or", "||", true },
		["and"] = { "and", "&&", true },
		
	-- Comparason
	
		["eq"] = { "eq", "==" },
		["neq"] = { "negeq", "!=" },
		["gth"] = { "greater", ">" },
		["lth"] = { "less", "<" },
		["geq"] = { "eqgreater", ">=" },
		["leq"] = { "eqless", "<=" },
		
	-- Mathmatic
		["add"] = { "addition", "+" },
		["sub"] = { "subtraction", "-" },
		["mul"] = { "multiply", "*" },
		["div"] = { "division", "/" },
		["mod"] = { "modulus", "%" },
		["exp"] = { "exponent", "^" },
	
	-- Binary
		["bor"]  = { "binary or", "|"},
		["band"] = { "binary and", "&"},
		["bxor"] = { "binary xor", "^^"},
		["bshr"] = { "binary shift right", ">>"},
		["bshl"] = { "binary shift left", "<<"},
		
}; TokenOperators = Compiler.TokenOperators -- Speed mainly!

function Compiler:GetTokenOperator( Token, ... )
	
	local Trace = self:GetFlag( "ExprTrace" )
	if !Token then return self:GetValue( Trace ) end
	
	local Operator = TokenOperators[Token]
	local Expression = self:GetTokenOperator( ... )
	local Compile = self[ "Compile_" .. string.upper( Operator[1] ) ]
	
	while self:AcceptToken( Token ) do
		self:ExcludeVarArg( )
		
		local Second = self:GetTokenOperator( ... )
		
		if Operator[3] then Second = self:Evaluate( Trace, Second ) end
		
		Expression = Compile( self, Trace, Expression, Second )
	end
	
	return Expression
end

function Compiler:PostExpression( RootTrace, Expression )
	if self:AcceptToken( "qsm" ) then
		local Trace = self:TokenTrace( RootTrace )
		
		local TrueExpr = self:GetExpression( Trace )
		
		self:RequireToken( "cnd", "Conditional operator (::) must appear after expression to complete conditional." )
		
		return self:Compile_CND( Trace, Expression, TrueExpr, self:GetExpression( Trace ) )
	end
	
	return Expression
end
/*==============================================================================================
	Section: Expression Value
==============================================================================================*/

function Compiler:CheckCast( )
	local Cast
	
	if self:AcceptToken( "lpa" ) then
		if self:AcceptToken( "fun", "func" ) then
			local Type = self.TokenData
			
			if self:AcceptToken( "rpa" ) then
				Cast = Type
			else
				self:PrevToken( )
				self:PrevToken( )
			end
		else
			self:PrevToken( )
		end
	end
	
	return Cast
end


function Compiler:GetValue( RootTrace, IgnoreOperators )
	local Value, PreInstr
	
	-- Prefix Operators
	
	if self:AcceptToken( "add" ) then
		self:ExcludeWhiteSpace( "Identity operator (+) must not be succeeded by whitespace" )
		
	elseif self:AcceptToken( "sub" ) then
		self:ExcludeWhiteSpace( "Negation operator (-) must not be succeeded by whitespace" )
		
		PreInstr = "NEGATIVE"
	
	elseif self:AcceptToken( "not" ) then
		self:ExcludeWhiteSpace( "Logical not operator (!) must not be succeeded by whitespace" )
		
		PreInstr = "NOT"
		
	elseif self:AcceptToken( "len" ) then
		self:ExcludeWhiteSpace( "length operator (#) must not be succeeded by whitespace" )
		
		PreInstr = "LENGTH"
	end
	
	-- Casting Operator
	local Trace = self:TokenTrace( RootTrace )
	local CastType = self:CheckCast( )
	local NextCastType = self:CheckCast( )
	
	if NextCastType then
		Value = self:Compile_CAST( Trace, NextCastType, self:GetExpression( Trace ) )
		
	elseif self:AcceptToken( "lpa" ) then
		Value = self:GetExpression( RootTrace )
		
		self:RequireToken( "rpa", "Right parenthesis ( )) missing, to close grouped equation" )
		
	-- Variable Prefix Operators
	
	elseif self:AcceptToken( "dlt" ) then
		self:ExcludeWhiteSpace( "Delta operator ($) must not be succeeded by white space" )
		self:RequireToken( "var", "variable expected, after Delta operator ($)" )
		
		Value = self:Compile_DELTA( self:TokenTrace( RootTrace ), self.TokenData )

	elseif self:AcceptToken( "trg" ) then
		self:ExcludeWhiteSpace( "Changed operator (~) must not be succeeded by white space" )
		self:RequireToken( "var", "variable expected, after Changed operator (~)" )
		
		Value = self:Compile_TRIGGER( self:TokenTrace( RootTrace ), self.TokenData )
		
	elseif self:AcceptToken( "wc" ) then -- Wiremod IO connection.
		self:ExcludeWhiteSpace( "Connect operator (->) must not be succeeded by white space" )
		self:RequireToken( "var", "variable expected, after Connect operator (->)" )
		
		Value = self:Compile_CONNECT( self:TokenTrace( RootTrace ), self.TokenData )
	
	-- Raw Values
	
	elseif self:AcceptToken( "num" ) then
		Value = self:Compile_NUMBER( self:TokenTrace( RootTrace ), self.TokenData )
	
	elseif self:AcceptToken( "str" ) then
		Value = self:Compile_STRING( self:TokenTrace( RootTrace ), "\"" .. self.TokenData .. "\"" )
	
	elseif self:AcceptToken( "tre" ) then
		Value = self:Compile_BOOLBEAN( self:TokenTrace( RootTrace ), true )
	elseif self:AcceptToken( "fls" ) then
		Value = self:Compile_BOOLBEAN( self:TokenTrace( RootTrace ), false )
	elseif self:AcceptToken( "varg" ) then
		
		if !self:GetFlag( "HasVargs", false ) then
			self:TokenError( "Vararg (...) must not appear outside of vararg function/method/event." )
		end
		
		Value = self:Instruction( Trace, 3, "...", "..." )
	-- Variable and Inc/Dec
	
	elseif self:AcceptToken( "var" ) then
		local Trace, Variable = self:TokenTrace( RootTrace ), self.TokenData

		if self:AcceptToken( "inc" ) then
			Value = self:Compile_INCREMENT( Trace, Variable, true )
		elseif self:AcceptToken( "dec" ) then
			Value = self:Compile_DECREMENT( Trace, Variable, true )
		else
			Value = self:Compile_VARIABLE( Trace, Variable )
		end
	
	elseif self:AcceptToken( "inc" ) then
		Value = self:Statment_INC( self:TokenTrace( RootTrace ) )
		
	elseif self:AcceptToken( "dec" ) then
		Value = self:Statment_DEC( self:TokenTrace( RootTrace ) )
	
	-- Function	
	
	elseif self:AcceptToken( "fun" ) then
		local Trace, Function = self:TokenTrace( RootTrace ), self.TokenData
		
		-- Custom Syntax function
		if self["FUNC_" .. Function] then
			Value = self["FUNC_" .. Function]( self, Trace )
		
		elseif self:AcceptToken( "lpa" ) then
			-- Call Function
			Value = self:Compile_FUNCTION( Trace, Function, self:NextInputPerams( RootTrace ) )
			
			self:RequireToken( "rpa", "Right parenthesis ( )) missing, to close function parameters" )
		else
		-- Lambda Variable
			Value = self:Compile_VARIABLE( Trace, Function )
		end
	
	-- Lambda Create
	
	elseif self:AcceptToken( "func" ) then
		Value = self:BuildLambda( nil, RootTrace ) -- TODO: This
	
	-- Table
	
	elseif self:AcceptToken( "lcb" ) then
		Value = self:BuildTable( RootTrace ) -- TODO: This!
	
	-- Error
	
	else
		self:ExpressionError( )
	end
	
	if !IgnoreOperators then
		Value = self:NextValueOperator( Value, self:GetFlag( "ExprTrace" ) )
	end
	
	if CastType then
		Value = self:Compile_CAST( Trace, CastType, Value )
	end

	if PreInstr then
		Value = self["Compile_" .. PreInstr]( self, Trace, Value )
	end
	
	return Value
end

/*==============================================================================================
	Section: Table
==============================================================================================*/

function Compiler:BuildTable( RootTrace )

	local Trace = self:TokenTrace( RootTrace )
	
	local Count, Values, Keys = 0, { }, { }
	
	if !self:CheckToken( "rcb" ) then
		
		while self:HasTokens( ) do
			self:ExcludeToken( "com", "Expression separator (,) can not appear here." )
			
			Count = Count + 1
			
			local Expression, Key = self:GetExpression( Trace, true ), nil
			
			if self:AcceptToken( "ass" ) then
				Key = Expression
				
				Expression = self:GetExpression( Trace )
				
				if Expression.Return == "..." then
					self:TraceError( Trace, "Invalid use of varargs (...)")
				elseif Key.Return == "..." then
					self:TraceError( Trace, "Invalid use of varargs (...)")
				end
			end
			
			Values[Count] = Expression
			Keys[Count] = Key
			
			if !self:AcceptToken( "com" ) then
				break
			end
		end
	end
	
	self:RequireToken( "rcb", "Right curly bracket (}) expected, after table contents" )
	
	return self:Compile_TABLE( Trace, Values, Keys, Count )
end

/*==============================================================================================
	Section: Expression Error
==============================================================================================*/
function Compiler:ExpressionError( )
	
	if self:HasTokens( ) then
		self:ExcludeToken( "add", "Addition operator (+) must be preceded by equation or value" )
		self:ExcludeToken( "sub", "Subtraction operator (-) must be preceded by equation or value" )
		self:ExcludeToken( "mul", "Multiplication operator (*) must be preceded by equation or value" )
		self:ExcludeToken( "div", "Division operator (/) must be preceded by equation or value" )
		self:ExcludeToken( "mod", "Modulo operator (%) must be preceded by equation or value" )
		self:ExcludeToken( "exp", "Exponentiation operator (^) must be preceded by equation or value" )

		self:ExcludeToken( "ass", "Assignment operator (=) must be preceded by variable" )
		self:ExcludeToken( "aadd", "Additive assignment operator (+=) must be preceded by variable" )
		self:ExcludeToken( "asub", "Subtractive assignment operator (-=) must be preceded by variable" )
		self:ExcludeToken( "amul", "Multiplicative assignment operator (*=) must be preceded by variable" )
		self:ExcludeToken( "adiv", "Divisive assignment operator (/=) must be preceded by variable" )

		self:ExcludeToken( "and", "Logical and operator (&&) must be preceded by equation or value" )
		self:ExcludeToken( "or", "Logical or operator (!|) must be preceded by equation or value" )

		self:ExcludeToken( "eq", "Equality operator (==) must be preceded by equation or value" )
		self:ExcludeToken( "neq", "Inequality operator (!=) must be preceded by equation or value" )
		self:ExcludeToken( "gth", "Greater than or equal to operator (>=) must be preceded by equation or value" )
		self:ExcludeToken( "lth", "Less than or equal to operator (<=) must be preceded by equation or value" )
		self:ExcludeToken( "geq", "Greater than operator (>) must be preceded by equation or value" )
		self:ExcludeToken( "leq", "Less than operator (<) must be preceded by equation or value" )

		self:ExcludeToken( "inc", "Increment operator (++) must be preceded by variable" )
		self:ExcludeToken( "dec", "Decrement operator (--) must be preceded by variable" )

		self:ExcludeToken( "rpa", "Right parenthesis ( )) without matching left parenthesis" )
		self:ExcludeToken( "lcb", "Left curly bracket ({) must be part of an table/if/while/for-statement block" )
		self:ExcludeToken( "rcb", "Right curly bracket (}) without matching left curly bracket" )
		self:ExcludeToken( "lsb", "Left square bracket ([) must be preceded by variable" )
		self:ExcludeToken( "rsb", "Right square bracket (]) without matching left square bracket" )

		self:ExcludeToken( "com", "Comma (,) not expected here, missing an argument?" )
		self:ExcludeToken( "col", "Method operator (:) must not be preceded by white space" )
		self:ExcludeToken( "cnd", "Conditional operator (::) must be part of conditional expression (A ? B :: C)." )

		self:ExcludeToken( "if", "If keyword (if) must not appear inside an equation" )
		self:ExcludeToken( "eif", "Else-if keyword (elseif) must be part of an if-statement" )
		self:ExcludeToken( "els", "Else keyword (else) must be part of an if-statement" )

		self:ExcludeToken( "swh", "Switch keyword (switch) must not appear inside an equation" )
		self:ExcludeToken( "cse", "Case keyword (case) must be part of an switch-statement" )
		self:ExcludeToken( "dft", "Default keyword (default) must be part of an switch-statement" )
		
		self:ExcludeToken( "try", "Try keyword (try) must be part of a try-statement" )
		self:ExcludeToken( "cth", "Catch keyword (catch) must be part of an try-statement" )
		self:ExcludeToken( "fnl", "Final keyword (final) must be part of an try-statement" )
		
		self:TokenError( "Unexpected token found (%s)", self.PrepTokenName )
	else
		self:TraceError( self:GetFlag( "ExprTrace" ), "Further input required at end of code, incomplete expression" )
	end
end

/*==============================================================================================
	Section: Useful and Recursive
==============================================================================================*/

function Compiler:NextInputPerams( RootTrace )
	
	if !self:HasTokens( ) or self:CheckToken( "rpa" ) then
		return
	else
		local Expression = self:GetExpression( RootTrace )
		
		if self:AcceptToken( "com" ) then
			return Expression, self:NextInputPerams( RootTrace )
		else
			return Expression
		end
	end
end

function Compiler:NextIndex( RootTrace )
	
	if !self:HasTokens( ) or !self:AcceptToken( "lsb" ) then
		return
	else
		local Trace, Expression = self:TokenTrace( RootTrace ), self:GetExpression( RootTrace )
		
		if !self:AcceptToken( "com" ) then
			self:RequireToken( "rsb", "Right square bracket (]) missing, to close indexing operator [Index]" )
			return { Expression, nil, Trace }, self:NextIndex( RootTrace )
			
		elseif !self:AcceptToken( "func" ) then
			self:RequireToken( "fun", "variable type expected after comma (,) in indexing operator [Index, type]" )
		end
		
		local Class = self:GetClass( Trace, self.TokenData )
		self:RequireToken( "rsb", "Right square bracket (]) missing, to close indexing operator [Index, type]" )
		return { Expression, Class.Short, Trace }, self:NextIndex( RootTrace )
	end
end

function Compiler:NextValueOperator( Value, RootTrace )
	
	if !Value then
		debug.Trace( )
		self:TraceError( RootTrace, "Unpredicted compile error, NextValueOperator got no value" )
	
	-- Method
	elseif self:AcceptToken( "col" ) then
		local Trace = self:TokenTrace( RootTrace ) 
		
		self:RequireToken( "fun", "Method operator (:) must be followed by method name" )
		
		local Method = self.TokenData
		
		self:RequireToken( "lpa", "Left parenthesis (( ) missing, after method name" )
		
		Value = self:Compile_METHOD( Trace, Method, Value, self:NextInputPerams( RootTrace ) )
			
		self:RequireToken( "rpa", "Right parenthesis ( )) missing, to close function parameters" )
		
		return self:NextValueOperator( Value, RootTrace )
	
	-- Index
	
	elseif self:AcceptToken( "lsb" ) then
		local Trace, Expression = self:TokenTrace( RootTrace ), self:GetExpression( RootTrace )
		
		if !self:AcceptToken( "com" ) then
			self:RequireToken( "rsb", "Right square bracket (]) missing, to close indexing operator [Index]" )
			
			Value = self:Compile_GET( Trace, Value, Expression )
		
		elseif !self:AcceptToken( "fun" ) and !self:AcceptToken( "func" ) then
			self:TraceError( Trace, "variable type expected after comma (,) in indexing operator [Index, type]" )
		
		else
			local Class = self:GetClass( Trace, self.TokenData )
		
			self:RequireToken( "rsb", "Right square bracket (]) missing, to close indexing operator [Index]" )
		
			Value = self:Compile_GET( Trace, Value, Expression, Class.Short )
		end
		
	-- Call
	
	elseif self:AcceptToken( "lpa" ) then
		
		Value = self:Compile_CALL( self:TokenTrace( RootTrace ), Value, self:NextInputPerams( RootTrace ) )
			
		self:RequireToken( "rpa", "Right parenthesis ( )) missing, to close call operator parameters" )
	else
		return Value
	end
	
	return self:NextValueOperator( Value, RootTrace )
end

/*==============================================================================================
	Section: Useful and inportant!
==============================================================================================*/
function Compiler:GetListedVariables( RootTrace )
	local Variables, Count = { { self:TokenTrace( ), self.TokenData } }, 1
		
	while self:AcceptToken( "com" ) do
		self:ExcludeToken( "com", "Variable separator (,) must not appear here." )
		self:RequireToken( "var", "Variable expected after comma (,) for variable statment" )
		
		Count = Count + 1
		
		Variables[Count] = { self:TokenTrace( RootTrace ), self.TokenData }
	end
	
	
	return Variables, Count
end

/*==============================================================================================
	Section: Statements
==============================================================================================*/

local Upper = string.upper

function Compiler:Statement( RootTrace )
	
	local Func = self[ "Statment_" .. Upper( self.PrepTokenType ) ]
	
	if Func then
		self:NextToken( )
		return Func( self, RootTrace )
	end
	
	return self:StatmentError( )
end

function Compiler:GetStatements( ExitType, RootTrace )
	
	local Trace = self:TokenTrace( RootTrace )
	
	local Statements, I = { }, 0
	
	if !self:HasTokens( ) or ( ExitType and self:CheckToken( ExitType ) ) then
		return self:Instruction( Trace, 0, "", "", "")
	end
	
	while true do
		
		I = I + 1
		
		Statements[I] = self:Statement( Trace ) 
		
		self:AcceptSeperator( )

		if !self:HasTokens( ) or ( ExitType and self:CheckToken( ExitType ) ) then
			break
		elseif !self:AcceptSeperator( ) and self.PrepTokenLine == self.TokenLine then
			self:TokenError( "Statements must be separated by semicolon (;) or newline" )
			
		elseif self.StatmentExit then
			self:TokenError( "Unreachable code after %s", self.StatmentExit )
		end
	end
	
	return self:Compile_SEQUENCE( Trace, Statements )
end

/*==============================================================================================
	Section: Statment
==============================================================================================*/
function Compiler:NextStatement( RootTrace )
	-- Todo: Add more stuff maybe?
	return self:StatmentError( )
end

function Compiler:Statment_VAR( RootTrace )
	local Trace, Variable = self:TokenTrace( RootTrace ), self.TokenData
	
	-- Inc / Dec
	if self:AcceptToken( "inc" ) then
		return self:Compile_INCREMENT( Trace, Variable, true )
	elseif self:AcceptToken( "dec" ) then
		return self:Compile_DECREMENT( Trace, Variable, true )
	
	-- Multi Assign/Arithmatic Assign
	
	elseif self:CheckToken( "com", "ass", "aadd", "asub", "amul", "adiv" ) then
		local Variables, Count = self:GetListedVariables( RootTrace )
		
		local Statements, Operator = { }
		
		if self:AcceptToken( "ass" ) then
			-- Nothing!
		elseif self:AcceptToken( "aadd", "asub", "amul", "adiv" ) then
			Operator = "Compile_" .. string.upper( TokenOperators[ string.sub( self.TokenType, 2 ) ][1] )
		else
			self:TokenError( "Assignment operator (=) expected after Variable" )
		end
		
		for I = 1, Count do
			local Var = Variables[ I ]
			local Expression = self:GetExpression( Var[1] )
			
			if Expression.Return == "..." then
				self:TokenError( "Invalid use of vararg (...)" )
			elseif Operator then
				Expression = self[Operator]( self, Var[1], self:Compile_VARIABLE( Var[1], Var[2] ), Expression )
			end
			
			Statements[I] = self:Compile_ASSIGN( Var[1], Var[2], Expression )
			
			if I != Count then
				self:RequireToken( "com", "comma (,) expected after expression" ) -- TODO: Better error message!
			end
		end
			
		return self:Compile_SEQUENCE( Trace, Statements )
	
	-- Indexing!
	
	elseif self:CheckToken( "lsb" ) then
		local Indexs = { self:NextIndex( Trace ) } -- {{1:Expr 2:Type 3:Trace}, ...}
		local Variable = self:Compile_VARIABLE( Trace, Variable )
		
		local Data = Indexs[#Indexs] -- Get is 1 from last table
		
		if #Indexs > 1 then
			local Var = self:NextLocal( )
			local Statements = { "local " ..  Var .. " = " .. Variable.Inline }
			local Prepare = { Variable.Prepare }
			local Perf = Variable.Perf
			
			local Fake = self:FakeInstr( Variable.Trace, Variable.Return, Var )
			for I = 1, #Indexs - 1 do
				local Data = Indexs[I]
				local Get = self:Compile_GET( Data[3], Fake, Data[1], Data[2] )
				
				Prepare[ #Prepare + 1 ] = Get.Prepare
				Statements[ #Statements + 1 ] = Var .. " = " .. Get.Inline
				Perf = Perf + Get.Perf
			end
			
			local Data = Indexs[#Indexs - 1]
			Variable = self:Instruction( Data[3], Perf, Data[2], Var, string.Implode( "\n", Prepare ) .. string.Implode( "\n", Statements ) )
		end
		
		local Instruction = self:Compile_GET( Data[3], Variable, Data[1], Data[2] )
		
		if self:AcceptToken( "ass" ) then
			self:ExcludeVarArg( )
			Instruction = self:GetExpression( Data[3] )
		elseif self:AcceptToken( "aadd" ) then
			Instruction = self:Compile_ADDITION( Trace, Instruction, self:GetExpression( Data[3] ) )
		elseif self:AcceptToken( "asub" ) then
			Instruction = self:Compile_SUBTRACT( Trace, Instruction, self:GetExpression( Data[3] ) )
		elseif self:AcceptToken( "amul" ) then
			Instruction = self:Compile_MULTIPLY( Trace, Instruction, self:GetExpression( Data[3] ) )
		elseif self:AcceptToken( "adiv" ) then
			Instruction = self:Compile_DIVIDIE( Trace, Instruction, self:GetExpression( Data[3] ) )
		else
			return self:NextValueOperator( Instruction, Data[3] )
		end
		
		
		return self:Compile_SET( Data[3], Variable, Data[1], Instruction, Data[2] )
	
	else
		return self:NextValueOperator( self:Compile_VARIABLE( Trace, Variable ), RootTrace )
	end
end

/****************************************************************************************************/

-- TODO: Add Table support!
function Compiler:Statment_INC( RootTrace )
	self:RequireToken( "var", "Increment operator (++) must be proceeded by variable" )
	return self:Compile_INCREMENT( RootTrace, self.TokenData, false )
end

function Compiler:Statment_DEC( RootTrace )
	self:RequireToken( "var", "Decrement operator (++) must be proceeded by variable" )
	return self:Compile_DECREMENT( RootTrace, self.TokenData, false )
end
		
/****************************************************************************************************/

function Compiler:Statment_STC( RootTrace )
	self:ExcludeToken( "in", "Invalid modifier 'static' for import." )
	self:ExcludeToken( "out", "Invalid modifier 'static' for outport." )
	
	if self:AcceptToken( "glo" ) then
		return self:Statment_GLO( RootTrace, true )
	elseif self:AcceptToken( "fun" ) then
		return self:Statment_FUN( RootTrace, true )
	end
	
	self:TraceError( RootTrace, "modifier 'static' must be followed by variable type." )
end

function Compiler:Statment_GLO( RootTrace, Static )
	local Trace = self:TokenTrace( RootTrace )
	
	if self:AcceptToken( "func" ) then -- This is a Global function!
		return self:Statment_FUNC( Trace )
	end
	
	self:RequireToken( "fun", "Variable type expected after Global" )
	
	local Class = self:GetClass( Trace, self.TokenData )
	
	self:RequireToken( "var", "Variable expected after variable type." )
	
	return self:Declair_Variables( Trace, Class.Short, "Global", Static )
end

function Compiler:Statment_OUT( RootTrace )
	local Trace = self:TokenTrace( RootTrace )
	
	self:RequireToken( "fun", "Variable type expected after Output" )
	
	local Class = self:GetClass( Trace, self.TokenData )
	
	self:RequireToken( "var", "Variable expected after variable type." )
	
	return self:Declair_Variables( Trace, Class.Short, "Outport" )
	
end

function Compiler:Statment_IN( RootTrace )
	local Trace = self:TokenTrace( RootTrace )
	
	self:RequireToken( "fun", "Variable type expected after Input" )
	
	local Class = self:GetClass( Trace, self.TokenData )
	
	self:RequireToken( "var", "Variable expected after variable type." )
	
	return self:Declair_Variables( Trace, Class.Short, "Inport" )
	
end

function Compiler:Statment_FUN( RootTrace, Static )
	local Trace = self:TokenTrace( RootTrace )
	local ClassName = self.TokenData
	
	if self:CheckToken( "var" ) then
		local Class = self:GetClass( Trace, ClassName, true )
		
		self:RequireToken( "var", "Variable expected for variable deceleration." )
		
		return self:Declair_Variables( Trace, Class.Short, "Local", Static )
	
	elseif Static then
		self:TraceError( RootTrace, "Modifier 'static' must not appear here." )
		
	elseif self:AcceptToken( "ass" ) then
		local Ref = self:Assign( Trace, ClassName, "f", "Local" )
		
		return self:Compile_ASSIGN( Trace, ClassName, self:GetExpression( RootTrace ) )
	end
		
	self:PrevToken( )
		
	return self:GetExpression( RootTrace )
end

function Compiler:Declair_Variables( Trace, Class, Type, Static )
	local Trace = Trace or self:TokenTrace( )
	local Variables, Count = self:GetListedVariables( )
	local Statements, Start = { }, 1
	
	self:ExcludeToken( "aadd", "Assignment operator (+=) can not assign to uninitialized variables" )
	self:ExcludeToken( "asub", "Assignment operator (-=) can not assign to uninitialized variables" )
	self:ExcludeToken( "amul", "Assignment operator (*=) can not assign to uninitialized variables" )
	self:ExcludeToken( "adiv", "Assignment operator (/=) can not assign to uninitialized variables" )
		
	if Type == "input" then
		self:ExcludeToken( "ass", "Assignment operator (=) can not assign to inputs" )
	
	elseif self:AcceptToken( "ass" ) then
		-- Initalized Assignment
		
		for I = 1, Count do 
			self:ExcludeToken( "com", "Expression separator (,) must not appear here." )
			
			if !self:HasTokens( ) then
				self:TokenError( "invalid variable assignment" )
			end
			
			local Data = Variables[I]
			Statements[I] = self:Compile_DECLAIR( Data[1], Type, Data[2], Class, self:GetExpression( Trace ), Static )
			
			
			Start = I + 1
			
			if !self:AcceptToken( "com" ) then
				break
			elseif I == Count then
				self:TokenError( "Unexpected Comma (,) all variables have been initalized" )
			end
		end
	end
	
	-- Initalized Default
		
	for I = Start, Count do
		local Data = Variables[I]
		
		Statements[I] = self:Compile_DECLAIR( Data[1], Type, Data[2], Class, nil, Static )
	end
	
	return self:Compile_SEQUENCE( Trace, Statements )
end

/****************************************************************************************************/

function Compiler:Statment_BRK( RootTrace )
	local Trace = self:TokenTrace( RootTrace )
	local Depth = self:AcceptToken( "num" ) and self.TokenData or 0
	
	if self:GetFlag( "LoopDepth", 0 ) < 1 then
		self:TraceError( Trace, "Break can not be used outside of a loop" )
	elseif Depth > self:GetFlag( "LoopDepth", 0 ) then
		self:TraceError( Trace, "Can not break at specified level" )
	end
	
	self:AcceptSeperator( )
	
	self.StatmentExit = "break"
	
	return self:Compile_BREAK( Trace, Depth )
end

function Compiler:Statment_CNT( RootTrace )
	local Trace = self:TokenTrace( RootTrace )
	local Depth = self:AcceptToken( "num" ) and self.TokenData or 0
	
	if self:GetFlag( "LoopDepth", 0 ) < 1 then
		self:TraceError( Trace, "Continue can not be used outside of a loop or case" )
	elseif Depth > self:GetFlag( "LoopDepth", 0 ) then
		self:TraceError( Trace, "Can not continue at specified level" )
	end
	
	self:AcceptSeperator( )
	
	self.StatmentExit = "continue"
	
	return self:Compile_CONTINUE( Trace, Depth )
end

function Compiler:Statment_RET( RootTrace )
	local Trace, Value = self:TokenTrace( RootTrace )
	
	if !self:GetFlag( "CanReturn", false ) then
		self:TokenError( "return may not be used outside a function or event" )
	elseif !self:CheckToken( "rcb" ) then
		Value = self:GetExpression( RootTrace )
		self:SetFlag( "ReturnedType", Value.Return )
	end
	
	self:AcceptSeperator( )
	
	self.StatmentExit = "return"
	
	return self:Compile_RETURN( Trace, Value )
end

/*==============================================================================================
	Section: Statment Error
==============================================================================================*/
function Compiler:StatmentError( )
	if self:HasTokens( ) then
		self:ExcludeToken("num", "Number must be part of statement or expression")
		self:ExcludeToken("str", "String must be part of statement or expression")
		self:ExcludeToken("var", "Variable must be part of statement or expression")

		self:Error(0, "Unexpected token found (%s)", self.PrepTokenName)
	else
		self:TokenError( self:GetFlag( "ExprTrace" ), "Further input required at end of code, incomplete statement / expression")
	end
end
	
/*==============================================================================================
	Section: Function Statements
==============================================================================================*/

function Compiler:Statment_FUNC( GlobalTrace )
	local Trace = GlobalTrace or self:TokenTrace( )
	
	self:RequireToken( "fun", "Function variable expected after function Keyword" )
	
	local Variable = self.TokenData
	local State = GlobalTrace and "Global" or "Local"
	
	self:ExcludeToken( "aadd", "Assignment operator (+=) can not assign to functions" )
	self:ExcludeToken( "asub", "Assignment operator (-=) can not assign to functions" )
	self:ExcludeToken( "amul", "Assignment operator (*=) can not assign to functions" )
	self:ExcludeToken( "adiv", "Assignment operator (/=) can not assign to functions" )
	
	if self:AcceptToken( "ass" ) then
		return self:Compile_DECLAIR( Trace, State, Variable, "f", self:GetExpression( Trace ) )
	else
		local Ref = self:Assign( Trace, Variable, "f", State )
		return self:Compile_ASSIGN( Trace, Variable, self:BuildLambda( Trace ) )
	end
end

function Compiler:BuildPerams( Trace )	
	local Perams, LU, HasVarg, Count = { }, { }, false, 1
	
	if self:CheckToken( "fun", "var", "func" ) then
		while true do
			self:ExcludeToken( "com", "Parameter separator (,) must not appear here" )
			
			local Class = self:GetClass( Trace, "number" )
			if self:AcceptToken( "fun", "func" ) then
				Class = self:GetClass( Trace, self.TokenData )
			end
			
			if Class.Short == "f" then
				self:RequireToken( "fun", "Function variable expected for function parameter." )
			else
				self:RequireToken( "var", "Variable expected for function parameter." )
			end
			
			if LU[ self.TokenData ] then
				self:TokenError( "Parameter %s may not appear twice", self.TokenData )
			else
				local Ref, Scope = self:Assign( Trace, self.TokenData, Class.Short, "Local" )
				Perams[ Count ] = { self.TokenData, Class.Short, Ref }
				LU[ self.TokenData ] = true
				Count = Count + 1
			end
			
			if !self:AcceptToken( "com" ) or self:CheckToken( "varg" ) then
				break
			end
		end
	end
	
	if self:AcceptToken( "varg" ) then
		self:ExcludeToken( ",", "vararg (...) must be last parameter." )	
		HasVarg = true
	end
	
	return Perams, HasVarg, Count
end

function Compiler:BuildLambda( RootTrace, Variable )
	local Trace = Trace or self:TokenTrace( RootTrace )
	
	self:RequireToken( "lpa", "Left parenthesis (( ) missing, to start lambda parameters." )
	
	self:PushScope( )
	
	self:PushFlag( "NewCells", { } )
	
	local Perams, HasVarg, Count = self:BuildPerams( Trace )	

	self:RequireToken( "rpa", "Right parenthesis ( )) missing, to close lambda parameters." )
	
	self:PushFlag( "HasVargs", HasVarg or self:GetFlag( "HasVargs", false ) )
	self:PushFlag( "ReturnedType", "" )
	self:PushFlag( "CanReturn", true )
	self:PushFlag( "Lambda", true )
	self:PushFlag( "LoopDepth", 0 )
	
	local Block = self:GetBlock( "function", Trace )
	local Instr = self:Compile_LAMBDA( Trace, Perams, HasVarg, Block )
	
	self:PopFlag( "ReturnedType" )
	self:PopFlag( "CanReturn" )
	self:PopFlag( "NewCells" )
	self:PopFlag( "HasVargs" )
	self:PopFlag( "Lambda" )
	
	self:PopScope( )
	
	return Instr
end

function Compiler:Statment_METH( Trace, RootTrace )
	local Trace = Trace or self:TokenTrace( RootTrace )
	
	local Meta = self:GetValue( Trace, true )
	
	self:RequireToken( "col", "Colon (:), expected after parent for method."  )
	
	self:RequireToken( "fun", "Method name, after colon (:)." )
	local Name = self:FakeInstr( Trace, "s", "\"" .. self.TokenData .. "\"" ) 
	
	self:RequireToken( "lpa", "Left parenthesis (( ) missing, to open method parameters" )
	
	self:PushScope( )
	
	self:PushFlag( "NewCells", { } )
	
	local Perams, HasVarg, Count = self:BuildPerams( Trace )
	
	self:RequireToken( "rpa", "Right parenthesis ( )) missing, to close method parameters" )
	
	self:PushFlag( "HasVargs", HasVarg )
	self:PushFlag( "ReturnedType", "" )
	self:PushFlag( "CanReturn", true )
	self:PushFlag( "Lambda", true )
	self:PushFlag( "LoopDepth", 0 )
	
	local Ref, Scope = self:Assign( Trace, "This", Meta.Return, "Local" )
	table.insert( Perams, 1, { "This", Meta.Return, Ref } )
	
	local Block = self:GetBlock( "method", Trace )
	local Method = self:Compile_LAMBDA( Trace, Perams, HasVarg, Block ) -- TODO: Add Type (method/function)!
	
	self:PopFlag( "ReturnedType" )
	self:PopFlag( "CanReturn" )
	self:PopFlag( "NewCells" )
	self:PopFlag( "HasVargs" )
	self:PopFlag( "Lambda" )
	
	self:PopScope( )
	
	return self:Compile_ADDMETHOD( Trace, Meta, Name, Method )
end

/*==============================================================================================
	Section: If / Ifelse / Else
==============================================================================================*/

function Compiler:Statment_IF( RootTrace ) -- If
	return self:Compile_IF( self:TokenTrace( RootTrace ), self:GetCondition( RootTrace ), self:GetBlock( "if statement", RootTrace ), self:GetElseIf( RootTrace ) )
end

function Compiler:GetElseIf( RootTrace ) -- ElseIf / Else
	if self:AcceptToken( "eif" ) then
		return self:Compile_ELSEIF( self:TokenTrace( RootTrace ), self:GetCondition( RootTrace ), self:GetBlock( "elseif statement", RootTrace ), self:GetElseIf( RootTrace ) )
	elseif self:AcceptToken( "els" ) then
		return self:Compile_ELSE( self:TokenTrace( RootTrace ), self:GetBlock( "else statement", RootTrace ) )
	end
end

/*==============================================================================================
	Section: Condition
==============================================================================================*/

function Compiler:GetCondition( RootTrace )
	self:RequireToken( "lpa", "Left parenthesis (( ) missing, to open condition" )
	
	local Expression = self:Compile_IS( self:TokenTrace( RootTrace ), self:GetExpression( RootTrace ) )
	
	self:RequireToken( "rpa", "Right parenthesis ( )) missing, to close condition" )
	
	return Expression
end

/*==============================================================================================
	Section: Blocks
==============================================================================================*/

function Compiler:GetBlock( Type, RootTrace )
	local StatmentExit = self.StatmentExit
	self.StatmentExit = nil
	
	self:RequireToken( "lcb", "Left curly bracket ({) expected after %s", Type )
	
	self:PushScope( )
	
	local Statements = self:GetStatements( "rcb", RootTrace )
	
	self:PopScope( )
	
	self:RequireToken( "rcb", "Right curly bracket (}) missing, to close %s", Type )
	
	local ExitResult = self.StatmentExit
	self.StatmentExit = StatmentExit
	
	return Statements, ExitResult
end

/*==============================================================================================
	Section: For Loop
==============================================================================================*/

function Compiler:Statment_FOR( RootTrace )
	local Trace = self:TokenTrace( RootTrace )
	
	self:RequireToken( "lpa", "Left parenthesis (( ) missing, after for" )
	
	if !self:AcceptToken( "fun" ) then
		self:RequireToken( "func", "variable type expected for loop deceleration" )
	end
	
	local Class = self:GetClass( Trace, self.TokenData ).Short
	
	self:RequireToken( "var", "variable expected for loop deceleration" )
	
	local Variable = self.TokenData
	self:RequireToken( "ass", "assignment operator (=) expected for loop deceleration" )
	
	local Assignment = self:Compile_DECLAIR( Trace, "Local", Variable, Class, self:GetExpression( Trace ) )
	
	self:RequireToken( "sep", "separator (;) expected after loop deceleration" )
	
	local Condition = self:Compile_IS( self:TokenTrace( Trace ), self:GetExpression( Trace ) )
	
	self:RequireToken( "sep", "separator (;) expected after loop condition" )
	
	self:RequireToken( "var", "Step expression expected after loop condition" )
	
	local Step = self:Statment_VAR( Trace )
	
	if !Step then self:TokenError( "Invalid Step expression for loop" ) end
	
	self:RequireToken( "rpa", "Right parenthesis ( )) missing, to close for loop" )
	
	self:PushFlag( "NewCells", { } )
	self:PushFlag( "LoopDepth", self:GetFlag( "LoopDepth", 0 ) + 1 )
	
	local Block = self:GetBlock( "for loop", Trace )
	
	local Inst = self:Compile_FOR( Trace, Class, Assignment, Condition, Step, Block )
	
	self:PopFlag( "NewCells" )
	self:PopFlag( "LoopDepth" )
	
	return Inst
end

/*==============================================================================================
	Section: While Loop
==============================================================================================*/
function Compiler:Statment_WHL( RootTrace )
	local Trace = self:TokenTrace( RootTrace )
	
	local Condition = self:GetCondition( RootTrace )
	
	self:PushFlag( "NewCells", { } )
	self:PushFlag( "LoopDepth", self:GetFlag( "LoopDepth", 0 ) + 1 )
	
	local Block = self:GetBlock( "while loop", Trace )
	
	local Inst = self:Compile_WHILE( Trace, Condition, Block )
	
	self:PopFlag( "NewCells" )
	self:PopFlag( "LoopDepth" )
	
	return Inst
end

/*==============================================================================================
	Section: ForEach Loop
==============================================================================================*/
function Compiler:Statment_EACH( RootTrace )
	local Trace = self:TokenTrace( RootTrace )
	
	self:RequireToken( "lpa", "Left parenthesis (( ) missing, after for" )
	
	if !self:AcceptToken( "fun" ) and !self:AcceptToken( "func" ) then
		self:TraceError( Trace, "type expected for Variable, in foreach loop" )
	end
	
	local TypeA, TypeB = self:GetClass( Trace, self.TokenData ).Short
	
	self:RequireToken( "var", "Variable expected after type, in foreach loop" )
	
	local RefA, RefB = self:Assign( Trace, self.TokenData, TypeA, "Local" )
	
	if self:AcceptToken( "sep" ) then
		
		if !self:AcceptToken( "fun" ) and !self:AcceptToken( "func" ) then
			self:TraceError( Trace, "type expected for Variable, in foreach loop" )
		end
		
		TypeB = self:GetClass( Trace, self.TokenData ).Short
		
		self:RequireToken( "var", "Variable expected after type, in foreach loop" )
		
		RefB = self:Assign( Trace, self.TokenData, TypeB, "Local" )
	end
	
	self:RequireToken( "col", "Colon (:) expected before table, in foreach loop" )
	
	local Value = self:GetExpression( Trace )
	
	self:RequireToken( "rpa", "Left parenthesis ( )) missing, after for" )
	
	self:PushFlag( "NewCells", { } )
	self:PushFlag( "LoopDepth", self:GetFlag( "LoopDepth", 0 ) + 1 )
	
	local Block, Inst = self:GetBlock( "foreach", Trace )
	
	if !TypeB then
		Inst = self:Compile_FOREACH( Trace, Value, TypeA, RefA, nil, nil, Block )
	else
		Inst = self:Compile_FOREACH( Trace, Value, TypeB, RefB, TypeA, RefA, Block )
	end
	
	self:PopFlag( "NewCells" )
	self:PopFlag( "LoopDepth" )
	
	return Inst
end

-- [[ Table 1, KeyType 2, KeyAss 3, ValType 4, ValAss 5, Statements 6

/*==============================================================================================
	Section: Try Catch
==============================================================================================*/
function Compiler:Statment_TRY( RootTrace )
	local Trace, Block = self:TokenTrace( RootTrace ), self:GetBlock( "try", RootTrace )
	
	if !self:CheckToken( "cth" ) then
		self:TokenError( "catch statement (catch), expected after try." )
	end
	
	return self:Compile_TRY( Trace, Block, self:GetCatchStmt( RootTrace ), self:GetFinalStmt( RootTrace ) )
end

function Compiler:GetCatchStmt( RootTrace )
	if self:AcceptToken( "cth" ) then
		local Trace = self:TokenTrace( RootTrace )
		
		self:RequireToken( "lpa", "Left parenthesis (( ) missing, after catch" )
		
		local Exceptions, LK, I = nil, { }, 1
		
		if self:AcceptToken( "fun" ) then
			Exceptions = { self.TokenData }
			LK[ self.TokenData ] = true
			
			while self:AcceptToken( "com" ) do
				self:ExcludeToken( "com", "Exception separator (,) must not appear twice" )
				
				self:RequireToken( "fun", "Exception class expected after comma (,)" )
				
				if !API.Exceptions[ self.TokenData ] then
					self:TokenError( "No such exception %s", self.TokenData )
				elseif LK[ self.TokenData ] then
					self:TokenError( "Exception class %s can not be caught twice", self.TokenData )
				end
				
				I = I + 1
				
				Exceptions[I] = self.TokenData
				LK[ self.TokenData ] = true
			end
		end
		
		self:RequireToken( "var", "Variable expected for catch" )
		
		local Ref = self:Assign( Trace, self.TokenData, "!", "Local" ) 
		
		self:RequireToken( "rpa", "Right parenthesis ( )) missing, to catch" )
		
		return self:Compile_CATCH( Trace, Ref, Exceptions, self:GetBlock( "catch", Trace ), self:GetCatchStmt( RootTrace ) )
	end
end

function Compiler:GetFinalStmt( RootTrace )
	if self:AcceptToken( "fnl" ) then
		return self:GetBlock( "final", RootTrace ) 
	end
end

/*==============================================================================================
	Section: Events Statements
==============================================================================================*/

function Compiler:Statment_EVT( RootTrace )
	local Trace = self:TokenTrace( RootTrace )
	
	self:RequireToken( "fun", "Event name required after event." )
	
	local EventName = self.TokenData
	
	self:RequireToken( "lpa", "Left parenthesis ( () missing, after catch" )
	
	self:PushFlag( "NewCells", { } )
	
	local Perams, HasVarg, Count = self:BuildPerams( Trace )	

	self:RequireToken( "rpa", "Right parenthesis ( )) missing, to close event parameters" )
	
	self:PushFlag( "Event", EventName )
	self:PushFlag( "HasVargs", HasVarg )
	self:PushFlag( "ReturnedType", "" )
	self:PushFlag( "CanReturn", true )
	self:PushFlag( "LoopDepth", 0 )
	
	local Inst = self:Compile_EVENT( Trace, EventName, Perams, HasVarg, self:GetBlock( "event", Trace ) )
	
	self:PopFlag( "LoopDepth" )
	self:PopFlag( "ReturnedType" )
	self:PopFlag( "CanReturn" )
	self:PopFlag( "HasVargs" )
	self:PopFlag( "Event" )
	self:PopFlag( "NewCells" )
	
	return Inst
end

/*==============================================================================================
	Section: Custom Syntax functions
==============================================================================================*/
function Compiler:FUNC_include( Trace )
	Trace.Location = "include(sb)"
	
	self:RequireToken( "lpa", "Left parenthesis (( ) missing after include" )
	
	self:RequireToken( "str", "Raw String expected for include( \"path\" )" )
	
	local Path, Scoped = self.TokenData, true
	
	if self:AcceptToken( "com" ) then
		if self:AcceptToken( "fls" ) then
			Scoped = false
		elseif !self:AcceptToken( "tre" ) then
			self:TraceError( self:TokenTrace( Trace ), "Raw boolean expected for include( String, Boolean )" )
		end
	end
	
	self:RequireToken( "rpa", "Right parenthesis ( )) missing, to close include" )
	
	return self:Compile_INCLUDE( Trace, Path, Scoped )
end
 
function Compiler:FUNC_print( Trace )
	Trace.Location = "print(...)"
	
	self:RequireToken( "lpa", "Left parenthesis (( ) missing after print" )
	
	local Values, Index = { }, 0
	
	if !self:CheckToken( "rpa" ) then
		while self:HasTokens( ) do
			self:ExcludeToken( "com", "Expression separator (,) can not appear here." )
			
			Index = Index + 1
			
			local Value = self:GetExpression( Trace )
			
			if Value.Return ~= "s" and Value.Return ~= "?" and Value.Return ~= "..." then
				Value = self:Compile_CAST( Trace, "string", Value )
			end -- Auto cast to string!
			
			Values[ Index ] = Value
			
			if !self:AcceptToken( "com" ) then
				break
			end
		end
	end
	
	self:RequireToken( "rpa", "Right parenthesis ( )) missing after print" )
	
	return self:Compile_PRINT( Trace, Values, Index )
end

--[[ TODO LIST!
/*==============================================================================================
	Section: Switch Case
	Purpose: Cus TechBot will give me Admin!
	Creditors: Rusketh
==============================================================================================*/
function Parser:SwitchCase( )
	if self:AcceptToken( "swh" ) then
		local Trace = self:TokenTrace( )

		if !self:AcceptToken( "lpa" ) then
			self:Error( "Left parenthesis (( ) missing, after 'switch'" )
		end

		local Expr = self:Expression( )

		if !self:AcceptToken( "rpa" ) then
			self:Error( "Right parenthesis ( )) missing, after loop condition" )
		end

		if !self:AcceptToken( "lcb" ) then
			self:Error( "Left curly bracket ({) expected after to start switch block" )
		end

		local Cases, Statements, Index, Default = { }, {}, 0

		while true do
			if self:CheckToken( "rcb" ) or !self:HasTokens( ) then
				break -- No code left!
			elseif self:AcceptToken( "cse" ) then
				Index = Index + 1

				if self:CheckToken( "num" ) then
					Cases[Index] = self:GetNumber( )
				elseif self:AcceptToken( "str" ) then -- Create a string from a string token.
					Cases[Index] = self:Instruction( "string", self:TokenTrace( ), self.TokenData)
				else
					self:Error( "number or string expected, after case" )
				end

				if !self:AcceptToken( "col" ) then
					self:Error( "colon (:) expected after case in switch block" )
				else
					Statements[Index] = self:CaseBlock( )
				end
			elseif self:AcceptToken( "dft" ) then
				if !self:AcceptToken( "col" ) then
					self:Error( "colon (:) expected after default in switch block" )
				elseif Default then
					self:Error( "default case must not appear twice" )
				else
					Index, Default = Index + 1, true
					Statements[Index] = self:CaseBlock( )
				end
			else
				self:Error( "case expected inside case block" )
			end
		end

		if !self:AcceptToken( "rcb" ) then
			self:Error( "Right curly bracket (}) missing, to close %s", Name or "condition" )
		end

		return self:Instruction( "switch", Trace, Expr, Cases, Statements, Index) 
	end
end

function Parser:CaseBlock( )
	self.LoopDepth = self.LoopDepth + 1
	local Trace, Statements, Index = self:TokenTrace( ), { }, 0

	if !self:HasTokens( ) or self:CheckToken( "rcb" ) or self:CheckToken( "cse" ) or self:CheckToken( "dft" ) then
		return nil
	end

	while true do

		Index = Index + 1
		Statements[Index] = self:Statement( )

		self:AcceptSeperator( )

		if !self:HasTokens( ) or self:CheckToken( "rcb" ) or self:CheckToken( "cse" ) or self:CheckToken( "dft" ) then
			break
		elseif !self:AcceptSeperator( ) and self.NextLine == self.TokenLine then
			self:Error( "Statements must be separated by semicolon (;) or newline" )
		elseif self.StatmentExit then
			self:Error( "Unreachable code after %s", self.StatmentExit)
		end
	end

	self.StatmentExit = nil
	self.LoopDepth = self.LoopDepth - 1
	return self:Instruction( "sequence", Trace, Statements) 
end
]]--
