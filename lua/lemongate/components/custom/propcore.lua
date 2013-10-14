/*==============================================================================================
	Expression Advanced: Component -> Prop Core.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Component = API:NewComponent( "propcore", false )

local PropCore = { 
	Prop_Max = CreateConVar( "lemon_prop_max", 50, {FCVAR_ARCHIVE, FCVAR_NOTIFY} ),
	Prop_Rate = CreateConVar( "lemon_prop_rate", 10, {FCVAR_ARCHIVE, FCVAR_NOTIFY} )
}

Component:AddExternal( "PropCore", PropCore )

/*==============================================================================================
	Section: Prop Tables
==============================================================================================*/
local Props, PlayerCount, PlayerRate = { }, { }, { }

timer.Create("lemon_propcore", 1, 0, function( )
	for K, V in pairs( PlayerRate ) do
		MsgN( "Reset Player Rate for", K, V )
		PlayerRate[K] = 0
		
	end
end)

function PropCore.RemoveProp( Entity )
	if IsValid( Entity ) then pcall( Entity.Remove, Entity ) end
end

function PropCore.RemoveAll( Entity )
	if Props[Entity] then
		for K, V in pairs( Props[Entity] ) do PropCore.RemoveProp( V ) end
		Props[Entity] = nil
	end
end

function PropCore.Props( Gate )
	return Props[ Gate ]
end

function PropCore.Player( Player )
	return PlayerCount[ Player ] or 0, PlayerRate[ Player ] or 0
end

/*==============================================================================================
	Section: API Hooks
==============================================================================================*/

function Component:CreateContext( Context )
	Props[ Context.Entity ] = { }
end

function Component:Remove( Gate )
	PropCore.RemoveAll( Gate )
end

function Component:ShutDown( Gate )
	PropCore.RemoveAll( Gate )
end

/*==============================================================================================
	Section: Util
==============================================================================================*/
Component:AddException( "propcore" )

function PropCore.AddProp( Prop, G, P )
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

local _DoPropSpawnedEffect = DoPropSpawnedEffect

function PropCore.Spawn( Trace, Context, Model, Freeze )
	local G, P = Context.Entity, Context.Player
	local PRate, PCount = PlayerRate[P] or 0, PlayerCount[P] or 0
	
	local Max = PropCore.Prop_Max:GetInt( )
	
	if Max ~= -1 and PCount >= Max then
		Context:Throw(Trace, "propcore", "Max total props reached (" .. Max .. ")." )
	elseif PRate >= PropCore.Prop_Rate:GetInt( ) then
		Context:Throw(Trace, "propcore", "Max prop spawn rate reached (" ..PropCore.Prop_Rate:GetInt( ) .. ")." )
	elseif !util.IsValidModel( Model ) or !util.IsValidProp( Model ) then
		Context:Throw(Trace, "propcore", "Invalid model for prop spawn." )
	elseif Context.Data.PC_NoEffect then
		DoPropSpawnedEffect = function( ) end
	end
	
	local Prop = MakeProp( P, G:GetPos(), G:GetAngles(), Model, {}, {} )
	
	if Context.Data.PC_NoEffect then
		DoPropSpawnedEffect = _DoPropSpawnedEffect
	end
	
	if !Prop or !Prop:IsValid( ) then
		Context:Throw("propcore", "Unable to spawn prop." )
	end

	PropCore.AddProp( Prop, G, P )
	
	Prop:Activate()

	local Phys = Prop:GetPhysicsObject()
	if Phys and Phys:IsValid( ) then
		if Freeze then Phys:EnableMotion( false ) end
		Phys:Wake()
	end

	Props[ G ][ Prop ] = Prop
	PlayerRate[ P ] = PRate + 1
	PlayerCount[ P ] = PCount + 1

	return Prop
end

function PropCore.CanSpawn( Context )
	local Max = PropCore.Prop_Max:GetInt( )
	
	if Max ~= -1 and (PlayerCount[Context.Player] or 0) >= Max then
		return false;
	elseif (PlayerRate[Context.Player] or 0) >= PropCore.Prop_Rate:GetInt( ) then
		return false;
	end
	
	return true
