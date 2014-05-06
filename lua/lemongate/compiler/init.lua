/*==============================================================================================
	Expression Advanced: Compiler -> Init.
	Purpose: The core of the compiler.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON = LEMON

local API = LEMON.API

LEMON.Compiler = { }

local Compiler = LEMON.Compiler
Compiler.__index = Compiler

/*==============================================================================================
	Section: Tokens
==============================================================================================*/

Compiler.RawTokens = {

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
		{ ";", "sep", "semicolon" },
		{ ",", "com", "comma" },
		{ "$", "dlt", "delta" },
		{ "#", "len", "length" },
		{ "~", "trg", "trigger" },
		{ "->", "wc", "connect" },
		{ "::", "cnd", "conditional" },

	-- BRACKETS:

		{ "(", "lpa", "left parenthesis" },
		{ ")", "rpa", "right parenthesis" },
		{ "{", "lcb", "left curly bracket" },
		{ "}", "rcb", "right curly bracket" },
		{ "[", "lsb", "left square bracket" },
		{ "]", "rsb", "right square bracket" },

	-- MISC:

		{ '@', "pred", "predictive operator" },
		{ "...", "varg", "varargs" },
}

-- Todo: API Hook!

table.sort( Compiler.RawTokens, 
	function( Token, Token2 )
		return #Token[1] > #Token2[1]
	end )
	
/*==============================================================================================
	Section: Compiler Executor
==============================================================================================*/

local pcall, setmetatable, SysTime = pcall, setmetatable, SysTime

function Compiler.Execute( ... )
	return pcall( Compiler.Run, setmetatable( { }, Compiler ), ... )
end

function Compiler:Run( Code, Files, NoCompile )
	
	self.Pos = 0
	
	self.TokenPos = -1
	
	self.Char, self.ReadData = "", ""
	
	self.ReadChar, self.ReadLine = 1, 1
	
	self.Buffer, self.Len = Code, #Code
	
	self:NextChar( )
	
	self.Flags = { }
	
	self.Expire = SysTime( ) + 20
	
	self.Tokens = { self:GetNextToken( ), self:GetNextToken( ) }
	
	self:NextToken( )
	
	self.CompilerRuns = 0
	
	return self:CompileCode( Code, Files, NoCompile )
end

/*==============================================================================================
	Section: Errors
==============================================================================================*/

local Format, error = string.format, error

function Compiler:Error( Offset, Message, A, ... )
	if A then Message = Format( Message, A, ... ) end
	error( Format( "%s at line %i, char %i", Message, self.ReadLine, self.ReadChar + Offset ), 0 )
end

function Compiler:TraceError( Trace, ... )
	if type( Trace ) ~= "table" then
		print( Trace, ... )
		debug.Trace( )
	end
	
	self.ReadLine, self.ReadChar = Trace[1], Trace[2]
	self:Error( 0, ... )
end

function Compiler:TokenError( ... )
	self:TraceError( self:TokenTrace( ), ... )
end

/*==============================================================================================
	Section: Trace
==============================================================================================*/

function Compiler:Trace( )
	return { self.ReadLine, self.ReadChar }
end

function Compiler:CompileTrace( Trace )
	if !Trace then debug.Trace( ) end
	return API.Util.ValueToLua( Trace )
end

/*==============================================================================================
	Section: Class
==============================================================================================*/
function Compiler:NType( Type )
	return API:GetClass( Type ).Name
end

function Compiler:SType( Type )
	if Type == "..." then return self:TokenError( "Invalid use of vararg (...) or unpack(T)." ) end
	return API:GetClass( Type ).Short
end

function Compiler:GetClass( Trace, Name )
	local Class = API:GetClass( Name, true )
	
	if Class and (Name == "int" or Name == "bool") then
		return Class
	elseif !Class or Class.Name ~= Name then
		self:TraceError( Trace, "No such class %s", Name )
	end
	
	return Class
end

/*==============================================================================================
	Section: Operators
==============================================================================================*/
function Compiler:GetOperator( Name, Param1, Param2, ... )
	local Op = API.Operators[ Format( "%s(%s)", Name, table.concat( { Param1 or "", Param2, ... } , "" ) ) ]
	
	if Op or !Param1 then
		return Op
	end
	
	local Class = API:GetClass( Param1, true )
	
	if Class and Class.DownCast then
		return self:GetOperator( Name, Class.DownCast, Param2, ... )
	
	elseif Param2 then
		local Class = API:GetClass( Param2, true )
	
		if Class and Class.DownCast then
			return self:GetOperator( Name, Param1, Class.DownCast, ... )
		end
	end
end

/*==============================================================================================
	Section: Loop Protection
==============================================================================================*/

function Compiler:TimeCheck( )
	if SysTime( ) > self.Expire then
		self:Error( 0, "Code took to long to Compile." )
	end
end

