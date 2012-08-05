/*============================================================================================================================================
	Expression-Advanced Derma
==============================================================================================================================================
	Name: EA_CloseButton
	Author: Oskar 
============================================================================================================================================*/

local draw_SimpleText = draw.SimpleText

local PANEL = {}

function PANEL:Init()
	self:SetWide( 30 )
end

function PANEL:Paint( ) local size = 32,32
	local w,h = self:GetSize()
	local x,y = w/2-size/2+4, h/2-size/2+4
	surface.SetDrawColor( 255,255,255,255 )
	surface.SetMaterial( eaMaterial( "fugue/24/cross-circle" ) )

	surface.DrawTexturedRect( x, y, size, size )

	surface.SetDrawColor( 0, 0, 0, 0 )
	if self.Hovered then surface.SetDrawColor( 0, 0, 0, 50 ) end
	if self.Depressed then surface.SetDrawColor( 0, 0, 0, 100 ) end

	surface.DrawTexturedRect( x, y, size, size )
end 

function PANEL:DoClick( )
	if ( self:GetParent( ) ) then
		if self:GetParent( ).Close then 
			self:GetParent( ):Close( )
		else
			self:GetParent( ):Remove( )
		end
	end
end

function PANEL:Think( )
	if ( self:GetParent() ) then
		local x = self:GetParent( ):GetWide( ) - self:GetWide( )
		self:SetPos( x, 0 )
	end
end

vgui.Register( "EA_CloseButton", PANEL, "EA_Button" )
