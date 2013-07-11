/*==============================================================================================
	Expression Advanced: Kinect.
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

Core:AddOperator( "default", "e", "e", "%NULL_ENTITY" )

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

Core:AddFunction( "pos", "e:", "v", "($IsValid(value %1) and Vector3( value %1:GetPos() ) or Vector3.Zero:Clone( ) )" )

Core:AddFunction( "ang", "e:", "a", "($IsValid(value %1) and Vector3( value %1:GetAngles() ) or Angle(0, 0, 0) )" )

/*==============================================================================================
	Section: Ent is something
==============================================================================================*/
Core:AddFunction( "isNPC", "e:", "b", "($IsValid(value %1) and value %1:IsNPC( ))" )

Core:AddFunction( "isWorld", "e:", "b", "($IsValid(value %1) and value %1:IsWorld( ))" )

Core:AddFunction( "isOnGround", "e:", "b", "($IsValid(value %1) and value %1:IsOnGround( ))" )

Core:AddFunction( "isUnderWater", "e:", "b", "($IsValid(value %1) and value %1:WaterLevel( ) > 0)" )

Core:AddFunction( "isValid", "e:", "b", "$IsValid(value %1)" )

Core:AddFunction( "isPlayerHolding", "e:", "b", "($IsValid(value %1) and value %1:IsPlayerHolding( ))" )

Core:AddFunction( "isOnFire", "e:", "b", "($IsValid(value %1) and value %1:IsOnFire( ))" )

Core:AddFunction( "isWeapon", "e:", "b", "($IsValid(value %1) and value %1:IsWeapon( ))" )

Core:AddFunction( "owner", "e:", "b", "($IsValid(value %1) and %GetOwner(value %1) or %NULL_ENTITY)" )

Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "isFrozen", "e:", "b", [[
	if $IsValid(value %1) then
		%util = value %1:GetPhysicsObject( )
	end
]], "($IsValid(%util) and %util:IsMoveable( ))" )


/*==============================================================================================
	Section: Ent Info
==============================================================================================*/
Core:AddFunction( "class", "e:", "s", "($IsValid(value %1) and (value %1:GetClass( )or \"\") or \"\")" )

Core:AddFunction( "model", "e:", "s", "($IsValid(value %1) and (value %1:GetModel( )or \"\") or \"\")" )

Core:AddFunction( "name", "e:", "s", "($IsValid(value %1) and (value %1:GetName( ) or value %1:Name( )or \"\") or \"\")" )

Core:AddFunction( "health", "e:", "n", "($IsValid(value %1) and (value %1:Health( ) or 0) or 0)" )

Core:AddFunction( "radius", "e:", "n", "($IsValid(value %1) and (value %1:BoundingRadius( ) or 0) or 0)" )


/*==============================================================================================
	Section: Vehicle Stuff
==============================================================================================*/
Core:AddFunction( "isVehicle", "e:", "b", "($IsValid(value %1) and value %1:IsVehicle( ))" )

Core:AddFunction( "driver", "e:", "e", "(($IsValid(value %1) and value %1:IsVehicle( )) and (value %1:GetDriver( ) or %NULL_ENTITY) or NULL_ENTITY))" )

Core:AddFunction( "passenger", "e:", "e", "(($IsValid(value %1) and value %1:IsVehicle( )) and (value %1:GetPassenger( ) or %NULL_ENTITY) or NULL_ENTITY))" )


/*==============================================================================================
	Section: Mass
==============================================================================================*/
Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddFunction( "mass", "e:", "n", [[
	if $IsValid(value %1) then
		%util = value %1:GetPhysicsObject( )
	end
]], "(IsValid(%util) and %util:GetMass( ) or 0)" )

Core:AddFunction( "massCenterWorld", "e:", "v", [[
	if $IsValid(value %1) then
		%util = value %1:GetPhysicsObject( )
	end
]], "(IsValid(%util) and Vector3( value %1:LocalToWorld( %util:GetMassCenter( ) ) ) or Vector3.Zero:Clone( ) )")

Core:AddFunction( "massCenter", "e:", "v", [[
	if $IsValid(value %1) then
		%util = value %1:GetPhysicsObject( )
	end
]], "(IsValid(%util) and Vector3( %util:GetMassCenter( ) ) or Vector3.Zero:Clone( ) )")

/*==============================================================================================
	Section: OBB Box
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

-- Trying these with out IsValid() checks, hopfuly they will always be null_entity

Core:AddFunction( "boxSize", "e:", "v", "(Vector3( value %1:OBBMaxs( ) - value %1:OBBMins( ) ) )" )

Core:AddFunction( "boxCenter", "e:", "v", "(Vector3( value %1:OBBCenter( ) ) )" )

Core:AddFunction( "boxMax", "e:", "v", "(Vector3( value %1:OBBMaxs( ) ) )" )

Core:AddFunction( "boxMin", "e:", "v", "(Vector3( value %1:OBBMins( ) ) )" )

/******************************************************************************/

Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddFunction( "aabbMin", "e:", "v", [[
local %Ent, %Val = value %1, Vector3.Zero:Clone( )
if %Ent and %Ent:IsValid( ) then
	local %Phys = %Ent:GetPhysicsObject( )
	if %Phys and %Phys:IsValid( ) then
		%Val = Vector3( %Phys:GetAABB( ) )
	end
end]], "%Val" )

