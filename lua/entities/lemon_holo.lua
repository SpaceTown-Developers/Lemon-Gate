AddCSLuaFile( )

/*==============================================================================================
	Expression Advanced: Entity -> Holograms.
	Creditors: Rusketh
==============================================================================================*/

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.IsHologram = true
ENT.AutomaticFrameAdvance  = true
ENT.RenderGroup = RENDERGROUP_BOTH

/*==============================================================================================
	First: NW Table Template.
==============================================================================================*/
local function NewInfoTable( )
	return {
		VISIBLE = true,
		SHADING = true,
		SCALEX = 1,
		SCALEY = 1,
		SCALEZ = 1,
		CLIPS = { },
		BONES = { } 
	}
end

local function NewClippingTable( )
	return {
		ENABLED = true,
		NORMALX = 0,
		NORMALY = 0,
		NORMALZ = 0,
		ORIGINX = 0,
		ORIGINY = 0,
		ORIGINZ = 0
	}
end

local function NewBoneTable( )
	return {
		JIGGLE = false,
		POSX = 0,
		POSY = 0,
		POSZ = 0,
		SCALEX = 0,
		SCALEY = 0,
		SCALEZ = 0,
		ANGLEP = 0,
		ANGLEY = 0,
		ANGLER = 0
	}
end 

/*==============================================================================================
	First: Create the NW table.
==============================================================================================*/
local INFOTABLE = { }

local function LinkHoloInfo( self )
	local Key = self:EntIndex( )

	INFOTABLE[ Key ] = INFOTABLE[ Key ] or NewInfoTable( )

	self.INFO = INFOTABLE[ Key ]

	self.CLIPS = self.INFO.CLIPS
	self.BONES = self.INFO.BONES

	if CLIENT then return end

	self.SYNC_CLIPS = { }
	self.SYNC_BONES = { }
end

if CLIENT then

	hook.Add( "NetworkEntityCreated", "lemon.hologram", function( ENT )
		if !IsValid( ENT ) then return end
		if ENT:GetClass( ) ~= "lemon_holo" then return end

		LinkHoloInfo( ENT )
		if ENT.ApplyHoloInfo then ENT:ApplyHoloInfo( ) end
	end )

end

/*==============================================================================================
    Section: Create Entity
==============================================================================================*/
local SyncQueue, ClipQueue, BoneQueue

