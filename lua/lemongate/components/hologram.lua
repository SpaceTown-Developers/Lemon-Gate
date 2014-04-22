/*==============================================================================================
	Expression Advanced: Component -> Holograms.
	Creditors: Rusketh
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Component = API:NewComponent( "hologram", true )

Component:AddExternal( "hologram", Component )

/*==============================================================================================
    Section: Convars
==============================================================================================*/
local Cvar_MaxHolograms = CreateConVar( "lemon_holograms_max", "250" )
local Cvar_SpawnRate = CreateConVar( "lemon_holograms_rate", "50" )
local Cvar_MaxClips = CreateConVar( "lemon_holograms_clips", "5" )
local Cvar_MaxScale = CreateConVar( "lemon_holograms_Size", "50" )
local Cvar_ModelAll = CreateConVar( "lemon_holograms_model_any", "1" )

-- Cvar based functions
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction( "hologramLimit", "", "n", "$GetConVarNumber(\"lemon_holograms_max\", 0)" )
Component:AddFunction( "hologramSpawnRate", "", "n", "$GetConVarNumber(\"lemon_holograms_per_tick\", 0)" )
Component:AddFunction( "hologramClipLimit", "", "n", "$GetConVarNumber(\"lemon_holograms_clips\", 0)" )
Component:AddFunction( "hologramMaxScale", "", "n", "$GetConVarNumber(\"lemon_holograms_Size\", 0)" )
Component:AddFunction( "hologramAnyModel", "", "n", "$tobool( $GetConVarNumber(\"lemon_holograms_model_any\", 0) )" )

/*==============================================================================================
    Section: Hologram Handeling
==============================================================================================*/
local HolosByEntity = { }

local HolosByPlayer = { }

local DeltaPerPlayer = { }

function Component:ShutDown( Gate )
	if IsValid( Gate.Player ) then
		local PlyTbl = HolosByPlayer[ Gate.Player:UniqueID( ) ]

		for _, Holo in pairs( HolosByEntity[ Gate ] or { } ) do
			PlyTbl[ Holo ] = nil
			if IsValid( Holo ) then Holo:Remove( ) end
		end
	else
		for _, Holo in pairs( HolosByEntity[ Gate ] or { } ) do
			if IsValid( Holo ) then Holo:Remove( ) end
		end
	end
end

function Component:APIReload( )
	HolosByPlayer = { }

	for Gate, Holos in pairs( HolosByEntity ) do
		for _, Holo in pairs( Holos ) do
			if IsValid( Holo ) then Holo:Remove( ) end
		end
	end
end

timer.Create( "lemon.holograms", 1, 0, function( )
	DeltaPerPlayer = { }
end )

hook.Add( "PlayerInitialSpawn", "lemon.hologram.owners", function( Ply )
	local Holos = HolosByPlayer[ Ply:UniqueID( ) ]
	
	if !Holos then return end

	local Total = 0

	for _, Holo in pairs( Holos ) do Total = Total + 1 end

	Ply:SetNWInt( "lemon.holograms", Total )
end )

/*==============================================================================================
    Section: Really Big Model List
==============================================================================================*/

