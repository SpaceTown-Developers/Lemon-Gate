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
local string_format = string.format 
local string_Split = string.Split 

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
		if Class.Name == "int" then return "number" end 
		if Class.Name == "bool" then return "boolean" end 
		return Class.Name or "" 
	end 
	if word == "..." then 
		return "..."
	end 
	error( "this should never be shown!! " .. word ) 
end

local function NodeClick( self ) 
	local Syntax = { }
	local meta, smeta = "", ""
	local Data = self.Data[3]
	
	for i = 1, #Data.Params do Syntax[#Syntax + 1] = GetType( Data.Params[i] ) or "" end
	if string_match( self.Data[1], ":" ) then 
		meta = table.remove( Syntax, 1 ) .. ":" 
		smeta = table.remove( Data.Params, 1 ) .. ":"
	end 
	
	local FuncName = string_format( "%s(%s%s)", string_match( self.Data[1], "^[^%(]+" ), smeta .. table_concat( Data.Params, "," ) , #Data.Return > 0 and "=" .. Data.Return or "" )
	
	self.Description:SetText( #LEMON.API.HelperData[FuncName] > 0 and LEMON.API.HelperData[FuncName] or "No description." ) 
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
		if Name == "..." or Name == "bool" or Name == "int" then continue end 
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
			-- Data[2]:Remove( ) 
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


/*============================================================================================================================================
	Helper Generator
============================================================================================================================================*/

local function DumpHelperData( ) 
	local HelperData = LEMON.API.HelperData 
	local FuncData, EventData = { }, { } 
	local DocumentedFunctions, DocumentedEvents = 0, 0
	
	for name, data in pairs( API.Functions ) do 
		if string_find( name, "***", nil, true ) then print( name ) continue end 
		local params = table.Copy( data.Params )
		local meta = ""
		
		if string_match( name, ":" ) then meta = table.remove( params, 1 ) .. ":" end 
		
		local _name = string_match( name, "^[^%(]+" )  .. "(" .. meta .. table_concat( params, "" )  .. (#data.Return > 0 and " " .. data.Return .. ")" or ")") 
		name = string_match( name, "^[^%(]+" )  .. "(" .. meta .. table_concat(params, "," )  .. (#data.Return > 0 and "=" .. data.Return .. ")" or ")") 
		local data = data.Desc or ( #HelperData[name]>0 and HelperData[name] or HelperData[_name] )
		
		DocumentedFunctions = DocumentedFunctions + (#data > 0 and 1 or 0)
		FuncData[#FuncData + 1] = string_format( "\nData[%q] = %q", name, data )
	end 
	
	for name, data in pairs( API.Events ) do 
		local _name = name .. "<" .. table_concat( data.Params, "" ) .. (#data.Return > 0 and " " .. data.Return .. ">" or ">")
		name = name .. "<" .. table_concat( data.Params, "," ) .. (#data.Return > 0 and "=" .. data.Return .. ">" or ">")
		local data = #HelperData[name]>0 and HelperData[name] or HelperData[_name] 
				
		DocumentedEvents = DocumentedEvents + (#data > 0 and 1 or 0)
		EventData[#EventData + 1] = string_format( "\nData[%q] = %q", name, data )
	end 
	
	table.sort( FuncData ) 
	table.sort( EventData ) 
	
	print( "Total functions: " .. #FuncData ) 
	print( "Total events: " .. #EventData ) 
	print( )
	print( "Documented functions: " .. DocumentedFunctions ) 
	print( "Documented events: " .. DocumentedEvents ) 
	print( )
	print( "Undocumented functions: " .. #FuncData - DocumentedFunctions ) 
	print( "Undocumented events: " .. #EventData - DocumentedEvents ) 
	print( )
	print( "Generated at: " .. os.date( ) )
	
	local f = file.Open( "ea_dump_helper.txt", "w", "DATA" ) 
	
	f:Write "local Data = LEMON.API.HelperData"
	
	f:Write( "\n" )
	f:Write( "\n/*---------------------------------------------------------------------------" )
	f:Write( "\n\tTotal functions: " .. #FuncData ) 
	f:Write( "\n\tTotal events: " .. #EventData ) 
	f:Write( "\n\t" )
	f:Write( "\n\tDocumented functions: " .. DocumentedFunctions ) 
	f:Write( "\n\tDocumented events: " .. DocumentedEvents ) 
	f:Write( "\n\t" )
	f:Write( "\n\tUndocumented functions: " .. #FuncData - DocumentedFunctions ) 
	f:Write( "\n\tUndocumented events: " .. #EventData - DocumentedEvents ) 
	f:Write( "\n\t" )
	f:Write( "\n\tGenerated at: " .. os.date( ) )
	f:Write( "\n---------------------------------------------------------------------------*/" )
	f:Write( "\n" )
	
	f:Write( "\n/*---------------------------------------------------------------------------\n\tEvents\n---------------------------------------------------------------------------*/" ) 
	local last = ""
	for i = 1, #EventData do
		if EventData[i][8] > last then 
			f:Write( "\n\n// " .. EventData[i][8]:upper( ) )
			last = EventData[i][8]
		end 
		f:Write( EventData[i] )
	end
	
	f:Write( "\n\n/*---------------------------------------------------------------------------\n\tFunctions\n---------------------------------------------------------------------------*/" ) 
	local last = ""
	for i = 1, #FuncData do
		if FuncData[i][8] > last then 
			f:Write( "\n\n// " .. FuncData[i][8]:upper( ) )
			last = FuncData[i][8]
		end 
		f:Write( FuncData[i] )
	end
	
	f:Close( ) 
	
	print( ) 
	print( "Data dumped to ea_dump_helper.txt" )
end 

concommand.Add( "lemon_dump_helper", DumpHelperData )


/*============================================================================================================================================
	Wiki Generator
============================================================================================================================================*/

local function convert( name, desc ) 
	local meta, args, ret
	local nicename = string_match( name, "[^%(]+" ) 
		
	if string_match( name, ":" ) then 
		meta = GetType( string_match( name, "%(([^:]+):" ) )
		meta = meta[1]:upper( ) .. meta:sub( 2 ) 
		args = string_Split( string_match( name, ":([^%()=]*)" ) or "", "," ) 
	else 
		args = string_Split( string_match( name, "%(([^%()=]*)" ) or "", "," ) 
	end 
	
	if #args <= 1 then 
		if #args[1] < 1 then args = {} end 
	end 
	
	if string_match( name, "=" ) then 
		ret = GetType( string_match( name, "=([^%)]+)") )
		ret = ret[1]:upper( ) .. ret:sub( 2 ) 
	end 
	
	local params = {}
	for i = 1, #args do 
		local name = GetType( args[i] ) 
		name = name[1]:upper( ) .. name:sub( 2 ) 
		params[#params+1] = name
	end 
	
	local func = string_format( "%s%s(%s)", meta and meta .. ":" or "" ,nicename, table.concat( params, ", " ) )
	
	return string_format( "| %s || %s || %s" , func, ret or "Void", desc ) 
end 

local function DumpWikiData( ) 
	local WikiData = { } 
	for k, v in pairs( LEMON.API.HelperData ) do 
		if string_match( k, "[<>]" ) then continue end 
		WikiData[#WikiData+1] = k 
	end 
	
	table.sort( WikiData ) 
	
	local f = file.Open( "ea_dump_wiki.txt", "w", "DATA" ) 
	
	f:Write( "=Stock functions=" )
	f:Write( "\n\n== A ==" )
	f:Write( "\n{|class=\"wikitable\" style=\"text-align: left;\"" )
	f:Write( "\n!|Function" )
	f:Write( "\n!|Return" )
	f:Write( "\n!|Description" )
	
	local last = "a"
	for i = 1, #WikiData do
		if WikiData[i][1] > last then 
			last = WikiData[i][1]
			f:Write( "\n|}" ) 
			f:Write( "\n\n== " .. WikiData[i][1]:upper( ) .. " ==" )
			f:Write( "\n{|class=\"wikitable\" style=\"text-align: left;\"" )
			f:Write( "\n!|Function" )
			f:Write( "\n!|Return" )
			f:Write( "\n!|Description" )
		end
		f:Write( "\n|-" )
		f:Write( "\n" .. convert( WikiData[i], LEMON.API.HelperData[WikiData[i]] ) ) 
	end
	
	f:Write( "\n|}" )
	f:Close( ) 
	
	print( "Data dumped to ea_dump_wiki.txt" )
end 

concommand.Add( "lemon_dump_wiki", DumpWikiData )
