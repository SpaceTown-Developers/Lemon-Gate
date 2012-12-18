/*==============================================================================================
	Expression Advanced: Callback Timers.
	Purpose: Based on Garry's lua timers =D
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local CallOp = E_A.CallOp
local CurTime = CurTime
local Date = os.date

local PAUSED = -1
local STOPPED = 0
local RUNNING = 1

/*==============================================================================================
	Section: Time
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterFunction("curTime", "", "n", function(self)
	return CurTime()
end)

E_A:RegisterFunction("time", "s", "n", function(self, Value)
	local V = Value(self)
	local Time = Date("!*t")
	local TU = Date[component]

	return tonumber(TU) or TU and 1 or 0
end)

/*==============================================================================================
	Section: Timers
==============================================================================================*/
E_A:SetCost(EA_COST_EXPENSIVE)

E_A:RegisterFunction("timerCreate", "snnf", "", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, C, D = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	
	local P, R = D[1], D[4]
	
	if P and P ~= "" then -- TODO: VarArgs
		self:Throw("invoke", "Timer callbacks can not take parameters.")
	elseif R and R ~= "" then
		self:Throw("invoke", "Timer callback return type  must be number")
	end
	
	self.Timers[A] = {N = 0, Status = RUNNING, Last = CurTime(), Delay = B, Repetitions = C, Func = D[3]}
end)

E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("timerAdjust", "snn", "", function(self, ValueA, ValueB, ValueC)
	local Timer = self.Timers[ValueA(self)]
	if Timer then
		Timer.Delay = ValueB(self)
		Timer.Repetitions = ValueC(self)
	end
end)

E_A:RegisterFunction("timerRemove", "s", "", function(self, Value)
	self.Timers[Value(self)] = nil
end)

E_A:RegisterFunction("timerStart", "s", "n", function(self, Value)
	local Timer = self.Timers[Value(self)]
	if Timer and Timer.Status != RUNNING then
		Timer.N = 0
		Timer.Status = RUNNING
		Timer.Last = CurTime()
		return 1
	end
	
	return 0
end)

E_A:RegisterFunction("timerPause", "s", "n", function(self, Value)
	local Timer = self.Timers[Value(self)]
	if Timer and Timer.Status == RUNNING then
		Timer.Diff = CurTime() - Timer.Last
        Timer.Status = PAUSED
		return 1
	end
	
	return 0
end)

E_A:RegisterFunction("timerUnpause", "s", "n", function(self, Value)
	local Timer = self.Timers[Value(self)]
	if Timer and Timer.Status == PAUSED then
		Timer.Diff = nil
        Timer.Status = RUNNING
		return 1
	end
	
	return 0
end)

E_A:RegisterFunction("timerStop", "s", "n", function(self, Value)
	local Timer = self.Timers[Value(self)]
	if Timer and Timer.Status != STOPPED then
		Timer.Status = STOPPED
		return 1
	end
	
	return 0
end)

E_A:RegisterFunction("timerStatus", "s", "n", function(self, Value)
	local Timer = self.Timers[Value(self)]
	if Timer then return Timer.Status end
	return 0
end)

/*==============================================================================================
	Section: Context
==============================================================================================*/
E_A.API.AddHook("GateThink", function(Entity)
	if !Entity or !Entity.Context then return end
	
	local Context, CurTime, Update = Entity.Context, CurTime()
	
	for Key, Timer in pairs( Context.Timers ) do
		if ( Timer.Status == PAUSED ) then

			Timer.Last = CurTime - Timer.Diff

		elseif ( Timer.Status == RUNNING and ( Timer.Last + Timer.Delay ) <= CurTime ) then

			Timer.Last = CurTime
			Timer.N = Timer.N + 1 

			if ( Timer.N >= Timer.Repetitions and Timer.Repetitions != 0) then
				Timer.Status = STOPPED
			end
			
			local Ok, Exception, RetValue = Timer.Func:SafeCall(Context)
			
				if Ok or Exception == "exit" then
					Update = true
				elseif Exception == "script" then
					return Entity:ScriptError(Message)
				elseif Exception == "return" or Exception == "break" or Exception == "continue" then
					return Entity:ScriptError("unexpected use of " .. Exception .. " reaching main execution")
				elseif Context.Exception and Context.Exception == Exception then
					return Entity:ScriptError("unexpected exception '" .. Exception .. "' in timer '" .. Key .. "'")
				else
					return Entity:LuaError(Exception, Message)
				end
	
		end
	end
	
	if Update then
		Entity:TriggerOutputs()
	end
end)
