/*==============================================================================================
Expression Advanced: Client-side file Functions
Purpose: Edit files.
Creditors: JerwuQu
==============================================================================================*/
if SERVER then
	return
end

local Files = {}

file.CreateDir( "lemon_files" )

net.Receive( "Lemon_File.Open" , function( len )
	local Tab = net.ReadTable( )
	if !Files[Tab[2]] then
		Files[Tab[2]]={}
	end
	
	Files[Tab[2]][Tab[1]] = file.Open( Tab[3], Tab[4], "DATA" )
end )

net.Receive( "Lemon_File.Close", function( len )
	local Tab = net.ReadTable( )
	
	if Files[Tab[2]][Tab[1]] then
		Files[Tab[2]][Tab[1]]:Close( )
	end
	
	print( "CLOSED!" )
end )

net.Receive( "Lemon_File.Write", function( len )
	local Tab = net.ReadTable( )
	
	if Files[Tab[2]][Tab[3]] then
		Files[Tab[2]][Tab[3]]:Write( Tab[4] )
	end
	
	if Tab[1] > 0 then
		net.Start( "Lemon_File.NopeDone" )
		net.WriteTable( { Tab[1], Tab[2] } )
		net.SendToServer( )
	end
end )

net.Receive( "Lemon_File.Delete", function( len )
	local Tab = net.ReadTable( )
	
	file.Delete( Tab[3] )
	
	if Tab[1] > 0 then
		net.Start( "Lemon_File.NopeDone" )
		net.WriteTable( { Tab[1], Tab[2] } )
		net.SendToServer( )
	end
end )

net.Receive( "Lemon_File.CreateDir", function( len )
	local Tab = net.ReadTable( )
	
	file.CreateDir( Tab[3] )
	
	if Tab[1] > 0 then
		net.Start( "Lemon_File.NopeDone" )
		net.WriteTable( { Tab[1], Tab[2] } )
		net.SendToServer( )
	end
end )

net.Receive( "Lemon_File.Read", function( len )
	local Tab = net.ReadTable( )
	local data = nil
	
	if(Files[Tab[2]][Tab[3]])then
		data = Files[Tab[2]][Tab[3]]:Read( Files[Tab[2]][Tab[3]]:Size( ) )
	end
	
	net.Start( "Lemon_File.OnsDone" )
		net.WriteTable( { Tab[1], Tab[2], data } )
	net.SendToServer( )
end )

net.Receive( "Lemon_File.Find", function( len )
	local Tab = net.ReadTable( )
	
	local f, d = file.Find( Tab[3], "DATA" )
	
	net.Start( "Lemon_File.TwtDone" )
		net.WriteTable( { Tab[1], Tab[2], f, d } )
	net.SendToServer( )
end )