/*==============================================================================================
	Expression Advanced: Component -> Timers.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Component = API:NewComponent( "timers", true )

local PAUSED = -1
local STOPPED = 0
local RUNNING = 1

/*==============================================================================================
	Section: API Hooks
==============================================================================================*/
function Component:BuildContext( Gate )
	Gate.Context.Data.Timers = { }
end

function Component:GateThink( Gate )
	local Time = CurTime( )
	
	for Key, Timer in pairs( Gate.Context.Data.Timers ) do
		
		if Timer.Status == -1 then
			Timer.Last = Time - Timer.Diff
		
		elseif Timer.Status == 1 and ( Timer.Last + Timer.Delay ) <= Time then
			
			Timer.Last = Time
			Timer.N = Timer.N + 1 

			if Timer.N >= Timer.Repetitions and Timer.Repetitions != 0 then
				Timer.Status = 0
			end

			local Ok, Status = pcall( Timer.Lambda )
			
			if Ok or Status == "Exit" then
				Gate:Update( )
			elseif Status == "Script" then
				local Cont = Gate.Context
				return Gate:ScriptError( Cont.ScriptTrace, Cont.ScriptError )
			elseif Status == "Exception" then
				local Excpt = Gate.Context.Exception
				return Gate:ScriptError( Excpt.Trace, "uncatched exception '" .. Excpt.Type .. "' in timer '" .. Key .. "'." )
			elseif Status == "Break" or Status == "Continue" then
				return Gate:ScriptError( nil, "unexpected use of " .. Status .. " in timer '" .. Key .. "'." )
			else
				return Gate:LuaError( Status )
			end
		end
	end
end

/*==============================================================================================
    General Time
==============================================================================================*/
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction("curTime", "", "n", "$CurTime( )" )

-- TODO: time(s)

/*==============================================================================================
	Section: Timers
==============================================================================================*/
Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction("timerCreate", "s,n,n,f", "", [[
%prepare

%data.Timers[ value %1 ] = {
	N = 0,
	Status = 1,
	Last = $CurTime( ),
	Delay = value %2,
	Repetitions = value %3,
	Lambda = value %4
}]], "" )

Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddFunction("timerAdjust", "s,n,n", "", [[
%prepare

local %Timer = %data.Timers[ value %1 ] 
if %Timer then
	%Timer.Delay = value %2
	%Timer.Repetitions = value %3
end]], "" )

Component:AddFunction("timerRemove", "s", "", "%data.Timers[ value %1 ] = nil", "" )

Component:AddFunction("timerStart", "s", "n", [[
%prepare

local %Timer, %Val = %data.Timers[ value %1 ], 0
if %Timer and %Timer.Status != 1 then
	%Val = 1
	%Timer.N = 0
	%Timer.Status = 1
	%Timer.Last = $CurTime( )
end]], "%Val" )

Component:AddFunction("timerPause", "s", "n", [[
%prepare

local %Timer, %Val = %data.Timers[ value %1 ], 0
if %Timer and %Timer.Status == 1 then
	%Val = 1
	%Timer.Diff = $CurTime( ) - %Timer.Last
	%Timer.Status = -1
end]], "%Val" )

Component:AddFunction("timerUnpause", "s", "n", [[
%prepare

local %Timer, %Val = %data.Timers[ value %1 ], 0
if %Timer and %Timer.Status == -1 then
	%Val = 1
	%Timer.Diff = nil
	%Timer.Status = 1
end]], "%Val" )

Component:AddFunction("timerStop", "s", "n", [[
%prepare

local %Timer, %Val = %data.Timers[ value %1 ], 0
if %Timer and %Timer.Status != 0 then
	%Val = 1
	%Timer.Status = 0
end]], "%Val" )

Component:AddFunction("timerStatus", "s", "n", [[
local %Timer, %Val = %data.Timers[ value %1 ], 0
if %Timer then
	%Val = %Timer.Status or 0
end]],"%Val" )