/*============================================================================================================================================
	Expression-Advanced Derma
==============================================================================================================================================
	Name: EA_FileBrowser
	Author: Oskar 
============================================================================================================================================*/

local PANEL = {} 

function PANEL:Init() 
	self:DockPadding( 0, 31, 0, 0 ) 

	self.PanelMenu = {}
	self.FolderMenu = {}
	self.FileMenu = {}
	
	self.Items = {}
	
	self.Ref = vgui.Create( "DButton", self )
	self.Ref:Dock( BOTTOM )
	self.Ref:DockMargin( 0,0,0,-1 )
	self.Ref:SetTall( 20 )
	self.Ref:SetText( "Update" )
	self.Ref.DoClick = function() 
		self:Update() 
	end 
end 

function PANEL:Setup( basefolder )
	self.BaseDir = basefolder or ""
	self:Update()
end

local function InternalDoClick( node )
	node:GetRoot():SetSelectedItem( node )
	if node:DoClick() then return end
	if node:GetRoot():DoClick( node ) then return end
end

local function InternalDoRightClick( node )
	node:GetRoot():SetSelectedItem( node )
	if node:DoRightClick() then return end
	if node:GetRoot():DoRightClick( node ) then return end
end

local function FineName( name )
	local name = string.Replace( name, ".txt", "" )
	return string.Replace( name, "/", "" )
end

local function sortlower( a,b )
	return string.lower( a ) < string.lower( b )
end

function PANEL.SetupFolderNode( self, fPath, fName )
	local pNode = self:AddNode( fName )
	pNode.IsFile = false 
	pNode.FileDir = fPath
	pNode.Name = fName

	pNode.Icon:SetImage( "fugue/blue-folder-horizontal" )
	pNode.InternalDoClick = InternalDoClick
	pNode.InternalDoRightClick = InternalDoRightClick

	PANEL:AllowExpanding( pNode, false )

	pNode.Folder = pNode:AddNode( "" )
	pNode.Folder:SetVisible( false )
	pNode.Folder:SetMouseInputEnabled( false )
end

function PANEL.SetupFileNode( self, fPath, fName )
	local pNode = self:AddNode( FineName( fName ) )
	pNode.IsFile = true 
	pNode.FileDir = fPath
	pNode.Name = FineName( fName )

	pNode.Icon:SetImage( "fugue/script-text" )
	pNode.InternalDoClick = InternalDoClick
	pNode.InternalDoRightClick = InternalDoRightClick
end

local MaxPerTick = 10
local timername = "SetupFolderTree"
local function SetupFolderTree( node, dir )
	if ltype( dir ) ~= "string" or not IsValid( node ) or timer.Exists( timername ) then return end

	node:Clear( true )
	node.ChildNodes = nil

	local _, files = file.Find( dir .. "/*", "DATA" )
	local tFiles = file.Find( dir .. "/*.txt", "DATA" )

	table.sort( files, sortlower )
	table.sort( tFiles, sortlower )
	table.Add( files, tFiles )

	local TCount = #files
	local TableCount = TCount / MaxPerTick
	local AddedItems = {}
	local Timervalue = -(MaxPerTick - 1)

	if (TableCount > 0) then
		if not node.IsFile then
			if IsValid(node.Icon) then
				node.Icon:SetImage("fugue/magnifier")
			end
			if node.SetExpanded then
				PANEL:AllowExpanding(node, false)
			end
		end
		timer.Create(timername, 0.01, TableCount, function() 
			if ltype(dir) ~= "string" or not IsValid(node) then
				if timer.Exists( timername ) then timer.Destroy( timername ) end
				return
			end
			if Timervalue < TCount then
				Timervalue = Timervalue + MaxPerTick

				for i = 1, MaxPerTick do
					local index = ( Timervalue + i ) - 1
					local fName = files[index]

					if ltype( fName ) == "string" then
						local Filepath = dir .. "/" .. fName 
						local IsDir = file.IsDir( Filepath, "DATA" )
						local FileExists = file.Exists( Filepath, "DATA" )

						if not string.match( fName, "%.%." ) and not AddedItems[Filepath] then 
							if IsDir then
								local pNode = node:AddNode( fName )
								pNode.IsFile = false 
								pNode.FileDir = Filepath
								pNode.Name = fName

								pNode.Icon:SetImage( "fugue/blue-folder-horizontal" )
								pNode.InternalDoClick = InternalDoClick
								pNode.InternalDoRightClick = InternalDoRightClick

								PANEL:AllowExpanding( pNode, false )

								pNode.Folder = pNode:AddNode( "" )
								pNode.Folder:SetVisible( false )
								pNode.Folder:SetMouseInputEnabled( false )

							elseif FileExists and IsDir == false then
								local pNode = node:AddNode( FineName( fName ) )
								pNode.IsFile = true 
								pNode.FileDir = Filepath
								pNode.Name = FineName( fName )

								pNode.Icon:SetImage( "fugue/script-text" )
								pNode.InternalDoClick = InternalDoClick
								pNode.InternalDoRightClick = InternalDoRightClick
							end
							AddedItems[Filepath] = true 
						end
						if index == TCount then
							if node.IsFile == false then
								node.loaded = true

								if IsValid( node.Icon ) then node.Icon:SetImage( "fugue/blue-folder-horizontal" ) end

								if node.SetExpanded then
									PANEL:AllowExpanding( node, true )
									node:SetExpanded( true )
								end
							end
							if timer.Exists( timername ) then timer.Destroy( timername ) end
						end
					end
				end
			else
				if node.IsFile == false then
					node.loaded = true

					if IsValid( node.Icon ) then node.Icon:SetImage( "fugue/folder-horizontal" ) end

					if node.SetExpanded then
						PANEL:AllowExpanding( node, true )
						node:SetExpanded( true )
					end
				end
				if timer.Exists( timername ) then timer.Destroy( timername ) end
			end
		end)
	else
		if node.IsFile == false then
			if IsValid( node.Folder ) and IsValid( node.Expander ) then
				node.Folder:Remove()
				node.Expander:SetVisible(false)
				node.Expander:SetMouseInputEnabled(false)
				node:InvalidateLayout(true)
			end
			node.ChildsLoaded = true
		end
	end
