/*==============================================================================================
	LemonGate: Orange Holograms.
	Purpose: Makes holograms, Based on work by McLovin.
	Creditors: Rusketh, McLovin
==============================================================================================*/
if !WireLib or !LEMON then return end
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
	self.NeedsUpdate = true
	self.Scale = Vector(1, 1, 1)
	
	self.IsVisible = true
	self.Shading = true
	self.Bones = { }
	self.Clips = { }
	self.Count = 0
	
	if SERVER then
		self:SetSolid( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:DrawShadow( false )
		
		self.Que = { }
		self.Que2 = { }
	else
		self:Rescale( )
	end
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
	
	-- BONES:
	function Orange:GetBone( ID )
		local Count = self:GetBoneCount( )
		
		if Count > 1 and ID > 0 and ID < Count -1 then
			local Bone = self.Bones[ ID ]
			
			if !Bone then
				Bone = {
					Jiggle = 0, //self:GetManipulateBoneJiggle( ID ),
					Scale = self:GetManipulateBoneScale( ID ),
					Pos = self:GetManipulateBonePosition( ID ),
					Ang = self:GetManipulateBoneAngles( ID )
				}; self.Bones[ ID ] = Bone
			end
			
			//print( "Bone Jiggle: ", ID, Bone.Jiggle, type( Bone.Jiggle ) )
			return Bone
		end		
	end
	
	function Orange:SetUpBonePos( ID, Pos )
		local Bone = self:GetBone( ID )
		if Bone and Pos ~= Bone.Pos then
			Bone.Pos = Pos
			self.Que2[ ID ] = Bone
			self.NeedsUpdate = true
			return true
		end
	end
	
	function Orange:SetUpBoneAng( ID, Ang )
		local Bone = self:GetBone( ID )
		if Bone and Ang ~= Bone.Ang then
			Bone.Ang = Ang
			self.Que2[ ID ] = Bone
			self.NeedsUpdate = true
			return true
		end
	end
	
	function Orange:SetUpBoneScale( ID, Scale )
		local Bone = self:GetBone( ID )
		if Bone and Scale ~= Bone.Scale then
			Bone.Scale = Scale
			self.Que2[ ID ] = Bone
			self.NeedsUpdate = true
			return true
		end
	end
	
	function Orange:SetUpBoneJiggle( ID, Jiggle )
		local Bone = self:GetBone( ID )
		if Bone and Jiggle ~= Bone.Jiggle then
			Bone.Jiggle = Jiggle
			self.Que2[ ID ] = Bone
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
		
		-- SEND CLIPS
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
        
		-- SEND BONES
			local Queue = Force and self.Bones or self.Que2
			local cnt = Count( Queue ) 
			net.WriteUInt( cnt, 16 )
			
			if cnt > 0 then
				for Index, Bone in pairs( Queue ) do
					net.WriteUInt( Index, 16 )
					net.WriteVector( Bone.Pos )
					net.WriteAngle( Bone.Ang )
					net.WriteVector( Bone.Scale )
					net.WriteBit( Bone.Jiggle ) 
				end
				
			end
			
			self.Que = { }
			self.Que2 = { }
			self.NeedsUpdate = false
		end 
	end 
	
else
	local SyncBuffer = { }
	
	Orange.RenderGroup = RENDERGROUP_BOTH
	
	local EnableClipping = render.EnableClipping
	local PushCustomClipPlane = render.PushCustomClipPlane
	local PopCustomClipPlane = render.PopCustomClipPlane
	local SuppressEngineLighting = render.SuppressEngineLighting
	
	function Orange:Rescale( )
		local Buffer = SyncBuffer[ self:EntIndex( ) ] 
		
		if Buffer then
			local Scale = Buffer.Scale
			
			if self:SetBones( Buffer ) then
				//Do nothing =D
			elseif self.EnableMatrix then
				local Neo = Matrix( )
				Neo:Scale( Scale )
				self:EnableMatrix("RenderMultiply", Neo )
			else
				self:SetModelScale( (Scale.x + Scale.y + Scale.z) / 3, 0)
			end

			local Min, Max = self:OBBMins( ), self:OBBMaxs( )
			self:SetRenderBounds( Scale * Max, Scale * Min )
		end
	end
	
	function Orange:SetBones( Buffer )
		local Scale = Buffer and Buffer.Scale or self.Scale
		local Bones = Buffer and Buffer.Bones or self.Bones
		local Count = self:GetBoneCount( )
		
		if Count > 1 then
			for ID = 0, Count - 1 do
				local Info = Bones[ ID ]
				
				if !Info then
					Info = {
						Scale = self:GetManipulateBoneScale( ID ),
						Pos = self:GetManipulateBonePosition( ID ),
						Ang = self:GetManipulateBoneAngles( ID ),
						Jiggle = false
					}; self.Bones[ ID ] = Info
				end
				
				self:ManipulateBonePosition( ID, Info.Pos )
				self:ManipulateBoneAngles( ID, Info.Ang )
				self:ManipulateBoneScale( ID, Info.Scale )
				self:ManipulateBoneJiggle( ID, Info.Jiggle and 1 or 0 )
			end
			
			return true
		end
	end

	function Orange:Draw( )
		local Buffer = self.Buffer or SyncBuffer[ self:EntIndex( ) ] 
		self.Buffer = Buffer
		
		if Buffer and Buffer.IsVisible then
		
			if self:GetColor( ).a ~= 255 then
				self.RenderGroup = RENDERGROUP_BOTH
			else
				self.RenderGroup = RENDERGROUP_OPAQUE
			end
			
			local ClipsPushed = 0
			local ClipState = EnableClipping( true )
		
			for _, Clip in pairs( Buffer.Clips ) do
				if Clip.Enabled then
					local Normal = self:LocalToWorld( Clip.Normal ) - self:GetPos( ) 
					
					local Origin = self:LocalToWorld( Clip.Origin )
					
					PushCustomClipPlane( Normal, Normal:Dot( Origin ) )
					
					ClipsPushed = ClipsPushed + 1
				end
			end
			
			SuppressEngineLighting( !Buffer.Shading )
			
			self:DrawModel( )
		
			SuppressEngineLighting( false )

			for I = 1, ClipsPushed do
				PopCustomClipPlane( )
			end
			
			EnableClipping( ClipState )
			
		end
	end
	
	local function Sync( self )
		self.IsVisible = net.ReadBit( ) == 1 
		self.Shading = net.ReadBit( ) == 1
		self.Scale = net.ReadVector( )
		
	-- GET CLIPS
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
		
	-- GET BONES
		self.Bones = self.Bones or { }
		
		local cnt = net.ReadUInt( 16 ) 
		for I = 1, cnt do 
			local Index = net.ReadUInt( 16 ) 
			self.Bones[ Index ] = {
				Pos = net.ReadVector( ),
				Ang = net.ReadAngle( ),
				Scale = net.ReadVector( ),
				Jiggle = net.ReadBit( ) == 1
			}
		end
	end
    
	net.Receive( "lemon_hologram", function( Len )
		local Index = net.ReadUInt( 16 )
		
		while Index ~= 0 do
			local Ent = Entity( Index )
			
			SyncBuffer[Index] = SyncBuffer[Index] or { }
			
			Sync( SyncBuffer[Index] )
			
			if IsValid( Ent ) then
				if Ent.Rescale then Ent:Rescale( ) end
			end
			
			Index = net.ReadUInt( 16 )
		end
	end )
    
    net.Receive( "lemon_hologram_remove_clips", function( Len ) 
        local Index = net.ReadUInt( 16 )
        if SyncBuffer[Index] then SyncBuffer[Index] = nil end 
    end )
end

