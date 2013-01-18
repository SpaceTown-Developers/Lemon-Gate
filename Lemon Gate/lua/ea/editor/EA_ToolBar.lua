/*============================================================================================================================================ 
	Expression-Advanced Derma 
============================================================================================================================================== 
	Name: EA_ToolBar 
	Author: Oskar 
============================================================================================================================================*/ 

local gradient_up = Material( "vgui/gradient-d" )
local gradient_down = Material( "vgui/gradient-u" )

local PANEL = {} 

function PANEL:Init() 
	self.btnSave = self:Add( "EA_ImageButton" ) 
	self.btnSave:Dock( LEFT ) 
	self.btnSave:SetPadding( 5 ) 
	self.btnSave:SetIconFading( false )
	self.btnSave:SetIconCentered( false )
	self.btnSave:SetTextCentered( false )
	self.btnSave:DrawButton( true )
	self.btnSave:SetTooltip( "Save" ) 
	self.btnSave:SetMaterial( Material( "fugue/disk.png" ) )
	
	self.btnSaveAs = self:Add( "EA_ImageButton" ) 
	self.btnSaveAs:Dock( LEFT ) 
	self.btnSaveAs:SetPadding( 5 ) 
	self.btnSaveAs:SetIconFading( false )
	self.btnSaveAs:SetIconCentered( false )
	self.btnSaveAs:SetTextCentered( false )
	self.btnSaveAs:DrawButton( true )
	self.btnSaveAs:SetTooltip( "Save As" ) 
	self.btnSaveAs:SetMaterial( Material( "fugue/disks.png" ) )
	
	self.btnNewTab = self:Add( "EA_ImageButton" ) 
	self.btnNewTab:Dock( LEFT )  
	self.btnNewTab:SetPadding( 5 ) 
	self.btnNewTab:SetIconFading( false )
	self.btnNewTab:SetIconCentered( false )
	self.btnNewTab:SetTextCentered( false )
	self.btnNewTab:DrawButton( true )
	self.btnNewTab:SetTooltip( "New tab" )
	self.btnNewTab:SetMaterial( Material( "fugue/script--plus.png" ) )
	
	self.btnCloseTab = self:Add( "EA_ImageButton" ) 
	self.btnCloseTab:Dock( LEFT )  
	self.btnCloseTab:SetPadding( 5 ) 
	self.btnCloseTab:SetIconFading( false )
	self.btnCloseTab:SetIconCentered( false )
	self.btnCloseTab:SetTextCentered( false )
	self.btnCloseTab:DrawButton( true )
	self.btnCloseTab:SetTooltip( "Close tab" )
	self.btnCloseTab:SetMaterial( Material( "fugue/script--minus.png" ) )
	
	/*self.btnCloseAll = self:Add( "EA_ImageButton" ) 
	self.btnCloseAll:Dock( LEFT )  
	self.btnCloseAll:SetPadding( 5 ) 
	self.btnCloseAll:SetIconFading( false )
	self.btnCloseAll:SetIconCentered( false )
	self.btnCloseAll:SetTextCentered( false )
	self.btnCloseAll:DrawButton( true )
	-- self.btnCloseAll:SetText( "Close all tabs" )
	self.btnCloseAll:SetTooltip( "Close all tabs" )
	self.btnCloseAll:SetMaterial( Material( "fugue/script--minus.png" ) )*/
	
	self.btnOptions = self:Add( "EA_ImageButton" ) 
	self.btnOptions:Dock( RIGHT )  
	self.btnOptions:SetPadding( 5 ) 
	self.btnOptions:SetIconFading( false )
	self.btnOptions:SetIconCentered( false )
	self.btnOptions:SetTextCentered( false )
	self.btnOptions:DrawButton( true )
	self.btnOptions:SetTooltip( "Options" )
	self.btnOptions:SetMaterial( Material( "fugue/gear.png" ) )
	
	self.btnHelp = self:Add( "EA_ImageButton" ) 
	self.btnHelp:Dock( RIGHT )  
	self.btnHelp:SetPadding( 5 ) 
	self.btnHelp:SetIconFading( false )
	self.btnHelp:SetIconCentered( false )
	self.btnHelp:SetTextCentered( false )
	self.btnHelp:DrawButton( true )
	self.btnHelp:SetTooltip( "Help" )
	self.btnHelp:SetMaterial( Material( "fugue/question.png" ) )
	
	function self.btnSave:DoClick()
		self:GetParent():GetParent():SaveFile( ) 
	end 
	
	function self.btnSaveAs:DoClick()
		self:GetParent():GetParent():SaveFile( nil, true ) 
	end 
	
	function self.btnNewTab:DoClick()
		self:GetParent():GetParent():NewTab() 
	end 
	
	function self.btnCloseTab:DoClick()
		self:GetParent():GetParent():CloseTab() 
	end 
	
	/*function self.btnCloseAll:DoClick()
		self:GetParent():GetParent():CloseAll() 
	end*/
end 

function PANEL:Paint( w, h ) 
	surface.SetDrawColor( self.btnSave:GetColor() )
	surface.DrawRect( 0, 0, w, h )
	
	surface.SetDrawColor( 200, 200, 200, 100 )
	surface.SetMaterial( gradient_down )
	surface.DrawTexturedRect( 0, 0, w, h )
end 

vgui.Register( "EA_ToolBar", PANEL, "Panel" )
