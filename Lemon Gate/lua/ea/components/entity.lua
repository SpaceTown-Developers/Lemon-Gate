/*==============================================================================================
	Expression Advanced: Entitys.
	Purpose: Entitys are stuffs.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate

local GetLongType = E_A.GetLongType

/*==============================================================================================
	Class & WireMod
==============================================================================================*/
E_A:RegisterClass("entity", "e", function() return Entity(-1) end)

local function Input(self, Memory, Value)
	-- Purpose: Used to set Memory via a wired input.
	
	self.Memory[Memory] = Value
end

local function Output(self, Memory)
	-- Purpose: Used to get Memory for a wired output.
	
	return self.Memory[Memory]
end

E_A:WireModClass("entity", "ENTITY", Input, Output)

/*==============================================================================================
	Var Operators
==============================================================================================*/
E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterOperator("assign", "e", "", function(self, ValueOp, Memory)
	-- Purpose: Assigns a number to memory
	
	local Value, Type = ValueOp(self)
	if Type != "e" then self:Error("Attempt to assign %s to entity", GetLongType(Type)) end
	
	self.Memory[Memory] = Value
	
	self.Click[Memory] = true
end)

E_A:RegisterOperator("variabel", "e", "e", function(self, Memory)
	-- Purpose: Assigns a number to memory
	
	return self.Memory[Memory]
end)

/*==============================================================================================
	Section: Comparason Operators
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)


E_A:RegisterOperator("negeq", "ee", "n", function(self, ValueA, ValueB)
	-- Purpose: != Comparason Operator
	
	return (ValueA(self) == ValueB(self)) and 0 or 1
end)

E_A:RegisterOperator("eq", "ee", "n", function(self, ValueA, ValueB)
	-- Purpose: == Comparason Operator
	
	return (ValueA(self) == ValueB(self)) and 1 or 0
end)

/*==============================================================================================
	Section: Conditonal Operators
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterOperator("is", "e", "n", function(self, Value)
	-- Purpose: Is Valid
	
	local Entity = Value(self)
	return (Entity and Entity:IsValid()) and 1 or 0
end)

E_A:RegisterOperator("or", "ee", "e", function(self, ValueA, ValueB)
	-- Purpose: | Conditonal Operator
	
	local Entity = ValueA(self)
	return (Entity and Entity:IsValid()) and Entity or ValueB(self)
end)

E_A:RegisterOperator("and", "ee", "n", function(self, ValueA, ValueB)
	-- Purpose: & Conditonal Operator
	
	local A, B = ValueA(self), ValueB(self)
	return (A and B and A:IsValid() and B:IsValid()) and 1 or 0
end)

/*==============================================================================================
	Section: Casting and converting
==============================================================================================*/
local tostring = tostring

E_A:RegisterFunction("toString", "e", "s", function(self, Value)
	return tostring( Value(self) )
end)

E_A:RegisterOperator("cast", "se", "s", function(self, Value, ConvertType)
	return tostring( Value(self) )
end)

/*==============================================================================================
	Section: Entity is somthing
==============================================================================================*/
E_A:RegisterFunction("isNPC", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsNPC() then return 1 end
	return 0
end)

E_A:RegisterFunction("isWorld", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsWorld() then return 1 end
	return 0
end)

E_A:RegisterFunction("isOnGround", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsOnGround() then return 1 end
	return 0
end)

E_A:RegisterFunction("isUnderWater", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:WaterLevel() > 0 then return 1 end
	return 0
end)

E_A:RegisterFunction("isValid", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() then return 1 end
	return 0
end)

/*==============================================================================================
	Section: Entity Info
==============================================================================================*/
E_A:RegisterFunction("class", "e:", "s", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return "" end
	
	return Entity:GetClass()
end)

E_A:RegisterFunction("model", "e:", "s", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return "" end
	
	return Entity:GetModel()
end)

E_A:RegisterFunction("name", "e:", "s", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return "" end
	
	return Entity:GetName() or Entity:Name()
end)

E_A:RegisterFunction("health", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return 0 end
	
	return Entity:Health()
end)

E_A:RegisterFunction("radius", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return 0 end
	
	return Entity:BoundingRadius()
end)

/*==============================================================================================
	Section: Vehicle Stuff
==============================================================================================*/
E_A:RegisterFunction("isVehicle", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() and Entity:IsVehicle() then return 1 end
	return 0
end)

E_A:RegisterFunction("driver", "e:", "e", function(self, Value)
	local entity = Value(self)
	if entity and entity:IsValid() and entity:IsVehicle() then return entity:GetDriver() end
	return Entity(0)
end)

E_A:RegisterFunction("passenger", "e:", "e", function(self, Value)
	local entity = Value(self)
	if entity and entity:IsValid() and entity:IsVehicle() then return entity:GetPassenger() end
	return Entity(0)
end)

