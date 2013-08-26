/*==============================================================================================
	Expression Advanced: Compiler -> Compiler.
	Purpose: The Compiler part of the compiler.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON = LEMON

local API = LEMON.API

local Util = API.Util

local Compiler = LEMON.Compiler

/*==============================================================================================
	Section: Util
==============================================================================================*/
local function NType( Type )
	return API:GetClass( Type ).Name
end

local function SType( Type )
	return API:GetClass( Type ).Short
end

/*==============================================================================================
	Section: Scopes
==============================================================================================*/
function Compiler:InitScopes( )
	self.ScopeID = 1
	self.Global, self.Scope = { }, { }
	self.Scopes = { [0] = self.Global, self.Scope }
	
	self.IncRef = 0
	
	self.Cells = { }
	self.InPorts = { }
	self.OutPorts = { }
end

function Compiler:PushScope( )
	self.Scope = { }
	self.ScopeID = self.ScopeID + 1
	self.Scopes[ self.ScopeID ] = self.Scope
end

function Compiler:PopScope( )
	self.Scopes[ self.ScopeID ] = nil
	self.ScopeID = self.ScopeID - 1
	self.Scope = self.Scopes[ self.ScopeID ]
end

/*==============================================================================================
	Section: Cell Util
==============================================================================================*/
function Compiler:NextRef( )
	local Ref = self.IncRef + 1
	self.IncRef = Ref
	return Ref
end

function Compiler:TestCell( Trace, Ref, Type, Variable )
	local Cell = self.Cells[ Ref ]
	if !Cell and Variable then
		self:TraceError( Trace, "%s of type %s does not exist", Variable, NType( Type ) )
	elseif Cell.Type ~= Type and Variable then
		self:TraceError( Trace, "%s of type %s can not be assigned as %s", Variable, NType( Cell.Type ), NType( Type ) )
	else
		return true
	end
end

function Compiler:FindCell( Trace, Variable )
	for Scope = self.ScopeID, 0, -1 do
		local Ref = self.Scopes[ Scope ][ Variable ]
		if Ref then return Ref, Scope end
	end
end

function Compiler:IsInput( Trace, Ref )
	local Cell = self.Cells[ Ref]
	return Cell and Cell.Assign == "Inport"
end

function Compiler:IsOutput( Trace, Ref )
	local Cell = self.Cells[ Ref]
	return Cell and Cell.Assign == "Outport"
end

/*==============================================================================================
	Section: Cell Assigment
==============================================================================================*/
local CELL_LOCAL = "Local"
local CELL_GLOBAL = "Global"
local CELL_INPUT = "Inport"
local CELL_OUTPUT = "Outport"

function Compiler:SetVariable( Trace, Variable, Type, GlobAss )
	local Ref, Scope = self:FindCell( Trace, Variable )
	
	if !Ref then
		self:TraceError( Trace, "Variable %s does not exist", Variable )
	elseif GlobAss then
		return self:Assign( Trace, Variable, Type, CELL_GLOBAL )
	else
		local Cell = self.Cells[ Ref ]
		if Cell.Type ~= Type then
			self:TraceError( Trace, "%s of type %s can not be assigned as %s", Variable, NType( Cell.Type ), NType( Type ) ) 
		else
			return Ref, Scope
		end
	end
end

function Compiler:GetVariable( Trace, Variable )
	local Ref, Scope = self:FindCell( Trace, Variable )
	local Cell = self.Cells[ Ref ]
	if Cell then return Ref, Cell.Type end
end

function Compiler:Assign( Trace, Variable, Type, Assign, Static )
	local Class = API:GetClass( Type )
	
	if Assign == CELL_LOCAL then
		local Ref = self.Scope[ Variable ]
		
		if Ref then
			self:TestCell( Trace, Ref, Type, Variable )
		else
			Ref = self:NextRef( )
			self.Scope[ Variable ] = Ref
			self.Cells[ Ref ] = { Ref = Ref, Scope = self.ScopeID, Type = Type, Class = Class, Variable = Variable, Assign = Assign, Static = Static, NotGarbage = Static }
		
			local NewCells = self:GetFlag( "NewCells" ) -- Lambda
			
			if !Static and NewCells then
				NewCells[Ref] = true
				NewCells.Push = true
			end
		end
		
		return Ref, self.ScopeID
	elseif Assign == CELL_GLOBAL then
		local Ref = self.Global[ Variable ]
		
		if Ref then
			self:TestCell( Trace, Ref, Type, Variable )	
		else
			Ref = self:NextRef( )
			self.Global[ Variable ] = Ref
			self.Cells[ Ref ] = { Ref = Ref, Scope = 0, Type = Type, Class = Class, Variable = Variable, Assign = Assign, NotGarbage = true, Static = Static }
		end
		
		local LRef = self.Scope[ Variable ]
		if LRef then
			self:TraceError( Trace, "Global vairiable %s conflicts with %s variable %s", Variable, self.Cells[ LRef ].Assign, Variable )
		end
		
		self.Scope[ Variable ] = Ref
		return Ref, 0
	elseif !Class.WireName then
		self:TraceError( Trace, "%s is not a valid %s class", NType( Type ), Assign )
	elseif Assign == CELL_INPUT and Class.Wire_In then
		local Ref = self.InPorts[ Variable ]
		
		if Ref then
			self:TestCell( Trace, Ref, Type, Variable )
		else
			Ref = self:NextRef( )
			self.InPorts[ Variable ] = Ref
			self.Cells[ Ref ] = { Ref = Ref, Scope = -1, Type = Type, Class = Class, Variable = Variable, Assign = Assign, NotGarbage = true }
		end
			
		local LRef = self.Scope[ Variable ]
		if LRef then
			self:TraceError( Trace, "Inport vairiable %s conflicts with %s variable %s", Variable, self.Cells[ LRef ].Assign, Variable )
		end
		
		self.Scope[ Variable ] = Ref
		return Ref, 0
	elseif Assign == CELL_OUTPUT and Class.Wire_Out then
		local Ref = self.OutPorts[ Variable ]
		
		if Ref then
			self:TestCell( Trace, Ref, Type, Variable )
		else
			Ref = self:NextRef( )
			self.OutPorts[ Variable ] = Ref
			self.Cells[ Ref ] = { Ref = Ref, Scope = -1, Type = Type, Class = Class, Variable = Variable, Assign = Assign, NotGarbage = true }
		end
			
		local LRef = self.Scope[ Variable ]
		if LRef then
			self:TraceError( Trace, "Outport vairiable %s conflicts with %s variable %s", Variable, self.Cells[ LRef ].Assign, Variable )
		end
		
		self.Scope[ Variable ] = Ref
		return Ref, 0
	else
		self:TraceError( Trace, "%s is not a valid %s class", NType( Type ), Assign )
	end
