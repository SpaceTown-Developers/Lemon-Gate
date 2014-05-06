ENT.Type            = "anim"
ENT.Base            = "base_wire_entity"

ENT.PrintName       = "Expression Advanced"
ENT.Author          = "Rusketh"
ENT.Contact         = "WM/FacePunch"
ENT.Purpose         = ""
ENT.Instructions    = ""

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.IsLemonGate = true 
ENT.AutomaticFrameAdvance  = true

if CLIENT then game.AddParticles( "particles/fire_01.pcf" ) end
PrecacheParticleSystem( "fire_verysmall_01" )

/*==========================================================================
	Section: Context Menu
==========================================================================*/
local LEMON = LEMON
local Util = LEMON.API.Util

properties.Add( "lemongate", {
	MenuLabel = "LemonGate",
	Order = 999,
	MenuIcon  = "fugue/gear.png",
	
	Filter = function( self, Entity, Player )
		if !IsValid( Entity ) or !Entity.IsLemonGate then
			return false -- Not valid Lemongate.
		end
		
		local Owner = Entity:GetOwner( )
		if ( !IsValid( Owner ) or Owner != Player or !Util.IsFriend( Owner, Player ) ) and !Player:IsAdmin( ) then
			return false -- Not owner, friend or Admin.
		end -- PP should use the one below anyway, so do we really need this check?
		
		if !gamemode.Call( "CanProperty", Player, "lemongate", Entity ) then
			return false -- Somthing denied access!
		end

		return true
	end,

	Action = function( self, Entity )
		-- Do nothing here.
	end,
	
	MenuOpen = function( self, Option, Entity, Trace )
		local SubMenu = Option:AddSubMenu( )
			
		SubMenu:AddOption( "Reload", function( )
			self:MsgStart( )
				net.WriteEntity( Entity )
				net.WriteString( "restart" )
			self:MsgEnd( )
		end )
		
		SubMenu:AddOption( "Shutdown", function( )
			self:MsgStart( )
				net.WriteEntity( Entity )
				net.WriteString( "shutdown" )
			self:MsgEnd( )
		end )
		
	end,
	
	Receive = function( self, Length, Player )
		local Entity = net.ReadEntity( )
		local Action = net.ReadString( )
		
		if self:Filter( Entity, Player ) then
			
			if Action == "restart" then
				Entity:Reset( )
			elseif Action == "shutdown" then
				Entity:ShutDown( )
				Entity.Context = nil
				Entity:SetNWInt( "GateTime", 0 )
				Entity:SetNWFloat( "GatePerf", 0 )
			end
		end
	end 
} )

/*==========================================================================
	Section: Status
==========================================================================*/

function ENT:GetStatus(  )
	return self:GetNWInt( "status", 0 )
end