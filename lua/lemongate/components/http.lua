/*==============================================================================================
	Expression Advanced: Component -> HTTP.
	Creditors: JerwuQu 
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Component = API:NewComponent( "http", true )

/*==============================================================================================
	Section: Functions
==============================================================================================*/
Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction( "httpRequest", "s,f,f", "", [[
%prepare

local %C = #%data.HTTP + 1

%data.HTTP[%C] = {
	Done = false,
	Success = false,
	Body = nil,
	Func = value %2,
	FailFunc = value %3
}

$http.Fetch( value %1, function( Data, Len, Head, Ret )
	if ( %data.HTTP[%C] ) then
		%data.HTTP[%C].Body=Data
		%data.HTTP[%C].Done=true
		%data.HTTP[%C].Success=true
	end
end, function( Ret )
	if ( %data.HTTP[%C] ) then
		%data.HTTP[%C].Done = true
	end
end )
]], "" )

Component:AddFunction( "httpPostRequest", "s,t,f,f", "", [[
%prepare

local %C = #%data.HTTP + 1

%data.HTTP[%C] = {
	Done = false,
	Success = false,
	Body = nil,
	Func = value %3,
	FailFunc = value %4
}

$http.Post( value %1, value %2.Data, function( Data, Len, Head, Ret )
	if( %data.HTTP[%C] )then
		%data.HTTP[%C].Body=Data
		%data.HTTP[%C].Done=true
		%data.HTTP[%C].Success=true
	end
end, function( Ret )
	if ( %data.HTTP[%C] ) then
		%data.HTTP[%C].Done = true
	end
end )
]], "" )

/*==============================================================================================
	Section: API Hooks
==============================================================================================*/
function Component:BuildContext( Gate )
	Gate.Context.Data.HTTP = { }
end

function Component:GateThink( Gate )
	local Context = Gate.Context
	if Gate:IsRunning( ) then
		for Key, Request in pairs( Gate.Context.Data.HTTP ) do
			if ( Request.Done ) then
				
				local Ok, Status
				
				if( Request.Success )then
					Ok, Status = pcall( Request.Func, { Request.Body, "s" } )
					Request.Done = false
				else
					Ok, Status = pcall( Request.FailFunc )
					Request.Done = false
				end
				
				if Ok or Status == "Exit" then
					Gate:Update( )
				elseif Status == "Script" then
					local Cont = Gate.Context
					return Gate:ScriptError( Cont.ScriptTrace, Cont.ScriptError )
				elseif Status == "Exception" then
					local Excpt = Gate.Context.Exception
					return Gate:ScriptError( Excpt.Trace, "uncatched exception '" .. Excpt.Type .. "' in http " .. (Request.Success and "success" or "fail") .. " callback." )
				elseif Status == "Break" or Status == "Continue" then
					return Gate:ScriptError( nil, "unexpected use of " .. Status .. " in http " .. (Request.Success and "success" or "fail") .. " callback." )
				else
					return Gate:LuaError( Status )
				end
			end
		end
	end
end