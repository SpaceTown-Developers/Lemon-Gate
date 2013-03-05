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

local GetLongType = LemonGate.GetLongType 

local PANEL = {} 

local function SetupButton( self, sName, mMaterial, nDock, fDoClick ) 
	local btn = self:Add( "EA_ImageButton" ) 
	btn:Dock( nDock ) 
	btn:SetPadding( 5 ) 
	btn:SetIconFading( false )
	btn:SetIconCentered( false )
	btn:SetTextCentered( false )
	btn:DrawButton( true )
	btn:SetTooltip( sName ) 
	btn:SetMaterial( mMaterial )
	
	btn.DoClick = fDoClick 
	return btn 
end 

function PANEL:Init() 
	self.btnSave = SetupButton( self, "Save", Material( "fugue/disk.png" ), LEFT )
	self.btnSaveAs = SetupButton( self, "Save As", Material( "fugue/disks.png" ), LEFT )
	self.btnNewTab = SetupButton( self, "New tab", Material( "fugue/script--plus.png" ), LEFT )
	self.btnCloseTab = SetupButton( self, "Close tab", Material( "fugue/script--minus.png" ), LEFT )
	
	self.btnOptions = SetupButton( self, "Options", Material( "fugue/gear.png" ), RIGHT )
	self.btnHelp = SetupButton( self, "Open helper", Material( "fugue/question.png" ), RIGHT )
	self.btnWiki = SetupButton( self, "Open wiki", Material( "fugue/home.png" ), RIGHT )
	
	
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

local function GetArgumentTypes( sArgs ) 
	local _sArgs = string_reverse( sArgs )
	local buff = ""
	sArgs = "" 
	while #_sArgs > 0 do 
		local shorttp = _sArgs[1] 
		local longtp = GetLongType( shorttp ) 
		if buff or not longtp then 
			buff = shorttp .. buff
			
			if GetLongType( buff ) then 
				longtp = GetLongType( buff )
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
		sArgs = sArgs .. longtp .. ", "
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
		super = GetLongType( argTypes:sub( 1, stop - 1 ) ) 
		argTypes = argTypes:sub( stop + 1 )
	end 
	
	argTypes = GetArgumentTypes( argTypes ) .. " "
	
	if retType and retType ~= "" then 
		retType = GetLongType( retType ) or ""
	end 
	
	if retType and string_match( retType, "^%s*$" ) then retType = nil end 
	
	return funcName, { comp = super, args = argTypes or "", ret = retType, opcost = ops }
end 

local function SetupHelperFunctions( List, filter, bFunctions, bEvents, bExceptions )
	if !LemonGate then return end 
	if !LemonGate.FunctionTable then 
		RunConsoleCommand( "lemon_sync" ) 
		timer.Simple( 0.5, function() 
			if !LemonGate.FunctionTable then return end 
			SetupHelperFunctions( List, filter, bFunctions, bEvents, bExceptions )
		end )
		return 
	end 
	
	bFunctions = bFunctions == nil and true or bFunctions 
	bEvents = bEvents == nil and true or bEvents 
	bExceptions = bExceptions == nil and true or bExceptions 
	
	// TODO: Do in timer to prevent lag? 
	local FunctionData = LemonGate.HelperFunctionData 
	local count = 0
	filter = filter or ".+" 
	List:Clear( true ) 
	
	if bFunctions then 
		for name, data in pairs( LemonGate.FunctionTable ) do 
			local funcName = string_match( name, "^[^%(]+" ) 
			local argTypes = string_match( name, "%(([^%)]*)%)" ) 
			
			if string_find( name, "***", nil, true ) or string.find( name, "!", nil, true ) then continue end 
			if !string_match( funcName, filter ) then continue end 
			
			List:AddLine( funcName, argTypes, data[2], data[3] ).OnSelect = function( self ) 
				local _, funcData = ParseFunction( name, data[2], data[3] ) 
				List:GetParent( ).Description:SetText( FunctionData[funcName .. "(" .. argTypes .. (funcData.ret and " " .. data[2] .. ")" or ")")] or ""  ) 
				List:GetParent( ).Syntax:SetText( (funcData.ret and funcData.ret .. " = " or "") .. (funcData.comp and funcData.comp .. ":" or "") .. funcName .. "( " .. funcData.args .. ")" )
			end 
			
			count = count + 1 
			if count > 50 then break end 
		end 
	end 
	
	if bEvents then 
		for name, data in pairs( LemonGate.EventsTable ) do 
			local argTypes = GetArgumentTypes( data[1] )
			local retType = GetArgumentTypes( data[2] )
			
			if !string_match( name, filter ) then continue end 
			
			List:AddLine( name, data[1], data[2], data[3] ).OnSelect = function( self ) 
				List:GetParent( ).Description:SetText( "" ) 
				List:GetParent( ).Syntax:SetText( (retType ~= "" and retType .. " = " or "") .. name .. "<" .. argTypes .. ">" )
			end 
		end 
	end 
	
	--[[ TODO: Add or not to add? Thats the question. 
	if bExceptions then 
		for name, data in pairs( LemonGate.Exceptions ) do 
			local argTypes = data[1] 
			local retType = data[2] 
			print( name )
			print( data )
		end 
	end 
	--]]
	
	List:SortByColumn( 1 )
