/*==============================================================================================
	Expression Advanced: Component -> Files.
	Creditors: JerwuQu
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API
local Component = API:NewComponent( "files", true )
local string = string

AddCSLuaFile( "cl_file.lua" )

/*==============================================================================================
	Section: Network Strings
==============================================================================================*/
util.AddNetworkString( "Lemon_File.Open" )
util.AddNetworkString( "Lemon_File.Close" )
util.AddNetworkString( "Lemon_File.Write" )
util.AddNetworkString( "Lemon_File.Read" )
util.AddNetworkString( "Lemon_File.Delete" )
util.AddNetworkString( "Lemon_File.CreateDir" )
util.AddNetworkString( "Lemon_File.Find" )
util.AddNetworkString( "Lemon_File.NopeDone" )
util.AddNetworkString( "Lemon_File.OnsDone" )
util.AddNetworkString( "Lemon_File.TwtDone" )

/*==============================================================================================
	Section: API Hooks
==============================================================================================*/
local Files, File_Stuff = { }, { }

function Component:CreateContext( Context )
	Files[Context.Entity] = { }
	File_Stuff[Context.Entity] = { }
end

/*==============================================================================================
	Section: Class and import!
==============================================================================================*/
Component:NewClass( "fl", "file" )

Component:AddExternal( "File", Component )

/*==============================================================================================
	Section: Open File
==============================================================================================*/
function Component:OpenFile( Context, File, Type )
	local I = #Files[Context.Entity] + 1
	
	Files[Context.Entity][I]={
        FilePath = File,
        OpenType = Type
    }
	
    while string.find( File, "../", nil, true ) do
		File = string.gsub( File, "../", "" )
	end
	
    File = "lemon_files/" .. File
	
    net.Start( "Lemon_File.Open" )
        net.WriteTable( { I, Context.Entity, File, Type } )
    net.Send( Context.Player )
	
    return I
end

Component:AddFunction( "openFile", "s,s", "fl", "%File:OpenFile( %context, value %1, value %2 )" )

/*==============================================================================================
	Section: Close
==============================================================================================*/
function Component:CloseFile( Trace, Context, File )
	if !Files[Context.Entity][File] then
        Context:Throw( Trace, "file","Invalid file!" )
    end
	
    net.Start( "Lemon_File.Close" )
        net.WriteTable( { File, Context.Entity } )
    net.Send( Context.Player )
	
    Files[Context.Entity][File] = nil
end

Component:AddFunction( "close", "fl:", "", "%File:CloseFile( %trace, %context, value %1 )" )

/*==============================================================================================
	Section: Write
==============================================================================================*/
function Component:WriteFile( Trace, Context, File, FileData, CallBack )
	if !Files[Context.Entity][File] then
        Context:Throw(Trace, "file","Invalid file!")
    end
	
	local I = 0
	
	if CallBack then
		I = #File_Stuff[Context.Entity] + 1
		
		File_Stuff[Context.Entity][I] = {
			Type = "meo",
			Owner = Context.Player,
			FileID = File,
			Done = false,
			Func = CallBack
		}
	end
	
    net.Start( "Lemon_File.Write" )
        net.WriteTable( { I, Context.Entity, File, FileData } )
    net.Send( Context.Player )
end

Component:AddFunction( "write", "fl:s", "", "%File:WriteFile( %trace, %context, value %1, value %2 )" )
Component:AddFunction( "write", "fl:s,f", "", "%File:WriteFile( %trace, %context, value %1, value %2, value %3 )" )

/*==============================================================================================
	Section: Delete
==============================================================================================*/
function Component:DeleteFile( Context, FilePath, CallBack )
	while string.find( FilePath, "../", nil, true ) do
		FilePath = string.gsub( FilePath, "../", "" )
	end
		
    FilePath = "lemon_files/" .. FilePath
	
	local I = 0
	
	if CallBack then
		I = #File_Stuff[Context.Entity] + 1
		File_Stuff[Context.Entity][I] = {
			Type = "nope",
			Owner = Context.Player,
			Done = false,
			Func = CallBack
		}
	end
	
    net.Start( "Lemon_File.Delete" )
        net.WriteTable( { I, Context.Entity, FilePath } )
    net.Send( Context.Player )
end

Component:AddFunction( "fileDelete", "s", "", "%File:DeleteFile( %context, value %1 )" )
Component:AddFunction( "fileDelete", "s,f", "", "%File:DeleteFile( %context, value %1, value %2 )" )

