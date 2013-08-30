/*==============================================================================================
	Expression Advanced: Context Base.
	Creditors: Rusketh
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

/**********************************************************************************************/

local PerfMax = CreateConVar( "lemongate_perf", "25000", {FCVAR_REPLICATED} )
LEMON.PerfMax = PerfMax

/**********************************************************************************************/

local Context = { }
LEMON.Context = Context
Context.__index = Context

/*==============================================================================================
	New Context
==============================================================================================*/

function LEMON:BuildContext( Entity, Player )
	local New = {
		Time = 0,
		CPUTime = 0,
		Perf = 0,
		MaxPerf = PerfMax:GetInt( ),
		Entity = Entity,
		Player = Player or Entity.Player,
		Data = { },
		Memory = { },
		Delta = { },
		Click = { },
	}
	
	Entity.Context = New
	
	API:CallHook( "CreateContext", New )
	
	return setmetatable( New, Context )
end

/*==============================================================================================
	Base Functions
==============================================================================================*/

function Context:Throw( Trace, Type, Message, Table )
	self.Exception = { Type = Type, Trace = Trace, Message = Message, Table = Table }
	error( "Exception", 0 )
end

function Context:Error( Trace, Message )
	self.ScriptError = Message
	self.ScriptTrace = Trace
	error( "Script", 0 )
end

function Context:PushPerf( Trace, Ammount )
	self.Perf = self.Perf + Ammount
	if self.Perf > self.MaxPerf then
		self:Error( Trace, "Maximum operations count exceeded." )
	end
end

local Empty = table.Empty
function Context:Update( )
	Empty( self.Click )
	API:CallHook( "UpdateContext", self )
end

/*==============================================================================================
	Enviroment Pushing
==============================================================================================*/
local setmetatable, rawset, rawget = setmetatable, rawset, rawget

function Context:Enviroment( _Memory, _Delta, _Click, Cells )
	local Memory = {
		__index = function( tbl, key )
			if Cells[key] then
				return rawget( tbl, key)
			else
				return _Memory[key]
			end
		end,
		
		__newindex = function( tbl, key, value )
			if Cells[key] then
				rawset( tbl, key, value)
			else
				_Memory[key] = value
			end
		end
	}
	
	local Delta = {
		__index = function( tbl, key )
			if Cells[key] then
				return rawget( tbl, key)
			else
				return _Delta[key]
			end
		end,
		
		__newindex = function( tbl, key, value )
			if Cells[key] then
				rawset( tbl, key, value)
			else
				_Delta[key] = value
			end
		end
	}
	
	local Click = {
		__index = function( tbl, key )
			if Cells[key] then
				return rawget( tbl, key)
			else
				return _Click[key]
			end
		end,
		
		__newindex = function( tbl, key, value )
			if Cells[key] then
				rawset( tbl, key, value)
			else
				_Click[key] = value
			end
		end
	}
	
	return setmetatable(Memory, Memory), setmetatable(Delta, Delta), setmetatable(Click, Click)
end


/*==============================================================================================
	External Components
==============================================================================================*/

API:CallHook( "GenerateContext", Context )
