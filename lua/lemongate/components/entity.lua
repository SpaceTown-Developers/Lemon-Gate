/*==============================================================================================
	Expression Advanced: Entity.
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

local Huge = math.huge

Core:AddExternal( "AngleNotHuge", function( self )
	return ( -Huge < self.p and self.p < Huge and -Huge < self.y and self.y < Huge and -Huge < self.r and self.r < Huge )
end ) 

/*==============================================================================================
	Section: Class
==============================================================================================*/
local Class = Core:NewClass( "e", "entity", Entity( -1 ) )

Class:Wire_Name( "ENTITY" )

function Class.Wire_Out( Context, Cell ) return Context.Memory[ Cell ] or Entity( -1 ) end

function Class.Wire_In( Context, Cell, Value ) Context.Memory[ Cell ] = Value end

Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddOperator( "default", "e", "e", "%NULL_ENTITY" )

-- Assign:

Core:AddOperator( "=", "e", "e", [[
%delta[value %1] = %memory[value %1] or %NULL_ENTITY
%memory[value %1] = value %2
%trigger[value %1] = %trigger[value %1] or ( %delta[value %1] ~= %memory[value %1] )
]], "value %2" )

-- Changed:

Core:AddOperator( "~", "e", "b", [[
local %Memory = %memory[value %1]
local %Changed = (%click[value %1] == nil) or (%click[value %1] ~= %Memory)
%click[value %1] = %Memory 
]], "%Changed" )

//Core:AddOperator( "~", "e", "b", "%click[value %1]" )

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

Core:AddFunction( "world", "", "e", "$game.GetWorld()" )

Core:AddFunction( "voidEntity", "", "e", "%NULL_ENTITY" )

Core:AddFunction( "id", "e:", "n", "value %1:EntIndex( )" )


Core:AddFunction( "playerID", "e:", "n", "(value %1:IsPlayer( ) and value %1:UserID( ) or 0)" )

/*==============================================================================================
	Section: Position and angles
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddFunction( "pos", "e:", "v", "($IsValid(value %1) and Vector3( value %1:GetPos() ) or Vector3.Zero:Clone( ) )" )

Core:AddFunction( "ang", "e:", "a", "($IsValid(value %1) and value %1:GetAngles() or Angle(0, 0, 0) )" )

/*==============================================================================================
	Section: Direction
==============================================================================================*/

Core:AddFunction( "forward", "e:", "v", "($IsValid(value %1) and Vector3( value %1:GetForward() ) or Vector3.Zero:Clone( ) )" )

Core:AddFunction( "right", "e:", "v", "($IsValid(value %1) and Vector3( value %1:GetRight() ) or Vector3.Zero:Clone( ) )" )

Core:AddFunction( "up", "e:", "v", "($IsValid(value %1) and Vector3( value %1:GetUp() ) or Vector3.Zero:Clone( ) )" )

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

Core:AddFunction( "owner", "e:", "e", "($IsValid(value %1) and %GetOwner(value %1) or %NULL_ENTITY)" )

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

Core:AddFunction( "getParent", "e:", "e", "($IsValid(value %1) and (value %1:GetParent( ) or %NULL_ENTITY) or %NULL_ENTITY)" )

Core:AddFunction( "id", "e:", "n", "($IsValid(value %1) and (value %1:EntIndex( ) or 0) or 0)" )

/*==============================================================================================
	Section: Vehicle Stuff
==============================================================================================*/
Core:AddFunction( "isVehicle", "e:", "b", "($IsValid(value %1) and value %1:IsVehicle( ))" )

Core:AddFunction( "driver", "e:", "e", "(($IsValid(value %1) and value %1:IsVehicle( )) and (value %1:GetDriver( ) or %NULL_ENTITY) or %NULL_ENTITY)" )

Core:AddFunction( "passenger", "e:", "e", "(($IsValid(value %1) and value %1:IsVehicle( )) and (value %1:GetPassenger(0) or %NULL_ENTITY) or %NULL_ENTITY)" )