local ModelEmu = {
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

-- TODO: Api Hook!

Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddExternal( "holomodel", ModelEmu )
Component:AddFunction( "asGameModel", "s", "s", "( %holomodel[value %1] or \"\" )" )

/*==============================================================================================
	Section: Class and Operators
==============================================================================================*/
local Hologram = Component:NewClass( "h", "hologram" )

Hologram:Extends( "e" )

Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddOperator( "default", "h", "h", "%NULL_ENTITY" )

-- Casting:

Component:SetPerf( LEMON_PERF_ABNORMAL )

Component:AddOperator( "hologram", "e", "h", [[
if !$IsValid( value %1 ) or !value %1.IsHologram then
	%context:Throw( %trace, "hologram", "casted none hologram from entity.")
end ]], "value %1" )

/*==============================================================================================
    Section: Set Model
==============================================================================================*/

function Component.SetModel( Context, Entity, Model )
	local ValidModel = ModelEmu[ Model or "sphere" ]

	if ValidModel then
		if Entity.IsHologram and Entity.Player == Context.Player then
			Entity:SetModel( "models/holograms/" .. ValidModel .. ".mdl" )
		end

	elseif !Cvar_ModelAll:GetBool( ) or !util.IsValidModel( Model ) then
		Context:Throw( nil, "hologram", "Invalid model set " .. Model )
	elseif Entity.IsHologram and Entity.Player == Context.Player then
		Entity:SetModel( ValidModel or Model )
	end
end

Component:AddFunction( "setModel", "h:s", "", "%hologram.SetModel( %context, value %1, value %2 )" )

/*==============================================================================================
    Section: ID Emulation
    	-- Don't worry, they are still objects!
==============================================================================================*/

function Component:SetID( Context, Entity, ID )
	if ID < 1 or !Entity.IsHologram then return end

	Context.Holograms[ Entity.ID or -1 ] = nil

	Context.Holograms[ ID ] = Entity

	Entity.ID = ID
end

Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddFunction( "getID", "h:", "n", "(value %1.ID or -1)" )
Component:AddFunction( "setID", "h:n", "", "%hologram:SetID( %context, value %1, value %2 )", "" )
Component:AddFunction( "hologram", "n", "h", "(%context.Holograms[ value %1] or %NULL_ENTITY)" )

/*==============================================================================================
    Section: Creation
==============================================================================================*/

function Component.NewHolo( Context, Model, Position, Angle )
	local UID = Context.Player:UniqueID( )

	if Context.Player:GetNWInt( "lemon.holograms", 0 ) >= Cvar_MaxHolograms:GetInt( ) then
		Context:Throw( nil, "hologram", "Hologram limit reached." )
	elseif ( DeltaPerPlayer[ UID ] or 0 ) >= Cvar_SpawnRate:GetInt( ) then
		Context:Throw( nil, "hologram", "Hologram cooldown reached." )
	end

	local Entity = ents.Create( "lemon_holo" )

	if !IsValid( Entity ) then
		Context:Throw( nil, "hologram", "Failed to create hologram." )
	end

	Context.Player:SetNWInt( "lemon.holograms", Context.Player:GetNWInt( "lemon.holograms", 0 ) + 1 )

	Entity.Player = Context.Player

	Entity:Spawn( )

	Entity:Activate( )
	
	if CPPI then Entity:CPPISetOwner( Context.Player ) end

	HolosByEntity[ Context.Entity ] = HolosByEntity[ Context.Entity ] or { }

	HolosByEntity[ Context.Entity ][ Entity ] = Entity

	HolosByPlayer[ UID ] = HolosByPlayer[ UID ] or { }

	HolosByPlayer[ UID ][ Entity ] = Entity

	DeltaPerPlayer[ UID ] = ( DeltaPerPlayer[ UID ] or 0 ) + 1

	Context.Holograms = Context.Holograms or { }

	local ID = #Context.Holograms + 1
	Context.Holograms[ ID ] = ID

	--if !Model then return Entity end
	Component.SetModel( Context, Entity, Model or "sphere" )

	if !Position then
		Entity:SetPos( Context.Entity:GetPos( ) )
	else
		Entity:SetPos( Position:Garry( ) )
	end

	if !Angle then
		Entity:SetAngles( Context.Entity:GetAngles( ) )
	else
		Entity:SetAngles( Angle )
	end

	return Entity
end

Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction( "hologram", "", "h", "%hologram.NewHolo( %context )" )

Component:AddFunction( "hologram", "s", "h", "%hologram.NewHolo( %context, value %1 )" )

Component:AddFunction( "hologram", "s,v", "h", "%hologram.NewHolo( %context, value %1, value %2 )" )

Component:AddFunction( "hologram", "s,v,a", "h", "%hologram.NewHolo( %context, value %1, value %2, value %3 )" )

/*==============================================================================================
    Section: Can Hologram
==============================================================================================*/
function Component.CanHolo( Context )
	local UID = Context.Player:UniqueID( )
	
	if Context.Player:GetNWInt( "lemon.holograms", 0 ) >= Cvar_MaxHolograms:GetInt( ) then
		return false
	elseif ( DeltaPerPlayer[ UID ] or 0 ) >= Cvar_SpawnRate:GetInt( ) then
		return false
	end

	return true
end

Component:AddFunction( "canMakeHologram", "", "b", "%hologram.CanHolo( %context )" )

/*==============================================================================================
    Position
==============================================================================================*/
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction("setPos", "h:v", "",[[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetPos( value %2:Garry( ) )
end]], "" )

Component:AddFunction("moveTo", "h:v,n", "",[[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:MoveTo( value %2:Garry( ), value %3 )
end]], "" )

Component:AddFunction("stopMove", "h:", "",[[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:StopMove( )
end]], "" )

/*==============================================================================================
    Angles
==============================================================================================*/
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction("setAng", "h:a", "",[[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetAngles( value %2 )
end]], "" )

Component:AddFunction("rotateTo", "h:a,n", "",[[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:RotateTo( value %2, value %3 )
end]], "" )

Component:AddFunction("stopRotate", "h:", "",[[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:StopRotate( )
end]], "" )

/*==============================================================================================
    Scale
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddFunction("setScale", "h:v", "",[[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetScale( value %2:Garry( ) )
end]], "" )

Component:AddFunction("setScaleUnits", "h:v", "",[[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetScaleUnits( value %2:Garry( ) )
end]], "" )

Component:AddFunction("scaleTo", "h:v,n", "",[[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:ScaleTo( value %2:Garry( ), value %3 )
end]], "" )

Component:AddFunction("stopScale", "h:", "",[[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:StopScale( )
end]], "" )

Component:AddFunction("getScale", "h:", "v",[[
if $IsValid( value %1 ) and value %1.GetScale then
	%util = value %1:GetScale( )
end]], "Vector3( %util or Vector( 0, 0, 0 ) )" )

Component:AddFunction("getScaleUnits", "h:", "v",[[
if $IsValid( value %1 ) and value %1.GetScale then
	%util = value %1:GetScaleUnits( )
end]], "Vector3( %util or Vector( 0, 0, 0 ) )" )


/*==============================================================================================
    Visible and Shading
==============================================================================================*/

Component:AddFunction("shading", "h:b", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetShading(value %2)
end]], "" )