Core:AddFunction( "aabbMax", "e:", "v", [[
local %Ent, %Val = value %1, Vector3.Zero:Clone( )
if %Ent and %Ent:IsValid( ) then
	local %Phys = %Ent:GetPhysicsObject( )
	if %Phys and %Phys:IsValid( ) then
		local _, %Pos = %Phys:GetAABB( )
		%Val = Vector3( %Pos )
	end
end]], "%Val" )

/*==============================================================================================
	Section: Force
==============================================================================================*/
Core:SetPerf( LEMON_PERF_EXPENSIVE )

Core:AddFunction( "applyForce", "e:v", "", [[
local %Ent = value %1
if %Ent and %Ent:IsValid( ) and %IsOwner( %context.Player, %Ent ) then
	local %Phys = %Ent:GetPhysicsObject( )
	if %Phys and %Phys:IsValid( ) then
		%Phys:ApplyForceCenter( value %2:Garry( ) )
	end
end]], "" )

Core:AddFunction( "applyOffsetForce", "e:v,v", "", [[
local %Ent = value %1
if %Ent and %Ent:IsValid( ) and %IsOwner( %context.Player, %Ent ) then
	local %Phys = %Ent:GetPhysicsObject( )
	if %Phys and %Phys:IsValid( ) then
		%Phys:ApplyForceOffset(value %2:Garry( ), value %3:Garry( ))
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
		if %Ang.p ~= 0 and %Ang.p < math.huge then
			local %Pitch = %Up * (%Ang.p * 0.5)
			%Phys:ApplyForceOffset( %Forward, %Pitch )
			%Phys:ApplyForceOffset( %Forward * -1, %Pitch * -1 )
		end

		-- apply yaw force
		if %Ang.y ~= 0 and %Ang.y < math.huge then
			local %Yaw = %Forward * (%Ang.y * 0.5)
			%Phys:ApplyForceOffset( %Left, %Yaw )
			%Phys:ApplyForceOffset( %Left * -1, %Yaw * -1 )
		end

		-- apply roll force
		if %Ang.r ~= 0 and %Ang.r < math.huge then
			local %Roll = %Left * (%Ang.r * 0.5)
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
local %Ent, %Val = value %1, Vector3(0, 0, 0)
if %Ent and %Ent:IsValid( ) then
	local %Phys = %Ent:GetPhysicsObject()
	
	if %Phys and %Phys:IsValid( ) then
		%Val = Vector3( %Phys:GetVelocity( ) )
	end
end]], "%Val" )

Core:AddFunction( "angVel", "e:", "a", [[
local %Ent, %Val = value %1, Angle(0, 0, 0)
if %Ent and %Ent:IsValid( ) then
	local %Phys = %Ent:GetPhysicsObject()
	
	if %Phys and %Phys:IsValid( ) then
		local %Vel = %Phys:GetAngleVelocity( )
		%Val = Angle(%Vel.x, %Vel.y, %Vel.z)
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
local %Ent, %Val, = value %1, 0
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:WorldToLocal( value %2:Garry( ) )
	%Val = %Rad2Deg * -math.atan2(%Pos.y, %Pos.x)
end]], "%Val" )

Core:AddFunction( "elevation", "e:v", "n", [[
local %Ent, %Val, = value %1, 0
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:WorldToLocal( value %2:Garry( ) )
	local %Len = %Pos:Length()
	if %Len > %Round then 
		%Val = %Rad2Deg * -math.asin(%Pos.z / %Len)
	end
end]], "%Val" )

Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddFunction( "heading", "e:v", "a", [[
local %Ent, %Val, = value %1, {0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:WorldToLocal( value %2:Garry( ) )
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

/*==============================================================================================
	Section: Player Trace
==============================================================================================*/
Core:SetPerf( LEMON_PERF_EXPENSIVE )

Core:AddFunction( "eyeTrace", "e:", "t", [[
local %Ent = value %1
local %Val = $IsValid( %Ent ) and %Table.From( %Ent:GetEyeTraceNoCursor( ) ) and %Table( )
]], "%Val" )

/*==============================================================================================
	Section: Trace Stuff
==============================================================================================*/
Core:AddFunction( "trace", "v,v[,b,t]", "t", "local %F = value %4",
"%Table.From( $util.TraceLine( { start = value %1:Garry( ), endpos = value %2:Garry( ), mask = (value %3 and MASK_WATER or nil), filter = (%F and %F.Data or nil) } ) )" )

Core:AddFunction( "traceHull", "v,v,v[,b,t]", "t", [[
local %O, %F = value %3:Garry( ), value %5
]], "%Table.From( $util.TraceHull( { start = value %1:Garry( ), endpos = value %2:Garry( ), mins = %O / 2, maxs = -(%O / 2), mask = (value %4 and MASK_WATER or nil), filter = (%F and %F.Data or nil) } ) )" )