end
 
local function CreateHelperWindow( )
	if ValidPanel( Helper ) then return end 
	local Helper = vgui.Create( "EA_Frame" )
	LemonGate.Helper = Helper 
	
	Helper:ShowCloseButton( true ) 
	Helper:SetSizable( true )
	Helper:SetMinWidth( 300 )
	Helper:SetMinHeight( 200 )
	Helper:SetText( "Expression Advanced Helper" )
	Helper:SetSize( 400, 600 ) 
	Helper:Center( )
	Helper:MakePopup( ) 
	
	
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
	
	
	local Func, Event, Exception 
	Helper.Search.OnEnter = function( self )
		SetupHelperFunctions( Helper.List, self:GetValue( ), Func, Event, Exception )
	end 
	
	
	Helper.Options = Helper:Add( "DPanel" ) 
	Helper.Options.Paint = function( self, w, h ) 
		surface.SetDrawColor( 0, 0, 0, 255 ) 
		surface.DrawRect( 0, 0, w, h )
	end 
	Helper.Options:SetTall( 25 ) 
	Helper.Options:Dock( TOP ) 
	Helper.Options:DockMargin( 5, 5, 5, 0 ) 
	
	Helper.Options.ShowFunctions = Helper.Options:Add( "DCheckBoxLabel" ) 
	Helper.Options.ShowFunctions:Dock( LEFT ) 
	Helper.Options.ShowFunctions:DockMargin( 5, 5, 0, 5 ) 
	Helper.Options.ShowFunctions:SetText( "Show Functions" ) 
	Helper.Options.ShowFunctions:SizeToContents( ) 
	Helper.Options.ShowFunctions.OnChange = function( self, bVal ) 
		Func = bVal 
		SetupHelperFunctions( Helper.List, Helper.Search:GetValue( ), Func, Event, Exception )
	end 
	Helper.Options.ShowFunctions:SetValue( true )
	
	Helper.Options.ShowEvents = Helper.Options:Add( "DCheckBoxLabel" ) 
	Helper.Options.ShowEvents:Dock( LEFT ) 
	Helper.Options.ShowEvents:DockMargin( 5, 5, 0, 5 ) 
	Helper.Options.ShowEvents:SetText( "Show Events" ) 
	Helper.Options.ShowEvents:SizeToContents( ) 
	Helper.Options.ShowEvents.OnChange = function( self, bVal ) 
		Event = bVal 
		SetupHelperFunctions( Helper.List, Helper.Search:GetValue( ), Func, Event, Exception )
	end 
	Helper.Options.ShowEvents:SetValue( false )
	
	Helper.Options.ShowExceptions = Helper.Options:Add( "DCheckBoxLabel" ) 
	Helper.Options.ShowExceptions:Dock( LEFT ) 
	Helper.Options.ShowExceptions:DockMargin( 5, 5, 0, 5 ) 
	Helper.Options.ShowExceptions:SetText( "Show Exceptions" ) 
	Helper.Options.ShowExceptions:SizeToContents( ) 
	Helper.Options.ShowExceptions:SetDisabled( true ) 
	Helper.Options.ShowExceptions.OnChange = function( self, bVal ) 
		Exception = bVal 
		SetupHelperFunctions( Helper.List, Helper.Search:GetValue( ), Func, Event, Exception )
	end 
	Helper.Options.ShowExceptions:SetValue( false )
	
	
	SetupHelperFunctions( Helper.List, Helper.Search:GetValue( ), Func, Event, Exception )
end

function PANEL:OpenHelper( ) 
	if !ValidPanel( LemonGate.Helper ) then CreateHelperWindow( ) end 
	LemonGate.Helper:SetVisible( true )
	LemonGate.Helper:MakePopup( ) 
end 

function PANEL:Paint( w, h ) 
	surface.SetDrawColor( self.btnSave:GetColor( ) )
	surface.DrawRect( 0, 0, w, h )
	
	surface.SetDrawColor( 200, 200, 200, 100 )
	surface.SetMaterial( gradient_down )
	surface.DrawTexturedRect( 0, 0, w, h )
end 

vgui.Register( "EA_ToolBar", PANEL, "Panel" )
