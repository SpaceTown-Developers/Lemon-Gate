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

local SetSize = debug.getregistry( ).Panel.SetSize 

local PANEL = {}

AccessorFunc( PANEL, "m_sText", 		"Text", FORCE_STRING )
AccessorFunc( PANEL, "m_bSizable", 		"Sizable", FORCE_BOOL )
AccessorFunc( PANEL, "m_bScreenLock", 	"ScreenLock", FORCE_BOOL )

AccessorFunc( PANEL, "m_iMinWidth", 	"MinWidth" )
AccessorFunc( PANEL, "m_iMinHeight", 	"MinHeight" )

function PANEL:Init()
	self.LastClick = 0
	
	self:DockPadding( 0, 26, 0, 0 )
	self:ShowCloseButton( true )
	self:SetSizable( false )
	self:SetMinWidth( 400 )
	self:SetMinHeight( 400 )
end

function PANEL:SetMaximized( Bool )
	if !self:GetSizable( ) then return end
	
	if Bool ~= nil then
		if Bool then
			self.LastPos = Vector2( self:GetPos( ) )
			self:SetPos( 0, 0 )
			self:SetSize( ScrW( ), ScrH( ), true )
			self.IsMaximized = true
		else
			self:SetSize( self.RealSize.x, self.RealSize.y, true )
			self:SetPos( self.LastPos( ) )
			self.IsMaximized = false
		end
	else
		if self.IsMaximized == true then
			self:SetSize( self.RealSize.x, self.RealSize.y, true )
			self:SetPos( self.LastPos( ) )
			self.IsMaximized = false
		else
			self.LastPos = Vector2( self:GetPos( ) )
			self:SetPos( 0, 0 )
			self:SetSize( ScrW( ), ScrH( ), true )
			self.IsMaximized = true
		end
	end
end

function PANEL:SetSize( w, h, bool )
	SetSize( self, w, h )
	
	if not bool then
		self.RealSize = Vector2( w, h )
	end
end

function PANEL:SetWide( n, bool )
	SetSize( self, n, self:GetTall( ) )
	
	if not bool then 
		self.RealSize.x = n
	end 
end

function PANEL:SetTall( n, bool )
	SetSize( self, self:GetWide( ), n )
	
	if not bool then 
		self.RealSize.y = n
	end
end

function PANEL:Think( )
	if self.IsMoving then
		self:SetCursor( "blank" )
		return
	end
	
	if self.Sizing then 
		if self.Sizing[1] and not self.Sizing[2] then 
			self:SetCursor( "sizewe" ) 
		elseif self.Sizing[2] and not self.Sizing[1] then 
			self:SetCursor( "sizens" ) 
		else 
			self:SetCursor( "sizenwse" ) 
		end 
		
		return 
	end 
	
	if self.Hovered and not self.IsMaximized then
		local x, y = self:CursorPos( )
		if y < 25 and y > 0 and x < self:GetWide( ) and x > 0 then
			self:SetCursor( "sizeall" )
			return
		end
		
		if self.m_bSizable then 
			if x > self:GetWide( ) - 20 and y > self:GetTall( ) - 20 then 
				self:SetCursor( "sizenwse" )
				return 
			end 
			
			if x > self:GetWide( ) - 20  then 
				self:SetCursor( "sizewe" )
				return
			end 
			
			if y > self:GetTall( ) - 20 then 
				self:SetCursor( "sizens" )
				return
			end 
		end 
	end
	
	self:SetCursor( "arrow" )
end

function PANEL:OnCursorMoved( x, y )
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
		
		return true
	end
	
	if self.Sizing then
		if self.Sizing[1] then 
			self:SetWide( x )
		
			x = self:LocalToScreen( x, 0 ) 
			if x > ScrW( ) then 
				self:SetWide( ScrW( ) - self.x ) 
				x = ScrW( ) - self.x
			end 
			if x < self.m_iMinWidth then self:SetWide( self.m_iMinWidth ) end 
		end 
		
		if self.Sizing[2] then 
			self:SetTall( y )
		
			_, y = self:LocalToScreen( 0, y ) 
			if y > ScrH( ) then 
				self:SetTall( ScrH( ) - self.y ) 
				y = ScrH( ) - self.y
			end 
			if y < self.m_iMinHeight then self:SetTall( self.m_iMinHeight ) end 
		end 
		
		return true 
	end
end

function PANEL:OnMousePressed( m ) 
	if m == MOUSE_LEFT then 
		local x, y = self:CursorPos( ) 
		if y < 25 and y > 0 and x < self:GetWide( ) and x > 0 then 
			if self.LastClick + 0.2 > CurTime( ) then
				self:SetMaximized( )
				self.LastClick = CurTime()
				return
			end
			self.LastClick = CurTime()
			
			if not self.IsMaximized then 
				self.IsMoving = true 
				self.LocalPos = Vector2( x, y ) 
				self.EndPos = Vector2( x, y ) 
				self:MouseCapture( true ) 
				return 
			end 
		end 
		
		if self.m_bSizable and not self.IsMaximized then
			if x > self:GetWide( ) - 20 and y > self:GetTall( ) - 20 then            
				self.Sizing = { true, true }
				self:MouseCapture( true ) 
				return
			end
			
			if y < self:GetTall( ) and y > 0 and x < self:GetWide( ) and x > self:GetWide( ) - 20 then
				self.Sizing = { true, false }
				self:MouseCapture( true )
				return
			end
			
			if y < self:GetTall( ) and y > self:GetTall( ) - 20 and x < self:GetWide( ) and x > 0 then
				self.Sizing = { false, true }
				self:MouseCapture( true )
				return
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