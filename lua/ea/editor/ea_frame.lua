/*============================================================================================================================================
	Expression-Advanced Derma
==============================================================================================================================================
	Name: EA_Frame
	Author: Oskar 
============================================================================================================================================*/

local ValidPanel = ValidPanel 
local surface = surface 
local gui = gui 
local math = math 

local gradient_up = Material( "vgui/gradient-d" )
local gradient_down = Material( "vgui/gradient-u" )

local PANEL = {}

AccessorFunc( PANEL, "m_sText", 		"Text", FORCE_STRING )
AccessorFunc( PANEL, "m_bSizable", 		"Sizable", FORCE_BOOL )
AccessorFunc( PANEL, "m_bScreenLock", 	"ScreenLock", FORCE_BOOL )

AccessorFunc( PANEL, "m_iMinWidth", 	"MinWidth" )
AccessorFunc( PANEL, "m_iMinHeight", 	"MinHeight" )


function PANEL:Init()
	self:DockPadding( 0, 26, 0, 0 )
	self:ShowCloseButton( true )
	self:SetSizable( false )
	self:SetMinWidth( 400 )
	self:SetMinHeight( 400 )
end

function PANEL:Think( )
	local x,y
	if self.IsMoving then
		local _x, _y = ( Vector2( gui.MousePos( ) ) - self.LocalPos )( )
		
		if self.m_bScreenLock then 
			x = math.Clamp( _x, 0, ScrW( ) - self:GetWide( ) )
			y = math.Clamp( _y, 0, ScrH( ) - self:GetTall( ) )
			
			self.LocalPos:Sub( x - _x, y - _y )
			
			self:SetPos( x, y )
		else 
			self:SetPos( _x, _y )
		end 
		
		self:SetCursor( "blank" )
		return
	end
	
	if self.Sizing then 
		self:SetSize( self:CursorPos( ) )
		
		x, y = self:LocalToScreen( self:GetSize( ) ) 
		if x > ScrW( ) then self:SetWide( ScrW( ) - self.x ) end 
		if y > ScrH( ) then self:SetTall( ScrH( ) - self.y ) end 
		
		x, y = self:GetSize( ) 
		if x < self.m_iMinWidth then self:SetWide( self.m_iMinWidth ) end 
		if y < self.m_iMinHeight then self:SetTall( self.m_iMinHeight ) end 
		
		self:SetCursor( "sizenwse" )
		return
	end 
	
	if self.Hovered then
		local x,y = self:CursorPos( )
		if y < 25 and y > 0 and x < self:GetWide( ) and x > 0 then
			self:SetCursor( "sizeall" )
			return
		end
		
		if self.m_bSizable then 
			local x, y = self:CursorPos( ) 
			if x > self:GetWide( ) - 20 and y > self:GetTall( ) - 20 then 
				self:SetCursor( "sizenwse" )
				return 
			end 
		end 
	end
	
	self:SetCursor( "arrow" )
end

function PANEL:OnMousePressed( m ) 
	if m == MOUSE_LEFT then 
		local x, y = self:CursorPos( ) 
		if y < 25 and y > 0 and x < self:GetWide( ) and x > 0 then 
			self.IsMoving = true 
			self.LocalPos = Vector2( x, y ) 
			self.EndPos = Vector2( x, y ) 
			self:MouseCapture( true ) 
			return 
		end 
		if self.m_bSizable then 
			if x > self:GetWide( ) - 20 and y > self:GetTall( ) - 20 then 
				self.Sizing = true 
				self:MouseCapture( true ) 
			end 
		end 
	end 
end 

function PANEL:OnMouseReleased( m )
	if m == MOUSE_LEFT then
		if self.IsMoving then
			self.IsMoving = false
			self:MouseCapture( false )
			local x,y = self:GetPos( )
			gui.SetMousePos( self.EndPos( x, y ) )
			self.LocalPos = Vector2( 0, 0 )
			self.EndPos = Vector2( 0, 0 )
			self:SetCursor( "sizeall" )
			return
		end
		
		if self.m_bSizable then
			self.Sizing = false
			self:MouseCapture( false )
		end 
	end
end

function PANEL:Paint( w, h ) 
	surface.SetDrawColor( 90, 90, 90, 255 )
	surface.DrawRect( 0, 0, w, h )
	
	surface.SetDrawColor( 60, 60, 60, 255 )
		surface.SetMaterial( gradient_up )
		surface.DrawTexturedRect( 0, 0, w, 25 )
		surface.DrawTexturedRect( 0, h/2, w, h/2 )
		
		surface.SetMaterial( gradient_down )
		surface.DrawTexturedRect( 0, 25, w, h/2 )
	
	
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawOutlinedRect( 0, 0, w, h ) 
	surface.DrawLine( 0, 25, w, 25 )
	
	surface.SetFont( "Trebuchet22" )
	local Text = self:GetText() or ""
	local x,y = surface.GetTextSize( Text )
	
	surface.SetTextColor( 220, 220, 220, 255 )
	surface.SetTextPos( 5, 12.5 - y / 2 )
	surface.DrawText( Text )
end

function PANEL:ShowCloseButton( Bool )
	if Bool and !ValidPanel( self.btnClose ) then 
		self.btnClose = self:Add( "EA_CloseButton" )
		self.btnClose:SetOffset( -5, 5 )
	elseif !Bool and ValidPanel( self.btnClose ) then 
		self.btnClose:Remove( ) 
	end
end


vgui.Register( "EA_Frame", PANEL, "EditablePanel" )