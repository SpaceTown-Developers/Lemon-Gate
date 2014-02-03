/*==============================================================================================
	Expression Advanced: Files, Based on E2
	Creditors: Rusketh, E2 authors
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local GetChunks = LEMON.GetChunks

local Component = API:NewComponent( "file", true )

/*==============================================================================================
	Base Stuffs
==============================================================================================*/
Component.Cvar_Delay = CreateConVar( "lemon_file_delay", "5", { FCVAR_ARCHIVE } )
Component.Cvar_Transfers = CreateConVar( "lemon_file_transfer_max", "5", { FCVAR_ARCHIVE } )
Component.Cvar_SizeMax = CreateConVar( "lemon_file_max_size", "300", { FCVAR_REPLICATED, FCVAR_ARCHIVE } ) //in kb

/*==============================================================================================
	Base Stuffs
==============================================================================================*/
local FILE_UNKNOWN = 0
local FILE_OK = 1
local FILE_TIMEOUT = 2
local FILE_404 = 3
local FILE_TRANSFER_ERROR = 4 

local FILE_UPLOAD = 1
local FILE_DOWNLOAD = 2
local FILE_LIST = 3
local FILE_DELETE = 4

/*==============================================================================================
	Net Work Stuffs
==============================================================================================*/
local Chunk_Size = 20000
local net, util = net, util

local Queue = { }
local LookUp = { }
local Finished = { }

function Component.CanQue( Player )
	local Queue = Queue[ Player ] or 0
	return Queue < Component.Cvar_Transfers:GetInt( )
end

timer.Create( "Lemon.Files", 0.1, 0, function( )
	local UsedGates = { }
	
	for I = 1, #Finished do
		local Action = Finished[I]
		
		if IsValid( Action.Entity ) and Action.Entity:IsRunning( ) and IsValid( Action.Player ) then
			UsedGates[ Action.Entity ] = true
			Queue[ Player ] = ( Queue[ Player ] or 0 ) - 1
			
			if ( Action.Status ~= FILE_OK or !Action.Sucess ) then
				if Action.Fail then
					Action.Entity:Pcall( "file callback", Action.Fail, { Action.Status or 0, "n" } )
				end
			elseif Action.Type == FILE_UPLOAD then
				Action.Entity:Pcall( "file callback", Action.Sucess, { Action.Data, "s" } )
			elseif Action.Type == FILE_LIST then
				Action.Entity:Pcall( "file callback", Action.Sucess, { Action.Data[1], "t" }, { Action.Data[2], "t" } )
			end
		end
		
		LookUp[ Action.ID ] = nil
	end
	
	for Entity, _ in pairs( UsedGates ) do
		if Entity:IsRunning( ) then
			Entity:Update( )
		end
	end
	
	Finished = { }
end )

/*==============================================================================================
	Upload File
==============================================================================================*/
util.AddNetworkString( "lemon_request_file" )

