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
	
	local RawCommands = { "quit", "lua_run_cl", "retry", "rcon" }
	
	if file.Exists( "lemom_con_bl.txt", "DATA" ) then
		RawCommands = string.Explode( ";", file.Read( "lemom_con_bl.txt", "DATA" ) or "" )
	end
	
	local BlockedList = { }
	
	for _, Command in pairs( RawCommands ) do
		BlockedList[ Command ] = true
	end
	
	local function Update( )
		RawCommands = { }
		
		for Command, _ in pairs( BlockedList ) do
			RawCommands[#RawCommands + 1] = Command
		end
		
		file.Write( "lemom_con_bl.txt", string.Implode( ";", RawCommands ) )
		
		net.Start( "lemon_blocked_commands" )
			net.WriteTable( BlockedList )
		net.SendToServer( )
	end
	
	concommand.Add( "lemon_console_block", function( Ply, Command, Args )
		local Command = Args[1]
		local Blocked = tobool( tonumber( Args[2] ) )
		
		local Update = false
		
		if Blocked and !BlockedList[ Command ] then
			BlockedList[ Command ] = true
			Update( )
		elseif !Blocked and BlockedList[ Command ] then
			BlockedList[ Command ] = nil
			Update( )
		end
		
		Update( )
	end )
	
	return Update( ) -- Client stuff is done!

else
/*==============================================================================================
	Blocked Chars
==============================================================================================*/
	//local BlockedChars = { "\58", "\32", "\13", "\10", "\84", "\n", "\t", "\r" }

/*==============================================================================================
	Component and API
==============================================================================================*/
	
	util.AddNetworkString( "lemon_blocked_commands" )
	
	local BlockedList = { }
	
	net.Receive( "lemon_blocked_commands", function( Len, Player )
		BlockedList[ Player ] = net.ReadTable( )
	end )
	
	local Component = API:NewComponent( "console", true )
	
	Component:AddExternal( "RunConCmd", function( Player, Command )
		if Player:GetInfoNum( "lemon_console_allow", 0 ) == 1 then
			
			/*for _, Char in pairs( BlockedChars ) do
				if string.find( Command, Char ) then
					return false
				end
			end*/

			local Blocked = BlockedList[Player]

			if Blocked then
				for Cmd in Command:gmatch( "[^;]+" ) do
					if Blocked[ Cmd:match( "[^%s]+" ) ] then
						return false
					end
				end
			end
			
			Player:ConCommand( Command:gsub( "%%", "%%%%" ):gsub( "[^ \t%w%p]", "" ) )

			
			return true
		end
		
		return false
	end )

	Component:AddFunction( "concmd", "s", "b", "%RunConCmd( %context.Player, value %1 )", LEMON_INLINE_ONLY )

	Component:AddFunction( "concmd", "s,s", "b", "%RunConCmd( %context.Player, value %1 .. value %2 )", LEMON_INLINE_ONLY )
end