end

function Compiler:NotGarbage( Trace, Ref )
	if self.Cells[ Ref ] then
		self.Cells[ Ref ].NotGarbage = true
	end
end

/*==============================================================================================
	Section: Compiler
==============================================================================================*/
function Compiler:CompileCode( Code, Files, NoCompile )
	self:InitScopes( )
	
	self.LocID = 0
	self.UtilID = 0
	self.Files = Files or { }
	self.FilesLK = { }
	self.Imports = { }
	self.ImportsLK = { }
	self.PrepCode = { }
	self.PrepCodeLK = { }
	
	local Lua = self:GetStatements( { 0, 0, Location = "Root" } ).Prepare
	
	self.Native = self:LUA_Format( string.gsub( [[
		-- Allow basic libaries & functions
			local API = LEMON.API
			local Externals = API.Externals
			
			local function LongType( Type )
				return API:GetClass( Type ).Name
			end
			
		-- Allow basic libaries & functions	
			local pcall, error = pcall, error
			local Vector3, Vector2, Vector, Angle = Vector3, Vector2, Vector, Angle
			local math, string, table, bit = math, string, table, bit
			local tostring, unpack, pairs, print = tostring, unpack, pairs, print
		
		-- Required Locals
			local ExitDeph
			local UTIL = { }
			local PrintTable = PrintTable -- Remove ME!
		-- Imports
			]] .. string.Implode( "\n", self.Imports ) .. [[
			
		-- Lock Out Lua
			setfenv(1, setmetatable( { }, {
				__index = function( _, Value ) debug.Trace( ); error("Attempt to reach Lua environment " .. Value, 1 ) end,
				__newindex = function( _, Value ) error("Attempt to write to Lua environment " .. Value, 1 ) end,
			} ) )
				
		return function( Context )
			
			-- Prep Code
				local Memory = Context.Memory
				local Delta = Context.Delta
				local Click = Context.Click
				
				]] .. string.Implode( "\n", self.PrepCode ) .. [[
		
			-- Main Body:
				]] .. Lua .. [[
		end]], " modulus ", "%%" ) )
		
	if !NoCompile then
		local Compiled = CompileString( self.Native, "LemonCompiler", false )
		
		if type( Compiled ) == "string" then
			file.Write( "LemonTest.txt", Code .. "\n/*=== COMPILED ===*/\n" .. self.Native )
			self:Error( 0, "Failed to compile native lua (%s)", Compiled )
		end
	
		self.Execute = Compiled( )
	end
	
	return self
end

function Compiler:Instruction( Trace, Perf, Return, Inline, Prepare )
	return { Trace = Trace, Return = Return, Return = Return, Inline = Inline, Prepare = Prepare, Perf = Perf }
end

local Format = string.format

function Compiler:FakeInstr( Trace, Return, Inline, A, ... )
	if A then Inline = Format( Inline, A, ... ) end
	return self:Instruction( Trace, 0, Return, Inline )
end -- Makes hacky stuff look less hacky!

function Compiler:Evaluate( Trace, Instr )
	if type( Instr ) != "table" or !Instr.Prepare or Instr.Evaluated then
		return Instr
	end -- No need to evaluate here!
	
	local Perf = Instr.Perf 
	local ID = self:NextLocal( )
	local Lua = "local " .. ID .. " = function( )\n"
	
	if Perf and Perf > 0 then
		Lua = Lua .. "Context:PushPerf( " .. self:CompileTrace( Trace ) .. ", " .. Perf .. " )\n"
	end
	
	Lua = Lua ..( Instr.Prepare or "" ) .. "\nreturn " .. Instr.Inline .. "\nend\n"
	
	local Instr = self:Instruction( Trace, 0, Instr.Return or "", ID .. "()", Lua )
	Instr.Evaluated = true -- Prevents revaluation.
	return Instr
end

function Compiler:PushEnviroment( )
	local Cells = self:GetFlag( "NewCells" )
	
	if !Cells or !Cells.Push then
		return ""
	end
	
	Cells.Push = nil
	
	return "local Cells = " .. Util.ValueToLua( Cells ) .. "\nlocal Memory, Delta, Click = Context:Enviroment( Memory, Delta, Click, Cells )"
end

