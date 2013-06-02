/*==========================================================================
	Expression Advanced: API
		- Rusketh
		- Oskar94
		- Syanide
==========================================================================*/
AddCSLuaFile( "includes/modules/von.lua" )
require( "von" )

LEMON = LEMON or { Ver = "2.0.0", API = { Util = { Cache = { } } } }

/*==========================================================================
	API - Definitions
==========================================================================*/
local API, Util = LEMON.API, LEMON.API.Util
API.BaseClass, API.BaseComponent = { }, { }
	
local Class, Component = API.BaseClass, API.BaseComponent
Class.__index, Component.__index = Class, Component

/*=============================================================================
	Util - Simple stuff!
=============================================================================*/
local Format = string.format
local error, type = error, type

function Util.StackError( N, Message, A, ... )
	local Info = debug.getinfo( 1 + N )
	if A then Message = Format( Message, A, ... ) end
	error( Format( "%s @%s - %s:%s", Message, Info.name or "?", Info.short_src, Info.linedefined), 0 )
end

function Util.CheckParams( N, Value, Type, Nil, Next, ... )
	    if !N then return 
	elseif !(Nil and Value == nil) and type( Value ) ~= Type then
		Util.StackError( N + 1, "Lemon-Core: Invalid argument #%i, (%s) expected got (%s)", N, Type, type(Value) )
	elseif Next then
		Util.CheckParams( N + 2, Next, ... )
	end
end

function Util.ValueToLua( Value, NoTables )
	local Type = type(Value)
	
	if Type == "nil" then
		return "nil"
	elseif Type == "number" then
		return Value
	elseif Type == "string" then
		return Format( "%q", Value )
	elseif Type == "boolean" then
		return Value and "true" or "false"
	elseif Type == "table" and !NoTables then
		return Util.TableToLua( Value )
	elseif Type == "function" and !NoTables then
		local Index = #Util.Cache + 1
		Util.Cache[Index] = Value
		return "LEMON.API.Util.Cache[" .. Index .. "]"
	end
end

function Util.TableToLua( Table )
	local Lua = "{"
	
	for Key, Value in pairs(Table) do
		local kLua = Util.ValueToLua( Key, true )
		local vLua = Util.ValueToLua( Value )
		
		if !kLua then
			error("TableToLua invalid Key of type " .. type(Key))
		elseif !vLua then
			error("TableToLua invalid Value of type " .. type(Value))
		end
		
		Lua = Lua .. "[" .. kLua .. "] = " .. vLua .. ", "
	end
	
	return Lua .. "}"
end

/*==============================================================================================
	Section: Prop Friending
==============================================================================================*/
function Util.GetOwner( Entity )
	local Owner = Entity:GetOwner( )
	if Entity.Player then Owner = Entity.Player end
	if CPPI then Owner = Entity:CPPIGetOwner( ) or Owner end

	return Owner
end

function Util.IsOwner(Player, Entity)
	local Owner = Util.GetOwner( Entity )
	if !Owner then return false end
	return Player == Owner
end

function Util.IsFriend(Owner, Player)
	if CPPI then 
		local Friends = Owner:CPPIGetFriends( )
		if type( Friends ) == "table" then 
			for _, Friend in pairs( Friends ) do
				if Friend == Player then return true end
			end
		end
	end 
	return Owner == Player 
end

/*==========================================================================
	Section: API
==========================================================================*/
function API:Init( )
	MsgN( "Loading LemonGate:" )
	
	self.Classes = { }
	self.ClassLU = { }
	self.Operators = { }
	self.Functions = { }
	self.Events = { }
	self.Exceptions = { }
	
	self.Components = { }
	self.ComponentLK = { }
	
	self.Externals = { }
	self.Raw_Externals = { }
	
	MsgN( "Loading compiler." )
	include( "lemongate/compiler/init.lua" )
	
	if SERVER then
		self.Config = util.KeyValuesToTable( file.Read("lemon_config.txt") or "" ) or { }
	else
		self.Config = self.DataPack.Config
	end
	
	MsgN( "Loading components." )
	self:LoadCoreComponents( ) 
	self:LoadCustomComponents( "lemongate/components/custom" ) 
	self:LoadCustomComponents( GAMEMODE.FolderName .. "/gamemode/EAComponents" )
	self:LoadEditor( )
	
	hook.Call( "PRE_LEMONGATE", GAMEMODE or GM )
	
	self:InstallComponents( )
	
	hook.Call( "POST_LEMONGATE", GAMEMODE or GM )
	
	if SERVER then
		self:SaveConfig( )
		self:BuildDataPack( )
		
		for _, Player in pairs( player.GetHumans( ) ) do
			self:SendDataPack( Player )
		end
		
		self:ReloadEntitys( )
	end
	
	self.Initialized = true
