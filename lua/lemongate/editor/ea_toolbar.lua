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
	
	self.btnOptions = self:SetupButton( "Options", Material( "fugue/gear.png" ), RIGHT )
	self.btnHelp = self:SetupButton( "Open helper", Material( "fugue/question.png" ), RIGHT )
	self.btnWiki = self:SetupButton( "Open wiki", Material( "fugue/home.png" ), RIGHT )
	
	self.lblLink = self.btnWiki:Add( "DLabelURL" ) 
	self.lblLink:Dock( FILL ) 
	self.lblLink:SetText( "" ) 
	self.lblLink:SetURL( "http://github.com/SpaceTown-Developers/Lemon-Gate/wiki" )
	
	local OnCursorEntered = self.lblLink.OnCursorEntered 
	local OnCursorExited = self.lblLink.OnCursorExited 
	
	self.lblLink.OnCursorEntered = function( lbl, ... ) 
		OnCursorEntered( lbl, ... ) 
		self.btnWiki.Hovered = true 
	end 
	
	self.lblLink.OnCursorExited = function( lbl, ... ) 
		OnCursorExited( lbl, ... ) 
		self.btnWiki.Hovered = false 
	end 
	
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
		
	function self.btnHelp:DoClick( )
		self:GetParent( ):OpenHelper( ) 
	end 
	
	function self.btnOptions:DoClick( ) end 
	function self.btnWiki:DoClick( ) end 
end 

local function GetType( word )
	local Class = API:GetClass( word, true ) 
	if Class then 
		return string_lower( Class.Name ) 
	end 
end

local function GetArgumentTypes( sArgs ) 
	local _sArgs = string_reverse( sArgs )
	local buff = ""
	sArgs = "" 
	while #_sArgs > 0 do 
		local shorttp = _sArgs[1] 
		local longtp = GetType( shorttp ) 
		if buff or not longtp then 
			buff = shorttp .. buff
			
			if GetType( buff ) then 
				longtp = GetType( buff )
				buff = "" 
			elseif buff == "..." then 
				sArgs = sArgs .. "...  " 
				_sArgs = "" 
				buff = "" 
				break 
			else 
				_sArgs = string_sub( _sArgs, 2 )
				continue 
			end 
		end 
		sArgs = longtp .. ", " .. sArgs 
		_sArgs = string_sub( _sArgs, 2 ) 
	end 
	
	if #buff > 0 then 
		print( sArgs ) 
		print( buff ) 
		error( "The helper is leaking lemon juice!", 2 ) 
	end 
	
	sArgs = string_sub( sArgs, 1, -3 ) 
	return sArgs 
end 

local function ParseFunction( name, retType, ops ) 
	local funcName = string_match( name, "^[^%(]+" ) 
	local argTypes = string_match( name, "%(([^%)]*)%)" )
	
	local super
	local found, stop = argTypes:find( ":" )
	if found then 
		super = GetType( string_sub( argTypes, 1, stop - 1 ) )
		argTypes = string_sub( argTypes, stop + 1 )
	end 
	
	argTypes = GetArgumentTypes( argTypes ) .. " "
	
	if retType and retType ~= "" then 
		retType = GetType( retType ) or ""
	end 
	
	if retType and string_match( retType, "^%s*$" ) then retType = nil end 
	
	return funcName, { comp = super, args = argTypes or "", ret = retType, opcost = ops }
end 

