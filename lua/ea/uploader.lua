/*==============================================================================================
	Expression Advanced: Uploader and Downloader.
	Creditors: Rusketh, Oskar94, Divran
==============================================================================================*/
local E_A = LemonGate

local table_concat = table.concat
local string_sub = string.sub 
local string_gsub = string.gsub 
local string_char = string.char 
local string_len = string.len 
local string_lower = string.lower

local type = type
local net = net

/*==============================================================================================
	Section: Chunk Chopper
	Purpose: Sends code from Client to Server.
	Todo: Add string compression?
==============================================================================================*/
function E_A.GetChunks( String, Size )
	local Data = {}
	
	while string_len( String ) > Size do 
		Data[#Data + 1] = string_sub( String, 1, Size )
		String = string_sub( String, Size + 1)
	end
	
	Data[#Data + 1] = String
	
	return Data
end; local GetChunks = E_A.GetChunks

/*==============================================================================================
	Section: Lemon Gate Uploader
	Purpose: Sends code from Client to Server.
==============================================================================================*/
E_A.Uploader = { Uploads = {} }
local Uploader = E_A.Uploader
local Uploads = Uploader.Uploads

/*==============================================================================================
		SERVER
==============================================================================================*/
if SERVER then
	
	util.AddNetworkString( "lemon_upload" )
	util.AddNetworkString( "lemon_upload_confirm" )
	util.AddNetworkString( "lemon_upload_request" )
	
	function Uploader.Rec_Chunk( length, Player )
		local PlyID = Player:UniqueID()
		local EntID = net.ReadUInt( 16 )
		local ChunkID = net.ReadUInt( 16 )
		local Chunks = net.ReadUInt( 16 )
		local Data = net.ReadString()
		
		local Entity = Entity(EntID) -- Check if the entity is a lemongate.
		if !Entity or !Entity:IsValid() or Entity:GetClass() ~= "lemongate" then
			Player:PrintMessage( HUD_PRINTTALK, "Either its out of lemons or its not a Lemongate." )
			Uploads[PlyID][EntID] = nil
			return
		end
		
		if !Uploads[PlyID] then Uploads[PlyID] = {} end -- Give player an upload session.
		
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
			
			local Script = table_concat( Upload.Data, "" )
			Entity:LoadScript( Script )
			Entity:Execute()
			
			Uploads[PlyID][EntID] = nil
			
			net.Start( "lemon_upload_confirm" )
				net.WriteUInt( EntID, 16 )
			net.Send( Player ) -- Tell the player we have received this!
		end
	end
	
	function E_A.RequestUpload(Entity, Player)
		if Entity and Entity:IsValid() and Entity:GetClass() == "lemongate" then
			net.Start( "lemon_upload_request" )
				net.WriteUInt( Entity:EntIndex(), 16 )
			net.Send( Player ) -- Tell the player we have received this!
		end
	end
	
	net.Receive( "lemon_upload", Uploader.Rec_Chunk )
end

/*==============================================================================================
		CLIENT
==============================================================================================*/
if CLIENT then
	
	function Uploader.Send_Script( Entity, Script )
		
		local EntID = Entity
		
		if type(Entity) == "Entity" then
			if !Entity or !Entity:IsValid() or Entity:GetClass() ~= "lemongate" then -- Check if the entity is a lemongate.
				LocalPlayer():PrintMessage( HUD_PRINTTALK, "Either its out of lemons or its not a Lemongate." ) -- Todo: use a better herpderp message then this for client!
				return
			end
			
			EntID = Entity:EntIndex()
		end
		
		if Uploads[EntID] then -- Check if this entity already has an upload.
			LocalPlayer():PrintMessage( HUD_PRINTTALK, "Already fueling that with lemon juice." )
			return
		end
		
		local Error = E_A.Editor.Validate( )
		
		if Error then
			LocalPlayer():PrintMessage( HUD_PRINTTALK, "Them lemons appear to be leaking (Script Error)." )
			return
		end
		
		local Data = GetChunks( Script, 65000 )
		local Chunks = #Data
		
		for ChunkID = 1, Chunks do
			net.Start( "lemon_upload" )
				net.WriteUInt( EntID, 16 )
				net.WriteUInt( ChunkID, 16 )
				net.WriteUInt( Chunks, 16 )
				net.WriteString( Data[ ChunkID ] )
			net.SendToServer()
		end
	end
	
	function E_A:Upload(Entity, Script)
		Uploader.Send_Script( Entity, Script )
	end
	
	function Uploader.Rec_Confirm( Length )
		local EntID = net.ReadUInt( 16 )
		Uploads[EntID] = nil -- This upload has completed!
	end
	
	function Uploader.Rec_Request( Length )
		Uploader.Send_Script( net.ReadUInt( 16 ), E_A.Editor.GetCode() or "" )
	end
	
	net.Receive( "lemon_upload_confirm", Uploader.Rec_Confirm )
	net.Receive( "lemon_upload_request", Uploader.Rec_Request )
end

/*==============================================================================================
	Section: Lemon Gate Downloader
	Purpose: Sends code from Server to Client.
==============================================================================================*/
E_A.Downloader = { }
local Downloader = E_A.Downloader

/*==============================================================================================
		SERVER
==============================================================================================*/
if SERVER then
	Downloader.Downloads = {}
	local Downloads = Downloader.Downloads
	
	util.AddNetworkString( "lemon_download" )
	util.AddNetworkString( "lemon_download_confirm" )
	util.AddNetworkString( "lemon_download_request" )
	
	function Downloader.Send_Script( Player, Script )
		
		if Downloads[ Player:UniqueID() ] then
			Player:PrintMessage( HUD_PRINTTALK, "Unable to comply, Juicing in progress!" ) -- CNC reference.
			return
		end
		
		local Data = GetChunks( Script, 65000 )
		local Chunks = #Data
		
		for ChunkID = 1, Chunks do
			net.Start( "lemon_download" )
				net.WriteUInt( ChunkID, 16 )
				net.WriteUInt( Chunks, 16 )
				net.WriteString( Data[ ChunkID ] )
			net.Send( Player )
		end
	end
	
	function Downloader.Rec_Confirm( Length, Player )
		Downloads[ Player:UniqueID() ] = nil -- This upload has completed!
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
		local Data = net.ReadString()
		
		local Download = Downloads
		if !Download then
			Download = { Chunks = 0, Data = { } }
			Downloads = Download
		end
		
		Download.Chunks = Download.Chunks + 1
		
		Download.Data[ChunkID] = Data
		
		if Download.Chunks == Chunks then -- used to be ChunkID == Chunks
			local Script = table_concat( Download.Data, "" )
			E_A.Editor.NewTab(Script)
			Downloads = nil
			
			net.Start( "lemon_download_confirm" )
			net.SendToServer( Player ) -- Tell the player we have received this!
		end
	end
	
	net.Receive( "lemon_download", Downloader.Rec_Chunk )
end