/*==============================================================================================
	Expression Advanced: Console.
	Creditors: Rusketh
==============================================================================================*/
AddCSLuaFile( )

local LEMON, API = LEMON, LEMON.API

/*==============================================================================================
	Client Side Stuffs!
==============================================================================================*/
if CLIENT then
	CreateClientConVar( "lemon_console_allow", 0, true, true )
	
	if file.Exists( "lemom_cmds.txt", "DATA" ) then
		API.Blocked_Console = util.KeyValuesToTable( file.Read( "lemom_cmds.txt", "DATA" ) or "" )
	else
		API.Blocked_Console = { quit = 1, lua_run_cl = 1, exit = 1, retry = 1, rcon = 1 } -- TODO: Add more!
		file.Write( "lemom_cmds.txt", util.TableToKeyValues( API.Blocked_Console ) )
	end
	
	concommand.Add( "lemon_console_block", function( Ply, Command, Args )
		local Cmd, Flag = Args[1], tobool( Args[2] )
		
		if Cmd and Cmd ~= "" then
			API.Blocked_Console[ string.lower( Cmd ) ] = Flag and 1 or 0
			file.Write( "lemom_cmds.txt", util.TableToKeyValues( API.Blocked_Console ) )
		end
	end,  function( Command, Args )
		if Args[1] then
			local Cmd = string.lower( string.Explode( " ", Args, true )[2] )
			
			if API.Blocked_Console[ Cmd ] then
				return { Command .. " " .. Cmd .. " " .. API.Blocked_Console[ Cmd ] }
			end
		end
	end )
	
	net.Receive( "lemon_console", function( Bytes )
		local Tbl = net.ReadTable( )
		
		for I = 1, #Tbl do
			local Args = string.Explode( " ", Tbl[I], false )
			
			if !tobool( API.Blocked_Console[ string.lower( Args[1] ) ] ) then
				RunConsoleCommand( table.remove( Args, 1 ), string.Implode( " ", Args ) )
			end
		end
	end )
	
	return -- Client stuff is done!
end

/*==============================================================================================
	Component and API
==============================================================================================*/
util.AddNetworkString( "lemon_console" )

local Component = API:NewComponent( "console", true )

function Component:CreateContext( Context )
	Context.Data.Console = { }
end

function Component:UpdateContext( Context )
	if Context.Player:GetInfoNum('lemon_console_allow', 0) == 1 then
		if #Context.Data.Console > 0 then
			net.Start( "lemon_console" )
				net.WriteTable( Context.Data.Console )
			net.Send( Context.Player )
		end
	end
	
	Context.Data.Console = { }
end

/*==============================================================================================
	Functions
==============================================================================================*/
Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction( "concmd", "s", "", [[table.insert( %data.Console, value %1 ]], LEMON_PREPARE_ONLY )

Component:AddFunction( "concmd", "s,s", "", [[table.insert( %data.Console, (value %1 .. " " .. value %2) )]], LEMON_PREPARE_ONLY )
