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
	
	self.btnWiki = self:Add( "EA_ImageButton" ) 
	self.btnWiki:Dock( RIGHT )  
	self.btnWiki:SetPadding( 5 ) 
	self.btnWiki:SetIconFading( false )
	self.btnWiki:SetIconCentered( false )
	self.btnWiki:SetTextCentered( false )
	self.btnWiki:DrawButton( true )
	self.btnWiki:SetTooltip( "Open wiki" )
	self.btnWiki:SetMaterial( Material( "fugue/home.png" ) )
	
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
		self:GetParent( ):GetParent( ):SaveFile( ) 
	end 
	
	function self.btnSaveAs:DoClick( )
		self:GetParent( ):GetParent( ):SaveFile( nil, true ) 
	end 
	
	function self.btnNewTab:DoClick()
		self:GetParent( ):GetParent( ):NewTab( ) 
	end 
	
	function self.btnCloseTab:DoClick()
		self:GetParent( ):GetParent( ):CloseTab( ) 
	end 
	
	function self.btnOptions:DoClick( )
	end 
	
	function self.btnHelp:DoClick( )
		self:GetParent( ):OpenHelper( ) 
	end 
	
	function self.btnWiki:DoClick( )
	end 
end 

local GetLongType = LemonGate.GetLongType 
local function ParseFunction( name, retType, ops ) 
	local funcName = string_match( name, "^[^%(]+" ) 
	local argTypes = string_match( name, "%(([^%)]*)%)" )
	
	local super
	local found, stop = argTypes:find( ":" )
	if found then 
		super = GetLongType( argTypes:sub( 1, stop - 1 ) ) 
		argTypes = argTypes:sub( stop + 1 )
	end 
	
	local _argTypes = argTypes:reverse( ) 
	local buff = ""
	argTypes = "" 
	while #_argTypes > 0 do 
		local shorttp = _argTypes[1] 
		local longtp = GetLongType( shorttp ) 
		if buff or not longtp then 
			buff = shorttp .. buff
			
			if GetLongType( buff ) then 
				longtp = GetLongType( buff )
				buff = "" 
			elseif buff == "..." then 
				argTypes = argTypes .. "...  " 
				_argTypes = "" 
				buff = "" 
				break 
			else 
				_argTypes = _argTypes:sub( 2 )
				continue 
			end 
		end 
		argTypes = argTypes .. longtp .. ", "
		_argTypes = _argTypes:sub( 2 )
	end 
	
	if #buff > 0 then 
		print( funcName )
		print( name )
		print( buff )
		error( "The helper is leaking lemon juice!", 2 ) 
	end 
	
	argTypes = argTypes:sub( 1, -3 ) .. " "
	
	if retType and retType ~= "" then 
		retType = GetLongType( retType ) or ""
	end 
	
	if retType and string_match( retType, "^%s*$" ) then retType = nil end 
	
	return funcName, { comp = super, args = argTypes or "", ret = retType, opcost = ops }
end 

local function SetupHelperFunctions( List, filter )
	if !LemonGate then return end 
	if !LemonGate.FunctionTable then 
		RunConsoleCommand( "lemon_sync" ) 
		timer.Simple( 0.5, function() 
			if !LemonGate.FunctionTable then return end 
			SetupHelperFunctions( List )
		end )
		return 
	end 
	
	// TODO: Do in timer to prevent lag? 
	local FunctionData = LemonGate.HelperFunctionData 
	local count = 0
	filter = filter or ".+" 
	List:Clear( true ) 
	for name, data in pairs( LemonGate.FunctionTable ) do 
		local funcName = string_match( name, "^[^%(]+" ) 
		local argTypes = string_match( name, "%(([^%)]*)%)" ) 
		
		if string_find( name, "***", nil, true ) or string.find( name, "!", nil, true ) then continue end 
		if !string_match( funcName, filter ) then continue end 
		
		List:AddLine( funcName, argTypes, data[2], data[3] ).OnSelect = function( self ) 
			local _, funcData = ParseFunction( name, data[2], data[3] ) 
			print( name )
			print( funcName .. "(" .. argTypes .. (funcData.ret and " " .. data[2]  .. ")" or ")") ) 
			List:GetParent( ).Description:SetText( FunctionData[funcName .. "(" .. argTypes .. (funcData.ret and " " .. data[2] .. ")" or ")")] or ""  ) 
			List:GetParent( ).Syntax:SetText( (funcData.ret and funcData.ret .. " = " or "") .. (funcData.comp and funcData.comp .. ":" or "") .. funcName .. "( " .. funcData.args .. ")" )
		end 
		count = count + 1 
		if count > 250 then break end 
	end 
	
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
	
	/*Helper.Close = function( self ) 
		self:KillFocus( ) 
		self:SetVisible( false ) 
	end */
	
	
	Helper.List = Helper:Add( "DListView" )
	Helper.List:Dock( FILL )
	Helper.List:DockMargin( 5, 5, 5, 5 )
	
	Helper.List:AddColumn( "Function" ):SetWide( 126 )
	Helper.List:AddColumn( "Takes" ):SetWide( 60 )
	Helper.List:AddColumn( "Returns" ):SetWide( 60 )
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
	
	Helper.Search.OnEnter = function( self )
		SetupHelperFunctions( Helper.List, self:GetValue( ) )
	end 
	
	SetupHelperFunctions( Helper.List )
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
