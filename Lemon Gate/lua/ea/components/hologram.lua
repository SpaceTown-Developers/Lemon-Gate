/*==============================================================================================
	Expression Advanced: Holograms.
	Purpose: Based of E2s by McLovin.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API

local Count = table.Count
local NULL_ENTITY = Entity(-1)

E_A.API.NewComponent("Holograms", true)

E_A.Holograms = { }
local Holograms = E_A.Holograms

E_A.HologramOwners = { }
local Owners = E_A.HologramOwners
local Recent = { }

local function RemoveHolos(Entity)
	local Holos = Holograms[Entity]
	
	if Holos then
		local Count = Owners[Entity.Player] or 0
		
		for _, Holo in pairs( Holograms[Entity] ) do
			Count = Count - 1
			Holo:Remove()
		end
		
		if Count < 0 then Count = 0 end -- Should never happen!
		
		Owners[Entity.Player] = Count
		Holograms[Entity] = { }
	end
end

local Queue, NeedsSync = { }, false

function API.QueueHologram( Entity )
	if Entity and Entity:IsValid() and Entity.IsHologram then
		Queue[Entity] = true
		NeedsSync = true
	end
end

API.AddHook("GateCreate", function(Entity)
	Holograms[Entity] = {}
end)

API.AddHook("BuildContext", function(Entity)
	RemoveHolos(Entity)
end)

API.AddHook("GateRemove", function(Entity)
	RemoveHolos(Entity)
end)

/*==============================================================================================
	Models
==============================================================================================*/
local ModelList = {
	["cone"]              = "cone",
	["cube"]              = "cube",
	["cylinder"]          = "cylinder",
	["hq_cone"]           = "hq_cone",
	["hq_cylinder"]       = "hq_cylinder",
	["hq_dome"]           = "hq_dome",
	["hq_hdome"]          = "hq_hdome",
	["hq_hdome_thick"]    = "hq_hdome_thick",
	["hq_hdome_thin"]     = "hq_hdome_thin",
	["hq_icosphere"]      = "hq_icosphere",
	["hq_sphere"]         = "hq_sphere",
	["hq_torus"]          = "hq_torus",
	["hq_torus_thick"]    = "hq_torus_thick",
	["hq_torus_thin"]     = "hq_torus_thin",
	["hq_torus_oldsize"]  = "hq_torus_oldsize",
	["hq_tube"]           = "hq_tube",
	["hq_tube_thick"]     = "hq_tube_thick",
	["hq_tube_thin"]      = "hq_tube_thin",
	["hq_stube"]           = "hq_stube",
	["hq_stube_thick"]     = "hq_stube_thick",
	["hq_stube_thin"]      = "hq_stube_thin",
	["icosphere"]         = "icosphere",
	["icosphere2"]        = "icosphere2",
	["icosphere3"]        = "icosphere3",
	["plane"]             = "plane",
	["prism"]             = "prism",
	["pyramid"]           = "pyramid",
	["sphere"]            = "sphere",
	["sphere2"]           = "sphere2",
	["sphere3"]           = "sphere3",
	["tetra"]             = "tetra",
	["torus"]             = "torus",
	["torus2"]            = "torus2",
	["torus3"]            = "torus3",

	["hq_rcube"]          = "hq_rcube",
	["hq_rcube_thick"]    = "hq_rcube_thick",
	["hq_rcube_thin"]     = "hq_rcube_thin",
	["hq_rcylinder"]      = "hq_rcylinder",
	["hq_rcylinder_thick"]= "hq_rcylinder_thick",
	["hq_rcylinder_thin"] = "hq_rcylinder_thin",
	["hq_cubinder"]       = "hq_cubinder",
	["hexagon"]           = "hexagon",
	["octagon"]           = "octagon",
	["right_prism"]       = "right_prism",

	// Removed models with their replacements

	["dome"]             = "hq_dome",
	["dome2"]            = "hq_hdome",
	["hqcone"]           = "hq_cone",
	["hqcylinder"]       = "hq_cylinder",
	["hqcylinder2"]      = "hq_cylinder",
	["hqicosphere"]      = "hq_icosphere",
	["hqicosphere2"]     = "hq_icosphere",
	["hqsphere"]         = "hq_sphere",
	["hqsphere2"]        = "hq_sphere",
	["hqtorus"]          = "hq_torus_oldsize",
	["hqtorus2"]         = "hq_torus_oldsize",

	// HQ models with their short names

	["hqhdome"]          = "hq_hdome",
	["hqhdome2"]         = "hq_hdome_thin",
	["hqhdome3"]         = "hq_hdome_thick",
	["hqtorus3"]         = "hq_torus_thick",
	["hqtube"]           = "hq_tube",
	["hqtube2"]          = "hq_tube_thin",
	["hqtube3"]          = "hq_tube_thick",
	["hqstube"]          = "hq_stube",
	["hqstube2"]         = "hq_stube_thin",
	["hqstube3"]         = "hq_stube_thick",
	["hqrcube"]          = "hq_rcube",
	["hqrcube2"]         = "hq_rcube_thick",
	["hqrcube3"]         = "hq_rcube_thin",
	["hqrcylinder"]      = "hq_rcylinder",
	["hqrcylinder2"]     = "hq_rcylinder_thin",
	["hqrcylinder3"]     = "hq_rcylinder_thick",
	["hqcubinder"]       = "hq_cubinder"
}

