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
		CPU_Tick = 0,
		CPU_PrevTick = 0,
		CPU_Average = 0,

		Quota_Tick = 0,
		Quota_Soft = 0,
		Quota_PrevTick = 0,
		Quota_Average = 0,

		Entity = Entity,
		Player = Player or Entity.Player,
		Data = { },
		Memory = { },
		Delta = { },
		Click = { },
		Trigger = { },
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

local FakeTrace = { 0, 0 }

function Context:UpdateQuota( Trace, Ammount )
	self.Quota_Tick = self.Quota_Tick + Ammount

	if self.Quota_Tick > LEMON.Tick_Quota:GetInt( ) then
		self.Entity:SetStatus( 2 ) -- Set on fire :D
		self:Error( Trace or FakeTrace, "Tick quota exceeded." )
	end
end

function Context:PreExecute( )
	self.CPU_TimeMark = SysTime( )
end

function Context:PostExecute( )
	self.CPU_Tick = self.CPU_Tick + ( SysTime( ) - self.CPU_TimeMark )
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
