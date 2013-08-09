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
function Component:CreateContext( Context )
	Context.Data.HTTP = { }
end

timer.Create( "LemonGate.Http", 0.1, 0, function( )
	for _, Gate in pairs( API:GetRunning( ) ) do
		if Gate:IsRunning( ) then
			for Key, Request in pairs( Gate.Context.Data.HTTP ) do
				
				if ( Request.Done and Status ) then
					
					if( Request.Success )then
						Status = Gate:Pcall( "http sucess callback", Request.Func, { Request.Body, "s" } )
						Request.Done = false
					else
						Status = Gate:Pcall( "http fail callback", Request.FailFunc )
						Request.Done = false
					end
					
					if !Status then
						break
					end
				end
			end; Gate:Update( )
		end
	end
end )