API.CallHook("HologramModels", ModelList)

for _, Model in pairs( ModelList ) do
	util.PrecacheModel( "models/Holograms/" .. Model .. ".mdl" )
end

/*==============================================================================================
	Convars
==============================================================================================*/
local _Max = CreateConVar( "lemon_holograms_max", "128" )
local _Rate = CreateConVar( "lemon_holograms_per_second", "10" )
local _Clips = CreateConVar( "lemon_holograms_max_clips", "5" )
local _Size = CreateConVar( "lemon_holograms_max_size", "50" )

/*==============================================================================================
	Class and Operators
==============================================================================================*/
E_A:RegisterClass("hologram", "h", function( ) return NULL_ENTITY end)

E_A:RegisterException("hologram")

E_A:RegisterOperator("assign", "h", "", function(self, ValueOp, Memory)
	-- Purpose: Assigns a number to memory
	
	local Value, Type = ValueOp(self)
	self.Memory[Memory] = Value
	
	self.Click[Memory] = true
end)

E_A:RegisterOperator("variable", "h", "h", function(self, Memory)
	-- Purpose: Assigns a number to memory
	
	return self.Memory[Memory]
end)

E_A:RegisterOperator("cast", "eh", "e", function(self, Value)
	-- Purpose: Assigns a number to memory
	
	return Value(self) -- They are entities anyway.
end)

E_A:RegisterOperator("cast", "he", "h", function(self, Value)
	-- Purpose: Assigns a number to memory
	
	local Holo = Value(self)
	if !Holo or !Holo:IsValid() or !Holo.IsHologram then
		self:Throw("hologram", "casted none hologram from entity")
	end
	
	return Holo
end)

E_A:RegisterOperator("is", "e", "n", function(self, Value)
	-- Purpose: Is Valid
	
	local Holo = Value(self)
	return (Holo and Holo:IsValid()) and 1 or 0
end)

E_A:RegisterOperator("negeq", "hh", "n", function(self, ValueA, ValueB)
	-- Purpose: != Comparison Operator
	
	return (ValueA(self) == ValueB(self)) and 0 or 1
end)

E_A:RegisterOperator("eq", "hh", "n", function(self, ValueA, ValueB)
	-- Purpose: == Comparison Operator
	
	return (ValueA(self) == ValueB(self)) and 1 or 0
end)

/*==============================================================================================
	Creator Functions
==============================================================================================*/
local function CreateHolo(self)
	local Ent, Owner = self.Entity, self.Player
	
	local Burst = Recent[Ent]
	if !Burst then
		Burst = 0
	elseif Burst > _Rate:GetInt( ) then
		self:Throw("hologram", "too many holograms made at once")
	end
	
	local Count = Owners[Owner]
	
	if !Count then
		Count = 0
	elseif Count >= _Max:GetInt( ) then
		self:Throw("hologram", "hologram limit reached")
	end
	
	local Holo = ents.Create( "lemon_holo" )
	if !Holo or !Holo:IsValid() then
		self:Throw("hologram", "unable to create hologram")
	end
	
	Holo.Player = Owner
	
	Recent[Ent] = Burst + 1
	Owners[Owner] = Count + 1
	Holograms[Ent][Holo] = Holo
	
	Holo:SetModel("models/Holograms/sphere.mdl")
	Holo:SetPos( Ent:GetPos() )
	Holo:Spawn()
	Holo:Activate()
	
	return Holo
