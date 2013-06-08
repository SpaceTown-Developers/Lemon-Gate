/*============================================================================================================================================
	Expression-Advanced Derma
==============================================================================================================================================
	Name: EA_Helper
	Author: Oskar
============================================================================================================================================*/

local LEMON, API = LEMON, LEMON.API

local string_match = string.match 
local string_find = string.find 
local string_reverse = string.reverse 
local string_sub = string.sub 
local string_lower = string.lower 

local table_concat = table.concat

local PANEL = { } 

function PANEL:Init( )
	self:ShowCloseButton( true ) 
	self:SetSizable( true )
	self:SetCanMaximize( false )
	self:SetMinWidth( 300 )
	self:SetMinHeight( 200 )
	self:SetText( "Expression Advanced Helper" )
	self:SetSize( cookie.GetNumber( "eahelper_w", 400 ), cookie.GetNumber( "eahelper_h", 600 ) ) 
	self:SetPos( cookie.GetNumber( "eahelper_x", ScrW( ) / 2 - self.x / 2 ), cookie.GetNumber( "eahelper_y", ScrH( ) / 2 - self.y / 2 ) )
	
	
	self.Description = self:Add( "DTextEntry" ) 
	self.Description:Dock( BOTTOM ) 
	self.Description:DockMargin( 5, 0, 5, 5 ) 
	self.Description:SetMultiline( true )
	self.Description:SetNumeric( false ) 
	self.Description:SetEnabled( false )
	self.Description:SetTall( 70 )
	
	
	self.Syntax = self:Add( "DTextEntry" ) 
	self.Syntax:Dock( BOTTOM ) 
	self.Syntax:DockMargin( 5, 0, 5, 5 ) 
	self.Syntax:SetMultiline( false )
	self.Syntax:SetNumeric( false ) 
	self.Syntax:SetEnabled( false )
	
	
	self.Browser = self:Add( "EA_Browser" )
	self.Browser:Dock( FILL )
	self.Browser:DockMargin( 5, 5, 5, 5 ) 
	
	self:SetupHelperFunctions( )
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

local function NodeClick( self )
	local _, funcData = ParseFunction( self.Data[1], self.Data[4].Return, 0 )
	self.Description:SetText( self.Data[4].Desc or "No description." ) 
	self.Syntax:SetText( (funcData.ret and funcData.ret .. " = " or "") .. (funcData.comp and funcData.comp .. ":" or "") .. self.Data[2] .. "( " .. funcData.args .. ")" )
end

function PANEL:SetupHelperFunctions( filter )
	if not API.Initialized then return end 
	
	// TODO: Do in timer to prevent lag? 
	local DescriptionData = LEMON.HelperData or { }
	filter = filter or ".+" 
	
	self.Classes = { } 
	self.Functions = { }
	self.cFunctions = { }
	
	local cList = { } 
	for Name, Data in pairs( API.Classes ) do
		cList[#cList + 1] = Name 
	end 
	
	table.sort( cList, function(a, b) 
		return string_lower( a[1] ) < string_lower( b[1] ) 
	end ) 
	
	for I = 1, #cList do
		local Name, Data = cList[I], API.Classes[cList[I]]
		local node = self.Browser:AddNode( Name, "fugue/block.png" ) 
		self.Classes[Data.Short] = { Name, node } 
	end
	
	for name, data in pairs( API.Functions ) do 
		local funcName = string_match( name, "^[^%(]+" )
		local argTypes = string_match( name, "%(([^%)]*)%)" )
		
		if string_match( name, "!" ) then print( name ) end 
		
		if string_find( name, "***", nil, true ) then continue end
		if !string_match( string_lower( funcName ), string_lower( filter ) ) then continue end
				
		local Class = string_match( argTypes, "^([^:]+):.*$" )
		
		if self.Classes[Class] then 
			self.cFunctions[Class] = self.cFunctions[Class] or { }
			self.cFunctions[Class][#self.cFunctions[Class] + 1] = { name, funcName, argType, data }
		else 
			self.Functions[#self.Functions + 1] = { name, funcName, argType, data }
		end 
	end
	
	for Class, List in pairs( self.cFunctions ) do
		table.sort( List, function(a, b) 
			return string_lower( a[1] ) < string_lower( b[1] ) 
		end ) 
		
		for I = 1, #List do 
			local Node = self.Classes[Class][2]:AddNode( List[I][1], "fugue/script.png" ) 
			Node.DoClick = NodeClick
			Node.Data = { List[I][1], List[I][2], List[I][3], List[I][4] }
			Node.Description = self.Description
			Node.Syntax = self.Syntax
		end 
	end
	
	table.sort( self.Functions, function(a, b) 
		return string_lower( a[1] ) < string_lower( b[1] ) 
	end ) 
	
	for I = 1, #self.Functions do 
		local Node = self.Browser:AddNode( self.Functions[I][1], "fugue/script.png" ) 
		Node.DoClick = NodeClick
		Node.Data = { self.Functions[I][1], self.Functions[I][2], self.Functions[I][3], self.Functions[I][4] }
		Node.Description = self.Description
		Node.Syntax = self.Syntax
	end 
end

function PANEL:Close( )
	self:SetVisible( false ) 
	cookie.Set( "eahelper_x", self.x )
	cookie.Set( "eahelper_y", self.y )
	cookie.Set( "eahelper_w", self:GetWide( ) )
	cookie.Set( "eahelper_h", self:GetTall( ) )
end

vgui.Register( "EA_Helper", PANEL, "EA_Frame" )