/*==============================================================================================
	Section: Mass
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

E_A:RegisterFunction("mass", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return 0 end
	
	local Phys = Entity:GetPhysicsObject()
	if !Phys or !Phys:IsValid() then return 0 end
	
	return Phys:GetMass()
end)

E_A:RegisterFunction("massCenterWorld", "e:", "v", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return {0, 0, 0} end
	
	local Phys = Entity:GetPhysicsObject()
	if !Phys or !Phys:IsValid() then return {0, 0, 0} end
	
	local V = E:LocalToWorld(Phys:GetMassCenter())
	return {V.x, V.y, V.z}
end)

E_A:RegisterFunction("massCenter", "e:", "v", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return {0, 0, 0} end
	
	local Phys = Entity:GetPhysicsObject()
	if !Phys or !Phys:IsValid() then return {0, 0, 0} end
	
	local V = Phys:GetMassCenter()
	return {V.x, V.y, V.z}
end)

/*==============================================================================================
	Section: OBB Box
==============================================================================================*/
E_A:RegisterFunction("boxSize", "e:", "v", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return {0, 0, 0} end
	
	local V = Entity:OBBMaxs() - Entity:OBBMins()
	return {V.x, V.y, V.z}
end)

E_A:RegisterFunction("boxCenter", "e:", "v", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return {0, 0, 0} end
	
	local V = Entity:OBBCenter()
	return {V.x, V.y, V.z}
end)

E_A:RegisterFunction("boxCenterWorld", "e:", "v", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return {0, 0, 0} end
	
	local V = Entity:LocalToWorld(Entity:OBBCenter())
	return {V.x, V.y, V.z}
end)

E_A:RegisterFunction("boxMax", "e:", "v", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return {0, 0, 0} end
	
	local V = Entity:OBBMaxs()
	return {V.x, V.y, V.z}
end)

E_A:RegisterFunction("boxMin", "e:", "v", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return {0, 0, 0} end
	
	local V = Entity:OBBMins()
	return {V.x, V.y, V.z}
end)

/******************************************************************************/

E_A:RegisterFunction("aabbMin", "e:", "v", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return {0, 0, 0} end
	
	local Phys = Entity:GetPhysicsObject()
	if !Phys or !Phys:IsValid() then return {0, 0, 0} end
	
	local V = Phys:GetAABB()
	return {V.x, V.y, V.z}
end)

E_A:RegisterFunction("aabbMax", "e:", "v", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return {0, 0, 0} end
	
	local Phys = Entity:GetPhysicsObject()
	if !Phys or !Phys:IsValid() then return {0, 0, 0} end
	
	local _, V Phys:GetAABB()
	return {V.x, V.y, V.z}
end)

/*==============================================================================================
	Section: Force
==============================================================================================*/
E_A:SetCost(EA_COST_EXSPENSIVE)

E_A:RegisterFunction("applyForce", "e:v", "", function(self, ValueA, ValueB)
	local Entity, V = ValueA(self), ValueB(self)
	
	if !Entity or !Entity:IsValid() then return end
	
	if !E_A.IsOwner(self.Player, Entity) then return  end
	
	local Phys = Entity:GetPhysicsObject()
	
	if Phys then
		Phys:ApplyForceCenter(Vector(V[1], V[2], V[3]))
	end
end)

E_A:RegisterFunction("applyOffsetForce", "e:vv", "", function(self, ValueA, ValueB, ValueC)
	local Entity, B, C = ValueA(self), ValueB(self), ValueC(self)
	
	if !Entity or !Entity:IsValid() then return end
	
	if !E_A.IsOwner(self.Player, Entity) then return end
	
	local Phys = Entity:GetPhysicsObject()
	
	if Phys then
		Phys:ApplyForceOffset(Vector(B[1], B[2], B[3]), Vector(C[1], C[2], C[3]))
	end
end)

E_A:RegisterFunction("applyAngForce", "e:a", "", function(self, ValueA, ValueB)
	local Entity, A = ValueA(self), ValueB(self)
	
	if !Entity or !Entity:IsValid() then return end
	
	if !E_A.IsOwner(self.Player, Entity) then return  end
	
	local Phys = Entity:GetPhysicsObject()
	
	if Phys then
	
		-- assign vectors
		local Up = Entity:GetUp()
		local Left = Entity:GetRight() * -1
		local Forward = Entity:GetForward()

		-- apply pitch force
		if A[1] ~= 0 then
			local Pitch = Up * (A[1] * 0.5)
			Phys:ApplyForceOffset( Forward, Pitch )
			Phys:ApplyForceOffset( Forward * -1, Pitch * -1 )
		end

		-- apply yaw force
		if A[2] ~= 0 then
			local Yaw = Forward * (A[2] * 0.5)
			Phys:ApplyForceOffset( Left, Yaw )
			Phys:ApplyForceOffset( Left * -1, Yaw * -1 )
		end

		-- apply roll force
		if A[3] ~= 0 then
			local Roll = Left * (A[3] * 0.5)
			Phys:ApplyForceOffset( Up, Roll )
			Phys:ApplyForceOffset( Up * -1, Roll * -1 )
		end
	end
end)