/*==============================================================================================
	Section: Mass
==============================================================================================*/
Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddFunction( "setMass", "e:n", "", [[
local %Ent = value %1
if %Ent and %Ent:IsValid( ) and %IsOwner( %context.Player, value %1 ) then
	local %Phys = %Ent:GetPhysicsObject( )
	if %Phys and %Phys:IsValid( ) then
		%Phys:SetMass( math.Clamp( value %2, 0.001, 50000 ) )
	end
end]], LEMON_NO_INLINE )

Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddFunction( "mass", "e:", "n", [[
	if $IsValid(value %1) then
		%util = value %1:GetPhysicsObject( )
	end
]], "($IsValid(%util) and %util:GetMass( ) or 0)" )

Core:AddFunction( "volume", "e:", "n", [[
	if $IsValid(value %1) then
		%util = value %1:GetPhysicsObject( )
	end
]], "($IsValid(%util) and %util:GetVolume( ) or 0)" )

Core:AddFunction( "massCenterWorld", "e:", "v", [[
	if $IsValid(value %1) then
		%util = value %1:GetPhysicsObject( )
	end
]], "($IsValid(%util) and Vector3( value %1:LocalToWorld( %util:GetMassCenter( ) ) ) or Vector3.Zero:Clone( ) )")

Core:AddFunction( "massCenter", "e:", "v", [[
	if $IsValid(value %1) then
		%util = value %1:GetPhysicsObject( )
	end
]], "($IsValid(%util) and Vector3( %util:GetMassCenter( ) ) or Vector3.Zero:Clone( ) )")

/*==============================================================================================
	Section: OBB Box
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddFunction( "boxSize", "e:", "v", "($IsValid( value %1) and Vector3( value %1:OBBMaxs( ) - value %1:OBBMins( ) ) or Vector3(0,0,0) )" )

Core:AddFunction( "boxCenter", "e:", "v", "($IsValid( value %1) and  Vector3( value %1:OBBCenter( ) ) or Vector3(0,0,0) )" )

Core:AddFunction( "boxMax", "e:", "v", "($IsValid( value %1) and  Vector3( value %1:OBBMaxs( ) ) or Vector3(0,0,0) )" )

Core:AddFunction( "boxMin", "e:", "v", "($IsValid( value %1) and  Vector3( value %1:OBBMins( ) ) or Vector3(0,0,0) )" )

/******************************************************************************/

Core:SetPerf( LEMON_PERF_NORMAL )

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
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) and value %2:IsNotHuge( ) then
	local %Phys = value %1:GetPhysicsObject( )
	if %Phys and %Phys:IsValid( ) then
		%Phys:ApplyForceCenter( value %2:Garry( ) )
	end
end]], "" )

Core:AddFunction( "applyOffsetForce", "e:v,v", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) and value %2:IsNotHuge( ) then
	local %Phys = value %1:GetPhysicsObject( )
	if %Phys and %Phys:IsValid( ) then
		%Phys:ApplyForceOffset(value %2:Garry( ), value %3:Garry( ))
	end
end]], "" )

Core:AddFunction( "applyAngForce", "e:a", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) and %AngleNotHuge( value %2 ) then
	local %Phys = value %1:GetPhysicsObject( )
	if %Phys and %Phys:IsValid( ) then
		-- assign vectors
		local %Up = value %1:GetUp()
		local %Left = value %1:GetRight() * -1
		local %Forward = value %1:GetForward()

		-- apply pitch force
		
		if value %2.p ~= 0 and value %2.p < math.huge then
			local %Pitch = %Up * (value %2.p * 0.5)
			%Phys:ApplyForceOffset( %Forward, %Pitch )
			%Phys:ApplyForceOffset( %Forward * -1, %Pitch * -1 )
		end

		-- apply yaw force
		if value %2.y ~= 0 and value %2.y < math.huge then
			local %Yaw = %Forward * (value %2.y * 0.5)
			%Phys:ApplyForceOffset( %Left, %Yaw )
			%Phys:ApplyForceOffset( %Left * -1, %Yaw * -1 )
		end

		-- apply roll force
		if value %2.r ~= 0 and value %2.r < math.huge then
			local %Roll = %Left * (value %2.r * 0.5)
			%Phys:ApplyForceOffset( %Up, %Roll )
			%Phys:ApplyForceOffset( %Up * -1, %Roll * -1 )
		end
	end
