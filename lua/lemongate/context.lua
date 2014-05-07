/*==============================================================================================
	Expression Advanced: Context Base.
	Creditors: Rusketh
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

/**********************************************************************************************/

local Context = { }
LEMON.Context = Context
Context.__index = Context

/*==============================================================================================
	New Context
==============================================================================================*/

function LEMON:BuildContext( Entity, Player )
	local New = {
		cpu_timemark = 0,
		cpu_tickquota = 0,
		cpu_prevtick = 0,
		cpu_softquota = 0,
		cpu_average = 0,

		Entity = Entity,
		Player = Player or Entity.Player,
		Data = { },
		Memory = { },
		Delta = { },
		Click = { },
		Trigger = { },
	}

	setmetatable( New, Context )
	Entity.Context = New
	
	API:CallHook( "CreateContext", New )
	
	return New
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

local FakeTrace = { 0, 0 }

function Context:UpdateBenchMark( Trace ) -- this checks tick quota
	local stime = SysTime( )
	self.cpu_tickquota = self.cpu_tickquota + ( stime - self.cpu_timemark )
	self.cpu_timemark = stime

	if self.cpu_tickquota * 1000000 > LEMON.Tick_CPU:GetInt() then
		self:Error( Trace or FakeTrace, "Tick quota exceeded." )
	end
end

local Empty = table.Empty

function Context:Update( )
	Empty( self.Trigger )
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