/*==============================================================================================
	Section: Importing
==============================================================================================*/
function Compiler:Import( Value )
	if !self.ImportsLK[ Value ] then
		self.Imports[ #self.Imports + 1 ] = "local " .. Value .. " = " .. Value
		self.ImportsLK[ Value ] = true
	end
end

function Compiler:Prepare( Name, Lua )
	if !self.PrepCodeLK[ Name ] then
		self.PrepCode[ #self.PrepCode + 1 ] = Lua
		self.PrepCodeLK[ Name ] = true
	end
end

/*==============================================================================================
	Section: Indexing
==============================================================================================*/
local Chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local LChars = "\"#$%&()*+,-./:;<=>?@[]^_`{|}~" -- Extra should we need them =D

function Compiler:NextBufferIndex( Index, Long )
	local Chars = Long and Chars .. LChars or Chars
	local Hash = ""
	
	while true do
		local I = Index % #Chars
		Index = math.floor( Index / #Chars )
		Hash = Chars[ I + 1] .. Hash
		
		if Index == 0 then
			break
		end
	end
	
	return Hash
end

function Compiler:NextLocal( )
	local ID = self:NextBufferIndex( self.LocID, false )
	self.LocID = self.LocID + 1
	return "_" .. ID
end

function Compiler:NextUtil( )
	local ID = self:NextBufferIndex( self.UtilID, false )
	self.UtilID = self.UtilID + 1
	return "_" .. ID
end
/*==============================================================================================
	Section: Statments
==============================================================================================*/

function Compiler:Compile_SEQUENCE( Trace, Statements )
	local Lua, Lines, Perf = "", { }, 0
	
	for I = 1, #Statements do
		local Instr = Statements[ I ]
		
		if !Instr then
			self:TraceError( Trace, "Unpredicted compile error, Sequence got invalid statment." )
		end
		
		Perf = Perf + (Instr.Perf or 0)
		
		if Instr.Prepare and self:IsPreparable( Instr.Prepare ) then
			table.insert( Lines, Instr.Prepare )
		end
		
		if Instr.Inline and self:IsPreparable( Instr.Inline ) then
			table.insert( Lines, Instr.Inline )
		end
	end
	
	if Perf > 0 then
		Lua = "Context:PushPerf( " .. self:CompileTrace( Trace ) .. ", " .. Perf .. " )\n"
	end
	
	if #Lines > 1 then
		Lua = Lua .. [[do
			]] .. string.Implode( "\n", Lines ) .. [[
		end]]
	elseif Lines[1] then
		Lua = Lua .. Lines[1]
	end
	
	return self:Instruction( Trace, 0, "", "", Lua .. "\n" )
end

/*==============================================================================================
	Section: Raw Values
==============================================================================================*/

function Compiler:Compile_NUMBER( Trace, Value )
	return self:Instruction( Trace, LEMON_PERF_CHEAP, "n", Value )
end

function Compiler:Compile_STRING( Trace, Value )
	return self:Instruction( Trace, LEMON_PERF_CHEAP, "s", Value )
end

function Compiler:Compile_BOOLBEAN( Trace, Value )
	return self:Instruction( Trace, LEMON_PERF_CHEAP, "b", Value and "true" or "false" )
end

/*==============================================================================================
	Section: Casting
==============================================================================================*/
function Compiler:Compile_CAST( Trace, CastType, Value )
	local CastFrom, CastTo = Value.Return, self:GetClass( Trace, CastType )
	
	if CastTo.Short == CastFrom then
		self:TraceError( Trace, "%s can not be cast to itself", CastTo.Name )
	elseif !CastFrom or CastFrom == "" then
		self:TraceError( Trace, "Casting operator recives void" )
	elseif CastFrom == "..." then
		self:TraceError( Trace, "Invalid use of varargs (...)." )
	end
	
	local Op = self:GetOperator( string.lower( CastTo.Name ), CastFrom )
	
	if Op then
		return Op.Compile( self, Trace, Value )
	
	elseif CastTo.DownCast and CastTo.DownCast == CastFrom then
		return self:Instruction( Trace, LEMON_PERF_CHEAP, CastTo.Short, Value.Inline, Value.Prepare )
	
	elseif CastTo.UpCast[ Value.Return ] then
		return self:Instruction( Trace, LEMON_PERF_CHEAP, CastTo.Short, Value.Inline, Value.Prepare )
	end
	
	self:TraceError( Trace, "%s can not be cast to %s",  NType( CastFrom ), CastTo.Name )
end
	
	-- Apple -> DownCast -> Fruit
	-- Fruit ->  Upcast  -> Apple
	
/*==============================================================================================
	Section: Vars
==============================================================================================*/
function Compiler:Compile_VARIABLE( Trace, Variable )
	local Ref, Class = self:GetVariable( Trace, Variable )
	if !Ref then
		self:TraceError( Trace, "Variable %s does not exist", Variable )
	elseif Scope ~= self.ScopeID and self:GetFlag( "Lambda", self:GetFlag( "Event" ) ) then
		self:NotGarbage( Trace, Ref )
	end
	
	local Op = self:GetOperator( "variable", Class ) or self:GetOperator( "variable" )
	
	local Instr = Op.Compile( self, Trace, Ref, Variable )
	Instr.Return = Class
	return Instr
end

function Compiler:Compile_INCREMENT( Trace, Variable, Second )
	local Ref, Class = self:GetVariable( Trace, Variable )
	if !Ref then
		self:TraceError( Trace, "Variable %s does not exist", Variable )
	elseif self:IsInput( Trace, Ref ) then
		self:TraceError( Trace, "Increment operator (++) can not reach Inport %s", Variable )
	elseif Scope ~= self.ScopeID and self:GetFlag( "Lambda", self:GetFlag( "Event" ) ) then
		self:NotGarbage( Trace, Ref )
	end
	
	local Op = Second and self:GetOperator( "i++", Class ) or self:GetOperator( "++i", Class )
	if !Op then self:TraceError( Trace, "Increment operator (++) does not support %s", NType( Class ) ) end
	
	return self:Evaluate( Trace, Op.Compile( self, Trace, Ref ) )
end

function Compiler:Compile_DECREMENT( Trace, Variable, First )
	local Ref, Class = self:GetVariable( Trace, Variable )
	if !Ref then
		self:TraceError( Trace, "Variable %s does not exist", Variable )
	elseif self:IsInput( Trace, Ref ) then
		self:TraceError( Trace, "Increment operator (--) can not reach Inport %s", Variable )
	elseif Scope ~= self.ScopeID and self:GetFlag( "Lambda", self:GetFlag( "Event" ) ) then
		self:NotGarbage( Trace, Ref )
	end
	
	local Op = Second and self:GetOperator( "i--", Class ) or self:GetOperator( "--i", Class )
	if !Op then self:TraceError( Trace, "Decrement operator (--) does not support %s", NType( Class ) ) end
	
	return self:Evaluate( Trace, Op.Compile( self, Trace, Ref ) )
end

function Compiler:Compile_DELTA( Trace, Variable )
	local Ref, Class = self:GetVariable( Trace, Variable )
	
	if !Ref then
		self:TraceError( Trace, "Variable %s does not exist", Variable )
	-- elseif Scope ~= self.ScopeID and self:GetFlag( "Lambda", self:GetFlag( "Event" ) ) then
		-- self:NotGarbage( Trace, Ref )
	end
	
	self:NotGarbage( Trace, Ref )
	
	local Op = self:GetOperator( "$", Class )
	if !Op then self:TraceError( Trace, "Delta operator ($) does not support %s", NType( Class ) ) end
	
	return Op.Compile( self, Trace, Ref )
end

function Compiler:Compile_TRIGGER( Trace, Variable )
	local Ref, Class = self:GetVariable( Trace, Variable )
	
	if !Ref then
		self:TraceError( Trace, "Variable %s does not exist", Variable )
	end
	
	local Op = self:GetOperator( "~", Class )
	if !Op then self:TraceError( Trace, "Changed operator (~) does not support %s", NType( Class ) ) end
	
	return Op.Compile( self, Trace, Ref )
end

/*==============================================================================================
	Section: Assignments
==============================================================================================*/
function Compiler:Compile_ASSIGN( Trace, Variable, Expression )
	local Type = Expression.Return
	
	if !Type or Type == "" then
		self:TraceError( Trace, "Assigment operator recives void" )
	elseif Type == "..." then
		self:TraceError( Trace, "Invalid use of varargs (...)." )
	end
	
	local Ref, Scope = self:SetVariable( Trace, Variable, Type )
	
	if !Ref then
		self:TraceError( Trace, "Variable %s does not exist", Variable )
	elseif self:IsInput( Trace, Ref ) then
		self:TraceError( Trace, "Assigment operator (=) can not reach Inport %s", Variable )
	elseif Scope ~= self.ScopeID and self:GetFlag( "Lambda", self:GetFlag( "Event" ) ) then
		self:NotGarbage( Trace, Ref )
	end
	
	local Op = self:GetOperator( "=", Type ) or self:GetOperator( "=" )
	return Op.Compile( self, Trace, Ref, Expression )
end

function Compiler:Compile_DECLAIR( Trace, Type, Variable, Class, Expression, Static )
	local Ref = self:Assign( Trace, Variable, Class, Type, Static )
	
	if self:IsInput( Trace, Ref ) then
		if Expression then
			self:TraceError( Trace, "Assigment operator (=) can not reach Inport %s", Variable )
		else
			return self:FakeInstr( Trace, "", "" )
		end
	end
	
	if !Expression then
		Expression = self:DefaultValue( Trace, Class )
	end

	if !Expression then
		self:TraceError( Trace, "%s %s must be assigned", NType( Class ), Variable )
	end

	if !Static then
		return self:Compile_ASSIGN( Trace, Variable, Expression )
	end
	
	local Op = self:GetOperator( "=", Class ) or self:GetOperator( "=" )
	return self:GetOperator( "static" ).Compile( self, Trace, Ref, Op.Compile( self, Trace, Ref, Expression ) )
end

function Compiler:DefaultValue( Trace, Type )
	local Op = self:GetOperator( "default", Type )
	
	if Op then
		return Op.Compile( self, Trace )
	end
	
	local Lua = API:GetClass( Type ).Default
	
	if Lua and Lua ~= "nil" then
		return self:FakeInstr( Trace, Type, Lua )
	end
end

/*==============================================================================================
	Section: Primary Operators
==============================================================================================*/
TokenOperators = Compiler.TokenOperators -- Speed mainly!

for _, Operator in pairs( TokenOperators ) do
	
	Compiler["Compile_" .. string.upper( Operator[1] ) ] = function( self, Trace, A, B )
		local Op = self:GetOperator( Operator[2], A.Return, B.Return )
		if !Op then self:TraceError( Trace, "No such operator (%s %s %s)", NType( A.Return ), Operator[2], NType( B.Return ) ) end 
		
		return Op.Compile( self, Trace, A, B )
	end
end

function Compiler:Compile_OR( Trace, A, B )
	
	local Op = self:GetOperator( "||", A.Return, B.Return )
	
	if Op then
		return Op.Compile( self, Trace, A, B )
	end
	
	-- Check for Conditonal Or

	if A.Return == B.Return then
		local Op = self:GetOperator( "?" )
		local ID = "_" .. self:NextLocal( )
		local C = self:Compile_IS( Trace, self:FakeInstr( Trace, A.Return, ID ), true )
		
		if Op and C then
			local Instr = Op.Compile( self, Trace, ID, A, B, C )
			Instr.Return = A.Return
			return Instr
		end
	end
	
	-- Try normal Or
	
	local Op = self:GetOperator( "||", "b", "b" )
	A, B = self:Compile_IS( Trace, A, true ), self:Compile_IS( Trace, B, true )
	
	if Op and A and B then
		return Op.Compile( self, Trace, A, B )
	end
	
	-- Error
	
	self:TraceError( Trace, "No such operator (%s || %s)", NType( A.Return ), NType( B.Return ) )
end

function Compiler:Compile_AND( Trace, A, B )
	local Op = self:GetOperator( "&&", A.Return, B.Return )
	
	if Op then
		return Op.Compile( self, Trace, A, B )
	end
	
	local Op = self:GetOperator( "&&", "b", "b" )
	A, B = self:Compile_IS( Trace, A, true ), self:Compile_IS( Trace, B, true )
	
	if Op and A and B then
		return Op.Compile( self, Trace, A, B )
	end
	
	self:TraceError( Trace, "No such operator (%s && %s)", NType( A.Return ), NType( B.Return ) )
end

function Compiler:Compile_LENGTH( Trace, Expression )
	local Op = self:GetOperator( "#", Expression.Return )
	
	if Op then return Op.Compile( self, Trace, Expression ) end
	
	self:TraceError( Trace, "No such operator (#%s)", NType( Expression.Return ) )
end

function Compiler:Compile_NEGATIVE( Trace, Expression )
	local Op = self:GetOperator( "-", Expression.Return )
	
	if Op then return Op.Compile( self, Trace, Expression ) end
	
	self:TraceError( Trace, "No such operator (-%s)", NType( Expression.Return ) )
end

function Compiler:Compile_CONNECT( Trace, Variable )
	local Ref, Class = self:GetVariable( Trace, Variable )
	
	if !Ref then
		self:TraceError( Trace, "Variable %s does not exist", Variable )
	end
	
	if self:IsInput( Trace, Ref ) then
		local Op = self:GetOperator( "->i" )
		return Op.Compile( self, Trace, Variable )
	elseif self:IsOutput( Trace, Ref ) then
		local Op = self:GetOperator( "->o" )
		return Op.Compile( self, Trace, Variable )
	else
		self:TraceError( Trace, "Connect operator (->) can only reach inport or outport" )
	end
end

/*==============================================================================================
	Section: Is and Not Operator
==============================================================================================*/
function Compiler:Compile_IS( Trace, Expression, NoError )
	local Op = self:GetOperator( "is", Expression.Return )
	
	if Op and Op.Return == "b" then
		return Op.Compile( self, Trace, Expression )
	elseif Expression.Return == "b" then
		return Expression
	elseif !NoError then
		self:TraceError( Trace, "No such condition (is %s)", NType( Expression.Return ) )
	end
end

function Compiler:Compile_NOT( Trace, Expression )
	local Op = self:GetOperator( "not", Expression.Return )
	
	if Op then return Op.Compile( self, Trace, Expression ) end
	
	self:TraceError( Trace, "No such operator (not %s)", NType( Expression.Return ) )
end

/*==============================================================================================
	Section: If and ElseIf and else
==============================================================================================*/
function Compiler:Compile_IF( Trace, Condition, Statments, Else )
	local Lua = ""
	
	if Condition.Prepare then
		Lua = Lua .. Condition.Prepare .. "\n"
	end
	
	if Else and Else.Prepare then
		Lua = Lua .. Else.Prepare .. "\n"
	end
	
	Lua = Lua .. "if ( " .. Condition.Inline .. " ) then\n"
	.. (Statments.Prepare or "") .. (Statments.Inline or "") .. "\n"
	
	if Else and Else.Inline then
		Lua = Lua .. Else.Inline .. "\n"
	end
	
	Lua = Lua .. "end\n"
	
	return self:Instruction( Trace, 1, "", "", Lua )
end

function Compiler:Compile_ELSEIF( Trace, Condition, Statments, Else )
	local Prepare = ""
	
	if Condition.Prepare then
		Prepare = Prepare .. Condition.Prepare .. "\n"
	end
	
	if Else and Else.Prepare then
		Prepare = Prepare .. Else.Prepare .. "\n"
	end
	
	local Sequence = "elseif ( " .. Condition.Inline .. " ) then\n"
	.. (Statments.Prepare or "") .. (Statments.Inline or "") .. "\n"
	
	if Else and Else.Inline then
		Sequence = Sequence .. Else.Inline .. "\n"
	end
	
	return self:Instruction( Trace, 1, "", Sequence, Prepare )
end

function Compiler:Compile_ELSE( Trace, Statments )
	local Sequence = "else\n" .. (Statments.Prepare or "") .. (Statments.Inline or "") .. "\n"
	return self:Instruction( Trace, 1, "", Sequence, "" )
end

/*==============================================================================================
	Section: Lambda
==============================================================================================*/
function Compiler:Compile_LAMBDA( Trace, Params, HasVarArg, Sequence )
	
	-- 1) Create the param checks!
		local CallParams, CallPrepare = { }, { }
		local ID = self:NextLocal( )
	
		for I = 1, #Params do
			local Param, Var = Params[I], "Peram_" .. I
			
			local Op = self:GetOperator( "=", Param[2] ) or self:GetOperator( "=" )
			
			CallParams[I] = Var
			
			if Param[2] ~= "?" then
				local Assign = Op.Compile( self, Trace, Param[3], Var .. "[1]" )
				
				CallPrepare[I] = [[
					if ( !]] .. Var .. " or (" .. Var ..[[[1] == nil) ) then
						Context:Throw( Trace, "invoke", "Paramater ]] .. Param[1] .. [[ is a void value" )
					elseif ( ]] .. Var .. [[[2] ~= "]] .. Param[2] .. [[" ) then
						Context:Throw( Trace, "invoke", "Paramater ]] .. Param[1] .. [[ got " .. ]] .. Var .. [[[2] .. " ]] .. Param[2].. [[ expected." )
					else
						]] ..  Assign.Prepare .. [[ 
					end
				]]
			else
				local Assign = Op.Compile( self, Trace, Param[3], Var )
				
				CallPrepare[I] = [[
					if ( !]] .. Var .. " or (" .. Var ..[[[1] == nil) ) then
						Context:Throw( Trace, "invoke", "Paramater ]] .. Param[1] .. [[ is a void value" )
					else
						PrintTable( ]] .. Var .. [[ )
						]] ..  Assign.Prepare .. [[ 
					end
				]]
			end
		end
		
		if HasVarArg then
			CallParams[ #CallParams + 1 ] = "..."
		end
	
	
	-- 2) Create calling function
		local Params = string.Implode( ", ", CallParams )
		
		local Lua = "local " .. ID .. " = function( " .. Params .. [[ )
			local Trace = ]] .. self:CompileTrace( Trace ) .. [[
			Context:PushPerf( Trace, ]] .. (( Sequence.Perf or 0) + LEMON_PERF_CHEAP ) .. [[ )
			
			]] .. self:PushEnviroment( ) .. [[
			]] .. string.Implode( "\n", CallPrepare ) .. [[
			]] .. Sequence.Prepare .. [[
		end]] .. "\n\n"
			
	-- 3) Function Done
		return self:Instruction( Trace, 1, "f", ID, Lua )
