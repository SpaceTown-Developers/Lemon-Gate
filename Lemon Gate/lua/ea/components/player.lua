/*==============================================================================================
	Expression Advanced: Entities.
	Purpose: Entities are stuffs.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local NULL_ENTITY = Entity(-1)

/*==============================================================================================
	Section: Player Stuff
==============================================================================================*/
E_A:RegisterFunction("isPlayer", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsPlayer() then return 1 end
	return 0
end)

E_A:RegisterFunction("isAdmin", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsPlayer() and Entity:IsAdmin() then return 1 end
	return 0
end)

E_A:RegisterFunction("isSuperAdmin", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsPlayer() and Entity:IsSuperAdmin() then return 1 end
	return 0
end)

/*==============================================================================================
	Section: Aiming and Eye
==============================================================================================*/

E_A:RegisterFunction("shootPos", "e:", "v", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and (Entity:IsPlayer() or Entity:IsNPC()) then
		local Pos = Entity:GetShootPos()
		return {Pos.x, Pos.y, Pos.z}
	end
	
	return {0, 0, 0}
end)

E_A:RegisterFunction("eye", "e:", "v", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and (Entity:IsPlayer() or Entity:IsNPC()) then
		local Pos = Entity:GetAimVector()
		return {Pos.x, Pos.y, Pos.z}
	end
	
	local Pos = Entity:GetForward()
	return {Pos.x, Pos.y, Pos.z}
end)

E_A:RegisterFunction("eyeAngles", "e:", "a", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() then
		local Ang = Entity:EyeAngles()
		return {Ang.p, Ang.y, Ang.r}
	end
	
	return {0, 0, 0}
end)

E_A:RegisterFunction("aimEntity", "e:", "e", function(self, Value)
	local Entity = Value(self)
	
	if Entity and Entity:IsValid() and Entity:IsPlayer() then
		local Ent = Entity:GetEyeTraceNoCursor().Entity
		if Ent and Ent:IsValid() then return Ent end
	end
	
	return NULL_ENTITY
end)

E_A:RegisterFunction("aimPos", "e:", "v", function(self, Value)
	local Entity = Value(self)
	
	if Entity and Entity:IsValid() and Entity:IsPlayer() then
		return Entity:GetEyeTraceNoCursor().HitPos
	end
	
	return {0, 0, 0}
end)

E_A:RegisterFunction("aimNormal", "e:", "v", function(self, Value)
	local Entity = Value(self)
	
	if Entity and Entity:IsValid() and Entity:IsPlayer() then
		return Entity:GetEyeTraceNoCursor().HitNormal
	end
	
	return {0, 0, 0}
end)

/*==============================================================================================
	Section: Stuffy Stuff
==============================================================================================*/
E_A:RegisterFunction("steamID", "e:", "s", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsPlayer() then
		return Entity:SteamID()
	end
	
	return ""
end)

E_A:RegisterFunction("armor", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and (Entity:IsPlayer() or Entity:IsNPC()) then
		return Entity:Armor()
	end
	
	return 0
end)

E_A:RegisterFunction("ping", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsPlayer() then
		return Entity:Ping()
	end
	
	return 0
end)

E_A:RegisterFunction("timeConnected", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsPlayer() then
		return Entity:TimeConnected()
	end
	
	return 0
end)

E_A:RegisterFunction("vehicle", "e:", "e", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsPlayer() then
		return Entity:GetVehicle()
	end
	
	return NULL_ENTITY
end)

E_A:RegisterFunction("inVehicle", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsPlayer() and Entity:InVehicle() then
		return 1
	end
	
	return 0
end)

E_A:RegisterFunction("inNoclip", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:GetMoveType() ~= MOVETYPE_NOCLIP then
		return 1
	end
	
	return 0
end)

