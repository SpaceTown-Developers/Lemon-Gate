/*==============================================================================================
	Expression Advanced: Entitys.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" )

/*==============================================================================================
	Section: Externals
==============================================================================================*/
Core:AddExternal( "GetOwner", API.Util.GetOwner )
Core:AddExternal( "IsOwner", API.Util.IsOwner )
Core:AddExternal( "IsFriend", API.Util.IsFriend )

Core:AddExternal( "NULL_ENTITY", Entity( -1 ) )

/*==============================================================================================
	Section: Class
==============================================================================================*/
local Class = Core:NewClass( "e", "entity", Entity( -1 ) )

Class:Wire_Name( "ENTITY" )

function Class.Wire_Out( Contex, Cell ) return Context.Memory[ Cell ] or Entity( -1 ) end

function Class.Wire_In( Context, Cell, Value ) Context.Memory[ Cell ] = Value end

Core:SetPerf( LEMON_PERF_CHEAP )

-- Compare:

Core:AddOperator( "==", "e,e", "b", "(value %1 == value %2)" )

Core:AddOperator( "!=", "e,e", "b", "(value %1 ~= value %2)" )

-- General:

Core:AddOperator( "is", "e", "b", "$IsValid(value %1)" )

Core:AddOperator( "not", "e", "b", "(!$IsValid(value %1))" )

-- Casting:

Core:AddOperator( "string", "e", "s", "tostring(value %1)" )

/*==============================================================================================
	Section: Get Entity
==============================================================================================*/
Core:AddFunction( "entity", "n", "e", "($Entity(value %1) or %NULL_ENTITY)" )

Core:AddFunction( "voidEntity", "", "e", "%NULL_ENTITY" )

/*==============================================================================================
	Section: Position and angles
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddFunction( "pos", "e:", "v", [[
local %Ent, %Val = value %1, {0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:GetPos( )
	%Val = { %Pos.x, %Pos.y, %Pos.z }
end]], "%Val" )

Core:AddFunction( "ang", "e:", "a", [[
local %Ent, %Val = value %1, {0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %Ang = %Ent:GetAngles( )
	%Val = { %Ang.p, %Ang.y, %Ang.r }
end]], "%Val" )

/*==============================================================================================
	Section: Ent is something
==============================================================================================*/
Core:AddFunction( "isNPC", "e:", "b", "local %Ent = value %1", "($IsValid(%Ent) and %Ent:IsNPC( ))" )

Core:AddFunction( "isWorld", "e:", "b", "local %Ent = value %1", "($IsValid(%Ent) and %Ent:IsWorld( ))" )

Core:AddFunction( "isOnGround", "e:", "b", "local %Ent = value %1", "($IsValid(%Ent) and %Ent:IsOnGround( ))" )

Core:AddFunction( "isUnderWater", "e:", "b", "local %Ent = value %1", "($IsValid(%Ent) and %Ent:WaterLevel( ) > 0)" )

Core:AddFunction( "isValid", "e:", "b", "local %Ent = value %1", "$IsValid(%Ent)" )

Core:AddFunction( "isPlayerHolding", "e:", "b", "local %Ent = value %1", "($IsValid(%Ent) and %Ent:IsPlayerHolding( ))" )

Core:AddFunction( "isOnFire", "e:", "b", "local %Ent = value %1", "($IsValid(%Ent) and %Ent:IsOnFire( ))" )

Core:AddFunction( "isWeapon", "e:", "b", "local %Ent = value %1", "($IsValid(%Ent) and %Ent:IsWeapon( ))" )

Core:AddFunction( "owner", "e:", "b", "local %Ent = value %1", "($IsValid(%Ent) and %GetOwner(%Ent) or %NULL_ENTITY)" )

Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "isFrozen", "e:", "b", [[
local %Ent, %Val = value %1, false
if %Ent and %Ent:IsValid( ) then
	local %Phys = %Ent:GetPhysicsObject( )
	%Val = (%Phys and %Phys:IsValid( ) and %Phys:IsMoveable( ))
end]], "%Val" )


/*==============================================================================================
	Section: Ent Info
==============================================================================================*/
Core:AddFunction( "class", "e:", "s", "local %Ent = value %1", "($IsValid(%Ent) and (%Ent:GetClass( )or \"\") or \"\")" )

Core:AddFunction( "model", "e:", "s", "local %Ent = value %1", "($IsValid(%Ent) and (%Ent:GetModel( )or \"\") or \"\")" )

Core:AddFunction( "name", "e:", "s", "local %Ent = value %1", "($IsValid(%Ent) and (%Ent:GetName( ) or %Ent:Name( )or \"\") or \"\")" )

Core:AddFunction( "health", "e:", "n", "local %Ent = value %1", "($IsValid(%Ent) and (%Ent:Health( ) or 0) or 0)" )