/*==============================================================================================
	Section: CreateDir
==============================================================================================*/
function Component:CreateDir( Context, FilePath, CallBack )
	while string.find( FilePath, "../", nil, true ) do
		FilePath = string.gsub( FilePath, "../", "" )
	end
		
    FilePath = "lemon_files/" .. FilePath
	
	local I = 0
	
	if CallBack then
		I = #File_Stuff[Context.Entity] + 1
		File_Stuff[Context.Entity][I] = {
			Type = "nope",
			Owner = Context.Player,
			Done = false,
			Func = CallBack
		}
	end
	
    net.Start( "Lemon_File.CreateDir" )
        net.WriteTable( { I, Context.Entity, FilePath } )
    net.Send( Context.Player )
end

Component:AddFunction( "createDir", "s", "", "%File:CreateDir( %context, value %1 )" )
Component:AddFunction( "createDir", "s,f", "", "%File:CreateDir( %context, value %1, value %2 )" )

/*==============================================================================================
	Section: ReadFile
==============================================================================================*/
function Component:ReadFile( Trace, Context, File, CallBack )
	if !Files[Context.Entity][File] then
        Context:Throw( Trace, "file","Invalid file!" )
    end
	
    local I = #File_Stuff[Context.Entity] + 1
    File_Stuff[Context.Entity][I] = {
		Type = "ons",
		Owner = Context.Player,
		Done = false,
		FileID = File,
		Func = CallBack,
		Data = nil
    }
	
    net.Start( "Lemon_File.Read" )
        net.WriteTable( { I, Context.Entity, FilePath } )
    net.Send( Context.Player )
end

Component:AddFunction( "read", "fl:f", "", "%File:ReadFile( %trace, %context, value %1, value %2 )" )

/*==============================================================================================
	Section: FileFind
==============================================================================================*/
function Component:FileFind( Context, FilePath, CallBack )
	while string.find( FilePath, "../", nil, true ) do
		FilePath = string.gsub( FilePath, "../", "" )
	end
		
    FilePath = "lemon_files/" .. FilePath
	
    local I = #File_Stuff[Context.Entity] + 1
    File_Stuff[Context.Entity][I] = {
		Type = "twt",
		Owner = Context.Player,
		Done = false,
		Func = CallBack,
		Tab1 = nil,
		Tab2 = nil
    }
	
    net.Start( "Lemon_File.Find" )
        net.WriteTable( { I, Context.Entity, FilePath } )
    net.Send( Context.Player )
end

Component:AddFunction( "fileFind", "s,f", "", "%File:FileFind( %context, value %1, value %2 )" )
 
/*==============================================================================================
    Section: File Path
==============================================================================================*/
function Component:FilePath( Trace, Context, File, CallBack )
	if !Files[Context.Entity][File] then
        Context:Throw( Trace, "file","Invalid file!" )
    end
	
    return Files[self.Entity][File].FilePath
end

Component:AddFunction( "filePath", "fl:", "s", "%File:ReadFile( %context, value %1 )" )
 
/*==============================================================================================
    Section: Network Hooks
==============================================================================================*/
net.Receive( "Lemon_File.NopeDone", function( Len, Client )
	local Tab = net.ReadTable( )
	local C, Entity = Tab[1], Tab[2]
	local Data = File_Stuff[Entity]
	
	if Data and Data[C] and Data[C].Owner == Client and Data[C].Type == "nope" then
		if Data[C].CallBack then
			if Entity:Pcall( "file callback", Data[C].CallBack ) then
				Entity:Update( )
			end
		end
		
		Data[C] = nil
	end
end)

net.Receive( "Lemon_File.OnsDone", function( Len, Client )
	local Tab = net.ReadTable( )
	local C, Entity = Tab[1], Tab[2]
	local Data = File_Stuff[Entity]
	
	if Data and Data[C] and Data[C].Owner == Client and Data[C].Type == "ons" then
		if Data[C].CallBack then
			if Entity:Pcall( "file callback", Data[C].CallBack, { Tab[3], "s" }, { Data[C].FileID, "xfl" } ) then
				Entity:Update( )
			end
		end
		
		Data[C] = nil
	end
end)

local Table = API:GetComponent( "table" ):GetMetaTable( )

net.Receive( "Lemon_File.TwtDone", function( Len, Client )
	local Tab = net.ReadTable( )
	local C, Entity = Tab[1], Tab[2]
	local Data = File_Stuff[Entity]
	
	if Data and Data[C] and Data[C].Owner == Client and Data[C].Type == "twt" then
		if Data[C].CallBack then
			if Entity:Pcall( "file callback", Data[C].CallBack, { Table.Results( Tab[3], "s" ), "t" }, { Table.Results( Tab[4], "s" ), "t" } ) then
				Entity:Update( )
			end
		end
		
		Data[C] = nil
	end
end)
