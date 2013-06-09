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

		-- { "?", "qsm", "?" }, Cant get this stable yet =(
		{ ":", "col", "colon" },
		{ ";", "sep", "semicolon" },
		{ ",", "com", "comma" },
		{ "$", "dlt", "delta" },
		{ "#", "len", "length" },
		{ "~", "trg", "trigger" },
		{ "->", "wc", "connect" },

	-- BRACKETS:

		{ "(", "lpa", "left parenthesis" },
		{ ")", "rpa", "right parenthesis" },
		{ "{", "lcb", "left curly bracket" },
		{ "}", "rcb", "right curly bracket" },
		{ "[", "lsb", "left square bracket" },
		{ "]", "rsb", "right square bracket" },

	-- MISC:

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
	
	self.Expire = SysTime( ) + 2
	
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
		self:Error( "Code took to long to Compile." )
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

/*==============================================================================================
	Section: Load the Compiler Stages!
==============================================================================================*/
include( "tokenizer.lua" )
include( "parser.lua" )
include( "compiler.lua" )
include( "debugger.lua" )