Core:AddFunction( "radius", "e:", "n", "local %Ent = value %1", "($IsValid(%Ent) and (%Ent:BoundingRadius( ) or 0) or 0)" )


/*==============================================================================================
	Section: Vehicle Stuff
==============================================================================================*/
Core:AddFunction( "isVehicle", "e:", "b", "local %Ent = value %1", "($IsValid(%Ent) and %Ent:IsVehicle( ))" )

Core:AddFunction( "driver", "e:", "e", "local %Ent = value %1", "(($IsValid(%Ent) and %Ent:IsVehicle( )) and (%Ent:GetDriver( ) or %NULL_ENTITY) or NULL_ENTITY))" )

Core:AddFunction( "passenger", "e:", "e", "local %Ent = value %1", "(($IsValid(%Ent) and %Ent:IsVehicle( )) and (%Ent:GetPassenger( ) or %NULL_ENTITY) or NULL_ENTITY))" )


/*==============================================================================================
	Section: Mass
==============================================================================================*/
Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddFunction( "mass", "e:", "n", [[
local %Ent, %Val = value %1, 0
if %Ent and %Ent:IsValid( ) then
	local %Phys = %Ent:GetPhysicsObject( )
	%Val = ((%Phys and %Phys:IsValid( )) and (%Phys:GetMass( ) or 0) or 0)
end]], "%Val" )

