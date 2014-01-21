/*============================================================================================================================================
	Expression-Advanced Derma
==============================================================================================================================================
	Name: EA_Browser
	Author: Oskar 
============================================================================================================================================*/

local gradient_down = Material( "vgui/gradient-u" )

local PANEL = {}

function PANEL:Init( )
	ErrorNoHalt( "EA_FILEBROWSER is obsolete, this should not happen." )
	
	self.Items = { }
	
	self.Browser = self:Add( "DTree" )
	self.Browser:Dock( FILL )
	
	self.Browser.Paint = function( ) return true end 
	self.Browser.DoRightClick = function( _, Node ) return self:DoRightClick( Node ) end 
	self.Browser.DoClick = function( _, Node ) 
		if Node.LastClick and CurTime( ) - Node.LastClick < 0.5 then 
			Node.LastClick = 0
			return self:DoDoubleClick( Node ) 
		end 
		Node.LastClick = CurTime( ) 
		return self:DoClick( Node )
	end 
	
	self.Browser.RootNode:Remove( ) 
	self.Browser.RootNode = self.Browser:GetCanvas( ):Add( "EA_FileNode" )
	self.Browser.RootNode:SetRoot( self.Browser )
	self.Browser.RootNode:SetParentNode( self.Browser )
	self.Browser.RootNode:Dock( TOP )
	self.Browser.RootNode:SetText( "" )
	self.Browser.RootNode:SetExpanded( true, true )
	self.Browser.RootNode:DockMargin( 0, 4, 0, 0 )
end

function PANEL:Clear( ) 
	self.Browser:Remove( ) 
	self.Browser = self:Add( "DTree" )
	self.Browser:Dock( FILL )
	
	self.Browser.Paint = function( ) return true end 
	self.Browser.DoRightClick = function( _, Node ) return self:DoRightClick( Node ) end 
	self.Browser.DoClick = function( _, Node ) 
		if Node.LastClick and CurTime( ) - Node.LastClick < 0.5 then 
			Node.LastClick = 0
			return self:DoDoubleClick( Node ) 
		end 
		Node.LastClick = CurTime( ) 
		return self:DoClick( Node )
	end 
	
	self.Browser.RootNode:Remove( ) 
	self.Browser.RootNode = self.Browser:GetCanvas( ):Add( "EA_FileNode" )
	self.Browser.RootNode:SetRoot( self.Browser )
	self.Browser.RootNode:SetParentNode( self.Browser )
	self.Browser.RootNode:Dock( TOP )
	self.Browser.RootNode:SetText( "" )
	self.Browser.RootNode:SetExpanded( true, true )
	self.Browser.RootNode:DockMargin( 0, 4, 0, 0 )
end 

function PANEL:Root( )
	return self.Browser:Root( ) 
end

function PANEL:AddNode( strName, strIcon )
	return self.Browser.RootNode:AddNode( strName, strIcon ) 
end

// Overrides 
function PANEL:DoClick( Node ) return false end 
function PANEL:DoDoubleClick( Node ) return false end 
function PANEL:DoRightClick( Node ) return false end 

function PANEL:Paint( w, h )
	surface.SetDrawColor( 100, 100, 100, 255 )
	surface.DrawRect( 0, 0, w, h )
	
	surface.SetDrawColor( 75, 75, 75 )
	surface.SetMaterial( gradient_down )
	surface.DrawTexturedRect( 0, 0, w, h )
	
	surface.SetDrawColor( 0, 0, 0 ) 
	surface.DrawOutlinedRect( 0, 0, w, h )
	return true 
end

vgui.Register( "EA_Browser", PANEL, "EditablePanel" ) 