end

/*==============================================================================================
	Section: PropCore Info
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddFunction("propcore", "", "t", [[local %Results = %Table( )
%Results:Set( "MaxProps", "n", %PropCore.Prop_Max:GetInt( ) )
%Results:Set( "MaxRate", "n", %PropCore.Prop_Rate:GetInt( ) )

local %Props, %Rate = %PropCore.Player( %context.Player )
%Results:Set("CurProps", "n", %Props)
%Results:Set("CurRate", "n", %Rate)
]], "%Results" )

Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction("spawnedProps", "", "t", [[
local %Results = %Table( )
for _, Ent in pairs( %PropCore.Props( %context.Entity ) ) do
	%Results:Insert( nil, "e", Ent )
end]], "%Results" )

/*==============================================================================================
	Section: Spawn funcs
==============================================================================================*/

Component:SetPerf( LEMON_PERF_EXPENSIVE * 2 )

Component:AddFunction("spawn", "s", "e", "%PropCore.Spawn( %trace, %context, value %1, true)" )

Component:AddFunction("spawn", "s, b", "e", "%PropCore.Spawn( %trace, %context, value %1, value %2)" )

Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction("noSpawnEffect", "b", "", "%data.PC_NoEffect = value %1", "" )

Component:AddFunction("canSpawn", "", "b", "(%PropCore.CanSpawn( %context ))" )

/*==============================================================================================
	Remove
==============================================================================================*/
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction("remove", "e:", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	%PropCore.RemoveProp(value %1 )
end]], "" )

/*==============================================================================================
    Position and angles
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddFunction("setPos", "e:v", "",[[
if $IsValid( value %1 ) and value %2:IsNotHuge( ) and %IsOwner( %context.Player, value %1 ) then
	value %1:SetPos( value %2:Garry( ) )
end]], "" )

Component:AddFunction("setAng", "e:a", "",[[
if $IsValid( value %1 ) and %AngleNotHuge( value %2 ) and %IsOwner( %context.Player, value %1 ) then
	value %1:SetAngles( value %2 )
end]], "" )

/*==============================================================================================
    Parent
==============================================================================================*/
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction("parent", "e:e", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) and $IsValid( value %2 ) then
	value %1:SetParent(value %2)
end]], "" )

Component:AddFunction("parent", "e:p", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) and $IsValid( value %2 ) then
	value %1:SetParent(value %2)
end]], "" )

/*==============================================================================================
	Section: Freeze
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddFunction("freeze", "e:b", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	local %Phys = value %1:GetPhysicsObject()
	%Phys:EnableMotion( value %2 )
	%Phys:Wake( )
end]], "" )

Component:AddFunction("freeze", "p:b", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1:GetEntity( ) ) then
	value %1:EnableMotion( value %2 )
	value %1:Wake( )
end]], "" )

/*==============================================================================================
	Section: Solidity
==============================================================================================*/
Component:AddFunction("setNotSolid", "e:b", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	value %1:SetNotSolid( value 2 )
end]], "" )

/*==============================================================================================
	Section: Gravity
==============================================================================================*/
Component:AddFunction("enableGravity", "e:b", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	local %Phys = value %1:GetPhysicsObject()
	%Phys:EnableGravity( value %2 )
	%Phys:Wake( )

	if !%Phys:IsMoveable() then
		%Phys:EnableMotion( true )
		%Phys:EnableMotion( false )
	end
end]], "" )

Component:AddFunction("enableGravity", "p:b", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1:GetEntity( ) ) then
	value %1:EnableGravity( value %2 )
	value %1:Wake( )

	if !value %1:IsMoveable( ) then
		value %1:EnableMotion( true )
		value %1:EnableMotion( false )
	end
end]], "" )

/*==============================================================================================
	Section: Properties
==============================================================================================*/
Component:AddFunction("setPhysProp", "e:s,b", "", [[
if $IsValid( value %1 ) and %IsOwner( %context.Player, value %1 ) then
	$construct.SetPhysProp( %context.Player, value %1, 0, nil, { GravityToggle = value %3, Material = value %2 } )
end]], "" )