end]], "" )

Core:AddFunction( "applyTorque", "e:v", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) and value %2:IsNotHuge( ) then
	local %Phys = value %1:GetPhysicsObject( )
	
	if %Phys and %Phys:IsValid( ) then
		local %Offset
		local %Torque = value %2:Garry( )
		local %Amount = %Torque:Length()

		%Torque = value %1:LocalToWorld( %Torque ) - value %1:GetPos( )
		
		if math.abs( %Torque.x ) > %Amount * 0.1 or math.abs(%Torque.z) > %Amount * 0.1 then
			%Offset = Vector(-%Torque.z, 0, %Torque.x)
		else
			%Offset = Vector(-%Torque.y, %Torque.x, 0)
		end
		
		%Offset = %Offset:GetNormal() * %Amount * 0.5

		local %Dir = ( %Torque:Cross( %Offset ) ):GetNormal()

		%Phys:ApplyForceOffset( %Dir, %Offset )
		%Phys:ApplyForceOffset( %Dir * -1, %Offset * -1 )
	end
end]], "" )

/*==============================================================================================
	Section: Velocity
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "vel", "e:", "v", [[
local %Ret = Vector3(0, 0, 0)
if $IsValid( value %1 ) then
	local %Phys = value %1:GetPhysicsObject()
	if %Phys and %Phys:IsValid() then
		%Ret = Vector3( %Phys:GetVelocity() )
	end
end]], "%Ret" )

Core:AddFunction( "velL", "e:", "v", [[
local %Ret = Vector3(0, 0, 0)
if $IsValid( value %1 ) then
	local %Phys = value %1:GetPhysicsObject()
	if %Phys and %Phys:IsValid() then
		%Ret = Vector3( value %1:WorldToLocal( %Phys:GetVelocity() + value %1:GetPos() ) )
	end
end]], "%Ret" )

Core:AddFunction( "angVelVector", "e:", "v", [[
local %Ret = Vector3(0, 0, 0)
if $IsValid( value %1 ) then
	local %Phys = value %1:GetPhysicsObject()
	if %Phys and %Phys:IsValid() then
		%Ret = Vector3( %Phys:GetAngleVelocity() )
	end
end]], "%Ret" )

Core:AddFunction( "angVel", "e:", "a", [[
local %Ret = Angle(0, 0, 0)
if $IsValid( value %1 ) then
	local %Phys = value %1:GetPhysicsObject()
	if %Phys and %Phys:IsValid() then
		local %GetVel = %Phys:GetAngleVelocity()
		%Ret = Angle( %GetVel.y, %GetVel.z, %GetVel.x )
	end
end]], "%Ret" )

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

Core:SetPerf( LEMON_PERF_ABNORMAL )

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

Core:AddFunction( "getConstraints", "e:", "e*", [[
local %Cons, %Entity = { }, value %1

if %Entity and %Entity:IsValid( ) and $constraint.HasConstraints( %Entity ) then
	for _, Con in pairs( $constraint.GetAllConstrainedEntities( %Entity ) ) do
		if Con and Con:IsValid() and Con ~= %Entity then
			%Cons[#%Cons + 1] = Con
		end
	end
end]], "%Cons" )

/*==============================================================================================
	Section: Bearing & Elevation
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "bearing", "e:v", "n", [[
local %Ent, %Val = value %1, 0
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:WorldToLocal( value %2:Garry( ) )
	%Val = %Rad2Deg * -math.atan2(%Pos.y, %Pos.x)
end]], "%Val" )

Core:AddFunction( "elevation", "e:v", "n", [[
local %Ent, %Val = value %1, 0
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:WorldToLocal( value %2:Garry( ) )
	local %Len = %Pos:Length()
	if %Len > %Round then 
		%Val = %Rad2Deg * math.asin(%Pos.z / %Len)
	end
end]], "%Val" )

Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddFunction( "heading", "e:v", "a", [[
local %Ent, %Val = value %1, Angle(0, 0, 0)
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:WorldToLocal( value %2:Garry( ) )
	local %Bearing = %Rad2Deg * -math.atan2(%Pos.y, %Pos.x)
	local %Len = %Pos:Length( )

	if %Len > %Round then
		%Val = { %Rad2Deg * math.asin(%Pos.z / %Len), %Bearing, 0 }
	else
		%Val = Angle( 0, %Bearing, 0 )
	end			
end]], "%Val" )

/*==============================================================================================
    Section: Color 
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction("setColor", "e:c", "", [[
local %Ent, %Col = value %1, value %2
if %Ent and %Ent:IsValid( ) and %IsOwner( %context.Player, %Ent ) then
	%Ent:SetColor( $Color( %Col[1], %Col[2], %Col[3], %Col[4] ) )
	%Ent:SetRenderMode(%Col[4] == 255 and 0 or 4)
end]], "" )

Core:AddFunction("getColor", "e:", "c", [[
local %Ent, %Val = value %1, {0, 0, 0, 0}
if %Ent and %Ent:IsValid( ) then
	local %C = %Ent:GetColor( )
	%Val = { %C.r, %C.g, %C.b, %C.a }
end]], "%Val" )

/*==============================================================================================
	Section: Material / Skin / Bodygroup
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddFunction( "getMaterial", "e:", "s", [[
local %Ent, %Val = value %1, ""
if %Ent and %Ent:IsValid( ) then
	%Val = %Ent:GetMaterial( ) or ""
end]], "%Val" )

Core:AddFunction( "setMaterial", "e:s", "", [[
local %Ent = value %1
if %Ent and %Ent:IsValid( ) and %IsOwner( %context.Player, %Ent ) then
	%Ent:SetMaterial(value %2)
end]], "" )

Core:AddFunction( "getSkin", "e:", "n", [[
local %Ent, %Val = value %1, ""
if %Ent and %Ent:IsValid( ) then
	%Val = %Ent:GetSkin( ) or 0
end]], "%Val" )

Core:AddFunction( "getSkinCount", "e:", "n", [[
local %Ent, %Val = value %1, ""
if %Ent and %Ent:IsValid( ) then
	%Val = %Ent:SkinCount( ) or 0
end]], "%Val" )

Core:AddFunction( "setSkin", "e:n", "", [[
local %Ent = value %1
if %Ent and %Ent:IsValid( ) and %IsOwner( %context.Player, %Ent ) then
	%Ent:SetSkin(value %2)
end]], "" )

Core:AddFunction( "setBodygroup", "e:n,n", "", [[
local %Ent = value %1
if %Ent and %Ent:IsValid( ) and %IsOwner( %context.Player, %Ent ) then
	%Ent:SetBodygroup(value %2, value %3)
end]], "" )

/*==============================================================================================
	Section: Inertia
==============================================================================================*/
Core:AddFunction( "inertia", "e:", "v", [[
if $IsValid(value %1) then
	%util = value %1:GetPhysicsObject( )
end]], "($IsValid(%util) and Vector3( %util:GetInertia( ) ) or Vector3.Zero:Clone( ) )")