function Component.Upload( Context, FileName, Func_Sucess, Func_Fail )
	if !IsValid( Context.Entity ) or !IsValid( Context.Player ) or !Context.Player:IsPlayer( ) then
		return
	elseif FileName:Right( 4 ) != ".txt" then
		return //Todo: Exception!
	end
	
	local InQueue = Queue[ Player ] or 0
	if InQueue >= Component.Cvar_Transfers:GetInt( ) then
		return //TODO: Exception
	else
		Queue[ Player ] = InQueue + 1
	end
	
	local Action = {
		Type = FILE_UPLOAD,
		Player = Context.Player,
		Entity = Context.Entity,
		FileName = FileName,
		Sucess = Func_Sucess,
		Fail = Func_Fail,
		Uploading = false,
	}
	
	Action.ID = #LookUp + 1
	Queue[ #Queue + 1 ] = Action
	LookUp[ Action.ID ] = Action
	
	net.Start( "lemon_request_file" )
		net.WriteUInt( Action.ID, 16 )
		net.WriteString( FileName )
	net.Send( Context.Player )
end

util.AddNetworkString( "lemon_file_begin" )

net.Receive( "lemon_file_begin", function( Bytes, Player )
	local ID = net.ReadUInt( 16 )
	local Status = net.ReadUInt( 3 )
	local Parts = net.ReadUInt( 16 )
	
	local Action = LookUp[ ID ]
	
	if Action and IsValid( Action.Entity ) then
		
		if Action.Player ~= Player then
			Status = FILE_TRANSFER_ERROR
		end
		
		Action.Status = Status
		
		if Status == FILE_OK then
			Action.Uploading = true
			Action.Parts = Parts
			Action.Chunks = { }
		else
			Finished[ #Finished + 1 ] = Action
		end
	else
		LookUp[ ID ] = nil
	end
end )


util.AddNetworkString( "lemon_file_chunk" )

net.Receive( "lemon_file_chunk", function( Bytes, Player )
	local ID = net.ReadUInt( 16 )
	local Part = net.ReadUInt( 16 )
	local Chunk = net.ReadString( 3 )
	
	local Action = LookUp[ ID ]
	
	if Action and IsValid( Action.Entity ) then
		
		if !Action.Uploading or Action.Player ~= Player then
			Action.Status = FILE_TRANSFER_ERROR
			Finished[ #Finished + 1 ] = Action
		else
			Action.Chunks[ Part ] = Chunk
			
			if #Action.Chunks == Action.Parts then
				Action.Data = table.concat( Action.Chunks, "" )
				Finished[ #Finished + 1 ] = Action
			end
		end
	else
		LookUp[ ID ] = nil
	end
end )

/*==============================================================================================
	Download File
==============================================================================================*/

function Component.Download( Context, FileName, Data, Func_Status, Append )
	if !IsValid( Context.Entity ) or !IsValid( Context.Player ) or !Context.Player:IsPlayer( ) then
		return
	elseif FileName:Right( 4 ) != ".txt" then
		return //Todo: Exception!
	end
	
	local InQueue = Queue[ Player ] or 0
	if InQueue >= Component.Cvar_Transfers:GetInt( ) then
		return //TODO: Exception
	else
		Queue[ Player ] = InQueue + 1
	end
	
	local Action = {
		Type = FILE_DOWNLOAD,
		Player = Context.Player,
		Entity = Context.Entity,
		FileName = FileName,
		Fail = Func_Status,
	}
	
	Action.ID = #LookUp + 1
	Queue[ #Queue + 1 ] = Action
	LookUp[ Action.ID ] = Action
	
	if #Data >= ( Component.Cvar_SizeMax:GetInt() * 1024 ) then
		Action.Status = FILE_TRANSFER_ERROR
		Finished[ #Finished + 1 ] = Action
	else
		local Chunks = GetChunks( Data, Chunk_Size )
		
		net.Start( "lemon_file_begin" )
			net.WriteUInt( Action.ID, 16 )
			net.WriteString( FileName )
			net.WriteUInt( #Chunks, 16 )
			net.WriteBit( Append or false )
		net.Send( Context.Player )
		
		for I = 1, #Chunks do
			timer.Simple( I * 0.1, function( )
				net.Start( "lemon_file_chunk" )
					net.WriteUInt( Action.ID, 16 )
					net.WriteUInt( I, 16 )
					net.WriteString( Chunks[I], 3 )
				net.Send( Context.Player )
			end )
		end
	end
end

/*==============================================================================================
	Upload File
==============================================================================================*/
util.AddNetworkString( "lemon_list_file" )

function Component.List( Context, FileName, Func_Sucess, Func_Fail )
	if !IsValid( Context.Entity ) or !IsValid( Context.Player ) or !Context.Player:IsPlayer( ) then
		return
	end
	
	local InQueue = Queue[ Player ] or 0
	if InQueue >= Component.Cvar_Transfers:GetInt( ) then
		return //TODO: Exception
	else
		Queue[ Player ] = InQueue + 1
	end
	
	local Action = {
		Type = FILE_LIST,
		Player = Context.Player,
		Entity = Context.Entity,
		FileName = FileName,
		Sucess = Func_Sucess,
		Fail = Func_Fail
	}
	
	Action.ID = #LookUp + 1
	Queue[ #Queue + 1 ] = Action
	LookUp[ Action.ID ] = Action
	
	net.Start( "lemon_list_file" )
		net.WriteUInt( Action.ID, 16 )
		net.WriteString( FileName )
	net.Send( Context.Player )
end

util.AddNetworkString( "lemon_list_file_done" )

net.Receive( "lemon_list_file_done", function( Bytes, Player )
	local Table = API:GetComponent( "table" ):GetMetaTable( )
	
	local ID = net.ReadUInt( 16 )
	local Part = net.ReadUInt( 16 )
	local Chunk = net.ReadString( 3 )
	
	// Files:
		local Files = Table( )
		
		for I = 1, net.ReadUInt( 16 ) do
			local Name = net.ReadString( )
			if Name ~= "" then Files:Insert( nil, "s", Name ) end
		end
	
	// Folders:
		local Folders = Table( )
		
		for I = 1, net.ReadUInt( 16 ) do
			local Name = net.ReadString( )
			if Name ~= "" then Folders:Insert( nil, "s", Name ) end
		end
	
	local Action = LookUp[ ID ]
	
	if Action and IsValid( Action.Entity ) then
		Action.Status = FILE_OK
		Action.Data = { Files, Folders }
		Finished[ #Finished + 1 ] = Action
	else
		LookUp[ ID ] = nil
	end
end )

/*==============================================================================================
	Action Status
==============================================================================================*/
util.AddNetworkString( "lemon_file_status" )

net.Receive( "lemon_file_status", function( Bytes, Player )
	local ID = net.ReadUInt( 16 )
	local Status = net.ReadUInt( 16 )
	
	local Action = LookUp[ ID ]
	
	if Action and IsValid( Action.Entity ) then
		Action.Status = Status or FILE_TRANSFER_ERROR
		Finished[ #Finished + 1 ] = Action
	else
		LookUp[ ID ] = nil
	end
end )

/*==============================================================================================
	Constants
==============================================================================================*/
Component:AddConstant( "FILE_UNKNOWN", "n", FILE_UNKNOWN )
Component:AddConstant( "FILE_OK", "n", FILE_OK )
Component:AddConstant( "FILE_TIMEOUT", "n", FILE_TIMEOUT )
Component:AddConstant( "FILE_404", "n", FILE_404 )
Component:AddConstant( "FILE_TRANSFER_ERROR", "n", FILE_TRANSFER_ERROR )

/*==============================================================================================
	Functions
==============================================================================================*/
Component:AddExternal( "Files", Component )

Component:AddFunction( "fileLoad", "s,f[,f]", "", "%Files.Upload( %context, value %1, value %2, value %3 )", LEMON_PREPARE_ONLY )

Component:AddFunction( "fileWrite", "s,s[,f]", "", "%Files.Download( %context, value %1, value %2, value %3, false )", LEMON_PREPARE_ONLY )

Component:AddFunction( "fileAppend", "s,s[,f]", "", "%Files.Download( %context, value %1, value %2, value %3, true )", LEMON_PREPARE_ONLY )

Component:AddFunction( "fileList", "s,f[,f]", "", "%Files.List( %context, value %1, value %2, value %3 )", LEMON_PREPARE_ONLY )
