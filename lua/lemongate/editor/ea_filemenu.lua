/*============================================================================================================================================
	Expression-Advanced Derma
==============================================================================================================================================
	Name: EA_FileMenu
	Author: Rusketh
============================================================================================================================================*/
PANEL = { }

function PANEL:Init( )
	self:ShowCloseButton( true )
	self:DockPadding( 0, 26, 0, 0 )
	
	self.CurrentPath = "lemongate"
	
	self.SubPanel = vgui.Create( "DPanel" )
	self:BuildPathBar( self.SubPanel )
	self:BuildFileList( self.SubPanel )
	self:BuildOpenSave( self.SubPanel )
	
	self.Divider = vgui.Create( "DHorizontalDivider", self )
	self.Divider:Dock( FILL )
	self.Divider:DockMargin( 5, 5, 5, 5 )
	self.Divider:SetDividerWidth( 5 )
	self.Divider:SetLeftMin( 50 )
	self.Divider:SetRightMin( 50 )
	self.Divider:SetLeft( self:BuildBrowser( ) )
	self.Divider:SetRight( self.SubPanel )
	
	self:SetSizable( true )
	self:SetMinWidth( 500 )
	self:SetMinHeight( 300 )
	self:SetSize( 500, 300 )
end

function PANEL:BuildBrowser( )
	self.Browser = vgui.Create( "DTree" )
	self:RefreshBrowser( )
	return self.Browser
end

function PANEL:RefreshBrowser( )
	self.Browser:Clear( )
	
	self.BrowserNode = self.Browser:AddNode( "LemonGate" )
	
	self:SetUpBrowserNode( self.BrowserNode, "lemongate" )
	
	self:AddFolderToBrowser( self.BrowserNode, "lemongate" )
	
	self.BrowserNode:SetExpanded( true )
end

function PANEL:AddFolderToBrowser( RootNode, Path )
	local Files, Folders = file.Find( Path .. "/*", "DATA", "nameasc" )
	
	for _, Folder in pairs( Folders ) do
		local Node = RootNode:AddNode( Folder )
		local NewPath = Path .. "/" .. Folder
		
		self:SetUpBrowserNode( Node, NewPath, Path )
		
		self:AddFolderToBrowser( Node, NewPath )
	end
end

function PANEL:SetUpBrowserNode( Node, Path, UpDir )
	Node.Icon:SetImage( "fugue/blue-folder-horizontal.png" )
	
	Node.Expander.DoClick = function( )
		local Expanded = !Node.m_bExpanded
		
		Node:SetExpanded( Expanded )
		
		if !Expanded then
			Node.Icon:SetImage( "fugue/blue-folder-horizontal.png" )
		else
			Node.Icon:SetImage( "fugue/blue-folder-horizontal-open.png" )
		end
	end
	
	function Node.Label.DoDoubleClick( )
		self:OpenFolder( Path, UpDir )
	end
	
	-- TODO: Right click Refresh menu.
end

function PANEL:BuildFileList( Parent )
	self.FileList = vgui.Create( "DListView", Parent )
	self.FileList:Dock( FILL )
	self.FileList:DockMargin( 0, 0, 0, 0 )
	
	self.FileList:SetMultiSelect( false )
	self.FileList:AddColumn( "" ):SetMaxWidth( 20 )
	self.FileList:AddColumn( "Name" ):SetMinWidth( 50 )
	self.FileList:AddColumn( "Size" ):SetMaxWidth( 40 )
	self.FileList:AddColumn( "Modified" ):SetMaxWidth( 80 )
	
	function self.FileList.OnClickLine( _, Line, Bool )
		if Bool then
			if Line.OnDoubleClick and Line.fLastClick and ( SysTime( ) - Line.fLastClick < 0.3 ) then
				Line:OnDoubleClick( )
			elseif Line.OnSingleClick then
				Line:OnSingleClick( )
			end
				
			Line.fLastClick = SysTime( )
		end
	end
	
	self:OpenFolder( "lemongate" )
	
	return self.FileList