function ENT:Initialize( )
	LinkHoloInfo( self )

	if CLIENT then return self:ApplyHoloInfo( ) end
	
	self:SetSolid( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:DrawShadow( false )

	SyncQueue[ self ] = true
end

function ENT:OnRemove( )
	if CLIENT then return end

	INFOTABLE[ self:EntIndex( ) ] = nil

	if IsValid( self.Player ) then
		self.Player:SetNWInt( "lemon.holograms", self.Player:GetNWInt( "lemon.holograms", 0 ) - 1 )
	end
end
/*==============================================================================================
    Section: Queue System
==============================================================================================*/

if SERVER then
	SyncQueue = { }

	util.AddNetworkString( "lemon.hologram" )

	function ENT:SyncInfo( Forced )
		if Forced then return self:SyncInfoForced( ) end

		-- Its faster to constantly update these:
			net.WriteBit( self.INFO.VISIBLE )
			net.WriteBit( self.INFO.SHADING )

		net.WriteBit( self.SYNC_SCALEX )
		if self.SYNC_SCALEX then
			self.SYNC_SCALEX = nil
			net.WriteFloat( self.INFO.SCALEX )
		end
		
		net.WriteBit( self.SYNC_SCALEY )
		if self.SYNC_SCALEY then
			self.SYNC_SCALEY = nil
			net.WriteFloat( self.INFO.SCALEY )
		end
		
		net.WriteBit( self.SYNC_SCALEZ )
		if self.SYNC_SCALEZ then
			self.SYNC_SCALEZ = nil
			net.WriteFloat( self.INFO.SCALEZ )
		end
	end

	function ENT:SyncInfoForced( )
	
		net.WriteBit( self.INFO.VISIBLE )
		net.WriteBit( self.INFO.SHADING )

		net.WriteBit( true )
		net.WriteFloat( self.INFO.SCALEX )
		
		net.WriteBit( true )
		net.WriteFloat( self.INFO.SCALEY )
		
		net.WriteBit( true )
		net.WriteFloat( self.INFO.SCALEZ )
		
	end

	ClipQueue = { }

	function ENT:SyncClips( Forced )
		
		if Forced then return self:SyncClipsForced( ) end

		for ID, _ in pairs( SYNC_CLIPS ) do

			net.WriteUInt( ID, 16 )

			local Info = self.CLIPS[ID]

			net.WriteBit( Info.ENABLED )

			net.WriteBit( Info.SYNC_NORMALX )
			if Info.SYNC_NORMALX then
				Info.SYNC_NORMALX = nil
				net.WriteFloat( Info.NORMALX )
			end

			net.WriteBit( Info.SYNC_NORMALY )
			if Info.SYNC_NORMALY then
				Info.SYNC_NORMALY = nil
				net.WriteFloat( Info.NORMALY )
			end

			net.WriteBit( Info.SYNC_NORMALZ )
			if Info.SYNC_NORMALZ then
				Info.SYNC_NORMALZ = nil
				net.WriteFloat( Info.NORMALZ )
			end

			net.WriteBit( Info.SYNC_ORIGINX )
			if Info.SYNC_ORIGINX then
				Info.SYNC_ORIGINX = nil
				net.WriteFloat( Info.ORIGINX )
			end

			net.WriteBit( Info.SYNC_ORIGINY )
			if Info.SYNC_ORIGINY then
				Info.SYNC_ORIGINY = nil
				net.WriteFloat( Info.ORIGINY )
			end

			net.WriteBit( Info.SYNC_ORIGINZ )
			if Info.SYNC_ORIGINZ then
				Info.SYNC_ORIGINZ = nil
				net.WriteFloat( Info.ORIGINZ )
			end

		end

		self.SYNC_CLIPS = { }

		net.WriteUInt( 0, 16 )
	end

	function ENT:SyncClipsForced( Forced )
		
		for ID, Info in pairs( self.CLIPS ) do

			net.WriteUInt( ID, 16 )

			net.WriteBit( Info.ENABLED )

			net.WriteBit( true )
			net.WriteFloat( Info.NORMALX )

			net.WriteBit( true )
			net.WriteFloat( Info.NORMALY )

			net.WriteBit( true )
			net.WriteFloat( Info.NORMALZ )

			net.WriteBit( true )
			net.WriteFloat( Info.ORIGINX )

			net.WriteBit( true )
			net.WriteFloat( Info.ORIGINY )

			net.WriteBit( true )
			net.WriteFloat( Info.ORIGINZ )

		end

		net.WriteUInt( 0, 16 )
	end


	BoneQueue = { }

	function ENT:SyncBones( Forced )
		
		if Forced then return self:SyncBonesForced( ) end

		for ID, _ in pairs( SYNC_BONES ) do

			net.WriteUInt( ID, 16 )

			local Info = self.BONES[ID]

			net.WriteBit( Info.JIGGLE )

			net.WriteBit( Info.SYNC_POSX )
			if Info.SYNC_POSX then
				Info.SYNC_POSX = nil
				net.WriteFloat( Info.POSX )
			end

			net.WriteBit( Info.SYNC_POSY )
			if Info.SYNC_POSY then
				Info.SYNC_POSY = nil
				net.WriteFloat( Info.POSY )
			end

			net.WriteBit( Info.SYNC_POSZ )
			if Info.SYNC_POSZ then
				Info.SYNC_POSZ = nil
				net.WriteFloat( Info.POSZ )
			end

			net.WriteBit( Info.SYNC_SCALEX )
			if Info.SYNC_SCALEX then
				Info.SYNC_SCALEX = nil
				net.WriteFloat( Info.SCALEX )
			end

			net.WriteBit( Info.SYNC_SCALEY )
			if Info.SYNC_SCALEY then
				Info.SYNC_SCALEY = nil
				net.WriteFloat( Info.SCALEY )
			end

			net.WriteBit( Info.SYNC_SCALEZ )
			if Info.SYNC_SCALEZ then
				Info.SYNC_SCALEZ = nil
				net.WriteFloat( Info.SCALEZ )
			end

			net.WriteBit( Info.SYNC_ANGLEP )
			if Info.SYNC_ANGLEP then
				Info.SYNC_ANGLEP = nil
				net.WriteFloat( Info.ANGLEP )
			end

			net.WriteBit( Info.SYNC_ANGLEY )
			if Info.SYNC_ANGLEY then
				Info.SYNC_ANGLEY = nil
				net.WriteFloat( Info.ANGLEY )
			end

			net.WriteBit( Info.SYNC_ANGLER )
			if Info.SYNC_ANGLER then
				Info.SYNC_ANGLER = nil
				net.WriteFloat( Info.ANGLER )
			end

		end

		net.WriteUInt( 0, 16 )

	end

	function ENT:SyncBonesForced( Forced )
		
		for ID, Info in pairs( self.BONES ) do
			
			net.WriteBit( Info.JIGGLE )

			net.WriteBit( true )
			net.WriteFloat( Info.POSX )

			net.WriteBit( true )
			net.WriteFloat( Info.POSY )

			net.WriteBit( true )
			net.WriteFloat( Info.POSZ )

			net.WriteBit( true )
			net.WriteFloat( Info.SCALEX )

			net.WriteBit( true )
			net.WriteFloat( Info.SCALEY )

			net.WriteBit( true )
			net.WriteFloat( Info.SCALEZ )

			net.WriteBit( true )
			net.WriteFloat( Info.ANGLEP )

			net.WriteBit( true )
			net.WriteFloat( Info.ANGLEY )

			net.WriteBit( true )
			net.WriteFloat( Info.ANGLER )

		end

		net.WriteUInt( 0, 16 )

	end

	function ENT:SyncClient( Force )
		
		net.WriteUInt( self:EntIndex( ), 16 )

		if SyncQueue[ self ] or Force then
			net.WriteBit( true )
			self:SyncInfo( Forced )
		else
			net.WriteBit( false )
		end

		if ClipQueue[ self ] or Force then
			net.WriteBit( true )
			self:SyncClips( Forced )
		else
			net.WriteBit( false )
		end

		if BoneQueue[ self ] or Force then
			net.WriteBit( true )
			self:SyncBones( Forced )
		else
			net.WriteBit( false )
		end

		if !Force then
			SyncQueue[ self ] = nil
			ClipQueue[ self ] = nil
			BoneQueue[ self ] = nil
		end
	end

	hook.Add( "PlayerInitialSpawn", "lemon.hologram", function( Ply )
		net.Start( "lemon.hologram" )
			
			for _, ENT in pairs( ents.FindByClass( "lemon_hologram" ) ) do
				ENT:SyncClient( true )
			end

			net.WriteUInt( 0, 16 )

		net.Send( Ply )
	end )

	hook.Add( "Tick", "lemon.hologram", function( )
		local Queue = { }
		local NeedsUpdate = false

		for ENT, _ in pairs( SyncQueue ) do Queue[ENT] = true; NeedsUpdate = true end
		for ENT, _ in pairs( ClipQueue ) do Queue[ENT] = true; NeedsUpdate = true end
		for ENT, _ in pairs( BoneQueue ) do Queue[ENT] = true; NeedsUpdate = true end

		if !NeedsUpdate then return end

		net.Start( "lemon.hologram" )
			
			for ENT, _ in pairs( Queue ) do
				ENT:SyncClient( false )
			end

			net.WriteUInt( 0, 16 )

		net.Broadcast( )
	end )

elseif CLIENT then -- End of <if SERVER>

	local function UpdateInfo( Key )

		local Info = INFOTABLE[ Key ]

		Info.VISIBLE = net.ReadBit( ) == 1
		Info.SHADING = net.ReadBit( ) == 1
		
		if net.ReadBit( ) == 1 then Info.SCALEX = net.ReadFloat( ) end
		if net.ReadBit( ) == 1 then Info.SCALEY = net.ReadFloat( ) end
		if net.ReadBit( ) == 1 then Info.SCALEZ = net.ReadFloat( ) end

	end

	local function UpdateClips( Key )
		
		local Clips = INFOTABLE[ Key ].CLIPS

		local ID = net.ReadUInt( 16 )

		while ID ~= 0 do

			Clips[ID] = Clips[ID] or NewClippingTable( )

			local Info = Clips[ID]

			Info.ENABLED = net.ReadBit( ) == 1

			if net.ReadBit( ) == 1 then Info.NORMALX = net.ReadFloat( ) end
			if net.ReadBit( ) == 1 then Info.NORMALY = net.ReadFloat( ) end
			if net.ReadBit( ) == 1 then Info.NORMALZ = net.ReadFloat( ) end

			if net.ReadBit( ) == 1 then Info.ORIGINX = net.ReadFloat( ) end
			if net.ReadBit( ) == 1 then Info.ORIGINY = net.ReadFloat( ) end
			if net.ReadBit( ) == 1 then Info.ORIGINZ = net.ReadFloat( ) end

			ID = net.ReadUInt( 16 )
		end
	end

	local function UpdateBones( Key )
		local Bones = INFOTABLE[ Key ].BONES

		local ID = net.ReadUInt( 16 )

		while ID ~= 0 do

			Bones[ID] = Bones[ID] or NewBoneTable( )

			local Info = Bones[ID]

			Info.JIGGLE = net.ReadBit( ) == 1

			if net.ReadBit( ) == 1 then Info.POSY = net.ReadFloat( ) end
			if net.ReadBit( ) == 1 then Info.POSX = net.ReadFloat( ) end
			if net.ReadBit( ) == 1 then Info.POSZ = net.ReadFloat( ) end

			if net.ReadBit( ) == 1 then Info.SCALEY = net.ReadFloat( ) end
			if net.ReadBit( ) == 1 then Info.SCALEX = net.ReadFloat( ) end
			if net.ReadBit( ) == 1 then Info.SCALEZ = net.ReadFloat( ) end

			if net.ReadBit( ) == 1 then Info.ANGLEP = net.ReadFloat( ) end
			if net.ReadBit( ) == 1 then Info.ANGLEY = net.ReadFloat( ) end
			if net.ReadBit( ) == 1 then Info.ANGLER = net.ReadFloat( ) end

			ID = net.ReadUInt( 16 )
		end
	end

	net.Receive( "lemon.hologram", function( Len )

		local Key = net.ReadUInt( 16 )

		while Key ~= 0 do

			INFOTABLE[ Key ] = INFOTABLE[ Key ] or NewInfoTable( )

			if net.ReadBit( ) == 1 then  UpdateInfo( Key ) end
			if net.ReadBit( ) == 1 then  UpdateClips( Key ) end
			if net.ReadBit( ) == 1 then  UpdateBones( Key ) end

			local ENT = Entity( Key )
			if IsValid( ENT ) and ENT.ApplyHoloInfo then ENT:ApplyHoloInfo( ) end

			Key = net.ReadUInt( 16 )

		end

	end )

end -- End Of <if CLIENT>

/*==============================================================================================
    ID
==============================================================================================*/
if SERVER then
	ENT.ID = -1

/*==============================================================================================
    Rendering
==============================================================================================*/

	function ENT:SetVisible( bVis )
		if self.INFO.VISIBLE == bVis then return end
		self.INFO.VISIBLE = bVis
		SyncQueue[ self ] = true
	end

	function ENT:SetShading( bShade )
		if self.INFO.SHADING == bShade then return end
		self.INFO.SHADING = bShade
		SyncQueue[ self ] = true
	end

	-- ENT:DrawShadow( b )

/*==============================================================================================
    Scale
==============================================================================================*/

	function ENT:SetScale( Vector )
		local ScaleLimit = GetConVarNumber( "lemon_holograms_Size", 50 )

		Vector.x = math.Clamp( Vector.x, -ScaleLimit, ScaleLimit )
		Vector.y = math.Clamp( Vector.y, -ScaleLimit, ScaleLimit )
		Vector.z = math.Clamp( Vector.z, -ScaleLimit, ScaleLimit )

		if self.INFO.SCALEX ~= Vector.x then
			self.INFO.SCALEX = Vector.x
			self.SYNC_SCALEX = true
			SyncQueue[ self ] = true
		end

		if self.INFO.SCALEY ~= Vector.y then
			self.INFO.SCALEY = Vector.y
			self.SYNC_SCALEY = true
			SyncQueue[ self ] = true
		end

		if self.INFO.SCALEZ ~= Vector.z then
			self.INFO.SCALEZ = Vector.z
			self.SYNC_SCALEZ = true
			SyncQueue[ self ] = true
		end
	end

	function ENT:SetScaleUnits( Vector )
		local  OBBSize = self:OBBMaxs( ) - self:OBBMins( )

		Vector.x = Vector.x * OBBSize.x
		Vector.y = Vector.y * OBBSize.y
		Vector.z = Vector.z * OBBSize.z

		self:SetScale( Vector )
	end

	function ENT:GetScale( )
		return Vector( self.INFO.SCALEX or 0, self.INFO.SCALEY or 0, self.INFO.SCALEZ or 0 )
	end

/*==============================================================================================
    Clipping
==============================================================================================*/
	
	function ENT:PushClip( ID, Origin, Normal )
		self:SetClipOrigin( ID, Origin )
		self:SetClipNormal( ID, Normal )
	end

	function ENT:SetClipEnabled( ID, bEnable )
		if ID < 1 or ID > GetConVarNumber( "lemon_holograms_clips", 5 ) then return end
		
		self.CLIPS[ ID ] = self.CLIPS[ ID ] or NewClippingTable( )

		self.CLIPS[ ID ].ENABLED = bEnable

		self.SYNC_CLIPS[ ID ] = true
	end

	function ENT:SetClipOrigin( ID, Vector )
		if ID < 1 or ID > GetConVarNumber( "lemon_holograms_clips", 5 ) then return end
		
		self.CLIPS[ ID ] = self.CLIPS[ ID ] or NewClippingTable( )

		local Clip = self.CLIPS[ ID ]

		if Clip.ORIGINX ~= Vector.x then
			Clip.ORIGINX = Vector.x
			Clip.SYNC_ORIGINX = true
			self.SYNC_CLIPS[ ID ] = true
		end

		if Clip.ORIGINY ~= Vector.y then
			Clip.ORIGINY = Vector.y
			Clip.SYNC_ORIGINY = true
			self.SYNC_CLIPS[ ID ] = true
		end

		if Clip.ORIGINZ ~= Vector.z then
			Clip.ORIGINZ = Vector.z
			Clip.SYNC_ORIGINZ = true
			self.SYNC_CLIPS[ ID ] = true
		end
	end

	function ENT:SetClipNormal( ID, Vector )
		if ID < 1 or ID > GetConVarNumber( "lemon_holograms_clips", 5 ) then return end
		
		self.CLIPS[ ID ] = self.CLIPS[ ID ] or NewClippingTable( )

		local Clip = self.CLIPS[ ID ]

		if Clip.NORMALX ~= Vector.x then
			Clip.NORMALX = Vector.x
			Clip.SYNC_NORMALX = true
			self.SYNC_CLIPS[ ID ] = true
		end

		if Clip.NORMALY ~= Vector.y then
			Clip.NORMALY = Vector.y
			Clip.SYNC_NORMALY = true
			self.SYNC_CLIPS[ ID ] = true
		end

		if Clip.NORMALZ ~= Vector.z then
			Clip.NORMALZ = Vector.z
			Clip.SYNC_NORMALZ = true
			self.SYNC_CLIPS[ ID ] = true
		end
	end

/*==============================================================================================
    Bones
==============================================================================================*/
	
	function ENT:SetBoneJiggle( ID, bJiggle )
		if ID < 1 or ID > self:GetBoneCount( ) then return end

		self:ManipulateBoneJiggle( ID - 1, bJiggle and 1 or 0 )

		self.BONES[ ID ] = self.BONES[ ID ] or NewBoneTable( )

		self.BONES[ ID ].JIGGLE = bJiggle

	end

	function ENT:GetBoneJiggle( ID )
		if ID < 1 or ID > self:GetBoneCount( ) then return false end

		return self:GetManipulateBoneJiggle( ID - 1 )
	end

	function ENT:SetBonePos( ID, Vector )
		if ID < 1 or ID > self:GetBoneCount( ) then return end
		
		self:ManipulateBonePosition( ID - 1, Vector )

		self.BONES[ ID ] = self.BONES[ ID ] or NewBoneTable( )

		local Clip = self.BONES[ ID ]

		if Clip.POSX ~= Vector.x then
			Clip.POSX = Vector.x
			Clip.SYNC_POSX = true
			self.SYNC_BONES[ ID ] = true
		end

		if Clip.POSY ~= Vector.y then
			Clip.POSY = Vector.y
			Clip.SYNC_POSY = true
			self.SYNC_BONES[ ID ] = true
		end

		if Clip.POSZ ~= Vector.z then
			Clip.POSZ = Vector.z
			Clip.SYNC_POSZ = true
			self.SYNC_BONES[ ID ] = true
		end
	end

	function ENT:GetBonePos( ID )
		if ID < 1 or ID > self:GetBoneCount( ) then return Vector( 0, 0, 0 ) end
		
		return self:GetManipulateBonePosition( ID - 1 )
	end

	function ENT:SetBoneScale( ID, Vector )
		if ID < 1 or ID > self:GetBoneCount( ) then return end
		
		self:ManipulateBoneScale( ID - 1, Vector )

		self.BONES[ ID ] = self.BONES[ ID ] or NewBoneTable( )

		local Clip = self.BONES[ ID ]

		if Clip.SCALEX ~= Vector.x then
			Clip.SCALEX = Vector.x
			Clip.SYNC_SCALEX = true
			self.SYNC_BONES[ ID ] = true
		end

		if Clip.SCALEY ~= Vector.y then
			Clip.SCALEY = Vector.y
			Clip.SYNC_SCALEY = true
			self.SYNC_BONES[ ID ] = true
		end

		if Clip.SCALEZ ~= Vector.z then
			Clip.SCALEZ = Vector.z
			Clip.SYNC_SCALEZ = true
			self.SYNC_BONES[ ID ] = true
		end
	end

	function ENT:GetBoneScale( ID )
		if ID < 1 or ID > self:GetBoneCount( ) then return Vector( 0, 0, 0 ) end
		
		return self:GetManipulateBoneScale( ID - 1 )
	end

	function ENT:SetBoneAngle( ID, Angle )
		if ID < 1 or ID > self:GetBoneCount( ) then return end

		self:ManipulateBoneAngles( ID - 1, Angle )
		
		self.BONES[ ID ] = self.BONES[ ID ] or NewBoneTable( )

		local Clip = self.BONES[ ID ]

		if Clip.ANGLEP ~= Angle.p then
			Clip.ANGLEP = Angle.p
			Clip.SYNC_ANGLEP = true
			self.SYNC_BONES[ ID ] = true
		end

		if Clip.ANGLEY ~= Angle.y then
			Clip.ANGLEY = Angle.y
			Clip.SYNC_ANGLEY = true
			self.SYNC_BONES[ ID ] = true
		end

		if Clip.ANGLER ~= Angle.r then
			Clip.ANGLER = Angle.r
			Clip.SYNC_ANGLER = true
			self.SYNC_BONES[ ID ] = true
		end
	end

	function ENT:GetBoneAngle( ID )
		if ID < 1 or ID > self:GetBoneCount( ) then return Angle( 0, 0, 0 ) end
		
		return self:GetManipulateBoneAngles( ID - 1 )
	end

/*==============================================================================================
    Animation
==============================================================================================*/
	function ENT:SetAnimation( Animation, Frame, Rate )
		self:ResetSequence( Animation )
		self:SetCycle( Frame or 0 )
		self:SetPlaybackRate( Rate or 1 )
	end

/*==============================================================================================
    Auto Move
==============================================================================================*/
	
	function ENT:MoveTo( Vector, Speed )
		self.MOVETO = Vector
		self.MOVESPEED = Speed
	end

	function ENT:StopMove( )
		self.MOVETO = nil
		self.MOVESPEED = nil
	end

	function ENT:RotateTo( Angle, Speed )
		self.ROTATETO = Angle
		self.ROTATESPEED = Speed
	end

	function ENT:StopRotate( )
		self.ROTATETO = nil
		self.ROTATESPEED = nil
	end

	function ENT:ScaleTo( Vector, Speed )
		self.SCALETO = Vector
		self.SCALESPEED = Speed
	end

	function ENT:StopScale( )
		self.SCALETO = nil
		self.SCALESPEED = nil
	end

	function ENT:Think( )
		if self.MOVETO and self.MOVESPEED then
			local Pos = self:GetPos( )

			Pos.x = Pos.x + math.Clamp( self.MOVETO.x - Pos.x, -self.MOVESPEED, self.MOVESPEED )
			Pos.y = Pos.y + math.Clamp( self.MOVETO.y - Pos.y, -self.MOVESPEED, self.MOVESPEED )
			Pos.z = Pos.z + math.Clamp( self.MOVETO.z - Pos.z, -self.MOVESPEED, self.MOVESPEED )

			self:SetPos( Pos )

			if Pos == self.MOVETO then self:StopMove( ) end
		end

		if self.ROTATETO and self.ROTATESPEED then
			local Ang = self:GetAngles( )

			Ang.p = Ang.p + math.Clamp( self.ROTATETO.p - Ang.p, -self.ROTATESPEED, self.ROTATESPEED )
			Ang.y = Ang.y + math.Clamp( self.ROTATETO.y - Ang.y, -self.ROTATESPEED, self.ROTATESPEED )
			Ang.r = Ang.r + math.Clamp( self.ROTATETO.r - Ang.r, -self.ROTATESPEED, self.ROTATESPEED )

			self:SetAngles( Ang )

			if Ang == self.ROTATETO then self:StopRotate( ) end
		end

		if self.SCALETO and self.SCALESPEED then
			local Pos = self:GetPos( )

			Pos.x = Pos.x + math.Clamp( self.SCALETO.x - Pos.x, -self.SCALESPEED, self.SCALESPEED )
			Pos.y = Pos.y + math.Clamp( self.SCALETO.y - Pos.y, -self.SCALESPEED, self.SCALESPEED )
			Pos.z = Pos.z + math.Clamp( self.SCALETO.z - Pos.z, -self.SCALESPEED, self.SCALESPEED )

			self:SetScale( Pos )

			if Pos == self.SCALETO then self:StopScale( ) end
		end

		self:NextThink( CurTime( ) )
		return true
	end

	return -- Exit Server Side Code
end -- end of <if SERVER>

/*==============================================================================================
    Render
==============================================================================================*/
function ENT:Draw( )

	local Info = INFOTABLE[ self:EntIndex( ) ]

	-- Don't render what doesn't exist.
	if !Info or !Info.VISIBLE then return end


	if self:GetColor( ).a ~= 255 then
		self.RenderGroup = RENDERGROUP_BOTH
	else
		self.RenderGroup = RENDERGROUP_OPAQUE
	end

	local Pushed, State

	if Info.CLIPS then
		
		Pushed = 0
		State = render.EnableClipping( true )

		for _, Clip in pairs( Info.CLIPS ) do
			
			if !Clip.ENABLED then continue end

			local Normal = self:LocalToWorld( Vector( Clip.NORMALX, Clip.NORMALY, Clip.NORMALZ ) ) - self:GetPos( ) 
					
			local Origin = self:LocalToWorld( Vector( Clip.ORIGINX, Clip.ORIGINY, Clip.ORIGINZ ) )
					
			render.PushCustomClipPlane( Normal, Normal:Dot( Origin ) )
					
			Pushed = Pushed + 1
		
		end

	end

	render.SuppressEngineLighting( !Info.SHADING )
			
	self:DrawModel( )
		
	render.SuppressEngineLighting( false )

	if Info.CLIPS then

		for I = 1, Pushed do
			render.PopCustomClipPlane( )
		end
			
		render.EnableClipping( State )
	end
end

/*==============================================================================================
    Scale Info
==============================================================================================*/

function ENT:ApplyHoloInfo( )
	local Info = INFOTABLE[ self:EntIndex( ) ]

	if !Info then return end

	local Scale = Vector( Info.SCALEX, Info.SCALEY, Info.SCALEZ )

	if Info.BONES and self:GetBoneCount( ) > 1 then
		
		/*for ID = 0, self:GetBoneCount( ) - 1 do
			local BoneMatrix = self:GetBoneMatrix( ID )

			BoneMatrix:Scale( Scale )

			self:SetBoneMatrix( ID, BoneMatrix )
		end*/

		for ID, Bone in pairs( self.BONES ) do
			
			local ID = ID - 1

			self:ManipulateBoneJiggle( ID, Bone.JIGGLE and 1 or 0 )

			self:ManipulateBonePosition( ID, Vector( Bone.POSX, Bone.POSY, Bone.POSZ ) )

			self:ManipulateBoneScale( ID, Vector( Bone.SCALEX, Bone.SCALEY, Bone.SCALEZ ) )

			self:ManipulateBoneAngles( ID, Angle( Bone.ANGLEP, Bone.ANGLEY, Bone.ANGLEY ) )
		end

	elseif self.EnableMatrix then

		local ScaleMatrix = Matrix( )

		ScaleMatrix:Scale( Scale )

		self:EnableMatrix("RenderMultiply", ScaleMatrix )

	else
		self:SetModelScale( ( Info.SCALEX + Info.SCALEY + Info.SCALEZ ) / 3, 0)
	end

	self:SetRenderBounds( Scale * self:OBBMaxs( ), Scale * self:OBBMins( ) )

end