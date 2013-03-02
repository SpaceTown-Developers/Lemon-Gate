/*==============================================================================================
	Expression Advanced: HTTP Functions
	Purpose: Make your Expression connect to the internet!
	Creditors: JerwuQu
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API

API.NewComponent("HTTP",true)
E_A:RegisterException("http")

/*==============================================================================================
	Section: CVars
==============================================================================================*/
local Enabled = CreateConVar("lemon_http_enabled",1,{FCVAR_ARCHIVE,FCVAR_NOTIFY})

/*==============================================================================================
	Section: Request Tables
==============================================================================================*/
local Requests = {}
API.AddHook("GateCreate",function(Entity)
	Requests[Entity] = {}
end)
API.AddHook("BuildContext",function(Entity)
	Requests[Entity] = {}
end)
API.AddHook("GateRemove",function(Entity)
	Requests[Entity] = nil
end)
API.AddHook("ShutDown",function(Entity)
	Requests[Entity] = nil
end)


/*==============================================================================================
	Section: Functions
==============================================================================================*/
E_A:SetCost(EA_COST_EXPENSIVE)

E_A:RegisterFunction("httpRequest","sff","",function(self,Val1,Val2,Val3)
	local RequestUrl,Function,Function2 = Val1(self),Val2(self),Val3(self)
	if(Enabled:GetInt()==0)then
		self:Throw("http","httpRequest is disabled!")
	elseif(Function.Signature and Function.Signature != "s")then
		self:Throw("invoke","Incorrect callback parameters for onSuccess httpRequest!")
	elseif(Function2.Signature and Function2.Signature != "")then
		self:Throw("invoke","Incorrect callback parameters for onFailure httpRequest!")
	elseif(Function.Return and Function.Return != "")then
		self:Throw("invoke","onSuccess httpRequest does not accept any callback return parameters!")
	elseif(Function2.Return and Function2.Return != "")then
		self:Throw("invoke","onFailure httpRequest does not accept any callback return parameters!")
	end
	local C = #Requests[self.Entity]+1
	Requests[self.Entity][C] = {
		Done = false,
		Success = false,
		Body = nil,
		Func = Function,
		FailFunc = Function2
	}
	http.Fetch(RequestUrl,function(Data,Len,Head,Ret)
		if(Requests[self.Entity] && Requests[self.Entity][C])then
			Requests[self.Entity][C].Body=Data
			Requests[self.Entity][C].Done=true
			Requests[self.Entity][C].Success=true
		end
	end,function(Ret)
		if(Requests[self.Entity] && Requests[self.Entity][C])then
			Requests[self.Entity][C].Done=true
		end
	end)
end)

E_A:RegisterFunction("httpPostRequest","stff","",function(self,Val1,Val2,Val3,Val4)
	local RequestUrl,Params,Function,Function2 = Val1(self),Val2(self),Val3(self),Val4(self)
	if(Enabled:GetInt()==0)then
		self:Throw("http","httpRequest is disabled!")
	elseif(Function.Signature and Function.Signature != "s")then
		self:Throw("invoke","Incorrect callback parameters for onSuccess httpRequest!")
	elseif(Function2.Signature and Function2.Signature != "")then
		self:Throw("invoke","Incorrect callback parameters for onFailure httpRequest!")
	elseif(Function.Return and Function.Return != "")then
		self:Throw("invoke","onSuccess httpRequest does not accept any callback return parameters!")
	elseif(Function2.Return and Function2.Return != "")then
		self:Throw("invoke","onFailure httpRequest does not accept any callback return parameters!")
	end
	local C = #Requests[self.Entity]+1
	Requests[self.Entity][C] = {
		Done = false,
		Success = false,
		Body = nil,
		Func = Function,
		FailFunc = Function2
	}
	http.Post(RequestUrl,Params.Data,function(Data,Len,Head,Ret)
		if(Requests[self.Entity] && Requests[self.Entity][C])then
			Requests[self.Entity][C].Body=Data
			Requests[self.Entity][C].Done=true
			Requests[self.Entity][C].Success=true
		end
	end,function(Ret)
		if(Requests[self.Entity] && Requests[self.Entity][C])then
			Requests[self.Entity][C].Done=true
		end
	end)
end)


/*==============================================================================================
	Section: Think
==============================================================================================*/
API.AddHook("GateThink",function(Entity)
	if Entity then
		local Context = Entity.Context
		if !Entity.Errored and Context and Requests[Entity] then
			for k,Request in pairs(Requests[Entity]) do
				if(Request.Done)then
					if(Request.Success)then
						Request.Func(Context,{function() return Request.Body,"s" end})
					else
						Request.FailFunc(Context,{})
					end
					Request.Done=false
				end
			end
		end
	end
end)