end

if SERVER then
	function API:SaveConfig( )
		file.Write("lemon_config.txt", util.TableToKeyValues( self.Config ) )
	end
end

function API:LoadCoreComponents( )
	if SERVER then
		MsgN( "[LemonGate] Loading built in components." )
		include( "lemongate/components/core.lua" )
		include( "lemongate/components/number.lua" )
		include( "lemongate/components/string.lua" )
		include( "lemongate/components/vector.lua" )
		include( "lemongate/components/angle.lua" )
		include( "lemongate/components/entity.lua" )
		include( "lemongate/components/color.lua" )
		include( "lemongate/components/events.lua" )
		
		include( "lemongate/components/lambda.lua" )
		include( "lemongate/components/table.lua" )
		include( "lemongate/components/hologram.lua" )
		include( "lemongate/components/communicate.lua" )
	end
end

function API:LoadCustomComponents( Path, Recursive )
	if not Path then return end 
	MsgN( "[LemonGate] Loading custom components." ) 
	
	while Path:match( "//" ) do 
		Path = Path:gsub( "//", "/" )
	end 
	
	local Files = file.Find( Path .. "*.lua", "LUA" ) 
	local _, Folders = file.Find( Path .. "*", "LUA" ) 
	
	for _, fName in pairs( Files or { } ) do
		local File = Path .. fName
		
		-- When and if server <> client files need to be separated
		if fName:match( "^cl_" ) then
			if SERVER then AddCSLuaFile( File ) else include( File ) end
		elseif fName:match( "^sh_" ) then
			if SERVER then AddCSLuaFile( File ) end
			include( File )
		else
			if SERVER then include( File ) end
		end
	end
	
	if Recursive and #Folders > 0 then 
		for _, sFolder in pairs( Folders ) do 
			self:LoadCustomComponents( Path .. Folder, true )
		end 
	end 
end

function API:LoadEditor( )
	if CLIENT then
		if LEMON.Editor then 
			if ValidPanel( LEMON.Editor.Instance ) then 
				LEMON.Editor.Instance:Close( )
				LEMON.Editor.Instance:Remove( ) 
			end 
			LEMON.Editor = nil 
		end 
		
		include( "lemongate/editor/ea_button.lua" )
		include( "lemongate/editor/ea_closebutton.lua" )
		include( "lemongate/editor/ea_editor.lua" )
		include( "lemongate/editor/ea_editorpanel.lua" )
		include( "lemongate/editor/ea_filenode.lua" )
		include( "lemongate/editor/ea_frame.lua" )
		-- include( "lemongate/editor/ea_helperdata.lua" )
		include( "lemongate/editor/ea_hscrollbar.lua" )
		include( "lemongate/editor/ea_imagebutton.lua" )
		include( "lemongate/editor/ea_toolbar.lua" )
		include( "lemongate/editor/syntaxer.lua" )
		
		include( "lemongate/editor.lua" )
	end
end

/*==========================================================================
	Section: API Hooks and Entity Managment
==========================================================================*/
if SERVER then
	function API:CallHook( Hook, ... )		
		if self[Hook] then
			local A, B, C = self[Hook]( self, ... )
			if A ~= nil then return A, B, C end
		end
		
		for _, Component in pairs( self.Components ) do
			local A, B, C = Component:CallHook( Hook, ... )
			if A ~= nil then return A, B, C end
		end
	end

	local Gate_Entitys = { }

	function API:ReloadEntitys( )
		Gate_Entitys = { }
		local Entitys = ents.FindByClass( "lemongate" )
		
		for _, Entity in pairs( Entitys ) do
			Entity:ShutDown( )
			self:CallHook( "Remove", Entity )
		end
		
		for _, Entity in pairs( Entitys ) do
			self:CallHook( "Create", Entity )
			Entity:LoadScript( Entity:GetScript( ) )
		end
	end

	function API:Create( Entity )
		Gate_Entitys[ Entity ] = Entity
	end

	function API:Remove( Entity )
		Gate_Entitys[ Entity ] = nil
	end

	function API:GetEntitys( )
		return Gate_Entitys
	end -- Force use of API!