end

function Compiler:Compile_CALL( Trace, Value, ... )
	local Op = self:GetOperator( "call", Value.Return, "..." )
	
	if !Op then
		self:TraceError( Trace, "Call operator does not support %s( ... )", Value.Return )
	end
	
	return Op.Compile( self, Trace, Value, ... )
end

function Compiler:Compile_RETURN( Trace, Expression )
	local Op = self:GetOperator( "return" )
	
	if !Expression then
		Expression = self:FakeInstr( Trace, "?", "{0, \"n\"" )
	elseif Expression.Return ~= "?" then
		Expression = self:Compile_CAST( Trace, "variant", Expression )
	end
	
	return Op.Compile( self, Trace, Expression )
end

/*==============================================================================================
	Section: Loops!
==============================================================================================*/
function Compiler:Compile_FOR( Trace, Class, Assigment, Condition, Step, Statments )
	local Condition = self:Evaluate( Trace, Condition )
	local Step = self:Evaluate( Trace, Step )
	local Op = self:GetOperator( "for", Class )
	
	if !Op then
		self:TraceError( Trace, "%s not compatable with for loops", NType( Class ) )
	end
	
	Statments.Prepare = self:PushEnviroment( ) .. "\n" .. Statments.Prepare
	
	return Op.Compile( self, Trace, Assigment, Condition, Step, Statments )