end

local function OpenFolderNode( node )
	if not IsValid( node ) or not IsValid( node.Folder ) then return end

	node.Folder:Remove()
	if not node.ChildsLoaded then
		SetupFolderTree( node, node.FileDir )
		node.ChildsLoaded = true
	end
end

function PANEL:AllowExpanding( node, bool )
	if not IsValid( node ) or not IsValid( node.Expander ) then return end

	if bool then
		node.Expander.DoClick = function()
			node:GetRoot():SetSelectedItem( node )
			node:SetExpanded( not node.m_bExpanded )
			return true
		end
		node.Expander.DoRightClick = function()
			node:GetRoot():SetSelectedItem( node )
			node:SetExpanded( not node.m_bExpanded )
			return true
		end
	else
		node.Expander.DoClick = function()
			node:GetRoot():SetSelectedItem( node )
			node:SetExpanded( false )
			if node.IsFile then
				self:OnClickFile( node.FileDir, node )
			else
				OpenFolderNode( node )
				self:OnClickFolder( node.FileDir, node )
			end
			return true
		end
		node.Expander.DoRightClick = function()
			node:GetRoot():SetSelectedItem( node )
			node:SetExpanded( false )
			if node.IsFile then
				self:OnClickFile( node.FileDir, node )
			else
				OpenFolderNode( node )
				self:OnClickFolder( node.FileDir, node )
			end
			return true
		end
	end
end

function PANEL.UpdateTree( node )
	SetupFolderTree( node, node.FileDir )
end

function PANEL:Update( )
	SetupFolderTree( self, self.BaseDir )
end

function PANEL:DoClick( node ) 
	if !node then return end 
	if node.IsFile then
		self:OnClickFile( node.FileDir, node )
	else
		self:OnClickFolder( node.FileDir, node )
	end
	return true 
end

function PANEL:DoRightClick( node )
	local Menu
	if node then 
		if node.IsFile then 
			Menu = self.FileMenu 
		else 
			Menu = self.FolderMenu 
		end
	else 
		Menu = self.PanelMenu 
	end 
	self:OpenMenu( Menu )
	return true 
end

function PANEL:OnMousePressed( mcode ) 
	if mcode == MOUSE_LEFT then self:DoClick( ) 
	elseif mcode == MOUSE_RIGHT then self:DoRightClick( ) 
	elseif mcode == MOUSE_MIDDLE then 
	end 
end 

function PANEL:OpenMenu( Menu ) 
	if ltype( Menu ) ~= "table" or #Menu < 1 then return end 
	local MenuOptions = DermaMenu() 
	
	for i,v in ipairs( Menu ) do 
		local Name, Option = v[1], v[2] 
		if Name == "*SPACER*" then 
			MenuOptions:AddSpacer()
		else 
			MenuOptions:AddOption( Name, Option )
		end 
	end

	MenuOptions:Open()
end

function PANEL:AddMenuOption( Menu, Name, Option )
	if ltype( Menu ) ~= "table" then return end 
	Menu[#Menu + 1] = { Name, Option }
end

function PANEL:AddNode( strName )
    local pNode = vgui.Create( "EA_FileNode", self )

        pNode:SetText( strName )
        pNode:SetParentNode( self )
        pNode:SetRoot( self )
    
    self:AddItem( pNode )
    
    return pNode
end

function PANEL:Clear()
	for k, panel in pairs( self.Items ) do
		if ( panel && panel:IsValid() ) then
			panel:Remove()
		end
	end
	self.Items = {}
end

function PANEL:SetSelectedItem( node )
	if ( self.m_pSelectedItem and IsValid( self.m_pSelectedItem ) ) then
		self.m_pSelectedItem:SetSelected( false )
	end

	if ( node ) then
		node:SetSelected( true )
	end

	self.m_pSelectedItem = node
end

function PANEL:Paint()
	local w,h = self:GetSize() 

	surface.SetDrawColor( 200, 200, 200, 255 )
	surface.DrawRect( 0, 0, w, h )

	return true
end 

// Overrides 
function PANEL:OnClickFile( Dir, Node ) end
function PANEL:OnClickFolder( Dir, Node ) end

vgui.Register( "EA_FileBrowser", PANEL, "DTree" ) 