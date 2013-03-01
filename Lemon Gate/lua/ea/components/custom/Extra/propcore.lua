/*==============================================================================================
	Expression Advanced: Prop Control.
	Purpose: Props, Lots and lots of Props!
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API

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
local Props, Time, Players = { }, { }, { }

timer.Create("lemon_propcore", 1, 0, function( )
	for K, V in pairs( Players ) do
		Players[K] = 0
	end
end)

local function RemoveAll( Entity )
	local Ents = Props[Entity]
	if Ents then
		for K, V in pairs( Ents ) do V:Remove( ) end
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
	P.Player = P
	
	P:AddCleanup( "props", Prop )
	undo.Create("lemon_spawned_prop")
		undo.AddEntity( Prop )
		undo.SetPlayer( P )
	undo.Finish( ) -- Add to undo que.
	
	Prop:CallOnRemove( "lemon_propcore_remove", function( Prop )
		if G and G:IsValid( ) then
			Props[ G ][ Prop ] = nil	
		end
		
		if P and P:IsValid( ) then
			Players[P] = (Players[P] or 1) - 1
		end
	end) -- Register its removal.
	
	if CPPI then
		Prop:CPPISetOwner( P )
	end -- Set Owner in CPPI!
end

local function Spawn( Context, Model, Freeze )
	Check_Enabled( Context )
	
	local G, P = Context.Entity, Context.Player
	local T, C = Players[ G ] or 0, Time[ G ] or 0
	
	if T > CV_Max:GetInt( ) then
		Context:Throw("propcore", "Max total props reached (" .. CV_Max:GetInt( ) .. ")." )
	elseif C > CV_Rate:GetInt( ) then
		Context:Throw("propcore", "Max prop spawn rate reached (" .. CV_Rate:GetInt( ) .. ")." )
	elseif !util.IsValidModel( Model ) or !util.IsValidProp( Model ) then
		Context:Throw("propcore", "Invalid model for prop spawn." )
	end
	
	local Prop = ents.Create("prop_physics")
	if !Prop or !Prop:IsValid( ) then
		Context:Throw("propcore", "Unable to spawn prop." )
	end
	
	local Phys = Prop:GetPhysicsObject()
	if Phys and Phys:IsValid( ) then
		Phys:Wake()
		
		if Freeze > 0 then
			Phys:EnableMotion( false )
		end
	end
	
	AddProp( Prop, G, P )
	
	Prop:SetPos( G:GetPos( ) )
	Prop:Spawn( )
	
	Props[ G ][ Prop ] = Prop
	Players[ P ] = T + 1
	Time[ P ] = C + 1
	
	return Prop
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
		Table:Set("CurProps", "n", Players[ G ] or 0)
		Table:Set("CurRate", "n", Time[ G ] or 0)
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
		
		Check_Enabled( Context )
		
		if Ent and Ent:IsValid( ) and E_A.IsOwner( self.Player, Ent) then
			Ent:Remove( )
		end
	end)
	
/*==============================================================================================
	Section: Pos and Ang
==============================================================================================*/
E_A:RegisterFunction("setPos","e:v","",
	function( self, A, B )
		Check_Enabled( Context )
		
		local Ent, Pos = A( self ), B( self )
		if Ent and Ent:IsValid( ) and E_A.IsOwner( self.Player, Ent) then
			Ent:SetPos( Vector( Pos[1], Pos[2], Pos[3] ) )
		end
	end)

E_A:RegisterFunction("setAng","e:a","",
	function( self, A, B )
		Check_Enabled( Context )
		
		local Ent, Ang = A( self ), B( self )
		if Ent and Ent:IsValid( ) and E_A.IsOwner( self.Player, Ent) then
			Ent:SetAngles( Angle( Ang[1], Ang[2], Ang[3] ) )
		end
	end)
	
/*==============================================================================================
	Section: Parent and Freeze
==============================================================================================*/
local function Parent( self, A, B )
	Check_Enabled( Context )
	
	local Ent, Par = A( self ), B( self )
	if Ent and Ent:IsValid( ) and !Ent:IsVehicle() and E_A.IsOwner( self.Player, Ent) then
		if Par and Par:IsValid( ) and !Par:IsVehicle() and E_A.IsOwner( self.Player, Par) then
			Ent:SetParent( Par )
		end
	end
end
	
E_A:RegisterFunction("setParent","e:e","", Parent)
E_A:RegisterFunction("setParent","e:h","", Parent)
	
E_A:RegisterFunction("setFrozen","e:n","",
	function( self, A, B )
		Check_Enabled( Context )
		
		local Ent, Freeze = A( self ), B( self )
		if Ent and Ent:IsValid( ) and E_A.IsOwner( self.Player, Ent) then
			local Phys = Ent:GetPhysicsObject()
			if Phys and Phys:IsValid( ) then
				Phys:EnableMotion( Freeze > 0 )
			end
		end
	end)