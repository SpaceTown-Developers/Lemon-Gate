/*============================================================================================================================================ 
	Expression-Advanced Derma 
============================================================================================================================================== 
	Name: EA_ToolBar 
	Author: Oskar 
============================================================================================================================================*/ 

local gradient_up = Material( "vgui/gradient-d" )
local gradient_down = Material( "vgui/gradient-u" )

local string_match = string.match 
local string_find = string.find 
local string_reverse = string.reverse 
local string_sub = string.sub 
local string_lower = string.lower 

local table_concat = table.concat

local LEMON = LEMON
local API = LEMON.API 

local PANEL = {} 

function PANEL:SetupButton( sName, mMaterial, nDock, fDoClick ) 
	local btn = self:Add( "EA_ImageButton" ) 
	btn:Dock( nDock ) 
	btn:SetPadding( 5 ) 
	btn:SetIconFading( false )
	btn:SetIconCentered( false )
	btn:SetTextCentered( false )
	btn:DrawButton( true )
	btn:SetTooltip( sName ) 
	btn:SetMaterial( mMaterial )
	
	if fDoClick then 
		btn.DoClick = fDoClick 
	end 
	return btn 
end 

function PANEL:Init( ) 
	self.btnSave = self:SetupButton( "Save", Material( "fugue/disk.png" ), LEFT )
	self.btnSaveAs = self:SetupButton( "Save As", Material( "fugue/disks.png" ), LEFT )
	self.btnOpen = self:SetupButton( "Open", Material( "fugue/blue-folder-horizontal-open.png" ), LEFT )
	self.btnNewTab = self:SetupButton( "New tab", Material( "fugue/script--plus.png" ), LEFT )
	self.btnCloseTab = self:SetupButton( "Close tab", Material( "fugue/script--minus.png" ), LEFT ) 
	self.btnUploadPaste = self:SetupButton( "Upload code to pastebin", Material( "fugue/drive-upload.png" ), LEFT )
	self.btnFind = self:SetupButton( "Find in code", Material( "fugue/binocular.png" ), LEFT )
	
	self:AddTabNamer( )

	self.btnOptions = self:SetupButton( "Options", Material( "fugue/gear.png" ), RIGHT )
	self.btnHelp = self:SetupButton( "Open helper", Material( "fugue/question.png" ), RIGHT )
	self.btnWiki = self:SetupButton( "Visit the wiki", Material( "fugue/home.png" ), RIGHT )
	
	self.btnRepoLink = self:SetupButton( "Open repository", Material( "github.png" ), RIGHT )
	
	self:AddInviteMenu( )

	self.btnFontPlus = self:SetupButton( "Increase font size.", Material( "fugue/edit-size-up.png" ), RIGHT )
	self.btnFontMinus = self:SetupButton( "Decrease font size.", Material( "fugue/edit-size-down.png" ), RIGHT )

	local function AddDebugIcon( )
		if GCompute and !self.btnOpenGCompute then 
			self.btnOpenGCompute = self:SetupButton( "Open native code in GCompute", Material( "fugue/bug.png" ), RIGHT, function( self )
				self:GetParent( ):GetParent( ):DoValidate( false, true ) 
				if not self:GetParent( ):GetParent( ).Data then return end
				
				self:GetParent( ):GetParent( ):Close( )
				
				local view = GCompute.IDE:GetInstance( ):GetFrame( ):CreateCodeView( )
				view:Select( )
				view:SetCode( self:GetParent():GetParent().Data.Native )
				
				GCompute.IDE:GetInstance( ):GetFrame( ):SetVisible( true )
			end )
		end
	end
	
	if GCompute then
		AddDebugIcon( )
	else
		hook.Add( "GComputeLoaded", "LemonGate", AddDebugIcon )
	end
	
	function self.btnOpen:DoClick( )
		self:GetParent( ):GetParent( ):ShowOpenFile( ) 
	end 
	
	function self.btnSave:DoClick( )
		self:GetParent( ):GetParent( ):SaveFile( true ) 
	end 
	
	function self.btnSaveAs:DoClick( )
		self:GetParent( ):GetParent( ):SaveFile( true, true ) 
	end 
	
	function self.btnNewTab:DoClick()
		self:GetParent( ):GetParent( ):NewTab( ) 
	end 
	
	function self.btnCloseTab:DoClick( )
		self:GetParent( ):GetParent( ):CloseTab( nil, true ) 
	end 
	
	local function CreatePasteSuccess( sUrl, nLength, tHeaders, nCode ) 
		SetClipboardText( sUrl ) 
		self:GetParent( ).ValidateButton:SetColor( Color( 0, 0, 255 ) )
		self:GetParent( ).ValidateButton:SetText( "Uploaded to pastebin - Link has been copied to clipboard" )
		surface.PlaySound( "buttons/button15.wav" ) 
	end 
	
	function self.btnUploadPaste:DoClick( ) 
		local Code, Path = self:GetParent( ):GetParent( ):GetCode( )
		Pastebin.CreatePaste( Code, "Lemongate script", nil, CreatePasteSuccess ) 
	end
	
	function self.btnOptions:DoClick( ) 
		self:GetParent( ):OpenOptions( ) 
	end 
		
	function self.btnHelp:DoClick( )
		self:GetParent( ):OpenHelper( ) 
	end 
	
	function self.btnWiki:DoClick( )
		gui.OpenURL( "https://github.com/SpaceTown-Developers/Lemon-Gate/wiki" )
	end
	
	function self.btnRepoLink:DoClick( )
		LEMON.Repo.OpenMenu( )
	end
	
	function self.btnFontPlus:DoClick( )
		self:GetParent( ):GetParent( ):IncreaseFontSize( 1 )
	end
	
	function self.btnFontMinus:DoClick( )
		self:GetParent( ):GetParent( ):IncreaseFontSize( -1 )
	end
	
	function self.btnFind:DoClick( )
		self:GetParent( ):GetParent( ).TabHolder:GetActiveTab( ):GetPanel( ).Search:FunctionKey( )
	end
	
