/*==============================================================================================
    Expression Advanced: File Functions
    Purpose: Edit files.
    Creditors: JerwuQu
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API
API.NewComponent("File",true)
util.AddNetworkString("EAfileOpen")
util.AddNetworkString("EAfileClose")
util.AddNetworkString("EAfileWrite")
util.AddNetworkString("EAfileRead")
util.AddNetworkString("EAfileDelete")
util.AddNetworkString("EAfileCreateDir")
util.AddNetworkString("EAfileFind")
util.AddNetworkString("EAfileNopeDone")
util.AddNetworkString("EAfileOnsDone")
util.AddNetworkString("EAfileTwtDone")
 
/*==============================================================================================
    Class & NO WireMod
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)
E_A:RegisterException("file")
E_A:RegisterClass("file","xfl","")
E_A:RegisterOperator("assign","xfl","",E_A.AssignOperator)
E_A:RegisterOperator("variable","xfl","xfl",E_A.VariableOperator)
E_A:RegisterOperator("trigger","xfl","n",E_A.TriggerOperator)
 
/*==============================================================================================
    Section: File Tables
==============================================================================================*/
local Files = {}
local FileStuff = {}
API.AddHook("GateCreate",function(Entity)
    Files[Entity] = {}
    FileStuff[Entity] = {}
end)
API.AddHook("BuildContext",function(Entity)
    Files[Entity] = {}
    FileStuff[Entity] = {}
end)
API.AddHook("GateRemove",function(Entity)
    Files[Entity] = nil
    FileStuff[Entity] = nil
end)
API.AddHook("ShutDown",function(Entity)
    Files[Entity] = nil
    FileStuff[Entity] = nil
end)
 
/*==============================================================================================
    Section: File Functions
==============================================================================================*/
E_A:SetCost(EA_COST_EXPENSIVE)
 
E_A:RegisterFunction("openFile","ss","xfl",function(self,Val1,Val2)
    local File,Type=Val1(self),Val2(self)
    local C = #Files[self.Entity]+1
    Files[self.Entity][C]={
        FilePath = File,
        OpenType = Type
    }
    while string.find(File,"../",nil,true) do File=string.gsub(File,"../","") end
    File="eafiles/"..File
    net.Start("EAfileOpen")
        net.WriteTable({C,self.Entity,File,Type})
    net.Send(self.Player)
    return C
end)
 
E_A:RegisterFunction("close","xfl:","",function(self,Val1)
    local File=Val1(self)
    if(!Files[self.Entity][File])then
        self:Throw("file","Invalid file!")
    end
    net.Start("EAfileClose")
        net.WriteTable({File,self.Entity})
    net.Send(self.Player)
    Files[self.Entity][File]=nil
end)
E_A:RegisterFunction("write","xfl:sf","",function(self,Val1,Val2,Val3)
    local File,FileData,Callback = Val1(self),Val2(self),Val3(self)
    if(!Files[self.Entity][File])then
        self:Throw("file","Invalid file!")
    end
    if(Callback.Signature and Callback.Signature != "xfl")then
        self:Throw("invoke","Incorrect callback parameters for file.Write callback!")
    elseif(Callback.Return and Callback.Return != "")then
        self:Throw("invoke","file.Write does not accept any callback return parameters!")
    end
    local C = #FileStuff[self.Entity]+1
    FileStuff[self.Entity][C] = {
        Type = "meo",
        Owner = self.Player,
		FileID = File,
        Done = false,
        Func = Callback
    }
    net.Start("EAfileWrite")
        net.WriteTable({C,self.Entity,File,FileData})
    net.Send(self.Player)
end)
E_A:RegisterFunction("fileDelete","sf","",function(self,Val1,Val2)
    local FilePath,Callback = Val1(self),Val2(self)
    while string.find(FilePath,"../",nil,true) do FilePath=string.gsub(FilePath,"../","") end
    FilePath="eafiles/"..FilePath
    if(Callback.Signature and Callback.Signature != "")then
        self:Throw("invoke","Incorrect callback parameters for fileDelete callback!")
    elseif(Callback.Return and Callback.Return != "")then
        self:Throw("invoke","fileDelete does not accept any callback return parameters!")
    end
    local C = #FileStuff[self.Entity]+1
    FileStuff[self.Entity][C] = {
        Type = "nope",
        Owner = self.Player,
        Done = false,
        Func = Callback
    }
    net.Start("EAfileDelete")
        net.WriteTable({C,self.Entity,FilePath})
    net.Send(self.Player)
end)
E_A:RegisterFunction("createDir","sf","",function(self,Val1,Val2)
    local FilePath,Callback = Val1(self),Val2(self)
    while string.find(FilePath,"../",nil,true) do FilePath=string.gsub(FilePath,"../","") end
    FilePath="eafiles/"..FilePath
    if(Callback.Signature and Callback.Signature != "")then
        self:Throw("invoke","Incorrect callback parameters for createDir callback!")
    elseif(Callback.Return and Callback.Return != "")then
        self:Throw("invoke","createDir does not accept any callback return parameters!")
    end
    local C = #FileStuff[self.Entity]+1
    FileStuff[self.Entity][C] = {
        Type = "nope",
        Owner = self.Player,
        Done = false,
        Func = Callback
    }
    net.Start("EAfileCreateDir")
        net.WriteTable({C,self.Entity,FilePath})
    net.Send(self.Player)
end)
E_A:RegisterFunction("read","xfl:f","",function(self,Val1,Val2)
    local File,Callback = Val1(self),Val2(self)
    if(!Files[self.Entity][File])then
        self:Throw("file","Invalid file!")
    end
    if(Callback.Signature and Callback.Signature != "sxfl")then
        self:Throw("invoke","Incorrect callback parameters for file.Read callback!")
    elseif(Callback.Return and Callback.Return != "")then
        self:Throw("invoke","file.Read does not accept any callback return parameters!")
    end
    local C = #FileStuff[self.Entity]+1
    FileStuff[self.Entity][C] = {
        Type = "ons",
        Owner = self.Player,
        Done = false,
		FileID = File,
        Func = Callback,
        Data = nil
    }
    net.Start("EAfileRead")
        net.WriteTable({C,self.Entity,File})
    net.Send(self.Player)
end)
E_A:RegisterFunction("fileFind","sf","",function(self,Val1,Val2)
    local FilePath,Callback = Val1(self),Val2(self)
    while string.find(FilePath,"../",nil,true) do FilePath=string.gsub(FilePath,"../","") end
    FilePath="eafiles/"..FilePath
    if(Callback.Signature and Callback.Signature != "tt")then
        self:Throw("invoke","Incorrect callback parameters for fileFind callback!")
    elseif(Callback.Return and Callback.Return != "")then
        self:Throw("invoke","fileFind does not accept any callback return parameters!")
    end
    local C = #FileStuff[self.Entity]+1
    FileStuff[self.Entity][C] = {
        Type = "twt",
        Owner = self.Player,
        Done = false,
        Func = Callback,
        Tab1 = nil,
        Tab2 = nil
    }
    net.Start("EAfileFind")
        net.WriteTable({C,self.Entity,FilePath})
    net.Send(self.Player)
end)
 
