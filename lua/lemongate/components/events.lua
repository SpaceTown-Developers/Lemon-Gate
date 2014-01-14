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
Core:AddEvent( "shutdown", "", "" )

Core:AddEvent( "trigger", "s", "" )

Core:AddEvent( "use", "e", "" )

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

Core:AddEvent( "playerSpawn", "e", "" )

hook.Add("PlayerSpawn", "LemonGate", function( Player )
	API:CallEvent( "playerSpawn", Player )
end)

/*==============================================================================================
	Section: Player Chat event.
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddEvent( "playerChat", "e,s", "s" )

hook.Add("PlayerSay", "LemonGate", function( Player, Text )
	
	for _, Gate in pairs( API:GetEntitys( ) ) do
		local Result = Gate:CallEvent( "playerChat", Player, Text )
		
		if Result and Player == Gate.Player then
			return Result
		end
	end
end)

Core:AddEvent( "playerSpeak", "e", "b" )

hook.Add("PlayerCanHearPlayersVoice", "LemonGate", function( Player, Speaker )
	for _, Gate in pairs( API:GetEntitys(  ) ) do
		if Player == Gate.Player then
			local Result, Gate = Gate:CallEvent( "playerSpeak", Speaker )
			if Result then return Result end
		end
	end
end)

/*==============================================================================================
	Section: Dupe Pasted.
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddEvent( "dupeFinished", "", "" )

hook.Add( "AdvDupe_FinishPasting", "LemonGate", function( Data, Current )
	for _, Gate in pairs( Data[Current].CreatedEntities ) do
		if IsValid( Gate ) and Gate.IsLemonGate and Gate:IsRunning( ) then
			Gate:CallEvent( "dupeFinished" )
		end
	end
end )

/*==============================================================================================
	Section: Kills.
==============================================================================================*/
Core:AddEvent( "onKill", "e,e,e", "" )

hook.Add("PlayerDeath", "LemonGate", function( Player, Inflictor, Attacker )
	Attacker = Attacker or Entity( 0 )
	Inflictor = Inflictor or Attacker
	API:CallEvent( "onKill", Player, Attacker, Inflictor )
end)

hook.Add("OnNPCKilled", "LemonGate", function( Player, Attacker, Inflictor )
	Attacker = Attacker or Entity( 0 )
	Inflictor = Inflictor or Attacker
	API:CallEvent( "onKill", Player, Attacker, Inflictor )
end)

/*==============================================================================================
	Section: Damage.
==============================================================================================*/
Core:AddEvent( "onDamage", "e,e,n,v", "" )

hook.Add("EntityTakeDamage", "LemonGate", function( Ent, Damage )
	local Attacker = Damage:GetAttacker( ) or Entity( 0 )
	local Num = Damage:GetDamage( ) or 0
	local Pos = Vector3( Damage:GetDamagePosition( ) or Vector( 0, 0, 0 ) )
	API:CallEvent( "onDamage", Ent, Attacker, Num, Pos )
end)

Core:AddEvent( "propBreak", "e,e", "" )

hook.Add("PropBreak", "LemonGate", function( Attacker, Ent )
	local Attacker = Attacker or Entity( 0 )
	API:CallEvent( "propBreak", Ent, Attacker )
end)

/*==============================================================================================
	Section: Player Input event.
	Note: Taken from wired keyboard.
==============================================================================================*/
include( "entities/gmod_wire_keyboard/remap.lua" )

if Wire_Keyboard_Remap then
	
	local Keys = { }
	local PlayerKeys = { }
	
	local function GetKey( Ply, Num, Pressed )
		local Tbl = Keys[ Ply ]
		
		if !Tbl then Tbl = { }; Keys[ Ply ] = Tbl end
		
		local State = Tbl[Num]
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
			
			return Key, State
		end
	end
	
	hook.Add( "PlayerButtonDown", "LemonGate", function( Ply, Num, Button )
		local Key, State = GetKey( Ply, Num, true )
		
		if Key and !State then 
			for _, Gate in pairs( API:GetEntitys( ) ) do
				local Players = PlayerKeys[ Gate ]
				if (Players and Players[ Ply ]) or Ply == Gate.Player then
					Gate:CallEvent( "keypress", Key, Ply )
				end
			end
		end
	end )
	
	hook.Add( "PlayerButtonUp", "LemonGate", function( Ply, Num, Button )
		local Key, State = GetKey( Ply, Num, nil )
		
		if Key and State then 
			for _, Gate in pairs( API:GetEntitys( ) ) do
				local Players = PlayerKeys[ Gate ]
				if (Players and Players[ Ply ]) or Ply == Gate.Player then
					Gate:CallEvent( "keyrelease", Key, Ply )
				end
			end
		end
	end )
	
	Core:SetPerf( LEMON_PERF_NORMAL )
	
	Core:AddEvent( "keypress", "n,e", "" )
	Core:AddEvent( "keyrelease", "n,e", "" )
	
	Core:AddExternal( "AddToKeys", function( Context, Player, Bool )
		local Value = false
		
		if Player and Player:IsValid( ) and Player:IsPlayer( ) then
			local Players = PlayerKeys[ Context.Entity ] or { }
			PlayerKeys[ Context.Entity ] = Players
			
			if Bool then
				Value = ( Player == Context.Player ) or ( Player:GetInfoNum( 'lemon_share_keys', 0 ) >= 1 )
			end
			
			Players[ Player ] = Value
		end
		
		return Value or false
	end )

	Core:SetPerf( LEMON_PERF_NORMAL )

	Core:AddFunction( "requestKeys", "e:b", "b", "%AddToKeys(%context, value %1, value %2)" )
	
end