end

function PANEL:AddTabNamer( )
	local Panel = self:Add( "DPanel" )
	Panel:Dock( LEFT )
	//Panel:SetPadding( 0 )
	self.pnlName = Panel
	
	Panel.btn = vgui.Create( "EA_ImageButton", Panel ) 
	Panel.btn:Dock( LEFT )
	Panel.btn:SetPadding( 5 )
	Panel.btn:SetIconFading( false )
	Panel.btn:SetIconCentered( false )
	Panel.btn:SetTextCentered( false )
	Panel.btn:DrawButton( true )
	Panel.btn:SetTooltip( "Set script name" ) 
	Panel.btn:SetMaterial( Material( "fugue/script--pencil.png" ) )
	
	Panel.txt = vgui.Create( "DTextEntry", Panel )
	
	Panel.txt:Dock( LEFT )
	function Panel.btn:DoClick( )
		if Panel.IsOpen then
			Panel.IsOpen = false
			Panel.txt:KillFocus( )
			Panel.txt:SetEnabled( false )
		else
			Panel.IsOpen = true
			Panel.txt:RequestFocus( )
			Panel.txt:SetEnabled( true )
		end
	end
	
	function Panel:Think( )
		local FullWide = Panel.IsOpen and 130 or 25
		
		local Wide = self:GetWide( )
		Wide = Wide + math.Clamp( FullWide - Wide, -5, 5 )
		
		self:SetWide( Wide )
		self.txt:SetWide( Wide - 30 )
		
		self:GetParent( ):InvalidateLayout( )
	end
	
	function Panel:Paint( )
	
	end
	
	function Panel.txt:Paint( )
		self:DrawTextEntryText( Color(0, 0, 0), Color(30, 130, 255), Color(0, 0, 0) )
		
		surface.SetDrawColor( 0, 0, 0 )
		surface.DrawLine( 2, 22, self:GetWide( ) - 2, 22 )
	end
	
	function Panel.txt:OnTextChanged( )
		local Value = self:GetValue( )
		local Title = string.sub( string.gsub( Value, "[^a-zA-Z0-9_ ]", "" ), 0, 16 )
		
		self:GetParent( ):GetParent( ):GetParent( ).TabHolder:GetActiveTab( ):SetText( Title )
		self:GetParent( ):GetParent( ):GetParent( ).TabHolder:PerformLayout( )
		
		local X, Y = self:GetCaretPos( )
		if Value != Title then X = X - 1 end
		
		self:SetText( Title )
		self:SetCaretPos( X, Y )
	end
	
	function Panel.txt:OnLoseFocus( )
		if self:GetValue( ) == "" then
			self:SetText( "generic" )
			self:OnTextChanged( )
		end
	end
	
	function Panel.txt:OnEnter( )
		Panel.IsOpen = false
		Panel.txt:KillFocus( )
		Panel.txt:SetEnabled( false )
	end