end

local function CreateHolo2(self, Value)
	local Holo = CreateHolo(self)
	local Model = ModelList[ Value(self) ]
	
	if !Model then
		Holo:Remove()
		self:Throw("hologram", "unknown hologram model used")
	end
	
	Holo:SetModel("models/Holograms/" .. Model .. ".mdl")
	return Holo
end

/***************************************************************************/

E_A:SetCost(EA_COST_EXPENSIVE)

E_A:RegisterFunction("hologram", "", "h", CreateHolo)

E_A:RegisterFunction("hologram", "s", "h", CreateHolo2)

E_A:RegisterFunction("hologram", "sv", "h", function(self, ValueA, ValueB)
	local Holo = CreateHolo2(self, ValueA)
	local B = ValueB(self)
	Holo:SetPos( Vector( B[1], B[2], B[3] ) )
	return Holo
end)

/*==============================================================================================
	Remove
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("remove", "h:", "", function(self, Value)
	local Holo = ValueA(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		local Ent, Owner = self.Entity, self.Player
		Owners[Owner][Holo] = nil
		Holograms[Ent][Holo] = nil
		Holo:Remove()
	end
end)

/*==============================================================================================
	Model
==============================================================================================*/
E_A:RegisterFunction("setModel", "h:s", "", function(self, ValueA, ValueB)
	local Holo = ValueA(self)
	local Model = ModelList[ ValueB(self) ]
	
	if !Model then
		self:Throw("hologram", "unknown hologram model used")
	end
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		Holo:SetModel("models/Holograms" .. Model .. ".mdl")
	end
end)

/*==============================================================================================
	Position and angles
==============================================================================================*/
E_A:RegisterFunction("setPos", "h:v", "", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		Holo:SetPos( Vector( B[1], B[2], B[3] ) )
	end
end)

E_A:RegisterFunction("setAng", "h:a", "", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		Holo:SetAngles(Angle( B[1], B[2], B[3] ) )
	end
end)

E_A:RegisterFunction("pos", "h:", "v", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return {0, 0, 0} end
	
	local Pos = Entity:GetPos()
	
	return {Pos.x, Pos.y, Pos.z}
end)

E_A:RegisterFunction("ang", "h:", "a", function(self, Value)
	local Entity = Value(self)
	if !Entity or !Entity:IsValid() then return {0, 0, 0} end
	
	local Ang = Entity:GetAngles()
	
	return {Ang.p, Ang.y, Ang.r}
end)

/*==============================================================================================
	Scale
==============================================================================================*/
E_A:RegisterFunction("scale", "h:v", "", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		local Max = _Size:GetInt()
		
		local X = math.Clamp(-Max, Max, B[1])
		local Y = math.Clamp(-Max, Max, B[2])
		local Z = math.Clamp(-Max, Max, B[3])
		
		if Holo:SetScale(X, Y, Z) then
			Queue[Holo] = true
			NeedsSync = true
		end
	end
end)

E_A:RegisterFunction("scaleUnits", "h:v", "", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		local Size = Holo:OBBMaxs() - Holo:OBBMins()
		local Max = _Size:GetInt()
		
		local X = math.Clamp(-Max, Max, B[1] * Size.x)
		local Y = math.Clamp(-Max, Max, B[2] * Size.y)
		local Z = math.Clamp(-Max, Max, B[3] * Size.z)
		
		if Holo:SetScale(X, Y, Z) then
			Queue[Holo] = true
			NeedsSync = true
		end
	end
end)

/*==============================================================================================
	Color
==============================================================================================*/
E_A:RegisterFunction("color", "h:", "v", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		Holo:SetColor(Color( B[1], B[2], B[3] ) )
	end
end)