end

function Compiler:Compile_WHILE( Trace, Condition, Statments )
	local Condition = self:Evaluate( Trace, Condition )
	
	Statments.Prepare = self:PushEnviroment( ) .. "\n" .. Statments.Prepare
	
	return self:GetOperator( "while" ).Compile( self, Trace, Condition, Statments )
end

function Compiler:Compile_FOREACH( Trace, Value, TypeV, RefV, TypeK, RefK, Statments )
	local Op = self:GetOperator( "foreach", Value.Return )
	
	if !Op then
		self:TraceError( Trace, "foreach loop does not support %s", NType( Value.Return ) )
	end
	
	local Op1 = self:GetOperator( "=", TypeV ) or self:GetOperator( "=" )
	local AssVal, AssKey = Op1.Compile( self, Trace, RefV, "Value" ), ""
	TypeV = '"' .. TypeV .. '"'
	
	if RefK then
		local Op2 = self:GetOperator( "=", TypeK ) or self:GetOperator( "=" )
		AssKey = Op2.Compile( self, Trace, RefK, "Key" )
		TypeK = '"' .. TypeK .. '"'
	end
	
	Statments.Prepare = self:PushEnviroment( ) .. "\n" .. Statments.Prepare
	
	return Op.Compile( self, Trace, Value, TypeV, TypeK, AssVal, AssKey, Statments )
