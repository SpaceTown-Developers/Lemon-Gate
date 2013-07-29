/*==============================================================================================
	Expression Advanced: Component -> Constraint Core.
	Creditors: shadowscion, Omicron
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Component = API:NewComponent( "constraintcore", false )

local ConstraintCore = { }

Component:AddExternal( "ConstraintCore", ConstraintCore )

/*==============================================================================================
	Section: Util
==============================================================================================*/
Component:AddException( "constraintcore" )

function ConstraintCore.AddConstraint( Constraint, Context )
	local P = Context.Player

	-- undo.Create( Constraint:Name() ) // Any easy way to get the constraint type?
	undo.Create( "Lemongate Constraint" )
		undo.AddEntity( Constraint )
		undo.SetPlayer( P )
	undo.Finish()

	P:AddCleanup( "constraints", Constraint )
end

/*==============================================================================================
	Section: Remove Constraints
==============================================================================================*/
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction("removeAllConstraints", "e:", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	$constraint.RemoveAll( value %1 )
end]], LEMON_NO_INLINE )

Component:AddFunction("removeConstraint", "e:s", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	$constraint.RemoveConstraints( value %1, value %2 )
end]], LEMON_NO_INLINE )

/*==============================================================================================
	Section: Create Constraints
==============================================================================================*/

----------------------------
-- Weld
----------------------------
Component:AddFunction("weldTo", "e:e,n", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	if $IsValid( value %2 ) and %IsOwner( %context.Player, value %2 ) then
		local %Constraint = $constraint.Weld( value %1, value %2, 0, 0, 0, value %4 )
		%ConstraintCore.AddConstraint( %Constraint, %context )
	end
end]], LEMON_NO_INLINE )

Component:AddFunction("weldTo", "e:e,n,n", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	if $IsValid( value %2 ) and %IsOwner( %context.Player, value %2 ) then
		local %Constraint = $constraint.Weld( value %1, value %2, 0, 0, value %3, value %4 )
		%ConstraintCore.AddConstraint( %Constraint, %context )
	end
end]], LEMON_NO_INLINE )

----------------------------
-- Axis
----------------------------
Component:AddFunction("axisTo", "e:e,v,v,n,n,n,n,v", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	if $IsValid( value %2 ) and %IsOwner( %context.Player, value %2 ) then
		local %Constraint = $constraint.Axis( value %1, value %2, 0, 0, value %3:Garry(), value %4:Garry(), value %5, value %6, value %7, value %8, value %9:Garry() )
		%ConstraintCore.AddConstraint( %Constraint, %context )
	end
end]], LEMON_NO_INLINE )

----------------------------
-- Ballsocket
----------------------------
Component:AddFunction("ballsocketTo", "e:e,v,n", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	if $IsValid( value %2 ) and %IsOwner( %context.Player, value %2 ) then
		local %Constraint = $constraint.Ballsocket( value %1, value %2, 0, 0, value %3:Garry(), 0, 0, value %4 )
		%ConstraintCore.AddConstraint( %Constraint, %context )
	end
end]], LEMON_NO_INLINE )

Component:AddFunction("ballsocketTo", "e:e,v,n,n,n", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	if $IsValid( value %2 ) and %IsOwner( %context.Player, value %2 ) then
		local %Constraint = $constraint.Ballsocket( value %1, value %2, 0, 0, value %3:Garry(), value %4, value %5, value %6 )
		%ConstraintCore.AddConstraint( %Constraint, %context )
	end
end]], LEMON_NO_INLINE )

----------------------------
-- Advanced Ballsocket
----------------------------
Component:AddFunction("advBallsocketTo", "e:e,v,v,n,n,v,v,v,n", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	if $IsValid( value %2 ) and %IsOwner( %context.Player, value %2 ) then
		local %Mn = value %7
		local %Mx = value %8
		local %Fr = value %9

		local %Constraint = $constraint.AdvBallsocket( value %1, value %2, 0, 0, value %3:Garry(), value %4:Garry(), value %5, value %6, %Mn.x, %Mn.y, %Mn.z, %Mx.x, %Mx.y, %Mx.x, %Fr.x, %Fr.y, %Fr.z, value %10, 0 )
		%ConstraintCore.AddConstraint( %Constraint, %context )
	end
end]], LEMON_NO_INLINE )

----------------------------
-- Rope
----------------------------			
Component:AddFunction("ropeTo", "e:e,v,v,n,n,n,n,s,b", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	if $IsValid( value %2 ) and %IsOwner( %context.Player, value %2 ) then
		local %Mat = value %9 == "" and "cable/rope" or value %9
		local %Constraint = $constraint.Rope( value %1, value %2, 0, 0, value %3:Garry(), value %4:Garry(), value %5, value %6, value %7, value %8, %Mat, value %10 )
		%ConstraintCore.AddConstraint( %Constraint, %context )
	end
end]], LEMON_NO_INLINE )

----------------------------
-- Elastic
----------------------------
Component:AddFunction("elasticTo", "e:e,v,v,n,n,n,s,n,b", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	if $IsValid( value %2 ) and %IsOwner( %context.Player, value %2 ) then
		local %Mat = value %8 == "" and "cable/rope" or value %8
		local %Constraint = $constraint.Elastic( value %1, value %2, 0, 0, value %3:Garry(), value %4:Garry(), value %5, value %6, value %7, %Mat, value %9, value %10 )
		%ConstraintCore.AddConstraint( %Constraint, %context )
	end
end]], LEMON_NO_INLINE )

----------------------------
-- Slider
----------------------------
Component:AddFunction("sliderTo", "e:e,v,v,n", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	if $IsValid( value %2 ) and %IsOwner( %context.Player, value %2 ) then
		local %Constraint = $constraint.Slider( value %1, value %2, 0, 0, value %3:Garry(), value %4:Garry(), value %5 )
		%ConstraintCore.AddConstraint( %Constraint, %context )
	end
end]], LEMON_NO_INLINE )

----------------------------
-- NoCollide
----------------------------
Component:AddFunction("noCollideAll", "e:b", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	value %1:SetCollisionGroup( value %2 and $COLLISION_GROUP_WORLD or $COLLISION_GROUP_NONE )
end]], LEMON_NO_INLINE )

Component:AddFunction("noCollideTo", "e:e", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	if $IsValid( value %2 ) and %IsOwner( %context.Player, value %2 ) then
		local %Constraint = $constraint.NoCollide( value %1, value %2, 0, 0 )
		%ConstraintCore.AddConstraint( %Constraint, %context )
	end
end]], LEMON_NO_INLINE )