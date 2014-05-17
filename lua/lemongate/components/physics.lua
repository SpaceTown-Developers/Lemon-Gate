/*==============================================================================================
	Expression Advanced: Phys Objects.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" )

/*==============================================================================================
	Section: Externals
==============================================================================================*/

local Class = Core:NewClass( "p", "physics" )

Core:SetPerf( LEMON_PERF_CHEAP )

-- Changed:

Core:AddOperator( "~", "p", "b", [[
local %Memory = %memory[value %1]
local %Changed = (%click[value %1] == nil) or (%click[value %1] ~= %Memory)
%click[value %1] = %Memory 
]], "%Changed" )

//Core:AddOperator( "~", "p", "b", "%click[value %1]" )

-- Compare:

Core:AddOperator( "==", "p,p", "b", "(value %1 == value %2)" )

Core:AddOperator( "!=", "p,p", "b", "(value %1 ~= value %2)" )

-- General:

Core:AddOperator( "is", "p", "b", "$IsValid(value %1)" )

Core:AddOperator( "not", "p", "b", "(!$IsValid(value %1))" )

-- Casting:

Core:AddOperator( "string", "p", "s", "tostring(value %1)" )

Core:AddOperator( "entity", "p", "e", "( $IsValid( value %1 ) and value %1:GetEntity( ) or %NULL_ENTITY )" )


/*==============================================================================================
	Section: Entity to Physics
==============================================================================================*/
Core:AddOperator( "physics", "e", "p", "( $IsValid( value %1 ) and value %1:GetPhysicsObject( ) or nil )" )

Core:AddFunction( "getPhysics", "e:", "p", "( $IsValid( value %1 ) and value %1:GetPhysicsObject( ) or nil )" )

Core:AddFunction( "getPhysicsCount", "e:", "n", "($IsValid(value %1) and value %1:GetPhysicsObjectCount( ) or 0)" )

Core:AddFunction( "getPhysicsIndex", "e:n", "p", "($IsValid(value %1) and value %1:GetPhysicsObjectNum( value %2 ) or nil)" )

/*==============================================================================================
	Section: Position and angles
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddFunction( "pos", "p:", "v", "($IsValid(value %1) and Vector3( value %1:GetPos() ) or Vector3.Zero:Clone( ) )" )

Core:AddFunction( "ang", "p:", "a", "($IsValid(value %1) and value %1:GetAngles() or Angle(0, 0, 0) )" )

/*==============================================================================================
	Section: Direction
==============================================================================================*/
Core:AddFunction( "forward", "p:", "v", "($IsValid(value %1) and Vector3(value %1:LocalToWorld( Vector(1,0,0) ) - value %1:GetPos( )) or Vector3.Zero:Clone( ) )" )

Core:AddFunction( "right", "p:", "v", "($IsValid(value %1) and Vector3(value %1:LocalToWorld( Vector(0,-1,0) ) - value %1:GetPos( )) or Vector3.Zero:Clone( ) )" )

Core:AddFunction( "up", "p:", "v", "($IsValid(value %1) and Vector3(value %1:LocalToWorld( Vector(0,0,1) ) - value %1:GetPos( )) or Vector3.Zero:Clone( ) )" )

/*==============================================================================================
	Section: World and Local
==============================================================================================*/
Core:AddFunction( "toWorld", "p:v", "v", "($IsValid(value %1) and Vector3(value %1:LocalToWorld( value %2:Garry() )) or Vector3.Zero:Clone( ) )" )

Core:AddFunction( "toLocal", "p:v", "v", "($IsValid(value %1) and Vector3(value %1:WorldToLocal( value %2:Garry() )) or Vector3.Zero:Clone( ) )" )

/*==============================================================================================
	Section: Velocity
==============================================================================================*/
Core:AddFunction( "vel", "p:", "v", "($IsValid(value %1) and Vector3(value %1:GetVelocity( )) or Vector3.Zero:Clone( ) )" )

-- Core:AddFunction( "velL", "p:", "v", "($IsValid(value %1) and Vector3(value %1:WorldtoLocal(value %1:GetVelocity( ) + value %1:GetPos( )) ) or Vector3.Zero:Clone( ) )" )

Core:AddFunction( "angVelVector", "p:", "v", [[
local %Ret = Vector3(0, 0, 0)
if $IsValid( value %1 ) then
	%Ret = Vector3( value %1:GetAngleVelocity() )
end]], "%Ret" )

Core:AddFunction( "angVel", "p:", "a", [[
local %Ret = Angle(0, 0, 0)
if $IsValid( value %1 ) then
	local %GetVel = value %1:GetAngleVelocity()
	%Ret = Angle( %GetVel.y, %GetVel.z, %GetVel.x )
end]], "%Ret" )

Core:AddFunction( "inertia", "p:", "v", "($IsValid(value %1) and Vector3(value %1:GetInertia( )) or Vector3.Zero:Clone( ) )" )

