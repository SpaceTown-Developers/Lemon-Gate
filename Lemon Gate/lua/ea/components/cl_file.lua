/*==============================================================================================
	Expression Advanced: Client-side file Functions
	Purpose: Edit files.
	Creditors: JerwuQu
==============================================================================================*/
if SERVER then return end
local Files = {}
net.Receive("EAfileOpen",function(len)
	local Tab=net.ReadTable()
	if(!Files[Tab[2]])then
		Files[Tab[2]]={}
	end
	Files[Tab[2]][Tab[1]]=file.Open(Tab[3],Tab[4],"DATA")
end)
net.Receive("EAfileClose",function(len)
	print("close")
	local Tab=net.ReadTable()
	if(Files[Tab[2]][Tab[1]])then
		Files[Tab[2]][Tab[1]]:Close()
	end
end)
net.Receive("EAfileWrite",function(len)
	print("wrote")
	local Tab=net.ReadTable()
	if(Files[Tab[2]][Tab[3]])then
		Files[Tab[2]][Tab[3]]:Write(Tab[4])
	end
	if(Tab[1]>0)then
		net.Start("EAfileNopeDone")
			net.WriteTable({Tab[1],Tab[2]})
		net.SendToServer()
	end
end)
net.Receive("EAfileDelete",function(len)
	local Tab=net.ReadTable()
	file.Delete(Tab[3])
	if(Tab[1]>0)then
		net.Start("EAfileNopeDone")
			net.WriteTable({Tab[1],Tab[2]})
		net.SendToServer()
	end
end)
net.Receive("EAfileCreateDir",function(len)
	local Tab=net.ReadTable()
	file.CreateDir(Tab[3])
	if(Tab[1]>0)then
		net.Start("EAfileNopeDone")
			net.WriteTable({Tab[1],Tab[2]})
		net.SendToServer()
	end
end)
net.Receive("EAfileRead",function(len)
	local Tab=net.ReadTable()
	local data=nil
	if(Files[Tab[2]][Tab[3]])then
		data=Files[Tab[2]][Tab[3]]:Read(Files[Tab[2]][Tab[3]]:Size())
	end
	Msg("Data: ")
	print(data)
	net.Start("EAfileOnsDone")
		net.WriteTable({Tab[1],Tab[2],data})
	net.SendToServer()
end)
net.Receive("EAfileFind",function(len)
	local Tab=net.ReadTable()
	local f,d=file.Find(Tab[3],"DATA")
	net.Start("EAfileTwtDone")
		net.WriteTable({Tab[1],Tab[2],f,d})
	net.SendToServer()
end)