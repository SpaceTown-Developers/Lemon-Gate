/*============================================================================================================================================
	Expression-Advanced Derma
==============================================================================================================================================
	Name: EA_FileNode
	Author: Oskar 
============================================================================================================================================*/

local plus = Material( "fugue/toggle-small-expand.png" )
local minus = Material( "fugue/toggle-small.png" )

local PANEL = {} 

function PANEL:Init()
	self.Label:SetTextColor( Color( 255, 255, 255 ) ) 
	self:SetIcon( "fugue/blue-folder-horizontal.png" )
	
	local exp = self.SetExpanded
	
	function self:SetExpanded( bExpand, bSurpressAnimation )
		exp( self, bExpand, bSurpressAnimation )
		if self:GetIcon( ) == "fugue/blue-folder-horizontal.png" and self.m_bExpanded then 
			self:SetIcon( "fugue/blue-folder-horizontal-open.png" )
		elseif self:GetIcon( ) == "fugue/blue-folder-horizontal-open.png" and !self.m_bExpanded then 
			self:SetIcon( "fugue/blue-folder-horizontal.png" )
		end 
	end
	
	function self.Expander:Paint( w, h )
		if self.m_bExpanded then 
			surface.SetMaterial( minus )
		else 
			surface.SetMaterial( plus ) 
		end 
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( 0, 0, w, h )
	end
end

function PANEL:AddNode( strName, strIcon )
	self:CreateChildNodes()
	
	local pNode = vgui.Create( "EA_FileNode", self )
		pNode:SetText( strName )
		pNode:SetParentNode( self )
		pNode:SetRoot( self:GetRoot() )
		pNode:SetIcon( strIcon )
		pNode:SetDrawLines( !self:IsRootNode( ) )
		
		self:InstallDraggable( pNode )			
	
	self.ChildNodes:Add( pNode )
	self:InvalidateLayout( )
	
	return pNode
end

function PANEL:AddFolder( strName, strFolder, strPath, bShowFiles, strWildCard, bDontForceExpandable, strIcon )
	local node = self:AddNode( strName )
	node:MakeFolder( strFolder, strPath, bShowFiles, strWildCard, bDontForceExpandable, strIcon )
	return node
end

function PANEL:MakeFolder( strFolder, strPath, bShowFiles, strWildCard, bDontForceExpandable, strIcon )
	strWildCard = strWildCard or "*"
	
	-- Store the data
	self:SetNeedsPopulating( true )
	self:SetWildCard( strWildCard )
	self:SetFolder( strFolder )
	self:SetPathID( strPath )
	self:SetShowFiles( bShowFiles or false )
	self.strChildIcon = strIcon 
	
	self:CreateChildNodes( )
	self:SetNeedsChildSearch( true )
	
	if !bDontForceExpandable then
		self:SetForceShowExpander( true )
	end
end

function PANEL:FilePopulateCallback( files, folders, foldername, path, bAndChildren )
	local showfiles = self:GetShowFiles( )
	
	self.ChildNodes:InvalidateLayout( true )
	
	local FileCount = 0
	
	if folders then
		for k, File in SortedPairsByValue( folders ) do
			local Node = self:AddNode( File )
			Node:MakeFolder( foldername .. "/" .. File, path, showfiles, wildcard, true, self.strChildIcon )
			FileCount = FileCount + 1
		end
	end
	
	if showfiles then
		for k, File in SortedPairs( files ) do
			local icon = self.strChildIcon or "icon16/page_white.png"
			
			local Node = self:AddNode( File, icon )
			Node:SetFileName( foldername .. "/" .. File )
			FileCount = FileCount + 1
		end
	end
	
	if FileCount == 0 then
		self.ChildNodes:Remove( )
		self.ChildNodes = nil
		
		self:SetNeedsPopulating( false )
		self:SetShowFiles( nil )
		self:SetWildCard( nil )
		
		self:InvalidateLayout( )
		
		self.Expander:SetExpanded( true )
	return end
	
	self:InvalidateLayout( )
end

vgui.Register( "EA_FileNode", PANEL, "DTree_Node" ) 