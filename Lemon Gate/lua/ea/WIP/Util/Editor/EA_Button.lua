/*============================================================================================================================================
	Expression-Advanced Derma
==============================================================================================================================================
	Name: EA_Button
	Author: Oskar 
============================================================================================================================================*/

local surface = surface 
local math = math 

local math_Clamp = math.Clamp

local PANEL = {}

AccessorFunc( PANEL, "m_tColor", "Color" )
AccessorFunc( PANEL, "m_tTextColor", "TextColor" )
AccessorFunc( PANEL, "m_sFont", "Font", FORCE_STRING )
AccessorFunc( PANEL, "m_bOutline", "Outlined", FORCE_BOOL )

function PANEL:Init( )
	self:SetSize( 25, 30 )

	self:SetFont"Trebuchet22" 
	self:SetText""
	self:SetColor( Color( 0,0,0 ) ) 
	self:SetOutlined( false )
end

function PANEL:ApplySchemeSettings() end

function PANEL:SetColorScheme( idx )
	self.Scheme = tonumber(idx)
end

function PANEL:SizeToContents() 
	surface.SetFont( self:GetFont() ) 
	local Text = self:GetText() 
	local w, h = surface.GetTextSize( Text )
	self:SetSize( w, h )
end 

function PANEL:SizeToContentsX() 
	surface.SetFont( self:GetFont() ) 
	local Text = self:GetText() 
	local w, h = surface.GetTextSize( Text ) 
	self:SetWide( w+10 )
end 

function PANEL:SizeToContentsY() 
	surface.SetFont( self:GetFont() ) 
	local Text = self:GetText() 
	local w, h = surface.GetTextSize( Text )
	self:SetTall( h )
end 

function PANEL:Paint( )
	local w,h = self:GetSize()
	
	if self.Scheme then surface.SetDrawColor( getSchemeColor( self.Scheme ) ) 
	else surface.SetDrawColor( self:GetColor() ) 
	end 
	surface.DrawRect( 0, 0, w, h )
	
	surface.SetDrawColor( 0, 0, 0, 0 )
	if self.Hovered then surface.SetDrawColor( 0, 0, 0, 50 ) end
	if self.Depressed then surface.SetDrawColor( 0, 0, 0, 100 ) end
	surface.DrawRect( 0, 0, w, h )
	
	if self:GetOutlined() then 
		surface.SetDrawColor( 0, 0, 0, 255 ) 
		surface.DrawOutlinedRect( 0, 0, w, h )  
	end 

	surface.SetFont( self:GetFont() ) 
	local Text = self:GetText() 
	local tw, th = surface.GetTextSize( Text ) 
	local x, y = math.floor( w / 2 ) - math.floor( tw / 2 ), math.floor( h / 2 ) - math.floor( th / 2 )
	
	surface.SetTextColor( getSchemeColor( 7 ) or Color( 0, 0, 0 ) )  

	surface.SetTextPos( 4, y )
	surface.DrawText( Text )

	surface.SetTextPos( 6, y )
	surface.DrawText( Text )

	surface.SetTextPos( 5, y - 1 )
	surface.DrawText( Text )

	surface.SetTextPos( 5, y + 1 )
	surface.DrawText( Text )

	surface.SetTextColor( getSchemeColor( 6 ) or Color( 255, 255, 255 ) )  
	surface.SetTextPos( 5, y )
	surface.DrawText( Text )

	return true
end

vgui.Register( "EA_Button", PANEL, "DButton" )
