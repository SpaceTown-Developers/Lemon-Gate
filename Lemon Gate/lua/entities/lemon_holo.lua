/*==============================================================================================
	LemonGate: Orange Holograms.
	Purpose: Makes holograms, Based on work by McLovin.
	Creditors: Rusketh, McLovin
==============================================================================================*/
AddCSLuaFile( )

local E_A = LemonGate

local Orange = ENT

local net = net
local pairs = pairs
local Count = table.Count

/*********************************************************************************************/

Orange.Type            = "anim"
Orange.Base            = "base_anim"

Orange.PrintName       = "Orange"
Orange.Author          = "Rusketh"

Orange.Spawnable       = false
Orange.AdminSpawnable  = false

/*********************************************************************************************/

function Orange:Initialize( )
	if SERVER then
		self:SetSolid( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:DrawShadow( false )
		
		self.Que = {}
	end
	
	self.Scale = Vector(1, 1, 1)
	
	self.IsVisable = true
	self.Shading = true
	self.Clips = {}
	self.Count = 0
end

/*********************************************************************************************/

if SERVER then
	
	Orange.IsHologram = true
	Orange.NeedsUpdate = false
	
	function Orange:SetVisable( Bool )
		if self.IsVisable != Bool then
			self.IsVisable = Bool
			
			Orange.NeedsUpdate = true
			return true
		end
	end
	
	function Orange:SetShading( Bool )
		if self.Shading != Bool then
			self.Shading = Bool
			
			Orange.NeedsUpdate = true
			return true
		end
	end
	
	function Orange:PushClip( Index, Normal, Origin )
		local Clips = self.Clips
		local Clip = self.Clips[Index]
		
		if !Clip then
			Clip = { Enabled = true }
			self.Count = self.Count + 1
		end
		
		if !Clip.Enabled or (!Clip.Normal or !Clip.Origin) or
		   Clip.Normal ~= Normal or Clip.Origin ~= Origin then
			
			Clip.Enabled = true
			Clip.Normal = Normal
			Clip.Origin = Origin
			
			self.Clips[Index] = Clip
			self.Que[Index] = Clip
			
			Orange.NeedsUpdate = true
			return true
		end
	end
	
	function Orange:RemoveClip( Index )
		if self.Clips[Index] then
			self.Count = self.Count - 1
		end
		
		local Clip = { Enabled = false, Remove = true }
		
		self.Clips[Index] = nil
		self.Que[Index] = Clip
		
		Orange.NeedsUpdate = true
		return true
	end
	
	function Orange:EnableClip( Index, Bool )
		local Clip = self.Clips[Index]
		if Clip and Clip.Enabled != Bool then
			Clip.Enabled = Bool
			self.Que[Index] = Clip
			Orange.NeedsUpdate = true
			return true
		end
	end
	
	function Orange:ClipCount( Index, Max )
		if self.Clips[Index] then
			return true
		else 
			return self.Count >= Max
		end
	end
	
	function Orange:SetScale( X, Y, Z )
		local Scale = self.Scale
		
		if Scale.x ~= X or Scale.y ~= Y or Scale.z ~= Z then
			self.Scale = Vector( X, Y, Z )
			Orange.NeedsUpdate = true
			return true
		end
	end
	
	function Orange:Sync( Force )
		if self.NeedsUpdate or Force then
			net.WriteUInt( self:EntIndex(), 16)
			net.WriteBit( self.IsVisable )
			net.WriteBit( self.Shading )
			net.WriteVector( self.Scale )
			
			local Que = self.Que
			if Force then Que = self.Clips end
			
			local QueSize = Count( Que )
			net.WriteUInt( QueSize, 16)
			
			if QueSize > 0 then
				for Index, Clip in pairs( Que ) do
					
					net.WriteUInt( Index, 16)
					net.WriteBit( Clip.Enabled )
					
					if Clip.Enabled then
						net.WriteVector( Clip.Normal )
						net.WriteVector( Clip.Origin )
					elseif Clip.Remove then
						self.Clips[Index] = nil
					end
				end
				
				self.Que = { }
			end
			
			self.NeedsUpdate = false
		end
	end
	
else
	Orange.RenderGroup = RENDERGROUP_BOTH
	
	local EnableClipping = render.EnableClipping
	local PushCustomClipPlane = render.PushCustomClipPlane
	local PopCustomClipPlane = render.PopCustomClipPlane
	local SuppressEngineLighting = render.SuppressEngineLighting
	
	function Orange:Draw( )
		if self.IsVisable then
		-- SCALE.
			
			local Scale = self.Scale
			local Neo = Matrix( ) -- He He :D
			Neo:Scale( Scale )
			self:EnableMatrix( "RenderMultiply", Neo )
			
			local Min, Max = self:OBBMins(), self:OBBMaxs()
			self:SetRenderBounds( Scale * Max, Scale * Min )
			
		-- CLIPPING.
		
			local Clips = self.Clips
			local Total, Clipped = 0, false
			
			for _, Clip in pairs( Clips ) do
				if Clip and Clip.Enabled then
					
					if !Clipped then
						EnableClipping( true )
						Clipped = true
					end
					
					local Normal = self:LocalToWorld( Clip.Normal )
					local Origin = self:LocalToWorld( Clip.Origin )
					PushCustomClipPlane( Normal, Normal:Dot( Origin ) )
					
					Total = Total + 1
				end
			end
			
		-- RENDER.
		
			if !self.Shading then
				SuppressEngineLighting( true )
			end
			
			self:DrawModel()
		
		-- RESET.
		
			SuppressEngineLighting( false )

			if Clipped then
				for I = 1, Total do PopCustomClipPlane() end
				EnableClipping( false )
			end
			
		end
	end
	
	function Orange:Sync( )
		self.IsVisable = ( net.ReadBit( ) == 1 ) and 1 or 0
		self.Shading   = ( net.ReadBit( ) == 1 ) and 1 or 0
		self.Scale     = net.ReadVector( )
		
		local Clips = self.Clips
		local QueSize  = net.ReadUInt( 16 )
		for I = 1, QueSize do
			local Index = net.ReadUInt( 16 )
			
			local Clip = { }
			Clip.Enabled = ( net.ReadBit( ) == 1 ) and 1 or 0
			
			if Clip.Enabled then
				Clip.Normal = net.ReadVector()
				Clip.Origin = net.ReadVector()
				Clips[Index] = Clip
			else
				Clips[Index] = nil
			end
		end
	end
	
	net.Receive("lemon_hologram", function( Len )
		local Index = net.ReadUInt( 16 )
		
		while Index ~= 0 do
			local Holo = Entity( Index )
			if Holo and Holo:IsValid() and Holo.Sync then
				Holo:Sync( )
			end
			
			Index = net.ReadUInt( 16 )
		end
	end)
end