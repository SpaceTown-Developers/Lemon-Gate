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
	
	self.NeedsUpdate = true
	self.Scale = Vector(1, 1, 1)
	
	self.IsVisible = true
	self.Shading = true
	self.Clips = {}
	self.Count = 0
end

/*********************************************************************************************/

if SERVER then
	
	Orange.IsHologram = true
	Orange.NeedsUpdate = false
	
	function Orange:SetVisible( Bool )
		if self.IsVisible != Bool then
			self.IsVisible = Bool
			
			self.NeedsUpdate = true
			return true
		end
	end
	
	function Orange:SetShading( Bool )
		if self.Shading != Bool then
			self.Shading = Bool
			
			self.NeedsUpdate = true
			return true
		end
	end
	
	function Orange:PushClip( Index, Origin, Normal )
		local Clips = self.Clips
		local Clip = self.Clips[Index]
		
		if !Clip then
			Clip = { Enabled = true }
			self.Count = self.Count + 1
		end
		
        if !Clip.Enabled then return false end 
        
        local Change = false 
        
        if !Clip.Normal or Clip.Normal ~= Normal then 
            Clip.Normal = Normal
            Change = true
        end 
        
        if !Clip.Origin or Clip.Origin ~= Origin then 
            Clip.Origin = Origin
            Change = true
        end 
        
        if Change then 
            self.Clips[Index] = Clip
            self.Que[Index] = Clip 
            
            self.NeedsUpdate = true 
            return true
        end 
        
        return false
	end
	
	function Orange:RemoveClip( Index )
		if self.Clips[Index] then
			self.Count = self.Count - 1
		end
		
		local Clip = { Enabled = false, Remove = true }
		
		self.Clips[Index] = nil
		self.Que[Index] = Clip
		
		self.NeedsUpdate = true
		return true
	end
	
	function Orange:EnableClip( Index, Bool )
		local Clip = self.Clips[Index]
		if Clip and Clip.Enabled != Bool then
			Clip.Enabled = Bool
			self.Que[Index] = Clip
			self.NeedsUpdate = true
			return true
		end
	end
	
	function Orange:ClipCount( Index, Max )
		if self.Clips[Index] then
			return true
		else 
			return self.Count < Max
		end
	end
	
	function Orange:SetScale( X, Y, Z )
		local Scale = self.Scale
		
		if Scale.x ~= X or Scale.y ~= Y or Scale.z ~= Z then
			self.Scale = Vector( X, Y, Z )
			self.NeedsUpdate = true
			return true
		end
	end
	
	function Orange:Sync( Force )
		if self.NeedsUpdate or Force then 
			net.WriteUInt( self:EntIndex( ), 16 ) 
			net.WriteBit( self.IsVisible ) 
			net.WriteBit( self.Shading ) 
			net.WriteVector( self.Scale ) 
			
			local Queue = Force and self.Clips or self.Que 
			
            local cnt = Count( Queue ) 
            net.WriteUInt( cnt, 16 )
            
            if cnt > 0 then 
                for Index, Clip in pairs( Queue ) do
                    net.WriteUInt( Index, 16 )
                    net.WriteBit( Clip.Enabled ) 
                    
                    if Clip.Enabled then 
                        net.WriteVector( Clip.Normal )
                        net.WriteVector( Clip.Origin )
                    elseif Clip.Remove then 
                        net.WriteBit( 1 )
                        self.Clips[Index] = nil 
                    else 
                        net.WriteBit( 0 )
                    end 
                end
            end 
            
			self.Que = { }
			self.NeedsUpdate = false
		end 
	end 
	
else
	local SyncBuffer = {}
	
	Orange.RenderGroup = RENDERGROUP_BOTH
	
	local EnableClipping = render.EnableClipping
	local PushCustomClipPlane = render.PushCustomClipPlane
	local PopCustomClipPlane = render.PopCustomClipPlane
	local SuppressEngineLighting = render.SuppressEngineLighting
	
	function Orange:Draw( )
		local Index = self:EntIndex()
		local Buffer = SyncBuffer[ Index ] 
		if Buffer and Buffer.IsVisible then
		-- SCALE.
			
			local Scale = Buffer.Scale
			local Neo = Matrix( ) -- He He :D
			Neo:Scale( Scale )
			self:EnableMatrix( "RenderMultiply", Neo )
			
			local Bound = Vector(9999, 9999, 9999)
			self:SetRenderBounds( -Bound, Bound )
			
		-- CLIPPING.
		
			local Clips = Buffer.Clips
			local Total, Clipped = 0, false
			
			for _, Clip in pairs( Clips ) do
				if Clip and Clip.Enabled then
					
					if !Clipped then
						EnableClipping( true )
						Clipped = true
					end
					
					local Normal = self:LocalToWorld( Clip.Normal ) - self:GetPos() 
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
	
	local function Sync( self )
		self.IsVisible = net.ReadBit( ) == 1 
		self.Shading = net.ReadBit( ) == 1
		self.Scale = net.ReadVector( )
		
		self.Clips = self.Clips or { }
		
		local cnt = net.ReadUInt( 16 ) 
		for I = 1, cnt do 
			local Index = net.ReadUInt( 16 ) 
			local Clip = self.Clips[Index] or { } 
			
			Clip.Enabled = net.ReadBit( ) == 1 
			if Clip.Enabled then 
				Clip.Normal = net.ReadVector( )
				Clip.Origin = net.ReadVector( )
			elseif net.ReadBit( ) == 1 then 
				Clip = nil 
			end 
			
			self.Clips[Index] = Clip 
		end 
	end
    
	net.Receive( "lemon_hologram", function( Len )
		local Index = net.ReadUInt( 16 )
		
		while Index ~= 0 do
			SyncBuffer[Index] = SyncBuffer[Index] or { }
			Sync( SyncBuffer[Index] ) 
			Index = net.ReadUInt( 16 )
		end
	end )
    
    net.Receive( "lemon_hologram_remove_clips", function( Len ) 
        local Index = net.ReadUInt( 16 )
        if SyncBuffer[Index] then SyncBuffer[Index] = nil end 
    end )
end

