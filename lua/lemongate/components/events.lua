/*==============================================================================================
	Expression Advanced: Component -> Number.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" )

/*==============================================================================================
	Section: Entity events.
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )
Core:AddEvent( "final", "", "" )

Core:AddEvent( "trigger", "s", "" )

/*==============================================================================================
	Section: Tick and Think Event
==============================================================================================*/
Core:SetPerf( LEMON_PERF_ABNORMAL )
Core:AddEvent( "think", "", "" )

hook.Add( "Think", "LemonGate", function( )
	API:CallEvent( "think" )
end )

Core:SetPerf( LEMON_PERF_EXPENSIVE )
Core:AddEvent( "tick", "", "" )

hook.Add( "Tick", "LemonGate", function( )
	API:CallEvent( "tick" )
end )

/*==============================================================================================
	Section: Player Join/Leave Event
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddEvent( "playerJoin", "e", "" )

hook.Add("PlayerInitialSpawn", "LemonGate", function( Player )
	API:CallEvent( "playerJoin", Player )
end)

Core:AddEvent( "playerQuit", "e", "" )

hook.Add("PlayerDisconnected", "LemonGate", function( Player )
	API:CallEvent( "playerQuit", Player )
end)

/*==============================================================================================
	Section: Player Chat event.
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddEvent( "playerChat", "e,s", "s" )

hook.Add("PlayerSay", "LemonGate", function( Player, Text )
	local Result, Gate = API:CallEvent( "playerChat", Player, Text )
	if Result and Gate.Player == Player then
		return Result
	end
end)

Core:AddEvent( "playerSpeak", "e", "b" )

hook.Add("PlayerCanHearPlayersVoice", "LemonGate", function( Player, Speaker )
	for _, Gate in pairs( API:GetEntitys( ) ) do
		if Gate.Player == Player then
			local Result, Gate = API:CallEvent( "playerSpeak", Speaker )
			if Result then return Result end
		end
	end
end)



/*==============================================================================================
	Section: Player Input event.
	Note: Taken from wired keyboard.
==============================================================================================*/
include( "entities/gmod_wire_keyboard/remap.lua" )

if Wire_Keyboard_Remap then
	Core:SetPerf( LEMON_PERF_NORMAL )
	
	Core:AddEvent( "keypress", "n", "" )
	Core:AddEvent( "keyrelease", "n", "" )
	
	local Keys = { }
	
	local function GetKey( Ply, Num, Pressed )
		local Tbl = Keys[ Ply ]
		
		if !Tbl then Tbl = { }; Keys[ Ply ] = Tbl end
		
		Tbl[Num] = Pressed
		
		local Layout = Wire_Keyboard_Remap[ Ply:GetInfo( "wire_keyboard_layout" ) ]
		
		if Num > 0 and Layout then
			local Key

			for K, V in pairs( Tbl ) do
				if V and Layout[K] then
					Key = Layout[K][Num]
				end
			end

			if !Key then
				Key = Layout.normal[Num]
				if !Key then return end
			end
			
			if type(Key) == "string" then
				Key = string.byte(Key)
				if !Key then return end
			end
			
			return Key
		end
	end
	
	hook.Add( "PlayerButtonDown", "LemonGate", function( Ply, Num, Button )
		local Key = GetKey( Ply, Num, true )
		
		if Key then 
			for _, Gate in pairs( API:GetEntitys( ) ) do
				if Gate.Player == Ply then
					API:CallEvent( "keypress", Key )
				end
			end
		end
	end )
	
	hook.Add( "PlayerButtonUp", "LemonGate", function( Ply, Num, Button )
		local Key = GetKey( Ply, Num, nil )
		
		if Key then 
			for _, Gate in pairs( API:GetEntitys( ) ) do
				if Gate.Player == Ply then
					API:CallEvent( "keyrelease", Key )
				end
			end
		end
	end )
end