end

local function CreateOptions( )
	local Panel = vgui.Create( "EA_Frame" ) 
	Panel:SetCanMaximize( false ) 
	Panel:SetSizable( false ) 
	Panel:SetText( "Options" ) 
	Panel:SetIcon( "fugue/gear.png" )
	
	local Mixer = Panel:Add( "DColorMixer" ) 
	Mixer:SetTall( 150 )
	Mixer:Dock( TOP ) 
	Mixer:DockMargin( 10, 5, 10, 0 )
	
	Mixer:SetPalette( false )
	Mixer:SetAlphaBar( false )
	
	local syntaxColor = Panel:Add( "DComboBox" ) 
		syntaxColor:SetTall( 20 )
		syntaxColor:Dock( TOP ) 
		syntaxColor:DockMargin( 10, 5, 10, 0 )
		syntaxColor:MoveToBack( ) 
	
	local currentIndex
	function syntaxColor:OnSelect( index, value, data )
		local r, g, b = string.match( data:GetString( ), "(%d+)_(%d+)_(%d+)" ) 
		currentIndex = index
		Mixer:SetColor( Color( r, g, b ) ) 
	end
	
	local first = true 
	for k, v in pairs( LEMON.Syntaxer.ColorConvars ) do
		syntaxColor:AddChoice( k, v, first )
		first = false 
	end 
	
	function Mixer:ValueChanged( color )
		RunConsoleCommand( "lemon_editor_color_" .. syntaxColor.Choices[currentIndex], color.r .. "_" .. color.g .. "_" .. color.b ) 
		LEMON.Syntaxer:UpdateSyntaxColors( ) 
	end
	
	function Panel:Close( )
		self:SetVisible( false ) 
		cookie.Set( "eaoptions_x", self.x )
		cookie.Set( "eaoptions_y", self.y )
	end
	
	local reset = vgui.Create( "DButton" ) 
		reset:SetText( "Reset color" ) 
		-- reset:Dock( LEFT )
		-- reset:DockMargin( 0, 4, 0, 0 )
	
	function reset:DoClick( )
		RunConsoleCommand( "lemon_editor_resetcolors", syntaxColor.Choices[currentIndex] ) 
		timer.Simple( 0, function() 
			local r, g, b = string.match( LEMON.Syntaxer.ColorConvars[syntaxColor.Choices[currentIndex]]:GetString( ), "(%d+)_(%d+)_(%d+)" ) 
			Mixer:SetColor( Color( r, g, b ) ) 
		end )
	end
	
	local resetall = vgui.Create( "DButton" ) 
		resetall:SetText( "Reset all colors" ) 
		-- resetall:Dock( RIGHT )
		-- resetall:DockMargin( 10, 5, 10, 0 )
	
	function resetall:DoClick( )
		RunConsoleCommand( "lemon_editor_resetcolors", "1" ) 
		timer.Simple( 0, function() 
			local r, g, b = string.match( LEMON.Syntaxer.ColorConvars[syntaxColor.Choices[currentIndex]]:GetString( ), "(%d+)_(%d+)_(%d+)" ) 
			Mixer:SetColor( Color( r, g, b ) ) 
		end )
	end
	
	
	local ResetDivider = Panel:Add( "DHorizontalDivider" ) 
	ResetDivider:Dock( TOP ) 
	ResetDivider:DockMargin( 10, 5, 10, 0 ) 
	ResetDivider:SetLeft( reset )
	ResetDivider:SetRight( resetall )
	ResetDivider:SetLeftWidth( 120 )
	ResetDivider.StartGrab = function( ) end 
	ResetDivider.m_DragBar:SetCursor( "" )
	
	
	local editorFont = Panel:Add( "DComboBox" ) 
		editorFont:SetTall( 20 )
		editorFont:Dock( TOP ) 
		editorFont:DockMargin( 10, 5, 10, 0 )
	
	local first = true 
	local n = 1
	for k, v in pairs( LEMON.Editor.GetInstance( ).Fonts ) do
		editorFont:AddChoice( k, "", first )
		first = false 
	end 
	
	function editorFont:OnSelect( index, value, data )
		LEMON.Editor.GetInstance( ):ChangeFont( value ) 
	end
	
	local kinect = vgui.Create( "DCheckBoxLabel" ) 
	kinect:SetText( "Use kinect? " ) 
	kinect:SetConVar( "lemon_kinect_allow" )
	kinect:SizeToContents( )
	
	local Console = vgui.Create( "DCheckBoxLabel" ) 
	Console:SetText( "Allow Console? " ) 
	Console:SetConVar( "lemon_console_allow" ) 
	Console:SizeToContents( )
	
	local KeyEvents = vgui.Create( "DCheckBoxLabel" ) 
	KeyEvents:SetText( "Share Keys? " ) 
	KeyEvents:SetConVar( "lemon_share_keys" ) 
	KeyEvents:SizeToContents( )
	
	local Cvars = Panel:Add( "DHorizontalScroller" )
	Cvars:Dock( TOP ) 
	Cvars:DockMargin( 10, 5, 10, 5 )
	Cvars:AddPanel( kinect )
	Cvars:AddPanel( Console )
	Cvars:AddPanel( KeyEvents )
	
	Panel:SetSize( 300, 285 ) 
	Panel:SetPos( cookie.GetNumber( "eaoptions_x", ScrW( ) / 2 - Panel:GetWide( ) / 2 ), cookie.GetNumber( "eaoptions_y", ScrH( ) / 2 - Panel:GetTall( ) / 2 ) ) 
	
	return Panel 
