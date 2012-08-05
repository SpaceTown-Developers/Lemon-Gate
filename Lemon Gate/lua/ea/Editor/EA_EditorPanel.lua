/*============================================================================================================================================
	Expression-Advanced Derma
==============================================================================================================================================
	Name: EA_EditorPanel
	Author: Oskar 
============================================================================================================================================*/

local PANEL = {}

local invalid_filename_chars = {
	["*"] = "",
	["?"] = "",
	[">"] = "",
	["<"] = "",
	["|"] = "",
	["\\"] = "",
	['"'] = "",
	[" "] = "_",
	[":"] = "",
}

local function sort( a, b )
	if a.IsFile == b.IsFile then 
		return string.lower( a.Name ) < string.lower( b.Name )
	end 
	return not a.IsFile 
end

local function InvalidateLayout( panel ) 
	if panel.ChildNodes then panel.ChildNodes:InvalidateLayout( true ) end
	panel:InvalidateLayout( true ) 
	if panel.GetParentNode then InvalidateLayout( panel:GetParentNode() ) end 
end

function PANEL:Init()
	self:SetKeyBoardInputEnabled( true )
	self:SetMouseInputEnabled( true )
	self:SetText( "Expression Advanced Editor" )

	self.Editor = vgui.Create( "EA_Editor", self )
	self.Editor:Dock( FILL )
	self.Editor:DockMargin( 5, 5, 5, 5 )

	self.Browser = vgui.Create( "EA_FileBrowser", self )
	self.Browser:Dock( LEFT )
	self.Browser:DockMargin( 5, 5, 0, 5 )
	self.Browser:SetWide( 200 ) 
	self.Browser:Setup( "Lemongate" ) 

	do 
		local folderMenu = {}
		self.Browser:AddMenuOption( folderMenu, "New File", function() 
			print(self.Browser:GetSelectedItem()) 
			Derma_StringRequestNoBlur("New File in \"" .. self.Browser:GetSelectedItem().FileDir .. "\"", "Create new file", "",
	 		function(result)
				result = string.gsub(result, ".", invalid_filename_chars)
				local fName = self.Browser:GetSelectedItem().FileDir .. "/" .. result .. ".txt"
				file.Write( fName, "")
				if self.Browser:GetSelectedItem().ChildsLoaded then 
					local exp = string.Explode( "/", result ) 
					self.Browser.SetupFileNode( self.Browser:GetSelectedItem(), fName, exp[#exp] )
					table.sort( self.Browser:GetSelectedItem().ChildNodes:GetItems(), sort )
					InvalidateLayout( self.Browser:GetSelectedItem() )
				end
			end)
		end )
		self.Browser:AddMenuOption( folderMenu, "New Folder", function() 
			print(self.Browser:GetSelectedItem().FileDir) 
			Derma_StringRequestNoBlur("new folder in \"" .. self.Browser:GetSelectedItem().FileDir .. "\"", "Create new folder", "",
			function(result)
				result = string.gsub(result, ".", invalid_filename_chars )
				local fName = self.Browser:GetSelectedItem().FileDir .. "/" .. result
				file.CreateDir( fName ) 
				if self.Browser:GetSelectedItem().ChildsLoaded then 
					local exp = string.Explode( "/", result ) 
					self.Browser.SetupFolderNode( self.Browser:GetSelectedItem(), fName, exp[#exp] ) 
					table.sort( self.Browser:GetSelectedItem().ChildNodes:GetItems(), sort ) 
					InvalidateLayout( self.Browser:GetSelectedItem() )
				end 
			end)
		end )
		self.Browser.FolderMenu = folderMenu 

		local fileMenu = {} 
		self.Browser:AddMenuOption( fileMenu, "Open", function() 
			self:LoadFile( self.Browser:GetSelectedItem().FileDir ) 
		end ) 
		self.Browser:AddMenuOption( fileMenu, "*SPACER*" ) 
		self.Browser:AddMenuOption( fileMenu, "New File", function() 
			Derma_StringRequestNoBlur("New File in \"" .. self.Browser:GetSelectedItem().FileDir .. "\"", "Create new file", "",
			function(result)
				result = string.gsub(result, ".", invalid_filename_chars)
				local fName = string.GetPathFromFilename( self.Browser:GetSelectedItem().FileDir ) .. result .. ".txt"
				file.Write( fName, "")
				local exp = string.Explode( "/", result ) 
				self.Browser.SetupFileNode( self.Browser:GetSelectedItem():GetParentNode(), fName, exp[#exp] )
				self:LoadFile( fName )
				table.sort( self.Browser:GetSelectedItem():GetParentNode().ChildNodes:GetItems(), sort )
				InvalidateLayout( self.Browser:GetSelectedItem():GetParentNode() )
			end)
		end )
		self.Browser:AddMenuOption( fileMenu, "Delete", function() 
			Derma_Query( "Do you realy want to delete \"" .. self.Browser:GetSelectedItem().FileDir .. "\" (This cannot be undone)", "", 
				"Delete", function() 
					local fName = self.Browser:GetSelectedItem().FileDir 
					-- file.Delete( fName ) 

				end,
				"Cancel", function() end )
		end )
		self.Browser.FileMenu = fileMenu

		local panelMenu = {}
		self.Browser:AddMenuOption( panelMenu, "New File", function() 
			Derma_StringRequestNoBlur("New File in \"" .. self.Browser.BaseDir .. "\"", "Create new file", "",
			function(result)
				result = string.gsub(result, ".", invalid_filename_chars)
				local fName = self.Browser.BaseDir .. "/" .. result .. ".txt"
				file.Write( fName, "")
				local exp = string.Explode( "/", result ) 
				self.Browser:SetupFileNode( fName, exp[#exp] )
				self.Browser:InvalidateLayout( true )
				self:LoadFile( fName )
				table.sort( self.Browser.Items, sort )
			end)
		end )
		self.Browser:AddMenuOption( panelMenu, "New Folder", function() 
			Derma_StringRequestNoBlur("new folder in \"" .. self.Browser.BaseDir .. "\"", "Create new folder", "",
			function(result)
				result = string.gsub(result, ".", invalid_filename_chars )
				local fName = self.Browser.BaseDir .. "/" .. result
				file.CreateDir( fName )
				local exp = string.Explode( "/", result ) 
				self.Browser:SetupFolderNode( fName, exp[#exp] )
				self.Browser:InvalidateLayout( true )
				table.sort( self.Browser.Items, sort )
			end)
		end )
		self.Browser.PanelMenu = panelMenu

		function self.Browser:OnClickFolder( Dir, Node )
			if Node.LastClick and CurTime() - Node.LastClick < 0.5 then 
				Node.Expander:DoClick()
				Node.LastClick = 0
				return 
			end 
			Node.LastClick = CurTime() 
		end

		function self.Browser:OnClickFile( Dir, Node )
			if Node.LastClick and CurTime() - Node.LastClick < 0.5 then 
				self:GetParent():LoadFile( Dir )
				Node.LastClick = 0
				return 
			end 
			Node.LastClick = CurTime() 
		end
	end 

	self.ToolBar = vgui.Create( "EA_ToolBar", self )
	self.ToolBar:Dock( TOP )
	self.ToolBar:DockMargin( 5, 5, 5, 0 )
	self.ToolBar:SetTall( 30 ) 
end

function PANEL:SetCode( Code ) 
	self.Editor:SetCode( Code )
end

function PANEL:GetCode( )
	return self.Editor:GetCode( )
end

function PANEL:SaveFile( Name, SaveAs )
	if ( !Name or SaveAs ) then 
		Derma_StringRequestNoBlur( "Save to New File", "", "generic",
		function( result )
			result = string.gsub(result, ".", invalid_filename_chars)
			self:SaveFile( result .. ".txt" )
			self.Browser:Update() 
		end )
		return
	end
	
	file.Write( Name, self:GetCode() )
	self.File = Name
end

function PANEL:LoadFile( Name )
	if !Name or file.IsDir( Name ) then return end
	local Code = file.Read( Name )
	if Code then 
		self.File = Name
		self:SetCode( Code )
	end
end

function PANEL:Open(  )
	self:SetOpen( true )
end

function PANEL:Close( )
	self:SetOpen( false )
end

function PANEL:SetOpen( bool )
	if bool then
		self:MakePopup()
		self:SetVisible( true )
		self:InvalidateLayout( true )
		self:SetKeyBoardInputEnabled( true )
	else
		self:SetVisible( false )
		self:SetKeyBoardInputEnabled( false )
	end
end 

vgui.Register( "EA_EditorPanel", PANEL, "EA_Frame" )