end

/*==============================================================================================
	Section: Break and Continue
==============================================================================================*/
function Compiler:Compile_BREAK( Trace, Depth )
	return self:GetOperator( "break" ).Compile( self, Trace, Depth )
end

function Compiler:Compile_CONTINUE( Trace, Depth )
	return self:GetOperator( "continue" ).Compile( self, Trace, Depth )
end

/*==============================================================================================
	Section: Function Calls
==============================================================================================*/
local Functions = LEMON.API.Functions

function Compiler:BeautifulParams( ... )
	local Params, Beautiful = { ... }, ""
	
	if #Params == 0 then
		return ""
	end
	
	Beautiful = NType( Params[1].Return )
	
	for I = 2, #Params do
		Beautiful = Format( "%s, %s", Beautiful, NType( Params[I].Return ) )
		if #Beautiful > 15 then 
			Beautiful = Beautiful .. "..."
			break
		end
	end
	
	return Beautiful
end

function Compiler:Compile_FUNCTION( Trace, Function, ... )
	if self:GetVariable( Trace, Function ) then
		return self:Compile_CALL( Trace, self:Compile_VARIABLE( Trace, Function ), ... )
	end
	
	local Perams, Signature, BestMatch = { ... }, ""
	
	for I = 1, #Perams do
		local Match = Format( "%s(%s...)", Function, Signature ) -- Vargs
		if Functions[ Match ] then BestMatch = Functions[ Match ] end
		
		Signature = Signature .. Perams[I].Return -- Static Args
	end
	
	local Op = Functions[ Format( "%s(%s)", Function, Signature ) ] or BestMatch
	if !Op then self:TraceError( Trace, "No such function %s(%s)", Function, self:BeautifulParams( ... ) ) end
	
	return Op.Compile( self, Trace, ... )
end

