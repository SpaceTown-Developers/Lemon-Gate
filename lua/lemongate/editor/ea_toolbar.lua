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
	self.btnNewTab = self:SetupButton( "New tab", Material( "fugue/script--plus.png" ), LEFT )
	self.btnCloseTab = self:SetupButton( "Close tab", Material( "fugue/script--minus.png" ), LEFT ) 
	self.btnUploadPaste = self:SetupButton( "Upload code to pastebin", Material( "fugue/drive-upload.png" ), LEFT )
	
	self.btnOptions = self:SetupButton( "Options", Material( "fugue/gear.png" ), RIGHT )
	self.btnHelp = self:SetupButton( "Open helper", Material( "fugue/question.png" ), RIGHT )
	self.btnWiki = self:SetupButton( "Open wiki", Material( "fugue/home.png" ), RIGHT )
	
	self.btnRepoLink = self:SetupButton( "Open repository", Material( "github.png" ), RIGHT )
	
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
		gui.OpenURL( "http://github.com/SpaceTown-Developers/Lemon-Gate/wiki" )
	end
	
	function self.btnRepoLink:DoClick( )
		LEMON.Repo.OpenMenu( )
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
	kinect:SetText( "Use kinect?" ) 
	kinect:SetConVar( "lemon_kinect_allow" ) 
	
	local Console = vgui.Create( "DCheckBoxLabel" ) 
	Console:SetText( "Allow Console?" ) 
	Console:SetConVar( "lemon_console_allow" ) 
	
	local Divider = Panel:Add( "DHorizontalDivider" ) 
	Divider:Dock( TOP ) 
	Divider:DockMargin( 10, 5, 10, 5 ) 
	Divider:SetLeft( Console )
	Divider:SetRight( kinect )
	Divider.StartGrab = function( ) end 
	Divider.m_DragBar:SetCursor( "" )
	
	Panel:SetSize( 300, 285 ) 
	Panel:SetPos( cookie.GetNumber( "eaoptions_x", ScrW( ) / 2 - Panel:GetWide( ) / 2 ), cookie.GetNumber( "eaoptions_y", ScrH( ) / 2 - Panel:GetTall( ) / 2 ) ) 
	
	return Panel 
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
