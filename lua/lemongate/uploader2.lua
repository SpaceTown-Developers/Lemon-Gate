/*==============================================================================================
	Expression Advanced: Uploader and Downloader.
	Creditors: Rusketh, Oskar94, Divran
==============================================================================================*/
local LEMON = LEMON

local table_concat = table.concat
local table_remove = table.remove 

local string_sub = string.sub 
local string_gsub = string.gsub 
local string_char = string.char 
local string_len = string.len 
local string_lower = string.lower
local string_match = string.match
local string_Explode = string.Explode

local util_Compress = util.Compress
local util_Decompress = util.Decompress

local net = net

local type = type 
local pairs = pairs 

require( "von" ) -- Temporary!

/*==============================================================================================
	Section: Chunk Chopper
	Purpose: Sends code from Client to Server.
==============================================================================================*/
function LEMON.GetChunks( String, Size )
	local Data = {}
	
	while string_len( String ) > Size do 
		Data[#Data + 1] = string_sub( String, 1, Size )
		String = string_sub( String, Size + 1)
	end
	
	Data[#Data + 1] = String
	
	return Data
end; local GetChunks = LEMON.GetChunks

/*==============================================================================================
	Section: Data packager
	Purpose: Packages up a table of Name=Contents and converts it into a binary string
	Note: Internal functions, should be used with care.
==============================================================================================*/
local function PackScripts( Scripts )
	-- local OutData, FileData = { }, { }
	
	-- for Name, Script in pairs( Scripts ) do
		-- local Data = util_Compress( Script )
		-- OutData[#OutData + 1] = Name .. ":" .. #Data 
		-- FileData[#FileData + 1] = Data 
	-- end 
	
	-- return table_concat( OutData, ";" ) .. "|" .. table_concat( FileData, "" ) 
	return von.serialize( Scripts )
end

local function UnpackScripts( Data )
	-- local Names, Codes = string_match( Data, "(.+)|(.+)")
	-- local Offset, Scripts = 1, { } 
	
	-- for _, Text in pairs( string_Explode( ";", Names ) ) do
		-- local FileName, FileLength = string_match( Text, "(.+):(.+)" ) 
		-- local FileData = string_sub( Codes, Offset, Offset + FileLength ) 
		-- Offset = Offset + FileLength
		-- Scripts[FileName] = util_Decompress( FileData )
	-- end
	
	-- return Scripts
	
	return von.deserialize( Data )
end

/*==============================================================================================
	Section: Lemon Gate Uploader
	Purpose: Sends code from Client to Server.
==============================================================================================*/
LEMON.Uploader = { Uploads = { } }
local Uploader = LEMON.Uploader
local Uploads = Uploader.Uploads

/*==============================================================================================
		SERVER
==============================================================================================*/
if SERVER then
	
	util.AddNetworkString( "lemon_upload" )
	util.AddNetworkString( "lemon_upload_confirm" )
	util.AddNetworkString( "lemon_upload_request" )
	
	function Uploader.Rec_Chunk( length, Player )
		local PlyID = Player:UniqueID( )
		local EntID = net.ReadUInt( 16 )
		local ChunkID = net.ReadUInt( 16 )
		local Chunks = net.ReadUInt( 16 )
		local DataLen = net.ReadUInt( 16 )
		local Data = net.ReadData( DataLen )
		
		local Entity = Entity( EntID ) -- Check if the entity is a lemongate.
		if !Entity or !Entity:IsValid( ) or Entity:GetClass( ) ~= "lemongate" then
			Player:PrintMessage( HUD_PRINTTALK, "Either its out of lemons or its not a Lemongate." )
			Uploads[PlyID][EntID] = nil
			return
		end
		
		if !Uploads[PlyID] then Uploads[PlyID] = { } end -- Give player an upload session.
		
		local Upload = Uploads[PlyID][EntID]
		if !Upload then
			Upload = { PlyID = PlyID, EntID = EntID, Chunks = 0, Data = { } }
			Uploads[PlyID][EntID] = Upload
		end
		
		if Upload.PlyID ~= PlyID then -- Check the player isn't a spy!
			Player:PrintMessage( HUD_PRINTTALK, "You ate a magical lemon, your now Moe Szyslak!" )
			Uploads[PlyID] = nil
			return
		end
		
		Upload.Chunks = Upload.Chunks + 1
		Upload.Data[ChunkID] = Data
		
		if Upload.Chunks == Chunks then -- used to be ChunkID == Chunks
			local Scripts = UnpackScripts( table_concat( Upload.Data, "" ) )
			local Script = Scripts["<code>"]; Scripts["<code>"] = nil -- table_remove( Scripts, "<code>" ) -- Requires number
			
			Entity:LoadScript( Script, Scripts )
			
			Uploads[PlyID][EntID] = nil
			
			net.Start( "lemon_upload_confirm" )
				net.WriteUInt( EntID, 16 )
			net.Send( Player ) -- Tell the player we have received this!
		end
	end
	
	function LEMON.RequestUpload( Entity, Player )
		timer.Simple( 0.5, function( )
			if Entity and Entity:IsValid( ) and Entity:GetClass( ) == "lemongate" then
				if Player and Player:IsValid( ) then
					net.Start( "lemon_upload_request" )
						net.WriteUInt( Entity:EntIndex( ), 16 )
					net.Send( Player ) -- Tell the player we have received this!
				end
			end
		end )
	end
	
	net.Receive( "lemon_upload", Uploader.Rec_Chunk )
end

/*==============================================================================================
		CLIENT
==============================================================================================*/
if CLIENT then
	
	function Uploader.Send_Script( Entity, Script )
		
		local EntID = Entity
		
		if type( Entity ) == "Entity" then
			if !Entity or !Entity:IsValid( ) or Entity:GetClass( ) ~= "lemongate" then -- Check if the entity is a lemongate.
				LocalPlayer( ):PrintMessage( HUD_PRINTTALK, "Either its out of lemons or its not a Lemongate." ) -- Todo: use a better herpderp message then this for client!
				return
			end
			
			EntID = Entity:EntIndex( )
		end
		
		if Uploads[EntID] then -- Check if this entity already has an upload.
			LocalPlayer( ):PrintMessage( HUD_PRINTTALK, "Already fueling that with lemon juice." )
			return
		end
		
		local Error = LEMON.Editor.Validate( )
		
		if Error then
			LocalPlayer( ):PrintMessage( HUD_PRINTTALK, "Them lemons appear to be leaking (Script Error)." )
			return
		end
		
		local Editor = LEMON.Editor.GetInstance( )
		local Data = table.Copy( Editor.Data.Files )
		Data["<code>"] = Script 
		
		local Data = GetChunks( PackScripts( Data ), 65000 )
		local Chunks = #Data
		
		for ChunkID = 1, Chunks do
			net.Start( "lemon_upload" )
				net.WriteUInt( EntID, 16 )
				net.WriteUInt( ChunkID, 16 )
				net.WriteUInt( Chunks, 16 )
				net.WriteUInt( #Data[ChunkID], 16 )
				net.WriteData( Data[ChunkID], #Data[ChunkID] )
			net.SendToServer( )
		end
	end
	
	function LEMON:Upload( Entity, Script )
		Uploader.Send_Script( Entity, Script )
	end
	
	function Uploader.Rec_Confirm( Length )
		local EntID = net.ReadUInt( 16 )
		Uploads[EntID] = nil -- This upload has completed!
	end
	
	function Uploader.Rec_Request( Length )
		Uploader.Send_Script( net.ReadUInt( 16 ), LEMON.Editor.GetCode( ) or "" )
	end
	
	net.Receive( "lemon_upload_confirm", Uploader.Rec_Confirm )
	net.Receive( "lemon_upload_request", Uploader.Rec_Request )
end

/*==============================================================================================
	Section: Lemon Gate Downloader
	Purpose: Sends code from Server to Client.
==============================================================================================*/
LEMON.Downloader = { }
local Downloader = LEMON.Downloader

/*==============================================================================================
		SERVER
==============================================================================================*/
if SERVER then
	Downloader.Downloads = {}
	local Downloads = Downloader.Downloads
	
	util.AddNetworkString( "lemon_download" )
	util.AddNetworkString( "lemon_download_entity" )
	util.AddNetworkString( "lemon_download_confirm" )
	util.AddNetworkString( "lemon_download_request" )
	
	function Downloader.Send_Script( Player, Script, Entity )
		
		if Downloads[ Player:UniqueID( ) ] then
			Player:PrintMessage( HUD_PRINTTALK, "Unable to comply, Juicing in progress!" ) -- CNC reference.
			return
		end
		
		if Entity then
			net.Start( "lemon_download_entity" )
				net.WriteEntity( Entity )
				net.WriteEntity( Entity.Player )
				net.WriteString( Entity.GateName )
			net.Send( Player )
		end
		
		local Data = table.Copy( Entity.Files )
		Data["<code>"] = Script 
		
		local Data = GetChunks( PackScripts( Data ), 65000 )
		local Chunks = #Data
		
		for ChunkID = 1, Chunks do
			net.Start( "lemon_download" )
				net.WriteUInt( ChunkID, 16 )
				net.WriteUInt( Chunks, 16 )
				net.WriteUInt( #Data[ChunkID], 16 )
				net.WriteData( Data[ChunkID], #Data[ChunkID] )
			net.Send( Player )
		end
	end
	
	function Downloader.Rec_Confirm( Length, Player )
		Downloads[ Player:UniqueID( ) ] = nil -- This upload has completed!
	end
	
	net.Receive( "lemon_download_confirm", Downloader.Rec_Confirm )
end

/*==============================================================================================
		CLIENT
==============================================================================================*/
if CLIENT then
	
	function Downloader.Rec_Chunk( length )
		local ChunkID = net.ReadUInt( 16 )
		local Chunks = net.ReadUInt( 16 )
		local DataLen = net.ReadUInt( 16 )
		local Data = net.ReadData( DataLen )
		
		local Download = Downloads
		if !Download then
			Download = { Chunks = 0, Data = { } }
			Downloads = Download
		end
		
		Download.Chunks = Download.Chunks + 1
		
		Download.Data[ChunkID] = Data
		
		if Download.Chunks == Chunks then -- used to be ChunkID == Chunks
			local Scripts = UnpackScripts( table_concat( Download.Data, "" ) )
			local Script = Scripts["<code>"]; Scripts["<code>"] = nil -- table_remove( Scripts, "<code>" ) -- Requires number
			
			Download.Script = Script //table_concat( Download.Data, "" )
			Download.Includes = Scripts
			-- LEMON.Editor.Open( Download.Script, true )
			LEMON.Editor.ReciveDownload( Download )
			Downloads = nil
			
			net.Start( "lemon_download_confirm" )
			net.SendToServer( ) -- Tell the server we have received this!
		end
	end
	
	net.Receive( "lemon_download", Downloader.Rec_Chunk )
	
	net.Receive( "lemon_download_entity", function( )
		if !Downloads then
			Downloads = { Chunks = 0, Data = { } }
		end
		
		Downloads.Entity = net.ReadEntity( )
		Downloads.Player = net.ReadEntity( )
		Downloads.GateName = net.ReadString( )
	end)
end