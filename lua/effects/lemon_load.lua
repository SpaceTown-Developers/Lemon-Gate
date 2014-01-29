/*==========================================================================
	Section: Lemongate Load animation.
==========================================================================*/
local Mat = Material( "omicron/lemongear" )

function EFFECT:Init( Input )
	
	local Entity = Input:GetEntity( )
	
	if !IsValid( Entity ) then
		return false
	end
	
	self:SetPos( Entity:GetPos( ) )
	
	self:SetAngles( Entity:GetAngles( ) + Angle( 0.01, 0.01, 0.01 ) )
	
	self:SetParent( Entity )
	
	self:SetCollisionBounds( Vector( -10, -10, -10 ), Vector( 10, 10, 10 ) )
	
	self.Alpha = 255
	
	self.Size = 5
end

function EFFECT:Think( )
	
	if !IsValid( self:GetParent( ) ) then
		return false
	end
	
	self.Alpha = self.Alpha - FrameTime( ) * 255 * 3
	
	self.Size = self.Size + FrameTime( ) * 156 * 0.5
	
	return self.Alpha >= 0
end

function EFFECT:Render( )

	if self.Alpha >= 1 then
		render.SetMaterial( Mat )
		render.DrawQuadEasy( self:GetPos( ), self:GetAngles( ):Up( ), self.Size, self.Size, Color( 255, 255, 255, self.Alpha ) )
	end

end