function Compiler:Compile_METHOD( Trace, Function, Meta, ... )
	local MetaType = Meta.Return
	
	if !MetaType or MetaType == "" then
		self:TraceError( Trace, "Can not call method on void" )
	elseif MetaType == "..." then
		self:TraceError( Trace, "Invalid use of varargs (...)." )
	end
	
	local Perams, Signature, BestMatch = { ... }, ""
	
	for I = 1, #Perams do
		local Match = Format( "%s(%s:%s...)", Function, MetaType, Signature ) -- Vargs
		if Functions[ Match ] then BestMatch = Functions[ Match ] end
		
		Signature = Signature .. Perams[I].Return -- Static Args
	end
	
	local Op = Functions[ Format( "%s(%s:%s)", Function, MetaType, Signature ) ] or BestMatch
	
	if Op then
		return Op.Compile( self, Trace, Meta, ... )
	end
	
	local Class = API:GetClass( MetaType, true )
	
	if Class and Class.DownCast then
		Meta.TrueReturn = Meta.TrueReturn or MetaType
		Meta.Return = Class.DownCast
		Op = self:Compile_METHOD( Trace, Function, Meta, ... )
	end
	
	if !Op then
		self:TraceError( Trace, "No such method %s:%s(%s)", Meta.TrueReturn or Meta.Return, Function, self:BeautifulParams( ... ) )
	end
	
	return Op
end

/*==============================================================================================
	Section: Tables
==============================================================================================*/
function Compiler:Compile_TABLE( Trace, Values, Keys, Count )
	if Count == 0 then
		return self:Instruction( Trace, LEMON_PERF_ABNORMAL, "t", "Externals.Table( )" )
	end--else
		local ID = self:NextLocal( )
		local Statements = { }
		
		for I = 1, Count do
			
			local Value, Key = Values[I], Keys[I]
			
			if Key then
				local Op = self:GetOperator( "[]=", "t", Key.Return, Value.Return )
				
				if !Op then
					self:TraceError( Trace, "No such operator ({[%s] = %s}).", NType( Key.Return ), NType( Value.Return ) )
				end
				
				Statements[I] = Op.Compile( self, Trace, ID, Key, Value )
			else
				local Op = self:GetOperator( "[]+", "t", Value.Return )
				
				if !Op then
					self:TraceError( Trace, "No such operator ({%s}).", NType( Value.Return ) )
				end
				
				Statements[I] = Op.Compile( self, Trace, ID, Value )
			end
			
		end
		local First = "local " .. ID .. " = Externals.Table( )"
		
		local Inst = self:Compile_SEQUENCE( Trace, Statements )
		
		Inst.Prepare = First .. "\n" .. Inst.Prepare
		Inst.Perf = LEMON_PERF_ABNORMAL
		Inst.Return = "t"
		Inst.Inline = ID
		
		return Inst
	--end
end

function Compiler:Compile_GET( Trace, Variable, Index, Type )
	local Op = self:GetOperator( "[]", Variable.Return, Index.Return, Type )
	
	if !Op and Type then
		self:TraceError( Trace, "No such operator (%s[%s, %s]).", NType( Variable.Return ), NType( Index.Return ), NType( Type ) )
	elseif !Op then
		self:TraceError( Trace, "No such operator (%s[%s]).", NType( Variable.Return ), NType( Index.Return ) )
	end
	
	return Op.Compile( self, Trace, Variable, Index )
end

function Compiler:Compile_SET( Trace, Variable, Index, Value, Type )
	if Type and Value.Return ~= Type then
		Value = self:Compile_CAST( Trace, NType( Type ), Value )
	end -- Auto Cast!
	
	local Op = self:GetOperator( "[]=", Variable.Return, Index.Return, Value.Return )
	
	if !Op then
		self:TraceError( Trace, "No such operator (%s[%s] = %s).", NType( Variable.Return ), NType( Index.Return ), NType( Value.Return ) )
	end
	
	return Op.Compile( self, Trace, Variable, Index, Value )
end

/*==============================================================================================
	Section: Try Catch
==============================================================================================*/
function Compiler:Compile_TRY( Trace, Block, Catch, Final )
	local ID = self:NextLocal( )
	
	local Lua = [[
		local ]] .. ID .. [[ = function( )
			]].. Block.Prepare .. [[
		end
		
		local Ok, Exit = pcall( ]] .. ID .. [[ )
		if !Ok and Exit == "Exception" then
			local ExceptionClass = Context.Exception.Class
			]] .. Catch.Prepare .. [[ 
		elseif !Ok then
			error( Exit, 0 )
		end
		
		]] .. ( Final and Final.Prepare or "" )
		
	return self:Instruction( Trace, LEMON_PERF_ABNORMAL, "", "", Lua )	
end

function Compiler:Compile_CATCH( Trace, Ref, Exceptions, Block, Catch )
	local Op = self:GetOperator( "=" )
	
	local Lua = !Exections and "true" or string.Implode( " == ExceptionClass or " ) .. " == ExceptionClass "
	Lua = "if ( " .. Lua .. [[ ) then
		-- Assign
			]] .. Op.Compile( self, Trace, Ref, "Context.Exception" ).Prepare .. [[ 
			
		-- Block
			]] .. Block.Prepare .. [[ 
			
			Context.Exception = nil
			
		]] .. ( Catch and ( "else" .. Catch.Prepare ) or "end" )
	
	return self:Instruction( Trace, LEMON_PERF_NORMAL, "", "", Lua )	
end

/*==============================================================================================
	Section: Events Statments
==============================================================================================*/