/*==============================================================================================
	Section: Bearing & Elevation
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "bearing", "p:v", "n", [[
local %Ent, %Val = value %1, 0
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:WorldToLocal( value %2:Garry( ) )
	%Val = %Rad2Deg * -math.atan2(%Pos.y, %Pos.x)
end]], "%Val" )

Core:AddFunction( "elevation", "p:v", "n", [[
local %Ent, %Val = value %1, 0
if %Ent and %Ent:IsValid( ) then
	local %Pos = %Ent:WorldToLocal( value %2:Garry( ) )
	local %Len = %Pos:Length()
	if %Len > %Round then 
		%Val = %Rad2Deg * -math.asin(%Pos.z / %Len)
	end
end]], "%Val" )

Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddFunction( "heading", "p:v", "a", [[
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
	Section: Mass
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "setMass", "p:n", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1:GetEntity( ) )
	value %1:SetMass( math.Clamp( value %2, 0.001, 50000 ) )
end]], LEMON_NO_INLINE )

Core:AddFunction( "mass", "p:", "n", "($IsValid(value %1) and value %1:GetMass( ) or 0)" )

Core:AddFunction( "massCenter", "p:", "v", "($IsValid(value %1) and Vector3( value %1:LocalToWorld( value %1:GetMassCenter( ) ) ) or Vector3.Zero:Clone( ) )")

Core:AddFunction( "massCenterL", "p:", "v", "($IsValid(value %1) and Vector3( value %1:GetMassCenter( ) ) or Vector3.Zero:Clone( ) )")

Core:AddFunction( "mass", "p:", "n", "($IsValid(value %1) and value %1:GetMass( ) or 0)" )

Core:AddFunction( "massCenterWorld", "p:", "v", "($IsValid(value %1) and Vector3( value %1:LocalToWorld( value %1:GetMassCenter( ) ) ) or Vector3.Zero:Clone( ) )")

Core:AddFunction( "massCenter", "p:", "v", "($IsValid(value %1) and Vector3( value %1:GetMassCenter( ) ) or Vector3.Zero:Clone( ) )")

/*==============================================================================================
	Section: AABB
==============================================================================================*/
Core:AddFunction( "aabbMin", "p:", "v", [[
if $IsValid( value %1 ) then
	%util = Vector3( value %1:GetAABB( ) )
end]], "(%util or Vector3.Zero:Clone( ))" )

Core:AddFunction( "aabbMax", "p:", "v", [[
if $IsValid( value %1 ) then
	local _, %Abb = value %1:GetAABB( )
	%util = Vector3( %Abb )
end]], "(%util or Vector3.Zero:Clone( ))" )

/*==============================================================================================
	Section: Frozen
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddFunction( "isFrozen", "p:", "b", "($IsValid(value %1) and value %1:IsMoveable( ))" )

/*==============================================================================================
	Section: Apply Force
==============================================================================================*/
Core:SetPerf( LEMON_PERF_EXPENSIVE )

Core:AddFunction( "applyForce", "p:v", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1:GetEntity( ) ) and value %2:IsNotHuge( ) then
	value %1:ApplyForceCenter( value %2:Garry( ) )
end]], "" )

Core:AddFunction( "applyOffsetForce", "p:v,v", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1:GetEntity( ) ) and value %2:IsNotHuge( ) then
	value %1:ApplyForceOffset(value %2:Garry( ), value %3:Garry( ))
end]], "" )

Core:AddFunction( "applyAngForce", "p:a", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1:GetEntity( ) ) and %AngleNotHuge( value %2 ) then
	-- assign vectors
	local %Pos     = value %1:GetPos()
	local %Forward = value %1:LocalToWorld(Vector(1,0,0)) - %Pos
	local %Left    = value %1:LocalToWorld(Vector(0,1,0)) - %Pos
	local %Up      = value %1:LocalToWorld(Vector(0,0,1)) - %Pos

	-- apply pitch force
	
	if value %2.p ~= 0 and value %2.p < math.huge then
		local %Pitch = %Up * (value %2.p * 0.5)
		value %1:ApplyForceOffset( %Forward, %Pitch )
		value %1:ApplyForceOffset( %Forward * -1, %Pitch * -1 )
	end

	-- apply yaw force
	if value %2.y ~= 0 and value %2.y < math.huge then
		local %Yaw = %Forward * (value %2.y * 0.5)
		value %1:ApplyForceOffset( %Left, %Yaw )
		value %1:ApplyForceOffset( %Left * -1, %Yaw * -1 )
	end

	-- apply roll force
	if value %2.r ~= 0 and value %2.r < math.huge then
		local %Roll = %Left * (value %2.r * 0.5)
		value %1:ApplyForceOffset( %Up, %Roll )
		value %1:ApplyForceOffset( %Up * -1, %Roll * -1 )
	end
end]], "" )

Core:AddFunction( "applyTorque", "p:v", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1:GetEntity( ) ) and value %2:IsNotHuge( ) then
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

	value %1:ApplyForceOffset( %Dir, %Offset )
	value %1:ApplyForceOffset( %Dir * -1, %Offset * -1 )
end]], "" )

