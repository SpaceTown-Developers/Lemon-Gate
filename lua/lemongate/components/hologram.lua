/*==============================================================================================
	Expression Advanced: Component -> Holograms.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Component = API:NewComponent( "hologram", true )

/*==============================================================================================
	Section: HoloGram Lib
==============================================================================================*/
local NeedsSync, Recent = false, { }
local HoloLib = { Owners = { }, Holograms = { }, HologramOwners = { }, Queue = { } }
local Owners, Holograms, HologramOwners, Queue = HoloLib.Owners, HoloLib.Holograms, HoloLib.HologramOwners, HoloLib.Queue
LEMON.HoloLib = HoloLib

-- Create external!
Component:AddExternal( "HoloLib", HoloLib )

function HoloLib.GetAll( Gate )
	return Holograms[ Gate ] or { }
end

function HoloLib.Remove( Context, Holo )
    if Holo and Holo:IsValid( ) and Holo.Player == Context.Player then
        local Gate, Owner = Gate.Entity, Context.Player
        Owners[Owner] = Owners[Owner] - 1
        Holograms[Gate][Holo] = nil
        Holo:Remove( )
    end
end

function HoloLib.RemoveAll( Gate )
	local Holos = Holograms[Gate]

    if Holos then
        local Count = Owners[Gate.Player] or 0

        for _, Holo in pairs( Holograms[Gate] ) do
            if Holo:IsValid( ) then
                if table.Count( Holo.Clips ) > 0 then 
                    net.Start( "lemon_hologram_removeHoloLib._Clips" )
                        net.WriteUInt( Holo:EntIndex( ), 16 )
                    net.Broadcast( )
                end 
                Count = Count - 1
                Holo:Remove( )
            end
        end

        if Count < 0 then Count = 0 end -- Should never happen!

        Owners[Gate.Player] = Count
        Holograms[Gate] = { }
    end
end


function HoloLib.QueueHologram( Gate )
    if Gate and Gate:IsValid( ) and Gate.IsHologram then
        Queue[Gate] = true
        NeedsSync = true
    end
end

function HoloLib.RescaleAny( X, Y, Z, Max, Size )
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

/*==============================================================================================
    Convars
==============================================================================================*/
HoloLib._Max = CreateConVar( "lemon_holograms_max", "128" )
HoloLib._Rate = CreateConVar( "lemon_holograms_per_tick", "20" )
HoloLib._Clips = CreateConVar( "lemon_holograms__clips", "5" )
HoloLib._Size = CreateConVar( "lemon_holograms_Size", "50" )
HoloLib._Model = CreateConVar( "lemon_holograms_model_any", "1" )