/*==============================================================================================
    Section: File functions that doesn't really callbacks
==============================================================================================*/
 
E_A:RegisterFunction("write","xfl:s","",function(self,Val1,Val2)
    local File,FileData = Val1(self),Val2(self)
    if(!Files[self.Entity][File])then
        self:Throw("file","Invalid file!")
    end
    net.Start("EAfileWrite")
        net.WriteTable({0,self.Entity,File,FileData})
    net.Send(self.Player)
end)
E_A:RegisterFunction("fileDelete","s","",function(self,Val1)
    local FilePath = Val1(self)
    while string.find(FilePath,"../",nil,true) do FilePath=string.gsub(FilePath,"../","") end
    FilePath="eafiles/"..FilePath
    net.Start("EAfileDelete")
        net.WriteTable({0,self.Entity,FilePath})
    net.Send(self.Player)
end)
E_A:RegisterFunction("createDir","s","",function(self,Val1)
    local FilePath = Val1(self)
    while string.find(FilePath,"../",nil,true) do FilePath=string.gsub(FilePath,"../","") end
    FilePath="eafiles/"..FilePath
    net.Start("EAfileCreateDir")
        net.WriteTable({0,self.Entity,FilePath})
    net.Send(self.Player)
end)
 
/*==============================================================================================
    Section: Other cool file functions
==============================================================================================*/
E_A:RegisterFunction("filePath","xfl:","s",function(self,Val1)
    local File = Val1(self)
    if(!Files[self.Entity][File] || !Files[self.Entity][File].FilePath || Files[self.Entity][File].FilePath=="")then
        self:Throw("file","Invalid file!")
    end
    return Files[self.Entity][File].FilePath
end)
 
/*==============================================================================================
    Section: Network hooks
==============================================================================================*/
net.Receive("EAfileNopeDone",function(len,client)
    local Tab = net.ReadTable()
   local C = Tab[1]
    local Entity = Tab[2]
   if(FileStuff[Entity] && FileStuff[Entity][C] && FileStuff[Entity][C].Owner == client && FileStuff[Entity][C].Type == "nope")then
        FileStuff[Entity][C].Done=true
    end
end)
 
net.Receive("EAfileOnsDone",function(len,client)
    local Tab = net.ReadTable()
   local C = Tab[1]
    local Entity = Tab[2]
   if(FileStuff[Entity] && FileStuff[Entity][C] && FileStuff[Entity][C].Owner == client && FileStuff[Entity][C].Type == "ons")then
        FileStuff[Entity][C].Data=Tab[3]
        FileStuff[Entity][C].Done=true
    end
end)
 
net.Receive("EAfileTwtDone",function(len,client)
    local Tab = net.ReadTable()
   local C = Tab[1]
    local Entity = Tab[2]
   if(FileStuff[Entity] && FileStuff[Entity][C] && FileStuff[Entity][C].Owner == client && FileStuff[Entity][C].Type == "twt")then
        FileStuff[Entity][C].Tab1=Tab[3]
        FileStuff[Entity][C].Tab2=Tab[4]
        FileStuff[Entity][C].Done=true
    end
end)
 
/*==============================================================================================
    Section: Think
==============================================================================================*/
API.AddHook("GateThink",function(Entity)
    if Entity then
        local Context = Entity.Context
        if !Entity.Errored and Context and FileStuff[Entity] then
            for k,Filen in pairs(FileStuff[Entity]) do
                if(Filen.Done)then
                    if(Filen.Func)then
                        if(Filen.Type=="nope")then
                            Filen.Func(Context,{})
						elseif(Filen.Type=="meo")then
                            Filen.Func(Context,{function() return Filen.FileID,"xfl" end})
                        elseif(Filen.Type=="ons")then
                            Filen.Func(Context,{function() return Filen.Data,"s" end,function() return Filen.FileID,"xfl" end})
                        elseif(Filen.Type=="twt")then
                            Filen.Func(Context,{function() return E_A.NewResultTable(Filen.Tab1,"s"),"t" end,function() return E_A.NewResultTable(Filen.Tab2,"s"),"t" end})
                        end
                    end
                    Filen.Done=false
                end
            end
        end
    end
end)