/*==============================================================================================
	Section: Falgs
==============================================================================================*/
function Compiler:PushFlag( Flag, Value )
	local FlagTable = self.Flags[ Flag ]
	
	if !FlagTable then
		FlagTable = { }
		self.Flags[ Flag ] = FlagTable
	end
	
	FlagTable[ #FlagTable + 1 ] = Value
end

function Compiler:PopFlag( Flag )
	local FlagTable = self.Flags[ Flag ]
	
	if FlagTable and #FlagTable > 1 then
		return table.remove( FlagTable, #FlagTable )
	end
end

function Compiler:GetFlag( Flag, Default )
	local FlagTable = self.Flags[ Flag ]
	
	if FlagTable then
		return FlagTable[ #FlagTable ] or Default
	end
	
	return Default
end

function Compiler:SetFlag( Flag, Value )
	local FlagTable = self.Flags[ Flag ]
	
	if FlagTable and #FlagTable > 1 then
		FlagTable[#FlagTable] = Value
	end
end

/*==========================================================================
	Section: Inline Checker
==========================================================================*/
local Valid_Words = {
	["return"] = true,
	["continue"] = true,
	["break"] = true,
	["local"] = true,
	["while"] = true,
	["for"] = true,
	["end"] = true,
	["if"] = true,
	["do"] = true
}

function Compiler:IsPreparable( Line )
	Line = string.Trim( Line )
	local _, _, Word = string.find( Line, "^([a-zA-Z_][a-zA-Z0-9_]*)" )
	return Valid_Words[ Word ] or ( Word and string.find( Line, "[=%(]" ) )
end

/*==========================================================================
	Section: CompileMode
==========================================================================*/

function Compiler:ConstructOperator( Types, Second, First, ... )
	if !First then
		self:Error( 0, "Unpredicable error: No inline was given!" )
	end
	
	local Values, Vargs = { ... }
	local Variants, Prepare = { }, { }
	
	local TestPeram = 1
	local MaxPerams = math.Max( #Types, #Values )
	
	while ( TestPeram < MaxPerams ) do
		local Type = Types[ TestPeram ]
		
		if Type and Type == "..." then
			Vargs = TestPeram
		end
		
		if string.find( First, "value %%" .. TestPeram ) or string.find( First, "prepare %%" .. TestPeram ) then
			TestPeram = TestPeram + 1
			MaxPerams = MaxPerams + 1
		elseif !Second then
			break
		elseif string.find( Second, "value %%" .. TestPeram ) or string.find( Second, "prepare %%" .. TestPeram ) then
			TestPeram = TestPeram + 1
			MaxPerams = MaxPerams + 1
		else
			break
		end
	end
	
	for I = MaxPerams, 1, -1 do
			
			local Prep, Value
			
			local RType, IType = Types[I] or ""
			local Input = Values[I] or "nil"
		
		-- 1) Read the instruction.
			
			if type( Input ) == "table" then
				Prep = Input.Prepare
				Value = Input.Inline
				IType = Input.Return
			elseif Input then
				Value = Input
			end
			
		-- 2) Count usage of instruction.
			
			local _, Usages = string.gsub( First, "value %%" .. I, "" )
			
			if Second then
				local _, Count = string.gsub( Second, "value %%" .. I, "" )
				Usages = Usages + Count
			end
		
		-- 3) Replace instruction with variable if needed.
			
			if Usages > 1 and type( Input ) ~= "number" and !string.find( Value, "^_([a-zA-z0-9]+)" ) then
				local ID = self:NextLocal( )
				Prep = Format( "%s\nlocal %s = %s\n", Prep or "", ID, string.gsub( Value, "(%%)", "%%%%" ) )
				
				Value = ID
			end
			
		-- 4) Creat a var-arg variant
			
			if Values[I] and Vargs and I >= Vargs then
				RType = IType
				
				if RType == "?" then
					table.insert( Variants, 1, Value )
				elseif RType == "..." then
					table.insert( Variants, 1, Value )
				else
					table.insert( Variants, 1, Format( "{%s,%q}", Value, RType ) )
				end
			end
			
		-- 5) Replace the inlined data
			Value = string.gsub( Value, "(%%)", "%%%%" )
			
			First = string.gsub( First, "type %%" .. I, Format( "%q", RType or IType or "" ) )
			
			First = string.gsub( First, "value %%" .. I, Value )
			
			if Second then
				Second = string.gsub( Second, "type %%" .. I, Format( "%q", RType or IType or "" ) )
				Second = string.gsub( Second, "value %%" .. I, Value )
		
		-- 6) Check for any specific prepare
				if string.find( Second, "prepare %%" .. I ) then
					Second = string.gsub( Second, "prepare %%" .. I, Prep or "" )
					Prep = nil
				end
			end
				
			if Prep then
				table.insert( Prepare, 1, Prep )
			end
	end
	
	-- 7) Replace Var-Args
		if Vargs then
			local Varargs = string.Implode( ",", Variants )
			
			if !Varargs or Varargs == "" then
				Varargs = "nil"
			end
			
			First = string.gsub( First, "(%%%.%.%.)", Varargs )
			
			if Second then
				Second = string.gsub( Second, "(%%%.%.%.)", Varargs )
			end
		end
		
	-- 8) Insert global prepare
		
		if Second and string.find( Second, "%%prepare" ) then
			Second = string.gsub( Second, "%%prepare", string.Implode( "\n", Prepare ) ) .. "\n"
		else
			Second = string.Implode( "\n", Prepare ) .. ( Second or "" ) .. "\n"
		end
		
	-- 9) Import to enviroment
	
		for RawImport in string.gmatch( First, "(%$[a-zA-Z0-9_]+)" ) do
			local What = string.sub( RawImport, 2 )
			First = string.gsub( First, RawImport, What )
			self:Import( What )
		end
		
		if Second then
			for RawImport in string.gmatch( Second, "(%$[a-zA-Z0-9_]+)" ) do
				local What = string.sub( RawImport, 2 )
				Second = string.gsub( Second, RawImport, What )
				self:Import( What )
			end
		end
		
	return First, Second
end


/*==============================================================================================
	Section: Load the Compiler Stages!
==============================================================================================*/
include( "tokenizer.lua" )
include( "parser.lua" )
include( "compiler.lua" )
include( "debugger.lua" )