/*==============================================================================================
	Section: Models
==============================================================================================*/
HoloLib.ModelList = {
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

-- TODO: Add Hook!

for _, Model in pairs( HoloLib.ModelList ) do
    util.PrecacheModel( "models/Holograms/" .. Model .. ".mdl" )
end

function HoloLib.Model( Trace, Context, Holo, ModelS )
	if IsValid( Holo ) and Holo.Player == Context.Player then
        local ValidModel = HoloLib.ModelList[ ModelS ]
		print( "YAY!" )
        if ValidModel then
            Holo:SetModel( "models/Holograms/" .. ValidModel .. ".mdl" )
            Holo.ModelAny = false
        elseif HoloLib._Model:GetInt( ) >= 1 and IsValidModel( ModelS ) then
            Holo:SetModel( Model( ModelS ) )
            Holo.ModelAny = true
        else
            Context:Throw( Trace, "hologram", "unknown hologram model used" )
        end	
	end
end
	
/*==============================================================================================
	Section: Creators
==============================================================================================*/
local IsValidModel = util.IsValidModel

function HoloLib.Create( Trace, Context )
    local Ent, Owner = Context.Entity, Context.Player

    local Burst = Recent[Ent]
    if !Burst then
        Burst = 0
    elseif Burst > HoloLib._Rate:GetInt( ) then
        Context:Throw( Trace, "hologram", "too many holograms made at once")
    end

    local Count = Owners[Owner]

    if !Count then
        Count = 0
    elseif Count >= HoloLib._Max:GetInt( ) then
        Context:Throw( Trace, "hologram", "hologram limit reached")
    end

    local Holo = ents.Create( "lemon_holo" )
    if !Holo or !Holo:IsValid( ) then
        Context:Throw( Trace, "hologram", "unable to create hologram")
    end

    Holo.Player = Owner
    if CPPI then Holo:CPPISetOwner( Owner ) end
	
	Recent[Ent] = Burst + 1
    Owners[Owner] = Count + 1
    
	Holograms[Ent][Holo] = Holo -- Hmm?
	
    Holo:SetModel( "models/Holograms/sphere.mdl" )
    Holo:SetPos( Ent:GetPos( ) )
    Holo:Spawn( )
    Holo:Activate( )

    NeedsUpdate = true 
    Queue[Holo] = true
    NeedsSync = true
    
    return Holo
end

function HoloLib.Create2( Trace, Context, ModelS )
    local Holo = HoloLib.Create( Trace, Context )
    local ValidModel = HoloLib.ModelList[ ModelS ]

    if ValidModel then
        Holo:SetModel( "models/Holograms/" .. ValidModel .. ".mdl" )
        Holo.ModelAny = false
        return Holo

    elseif HoloLib._Model:GetInt() >= 1 and IsValidModel( ModelS ) then
        Holo:SetModel( Model(ModelS) )
        Holo.ModelAny = true
        return Holo
    end

    Holo:Remove( )
	
    Context:Throw( Trace, "hologram", "unknown hologram model used")
end

/*==============================================================================================
	Section: API Hooks
==============================================================================================*/
function Component:Create( Gate )
	Holograms[ Gate ] = { }
end

function Component:BuildContext( Gate )
	HoloLib.RemoveAll( Gate )
end

function Component:Remove( Gate )
	HoloLib.RemoveAll( Gate )
end

function Component:ShutDown( Gate )
	HoloLib.RemoveAll( Gate )
end

/*==============================================================================================
	Section: Class and Operators
==============================================================================================*/
local Hologram = Component:NewClass( "h", "hologram" )

Hologram:Extends( "e" )

-- Casting:

Component:SetPerf( LEMON_PERF_ABNORMAL )

Component:AddOperator( "hologram", "e", "h", [[
if !$IsValid( value %1 ) or !value %1.IsHologram then
	%context:Throw( %trace, "hologram", "casted none hologram from entity")
end ]], "value %1" )

/*==============================================================================================
    Creator Functions
==============================================================================================*/
Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction( "hologram", "", "h", "%HoloLib.Create( %trace, %context )")

Component:AddFunction("hologram", "s", "h", "%HoloLib.Create2( %trace, %context, value %1 )")

Component:AddFunction( "hologram", "s,v", "h", [[
local %Holo = %HoloLib.Create( %trace, %context, value %1 )
%Holo:SetPos( value %2:Garry( ) )
]], "%Holo" )

/*==============================================================================================
    Util
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddFunction( "remove", "h:", "", "%HoloLib.Remove( %context, value %1 )" )

Component:AddFunction( "setModel", "h:s", "", "%HoloLib.Model( %trace, %context, value %1, value %2 )", "" )

Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction("isHologram", "e:", "b", "local %Holo = value %1", "(%Holo and %Holo:IsValid( ) and %Holo.IsHologram)" )

-- CVars:

Component:AddFunction("maxHolograms", "", "n", "%HoloLib._Max:GetInt( )" )

Component:AddFunction("maxHologramClips", "", "n", "%HoloLib._Clips:GetInt( )" )

Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction("holograms", "", "t", "%Table.Results( %HoloLib.GetAll( %context.Entity ), \"h\" )" )

/*==============================================================================================
    Position and angles
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddFunction("setPos", "h:v", "",[[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetPos( value %2:Garry( ) )
end]], "" )

Component:AddFunction("setAng", "h:a", "",[[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	value %1:SetAngles( value %2 )
end]], "" )

/*==============================================================================================
    Scale
==============================================================================================*/
Component:SetPerf( LEMON_PERF_ABNORMAL )

Component:AddFunction("scale", "h:v", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	local %Max = %HoloLib._Size:GetInt()
	local %X, %Y, %Z

	if !value %1.ModelAny then
		%X = math.Clamp(value %2.x, -%Max, %Max)
		%Y = math.Clamp(value %2.y, -%Max, %Max)
		%Z = math.Clamp(value %2.z, -%Max, %Max)
	else
		local %Size = value %1:OBBMaxs() - value %1:OBBMins()
		%X, %Y, %Z = %HoloLib.RescaleAny(value %2.x, value %2.y, value %2.z, %Max, %Size)
	end

	if value %1:SetScale(%X, %Y, %Z) then
		%HoloLib.QueueHologram( value %1 )
	end
end]], "" )

