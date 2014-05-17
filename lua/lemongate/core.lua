/*==========================================================================
	Expression Advanced: API
		- Rusketh
		- Oskar94
		- Syanide
==========================================================================*/
require( "von" )

LEMON = LEMON or { API = { Util = { Cache = { } } } }
LEMON.Ver = "GIT: " .. "2." .. ( file.Read( "ea_version.lua", "LUA" ) or 0 )

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
		return "API.Util.Cache[" .. Index .. "]"
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
	if !IsValid( Entity ) then
		return nil
	elseif CPPI then
		local Owner = Entity:CPPIGetOwner( )
		
		if IsValid( Owner ) then
			return Owner
		end
	end
	
	if Entity.GetPlayer then
		return Entity:GetPlayer( )
	end
	
	local ODF = Entity.OnDieFunctions
	
	if ODF and ODF.GetCountUpdate and ODF.GetCountUpdate.Args then
		return ODF.GetCountUpdate.Args[1]
	elseif ODF and ODF.undo1 and ODF.undo1.Args then
		return ODF.undo1.Args[2]
	end -- Garry it sadens me we have to do stuff like this =(
	
	if Entity.GetOwner then
		return Entity:GetOwner( )
	end
	
	return Entity.player or Entity.Player
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
	
	if !WireLib then
		LEMON = nil
		MsgN( "Failed to load LemonGate wiremod is missing!" )
		return -- Uninstall if wiremod is missing!
	end
		
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
	
	self.Constants = { }
	
	MsgN( "Loading compiler." )
	include( "lemongate/compiler/init.lua" )
	
	if SERVER then
		self.Config = util.KeyValuesToTable( file.Read("lemon_config.txt") or "" ) or { }
	else
		self.Config = self.DataPack.Config
	end
	
	hook.Call( "LemonGate_PreInit", GAMEMODE or GM, self )
	
	MsgN( "[LemonGate] Loading components." )
	self:LoadCoreComponents( ) 
	
	MsgN( "[LemonGate] Loading custom components." ) 
	
	self:LoadCustomComponents( "lemongate/components/custom/" ) 
	self:LoadCustomComponents( GAMEMODE.FolderName .. "/gamemode/EAComponents/" )
	
	hook.Call( "LemonGate_AddComponents", GAMEMODE or GM, self )
	
	MsgN( "[LemonGate] Loading awesome editor." ) 
	
	self:LoadEditor( )
	
	self:InstallComponents( )
	
	if SERVER then
		MsgN( "Loading context." )
		include( "lemongate/context.lua" )
	
		self:SaveConfig( )
		self:BuildDataPack( )
		
		for _, Player in pairs( player.GetHumans( ) ) do
			self:SendDataPack( Player )
		end
		
		self:ReloadEntitys( )
	end
	
	self.Initialized = true
	
	hook.Call( "LemonGate_PostInit", GAMEMODE or GM, self )
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
		include( "lemongate/components/vector2.lua" )
		include( "lemongate/components/angle.lua" )
		include( "lemongate/components/entity.lua" )
		include( "lemongate/components/physics.lua" )
		include( "lemongate/components/color.lua" )
		include( "lemongate/components/events.lua" )
		include( "lemongate/components/wirelink.lua" )
		include( "lemongate/components/units.lua" )
		
		include( "lemongate/components/lambda.lua" )
		include( "lemongate/components/table.lua" )
		include( "lemongate/components/hologram.lua" ) 
		include( "lemongate/components/sound.lua" )
		include( "lemongate/components/communicate.lua" )
		include( "lemongate/components/timer.lua" )
		include( "lemongate/components/kinect.lua" )
		include( "lemongate/components/http.lua" )
		include( "lemongate/components/trace.lua" )
		include( "lemongate/components/ranger.lua" )
		include( "lemongate/components/egp.lua" )
		include( "lemongate/components/quaternion.lua" )
		include( "lemongate/components/file.lua" )
		include( "lemongate/components/console.lua" )
		include( "lemongate/components/coroutine.lua" )
		include( "lemongate/components/arrays.lua" )
		
		-- Shared Editor
		include( "lemongate/editor/shared.lua" )
	end
end

function API:LoadCustomComponents( Path, Recursive )
	if not Path then return end
	
	Path = Path .. "/"
	while string.match( Path, "//" ) do 
		Path = string.gsub( Path, "//", "/" )
	end 
	
	local Files = file.Find( Path .. "*.lua", "LUA" ) 
	local _, Folders = file.Find( Path .. "*", "LUA" ) 
	
	for _, fName in pairs( Files or { } ) do
		local File = Path .. fName
		
		-- When and if server <> client files need to be separated
		if string.match( fName, "^cl_" ) then
			if SERVER then AddCSLuaFile( File ) else include( File ) end
		elseif string.match( fName, "^sh_" ) then
			if SERVER then AddCSLuaFile( File ) end
			include( File )
		else
			if SERVER then include( File ) end
		end
	end
	
	if Recursive and Folders and #Folders > 0 then 
		for _, sFolder in pairs( Folders ) do 
			self:LoadCustomComponents( Path .. sFolder, true )
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
		
		self.HelperData = setmetatable( {}, { __index = function( tbl, index ) return "" end } )  
		
		
		include( "lemongate/editor/ea_browser.lua" ) -- TODO: Delte this!
		include( "lemongate/editor/ea_filemenu.lua" )
		include( "lemongate/editor/ea_button.lua" )
		include( "lemongate/editor/ea_closebutton.lua" )
		include( "lemongate/editor/ea_editor.lua" )
		include( "lemongate/editor/ea_editorpanel.lua" )
		include( "lemongate/editor/ea_filenode.lua" )
		include( "lemongate/editor/ea_frame.lua" )
		include( "lemongate/editor/ea_helper.lua" )
		include( "lemongate/editor/ea_helperdata.lua" )
		include( "lemongate/editor/ea_hscrollbar.lua" )
		include( "lemongate/editor/ea_imagebutton.lua" )
		include( "lemongate/editor/ea_toolbar.lua" )
		include( "lemongate/editor/syntaxer.lua" )
		include( "lemongate/editor/pastebin.lua" )
		include( "lemongate/editor/repo.lua" )
		include( "lemongate/editor/ea_search.lua" )
		include( "lemongate/editor.lua" )

		include( "lemongate/editor/shared.lua" )
		
		include( "lemongate/components/kinect.lua" )
		include( "lemongate/components/cl_files.lua" )
		include( "lemongate/components/console.lua" )
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
	end
	
end
/*==========================================================================
	Section: DataPack
==========================================================================*/
if SERVER then
	function API:BuildDataPack( )
		MsgN( "Building LemonGate Datapack..." )
		
		local Cls, Ops, Funcs, Exts = { }, { }, { }, { }
		
		local DataPack = {
			Config = self.Config,
			Classes = Cls,
			Operators = Ops,
			Functions = Funcs,
			Events = self.Events,
			Externals = self.Raw_Externals,
			Exceptions = self.Exceptions,
			Components = self.ComponentLK,
			Constants = self.Constants,
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
		self.DataPack = util.Compress( von.serialize( DataPack ) )
		
		MsgN( Format( "Datapack compressed %d bytes.", #self.DataPack  ) )
		
		-- Send datapack to new players
		hook.Add( "PlayerInitialSpawn", "Lemon_DataPack", function( Player )
			self:SendDataPack( Player )
		end ) 
	end
	
	util.AddNetworkString( "lemon_datapack" )
	
	function API:SendDataPack( Player )
		net.Start( "lemon_datapack" )
			net.WriteData( self.DataPack, #self.DataPack )
		net.Send( Player )
	end
else
	net.Receive( "lemon_datapack", function( Bytes )
		MsgN( Format( "Recived LemonGate DataPack (%d bytes)", Bytes / 8 ) )
		
		LEMON.API.DataPack = von.deserialize( util.Decompress( net.ReadData( Bytes / 8 ) ) )
		
		API:Init( ) -- Load on client!
	end )
end

/*==========================================================================
	Section: Player DC auto shutdown
==========================================================================*/
if SERVER then
	local AutoShutDown = CreateConVar( "lemon_auto_shutdown", "1" )

	hook.Add( "PlayerDisconnected", "LemonGate.AutoShutDown", function( Player )
		if AutoShutDown:GetInt( ) == 1 or ( AutoShutDown:GetInt( ) == 2 and !Player:IsAdmin( ) ) then
			for _, Entity in pairs( API:GetEntitys( ) ) do
				if Util.IsOwner( Player, Entity ) then
					Entity:ShutDown( )
					API:CallHook( "Remove", Entity )
					Entity.AutoShutDown = true
				end
			end
		end
	end )
	
	hook.Add( "PlayerInitialSpawn", "LemonGate.AutoShutDown", function( Player )
		timer.Simple( 5, function( )
			for _, Entity in pairs( API:GetEntitys( ) ) do
				if Entity.AutoShutDown and Entity.PlyID == Player:EntIndex( ) then
					Entity:SetNWEntity( "player", Player )
					Entity:SetPlayer( Player )
					Entity.Player = Player
				
					Entity:Reset( )
					Entity.AutoShutDown = false
				end
			end
		end )
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
				Default = Enabled or false,
				Enabled = false,
				
				Classes = { }, -- Class's by Name.
				Operators = { }, -- Operators.
				Functions = { },  -- Functions.
				
				Exceptions = { },
				Externals = { },
				Events = { },
				
				Constants = { },
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
		local Config, IsEnabled = API.Config[ self.LName ], self.Default
		
		if Config then
			IsEnabled = tobool( Config )
		end
		
		if IsEnabled and self:CallHook( "OnEnable" ) then
			IsEnabled = false -- OnEnabled returned true
		end
		
		self.Enabled = IsEnabled
		
		if self.Enabled then
			self.ID = #API.ComponentLK + 1
			API.ComponentLK[ self.ID ] = self.Name
		end
		
		API.Config[ self.LName ] = IsEnabled and 1 or 0
		
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
					
					if Class.DefaultRaw == nil then
						Class.DefaultRaw = BaseClass.DefaultRaw
						Class.DefaultType = BaseClass.DefaultType
					end
				end
			end
			
			if Class.DefaultRaw ~= nil and Class.DefaultType then
				Class.Default = Class.DefaultRaw -- Run this as lua!
			elseif Class.DefaultRaw ~= nil then -- Convert this to lua!
				Class.Default = Util.ValueToLua( Class.DefaultRaw )
			end
		end
		
		
	-- Sort Components
		for Name, Comp in pairs ( self.Components ) do
			Comp:LoadOperators( )
			Comp:LoadFunctions( )
			Comp:LoadEvents( )
			Comp:LoadExternals( )
			Comp:LoadExceptions( )
			Comp:LoadConstants( )
		end
		
		include( "lemongate/e2.lua" )
		
	elseif CLIENT then
	
		local DataPack = self.DataPack
		local Ops, Funcs = self.Operators, self.Functions
		
		self.Classes = DataPack.Classes
		self.Events = DataPack.Events
		self.Raw_Externals = DataPack.Externals
		self.Exceptions = DataPack.Exceptions
		self.Components = DataPack.Components
		self.Constants = DataPack.Constants
		
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

	//Add an alias for number and boolean.
	self.Classes.int = self.Classes.number
	self.Classes.bool = self.Classes.boolean
end

/*==========================================================================
	Section: Classes
==========================================================================*/
function API:GetClass( RawName, NoError )
	Util.CheckParams( 1, RawName, "string", false, NoError, "boolean", true )

	local Name = string.lower( RawName )
	local Class = self.Classes[ Name ]
	
	if Class then return Class end
	
	if #Name > 1 and !( #Name > 2 and Name[1] == "x" ) then
		Name = "x" .. Name
	end
	
	--if #Name > 1 and Name[1] ~= "x" then Name = "x" .. Name end
	
	local Class = self.ClassLU[ Name ]
	
	if Class then return Class end
	
	if !NoError then
		debug.Trace( )
		Util.StackError( 1, "Class %s can not be found, and probably doesn't exist.", RawName )
	end
end

if SERVER then
	function Component:NewClass( Short, Name, Default, DefIsLua )
		Util.CheckParams( 1, Name, "string", false, Short, "string", false )
		
		if #Short > 1 then Short = "x" .. Short end
		
		local New = setmetatable( {
				Name = Name,
				Short = string.lower( Short ),
				DefaultRaw = Default,
				DefaultType = DefIsLua,
				Default = nil,
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
	
	function Class:UsesMetaTable( Meta )
		self.__MetaTable = Meta
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
LEMON_PERF_LOOPED = 2.5
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
	Section: Neat yet usless enums
==========================================================================*/
	LEMON_INLINE_ONLY = nil
	LEMON_PREPARE_ONLY = ""
	
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
			Second = Second,
		}
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
				else
					Data.Return = ( Return and Return.Short or "" )
				end
				
				for _, Param in string.gmatch( Data.Params, "()([%w%?!%*]+)%s*([%[%]]?)()" ) do
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
		HasPrep = (First and Second),
		
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
	function Component:AddFunction( Name, Params, Return, First, Second, Flag, Desc )
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
				
				if !Return and Data.Return ~= "" and Data.Return ~= "..." then
					MsgN( Format( "%s can't register function %s[%s]\nclass %q doesn't exist." , self.Name, Data.Name, Data.Params, Data.Return ) )
					continue
				elseif Data.Return ~= "..." then
					Data.Return = ( Return and Return.Short or "" )
				end
				
				local Meta = string.find( Data.Params, ":", 1, true )
				if Meta then
					local Param = string.sub( Data.Params, 1, Meta - 1 )
					Data.Params = string.sub( Data.Params, Meta + 1 )
					
					local Class = API:GetClass( Param, true )
					
					if !Class then
						MsgN( Format( "%s can't register function %s(%s)\nclass %q doesn't exist." , self.Name, Data.Name, Data.Params, Param ) )
						continue
					else
						Params[1] = Class.Short
						Signature = Class.Short .. ":"
					end
				end
				
				for Char, Param, Bracket in string.gmatch( Data.Params, "()([%w%?!%*]+)%s*([%[%]]?)()" ) do
					
					local Class = API:GetClass( Param, true )
					
					if !Class then
						MsgN( Format( "%s can't register function %s(%s)\nclass %q doesn't exist." , self.Name, Data.Name, Data.Params, Param ) )
						break -- continue
					else
						Params[#Params + 1] = Class.Short
						Signature = Signature .. Class.Short
					end
					
					if Bracket == "[" and !Optional then
						Optional = true
					end 
					
					if Optional then 
						API:NewFunction( self.ID, Data.Name, Signature, table.Copy( Params ), Data.Return, Data.Perf, Data.First, Data.Second, Data.Desc )
					end
				end
				
				if string.Right( Data.Params, 3 ) == "..." then
					Params[#Params + 1] = "..."
					Signature = Signature .. "..."
					
					if Optional then
						API:NewFunction( self.ID, Data.Name, Signature, table.Copy( Params ), Data.Return, Data.Perf, Data.First, Data.Second, Data.Desc )
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
		HasPrep = (First and Second),
		Desc = CLIENT and Desc or nil,
		
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
				else
					ReturnType = ( Return and Return.Short or "" )
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
			local Result, Gate
			
			for _, _Gate in pairs( self:GetEntitys( ) ) do
				if IsValid( _Gate ) and _Gate.CallEvent then
					local _Result = _Gate:CallEvent( Name, ... )
				
					if _Result and !Result then
						Result, Gate = _Result, _Gate
					end
				end
			end
			
			self:CallHook( "PostEvent", Name, ... )

			if Result then return Result, Gate end
		end
	end
	
/*==========================================================================
	Section: Exceptions
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

/*==========================================================================
	Section: Constants
==========================================================================*/
	
	function Component:AddConstant( Name, Type, Value )
		Util.CheckParams( 1, Name, "string", false, Type, "string", false )
		self.Constants[ Name:upper( ) ] = { Type, Value }
	end
	
	function Component:LoadConstants( )
		if self.Enabled then
			self:CallHook( "BuildConstantss" )
			
			for Name, Constant in pairs( self.Constants ) do
			
				local Type = API:GetClass( Constant[1], true )
				
				if !Type then
					MsgN ( Format( "%s can't register constant %s\nclass %q doesn't exist." , self.Name, Name, Constant[1] ) )
					continue
				else
					API.Constants[ Name ] = { Return = Type.Short, Inline = Constant[2] }
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

LEMON_NO_INLINE = ""

/*==========================================================================
	Section: Lua Syntax Replacer
==========================================================================*/
local function Replace_Context( Line )
	 Line = string.gsub( Line, "%%context", "Context" )
	 Line = string.gsub( Line, "%%memory", "Memory" )
	 Line = string.gsub( Line, "%%delta", "Delta" )
	 Line = string.gsub( Line, "%%click", "Click" )
	 Line = string.gsub( Line, "%%trigger", "Trigger" )
	return  string.gsub( Line, "%%data", "Context.Data" )
	
end

local function Replace_Internals( Line, Perf, Trace )
	local PopPerf = string.find( Line, "%%perf" )
	
	if PopPerf or string.find( Line, "%%trace" ) then
		Trace = Trace and Util.ValueToLua( Trace ) or [[{Location = "Uknown", 0, 0}]]
		Line = string.gsub( Line, "%%trace", Trace )
		
		if PopPerf then
			Line = string.gsub( Line, "%%perf", "Context:PushPerf( " .. Trace .. ", " ..( Perf or 0 ) .. ")" )
		end
	end
	
	return Line, PopPerf
end

function Replace_Externals( Line, Internals )
	Line = string.gsub( Line, "(%%[a-zA-Z0-9_]+)", Internals )
	Line = string.gsub( Line, "(%%[a-zA-Z0-9_]+)", API.Raw_Externals )
	return Line
end

/*==========================================================================
	Section: API Builder
==========================================================================*/
function API:BuildFunction( Sig, Perf, Types, Ret, Second, First )
	
	if !First then
		First = Second
		Second = nil
	end
	
	
	return function( Compiler, Trace, ... )
		if !Trace then deubg.Trace( ) end
		
		local Local_Values = { }
		local PopPerf = false
		Trace.Location = Sig
		
		if Second then
			for Line in string.gmatch( Second, "local [a-zA-Z_0-9%%, \t]+" ) do
				for Variable in string.gmatch( Line, "(%%[a-zA-Z0-9_]+)" ) do
					Local_Values[ Variable ] = Compiler:NextLocal( )
				end
			end
			
			Second = Replace_Context( Second )
			Second, PopPerf = Replace_Internals( Second, Perf, Trace )
			
			if string.find( Second, "%%util" ) then
				local Util = "UTIL." .. Compiler:NextUtil( )
				First = string.gsub( First, "%%util", Util )
				Second = string.gsub( Second, "%%util", Util )
			end
		end
		
		First = Replace_Context( First )
		First = Replace_Internals( First, Perf, Trace )
		
		local First, Second, Perf = Compiler:ConstructOperator( Perf, Types, Second, First, ... )
		
		First = Replace_Externals( First, Local_Values )
		if Second then Second = Replace_Externals( Second, Local_Values ) end
		
		if PopPerf then Perf = 0 end
		return Compiler:Instruction( Trace, Perf, Ret, First, Second )
	end
end

/*==========================================================================
	Section: Init hook
==========================================================================*/
if SERVER then
	
	CreateConVar( "lemon_version", LEMON.Ver, FCVAR_NOTIFY )

	hook.Add( "Initialize", "LEMON_INIT", function( )
		MsgN( "Loading LemonGate (Expression Advanced)" )
		
		if API:Init( ) then
			MsgN( "Done..." )
		end
	end )

/*==========================================================================
	Section: Con Commands
==========================================================================*/

	concommand.Add( "lemon_reload", function ( Ply, Cmd, Args, Line )
		local Name = "Console"
		
		if IsValid( Ply ) and !game.SinglePlayer( ) then
			if !Ply:IsAdmin( ) and !Ply:IsListenServerHost( ) then return end
			Name = Ply:Name( )
		end
		
		for _, Ply in pairs( player.GetAll( ) ) do
			Ply:ChatPrint( Name .. " has reloaded Lemon-Gate." )
		end
		
		MsgN( Name .. " has reloaded Lemon-Gate." )
		
		API:CallHook( "APIReload" )
		
		API:Init( )
		
	end )


	concommand.Add( "lemon_component", function ( Ply, Cmd, Args, Line )
		local Name = "Console"
		
		if IsValid( Ply ) and !game.SinglePlayer( ) then
			if !Ply:IsAdmin( ) and !Ply:IsListenServerHost( ) then return end
			Name = Ply:Name( )
		end
		
		local Component, Bool = string.lower( Args[1] ), tobool( Args[2] )
		
		if Component != "core" and API.Components[ Component ] then
			
			API.Config[ Component ] = Bool and 1 or 0
			
			API:SaveConfig( )
			
			local Message = Format( "%s has %s Lemon-Gate component %s.", Name, Bool and "enabled" or "disabled", Component )
			
			for _, Ply in pairs( player.GetAll( ) ) do
				Ply:ChatPrint( Message )
			end
			
			Msg( Message )
		end
		
	end )
	
	-- In Editor
		concommand.Add( "lemon_editor_open", function( Ply ) Ply:SetNWBool( "Lemon_Editor", true ) end )
		concommand.Add( "lemon_editor_close", function( Ply ) Ply:SetNWBool( "Lemon_Editor", false ) end )
	
elseif CLIENT then

	concommand.Add( "lemon_reload_editor", function ( Player, Cmd, Args, Line )
		MsgN( "LemonGate Editor Reloading" )
		API:LoadEditor( )
		MsgN( "Editor Reloaded" )
	end )
end