Core:AddFunction( "inertiaA", "e:", "a", [[
if $IsValid(value %1) then
	local %Phys = value %1:GetPhysicsObject( )
	
	if %Phys and %Phys:IsValid( ) then
		local %Inertia = %Phys:GetInertia( )
		%util = Angle(%Inertia.y, %Inertia.z, %Inertia.x)
	end
end]], "(%util or Angle(0, 0, 0))")

/*==============================================================================================
	Section: Trails
==============================================================================================*/
Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddFunction( "setTrail", "e:n,n,n,s,c", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	if !string.find( value %5, "\"", 1, true ) and $file.Exists( "materials/" .. value %5 .. ".vmt", "GAME" ) then
		$duplicator.EntityModifiers.trail( %context.Player, value %1, {
			Color = $Color( value %6[1], value %6[2], value %6[3], value %6[4] ),
			Length = value %4,
			StartSize = value %2,
			EndSize = value %3,
			Material = value %5,
		} )
	end
end]], "" )

Core:AddFunction( "setTrail", "e:n,n,n,s,c,n,b", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	if !string.find( value %5, "\"", 1, true ) and $file.Exists( "materials/" .. value %5 .. ".vmt", "GAME" ) then
		$duplicator.EntityModifiers.trail( %context.Player, value %1, {
			Color = $Color( value %6[1], value %6[2], value %6[3], value %6[4] ),
			Length = value %4,
			StartSize = value %2,
			EndSize = value %3,
			Material = value %5,
			AttachmentID = value %7,
			Additive = value %8
		} )
	end
end]], "" )

Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddFunction( "removeTrail", "e:", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	$duplicator.EntityModifiers.trail( %context.Player, value %1, nil )
end]], "" )