end

function PANEL:OpenFolder( Path, UpDir )
	self.CurrentPath = Path
	self.PathEntry:SetText( Path .. "/" )
	
	self.FileList:Clear( )
	
	-- Parent Dir:
	if UpDir then
		local Parent = self.FileList:AddLine( "", "..", "", "" )
		self:SetFileIcon( Parent, "fugue/blue-folder-horizontal-open.png" )
	
		function Parent.OnDoubleClick( )
			self:OpenFolder( UpDir, self:GetUpDir( UpDir ) )
		end
	end
	
	-- Files and folders:
	local Files, Folders = file.Find( Path .. "/*", "DATA", "nameasc" )
	
	for _, File in pairs( Files ) do
		if File:Right( 4 ) == ".txt" then
			local Line = self:AddFile( File, Path, "fugue/script.png" )
			
			function Line.OnSingleClick( )
				self.SavePath:SetText( File )
			end
			
			function Line.OnDoubleClick( )
				local Close = false
				
				if self.IsSaveMenu then
					Close = self:DoSaveFile( Path, File )
				else
					Close = self:DoLoadFile( Path, File )
				end
				
				if Close then
					self:Remove( )
				end
			end
		end
	end
	
	for _, Folder in pairs( Folders ) do
		local Line = self:AddFile( Folder, Path, "fugue/blue-folder-horizontal.png" )
		
		function Line.Action( )
			self:OpenFolder( Path .. "/" .. Folder, Path )
		end
	end
end

function PANEL:AddFile( Name, Path, Icon )
	local NewPath = Path .. "/" .. Name
	
	local Bytes = self:ToBytes( file.Size( NewPath, "DATA" ) )
	local Time = os.date( "%d-%m-%Y", file.Time( NewPath, "DATA" ) )
	
	local Line = self.FileList:AddLine( "", Name, Bytes, Time )
	
	self:SetFileIcon( Line, Icon )
	
	function Line.OnRightClick( )
		if !file.IsDir( NewPath, "DATA" ) then
			-- file.Delete can not delete folder?
			
			local Menu = DermaMenu( )
			
			if self.IsSaveMenu then
				Menu:AddSubMenu( "Over Write" ):AddOption( "Confirm", function( )
					if self:DoSaveFile( self.CurrentPath, Name ) then
						self:Remove( )
					end
				end )
			else
				Menu:AddOption( "Open", function( )
					if self:DoLoadFile( self.CurrentPath, Name ) then
						self:Remove( )
					end
				end )
			end
			
			Menu:AddSubMenu( "Delete" ):AddOption( "Confirm", function( )
				file.Delete( NewPath )
				self:OpenFolder( Path, self:GetUpDir( Path ) )
			end )
			
			Menu:Open( )
		end
		
	end
	
	return Line
end

function PANEL:ToBytes( Bytes )
	if !Bytes or Bytes == 0 then
		return ""
	elseif Bytes < 1024 then
		return Bytes .. "b"
	end
	
	local KBytes = math.ceil( Bytes / 1024 )
	if KBytes < 1024 then
		return KBytes .. "kb"
	end
	
	local MByte = math.ceil( KBytes / 1024 )
	if MBytes < 1024 then
		return MBytes .. "mb"
	end
	
	local GByte = math.ceil( MBytes / 1024 )
	if GBytes < 1024 then
		return GBytes .. "mb"
	end
	
	return "?tb"
end

function PANEL:SetFileIcon( Line, Icon )
	local Img = vgui.Create( "DImage", Line )
	Img:Dock( NODOCK )
	Img:SetImage( Icon )
	Img:SizeToContents( )
	
	Line.Columns[ 1 ] = Img
end