E_A:RegisterFunction("color", "h:", "vn", function(self, ValueA, ValueB, ValueC)
	local Holo, B, C = ValueA(self), ValueB(self), ValueC(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		Holo:SetColor(Color( B[1], B[2], B[3], C ) )
	end
end)

E_A:RegisterFunction("alpha", "h:", "n", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		Holo:SetAlpha(B)
	end
end)

/*==============================================================================================
	Rendering
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("shading", "h:n", "", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		if Holo:SetShading(B >= 1) then
			Queue[Holo] = true
			NeedsSync = true
		end
	end
end)

E_A:RegisterFunction("visible", "h:n", "", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		if Holo:SetVisible(B >= 1) then
			Queue[Holo] = true
			NeedsSync = true
		end
	end
end)

/*==============================================================================================
	Clipping
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("pushClip", "h:nvv", "", function(self, ValueA, ValueB, CalueC, ValueD)
	local Holo, B, C, D = ValueA(self), ValueB(self), ValueC(self), ValueD(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		
		if !Holo:ClipCount( B, _Clips:GetInt() ) then
			self:Throw("hologram", "max clip count reached")
		end
		
		local E, F = Vector( C[1], C[2], C[3] ), Vector( D[1], D[2], D[3] )
		if Holo:PushClip( B, E, F ) then
			Queue[Holo] = true
			NeedsSync = true
		end
	end
end)

E_A:RegisterFunction("removeClip", "h:n", "", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		if Holo:RemoveClip( B ) then
			Queue[Holo] = true
			NeedsSync = true
		end
	end
end)

E_A:RegisterFunction("enableClip", "h:nn", "", function(self, ValueA, ValueB, ValueC)
	local Holo, B, C = ValueA(self), ValueB(self), ValueC(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		if Holo:EnableClip( B, C >= 1 ) then
			Queue[Holo] = true
			NeedsSync = true
		end
	end
end)

/*==============================================================================================
	Parent
==============================================================================================*/
E_A:RegisterFunction("setParent", "h:e", "", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		if B and B:IsValid() then
			Holo:SetParent(B)
		end
	end
end)

E_A:RegisterFunction("setParent", "h:h", "", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		if B and B:IsValid() then
			Holo:SetParent(B)
		end
	end
end)

E_A:RegisterFunction("getParent", "h:", "e", function(self, Value)
	local Holo = Value(self)
	
	if Holo and Holo:IsValid() then
		return holo:GetParent()
	end
end)

/*==============================================================================================
	Entity
==============================================================================================*/
E_A:RegisterFunction("isHologram", "e:", "", function(self, Value)
	local Holo = Value(self)
	
	if Holo and Holo:IsValid() then
		return Holo.IsHologram and 1 or 0
	end
end)

/*==============================================================================================
	Util
==============================================================================================*/

E_A:SetCost(EA_COST_CHEAP)

E_A:RegisterFunction("maxHolograms", "", "n", function(self)
	return _Max:GetInt( )
end)

E_A:RegisterFunction("maxHologramClips", "", "n", function(self)
	return _Clips:GetInt( )
end)

E_A:SetCost(EA_COST_EXPENSIVE)

E_A:RegisterFunction("holograms", "", "t", function(self)
	return E_A.NewResultTable(Holograms[self.Entity], "h")
end)

/*==============================================================================================
	Sync
==============================================================================================*/
local net = net
util.AddNetworkString( "lemon_hologram" )

timer.Create( "Lemon_Holograms", 1, 0, function( )
	
	if NeedsSync then
		net.Start("lemon_hologram")
		
			for Holo, _ in pairs( Queue ) do
				if Holo and Holo:IsValid() then
					Holo:Sync( false )
				end
			end
			
		net.Broadcast()
	end
	
	Queue, NeedsSync = { }, false
	Recent = {}
end)

hook.Add( "PlayerInitialSpawn", "Lemon_Holograms", function( Player )
	net.Start("lemon_hologram")
		
		for Gate, Holos in pairs( Holograms ) do
			for _, Holo in pairs( Holos ) do
				if Holo and Holo:IsValid() and !Queue[Holo] then
					Holo:Sync( true ) -- We wont force sync whats in the queue!
				end
			end
		end
		
	net.Send( Player )
end)