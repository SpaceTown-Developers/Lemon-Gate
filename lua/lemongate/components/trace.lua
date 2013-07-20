/*==============================================================================================
	Expression Advanced: Kinect.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Component = API:NewComponent( "trace", true )

/*==============================================================================================
	Section: Class
==============================================================================================*/

local Class = Component:NewClass( "tr", "trace" )

Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddOperator( "default", "tr", "tr", "{ start = Vector(0, 0, 0), endpos = Vector(0, 0, 0), filter = { } }", LEMON_INLINE_ONLY )

/*==============================================================================================
	Section: Constructors
==============================================================================================*/

Component:AddFunction( "trace", "", "tr", "{ start = Vector(0, 0, 0), endpos = Vector(0, 0, 0), filter = { } }", LEMON_INLINE_ONLY )

Component:AddFunction( "trace", "v,v", "tr", "{ start = value %1:Garry(), endpos = value %2:Garry(), filter = { } }", LEMON_INLINE_ONLY )

/*==============================================================================================
	Section: Start / End
==============================================================================================*/

Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction( "startPos", "tr:v", "", "value %1.start = value %2:Garry()", LEMON_PREPARE_ONLY )

Component:AddFunction( "endPos", "tr:v", "", "value %1.endpos = value %2:Garry()", LEMON_PREPARE_ONLY )

/*==============================================================================================
	Section: Filter
==============================================================================================*/

Component:AddFunction( "clearFilter", "tr", "", "value %1.filter = { }", LEMON_PREPARE_ONLY )

Component:AddFunction( "filter", "tr:e", "", "table.insert(value %1.filter, value %2)", LEMON_PREPARE_ONLY )

/*==============================================================================================
	Section: Usage
==============================================================================================*/

Component:AddFunction( "update", "tr", "", "value %1.result = $util.TraceLine(value %1)", LEMON_PREPARE_ONLY )
Component:AddFunction( "entity", "tr", "e", "value %1.result = value %1.result or $util.TraceLine(value %1)", "value %1.result.Entity or %NULL_ENTITY" )
Component:AddFunction( "fraction", "tr", "n", "value %1.result = value %1.result or $util.TraceLine(value %1)", "value %1.result.Fraction or 0" )
Component:AddFunction( "fractionLeftSolid", "tr", "n", "value %1.result = value %1.result or $util.TraceLine(value %1)", "value %1.result.FractionLeftSolid or 0" )
Component:AddFunction( "hit", "tr", "b", "value %1.result = value %1.result or $util.TraceLine(value %1)", "value %1.result.Hit" )
Component:AddFunction( "hitNoDraw", "tr", "b", "value %1.result = value %1.result or $util.TraceLine(value %1)", "value %1.result.HitNoDraw" )
Component:AddFunction( "hitNonWorld", "tr", "b", "value %1.result = value %1.result or $util.TraceLine(value %1)", "value %1.result.HitNonWorld" )
Component:AddFunction( "hitSky", "tr", "b", "value %1.result = value %1.result or $util.TraceLine(value %1)", "value %1.result.HitSky" )
Component:AddFunction( "hitWorld", "tr", "b", "value %1.result = value %1.result or $util.TraceLine(value %1)", "value %1.result.HitWorld" )
Component:AddFunction( "startSolid", "tr", "b", "value %1.result = value %1.result or $util.TraceLine(value %1)", "value %1.result.StartSolid" )
Component:AddFunction( "hitBox", "tr", "n", "value %1.result = value %1.result or $util.TraceLine(value %1)", "(value %1.result.HitBox or 0)" )
Component:AddFunction( "hitGroup", "tr", "n", "value %1.result = value %1.result or $util.TraceLine(value %1)", "(value %1.result.HitGroup or 0)" )
Component:AddFunction( "hitMaterial", "tr", "n", "value %1.result = value %1.result or $util.TraceLine(value %1)", "(value %1.result.MatType or 0)" )
Component:AddFunction( "hitBone", "tr", "n", "value %1.result = value %1.result or $util.TraceLine(value %1)", "(value %1.result.PhysicsBone or 0)" )
Component:AddFunction( "hitNormal", "tr", "v", "value %1.result = value %1.result or $util.TraceLine(value %1)", "Vector3(value %1.result.HitNormal or Vector(0, 0, 0))" )
Component:AddFunction( "hitPos", "tr", "v", "value %1.result = value %1.result or $util.TraceLine(value %1)", "Vector3(value %1.result.HitPos or Vector(0, 0, 0))" )
Component:AddFunction( "normal", "tr", "v", "value %1.result = value %1.result or $util.TraceLine(value %1)", "Vector3(value %1.result.Normal or Vector(0, 0, 0))" )
Component:AddFunction( "hitTexture", "tr", "s", "value %1.result = value %1.result or $util.TraceLine(value %1)", "(value %1.result.HitTexture or \"\")" )