Component:AddFunction("scaleUnits", "h:v", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	local %Scale = value %1:OBBMaxs() - value %1:OBBMins()
	local %Max = HoloLib._Size:GetInt()

	local %X = math.Clamp(value %2.x / %Scale.x, -%Max, %Max)
	local %Y = math.Clamp(value %2.y / %Scale.y, -%Max, %Max)
	local %Z = math.Clamp(value %2.z / %Scale.z, -%Max, %Max)

	if value %1.ModelAny then
		%X, %Y, %Z = HoloLib.RescaleAny(%X, %Y, %Z, %Max, %Scale)
	end

	if value %1:SetScale(%X, %Y, %Z) then
		HoloLib.QueueHologram( value %1 )
	end
end]], "" )

Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction("getScale", "h:", "v", "local %Holo = value %1", "($IsValid(%Holo) and Vector3(%.Scale or Vector(0, 0, 0)) or Vector3.Zero:Clone())" )

/*==============================================================================================
    Color
==============================================================================================*/
Component:AddFunction("setColor", "h:c", "", [[
if IsValid( value %1 ) and value %1.Player == %context.Player then
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
	Material
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

/*==============================================================================================
    Rendering
==============================================================================================*/
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction("shading", "h:b", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	if value %1:SetShading(value %2) then
		%HoloLib.QueueHologram( value %1 )
	end
end]], "" )

Component:AddFunction("visible", "h:b", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	if value %1:SetVisible(value %2) then
		%HoloLib.QueueHologram( value %1 )
	end
end]], "" )

/*==============================================================================================
    Clipping
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddFunction("pushClip", "h:n,v,v", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player then
	if !value %1:ClipCount( value %2, %HoloLib._Clips:GetInt( ) ) then
		%context:Throw( %trace, "hologram", "max clip count reached")
	end

	if value %1:PushClip( value %2, value %3:Garry( ), value %4:Garry( ) ) then
		%HoloLib.QueueHologram( value %1 )
	end
end]], "" )

Component:AddFunction("removeClip", "h:n", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player and value %1:RemoveClip( value %2 ) then
	%HoloLib.QueueHologram( value %1 )
end]], "" )

Component:AddFunction("enableClip", "h:n,b", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player and value %1:EnableClip( value %2, value %3 ) then
	%HoloLib.QueueHologram( value %1 )
end]], "" )

/*==============================================================================================
    Parent
==============================================================================================*/
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction("parent", "h:e", "", [[
if $IsValid( value %1 ) and value %1.Player == %context.Player and $IsValid( value %2 )then
	value %1:SetParent(value %2)
end]], "" , "Sets the parent of a hologram" )

Component:AddFunction("getParentHolo", "h:", "h", [[
local %Val = %NULL_ENTITY

if %IsValid( value %1 ) then
	local %Parent = value %1:GetParent( )
	
	if %Parent and %Parent:IsValid( ) and %Parent.IsHologram then
		%Val = %Parent
	end
end]], "%Val", "Gets the parent hologram of a hologram" )

Component:AddFunction("getParent", "h:", "e", [[
local %Val = %NULL_ENTITY
if $IsValid( value %1 ) then
	local %Parent = value %1:GetParent( )
	
	if %Parent and %Parent:IsValid( ) then
		%Val = %Parent
	end
end]], "%Val", "Gets the parent entity of a hologram" )

/*==============================================================================================
    Sync
==============================================================================================*/
local net = net
util.AddNetworkString( "lemon_hologram" )
util.AddNetworkString( "lemon_hologram_removeHoloLib._Clips" )

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