function Compiler:Compile_EVENT( Trace, EventName, Perams, HasVarg, Block, Exit )
	local Event = LEMON.API.Events[ EventName ]
	
	if !Event then self:TraceError( Trace, "Unkown event %s", EventName ) end
	
	local EParams = Event.Params
	
	local EventParams, EventPrepare, Start = { }, { }, 1
	
	for I = 1, #Perams do
		Start = I + 1
		
		local Param = Perams[I]
		if !EParams[I] or EParams[I] ~= Param[2] then
			self:TraceError( Trace, "Event %s has no such parameter (#%s - %s )", EventName, I, NType( Param[2] ) )
		end
		
		local Var = "Peram_" .. I
		local Op = self:GetOperator( "=", Param[2] ) or self:GetOperator( "=" )
		local Assign = Op.Compile( self, Trace, Param[3], Var )
		
		EventParams[I] = Var
		EventPrepare[I] = Assign.Prepare
	end
	
	local Lua = Block.Prepare
	
	if HasVarg then
		local VArgs = { }
		
		for I = Start, #EParams do
			local Var = "Peram_" .. I
			
			EventParams[I] = Var
			VArgs[ #VArgs + 1 ] = "{ " .. Var .. ", \"" .. EParams[I] .. "\" }"
		end
		
		Lua = [[local EventCall = function( ... )
			
				]] .. Lua .. [[
			end
			
			return EventCall( ]] .. string.Implode( ",", VArgs ) .. [[ )
		]]
	end
	
	if Exit and Exit == "Return" then
		local Return = self:GetFlag( "ReturnedType", "" )
		if Return == "" then
			-- DO nothing!
		elseif Event.Return == "" then
			self:TraceError( Trace, "Event %s does not accept a return value", EventName )
		elseif Return != Event.Return then
			self:TraceError( Trace, "Event %s must return %2", EventName, NType( Return ) )
		end
	end
	
	Lua = "Context.Event_" .. EventName .. " = function( " .. string.Implode( ",", EventParams ) .. [[ )
		]] .. self:PushEnviroment( ) .. [[
				
		Context:PushPerf( ]] .. self:CompileTrace( Trace ) .. "," .. Event.Perf .. [[ )
		
		]] .. string.Implode( "\n", EventPrepare ) .. [[
		
		]] .. Lua .. [[
		
	end]]
	
	return self:Instruction( Trace, 0, "", "", Lua )
end

/*==============================================================================================
	Section: Include
==============================================================================================*/
function Compiler:DoScript( Code, File )
	self:NextChar( )
	
	self.Flags = { }
	
	self.Tokens = { self:GetNextToken( ), self:GetNextToken( ) }
	
	self:NextToken( )
	
	return self:GetStatements( { 0, 0, Location = File or "Uknown" } ).Prepare
end

function Compiler:Compile_INCLUDE( Trace, Path, Scoped )
	local LkPath = Path .. "_" .. tostring( Scoped or false )
	
	if !self.FilesLK[ LkPath ] then
		
		if CLIENT then
			self.Files[ Path ] = LEMON.Editor.Instance:GetFileCode( Path )
		end
		
		local Code = self.Files[ Path ]
		
		if !Code then
			self:TraceError( Trace, "Could not include file '%s'", Path )
		end
		
	-- First: Register this!
		
		
		local ID = self:NextLocal( )
		
		self.FilesLK[ LkPath ] = ID
	
	-- Second: Back up current state!
		local Pos = self.Pos
		self.Pos = 0
		
		local TokenPos = self.TokenPos
		self.TokenPos = -1
		
		local Char, ReadData = self.Char, self.ReadData
		self.Char, self.ReadData = "", ""
		
		local ReadChar, ReadLine = self.ReadChar, self.ReadLine
		self.ReadChar, self.ReadLine = 1, 1
		
		local Buffer, Len = self.Buffer, self.Len
		self.Buffer, self.Len = Code, #Code
		
		local Flags = self.Flags
		self.Flags = { }
		
		local Tokens = self.Tokens
		
	-- Third: Compile the new code
	
		if Scoped then self:PushScope( ) end
		
		local Ok, Lua = pcall( self.DoScript, self, Code, Path )
		
		if Scoped then self:PopScope( ) end
		
		if !Ok then
			self:Error( 0, Lua .. ", " .. Path )
		end -- Error from file!
		
		self:Prepare( ID, "function Context.Include" .. ID .. [[( )
			]] .. Lua .. [[
		end]] ) -- Create the include function.
		
	-- Fourth: Return to previous state.
		
		self.Pos = Pos
		
		self.Tokens = Tokens
		
		self.TokenPos = TokenPos
		
		self.Char, self.ReadData = Char, ReadData
		
		self.ReadChar, self.ReadLine = ReadChar, ReadLine
		
		self.Buffer, self.Len = Buffer, Len
		
		self.Flags = self.Flags
		
		self:PrevToken( )
		self:NextToken( )
	-- Now just call it =D
	
		return self:Instruction( Trace, LEMON_PERF_ABNORMAL, "", "", "Context.Include" .. ID .. "( )" )
	else
	
		return self:Instruction( Trace, LEMON_PERF_ABNORMAL, "", "", "Context.Include" .. self.FilesLK[ LkPath ] .. "( )" )
	end
end

/*==============================================================================================
	Section: Cystom Syntax Functions
==============================================================================================*/
function Compiler:Compile_PRINT( Trace, Values, Count )
	local Perf = LEMON_PERF_NORMAL
	local Inline, Lua = { }, { }
	
	for I = 1, Count do
		local Instr = Values[ I ]
		Perf = Perf + ( Instr.Perf or 0 )
		
		Lua[I] = ( Instr.Prepare or "" ) .. "\nlocal __" .. I .. " = " .. Instr.Inline
		
		if Instr.Return == "?" then
			Inline[I] = "tostring(__" .. I .. "[1])"
		else
			Inline[I] = "tostring(__" .. I .. ")"
		end
	end
	
	return self:Instruction( Trace, 0, "", "", [[do
		Context:PushPerf( ]] .. self:CompileTrace( Trace ) .. ", " .. Perf .. [[ )
		
		]] .. string.Implode( "\n", Lua ) .. [[
		
		Context.Player:PrintMessage( 3, string.Left( ]] .. string.Implode( " .. \" \" .. ", Inline ) .. [[, 249 ) )
	end]] )
end