local function SetupHelperFunctions( List, filter, bFunctions, bEvents )
	if not API.Initialized then return end 
	if not API.Functions or not API.Events then 
		timer.Simple( 0.5, function() 
			SetupHelperFunctions( List, filter, bFunctions, bEvents )
		end )
		return 
	end 
	
	-- bFunctions = bFunctions == nil and true or bFunctions
	-- bEvents = bEvents == nil and true or bEvents
	
	// TODO: Do in timer to prevent lag? 
	local DescriptionData = LEMON.HelperData or {}
	local count = 0
	filter = filter or ".+" 
	List:Clear( true ) 
	
	if bFunctions then 
		for name, data in pairs( API.Functions ) do 
			local funcName = string_match( name, "^[^%(]+" ) 
			local argTypes = string_match( name, "%(([^%)]*)%)" ) 
			
			if string_find( name, "***", nil, true ) or string_find( name, "!", nil, true ) then continue end 
			if !string_match( string_lower( funcName ), string_lower( filter ) ) then continue end 
			
			List:AddLine( funcName, argTypes, data.Return, 0 ).OnSelect = function( self ) 
				local _, funcData = ParseFunction( name, data.Return, 0 ) 
				List:GetParent( ).Description:SetText( data.Desc or "" )
				List:GetParent( ).Syntax:SetText( (funcData.ret and funcData.ret .. " = " or "") .. (funcData.comp and funcData.comp .. ":" or "") .. funcName .. "( " .. funcData.args .. ")" )
			end 
			
			count = count + 1 
			if count > 50 then break end 
		end 
	end 
	
	if bEvents then 
		for name, data in pairs( API.Events ) do 
			local argTypes = GetArgumentTypes( table_concat( data.Params, "" ) )
			local retType = GetArgumentTypes( data.Return )
			
			if !string_match( string_lower( name ), string_lower( filter ) ) then continue end 
			
			List:AddLine( name, table_concat( data.Params, "" ), data.Return, 0 ).OnSelect = function( self ) 
				List:GetParent( ).Description:SetText( DescriptionData[name .. "<" .. table_concat( data.Params, "" ) .. (#data.Return > 0 and " " .. data.Return .. ">" or ">")] or "" ) 
				List:GetParent( ).Syntax:SetText( (retType ~= "" and retType .. " = " or "") .. name .. "<" .. argTypes .. ">" )
			end 
		end 
	end 
	
	List:SortByColumn( 1 )
end

local function CreateHelperWindow( )
	if ValidPanel( Helper ) then return end 
	local Helper = vgui.Create( "EA_Frame" )
	LEMON.Helper = Helper 
	
	Helper:ShowCloseButton( true ) 
	Helper:SetSizable( true )
	Helper:SetCanMaximize( false )
	Helper:SetMinWidth( 300 )
	Helper:SetMinHeight( 200 )
	Helper:SetText( "Expression Advanced Helper" )
	Helper:SetSize( cookie.GetNumber( "eahelper_w", 400 ), cookie.GetNumber( "eahelper_h", 600 ) ) 
	Helper:SetPos( cookie.GetNumber( "eahelper_x", ScrW( ) / 2 - Helper.x / 2 ), cookie.GetNumber( "eahelper_y", ScrH( ) / 2 - Helper.y / 2 ) )
	Helper:MakePopup( ) 
	Helper.Close = function(self) 
		self:SetVisible( false ) 
		cookie.Set( "eahelper_x", Helper.x )
		cookie.Set( "eahelper_y", Helper.y )
		cookie.Set( "eahelper_w", Helper:GetWide( ) )
		cookie.Set( "eahelper_h", Helper:GetTall( ) )
	end 
	
	
	Helper.List = Helper:Add( "DListView" )
	Helper.List:Dock( FILL )
	Helper.List:DockMargin( 5, 5, 5, 5 )
	
	Helper.List:AddColumn( "Function" ):SetWide( 126 )
	Helper.List:AddColumn( "Arguments" ):SetWide( 60 )
	Helper.List:AddColumn( "Return" ):SetWide( 60 )
	Helper.List:AddColumn( "Cost" ):SetWide( 30 )
	
	
	Helper.Description = Helper:Add( "DTextEntry" ) 
	Helper.Description:Dock( BOTTOM ) 
	Helper.Description:DockMargin( 5, 0, 5, 5 ) 
	Helper.Description:SetMultiline( true )
	Helper.Description:SetNumeric( false ) 
	Helper.Description:SetEnabled( false )
	Helper.Description:SetTall( 70 )
	
	
	Helper.Syntax = Helper:Add( "DTextEntry" ) 
	Helper.Syntax:Dock( BOTTOM ) 
	Helper.Syntax:DockMargin( 5, 0, 5, 5 ) 
	Helper.Syntax:SetMultiline( false )
	Helper.Syntax:SetNumeric( false ) 
	Helper.Syntax:SetEnabled( false )
	
	
	Helper.Search = Helper:Add( "DTextEntry" ) 
	Helper.Search:Dock( TOP ) 
	Helper.Search:DockMargin( 5, 5, 5, 0 ) 
	Helper.Search:SetMultiline( false )
	Helper.Search:SetNumeric( false ) 
	Helper.Search:SetEnabled( true )
	Helper.Search:SetEnterAllowed( true )
	Helper.Search:SetZPos( 0 )
	
	local Func, Event = cookie.GetNumber( "eahelper_show_functions", 1 ) == 1, cookie.GetNumber( "eahelper_show_events", 0 ) == 1
	Helper.Search.OnEnter = function( self )
		SetupHelperFunctions( Helper.List, self:GetValue( ), Func, Event )
	end 
	
	
	Helper.Options = Helper:Add( "DPanel" ) 
	Helper.Options.Paint = function( self, w, h ) 
		surface.SetDrawColor( 0, 0, 0, 255 ) 
		surface.DrawRect( 0, 0, w, h )
	end 
	Helper.Options:SetTall( 25 ) 
	Helper.Options:Dock( TOP ) 
	Helper.Options:DockMargin( 5, 5, 5, 0 ) 
	
	Helper.Options:SetZPos( 10 )
	
	-- [[
	Helper.Options.ShowFunctions = Helper.Options:Add( "DCheckBoxLabel" ) 
	Helper.Options.ShowFunctions:Dock( LEFT ) 
	Helper.Options.ShowFunctions:DockMargin( 5, 5, 0, 5 ) 
	Helper.Options.ShowFunctions:SetText( "Show Functions" ) 
	Helper.Options.ShowFunctions:SizeToContents( ) 
	Helper.Options.ShowFunctions.OnChange = function( self, bVal ) 
		Func = bVal 
		cookie.Set( "eahelper_show_functions", bVal and 1 or 0 ) 
		SetupHelperFunctions( Helper.List, Helper.Search:GetValue( ), Func, Event )
	end 
	Helper.Options.ShowFunctions:SetValue( cookie.GetNumber( "eahelper_show_functions", 1 ) == 1 )
	-- ]]
	
	-- [[
	Helper.Options.ShowEvents = Helper.Options:Add( "DCheckBoxLabel" ) 
	Helper.Options.ShowEvents:Dock( LEFT ) 
	Helper.Options.ShowEvents:DockMargin( 5, 5, 0, 5 ) 
	Helper.Options.ShowEvents:SetText( "Show Events" ) 
	Helper.Options.ShowEvents:SizeToContents( ) 
	Helper.Options.ShowEvents.OnChange = function( self, bVal ) 
		Event = bVal 
		cookie.Set( "eahelper_show_events", bVal and 1 or 0 ) 
		SetupHelperFunctions( Helper.List, Helper.Search:GetValue( ), Func, Event )
	end 
	Helper.Options.ShowFunctions:SetValue( cookie.GetNumber( "eahelper_show_events", 0 ) == 1 )
	-- ]]
	
	SetupHelperFunctions( Helper.List, Helper.Search:GetValue( ), Func, Event )
end

function PANEL:OpenHelper( ) 
	if !ValidPanel( LEMON.Helper ) then CreateHelperWindow( ) end 
	LEMON.Helper:SetVisible( true )
	LEMON.Helper:MakePopup( ) 
end 

function PANEL:Paint( w, h ) 
	surface.SetDrawColor( self.btnSave:GetColor( ) )
	surface.DrawRect( 0, 0, w, h )
	
	surface.SetDrawColor( 200, 200, 200, 100 )
	surface.SetMaterial( gradient_down )
	surface.DrawTexturedRect( 0, 0, w, h )
end 

vgui.Register( "EA_ToolBar", PANEL, "Panel" )
