/*============================================================================================================================================
	Expression-Advanced Derma
==============================================================================================================================================
	Name: EA_Helper
	Author: Oskar
============================================================================================================================================*/

local LEMON, API, HelperData = LEMON, LEMON.API, LEMON.API.HelperData

local string_match = string.match 
local string_find = string.find 
local string_reverse = string.reverse 
local string_sub = string.sub 
local string_lower = string.lower 
local string_format = string.format 

local table_concat = table.concat 
local table_Copy = table.Copy 

local PANEL = { } 

function PANEL:Init( )
	self:ShowCloseButton( true ) 
	self:SetSizable( true ) 
	self:SetCanMaximize( false ) 
	self:SetMinWidth( 300 ) 
	self:SetMinHeight( 200 ) 
	self:SetIcon( "fugue/magnifier.png" )
	self:SetText( "Expression Advanced Helper" ) 
	self:SetSize( cookie.GetNumber( "eahelper_w", 400 ), cookie.GetNumber( "eahelper_h", 600 ) ) 
	self:SetPos( cookie.GetNumber( "eahelper_x", ScrW( ) / 2 - self:GetWide( ) / 2 ), cookie.GetNumber( "eahelper_y", ScrH( ) / 2 - self:GetTall( ) / 2 ) ) 
	
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
	
	self.Search = self:Add( "DTextEntry" ) 
	self.Search:Dock( TOP ) 
	self.Search:DockMargin( 5, 5, 5, 0 ) 
	self.Search:SetMultiline( false ) 
	self.Search.OnEnter = function( Search ) 
		self:SetupHelperFunctions( Search:GetValue( ) ) 
	end 
	
	self.Browser = self:Add( "EA_Browser" ) 
	self.Browser:Dock( FILL ) 
	self.Browser:DockMargin( 5, 5, 5, 5 ) 
	
	self:SetupHelperFunctions( ) 
end

local function GetType( word )
	local Class = API:GetClass( word, true ) 
	if Class then 
		return Class.Name
	end 
end

local function NodeClick( self ) 
	local Syntax = { }
	local meta = ""
	local Data = self.Data[3]
	
	local FuncName = string_format( "%s(%s%s)", string_match( self.Data[1], "^[^%(]+" ), string_match( self.Data[1], "%(([^%)]*)%)" ), #Data.Return > 0 and " " .. Data.Return or "" )
	
	for i = 1, #Data.Params do Syntax[#Syntax + 1] = GetType( Data.Params[i] ) or "" end
	if string_match( self.Data[1], ":" ) then meta = table.remove( Syntax, 1 ) .. ":" end 
	
	self.Description:SetText( #HelperData[FuncName] > 0 and HelperData[FuncName] or "No description." ) 
	self.Syntax:SetText( (#Data.Return > 0 and GetType( Data.Return ) .. " = " or "") .. meta .. string_match( self.Data[1], "^[^%(]+." ) .. table_concat( Syntax, ", " ) .. ")" )
end

function PANEL:SetupHelperFunctions( filter )
	if not API.Initialized then return end 
	
	self.Browser:Clear( ) 
	
	// TODO: Do in timer to prevent lag?
	// Or use a coroutine =D
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
		
		if string_find( name, "***", nil, true ) then continue end
		if not string_find( string_lower( funcName ), string_lower( filter ) ) then continue end 
				
		local Class = string_match( argTypes, "^([^:]+):.*$" )
		local Syntax = {}
		
		if self.Classes[Class] then 
			for i = 2, #data.Params do Syntax[#Syntax + 1] = GetType( data.Params[i] ) or "" end
			
			self.cFunctions[Class] = self.cFunctions[Class] or { }
			self.cFunctions[Class][#self.cFunctions[Class] + 1] = { 
				name, 
				string_format( 
					"%s%s:%s(%s)", 
					#data.Return > 0 and GetType(data.Return) .. "    " or "", 
					GetType(Class), 
					funcName, 
					table_concat( Syntax, ", " ) 
					-- string_match( argTypes, "^[^:]+:(.*)$" ) 
				) or "", 
				data 
			}
		else 
			for i = 1, #data.Params do Syntax[#Syntax + 1] = GetType( data.Params[i] ) or "" end
			
			self.Functions[#self.Functions + 1] = { 
				name, 
				string_format( 
					"%s%s(%s)", 
					#data.Return > 0 and GetType(data.Return) .. "    " or "", 
					funcName, 
					table_concat( Syntax, ", " ) 
					-- argTypes 
				), 
				data 
			}
		end
	end
	
	for Class, List in pairs( self.cFunctions ) do
		table.sort( List, function(a, b) 
			-- return string_lower( a[2] ) < string_lower( b[2] ) 
			return string_lower( a[1] ) < string_lower( b[1] ) 
		end ) 
		
		for I = 1, #List do 
			local Node = self.Classes[Class][2]:AddNode( List[I][2], "fugue/script.png" ) 
			Node.DoClick = NodeClick
			Node.Data = table_Copy( List[I] ) 
			Node.Description = self.Description
			Node.Syntax = self.Syntax
		end 
	end 
	
	for Class, Data in pairs( self.Classes ) do
		if not self.cFunctions[Class] then 
			Data[2]:Remove( ) 
		end 
	end
	
	table.sort( self.Functions, function(a, b) 
		-- return string_lower( a[2] ) < string_lower( b[2] ) 
		return string_lower( a[1] ) < string_lower( b[1] ) 
	end ) 
	
	for I = 1, #self.Functions do 
		local Node = self.Browser:AddNode( self.Functions[I][2], "fugue/script.png" ) 
		Node.DoClick = NodeClick
		Node.Data = table_Copy( self.Functions[I] ) 
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
