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

local PANEL = {}

AccessorFunc( PANEL, "m_sText", "Text", FORCE_STRING )

function PANEL:Init()
	self:DockPadding( 0, 31, 0, 0 )
end

function PANEL:Think()
	local x,y
	if self.IsMoving then
		x = gui.MouseX() - self.LocalPos.x
		y = gui.MouseY() - self.LocalPos.y
		
		local _x, _y = x, y
		
		x = math.Clamp( x, 0, ScrW() - self:GetWide() )
		y = math.Clamp( y, 0, ScrH() - self:GetTall() )
		
		if _x ~= x then self.LocalPos.x = self.LocalPos.x - (x - _x) end
		if _y ~= y then self.LocalPos.y = self.LocalPos.y - (y - _y) end
		
		self:SetPos(x,y)
		self:SetCursor( "blank" )
		return
	end
	
	if ( self.Hovered ) then
		local x,y = self:CursorPos()
		if (y < 30 and y > 0) and (x < self:GetWide() and x > 0) then
			self:SetCursor( "sizeall" )
			return
		end
	end
	
	self:SetCursor( "arrow" )
end

function PANEL:OnMousePressed( m )
	if m == MOUSE_LEFT then
		local x,y = self:CursorPos()
		if (y < 30 and y > 0) and (x < self:GetWide() and x > 0) then
			self.IsMoving = true
			self.LocalPos = Vector2( x,y )
			self.EndPos = Vector2( x,y )
			self:MouseCapture( true )
			return
		end
	end
end

function PANEL:OnMouseReleased( m )
	if m == MOUSE_LEFT then
		if self.IsMoving then
			self.IsMoving = false
			self:MouseCapture( false )
			local x,y = self:GetPos()
			gui.SetMousePos(self.EndPos(x,y))
			self.LocalPos = Vector2( 0,0 )
			self.EndPos = Vector2( 0,0 )
			return
		end
	end
end

function PANEL:Paint( w, h )
	local w,h = self:GetSize( ) 
	
	surface.SetDrawColor( getSchemeColor(1) )
	surface.DrawRect( 0, 0, w, h )
	
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.SetMaterial( eaMaterial( "vgui/gradient_up" ) )
	surface.DrawTexturedRect( 0, h/2, w, h/2 )
	
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawOutlinedRect( 0, 0, w, h )
	
	surface.SetFont("Trebuchet22")
	
	surface.SetDrawColor( 0, 0, 0, 100 )
	surface.SetMaterial( eaMaterial( "vgui/gradient_down" ) )
	
	surface.DrawTexturedRect( 0, 0, w, 30 )
	
	surface.SetDrawColor( 0, 0, 0, 255 )
	surface.DrawOutlinedRect( 0, 0, w, h )
	surface.DrawLine( 0, 29, w, 29 )
	
	local Text = self:GetText() or ""
	local x,y = surface.GetTextSize( Text )
	
	surface.SetTextColor( 0, 0, 0, 255 )
	surface.SetTextPos( 10 - 1, 15 - ( y / 2 ) - 1 )
	surface.DrawText( Text )
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetTextPos( 10, 15 - ( y / 2 ) )
	surface.DrawText( Text )
end

function PANEL:ShowCloseButton( Bool )
	if Bool and !ValidPanel( self.btnClose ) then 
		self.btnClose = vgui.Create( "EA_CloseButton", self )
	elseif !Bool and ValidPanel( self.btnClose ) then 
		self.btnClose:Remove( ) 
	end
end


vgui.Register("EA_Frame", PANEL, "EditablePanel")