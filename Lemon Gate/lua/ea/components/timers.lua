/*==============================================================================================
	Expression Advanced: Callback Timers.
	Purpose: Based on Garry's lua timers =D
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API

local CallOp = E_A.CallOp
local CurTime = CurTime
local Date = os.date

local PAUSED = -1
local STOPPED = 0
local RUNNING = 1

/*==============================================================================================
	Section: Timer Tables
==============================================================================================*/
local Timers = { }

API.AddHook("GateCreate", function(Entity)
	Timers[Entity] = { }
end)

API.AddHook("BuildContext", function(Entity)
	Timers[Entity] = { }
end)

API.AddHook("GateRemove", function(Entity)
	Timers[Entity] = nil
end)

API.AddHook("ShutDown", function(Entity)
	Timers[Entity] = nil
end)

local function GetTimer( self, Name )
	return Timers[self.Entity][Name]
end

/*==============================================================================================
	Section: Time
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterFunction("curTime", "", "n",
	function(self)
		return CurTime()
	end)

E_A:RegisterFunction("time", "s", "n",
	function(self, Value)
		local V = Value(self)
		local Time = Date("!*t")
		local TU = Date[component]

		return tonumber(TU) or TU and 1 or 0
	end)

/*==============================================================================================
	Section: Timers
==============================================================================================*/
E_A:SetCost(EA_COST_EXPENSIVE)

E_A:RegisterFunction("timerCreate", "snnf", "",
	function(self, ValueA, ValueB, ValueC, Lambda)
		local A, B, C, L = ValueA(self), ValueB(self), ValueC(self), Lambda(self)
		
		if L.Signature and L.Signature ~= "" then
			self:Throw("invoke", "timer callback does not accept peramaters.")
		elseif L.Return and L.Return ~= "" then
			self:Throw("invoke", "timer callback does not allow return values.")
		end
		
		Timers[self.Entity][A] = {
			N = 0,
			Status = RUNNING,
			Last = CurTime(),
			Delay = B,
			Repetitions = C,
			Lambda = L
		}
	end)

E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("timerAdjust", "snn", "",
	function(self, ValueA, ValueB, ValueC)
		local Timer = GetTimer(self, ValueA(self))
		if Timer then
			Timer.Delay = ValueB(self)
			Timer.Repetitions = ValueC(self)
		end
	end)

E_A:RegisterFunction("timerRemove", "s", "",
	function(self, Value)
		Timers[self.Entity][ Value(self) ] = nil
	end)

E_A:RegisterFunction("timerStart", "s", "n",
	function(self, Value)
		local Timer = GetTimer(self, Value(self))
		if Timer and Timer.Status != RUNNING then
			Timer.N = 0
			Timer.Status = RUNNING
			Timer.Last = CurTime()
			return 1
		end
		
		return 0
	end)

E_A:RegisterFunction("timerPause", "s", "n",
	function(self, Value)
		local Timer = GetTimer(self, Value(self))
		if Timer and Timer.Status == RUNNING then
			Timer.Diff = CurTime() - Timer.Last
			Timer.Status = PAUSED
			return 1
		end
		
		return 0
	end)

E_A:RegisterFunction("timerUnpause", "s", "n",
	function(self, Value)
		local Timer = GetTimer(self, Value(self))
		if Timer and Timer.Status == PAUSED then
			Timer.Diff = nil
			Timer.Status = RUNNING
			return 1
		end
		
		return 0
	end)

E_A:RegisterFunction("timerStop", "s", "n",
	function(self, Value)
		local Timer = GetTimer(self, Value(self))
		if Timer and Timer.Status != STOPPED then
			Timer.Status = STOPPED
			return 1
		end
		
		return 0
	end)

E_A:RegisterFunction("timerStatus", "s", "n",
	function(self, Value)
		local Timer = GetTimer(self, Value(self))
		if Timer then return Timer.Status end
		return 0
	end)

/*==============================================================================================
	Section: 
==============================================================================================*/

E_A.API.AddHook("GateThink", function(Entity)
	if Entity then
		local Context, Time = Entity.Context, CurTime()
		
		if !Entity.Errored and Context and Timers[Entity] then
			for Key, Timer in pairs( Timers[Entity] ) do
				if Timer.Status == PAUSED then
					Timer.Last = Time - Timer.Diff

				elseif Timer.Status == RUNNING and ( Timer.Last + Timer.Delay ) <= Time then
					Timer.Last = Time
					Timer.N = Timer.N + 1 

					if Timer.N >= Timer.Repetitions and Timer.Repetitions != 0 then
						Timer.Status = STOPPED
					end
								
					local Ok, ExitCode = Timer.Lambda( Context )
					
					if Ok or ExitCode == "Exit" then
						Entity:TriggerOutputs()
					else
						Entity:Exit( Exit )
						break
					end
				end
			end
		end
	end
end)