Component:AddFunction("visible", "h:b", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetVisible(value %2)
end]], "" )

Component:AddFunction("isVisible", "h:", "b", "($IsValid( value %1 ) and value %1.INFO.VISIBLE or false )" )

Component:AddFunction("hasShading", "h:", "b", "($IsValid( value %1 ) and value %1.INFO.SHADING or false )" )

/*==============================================================================================
    Section: Clipping
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddFunction("pushClip", "h:n,v,v", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:PushClip( value %2, value %3:Garry( ), value %4:Garry( ) )
end]], "" )

/*Component:AddFunction("removeClip", "h:n", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player and value %1:RemoveClip( value %2 ) then
	%HoloLib.QueueHologram( value %1 )
end]], "" ) Not supported yet*/

Component:AddFunction("enableClip", "h:n,b", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetClipEnabled( value %2, value %3 )
end]], "" )

Component:AddFunction("setClipOrigin", "h:n,v", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetClipOrigin( value %2, value %3:Garry( ) )
end]], "" )

Component:AddFunction("setClipNormal", "h:n,v", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetClipNormal( value %2, value %3:Garry( ) )
end]], "" )

/*==============================================================================================
    Section: Color
==============================================================================================*/
Component:AddFunction("setColor", "h:c", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetColor( $Color( value %2[1], value %2[2], value %2[3], value %2[4] ) )
	value %1:SetRenderMode(value %2[4] == 255 and 0 or 4)
end]], "" )

Component:AddFunction("getColor", "h:", "c", [[
local %Val = {0, 0, 0, 0}
if $IsValid( value %1 ) then
	local %C = value %1:GetColor( )
	%Val = { %C.r, %C.g, %C.b, %C.a }
end]], "%Val" )

/*==============================================================================================
	Section: Material / Skin / Bodygroup
==============================================================================================*/
Component:AddFunction( "setMaterial", "h:s", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetMaterial(value %2)
end]], "" )

Component:AddFunction( "getMaterial", "h:", "s", [[
local %Val = ""
if $IsValid( value %1 ) then
	%Val = value %1:GetMaterial( ) or ""
end]], "%Val" )

Component:AddFunction( "getSkin", "h:", "n", [[
local %Val = ""
if $IsValid( value %1 ) then
	%Val = value %1:GetSkin( ) or 0
end]], "%Val" )

Component:AddFunction( "getSkinCount", "h:", "n", [[
local %Val = ""
if $IsValid( value %1 ) then
	%Val = value %1:SkinCount( ) or 0
end]], "%Val" )

Component:AddFunction( "setSkin", "h:n", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetSkin(value %2)
end]], "" )

