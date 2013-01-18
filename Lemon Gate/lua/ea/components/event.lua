/*==============================================================================================
	Expression Advanced: Event Manager.
	Purpose: Events make E-A Tick (literary).
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local API = E_A.API

local pairs = pairs
local Entity = Entity

/*==============================================================================================
	Section: Event Function.
	Purpose: Functions that Create and Remove events.
	Creditors: Rusketh
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)
E_A:RegisterOperator("event", "", "", function(self, Event, Arguments, Statements)
	-- Purpose: Builds a Function.
	
	self.Events[Event] = {Arguments, Statements}
end)

/*==============================================================================================
	Section: Entity events.
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)
E_A:RegisterEvent("think")

E_A:SetCost(EA_COST_NORMAL)
E_A:RegisterEvent("final")
E_A:RegisterEvent("trigger", "s")

/*==============================================================================================
	Section: Tick Event
==============================================================================================*/
E_A:SetCost(EA_COST_EXPENSIVE)
E_A:RegisterEvent("tick")

hook.Add("Tick", "LemonGate", function()
	for _, Entity in pairs( API.GetGates() ) do
		if Entity:IsValid() then
			Entity:CallEvent("tick")
		end
	end
end)

/*==============================================================================================
	Section: Player Join/Leave Event
==============================================================================================*/
E_A:RegisterEvent("playerJoin","e")

hook.Add("PlayerInitialSpawn", "LemonGate", function(Player)
	for _, Entity in pairs( API.GetGates() ) do
		if Entity:IsValid() then
			Entity:CallEvent("playerJoin", E_A.ValueToOp(Player, "e"))
		end
	end
end)

E_A:RegisterEvent("playerQuit","e")

hook.Add("PlayerDisconnected", "LemonGate", function(Player)
	for _, Entity in pairs( API.GetGates() ) do
		if Entity:IsValid() then
			Entity:CallEvent("playerQuit", E_A.ValueToOp(Player, "e"))
		end
	end
end)

/*==============================================================================================
	Section: Player Chat event.
==============================================================================================*/
E_A:RegisterEvent("playerChat","es","s")

hook.Add("PlayerSay", "LemonGate", function(Player, Text)
	for _, Entity in pairs( API.GetGates() ) do
		if Entity:IsValid() then
			local Result = Entity:CallEvent("playerChat", E_A.ValueToOp(Player, "e"), E_A.ValueToOp(Text, "s"))
			if Result and Player == Entity.Player then return Result end
		end
	end
end)

/*==============================================================================================
	Section: Player Input event.
	Note: Taken from wired keyboard.
==============================================================================================*/
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