/*==============================================================================================
	Section: Player Stuff
==============================================================================================*/
Core:AddFunction( "isPlayer", "e:", "b", "($IsValid(value %1) and value %1:IsPlayer( ))" )

Core:AddFunction( "isAdmin", "e:", "b", "($IsValid(value %1) and value %1:IsPlayer( ) and value %1:IsAdmin( ))" )

Core:AddFunction( "isSuperAdmin", "e:", "b", "($IsValid(value %1) and value %1:IsPlayer( ) and value %1:IsSuperAdmin( ))" )

/*==============================================================================================
	Section: Team Stuff
==============================================================================================*/
Core:AddFunction( "team", "e:", "n", "( ($IsValid(value %1) and value %1:IsPlayer( )) and value %1:Team( ) or 0 )" )

Core:AddFunction( "teamName", "n", "s", "($team.GetName(value %1) or \"\")" )

Core:AddFunction( "teamScore", "n", "n", "($team.GetScore(value %1) or 0)" )

Core:AddFunction( "playersInTeam", "n", "n", "($team.NumPlayers(value %1) or 0)" )

Core:AddFunction( "teamDeaths", "n", "n", "($team.TotalDeaths(value %1) or 0)" )

Core:AddFunction( "teamFrags", "n", "n", "($team.TotalFrags(value %1) or 0)" )

Core:AddFunction( "teamColor", "n", "c", "local %C = $team.GetColor(value %1)", "{ %C.r, %C.g, %C.b, %C.a }" )

Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "teams", "", "t*", "$team.GetAllTeams()" )

/*==============================================================================================
	Section: Aiming and Eye
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddFunction( "shootPos", "e:", "v", "( ($IsValid(value %1) and value %1:IsPlayer( )) and Vector3( value %1:GetShootPos() ) or Vector3.Zero:Clone() )" )

Core:AddFunction( "eye", "e:", "v", "( ( $IsValid(value %1) and value %1:IsPlayer( ) ) and Vector3( value %1:GetAimVector() or value %1:GetForward() ) or Vector3.Zero:Clone( )  )" )

Core:AddFunction( "eyeAngles", "e:", "a", "($IsValid(value %1) and value %1:EyeAngles() or Angle(0, 0, 0))" )

Core:AddFunction( "aimEntity", "e:", "e", "( ($IsValid(value %1) and value %1:IsPlayer( )) and value %1:GetEyeTraceNoCursor().Entity or %NULL_ENTITY or %NULL_ENTITY)" )

Core:AddFunction( "aimNormal", "e:", "v", "( ($IsValid(value %1) and value %1:IsPlayer( )) and Vector3(value %1:GetEyeTraceNoCursor().HitNormal) or Vector3.Zero:Clone() )" )

Core:AddFunction( "aimPos", "e:", "v", "( ($IsValid(value %1) and value %1:IsPlayer( )) and Vector3(value %1:GetEyeTraceNoCursor().HitPos) or Vector3.Zero:Clone() )" )

/*==============================================================================================
	Section: Player Stats
==============================================================================================*/

Core:AddFunction( "steamID", "e:", "s", "( ($IsValid(value %1) and value %1:IsPlayer( )) and value %1:SteamID() or \"\" )" )

Core:AddFunction( "armor", "e:", "n", "( ($IsValid(value %1) and value %1:IsPlayer( )) and value %1:Armor() or 0 )" )

Core:AddFunction( "ping", "e:", "n", "( ($IsValid(value %1) and value %1:IsPlayer( )) and value %1:Ping() or 0 )" )

Core:AddFunction( "timeConnected", "e:", "n", "( ($IsValid(value %1) and value %1:IsPlayer( )) and value %1:TimeConnected() or 0 )" )

