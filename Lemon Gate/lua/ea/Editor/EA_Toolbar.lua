/*============================================================================================================================================ 
	Expression-Advanced Derma 
============================================================================================================================================== 
	Name: EA_ToolBar 
	Author: Oskar 
============================================================================================================================================*/ 

local PANEL = {} 

function PANEL:Init() 
	self.btnSave = vgui.Create( "EA_Button", self ) 
	self.btnSave:Dock( LEFT ) 
	self.btnSave:DockMargin( 3,3,3,3 ) 
	self.btnSave:SetText( "Save" ) 
	self.btnSave:SetFont( "Trebuchet18" ) 
	self.btnSave:SetColorScheme( 4 ) 
	self.btnSave:SizeToContentsX() 

	function self.btnSave:DoClick()
		self:GetParent():GetParent():SaveFile( self:GetParent():GetParent().File ) 
	end 


	self.btnSaveAs = vgui.Create( "EA_Button", self ) 
	self.btnSaveAs:Dock( LEFT ) 
	self.btnSaveAs:DockMargin( 0,3,3,3 ) 
	self.btnSaveAs:SetText( "Save As" ) 
	self.btnSaveAs:SetFont( "Trebuchet18" ) 
	self.btnSaveAs:SetColorScheme( 4 ) 
	self.btnSaveAs:SizeToContentsX() 

	function self.btnSaveAs:DoClick()
		self:GetParent():GetParent():SaveFile( self:GetParent():GetParent().File, true ) 
	end 


	self.btnScheme = vgui.Create( "EA_Button", self ) 
	self.btnScheme:Dock( RIGHT ) 
	self.btnScheme:DockMargin( 3,3,3,3 ) 
	self.btnScheme:SetText( "Switch color scheme" ) 
	self.btnScheme:SetFont( "Trebuchet18" ) 
	self.btnScheme:SetColorScheme( 4 ) 
	self.btnScheme:SizeToContentsX() 
	self.btnScheme.State = 1

	function self.btnScheme:DoClick()
		if self.State == 1 then 
			setScheme( "green") 
			self.State = 2
		elseif self.State == 2 then 
			setScheme( "red") 
			self.State = 3
		elseif self.State == 3 then 
			setScheme( "blue") 
			self.State = 1
		end
	end 
end 

function PANEL:Paint() 
	local w,h = self:GetSize() 

	surface.SetDrawColor( getSchemeColor(4) ) 
	surface.DrawRect( 0,0,w,h ) 
end 

vgui.Register( "EA_ToolBar", PANEL, "Panel" )