Core:AddFunction( "massCenterWorld", "e:", "v", [[
local %Ent, %Val = value %1, {0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %Phys = %Ent:GetPhysicsObject( )
	if %Phys and %Phys:IsValid( ) then
		local %Pos = %Ent:LocalToWorld( %Phys:GetMassCenter( ) )
		%Val = {%Pos.x, %Pos.y, %Pos.z}
	end
end]], "%Val" )

Core:AddFunction( "massCenter", "e:", "v", [[
local %Ent, %Val = value %1, {0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %Phys = %Ent:GetPhysicsObject( )
	if %Phys and %Phys:IsValid( ) then
		local %Pos = %Phys:GetMassCenter( )
		%Val = {%Pos.x, %Pos.y, %Pos.z}
	end
end]], "%Val" )

/*==============================================================================================
	Section: OBB Box
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "boxSize", "e:", "v", [[
local %Ent, %Val = value %1, {0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %Size = %Ent:OBBMaxs( ) - %Ent:OBBMins( )
	%Val = { %Size.x, %Size.y, %Size.z }
end]], "%Val" )

Core:AddFunction( "boxCenter", "e:", "v", [[
local %Ent, %Val = value %1, {0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:OBBCenter( )
	%Val = { %Pos.x, %Pos.y, %Pos.z }
end]], "%Val" )


Core:AddFunction( "boxCenterWorld", "e:", "v", [[
local %Ent, %Val = value %1, {0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:LocalToWorld(%Ent:OBBCenter( ))
	%Val = { %Pos.x, %Pos.y, %Pos.z }
end]], "%Val" )

Core:AddFunction( "boxMax", "e:", "v", [[
local %Ent, %Val = value %1, {0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:OBBMaxs( )
	%Val = { %Pos.x, %Pos.y, %Pos.z }
end]], "%Val" )

Core:AddFunction( "boxMin", "e:", "v", [[
local %Ent, %Val = value %1, {0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:OBBMins( )
	%Val = { %Pos.x, %Pos.y, %Pos.z }
end]], "%Val" )

/******************************************************************************/

Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddFunction( "aabbMin", "e:", "v", [[
local %Ent, %Val = value %1, {0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %Phys = %Ent:GetPhysicsObject( )
	if %Phys and %Phys:IsValid( ) then
		local %Pos = %Phys:GetAABB( )
		%Val = {%Pos.x, %Pos.y, %Pos.z}
	end
end]], "%Val" )

Core:AddFunction( "aabbMax", "e:", "v", [[
local %Ent, %Val = value %1, {0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %Phys = %Ent:GetPhysicsObject( )
	if %Phys and %Phys:IsValid( ) then
		local _, %Pos = %Phys:GetAABB( )
		%Val = {%Pos.x, %Pos.y, %Pos.z}
	end
end]], "%Val" )

/*==============================================================================================
	Section: Force
==============================================================================================*/
Core:SetPerf( LEMON_PERF_EXPENSIVE )

Core:AddFunction( "applyForce", "e:v", "", [[
local %Ent, %Vec = value %1, value %2
if %Ent and %Ent:IsValid( ) and %IsOwner( %context.Player, %Ent ) then
	local %Phys = %Ent:GetPhysicsObject( )
	if %Phys and %Phys:IsValid( ) then
		%Phys:ApplyForceCenter( $Vector(%Vec[1], %Vec[2], %Vec[3]) )
	end
end]], "" )

Core:AddFunction( "applyOffsetForce", "e:v,v", "", [[
local %Ent, %A, %B = value %1, value %2, value %3
if %Ent and %Ent:IsValid( ) and %IsOwner( %context.Player, %Ent ) then
	local %Phys = %Ent:GetPhysicsObject( )
	if %Phys and %Phys:IsValid( ) then
		%Phys:ApplyForceOffset($Vector(%B[1], %B[2], %B[3]), Vector(%C[1], %C[2], %C[3]))
	end
end]], "" )

Core:AddFunction( "applyAngForce", "e:a", "", [[
local %Ent, %Ang = value %1, value %2
if %Ent and %Ent:IsValid( ) and %IsOwner( %context.Player, %Ent ) then
	local %Phys = %Ent:GetPhysicsObject( )
	if %Phys and %Phys:IsValid( ) then
		-- assign vectors
		local %Up = %Ent:GetUp()
		local %Left = %Ent:GetRight() * -1
		local %Forward = %Ent:GetForward()

		-- apply pitch force
		if %A[1] ~= 0 and %A[1] < math.huge then
			local %Pitch = %Up * (%A[1] * 0.5)
			%Phys:ApplyForceOffset( %Forward, %Pitch )
			%Phys:ApplyForceOffset( %Forward * -1, %Pitch * -1 )
		end

		-- apply yaw force
		if %A[2] ~= 0 and %A[2] < math.huge then
			local %Yaw = %Forward * (%A[2] * 0.5)
			%Phys:ApplyForceOffset( %Left, %Yaw )
			%Phys:ApplyForceOffset( %Left * -1, %Yaw * -1 )
		end

		-- apply roll force
		if %A[3] ~= 0 and %A[3] < math.huge then
			local %Roll = %Left * (%A[3] * 0.5)
			%Phys:ApplyForceOffset( %Up, %Roll )
			%Phys:ApplyForceOffset( %Up * -1, %Roll * -1 )
		end
	end
end]], "" )

/*==============================================================================================
	Section: Velocity
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "vel", "e:", "v", [[
local %Ent, %Val = value %1, {0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %Phys = %Ent:GetPhysicsObject()
	
	if %Phys and %Phys:IsValid( ) then
		local %Vel = %Ent:GetVelocity( )
		%Val = {%Vel.x, %Vel.y, %Vel.z}
	end
end]], "%Val" )

Core:AddFunction( "angVel", "e:", "a", [[
local %Ent, %Val = value %1, {0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %Phys = %Ent:GetPhysicsObject()
	
	if %Phys and %Phys:IsValid( ) then
		local %Vel = %Ent:GetAngleVelocity( )
		%Val = {%Vel.p, %Vel.y, %Vel.r}
	end
end]], "%Val" )

/*==============================================================================================
	Section: Constraints
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "hasConstraints", "e:", "n", [[
local %Ent, %Val = value %1, 0
if %Ent and %Ent:IsValid( ) then
	%Val = #$constraint.GetTable( %Ent )
end]], "%Val" )

Core:AddFunction( "isConstrained", "e:", "b", [[
local %Ent, %Val = value %1, false
if %Ent and %Ent:IsValid( ) then
	%Val = $constraint.HasConstraints( %Ent )
end]], "%Val" )


Core:AddFunction( "isWeldedTo", "e:", "e", [[
local %Ent, %Val = value %1, %NULL_ENTITY
if %Ent and %Ent:IsValid( ) and $constraint.HasConstraints( %Ent ) then
	local %Con = $constraint.FindConstraint( %Ent, "Weld" )
	if %Con and %Con.Ent1 == %Ent then
		%Val = %Con.Ent2
	elseif %Con then
		%Val = %Con.Ent1 or %Val
	end	
end]], "%Val" )

Core:SetPerf( LEMON_PERF_EXPENSIVE )

Core:AddFunction( "getConstraints", "e:", "t", [[
local %Ent, %Ret = value %1, %Table( )
if %Ent and %Ent:IsValid( ) and $constraint.HasConstraints( %Ent ) then
	for _, %Con in pairs( $constraint.GetAllConstrainedEntities( %Ent ) ) do
		if %Con and %Con:IsValid() and %Con ~= %Ent then
			%Ret:Insert(nil, "e", %Con)
		end
	end
end]], "%Ret" )

/*==============================================================================================
	Section: Bearing & Elevation
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "bearing", "e:v", "n", [[
local %Ent, %Vec, %Val, = value %1, value %2, 0
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:WorldToLocal( $Vector(%Vec[1], %Vec[2], %Vec[3]) )
	%Val = %Rad2Deg * -math.atan2(%Pos.y, %Pos.x)
end]], "%Val" )

Core:AddFunction( "elevation", "e:v", "n", [[
local %Ent, %Vec, %Val, = value %1, value %2, 0
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:WorldToLocal( $Vector(%Vec[1], %Vec[2], %Vec[3]) )
	local %Len = %Pos:Length()
	if %Len > %Round then 
		%Val = %Rad2Deg * -math.asin(%Pos.z / %Len)
	end
end]], "%Val" )

Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddFunction( "heading", "e:v", "a", [[
local %Ent, %Vec, %Val, = value %1, value %2, {0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:WorldToLocal( $Vector(%Vec[1], %Vec[2], %Vec[3]))
	local %Bearing = %Rad2Deg * -math.atan2(%Pos.y, %Pos.x)
	local %Len = %Pos:Length( )

	if %Len > %Round then
		%Val = { %Rad2Deg * math.asin(%Pos.z / %Len), %Bearing, 0 }
	else
		%Val = { 0, %Bearing, 0 }
	end			
end]], "%Val" )

/*==============================================================================================
    Color 
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction("setColor", "e:c", "", [[
local %Ent, %Col = value %1, value %2
if %Ent and %Ent:IsValid( ) and %IsOwner( %context.Player, %Ent ) then
	%Ent:SetColor( %Color( %Color[1], %Col[2], %Col[3], %Col[4] ) )
	%Ent:SetRenderMode(%Col[4] == 255 and 0 or 4)
end]], "" )

Core:AddFunction("getColor", "e:", "c", [[
local %Ent, %Val = value %1, {0, 0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %C = %Ent:GetColor( )
	%Val = { %C.r, %C.g, %C.b, %C.a }
end]], "%Val" )

/*==============================================================================================
	Section: Material
==============================================================================================*/
Core:AddFunction( "getMaterial", "e:", "s", [[
local %Ent, %Val = value %1, ""
if %Ent and %Ent:IsValid( ) then
	%Val = %Ent:GetMaterial( ) or ""
end]], "%Val" )


Core:AddFunction( "setMaterial", "e:s", "", [[
local %Ent = value %1
if %Ent and %Ent:IsValid( ) and %IsOwner( %context.Player, %Ent ) then
	Ent:SetMaterial(value %2)
end]], "" )

/*==============================================================================================
	Section: Finding
==============================================================================================*/
local FindFilter = { -- E2 filters these.
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

-- TODO: API Hook!

Core:AddExternal( "FindFilter", FindFilter )

/***********************************************************************************************/

Core:SetPerf( LEMON_PERF_EXPENSIVE )

Core:AddFunction( "getPlayers", "", "t", "%Table.Results( $player.GetAll( ), \"e\" )" )

Core:AddFunction( "findByClass", "s", "t", [[
local %Res = %Table( )
for _, Find_Entity in pairs( $ents.FindByClass( value %1 ) ) do
	if Find_Entity:IsValid() and !%FindFilter[Find_Entity:GetClass( )] then
		%Res:Insert(nil, "e", Find_Entity)
	end
end]], "%Res" )

Core:AddFunction( "findByModel", "s", "t", [[
local %Res = %Table( )
for _, Find_Entity in pairs( $ents.FindByModel( value %1 ) ) do
	if Find_Entity:IsValid() and !%FindFilter[Find_Entity:GetClass( )] then
		%Res:Insert(nil, "e", Find_Entity)
	end
end]], "%Res" )

Core:AddFunction( "findInSphere", "v,n", "t", [[
local %Vec, %Res = value %1, %Table( )
for _, Find_Entity in pairs( $ents.FindInSphere( $Vector( %Vec[1], %Vec[2], %Vec[3] ), value %2 ) ) do
	if Find_Entity:IsValid() and !%FindFilter[Find_Entity:GetClass( )] then
		%Res:Insert(nil, "e", Find_Entity)
	end
end]], "%Res" )

Core:AddFunction( "findInBox", "v,v", "t", [[
local %A, %B, %Res = value %1, value %2, %Table( )
for _, Find_Entity in pairs( $ents.FindInBox($Vector(%A[1], %A[2], %A[3]), $Vector(%B[1], %B[2], %B[3])) ) do
	if Find_Entity:IsValid() and !%FindFilter[Find_Entity:GetClass( )] then
		%Res:Insert(nil, "e", Find_Entity)
	end
end]], "%Res" )

Core:AddFunction( "findInCone", "v,v,n,a", "t", [[
local %A, %B, %D, %Res = value %1, value %2, value %4, %Table( )
for _, Find_Entity in pairs( $ents.FindInCone($Vector(%A[1], %A[2], %A[3]), $Vector(%B[1], %B[2], %B[3]), value %3, $Angle(%D[1], %D[2], %D[3]))) do
	if Find_Entity:IsValid() and !%FindFilter[Find_Entity:GetClass( )] then
		%Res:Insert(nil, "e", Find_Entity)
	end
end]], "%Res" )