Core:AddFunction( "vehicle", "e:", "e", "( ($IsValid(value %1) and value %1:IsPlayer( )) and value %1:GetVehicle() or %NULL_ENTITY or %NULL_ENTITY)" )

Core:AddFunction( "inNoclip", "e:", "b", "($IsValid(value %1) and value %1:IsPlayer( ) and (value %1:GetMoveType() == $MOVETYPE_NOCLIP) )" )

Core:AddFunction( "flashLight", "e:", "b", "($IsValid(value %1) and value %1:IsPlayer( ) and value %1:FlashlightIsOn( ))" )

/*==============================================================================================
	Section: Keys
==============================================================================================*/
local FuncKeys = {
	["leftClick"] = IN_ATTACK,
	["rightClick"] = IN_ATTACK2,
	["keyForward"] = IN_FORWARD,
	["keyLeft"] = IN_MOVELEFT,
	["keyBack"] = IN_BACK,
	["keyRight"] = IN_MOVERIGHT,
	["keyJump"] = IN_JUMP,
	["keyUse"] = IN_USE,IN_RELOAD,
	["keyZoom"] = IN_ZOOM,
	["keyWalk"] = IN_WALK,
	["keySprint"] = IN_SPEED,
	["keyDuck"] = IN_DUCK,
	["keyLeftTurn"] = IN_LEFT,
	["keyRightTurn"] = IN_RIGHT,
}

for Name, Enum in pairs( FuncKeys ) do
	if type( Name ) == "string" then
		Core:AddFunction( Name, "e:", "b", "($IsValid(value %1) and value %1:IsPlayer( ) and value %1:KeyDown( " .. Enum .. " ) )" )
	end
end

/*==============================================================================================
	Section: Weapons
==============================================================================================*/
Core:AddFunction( "getEquipped", "e:", "e", "(($IsValid(value %1) and value %1:IsPlayer( )) and (value %1:GetActiveWeapon() or %NULL_ENTITY) or %NULL_ENTITY )" )

/*==============================================================================================
	Section: Attachment Points
==============================================================================================*/
Core:AddFunction( "lookupAttachment", "e:s", "n", "($IsValid(value %1) and value %1:LookupAttachment(value %2) or 0)" )

Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddFunction( "attachmentPos", "e:n", "v", [[
if $IsValid( value %1 ) then
	local %At = value %1:GetAttachment(value %2)
	if %At then
		%util = Vector3(%At.Pos)
	end
end
]], "(%util or Vector3(0, 0, 0))")

Core:AddFunction( "attachmentAng", "e:n", "a", [[
if $IsValid( value %1 ) then
	local %At = value %1:GetAttachment(value %2)
	if %At then
		%util = %At.Ang
	end
end
]], "(%util or Angle(0, 0, 0))")

Core:AddFunction( "attachmentPos", "e:s", "v", [[
if $IsValid( value %1 ) then
	local %At = value %1:GetAttachment(value %1:LookupAttachment(value %2) or 0)
	if %At then
		%util = Vector3(%At.Pos)
	end
end
]], "(%util or Vector3(0, 0, 0))")

Core:AddFunction( "attachmentAng", "e:s", "v", [[
if $IsValid( value %1 ) then
	local %At = value %1:GetAttachment(value %1:LookupAttachment(value %2) or 0)
	if %At then
		%util = %At.Ang
	end
end
]], "(%util or Angle(0, 0, 0))")

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

Core:AddFunction( "getPlayers", "", "e*", "$player.GetAll( )" )

