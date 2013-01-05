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
			if Holo:IsValid() then
                if table.Count( Holo.Clips ) > 0 then 
                    net.Start( "lemon_hologram_remove_clips" )
                        net.WriteUInt( Holo:EntIndex( ), 16 )
                    net.Broadcast( )
                end 
				Count = Count - 1
				Holo:Remove()
			end
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

API.AddHook("ShutDown", function(Entity)
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
local _Rate = CreateConVar( "lemon_holograms_per_tick", "10" )
local _Clips = CreateConVar( "lemon_holograms_max_clips", "5" )
local _Size = CreateConVar( "lemon_holograms_max_size", "50" )
local _Model = CreateConVar( "lemon_holograms_model_any", "0" )

/*==============================================================================================
	Class and Operators
==============================================================================================*/
E_A:RegisterClass("hologram", "h", function( ) return NULL_ENTITY end)

E_A:RegisterException("hologram")

E_A:RegisterOperator("assign", "h", "", function(self, ValueOp, Memory)
	-- Purpose: Assigns a number to memory
	
	self.Memory[Memory] = ValueOp(self)
	self.Click[Memory] = true
end)

E_A:RegisterOperator("variable", "h", "h", function(self, Memory)
	-- Purpose: Assigns a number to memory
	
	return self.Memory[Memory] or NULL_ENTITY
end)

E_A:RegisterOperator("cast", "eh", "e", function(self, Value)
	return Value(self), "e" -- They are entities anyway.
end)

E_A:RegisterOperator("cast", "he", "h", function(self, Value)
	-- Purpose: Assigns a number to memory
	
	local Holo = Value(self)
	if !Holo or !Holo:IsValid() or !Holo.IsHologram then
		self:Throw("hologram", "casted none hologram from entity")
	end
	
	return Holo
end)

E_A:RegisterOperator("is", "h", "n", function(self, Value)
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
	
    Holo.NeedsUpdate = true 
    Queue[Holo] = true
    NeedsSync = true
    
	return Holo
end

local IsValidModel = util.IsValidModel

local function CreateHolo2(self, Value)
	local Holo = CreateHolo(self)
	local ModelS =  Value(self)
	local ValidModel = ModelList[ ModelS ]
	
	if ValidModel then
		Holo:SetModel("models/Holograms/" .. ValidModel .. ".mdl")
		Holo.ModelAny = false
		return Holo
	
	elseif _Model:GetInt() >= 1 and IsValidModel(ModelS) then
		Holo:SetModel( Model(ModelS) )
		Holo.ModelAny = true
		return Holo
	end
	
	Holo:Remove()
	self:Throw("hologram", "unknown hologram model used")
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

E_A:RegisterFunction("isValid", "h:", "n", function(self, Value)
	local Entity = Value(self)
	if Entity and Entity:IsValid() then return 1 end
	return 0
end)

/*==============================================================================================
	Remove
==============================================================================================*/
E_A:SetCost(EA_COST_NORMAL)

E_A:RegisterFunction("remove", "h:", "", function(self, Value)
	local Holo = Value(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		local Ent, Owner = self.Entity, self.Player
		Owners[Owner] = Owners[Owner] - 1
		Holograms[Ent][Holo] = nil
		Holo:Remove()
	end
end)

/*==============================================================================================
	Model
==============================================================================================*/
E_A:RegisterFunction("setModel", "h:s", "", function(self, ValueA, ValueB)
	local Holo = ValueA(self)
	local ModelS =  ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		local ValidModel = ModelList[ ModelS ]
		
		if ValidModel then
			Holo:SetModel("models/Holograms/" .. ValidModel .. ".mdl")
			Holo.ModelAny = false
		elseif _Model:GetInt() >= 1 and IsValidModel(ModelS) then
			Holo:SetModel( Model(ModelS) )
			Holo.ModelAny = true
		else
			self:Throw("hologram", "unknown hologram model used")
		end
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
local function RescaleAny(X, Y, Z, Max, Size)
	TestMax = Max * 12
	
	local TextX = X * Size.x
	if TextX > TestMax or TextX < -TestMax then
		local Val = Size.x * TestMax
		X = math.Clamp(Max / Size.x, -Val, Val)
	end
	
	local TextY = Y * Size.y
	if TextY > TestMax or TextY < -TestMax then
		local Val = Size.y * TestMax
		Y = math.Clamp(Max / Size.y, -Val, Val)
	end
	
	local TextZ = Z * Size.z
	if TextZ > TestMax or TextZ < -TestMax then
		local Val = Size.z * TestMax
		Z = math.Clamp(Max / Size.z, -Val, Val)
	end
	
	return X, Y, Z
end
	
	
E_A:RegisterFunction("scale", "h:v", "", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		local Max = _Size:GetInt()
		local X, Y, Z
		
		if !Holo.ModelAny then
			X = math.Clamp(B[1], -Max, Max)
			Y = math.Clamp(B[2], -Max, Max)
			Z = math.Clamp(B[3], -Max, Max)
		else
			local Size = Holo:OBBMaxs() - Holo:OBBMins()
			X, Y, Z = RescaleAny(B[1], B[2], B[3], Max, Size)
		end
		
		if Holo:SetScale(X, Y, Z) then
			Queue[Holo] = true
			NeedsSync = true
		end
	end
end)

E_A:RegisterFunction("scaleUnits", "h:v", "", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		local Scale = Holo:OBBMaxs() - Holo:OBBMins()
		local Max = _Size:GetInt()
			
			X = math.Clamp(B[1] / Scale.x, -Max, Max)
			Y = math.Clamp(B[2] / Scale.y, -Max, Max)
			Z = math.Clamp(B[3] / Scale.z, -Max, Max)
		
		if Holo.ModelAny then
			X, Y, Z = RescaleAny(X, Y, Z, Max, Scale)
		end
		
		if Holo:SetScale(X, Y, Z) then
			Queue[Holo] = true
			NeedsSync = true
		end
	end
end)

E_A:RegisterFunction("getScale", "h:", "v", function(self, Value)
	local Holo = Value(self)
	
	if Holo and Holo:IsValid() then
		local S = Holo.Scale
		return { S.x, S.y, S.z }
	end
	
	return { 0, 0, 0 }
end)

/*==============================================================================================
	Color
==============================================================================================*/
E_A:RegisterFunction("color", "h:c", "", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
        Holo:SetColor( Color( B[1], B[2], B[3], B[4] ) )
        Holo:SetRenderMode(B[4] == 255 and RENDERMODE_NORMAL or RENDERMODE_TRANSALPHA)
	end
end)

E_A:RegisterFunction("getColor", "h:", "c", function(self, Value)
	local Holo = Value(self)
	
	if Holo and Holo:IsValid() then
		local C = Holo:GetColor( )
        return { C.r, C.g, C.b, C.a }
	end
	
	return { 0, 0, 0, 0 }
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

E_A:RegisterFunction("pushClip", "h:nvv", "", function(self, ValueA, ValueB, ValueC, ValueD)
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
E_A:RegisterFunction("parent", "h:e", "", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		if B and B:IsValid() then
			Holo:SetParent(B)
		end
	end
end)

E_A:RegisterFunction("parent", "h:h", "", function(self, ValueA, ValueB)
	local Holo, B = ValueA(self), ValueB(self)
	
	if Holo and Holo:IsValid() and Holo.Player == self.Player then
		if B and B:IsValid() then
			Holo:SetParent(B)
		end
	end
end)

E_A:RegisterFunction("getParent", "h:", "h", function(self, Value)
	local Holo = Value(self)
	
	if Holo and Holo:IsValid() then
		local Parent = holo:GetParent()
		
		if Parent and Parent:IsValid() and Parent.IsHologram then
			return Parent
		end
		
		return NULL_ENTITY
	end
end)

E_A:RegisterFunction("getParentE", "h:", "e", function(self, Value)
	local Holo = Value(self)
	
	if Holo and Holo:IsValid() then
		local Parent = holo:GetParent()
		
		if Parent and Parent:IsValid() then
			return Parent
		end
		
		return NULL_ENTITY
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
util.AddNetworkString( "lemon_hologram_remove_clips" )

--timer.Create( "Lemon_Holograms", 1, 0, function( )
hook.Add("Tick", "Lemon_Holograms", function()
	if NeedsSync then
		net.Start("lemon_hologram")
		
			for Holo, _ in pairs( Queue ) do
				if Holo and Holo:IsValid() then
					Holo:Sync( false )
				end
			end
			
            net.WriteUInt( 0, 16 )
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
		
        net.WriteUInt( 0, 16 )
	net.Send( Player )
end)
