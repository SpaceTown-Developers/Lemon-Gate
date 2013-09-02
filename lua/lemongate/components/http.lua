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

$http.Fetch( value %1,
	function( Body )
		if %context.Entity:Pcall( "http success callback", value %2, { Body, "s" } ) then
			%context.Entity:Update( )
		end
	end, function( )
		if %context.Entity:Pcall( "http fail callback", value %3 ) then
			%context.Entity:Update( )
		end
	end
)
]], "" )

Component:AddFunction( "httpPostRequest", "s,t,f,f", "", [[
%prepare

$http.Post( value %1, value %2.Data,
	function( Body )
		if %context.Entity:Pcall( "http success callback", value %3, { Body, "s" } ) then
			%context.Entity:Update( )
		end
	end, function( )
		if %context.Entity:Pcall( "http fail callback", value %4 ) then
			%context.Entity:Update( )
		end
	end
)
]], "" )

/*==============================================================================================
	Section: API Hooks
==============================================================================================*/
-- function Component:CreateContext( Context )
	-- Context.Data.HTTP = { }
-- end

-- timer.Create( "LemonGate.Http", 0.1, 0, function( )
	-- for _, Gate in pairs( API:GetEntitys( ) ) do
		-- if Gate:IsRunning( ) then
			-- local Requests = Gate.Context.Data.HTTP
			-- for Key, Request in pairs( Requests ) do
			
				-- Msg( "Testing Request For: ", Key )
				
				-- if ( Request.Done and Status ) then
					
					-- if( Request.Success )then
						-- Status = Gate:Pcall( "http success callback", Request.Func, { Request.Body, "s" } )
						-- Requests[ Key ] = nil
					-- else
						-- Status = Gate:Pcall( "http fail callback", Request.FailFunc )
						-- Requests[ Key ] = nil
					-- end
					
					-- if !Status then
						-- break
					-- end
				-- end
			-- end; Gate:Update( )
		-- end
	-- end
-- end )