Core:AddFunction( "findByClass", "s", "e*", [[
local %Ents = { }
for _, Ent in pairs( $ents.FindByClass( value %1 ) ) do
	if Ent:IsValid() and !%FindFilter[Ent:GetClass( )] then
		%Ents[#%Ents + 1] = Ent
	end
end]], "%Ents" )

Core:AddFunction( "findByModel", "s", "e*", [[
local %Ents = { }
for _, Ent in pairs( $ents.FindByModel( value %1 ) ) do
	if Ent:IsValid() and !%FindFilter[Ent:GetClass( )] then
		%Ents[#%Ents + 1] = Ent
	end
end]], "%Ents" )

Core:AddFunction( "findInSphere", "v,n", "e*", [[
local %Ents = { }
for _, Ent in pairs( $ents.FindInSphere( value %1:Garry( ), value %2 ) ) do
	if Ent:IsValid() and !%FindFilter[Ent:GetClass( )] then
		%Ents[#%Ents + 1] = Ent
	end
end]], "%Ents" )

Core:AddFunction( "findInBox", "v,v", "e*", [[
local %Ents = { }
for _, Ent in pairs( $ents.FindInBox( value %1:Garry( ), value %2:Garry( ) ) ) do
	if Ent:IsValid() and !%FindFilter[Ent:GetClass( )] then
		%Ents[#%Ents + 1] = Ent
	end
end]], "%Ents" )

Core:AddFunction( "findInCone", "v,v,n,a", "e*", [[
local %Ents = { }
for _, Ent in pairs( $ents.FindInCone( value %1:Garry( ), value %2:Garry( ), value %3, value %4)) do
	if Ent:IsValid() and !%FindFilter[Ent:GetClass( )] then
		%Ents[#%Ents + 1] = Ent
	end
end]], "%Ents" )

/***********************************************************************************************/

Core:AddFunction( "findByModel", "s,s", "e*", [[
local %Ents = { }
for _, Ent in pairs( $ents.FindByModel( value %1 ) ) do
	local Class = Ent:GetClass( )
	if Ent:IsValid() and !%FindFilter[Class] and Class == value %2 then
		%Ents[#%Ents + 1] = Ent
	end
end]], "%Ents" )

Core:AddFunction( "findInSphere", "s,v,n", "t", [[
local %Ents = { }
for _, Ent in pairs( $ents.FindInSphere( value %2:Garry( ), value %3 ) ) do
	local Class = Ent:GetClass( )
	if Ent:IsValid() and !%FindFilter[Class] and Class == value %1 then
		%Ents[#%Ents + 1] = Ent
	end
end]], "%Ents" )

Core:AddFunction( "findInSphere", "s,v,n", "t", [[
local %Ents = { }
for _, Ent in pairs( $ents.FindInSphere( value %2:Garry( ), value %3 ) ) do
	local Class = Ent:GetClass( )
	if Ent:IsValid() and !%FindFilter[Class] and Class == value %1 then
		%Ents[#%Ents + 1] = Ent
	end
end]], "%Ents" )

Core:AddFunction( "findInBox", "s,v,v", "t", [[
local %Ents = { }
for _, Ent in pairs( $ents.FindInBox( value %2:Garry( ), value %3:Garry()) ) do
	local Class = Ent:GetClass( )
	if Ent:IsValid() and !%FindFilter[Class] and Class == value %1 then
		%Ents[#%Ents + 1] = Ent
	end
end]], "%Ents" )

Core:AddFunction( "findInCone", "s,v,v,n,a", "t", [[
local %Ents = { }
for _, Ent in pairs( $ents.FindInCone( value %2:Garry( ), value %3:Garry( ), value %4, value %5)) do
	local Class = Ent:GetClass( )
	if Ent:IsValid() and !%FindFilter[Class] and Class == value %1 then
		%Ents[#%Ents + 1] = Ent
	end
end]], "%Ents" )

/***********************************************************************************************/

Core:AddFunction( "findByClass", "s,v", "e*", [[
local %Array, %Vec = { }, value %2:Garry( )
local %Ents = $ents.FindByClass( value %1 )

table.sort( %Ents, function( A, B )
	if !$IsValid( A ) then return false end
	if !$IsValid( B ) then return true end
	return %Vec:Distance( A:GetPos( ) ) < %Vec:Distance( B:GetPos( ) )
end )

for _, Ent in pairs( %Ents ) do
	if Ent:IsValid() and !%FindFilter[Ent:GetClass( )] then
		%Array[#%Array + 1] = Ent
	end
end]], "%Array" )

/***********************************************************************************************/

Core:AddFunction( "playerByName", "s,b", "e", [[
for _, Ply in pairs( $player.GetAll( ) ) do
	if Ply:Name( ) == value %1 or ( !value %2 and Ply:Name( ):lower( ):find( value %1:lower( ) ) ) then
		%util = Ply
		break
	end
end
]], "(%util or %NULL_ENTITY)" )