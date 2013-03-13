/*==============================================================================================
	Expression Advanced: Prop Control.
	Purpose: Props, Lots and lots of Props!
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API

local function RemoveProp(Entity)
	if Entity and Entity:IsValid() then
		pcall(Entity.Remove, Entity)
	end
end
 
MsgN("EA: Prop Core Avalible")

API.NewComponent("Prop Control", true)

/*==============================================================================================
	Section: CVars
==============================================================================================*/
local CV_Enabled = CreateConVar("lemon_prop_enabled", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
local CV_Max = CreateConVar("lemon_prop_max", 10, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
local CV_Rate = CreateConVar("lemon_prop_rate", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY})

/*==============================================================================================
	Section: Prop Tables
==============================================================================================*/
local Props, PlayerCount, PlayerRate = { }, { }, { }

timer.Create("lemon_propcore", 1, 0, function( )
	for K, V in pairs( PlayerRate ) do PlayerRate[K] = 0 end
end)

local function RemoveAll( Entity )
	local Ents = Props[Entity]
	if Ents then
		for K, V in pairs( Ents ) do RemoveProp( V ) end
		Props[Entity] = nil
	end
end

API.AddHook("GateCreate", function(Entity)
	Props[Entity] = { }
end)

API.AddHook("BuildContext", function(Entity)
	Props[Entity] = { }
end)

API.AddHook("GateRemove", function(Entity)
	RemoveAll( Entity )
end)

API.AddHook("ShutDown", function(Entity)
	RemoveAll( Entity )
end)

/*==============================================================================================
	Section: Util
==============================================================================================*/
E_A:RegisterException("propcore")

local function Check_Enabled( Context )
	if !CV_Enabled:GetBool( ) then
		Context:Throw("propcore", "Server has disabled propcore" )
	end
end

local function AddProp( Prop, G, P )
	Prop.Player = P
	
	P:AddCleanup( "props", Prop )
	undo.Create("lemon_spawned_prop")
		undo.AddEntity( Prop )
		undo.SetPlayer( P )
	undo.Finish( ) -- Add to undo que.
	
	Prop:CallOnRemove( "lemon_propcore_remove", function( E )
		if G and G:IsValid( ) and E then
			if Props[G] then Props[G][E] = nil end
		end
		
		if P and P:IsValid( ) then
			local Count = PlayerCount[P] or 1
			if Count < 1 then Count = 1 end
			PlayerCount[P] = Count - 1
		end
	end) -- Register its removal.
	
	if CPPI then
		Prop:CPPISetOwner( P )
	end -- Set Owner in CPPI!
end

local function Spawn( Context, Model, Freeze )
	Check_Enabled( Context )
	
	local G, P = Context.Entity, Context.Player
	local PRate, PCount = PlayerRate[P] or 0, PlayerCount[P] or 0
	
	if PCount >= CV_Max:GetInt( ) then
		Context:Throw("propcore", "Max total props reached (" .. CV_Max:GetInt( ) .. ")." )
	elseif PRate >= CV_Rate:GetInt( ) then
		Context:Throw("propcore", "Max prop spawn rate reached (" .. CV_Rate:GetInt( ) .. ")." )
	elseif !util.IsValidModel( Model ) or !util.IsValidProp( Model ) then
		Context:Throw("propcore", "Invalid model for prop spawn." )
	end
	
	local Prop = MakeProp( P, G:GetPos(), G:GetAngles(), Model, {}, {} )
	if !Prop or !Prop:IsValid( ) then
		Context:Throw("propcore", "Unable to spawn prop." )
	end
	
	AddProp( Prop, G, P )
	Prop:Activate()
	
	local Phys = Prop:GetPhysicsObject()
	if Phys and Phys:IsValid( ) then
		if Freeze > 0 then Phys:EnableMotion( false ) end
		Phys:Wake()
	end
	
	Props[ G ][ Prop ] = Prop
	PlayerRate[ P ] = PRate + 1
	PlayerCount[ P ] = PCount + 1
	
	return Prop
end

local function PropValid( self, Entity )
	return Entity and Entity:IsValid( ) and E_A.IsOwner( self.Player, Entity)
end

/*==============================================================================================
	Section: info funcs
==============================================================================================*/
E_A:RegisterFunction("propcore","","n",
	function( self )
		return CV_Enabled:GetInt( )
	end)

E_A:RegisterFunction("propcoreInfo","","t",
	function( self )
		local Table = E_A.NewTable( )
		Table:Set("Enabled", "n", CV_Enabled:GetInt( ))
		Table:Set("MaxProps", "n", CV_Max:GetInt( ))
		Table:Set("MaxRate", "n", CV_Rate:GetInt( ))
		Table:Set("CurProps", "n", PlayerCount[ self.Player ] or 0)
		Table:Set("CurRate", "n", PlayerRate[ self.Player ] or 0)
		return Table
	end)

E_A:RegisterFunction("propcoreProps","","t",
	function( self )
		return E_A.NewResultTable( Props[self.Entity] or { } , "e")
	end)
	
/*==============================================================================================
	Section: Spawn funcs
==============================================================================================*/
E_A:RegisterFunction("spawn","s","e",
	function( self, A )
		return Spawn( self, A( self ), 1 )
	end)

E_A:RegisterFunction("spawn","sn","e",
	function( self, A, B )
		return Spawn( self, A( self ), B( self ) )
	end)

E_A:RegisterFunction("remove","e:","",
	function( self, A )
		local Ent = A( self )
		
		Check_Enabled( self )
		if PropValid( self, Ent ) then
			RemoveProp( Ent )
		end
	end)
	
/*==============================================================================================
	Section: Pos and Ang
==============================================================================================*/
E_A:RegisterFunction("setPos","e:v","",
	function( self, A, B )
		Check_Enabled( self )
		
		local Ent, Pos = A( self ), B( self )
		if PropValid( self, Ent ) then
			Ent:SetPos( Vector( Pos[1], Pos[2], Pos[3] ) )
		end
	end)

E_A:RegisterFunction("setAng","e:a","",
	function( self, A, B )
		Check_Enabled( self )
		
		local Ent, Ang = A( self ), B( self )
		if PropValid( self, Ent ) then
			Ent:SetAngles( Angle( Ang[1], Ang[2], Ang[3] ) )
		end
	end)
	
/*==============================================================================================
	Section: Parent
==============================================================================================*/
local function Parent( self, A, B )
	Check_Enabled( self )
	
	local Ent, Par = A( self ), B( self )
	if PropValid( self, Ent ) and PropValid( self, Par )  then
		if !Ent:IsVehicle() and !Par:IsVehicle() then
			Ent:SetParent( Par )
		end
	end
end
	
E_A:RegisterFunction("parent","e:e","", Parent)
E_A:RegisterFunction("parent","e:h","", Parent)

E_A:RegisterFunction("unparent","e:","",
	function(self, Value)
		Check_Enabled( self )
		
		local Ent = Value( self )
		if PropValid( self, Ent ) then
			Ent:SetParent( nil )
		end
	end)
	
/*==============================================================================================
	Section: Freeze
==============================================================================================*/
E_A:RegisterFunction("freeze","e:n","",
	function( self, A, B )
		Check_Enabled( self )
		
		local Ent, Freeze = A( self ), B( self )
		if PropValid( self, Ent ) then
			local Phys = Ent:GetPhysicsObject()
			Phys:EnableMotion( Freeze == 0 )
			Phys:Wake( )
			
			if !Phys:IsMoveable() then
				Phys:EnableMotion( true  )
				Phys:EnableMotion( false)
			end
		end
	end)

/*==============================================================================================
	Section: Solidnes
==============================================================================================*/
E_A:RegisterFunction("setNotSolid","e:n","",
	function( self, A, B )
		Check_Enabled( self )
		
		local Ent, Solid = A( self ), B( self )
		if PropValid( self, Ent ) then
			Ent:SetNotSolid( Solid > 0 )
		end
	end)
	
/*==============================================================================================
	Section: Gravity
==============================================================================================*/
E_A:RegisterFunction("enableGravity","e:n","",
	function( self, A, B )
		Check_Enabled( self )
		
		local Ent, Gravity = A( self ), B( self )
		if PropValid( self, Ent ) then
			local Phys = Ent:GetPhysicsObject()
			Phys:EnableGravity( Gravity > 0 )
			Phys:Wake( )
			
			if !Phys:IsMoveable() then
				Phys:EnableMotion( true  )
				Phys:EnableMotion( false)
			end
		end
	end)