/*==============================================================================================
	Section: Vectors
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("pos", "e:", "v", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return {0, 0, 0} end
	
	local Pos = Entity:GetPos()
	
	return {Pos.x, Pos,y, Pos.z}
end)

/*==============================================================================================
	Section: Angles
==============================================================================================*/
E_A:RegisterFunction("ang", "e:", "a", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return {0, 0, 0} end
	
	local Ang = Entity:GetAngles()
	
	return {Ang.p, Ang,y, Ang.r}
end)

/*==============================================================================================
	Section: Constraints
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

local constraint = constraint
local HasConstraints = constraint.HasConstraints
local GetAllConstrainedEntities = constraint.GetAllConstrainedEntities
local ConstraintTable = constraint.GetTable
local FindConstraint = constraint.FindConstraint

E_A:RegisterFunction("hasConstraints", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return 0 end
	
	return #ConstraintTable(Entity)
end)

E_A:RegisterFunction("isConstrained", "e:", "n", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() or !HasConstraints(Entity) then return 0 end
	
	return 1
end)

E_A:RegisterFunction("isWeldedTo", "e:", "e", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() or !HasConstraints(Entity) then return Entity(-1) end
	
	local Constraint = FindConstraint(Entity, "Weld")
	
	if !Constraint then
		return Entity(-1)
	
	elseif Constraint.Ent1 == Entity then
		return Constraint.Ent2
	else
		return Constraint.Ent1 or Entity(-1)
	end
end)


E_A:SetCost(EA_COST_EXSPENSIVE)

E_A:RegisterFunction("getConstraints", "e:", "t", function(self, Value)
	local Entity, Table = Value(self), E_A.NewTable()
	if !Entity or !Entity:IsValid() or !HasConstraints(Entity) then return Table end
	
	for _, Constraint in pairs( GetAllConstrainedEntities(Entity) ) do
		if Constraint and Constraint:IsValid() and Constraint ~= Entity then
			Table:Insert(nil, "e", Constraint)
		end
	end
	
	return Table
end)

/*==============================================================================================
	Section: Finding
==============================================================================================*/
local Players = player.GetAll
local FindByClass = ents.FindByClass
local FindInSphere = ents.FindInSphere
local FindInBox = ents.FindInBox
local FindInCone = ents.FindInCone
local FindByModel = ents.FindByModel

local BanedEntitys = { -- E2 filters these.
	["info_player_allies"] = true,
	["info_player_axis"] = true,
	["info_player_combine"] = true,
	["info_player_counterterrorist"] = true,
	["info_player_deathmatch"] = true,
	["info_player_logo"] = true,
	["info_player_rebel"] = true,
	["info_player_start"] = true,
	["info_player_terrorist"] = true,
	["info_player_blu"] = true,
	["info_player_red"] = true,
	["prop_dynamic"] = true,
	["physgun_beam"] = true,
	["player_manager"] = true,
	["predicted_viewmodel"] = true,
	["gmod_ghost"] = true,
}
	
local function FilterResults(Entitys)
	local Table = E_A.NewTable()
	
	for _, Entity in pairs( Entitys ) do
		if Entity:IsValid() and !BanedEntitys[  Entity:GetClass() ] then
			Table:Insert(nil, "e", Entity)
		end
	end
	
	return Table
end


E_A:RegisterFunction("getPlayers", "", "t", function(self)
	return E_A.NewResultTable(Players(), "e")
end)

E_A:RegisterFunction("findByClass", "s", "t", function(self, Value)
	V = Value(self)
	Ents = FindByClass(V)
	
	return FilterResults(Ents)
end)

E_A:RegisterFunction("findByModel", "s", "t", function(self, Value)
	V = Value(self)
	Ents = FindByModel(V)
	
	return FilterResults(Ents)
end)

E_A:RegisterFunction("findInSphere", "vn", "t", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	local V = Vector(A[1], A[2], A[3])
	
	local Ents = FindInSphere(V, B)
	return FilterResults(Ents)
end)

E_A:RegisterFunction("findInBox", "vv", "t", function(self, ValueA, ValueB)
	local A, B = ValueA(self), ValueB(self)
	local VA, VB = Vector(A[1], A[2], A[3]), Vector(B[1], B[2], B[3])
	
	local Ents = FindInBox(VA, VB)
	return FilterResults(Ents)
end)

E_A:RegisterFunction("findInCone", "vvna", "t", function(self, ValueA, ValueB, ValueC, ValueD)
	local A, B, C, D = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	local VA, VB = Vector(A[1], A[2], A[3]), Vector(B[1], B[2], B[3])
	local AD = Angle(D[1], D[2], D[3])
	
	local Ents = FindInCone(VA, VB, C, AD)
	return FilterResults(Ents)
end)

/*==============================================================================================
	Section: Casting and converting
==============================================================================================*/
E_A:SetCost(EA_COST_ABNORMAL)

local tostring = tostring

E_A:RegisterFunction("toString", "e", "s", function(self, Value)
	return tostring(Value(self))
end)

E_A:RegisterFunction("toString", "e:", "s", function(self, Value)
	return tostring(Value(self))
end)

E_A:RegisterOperator("cast", "se", "s", function(self, Value, ConvertType)
	return tostring(Value(self))
end)