/*==============================================================================================
	Section: Masks
==============================================================================================*/
Component:AddFunction( "getHitState", "tr", "n", "(value %1.mask or 0)", LEMON_INLINE_ONLY )
Component:AddFunction( "setHitState", "tr:n", "", "value %1.mask = value %2", LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_SOLID", CONTENTS_SOLID )
Component:AddFunction( "hitSolid", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_SOLID ) == %CONTENTS_SOLID ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_SOLID ) or bit.band( %Mask, bit.bnot( %CONTENTS_SOLID ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_WINDOW", CONTENTS_WINDOW )
Component:AddFunction( "hitWindows", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_WINDOW ) == %CONTENTS_WINDOW ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_WINDOW ) or bit.band( %Mask, bit.bnot( %CONTENTS_WINDOW ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_AUX", CONTENTS_AUX )
Component:AddFunction( "hitAuxilory", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_AUX ) == %CONTENTS_AUX ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_AUX ) or bit.band( %Mask, bit.bnot( %CONTENTS_AUX ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_GRATE", CONTENTS_GRATE )
Component:AddFunction( "hitGrate", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_GRATE ) == %CONTENTS_GRATE ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_GRATE ) or bit.band( %Mask, bit.bnot( %CONTENTS_GRATE ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_SLIME", CONTENTS_SLIME )
Component:AddFunction( "hitSlime", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_SLIME ) == %CONTENTS_SLIME ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_SLIME ) or bit.band( %Mask, bit.bnot( %CONTENTS_SLIME ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_WATER", CONTENTS_WATER )
Component:AddFunction( "hitWater", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_WATER ) == %CONTENTS_WATER ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_WATER ) or bit.band( %Mask, bit.bnot( %CONTENTS_WATER ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_BLOCKLOS", CONTENTS_BLOCKLOS )
Component:AddFunction( "useLineOfSight", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_BLOCKLOS ) == %CONTENTS_BLOCKLOS ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_BLOCKLOS ) or bit.band( %Mask, bit.bnot( %CONTENTS_BLOCKLOS ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_OPAQUE", CONTENTS_OPAQUE )
Component:AddFunction( "hitOpaque", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_OPAQUE ) == %CONTENTS_OPAQUE ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_OPAQUE ) or bit.band( %Mask, bit.bnot( %CONTENTS_OPAQUE ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_IGNORE_NODRAW_OPAQUE", CONTENTS_IGNORE_NODRAW_OPAQUE )
Component:AddFunction( "ignoreNoDraw", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_IGNORE_NODRAW_OPAQUE ) == %CONTENTS_IGNORE_NODRAW_OPAQUE ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_IGNORE_NODRAW_OPAQUE ) or bit.band( %Mask, bit.bnot( %CONTENTS_IGNORE_NODRAW_OPAQUE ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_MOVEABLE", CONTENTS_MOVEABLE )
Component:AddFunction( "hitMoveable", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_MOVEABLE ) == %CONTENTS_MOVEABLE ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_MOVEABLE ) or bit.band( %Mask, bit.bnot( %CONTENTS_MOVEABLE ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_AREAPORTAL", CONTENTS_AREAPORTAL )
Component:AddFunction( "hitPortal", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_AREAPORTAL ) == %CONTENTS_AREAPORTAL ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_AREAPORTAL ) or bit.band( %Mask, bit.bnot( %CONTENTS_AREAPORTAL ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_PLAYERCLIP", CONTENTS_PLAYERCLIP )
Component:AddFunction( "hitPlayerClip", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_PLAYERCLIP ) == %CONTENTS_PLAYERCLIP ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_PLAYERCLIP ) or bit.band( %Mask, bit.bnot( %CONTENTS_PLAYERCLIP ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_MONSTERCLIP", CONTENTS_MONSTERCLIP )
Component:AddFunction( "hitNPCClip", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_MONSTERCLIP ) == %CONTENTS_MONSTERCLIP ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_MONSTERCLIP ) or bit.band( %Mask, bit.bnot( %CONTENTS_MONSTERCLIP ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_ORIGIN", CONTENTS_ORIGIN )
Component:AddFunction( "hitOrigin", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_ORIGIN ) == %CONTENTS_ORIGIN ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_ORIGIN ) or bit.band( %Mask, bit.bnot( %CONTENTS_ORIGIN ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_MONSTER", CONTENTS_MONSTER )
Component:AddFunction( "hitNPC", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_MONSTER ) == %CONTENTS_MONSTER ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_MONSTER ) or bit.band( %Mask, bit.bnot( %CONTENTS_MONSTER ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_DEBRIS", CONTENTS_DEBRIS )
Component:AddFunction( "hitDebris", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_DEBRIS ) == %CONTENTS_DEBRIS ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_DEBRIS ) or bit.band( %Mask, bit.bnot( %CONTENTS_DEBRIS ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_DETAIL", CONTENTS_DETAIL )
Component:AddFunction( "hitDetail", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_DETAIL ) == %CONTENTS_DETAIL ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_DETAIL ) or bit.band( %Mask, bit.bnot( %CONTENTS_DETAIL ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_TRANSLUCENT", CONTENTS_TRANSLUCENT )
Component:AddFunction( "hitTranslucent", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_TRANSLUCENT ) == %CONTENTS_TRANSLUCENT ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_TRANSLUCENT ) or bit.band( %Mask, bit.bnot( %CONTENTS_TRANSLUCENT ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_LADDER", CONTENTS_LADDER )
Component:AddFunction( "hitLadders", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_LADDER ) == %CONTENTS_LADDER ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_LADDER ) or bit.band( %Mask, bit.bnot( %CONTENTS_LADDER ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "CONTENTS_HITBOX", CONTENTS_HITBOX )
Component:AddFunction( "hitHitboxes", "tr:b", "", [[
local %Mask = value %1.mask or 0
if ( bit.band( %Mask, %CONTENTS_HITBOX ) == %CONTENTS_HITBOX ) == value %2 then
	value %1.mask = value %2 and bit.bor( %Mask, %CONTENTS_HITBOX ) or bit.band( %Mask, bit.bnot( %CONTENTS_HITBOX ) )
end]], LEMON_PREPARE_ONLY )

Component:AddExternal( "MASK_ALL", MASK_ALL )
Component:AddFunction( "hitAll", "tr:", "", "value %1.mask = %MASK_ALL", LEMON_PREPARE_ONLY )