Component:AddFunction( "setBodygroup", "h:n,n", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetBodygroup(value %2, value %3)
end]], "" )

/*==============================================================================================
    Section: Parent
==============================================================================================*/
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction("parent", "h:e", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player and $IsValid( value %2 )then
	value %1:SetParent(value %2)
end]], "" )

Component:AddFunction("parent", "h:h", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player and $IsValid( value %2 )then
	value %1:SetParent(value %2)
end]], "" )

Component:AddFunction("parent", "h:p", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player and $IsValid( value %2 )then
	value %1:SetParent(value %2)
end]], "" )

Component:AddFunction("unParent", "h:", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetParent( nil )
end]], "" )

Component:AddFunction("getParentHolo", "h:", "h", [[
local %Val = %NULL_ENTITY

if $IsValid( value %1 ) then
	local %Parent = value %1:GetParent( )
	
	if %Parent and %Parent:IsValid( ) and %Parent.IsHologram then
		%Val = %Parent
	end
end]], "%Val" )

Component:AddFunction("getParent", "h:", "e", [[
local %Val = %NULL_ENTITY
if $IsValid( value %1 ) then
	local %Parent = value %1:GetParent( )
	
	if %Parent and %Parent:IsValid( ) then
		%Val = %Parent
	end
end]], "%Val" )

/*==============================================================================================
    Section: Bones
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddFunction("setBonePos", "h:n,v", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetBonePos( value %2, value %3:Garry( ) )
end]], "" )

Component:AddFunction("setBoneAngle", "h:n,a", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetBoneAng( value %2, value %3 )
end]], "" )

Component:AddFunction("setBoneScale", "h:n,v", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetBoneScale( value %2, value %3:Garry( ) )
end]], "" )

Component:AddFunction("jiggleBone", "h:n,b", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetBoneJiggle( value %2, value %3 )
end]], "" )

Component:AddFunction("getBonePos", "h:n", "v", [[
if $IsValid( value %1 ) then
	%util = value %1:GetBonePos( value %1 )
end]], "Vector3( %util or Vector( 0, 0, 0 ) )" )

Component:AddFunction("getBoneAng", "h:n", "v", [[
if $IsValid( value %1 ) then
	%util = value %1:GetBoneAngle( value %1 )
end]], "( %util or Angle( 0, 0, 0 ) )" )

Component:AddFunction("getBoneScale", "h:n", "v", [[
if $IsValid( value %1 ) then
	%util = value %1:GetBoneScale( value %1 )
end]], "Vector3( %util or Vector( 0, 0, 0 ) )" )

Component:AddFunction("boneCount", "h:", "n", [[
if $IsValid( value %1 ) then
	%util = value %1:GetBoneCount( )
end]], "( %util or 0 )" )

/*==============================================================================================
    Section: Animation
==============================================================================================*/
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction("setAnimation", "h:n[,n,n]", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetHoloAnimation(value %2, value %3, value %4)
end]], "" ) 

Component:AddFunction("setAnimation", "h:s[,n,n]", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetHoloAnimation(value %1:LookupSequence( value %2 ), value %3, value %4)
end]], "" )

Component:AddFunction("animationLength", "h:", "n", "( $IsValid( value %1 ) and value %1:SequenceDuration( ) or 0 )" )

Component:AddFunction("setPose", "h:s,n", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetPoseParameter(value %2, value %3 )
end]], "" )

Component:AddFunction("getPose", "h:s", "n", "( $IsValid( value %1 ) and value %1:GetPoseParameter( value %2 ) or 0 )" )

Component:AddFunction("animation", "h:s", "n", [[
if $IsValid( value %1 ) then
	%util = value %1:LookupSequence(value %2)
end]], "(%util or 0)" )

Component:AddFunction( "getAnimation", "h:", "n", "( $IsValid( value %1 ) and value %1:GetSequence( ) or 0 )" )

Component:AddFunction( "getAnimationName", "h:n", "s", "( $IsValid( value %1 ) and value %1:GetSequenceName( value %2 ) or \"\" )" )

Component:AddFunction( "setAnimationRate", "h:n", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetPlaybackRate(value %2)
end]], "" )

/*==============================================================================================
    Section: Remove
==============================================================================================*/
Component:AddFunction("remove", "h:", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:Remove( )
end]], "" )