end

function PANEL:AddInviteMenu( )
	self.pnlSharedView = vgui.Create( "DPanelList", self:GetParent( ) )
	self.pnlSharedView:SetVisible( false )
	self.pnlSharedView:SetAutoSize( true )
	self.pnlSharedView:SetWide( 200 )

	self.pnlSharedList = vgui.Create( "DPanelList" )
	self.pnlSharedList:SetAutoSize( true )
	self.pnlSharedList:Dock( TOP )
	self.pnlSharedList:DockPadding( 5, 5, 5, 5 )
	self.pnlSharedView:AddItem( self.pnlSharedList, "ownline" )

	local subPnl = vgui.Create( "DPanel" )
	subPnl:SetTall( 30 )
	subPnl:Dock( BOTTOM )
	subPnl:DockPadding( 5, 5, 5, 5 )
	self.pnlSharedView:AddItem( subPnl, "ownline" )

	local btnSub = self.SetupButton( subPnl, "Create", Material( "fugue/share.png" ), RIGHT )
	btnSub:DrawButton( false )
	
	local txtName = subPnl:Add( "DTextEntry" )
	txtName:Dock( FILL )
	
	function btnSub.DoClick( Btn )
		RunConsoleCommand( "lemon_editor_host", txtName:GetValue( ) )

		txtName:SetValue( "" )
		self.pnlSharedView:SetVisible( false )
	end

	-- Add to toolbar!
	self.btnShared = self:SetupButton( "Start Session", Material( "fugue/share.png" ), RIGHT )

	local OldPaint = self.btnShared.Paint
	function self.btnShared.Paint( Btn, W, H )
		OldPaint( Btn, W, H )

		local Invites = self:GetParent( ).SharedInviteCount
		if !Invites or Invites == 0 then return end

		draw.SimpleText( tostring( Invites ), "defaultsmall", W - 5, H - 5, Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )
	end -- This draws the invite count, ontop of the icon.

	function self.btnShared.DoClick( Btn )
		local Visible = !self.pnlSharedView:IsVisible( )
		
		self.pnlSharedView:SetVisible( Visible )

		if IsValid( self.Edit ) then
			self.Edit:Remove( )
			subPnl:Dock( FILL )
			subPnl:PerformLayout( )
		end

		if !Visible then return end

		local btnX, btnY = Btn:GetPos( )
		local tlbX, tlbY = self:GetPos( )

		self.pnlSharedView:SetPos( btnX + tlbX - ((self.pnlSharedView:GetWide( ) - Btn:GetWide( )) / 2 ), btnY + tlbY + Btn:GetTall( ) )

		local Tab = self:GetParent( ).TabHolder:GetActiveTab( )
		if !IsValid( Tab ) then return end
		
		local Session = Tab:GetPanel( ).SharedSession 
		if !Session then return end

		local IsHost = Session.Host == LocalPlayer( ) 

		self.Edit = self.SetupButton( subPnl, "Current Session", Material( "fugue/globe-network.png" ), LEFT )
		self.Edit:DrawButton( false )
		subPnl:PerformLayout( )

		function self.Edit.DoClick( )
			local Menu = DermaMenu( )
			
			Menu:AddOption( IsHost and "End Session" or "Leave Session", function( ) RunConsoleCommand( "lemon_editor_leave", Session.ID ) end )

			if IsHost then
					Menu:AddSpacer( )

					local Invite, Kick

					for _, Ply in pairs( player.GetAll( ) ) do
						if Ply == LocalPlayer( ) then continue end

						if !Session.Users[ Ply ] then
							if !Invite then Invite = Menu:AddSubMenu( "Invite" ) end
							Invite:AddOption( Ply:Name( ), function( ) RunConsoleCommand( "lemon_editor_invite", Session.ID, Ply:UniqueID( ) ) end )
						else
							if !Kick then Kick = Menu:AddSubMenu( "Kick" ) end
							Kick:AddOption( Ply:Name( ), function( ) RunConsoleCommand( "lemon_editor_kick", Session.ID, Ply:UniqueID( ) ) end )
						end
					end
			end

			for _, Ply in pairs( Session.Users ) do
				if Ply == LocalPlayer( ) then continue end

				local Option = Menu:AddSubMenu( Ply:Name( ) )
				
				if Session.Editor.HiddenSyncedCursors[ Ply:UniqueID( ) ] then
					Option:AddOption( "Show Cursor", function( ) Session.Editor.HiddenSyncedCursors[ Ply:UniqueID( ) ] = nil end )
				else
					Option:AddOption( "Hide Cursor", function( ) Session.Editor.HiddenSyncedCursors[ Ply:UniqueID( ) ] = true end )
				end

				--TODO: Add more options!
			end

			Menu:Open()
		end

	end -- Toggle the invites window.
end


function PANEL:OpenHelper( ) 
	if !ValidPanel( LEMON.Helper ) then LEMON.Helper = vgui.Create( "EA_Helper" ) end 
	LEMON.Helper:SetVisible( true )
	LEMON.Helper:MakePopup( ) 
end 

function PANEL:OpenOptions( )
	if !ValidPanel( self.Options ) then self.Options = CreateOptions( ) end 
	self.Options:SetVisible( true ) 
	self.Options:MakePopup( ) 
end

function PANEL:Paint( w, h ) 
	surface.SetDrawColor( self.btnSave:GetColor( ) )
	surface.DrawRect( 0, 0, w, h )
	
	surface.SetDrawColor( 200, 200, 200, 100 )
	surface.SetMaterial( gradient_down )
	surface.DrawTexturedRect( 0, 0, w, h )
end 

vgui.Register( "EA_ToolBar", PANEL, "Panel" )
