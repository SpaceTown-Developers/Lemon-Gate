/*============================================================================================================================================
	Expression-Advanced Derma
==============================================================================================================================================
	Name: EA_ImageButton
	Author: Oskar 
============================================================================================================================================*/

local gradient_down = Material( "vgui/gradient-u" )

local PANEL = {}

AccessorFunc( PANEL, "m_Material", 			"Material" )
AccessorFunc( PANEL, "m_nPadding", 			"Padding" )

AccessorFunc( PANEL, "m_bIconFading", 		"IconFading", FORCE_BOOL )
AccessorFunc( PANEL, "m_bIconCentered", 	"IconCentered", FORCE_BOOL )

function PANEL:Init( )
	self:SetText( "" )
	self:SetPadding( 0 )
	self:SetIconFading( true )
	self:SetTextCentered( false )
	self:SetIconCentered( false )
end

function PANEL:DrawButton( bool )
	self.m_bDrawButton = bool 
end

function PANEL:SetMaterial( mat )
	if type( mat ) != "IMaterial" or mat:IsError( ) then return end // TODO: Fling some shit here 
	self.m_Material = mat
	self:SizeToContents( )
end 

function PANEL:SizeToContents( ) 
	local w, h = 0, 0 
	if self.m_Material then 
		w, h = self.m_Material:Width( ) + self.m_nPadding * 2, self.m_Material:Height( ) + self.m_nPadding * 2
	end
	
	if self.m_bDrawButton then 
		surface.SetFont( self:GetFont() ) 
		local Text = self:GetText() 
		local x, y = surface.GetTextSize( Text )
		if x > 0 then 
			w = w + x + self.m_nPadding * ( self.m_Material and 1 or 2 ) 
			h = math.max( h, y + 10 )
		end 
	end 
	
	self:SetSize( w, h )
end 

function PANEL:SizeToContentsX( ) 
	local w = 0 
	if self.m_Material then 
		w = self.m_Material:Width( ) + self.m_nPadding * 2 
	end
	
	if self.m_bDrawButton then 
		surface.SetFont( self:GetFont( ) ) 
		local Text = self:GetText( ) 
		local x = surface.GetTextSize( Text )
		if x > 0 then 
			w = w + x + self.m_nPadding * ( self.m_Material and 1 or 2 ) 
		end 
	end 
	
	self:SetWide( w )
end 

function PANEL:SizeToContentsY( )
	local h = 0 
	if self.m_Material then 
		h = self.m_Material:Height( ) + self.m_nPadding * 2
	end
	
	if self.m_bDrawButton then 
		surface.SetFont( self:GetFont( ) ) 
		local Text = self:GetText( ) 
		local _, y = surface.GetTextSize( Text )
		h = math.max( h, y + 10 )
	end 
	
	self:SetTall( h )
end 

local function PaintButton( self, w, h )
	surface.SetDrawColor( self:GetColor( ) )
	surface.DrawRect( 0, 0, w, h )
	
	surface.SetDrawColor( 200, 200, 200, 100 )
	surface.SetMaterial( gradient_down )
	surface.DrawTexturedRect( 0, 0, w, h )
	
	if self:GetFading( ) then 
		surface.SetDrawColor( 0, 0, 0, 0 )
		if self.Hovered then surface.SetDrawColor( 0, 0, 0, 100 ) end 
		if self.Depressed then surface.SetDrawColor( 0, 0, 0, 150 ) end 
		surface.DrawRect( 0, 0, w, h )
	end 
	
	if self:GetOutlined( ) then 
		surface.SetDrawColor( 0, 0, 0, 255 ) 
		surface.DrawOutlinedRect( 0, 0, w, h )  
	end 
	
	surface.SetFont( self:GetFont( ) ) 
	local Text = self:GetText( ) 
	local tw, th = surface.GetTextSize( Text ) 
	local x, y = math.floor( w / 2 ) - math.floor( tw / 2 ), math.floor( h / 2 ) - math.floor( th / 2 )
	
	if !self.m_bTextCentered then x = 5 end 
	
	if self.m_Material then x = x + self.m_Material:Width( ) + self.m_nPadding end 
	
	if self:GetTextShadow( ) then 
		surface.SetTextColor( self:GetTextShadow( ) ) 
		
		for _x = -1, 1 do
			for _y = -1, 1 do
				surface.SetTextPos( x + _x, y + _y )
				surface.DrawText( Text )
			end
		end
	end 
	
	surface.SetTextColor( self:GetTextColor( ) ) 
	surface.SetTextPos( x, y )
	surface.DrawText( Text )
end

function PANEL:Paint( w, h ) 
	if self.m_bDrawButton then PaintButton( self, w, h ) end 
	
	if self.m_Material then 
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( self.m_Material )
		
		local n = math.max( self.m_Material:Width( ), self.m_Material:Height( ) )
		local x, y = w/2 - n/2, h/2 - n/2
		
		if !self.m_bIconCentered then x = self.m_nPadding end 
		
		surface.DrawTexturedRect( x, y, n, n )
		
		if self:GetIconFading( ) then 
			surface.SetDrawColor( 0, 0, 0, 0 )
			if self.Hovered then surface.SetDrawColor( 0, 0, 0, 50 ) end
			if self.Depressed then surface.SetDrawColor( 0, 0, 0, 100 ) end
		end 
		
		surface.DrawTexturedRect( x, y, n, n )
	end 
	
	return true 
end 

vgui.Register( "EA_ImageButton", PANEL, "EA_Button" )