end
/*==========================================================================
	Section: DataPack
==========================================================================*/
if SERVER then
	function API:BuildDataPack( )
		MsgN( "Building LemonGate Datatpack..." )
		
		local Cls, Ops, Funcs, Exts = { }, { }, { }, { }
		
		local DataPack = {
			Config = self.Config,
			Classes = Cls,
			Operators = Ops,
			Functions = Funcs,
			Events = self.Events,
			Externals = self.Raw_Externals,
			Exceptions = self.Exceptions,
			Components = ComponentLK,
		}
		
		for Name, Class in pairs( self.Classes ) do
			Cls[ Name ] = {
				Name = Name,
				Short = Class.Short,
				UpCast = Class.UpCast,
				DownCast = Class.DownCast,
				Default = Class.Default,
				WireName = Class.WireName,
				Wire_In = (Class.Wire_In ~= nil),
				Wire_Out = (Class.Wire_Out ~= nil),
			}
		end
				
		for Signature, Data in pairs( self.Operators ) do
			Ops[ Signature ] = Data.DataPack
			Data.DataPack = nil -- Clear up some memory!
		end
		
		for Signature, Data in pairs( self.Functions ) do
			Funcs[ Signature ] = Data.DataPack
			Data.DataPack = nil -- Clear up some memory!
		end
			
		-- JSON corupts easily!
		self.DataPack = util.Compress( von.serialize( DataPack ) ) -- Util.ValueToLua( DataPack ) )
		
		MsgN( Format( "Datatpack compressed %d bytes.", #self.DataPack  ) )
		
		hook.Add( "PlayerInitialSpawn", "Lemon_DataPack", function( Player )
			self:SendDataPack( Player )
		end ) -- Its better here!
	end
	
	util.AddNetworkString( "lemon_datapack" )
	
	function API:SendDataPack( Player )
		net.Start( "lemon_datapack" )
			net.WriteData( self.DataPack, #self.DataPack )
		net.Send( Player )
	end

else
	net.Receive( "lemon_datapack", function( Bytes )
		-- RunString( " LEMON.API.DataPack = " .. util.Decompress( net.ReadData( Bytes ) ) )
		MsgN( Format( "Recived LemonGate Data Pack (%d bytes)", Bytes / 8 ) )
		
		LEMON.API.DataPack = von.deserialize( util.Decompress( net.ReadData( Bytes / 8 ) ) )
		
		API:Init( ) -- Load on client!
	end )
end
/*==========================================================================
	Section: Components
==========================================================================*/
if SERVER then
	function API:NewComponent( Name, Enabled )
		
		Util.CheckParams( 1, Name, "string", false, Enabled, "boolean", true )
		
		local New = setmetatable( {
				Name = Name,
				LName = string.lower( Name ),
				Default = Enabled or true,
				Enabled = tobool( API.Config[ string.lower( Name ) ] ) or Enabled or true,
				
				Classes = { }, -- Class's by Name.
				Operators = { }, -- Operators.
				Functions = { },  -- Functions.
				
				Exceptions = { },
				Externals = { },
				Events = { },
			}, Component )
			
		self.Components[ New.LName ] = New
		
		return New
	end
	
	function API:GetComponent( Name, Error )
		Util.CheckParams( 1, Name, "string", false, Error, "boolean", true )
		
		local Component = self.Components[ string.lower( Name ) ]
		if !Component and Error then
			Util.StackError( 1, "Component %s does not exist", Name )
		end
		
		return Component
	end

	function Component:CallHook( Hook, ... )
		if self[Hook] and self.Enabled then
			return self[Hook]( self, ... )
		end
	end

	function Component:Enable( )
		local Check = API.Config[ self.LName ]
		
		if Check == nil then
			Check = self.Default
		end
		
		if Check and self:CallHook( "OnEnable" ) then
			Check = false -- OnEnabled returned true
		end
		
		self.Enabled = Check or false
		
		if self.Enabled then
			self.ID = #API.ComponentLK + 1
			API.ComponentLK[ self.ID ] = self.Name
			API.Config[ self.LName ] = tostring( Check )
		end
		
		return Check
	end
end

/*==========================================================================
	Section: API
==========================================================================*/
function API:InstallComponents( )
	if SERVER then
	
	-- Sort Classes
		for Name, Comp in pairs ( self.Components ) do
			Comp:Enable( )
			Comp:LoadClasses( )
		end
		
		for Name, Class in pairs ( self.Classes ) do
			if Class.ExtendsClass then
				local BaseClass = self:GetClass( Class.ExtendsClass, true )
				
				if !BaseClass then
					MsgN( Format( "Class %q unable to extend non existing class %q.", Name, Class.ExtendsClass ) )
					MsgN( "Unexpected behavior may occur." )
				else
					Class.DownCast = BaseClass.Short
					BaseClass.UpCast[ Class.Short ] = Class.Short
					Class._Default = Class._Default or BaseClass._Default
				end
			end
			
			Class.Default = Util.ValueToLua( Class._Default, false )
		end
	
	-- Sort Components
		for Name, Comp in pairs ( self.Components ) do
			Comp:LoadOperators( )
			Comp:LoadFunctions( )
			Comp:LoadEvents( )
			Comp:LoadExternals( )
			Comp:LoadExceptions( )
		end
		
	elseif CLIENT then
	
		local DataPack = self.DataPack
		local Ops, Funcs = self.Operators, self.Functions
		
		self.Classes = DataPack.Classes
		self.Events = DataPack.Events
		self.Raw_Externals = DataPack.Externals
		self.Exceptions = DataPack.Exceptions
		self.Components = DataPack.Components
		
		for _, Class in pairs( self.Classes ) do
			self.ClassLU[Class.Short] = Class
		end
		
		for Signature, Data in pairs( DataPack.Operators ) do
			self:NewOperator( Data.Component, Data.Name, Data.Signature, Data.Params, Data.Return, Data.Perf, Data.First, Data.Second )
		end
		
		for Signature, Data in pairs( DataPack.Functions ) do
			self:NewFunction( Data.Component, Data.Name, Data.Signature, Data.Params, Data.Return, Data.Perf, Data.First, Data.Second, Data.Desc )
		end
	end
end

/*==========================================================================
	Section: Classes
==========================================================================*/
function API:GetClass( RawName, NoError )
	Util.CheckParams( 1, RawName, "string", false, NoError, "boolean", true )
	
	local Name = string.lower( RawName )
	local Class = self.Classes[ Name ]
	
	if Class then return Class end
	
	if #Name > 1 then Name = "x" .. Name end
	
	local Class = self.ClassLU[ Name ]
	
	if Class then return Class end
	
	if !NoError then
		debug.Trace( )
		Util.StackError( 1, "Class %s can not be found, and probably doesn't exist.", RawName )
	end
end

if SERVER then
	function Component:NewClass( Short, Name, Default )
		Util.CheckParams( 1, Name, "string", false, Short, "string", false )
		
		if #Short > 1 then Short = "x" .. Short end
		
		local New = setmetatable( {
				Name = Name,
				Short = string.lower( Short ),
				_Default = Default,
				UpCast = { }
			}, Class )
		
		New.Component = self.ID
		self.Classes[ string.lower( Name ) ] = New
		
		return New
	end

	function Class:Extends( Class )
		Util.CheckParams( 1, Class, "string", false )
		
		if self.ExtendsClass then
			Util.StackError( 1, "Class %s can not extend 2 classes, it already extends %s", self.Name, Class )
		end
		
		self.ExtendsClass = Class
	end
	
	function Class:Wire_Name( Name )
		self.WireName = Name
	end

	function Component:LoadClasses( )
		if self.Enabled then
			self:CallHook( "BuildClasses" )
			
			for LName, Class in pairs( self.Classes ) do
				API.Classes[LName] = Class
				API.ClassLU[Class.Short] = Class
			end
		end
	end
end


/*==========================================================================
	Section: Perf Pricing
==========================================================================*/
LEMON_PERF_CHEAP = 1
LEMON_PERF_NORMAL = 5
LEMON_PERF_ABNORMAL = 10
LEMON_PERF_EXPENSIVE = 20

if SERVER then
	Component.Perf = LEMON_PERF_NORMAL

	function Component:SetPerf( Value )
		Util.CheckParams( 1, Value, "number", false )
		self.Perf = Value
	end

/*==========================================================================
	Section: Operators
==========================================================================*/
	function Component:AddOperator( Name, Params, Return, First, Second )
		Util.CheckParams( 1, Name, "string", false, Params, "string", false, Return, "string", false, First, "string", false, Second, "string", true )
		
		self.Operators[  #self.Operators + 1 ] = {
			Name = Name,
			Params = Params,
			Return = Return,
			Perf = self.Perf,
			First = First,
			Second = Second
		}
	end

	function Component:AddReversableOperator( Name, Params, Return, First, Second )
		Util.CheckParams( 1, Name, "string", false, Params, "string", false, Return, "string", false, First, "string", false, Second, "string", true )
		
		local S = Find( Params, ",", 0, true )
		self:AddOperator( Name, Params, Return, First, Second )
		
		if S then -- Now S+N will become N+S
			local Params = string.sub( Params, 1, S - 1 ) .. string.sub( Params, S + 1 )
			self:AddOperator( Name, Params, Return, First, Second )
		end
	end
	
	function Component:LoadOperators( )
		if self.Enabled then
			self:CallHook( "BuildOperators" )
			
			local Operators = self.Operators
			
			for I = 1, #Operators do
				local Data = Operators[I]
				
				local Signature, Params, Locked = "", { }, false
				local Return = API:GetClass( Data.Return, true ) -- Null class to be added!
				
				if !Return and Data.Return ~= "" and Data.Return ~= "..." then -- Only operators can return VarArg!
					MsgN ( Format( "%s can't register operator %s(%s)\nclass %q doesn't exist." , self.Name, Data.Name, Data.Params, Data.Return ) )
					continue
				end
				
				for _, Param in string.gmatch( Data.Params, "()(%w+)%s*([%[%]]?)()" ) do
					local Class = API:GetClass( Param, true )
					
					if !Class then
						MsgN( Format( "%s can't register operator %s(%s)\nclass %q doesn't exist." , self.Name, Data.Name, Data.Params, Param ) )
						continue
					else
						Params[#Params + 1] = Class.Short
						Signature = Signature .. Class.Short
					end
				end
				
				if string.Right( Data.Params, 3 ) == "..." then
					Params[#Params + 1] = "..."
					Signature = Signature .. "..."
				end
				
				API:NewOperator( self.ID, Data.Name, Signature, Params, Data.Return, Data.Perf, Data.First, Data.Second )
			end
		end
	end
end

function API:NewOperator( Component, Name, Signature, Params, Return, Perf, First, Second )
	local TrueSignature = Format( "%s(%s)",Name, Signature )
	
	self.Operators[ TrueSignature ] = {
		Compile = self:BuildFunction( TrueSignature, Perf, Params, Return, First, Second ),
		Component = Component,
		Params = Params,
		Return = Return,
		
		DataPack = SERVER and { 
			Component = Component,
			Name = Name,
			Signature = Signature,
			Params = Params,
			Return = Return,
			Perf = Perf,
			First = First,
			Second = Second
		} or nil,
	}
end

/*==========================================================================
	Section: Functions
==========================================================================*/
if SERVER then
	function Component:AddFunction( Name, Params, Return, First, Second, Desc )
		Util.CheckParams( 1, Name, "string", false, Params, "string", false, Return, "string", false, First, "string", false, Second, "string", true, Desc, "string", true )
		
		self.Functions[  #self.Functions + 1 ] = { 
			Name = Name,
			Params = Params,
			Return = Return,
			Perf = self.Perf,
			First = First,
			Second = Second,
			Desc = Desc
		}
	end

	function Component:LoadFunctions( )
		if self.Enabled then
			self:CallHook( "BuildFunctions" )
			
			local Functions = self.Functions
			
			for I = 1, #Functions do
				local Data = Functions[I]
				-- local Name, ParamTypes, ReturnType, Perf, First, Second, Desc = Data[1], Data[2], Data[3], Data[4], Data[5], Data[6], Data[7], Data[8], Data[9]
				
				local Signature, Params, Optional, Locked = "", { }, false, false
				local Return = API:GetClass( Data.Return, true )
				
				if !Return and Data.Return ~= "" then
					MsgN( Format( "%s can't register function %s[%s]\nclass %q doesn't exist." , self.Name, Data.Name, Data.Params, Data.Return ) )
					continue
				end
				
				for Char, Param, Bracket in string.gmatch( Data.Params, "()(%w+)%s*([%[%]]?)()" ) do
					
					local Class = API:GetClass( Param, true )
					
					if !Class then
						MsgN( Format( "%s can't register function %s(%s)\nclass %q doesn't exist." , self.Name, Data.Name, Data.Params, Param ) )
						continue
					else
						Params[#Params + 1] = Class.Short
						Signature = Signature .. Class.Short
					end
					
					if Char == 1 and Data.Params[ #Param + 1] == ":" then
						Signature = Signature .. ":"
					elseif Bracket == "[" and !Optional then
						Optional = true
					end 
					
					if Optional then
						API:NewFunction( self.ID, Data.Name, Signature, Params, Data.Return, Data.Perf, Data.First, Data.Second, Data.Desc )
					end
				end
				
				if string.Right( Data.Params, 3 ) == "..." then
					Params[#Params + 1] = "..."
					Signature = Signature .. "..."
					
					if Optional then
						API:NewFunction( self.ID, Data.Name, Signature, Params, Data.Return, Data.Perf, Data.First, Data.Second, Data.Desc )
					end
				end
				
				if !Optional then
					API:NewFunction( self.ID, Data.Name, Signature, Params, Data.Return, Data.Perf, Data.First, Data.Second, Data.Desc )
				end -- If optional is true then its already registered!
			end
		end
	end
end

function API:NewFunction( Component, Name, Signature, Params, Return, Perf, First, Second, Desc )
	local TrueSignature	= Format( "%s(%s)", Name, Signature )
	
	self.Functions[ TrueSignature ] = {
		Compile = self:BuildFunction( TrueSignature, Perf, Params, Return, First, Second ),
		Component = Component,
		Params = Params,
		Return = Return,
		Desc = Desc,
		
		DataPack = SERVER and {
			Component = Component,
			Name = Name,
			Signature = Signature,
			Params = Params,
			Return = Return,
			Perf = Perf,
			First = First,
			Second = Second,
			Desc = Desc } or nil,
	}
end

/*==========================================================================
	Section: Events
==========================================================================*/
if SERVER then
	function Component:AddEvent( Name, Params, Return )
		Util.CheckParams( 1, Name, "string", false, Params, "string", false, Return, "string", false )
		self.Events[ #self.Events + 1 ] = { Name, Params, Return, self.Perf }
	end
	
	function Component:LoadEvents( )
		if self.Enabled then
			self:CallHook( "BuildEvents" )
			
			local Events = self.Events
			
			for I = 1, #Events do
				local Name, ParamTypes, ReturnType, Perf = unpack( Events[I] )
				local Params, Return = { }, nil
				
				Return = API:GetClass( ReturnType, true )
				
				if !Return and ReturnType ~= "" then
					MsgN ( Format( "%s can't register event %s(%s)\nclass %q doesn't exist." , self.Name, Name, ParamTypes, ReturnType ) )
					continue
				end
			
				for _, Param in string.gmatch( ParamTypes, "()(%w+)%s*([%[%]]?)()" ) do
					local Class = API:GetClass( Param, true )
					
					if !Class then
						MsgN( Format( "%s can't register event %s(%s)\nclass %q doesn't exist." , self.Name, Name, ParamTypes, Param ) )
						continue
					else
						Params[#Params + 1] = Class.Short
					end
				end
				
				API:NewEvent( self.ID, Name, Params, ReturnType, Perf )
			end
		end
	end
	
	function API:NewEvent( Component, Name, Params, Return, Perf )
		self.Events[ Name ] = {
			Component = Component,
			Name = Name,
			Params = Params,
			Return = Return,
			Perf = Perf,
		}
	end
	
	function API:CallEvent( Name, ... )
		if self.Events[ Name ] then
			for _, Gate in pairs( self:GetEntitys( ) ) do
				local Result = Gate:CallEvent( Name, ... )
				if Result then return Result end
			end
		end
	end

/*==========================================================================
	Section: Externals
==========================================================================*/
	function Component:AddException( Exception )
		Util.CheckParams( 1, Exception, "string", false )
		self.Exceptions[ Exception ] = Exception
	end
	
	function Component:LoadExceptions( )
		for _, Exception in pairs( self.Exceptions ) do
			API.Exceptions[ Exception ] = self.ID
		end
	end

/*==========================================================================
	Section: Externals
==========================================================================*/
	
	function Component:AddExternal( Name, External )
		Util.CheckParams( 1, Name, "string", false )
		self.Externals[ Name ] = External
	end
	
	function Component:LoadExternals( )
		if self.Enabled then
			self:CallHook( "BuildExternals" )
			
			for Name, External in pairs( self.Externals ) do
				if type( External ) == "number" then
					API.Raw_Externals[ "%" .. Name ] = External
				elseif type( External ) == "string" then
					API.Raw_Externals[ "%" .. Name ] = "\"" .. External .. "\""
				else
					API.Externals[ Name ] = External
					API.Raw_Externals[ "%" .. Name ] = "Externals[\"" .. Name .. "\"]"
				end
			end
		end
	end		
end
/*==================================================================================================
	API - Syntax:
			
		1)  prepare %N 	-> The preperation for Param N.
		2)  value %N	-> The result (inline) of Param N.
		3)  type %N		-> The short type of N (as string).
		
		4)  %prepare	-> The preperation for anything not effected by 1.
		5)  %perf		-> A line that does the perf calculation and exceed.
		6)  %trace		-> The trace of this function as a table.
		7)  %...		-> A list of variants from a vararg.
		
		8)  %memory		-> Gets the contexts memory table.
		9)  %delta		-> Gets the contexts delta table.
		10) %click		-> Gets the contexts click table.
		11) %data		-> Gets the contexts data table.
		
		12) local %word	-> Define a new local variable with a unique id.
		13) %word		-> Completes 12 using the variables unique id.
		14) %external	-> Uses an external.
		
		15) $variable	-> Imports somthing into the lua enviroment
		
		16)				-> 4 & 5 will pass to calling operator if not used.
		
====================================================================================================*/
local Trim, Find, Gsub, Gmatch = string.Trim, string.find, string.gsub, string.gmatch

function API:BuildFunction( Signature, Perf, ParamTypes, Return, Prepare, Inline )
		
	-- Trim stuff!
		if !Inline then
			Inline = Trim( Prepare )
			Prepare = nil
		else
			Inline = Trim( Inline )
			Prepare = Trim( Prepare )
		end
	
	-- Biuld the function
		return function( Compiler, Trace, ... )
			Trace.Location = Signature
			
			if !Inline then
				Compiler:TraceError( Trace, "Unpredicted compile error, %s has no inline", Signature )
			end
			
			local Prepare, Inline, VArgs = Prepare, Inline
			local Params, PrepLua, Perf = { ... }, "", Perf
			
			local Inserts, Values, Imports = { }, {
				["%context"] = "Context",
				["%memory"] = "Context.Memory",
				["%delta"] = "Context.Delta",
				["%click"] = "Context.Click",
				["%data"] = "Context.Data"
			}, { }
			
			for I = 1, #Params + 5 do -- +5 to take care of optionals!
				local Param, Type = Params[I], ParamTypes[I]
				
				if Type and Type == "..." then
					VArgs = { }
				end
					
				if !Param then
					-- Optional perams.
					Inserts[ "type %" .. I ] = "nil"
					Inserts[ "value %" .. I ] = "nil"
					
				elseif type( Param ) == "table" then
					-- Instruction perams.
					Type = Param.Return
					Inserts[ "type %" .. I ] = "\"" .. Type .. "\""
					Inserts[ "value %" .. I ] = Param.Inline
					
					Perf = Perf + (Param.Perf or 0)
					
					if Prepare and Find( Prepare, "prepare %%" .. I ) then
						Inserts[ "prepare %" .. I ] = Param.Prepare or ""
					elseif Param.Prepare then
						PrepLua = PrepLua .. "\n" .. Param.Prepare
					end
				else
					Type = ( Type or "?" )
					Inserts[ "type %" .. I ] = "\"" .. Type .. "\""
					Inserts[ "value %" .. I ] = Param
				end
				
				if VArgs and Param then
					if Type ~= "?" and Type ~= "..." then
						VArgs[#VArgs + 1] = "{ value %%" .. I .. ", type %%" .. I .. " }"
					else
						VArgs[#VArgs + 1] = "value %%" .. I
					end
				end
			end
			
			-- Insert traces
			if ( Prepare and Find( Prepare, "%%trace" ) ) or Find( Inline, "%%trace" ) then
				Values["%trace"] = Compiler:CompileTrace( Trace )
			end
			
			-- Insert Varargs
			if ( Prepare and Find( Prepare, "%%%.%.%." ) ) or Find( Inline, "%%%.%.%." ) then
				local VArgs = VArgs and table.concat( VArgs, "," ) or "nil"
				
				Inline = Gsub( Inline, "(%%%.%.%.)", VArgs )
				if Prepare then
					Prepare = Gsub( Prepare, "(%%%.%.%.)", VArgs )
				end
			end
			
			-- Find local variables
			if Prepare then
				for Line in Gmatch( Prepare, "local [a-zA-Z_0-9%%, \t]+" ) do
					for Variable in Gmatch( Line, "(%%[a-zA-Z0-9_]+)" ) do
						Values[ Variable ] = Compiler:NextLocal( )
					end
				end
			end
			
			-- Import lua values
			for Variable in Gmatch( Inline, "(%$[a-zA-Z0-9_]+)" ) do
				local Replaced = string.sub( Variable, 2 )
				Compiler:Import( Replaced )
				Imports[ Variable ] = Replaced
			end
				
			-- Configure the inline.
			Inline = Gsub( Inline, "(%%[a-zA-Z0-9_]+)", Values ) -- Must Be First!
			Inline = Gsub( Inline, "(%$[a-zA-Z0-9_]+)", Imports )
			Inline = Gsub( Inline, "([a-zA-Z0-9_]+ %%[0-9]+)", Inserts )
			Inline = Gsub( Inline, "(%%[a-zA-Z0-9_]+)", API.Raw_Externals )
			
			if Prepare then
				
				-- Import lua values
				for Variable in Gmatch( Prepare, "(%$[a-zA-Z0-9_]+)" ) do
					local Replaced = string.sub( Variable, 2 )
					Compiler:Import( Replaced )
					Imports[ Variable ] = Replaced
				end
				
				-- Prepare params
				if Find( Prepare, "%%prepare" ) then
					Values["%prepare"] = PrepLua
					PrepLua = ""
				end
				
				-- Push perf points
				if Find( Prepare, "%%perf" ) then
					local LuaTrace = Compiler:CompileTrace( Trace )
					Prepare = Gsub( Prepare, "%%perf", "Context:PushPerf( " .. LuaTrace .. ", " .. Perf .. ")" )
					Perf = 0 -- All performance points pushed, clear the cost.
				end
				
				-- Configure the prepare
				Prepare = Gsub( Prepare, "(%%[a-zA-Z0-9_]+)", Values )
				Prepare = Gsub( Prepare, "(%$[a-zA-Z0-9_]+)", Imports )
				Prepare = Gsub( Prepare, "([a-zA-Z0-9_]+ %%[0-9]+)", Inserts )
				Prepare = Gsub( Prepare, "(%%[a-zA-Z0-9_]+)", API.Raw_Externals )
			
				Prepare = PrepLua .. "\n" .. Prepare
			else
				Prepare = PrepLua
			end
			
			return Compiler:Instruction( Trace, Perf, Return, Inline, Prepare ) 
		end
end

/*==========================================================================
	Section: Init hook
==========================================================================*/
if SERVER then

	hook.Add( "Initialize", "LEMON_INIT", function( )
		MsgN( "Loading LemonGate (Expression Advanced)" )
		
		API:Init( )
		
		MsgN( "Done..." )
	end )

/*==========================================================================
	Section: Con Commands
==========================================================================*/

	function LEMON.Cmd_Reload( Player, Cmd, Args, Line )
		if Player and Player:IsAdmin( ) then
			MsgN( Format( "Player %s is reloading LemonGate!", Player:GetName( ) ) )
			
			Player:ChatPrint( "LemonGate reloading!" )
			
			API:Init( )
		elseif !Player then
			MsgN( "Console %s is reloading LemonGate!" )
			
			API:Init( )
		end
	end

	concommand.Add( "lemon_reload", LEMON.Cmd_Reload )

	function LEMON.Cmd_Component( Player, Cmd, Args, Line )
		if !Player or Player:IsAdmin( ) then
			local Component, Bool = string.lower( Args[1] ), tobool( Args[2] )
			if Component != "core" and API.Components[ Component ] then
				API.Components[ Component ] = Bool
				
				API:SaveConfig( )
				
				local Word = Bool and "enabled" or "disabled"
				
				if Player then
					MsgN( Format( "Player %s has %s lemongate component %s.", Player:GetName( ), Word, Component ) )
					
					Player:ChatPrint( Format( "Component %s  %s.", Word, Component ) )
				else
					MsgN( "Console has %s lemongate component %s.", Word, Component )
				end
			end
		end
	end

	concommand.Add( "lemon_component", LEMON.Cmd_Component )

elseif CLIENT then

	function LEMON.Cmd_Editor( Player, Cmd, Args, Line )
		MsgN( "LemonGate Editor Reloading" )
		API:LoadEditor( )
		MsgN( "Editor Reloaded" )
	end
	
	concommand.Add( "lemon_reload_editor", LEMON.Cmd_Editor )
end

