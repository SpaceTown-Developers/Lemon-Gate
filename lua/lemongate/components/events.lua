/*==============================================================================================
	Expression Advanced: Component -> Number.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" )

/*==============================================================================================
	Section: Entity events.
==============================================================================================*/
Core:SetPerf( LEMON_PERF_ABNORMAL )
Core:AddEvent("think", "", "" )

Core:SetPerf( LEMON_PERF_NORMAL )
Core:AddEvent("final", "", "" )
-- E_A:RegisterEvent("trigger", "s", "", "" )

/*==============================================================================================
	Section: Tick Event
==============================================================================================*/
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


/*==============================================================================================
	Section: Player Input event.
	Note: Taken from wired keyboard.
==============================================================================================*/
--[[ TODO: Convert this.

include("entities/gmod_wire_keyboard/remap.lua") -- ClientSide for WM Serverside for us!
if !Wire_Keyboard_Remap then return MsgN("Wire Keyboard missing!") end
local Wire_Keyboard_Remap = Wire_Keyboard_Remap

E_A:SetCost( EA_COST_NORMAL )
E_A:RegisterEvent( "keypress", "n" )
E_A:RegisterEvent( "keyrelease", "n" )


local function HookPlayer( Player )
	for Emu = 1, 130 do
		local EventKeys = { }
		numpad.OnDown( Player, Emu, "Lemon.KeyEvent", Emu, true, EventKeys )
		numpad.OnUp  ( Player, Emu, "Lemon.KeyEvent", Emu, false, EventKeys )
	end
end

local KeyBoardType = CreateConVar( "lemon_keyboard_layout", "British" )

numpad.Register( "Lemon.KeyEvent", function( Player, Emu, Pressed, EventKeys )
	if (EventKeys[Emu] and Pressed) or (!EventKeys[Emu] and !Pressed) then
		return
	end

	EventKeys[Emu] = Pressed and true or nil

	local Layout = Wire_Keyboard_Remap[ KeyBoardType:GetString() ] 
	if !Layout or !Emu or Emu == 0 then return end
	local Key

	for K, V in pairs( EventKeys ) do
		if V and Layout[K] then
			Key = Layout[K][Emu]
		end
	end

	if !Key then
		Key = Layout.normal[Emu]
		if !Key then return end
	end

	if type(Key) == "string" then
		Key = string.byte(Key)
		if !Key then return end
	end

	for _, Gate in pairs( API.GetGates( ) ) do
		if Gate:IsValid( ) and Gate.Player == Player then
			if Pressed then
				Gate:CallEvent( "keypress", E_A.ValueToOp(Key, "n"))
			else
				Gate:CallEvent( "keyrelease", E_A.ValueToOp(Key, "n"))
			end
		end
	end
end)

for _, Player in pairs( player.GetAll() ) do HookPlayer( Player ) end
hook.Add( "PlayerInitialSpawn", "Lemon.KeyEvent", HookPlayer)

]] 