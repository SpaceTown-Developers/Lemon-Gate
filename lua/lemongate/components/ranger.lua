/*==============================================================================================
	Expression Advanced: Ranger, Based on E2
	Creditors: Rusketh, E2 authors
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Component = API:NewComponent( "ranger", true )

local Bor = bit.bor
local IsValid = IsValid
local TraceHull, TraceLine = util.TraceHull, util.TraceLine

/*==============================================================================================
	Section: Ranger Class
==============================================================================================*/
local Ranger = { Default_Zero = false, Ignore_World = false, Hit_Water = false, Ignore_Entities = false }
Ranger.Result = { }

Ranger.__index = Ranger

setmetatable( Ranger, Ranger )

function Ranger.__call(  )
	return setmetatable( { Filter = { } }, Ranger )
end

function Ranger:Filter( Entity )
	if IsValid( Entity ) then
		self.Filter[ Entity ] = true
	end
end

function Ranger:Unfilter( Entity )
	if IsValid( Entity ) then
		self.Filter[ Entity ] = nil
	end
end

function Ranger:DoTrace( Start, End, Distance )
	if Distance then
		End = Start + ( End:GetNormalized( ) * Distance )
	end
	
	self.Start = Start
	self.End = End
	
	local Filter = { }
	local Ignore_World = self.Ignore_World
	local TraceData = { start = Start, endpos = End, filter = Filter }
	
	for Entity, _ in pairs( self.Filter ) do
		Filter[ #Filter + 1 ] = Entity
	end
	
	if self.Hit_Water then
		if self.Ignore_Entities then
			TraceData.mask = -1
		elseif Ignore_World then
			Ignore_World = false
			TraceData.mask = MASK_WATER
		else
			TraceData.mask = Bor( MASK_WATER, CONTENTS_SOLID )
		end
	elseif !self.Ignore_Entities then
		if Ignore_World then
			Ignore_World = false
			TraceData.mask = 0
		else
			TraceData.mask = MASK_NPCWORLDSTATIC
		end
	end
	
	local Trace
	
	if self.Mins and self.Maxs then
		TraceData.mins = self.Mins
		TraceData.maxs = self.Maxs
		
		Trace = TraceHull( TraceData )
	else
		Trace = TraceLine( TraceData )
	end
	
	if Ignore_World and Trace.HitWorld then
		Trace.HitPos = self.Default_Zero and Start or End
		Trace.HitWorld = false
		Trace.Hit = false
	elseif self.Default_Zero and !Trace.Hit then
		Trace.HitPos = Start
	end
	
	self.Result = Trace
end

function Ranger.__tostring( Table )
	return "Ranger"
end

Component:AddExternal( "Ranger", Ranger )

/*==============================================================================================
	Section: Class
==============================================================================================*/

local Class = Component:NewClass( "rd", "ranger" )

Component:SetPerf( LEMON_PERF_NORMAL )

-- Create a ranger object
Component:AddFunction( "ranger", "", "rd", "%Ranger( )", LEMON_INLINE_ONLY )

-- Set up a ranger.
Component:AddFunction( "ignoreEntities", "rd:b", "", "value %1.Ignore_Entities = value %2", LEMON_PREPARE_ONLY )

Component:AddFunction( "defaultZero", "rd:b", "", "value %1.Default_Zero = value %2", LEMON_PREPARE_ONLY )

Component:AddFunction( "ignoreWorld", "rd:b", "", "value %1.Ignore_World = value %2", LEMON_PREPARE_ONLY )

Component:AddFunction( "hitWater", "rd:b", "", "value %1.Hit_Water = value %2", LEMON_PREPARE_ONLY )

-- Get
Component:AddFunction( "ignoreEntities", "rd:", "", "value %1.Ignore_Entities", LEMON_INLINE_ONLY )

Component:AddFunction( "defaultZero", "rd:", "", "value %1.Default_Zero", LEMON_INLINE_ONLY )

Component:AddFunction( "ignoreWorld", "rd:", "", "value %1.Ignore_World", LEMON_INLINE_ONLY )

Component:AddFunction( "hitWater", "rd:", "", "value %1.Hit_Water", LEMON_INLINE_ONLY )


-- Hull Trace
Component:AddFunction( "setHull", "rd:v,v", "", [[
	value %1.Mins = value %2:Garry( )
	value %1.Maxs = value %3:Garry( )
]], LEMON_PREPARE_ONLY )

Component:AddFunction( "noHull", "rd:", "", [[
	value %1.Mins = nil
	value %1.Maxs = nil
]], LEMON_PREPARE_ONLY )

Component:AddFunction( "mins", "rd:", "", "( value %1.Mins or Vector3( 0, 0, 0 ) )", LEMON_INLINE_ONLY )

Component:AddFunction( "maxs", "rd:", "", "( value %1.Maxs or Vector3( 0, 0, 0 ) )", LEMON_INLINE_ONLY )

-- Do Trace

Component:SetPerf( LEMON_PERF_EXPENSIVE )

Component:AddFunction( "fire", "rd:v,v", "", "value %1:DoTrace( value %2:Garry( ), value %3:Garry( ) )", LEMON_PREPARE_ONLY )

Component:AddFunction( "fire", "rd:v,v,n", "", "value %1:DoTrace( value %2:Garry( ), value %3:Garry( ), value %4 )", LEMON_PREPARE_ONLY )

Component:AddFunction( "fire", "rd:", "", [[
if ( value %1.Start and value %1.End ) then
	value %1:DoTrace( value %1.Start, value %1.End )
end]], LEMON_PREPARE_ONLY )

-- Start and End

Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction( "start", "rd:", "v", "Vector3( value %1.Start or Vector( 0, 0, 0 ) )", LEMON_INLINE_ONLY )

Component:AddFunction( "end", "rd:", "v", "Vector3( value %1.End or Vector( 0, 0, 0 ) )", LEMON_INLINE_ONLY )

-- Filter

Component:SetPerf( LEMON_PERF_ABNORMAL )

Component:AddFunction( "filter", "rd:e", "", "value %1:Filter( value %2 )", LEMON_PREPARE_ONLY )

Component:AddFunction( "unfilter", "rd:e", "", "value %1:Unfilter( value %2 )", LEMON_PREPARE_ONLY )

Component:AddFunction( "clearFilter", "rd:e", "", "value %1.Filter = { }", LEMON_PREPARE_ONLY )

-- Results:

Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction( "entity", "rd:", "e", "( value %1.Result.Entity or %NULL_ENTITY )", LEMON_INLINE_ONLY )

-- Boolean
	Component:AddFunction( "hit", "rd:", "b", "( value %1.Result.Hit or false )", LEMON_INLINE_ONLY )

	Component:AddFunction( "hitSky", "rd:", "b", "( value %1.Result.HitSky or false )", LEMON_INLINE_ONLY )
	
	Component:AddFunction( "hitNoDraw", "rd:", "b", "( value %1.Result.HitNoDraw or false )", LEMON_INLINE_ONLY )

	Component:AddFunction( "hitWorld", "rd:", "b", "( value %1.Result.HitWorld or false )", LEMON_INLINE_ONLY )

	Component:AddFunction( "hitNoneWorld", "rd:", "b", "( value %1.Result.HitNonWorld or false )", LEMON_INLINE_ONLY )
	
	Component:AddFunction( "startSolid", "rd:", "b", "( value %1.Result.StartSolid or false )", LEMON_INLINE_ONLY )

-- Vector
	Component:AddFunction( "hitPos", "rd:", "v", "Vector3( value %1.Result.HitPos or Vector( 0, 0, 0 ) )", LEMON_INLINE_ONLY )

	Component:AddFunction( "hitNormal", "rd:", "v", "Vector3( value %1.Result.HitNormal or Vector( 0, 0, 0 ) )", LEMON_INLINE_ONLY )

	Component:AddFunction( "normal", "rd:", "v", "Vector3( value %1.Result.Normal or Vector( 0, 0, 0 ) )", LEMON_INLINE_ONLY )

-- Number
	
	Component:AddFunction( "fraction", "rd:", "n", "( value %1.Result.Fraction or 0 )", LEMON_INLINE_ONLY )
	
	Component:AddFunction( "fractionLeftSolid", "rd:", "n", "( value %1.Result.FractionLeftSolid or 0 )", LEMON_INLINE_ONLY )
	
	Component:AddFunction( "hitGroup", "rd:", "n", "( value %1.Result.HitGroup or 0 )", LEMON_INLINE_ONLY )
	
	Component:AddFunction( "hitBox", "rd:", "n", "( value %1.Result.HitBox or 0 )", LEMON_INLINE_ONLY )
	
	Component:AddFunction( "hitPhysics", "rd:", "n", "( value %1.Result.PhysicsBone or 0 )", LEMON_INLINE_ONLY )
	
	Component:AddFunction( "hitBoxbone", "rd:", "n", "( value %1.Result.HitBoxBone or 0 )", LEMON_INLINE_ONLY )
	
	Component:AddFunction( "materialType", "rd:", "n", "( value %1.Result.MatType or 0 )", LEMON_INLINE_ONLY )
	
-- String
	
	Component:AddFunction( "hitTexture", "rd:", "s", "( value %1.Result.HitTexture or \"\" )", LEMON_INLINE_ONLY )

-- Clear

Component:AddFunction( "clear", "rd:", "", "value %1.Result = nil", LEMON_PREPARE_ONLY )
