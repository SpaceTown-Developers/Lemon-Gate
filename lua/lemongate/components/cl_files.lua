/*==============================================================================================
	Expression Advanced: Files, Based on E2
	Creditors: Rusketh, E2 authors
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local GetChunks = LEMON.GetChunks

local MaxSize = CreateConVar( "lemon_file_max_size", "300", { FCVAR_REPLICATED, FCVAR_ARCHIVE } )

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

local Chunk_Size = 20000
local file, net = file, net

/*==============================================================================================
	Valid File Paths
==============================================================================================*/
local Valid_Paths = {
	["e2files"] = "e2files",
	["lemon"] = "lemongate/files",
	["e2shared"] = "expression2/e2shared",
	["cpushared"] = "cpuchip/e2shared",
	["gpushared"] = "gpuchip/e2shared",
	["dupeshared"] = "adv_duplicator/e2shared"
}

if !file.IsDir( "lemongate/files", "DATA" ) then
	file.CreateDir( "lemongate/files" )
end

local function GetValidPath( Path )
	if Path:find( "..", 1, true ) then return "lemongate/files/", "noname.txt" end

	local NewPath = ""

	if Path:Left( 1 ) == ">" then
		local DirS = Path:find( "/" )

		if DirS then
			local ExtDir = Path:sub( 2, DirS - 1 )
			local Dir = ( Valid_Paths[ ExtDir ] or "lemongate/files" ) .. "/"
			NewPath = Dir .. Path:sub( DirS + 1, #Path )
		else
			NewPath = "lemongate/files/" .. Path
		end
	else
		NewPath = "lemongate/files/" .. Path
	end

	return string.GetPathFromFilename( NewPath ) or "lemongate/files/", string.GetFileFromFilename( NewPath ) or "noname.txt"
end

/*==============================================================================================
	Upload File
==============================================================================================*/
net.Receive( "lemon_request_file", function( Bytes )
	local ID = net.ReadUInt( 16 )
	local Path, File = GetValidPath( net.ReadString( ) )
	local File_Path = Path .. File
	
	local Status = FILE_OK
	local Messages, Chunks = 0
	
	if !file.Exists( File_Path, "DATA" ) then
		Status = FILE_404
	elseif file.Size( File_Path, "DATA" ) >= ( MaxSize:GetInt() * 1024 ) then
		Status = FILE_TRANSFER_ERROR
	else
		Chunks = GetChunks( file.Read( File_Path, "DATA" ), Chunk_Size )
		Messages = #Chunks
	end
	
	net.Start( "lemon_file_begin" )
		net.WriteUInt( ID, 16 )
		net.WriteUInt( Status, 3 )
		net.WriteUInt( Messages, 16 )
	net.SendToServer( )
	
	for I = 1, Messages do
		timer.Simple( I * 0.1, function( )
			net.Start( "lemon_file_chunk" )
				net.WriteUInt( ID, 16 )
				net.WriteUInt( I, 16 )
				net.WriteString( Chunks[I], 3 )
			net.SendToServer( )
		end )
	end
end )

/*==============================================================================================
	Download File: NOT DONE!
==============================================================================================*/
local Incomming = { }

net.Receive( "lemon_file_begin", function( Bytes )
	local ID = net.ReadUInt( 16 )
	local Path, File = GetValidPath( net.ReadString( ) )
	local File_Path = Path .. File
	
	local Parts = net.ReadUInt( 16 )
	local Append = ned.ReadBit( ) == 1
	
	if Append and !file.Exists( File_Path, "DATA" ) then
		net.Start( "lemon_file_status" )
			net.WriteUInt( ID, 16 )
			net.WriteUInt( FILE_404, 16 )
		net.SendToServer( )
	
	elseif string.GetExtensionFromFilename( File:lower( ) ) != "txt" then
		net.Start( "lemon_file_status" )
			net.WriteUInt( ID, 16 )
			net.WriteUInt( FILE_404, 16 )
		net.SendToServer( )
	else
		Incomming[ ID ] = {
			FilePath = File_Path,
			Parts = Parts,
			Chunks = { },
			Append = Append,
		}
		
		if !file.Exists( Path, "DATA") then
			file.CreateDir( Path )
		end
	end
end )

net.Receive( "lemon_file_chunk", function( Bytes )
	local ID = net.ReadUInt( 16 )
	local Part = net.ReadUInt( 16 )
	local Chunk = net.ReadString( 3 )
	local Info = Incomming[ ID ]
	
	if !Info then
		net.Start( "lemon_file_status" )
			net.WriteUInt( ID, 16 )
			net.WriteUInt( FILE_TRANSFER_ERROR, 16 )
		net.SendToServer( )
	else
		Info.Chunks[ Part ] = Chunk
		
		if #Info.Chunks == Info.Parts then
			if Info.Append then
				file.Append( Info.FilePath, table.concat( Info.Chunks, "" ) )
			else
				file.Write( Info.FilePath, table.concat( Info.Chunks, "" ) )
			end
			
			net.Start( "lemon_file_status" )
				net.WriteUInt( ID, 16 )
				net.WriteUInt( FILE_OK, 16 ) -- Was 404, no idea why?
			net.SendToServer( )
		
			Incomming[ ID ] = nil
		end
	end
end )

/*==============================================================================================
	List Dir
==============================================================================================*/
net.Receive( "lemon_list_file", function( Bytes )
	local ID = net.ReadUInt( 16 )
	local Path, File = GetValidPath( net.ReadString( ) )
	
	if !file.IsDir( Path, "DATA" ) then
		net.Start( "lemon_file_status" )
			net.WriteUInt( ID, 16 )
			net.WriteUInt( FILE_OK, 16 )
		net.SendToServer( )
	else
		local Files, Folders = file.Find( Path .. "*","DATA" )
		for _, File in pairs( Files ) do
			if string.GetExtensionFromFilename( File ) == "txt" then
				Folders[ #Folders + 1 ] = File
			end
		end
		
		net.Start( "lemon_list_file_done" )
			net.WriteUInt( ID, 16 )
			net.WriteTable( Folders )
		net.SendToServer( )
	end
end )