function PANEL:GetUpDir( Path )
	local Split = string.Explode( "/", Path )
	
	if #Split > 1 then
		Split[ #Split ] = nil
		return string.Implode( "/", Split )
	end
end

function PANEL:BuildPathBar( Parent )
	self.PathEntry = vgui.Create( "DTextEntry", Parent )
	self.PathEntry:Dock( TOP )
	
	function self.PathEntry.OnEnter( Entry )
		local Path = Entry:GetValue( )
		
		if Path:Right( 1 ) == "/" then
			Path = Path:sub( 1, #Path - 1 )
		end
		
		if Path:Left( 9 ) == "lemongate" then
			if file.IsDir( Path, "DATA" ) then
				self:OpenFolder( Path )
			end
		end
	end
	
	return self.PathEntry
end

function PANEL:BuildOpenSave( Parent )
	self.OpenSave = vgui.Create( "DPanel", Parent )
	self.OpenSave:SetTall( 22 )
	self.OpenSave:Dock( BOTTOM )
	
	self.SavePath = vgui.Create( "DTextEntry", self.OpenSave )
	self.SavePath:Dock( FILL ) 
	
	self.NewDir = vgui.Create( "EA_ImageButton", self.OpenSave )
	self.NewDir:Dock( RIGHT ) 
	self.NewDir:SetPadding( 5 )
	self.NewDir:SetTooltip( "New Folder" ) 
	self.NewDir:SetMaterial( Material( "fugue/blue-folder--plus.png" ) )
	
	self.NewDir:SetIconFading( false )
	self.NewDir:SetIconCentered( false )
	self.NewDir:SetTextCentered( false )
	self.NewDir:DrawButton( false )
	
	self.SaveOrLoad = vgui.Create( "EA_ImageButton", self.OpenSave )
	self.SaveOrLoad:Dock( RIGHT ) 
	self.SaveOrLoad:SetPadding( 5 )
	
	self.SaveOrLoad:SetIconFading( false )
	self.SaveOrLoad:SetIconCentered( false )
	self.SaveOrLoad:SetTextCentered( false )
	self.SaveOrLoad:DrawButton( false )
	
	function self.NewDir.DoClick( )
		local Path = self.CurrentPath .. "/" .. self.SavePath:GetValue( )
		
		file.CreateDir( Path )
		
		if file.IsDir( Path, "DATA" ) then
			self:OpenFolder( Path, self.CurrentPath )
		end
	end
	
	function self.SavePath.OnEnter( )
		self.SaveOrLoad:DoClick( )
	end
	
	self:SetLoadFile( )
	
	return self.OpenSave
end

function PANEL:SetSaveFile( Default, Path )
	self.IsSaveMenu = true
	
	self:SetText( "Save File:" )
	self.SaveOrLoad:SetTooltip( "Save" ) 
	self.SaveOrLoad:SetMaterial( Material( "fugue/disk.png" ) )
	
	self.SavePath:SetText( Default or "" )
	
	if Path and file.IsDir( Path, "DATA" ) then
		self:OpenFolder( Path )
	end
	
	function self.SaveOrLoad.DoClick( )
		if self:DoSaveFile( self.CurrentPath, self.SavePath:GetValue( ) ) then
			self:Remove( )
		end
	end
end

function PANEL:SetLoadFile( )
	self.IsSaveMenu = false
	
	self:SetText( "Load File:" )
	self.SaveOrLoad:SetTooltip( "Open" )
	self.SaveOrLoad:SetMaterial( Material( "fugue/script.png" ) ) 
	
	function self.SaveOrLoad.DoClick( )
		if self:DoLoadFile( self.CurrentPath, self.SavePath:GetValue( ) ) then
			self:Remove( )
		end
	end
end

function PANEL:DoSaveFile( Path, FileName )
	-- Return true to close!
end

function PANEL:DoLoadFile( Path, FileName )
	-- Return true to close!
end


vgui.Register( "EA_FileMenu", PANEL, "EA_Frame" )
