/*==============================================================================================
	Expression Advanced: Component -> EGP.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

/*==============================================================================================
	Section: Egp Hacks
==============================================================================================*/

local EGP = EGP

function API.EGPAction( Entity, Context, ... )
	local EMU = { player = Context.Player, entity = Context.Entity, prf = 0 }
	
	EGP:DoAction( Entity, EMU, ... )
	
	if EMU.prf > 0 then Context.Perf = Context.Perf + EMU.prf end
end

/*==============================================================================================
	Section: API Hooks
==============================================================================================*/
local Component = API:NewComponent( "egp", true )

function Component:CreateContext( Context )
	Context.Data.EGP = { }
end

function Component:UpdateContext( Context )
	for k,v in pairs( Context.Data.EGP ) do 
		if IsValid( k ) and v == true then 
			EGP:SendQueueItem( Context.Player )
			-- EGP:StartQueueTimer( Context.Player )
			Context.Data.EGP[k] = nil 
		end 
		Context.Data.EGP[k] = nil
	end 
end

/*==============================================================================================
	Section: Frames
==============================================================================================*/
Component:SetPerf( LEMON_PERF_NORMAL )

Component:AddFunction( "egpSaveFrame", "wl:s", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	if value %2 ~= "" then
		local %Bool, %Frame = EGP:LoadFrame( %context.Player, nil, value %2 )
		
		if %Bool and EGP:IsDifferent( value %1.RenderTable, %Frame ) then
			API.EGPAction( value %1, %context, "SaveFrame", value %1 )
			%data.EGP[value %1] = true
		end
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpLoadFrame", "wl:s", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	if value %2 ~= "" then
		local %Bool, %Frame = EGP:LoadFrame( %context.Player, nil, value %2 )
		
		if %Bool and EGP:IsDifferent( value %1.RenderTable, %Frame ) then
			API.EGPAction( value %1, %context, "LoadFrame", value %1 )
			%data.EGP[value %1] = true
		end
	end
end]], LEMON_NO_INLINE )

/*==============================================================================================
	Section: Order
==============================================================================================*/
Component:AddFunction( "egpOrder", "wl:n,n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	if value %2 ~= value %3 then
		local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
		if %Bool and EGP:SetOrder( value %1, %A, value %3 ) then
			API.EGPAction( value %1, %context, "SendObject", %B )
			%data.EGP[value %1] = true
		end
	end
end]], LEMON_NO_INLINE )
		
Component:AddFunction( "egpOrder", "wl:n", "n", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	if value %2 ~= value %3 then
		local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		%util = %Bool and %A or 0
	end
end]], "%util" )	

/*==============================================================================================
	Section: Box / Outline / Rounded
==============================================================================================*/
Component:AddFunction( "egpBox", "wl:n,v2,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["Box"], { index = value %2, w = value %4.x, h = value %4.y, x = value %3.x, y = value %3.y }, %context.Player )
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpBoxOutline", "wl:n,v2,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["BoxOutline"], { index = value %2, w = value %4.x, h = value %4.y, x = value %3.x, y = value %3.y }, %context.Player )
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpRoundedBox", "wl:n,v2,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["RoundedBox"], { index = value %2, w = value %4.x, h = value %4.y, x = value %3.x, y = value %3.y }, %context.Player )
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpRadius", "wl:n,n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and EGP:EditObject( %B, { radius = value %3 } ) then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpRoundedBoxOutline", "wl:n,v2,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["RoundedBoxOutline"], { index = value %2, w = value %4.x, h = value %4.y, x = value %3.x, y = value %3.y }, %context.Player )
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

/*==============================================================================================
	Section: Text
==============================================================================================*/
Component:AddFunction( "egpText", "wl:n,s,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["Text"], { index = value %2, text = value %3, x = value %4.x, y = value %4.y }, %context.Player )
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpTextLayout", "wl:n,s,v2,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["TextLayout"], { index = value %2, text = value %3, w = value %5.x, h = value %5.y, x = value %4.x, y = value %4.y }, %context.Player )
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpSetText", "wl:n,s", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and EGP:EditObject( %B, { text = value %3 } ) then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpAlign", "wl:n,n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and EGP:EditObject( %B, { halign = math.Clamp(value %3, 0, 2) } ) then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpAlign", "wl:n,n,n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and EGP:EditObject( %B, { valign = math.Clamp(value %4, 0, 2), halign = math.Clamp(value %3, 0, 2) } ) then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpFont", "wl:n,s", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool then
		local FontID = 0
		
        for K,V in ipairs( EGP.ValidFonts ) do
            if V:lower() == string.lower( value %3 ) then
                FontID = K
                break
            end
        end
		
		if EGP:EditObject( %B, { fontid = FontID } ) then
			API.EGPAction( value %1, %context, "SendObject", %B )
			%data.EGP[value %1] = true
		end
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpFont", "wl:n,s,n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool then
		local FontID = 0
		
        for K,V in ipairs( EGP.ValidFonts ) do
            if V:lower() == string.lower( value %3 ) then
                FontID = K
                break
            end
        end
		
		if EGP:EditObject( %B, { fontid = FontID, size = value %4 } ) then
			API.EGPAction( value %1, %context, "SendObject", %B )
			%data.EGP[value %1] = true
		end
	end
end]], LEMON_NO_INLINE )

/*==============================================================================================
	Section: Line
==============================================================================================*/
Component:AddFunction( "egpLine", "wl:n,v2,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["Line"], { index = value %2, x = value %3.x, y = value %3.y, x2 = value %4.x, y2 = value %4.y }, %context.Player )
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

/*==============================================================================================
	Section: Circle
==============================================================================================*/
Component:AddFunction( "egpCircle", "wl:n,v2,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["Circle"], { index = value %2, x = value %3.x, y = value %3.y, w = value %4.x, h = value %4.y }, %context.Player )
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpCircleOutline", "wl:n,v2,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["CircleOutline"], { index = value %2, x = value %3.x, y = value %3.y, w = value %4.x, h = value %4.y }, %context.Player )
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

/*==============================================================================================
	Section: Triangle
==============================================================================================*/
Component:AddFunction( "egpTriangle", "wl:n,v2,v2,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["Poly"], { index = value %2, vertices = { { x = value %3.x, y = value %3.y }, { x = value %4.x, y = value %4.y }, { x = value %5.x, y = value %5.y } } }, %context.Player )
	
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpTriangleOutline", "wl:n,v2,v2,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["PolyOutline"], { index = value %2, vertices = { { x = value %3.x, y = value %3.y }, { x = value %4.x, y = value %4.y }, { x = value %5.x, y = value %5.y } } }, %context.Player )
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

/*==============================================================================================
	Section: Wedge
==============================================================================================*/
Component:AddFunction( "egpWedge", "wl:n,v2,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["Wedge"], { index = value %2, x = value %3.x, y = value %3.y, w = value %4.x, h = value %4.y }, %context.Player )
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpWedgeOutline", "wl:n,v2,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["WedgeOutline"], { index = value %2, x = value %3.x, y = value %3.y, w = value %4.x, h = value %4.y }, %context.Player )
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

/*==============================================================================================
	Section: Poly
==============================================================================================*/
Component:AddFunction( "egpPoly", "wl:n,...", "", [[
if $EGP:ValidEGP( value %1 ) and #{%...} >= 3 then //and %IsOwner( %context.Player, value %1 ) then
	local Vertices, I = { }, 0
	local Max = EGP.ConVars.MaxVertices:GetInt( )
	
	for _, Data in pairs( { %... } ) do
		local Var, Type = Data[1], Data[2]
		
		if I > Max then
			break
		elseif Type == "xv2" then
			I = I + 1
			Vertices[ I ] = { x = Var.x, y= Var.y }
		end
	end
	
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["Poly"], { index = value %2, vertices = Vertices }, %context.Player )
	
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpPoly", "wl:n,xxv2*", "", [[
if $EGP:ValidEGP( value %1 ) and #value %3 >= 3 then //and %IsOwner( %context.Player, value %1 ) then
	local Vertices, I = { }, 0
	local Max = EGP.ConVars.MaxVertices:GetInt( )
	
	for _, Data in pairs( value %3 ) do
		if I > Max then
			break
		else
			I = I + 1
			Vertices[ I ] = { x = Data.x, y= Data.y }
		end
	end
	
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["Poly"], { index = value %2, vertices = Vertices }, %context.Player )
	
	if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpPolyOutline", "wl:n,...", "", [[
if $EGP:ValidEGP( value %1 ) and #{%...} >= 3 then //and %IsOwner( %context.Player, value %1 ) then
	local Vertices, I = { }, 0
	local Max = EGP.ConVars.MaxVertices:GetInt( )
	
	for _, Data in pairs( { %... } ) do
		local Var, Type = Data[1], Data[2]
		
		if I > Max then
			break
		elseif Type == "xv2" then
			I = I + 1
			Vertices[ I ] = { x = Var.x, y= Var.y }
		end
	end
	
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["PolyOutline"], { index = value %2, vertices = Vertices }, %context.Player )
	
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpPolyOutline", "wl:n,xxv2*", "", [[
if $EGP:ValidEGP( value %1 ) and #value %3 >= 3 then //and %IsOwner( %context.Player, value %1 ) then
	local Vertices, I = { }, 0
	local Max = EGP.ConVars.MaxVertices:GetInt( )
	
	for _, Data in pairs( value %3 ) do
		if I > Max then
			break
		else
			I = I + 1
			Vertices[ I ] = { x = Data.x, y= Data.y }
		end
	end
	
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["PolyOutline"], { index = value %2, vertices = Vertices }, %context.Player )
	
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpPolyUV", "wl:n,...", "", [[
if $EGP:ValidEGP( value %1 ) then 
	local %bool, _, %object = EGP:HasObject( value %1, value %2 )
	if %bool and #{%...} >= 3 then 
		
		local Vertices = { } //%object.vertices or { }
		for i, v in ipairs( {%...} ) do
			if i > #%object.vertices then break end 
			Vertices[i] = { }
			Vertices[i].x = %object.vertices[i].x
			Vertices[i].y = %object.vertices[i].y
			Vertices[i].u = v[1].x
			Vertices[i].v = v[1].y
		end
		
		if EGP:EditObject( %object, { vertices = Vertices } ) then
			EGP:InsertQueue( value %1, Context.Player, EGP._SetVertex, "SetVertex", value %2, Vertices, true )
			%data.EGP[value %1] = true
		end
	end 
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpPolyUV", "wl:n,xxv2*", "", [[
if $EGP:ValidEGP( value %1 ) then 
	local %bool, _, %object = EGP:HasObject( value %1, value %2 )
	if %bool and #value %3 >= 3 then 
		
		local Vertices = { } //%object.vertices or { }
		for i, v in ipairs( value %3 ) do
			if i > #%object.vertices then break end 
			Vertices[i] = { }
			Vertices[i].x = %object.vertices[i].x
			Vertices[i].y = %object.vertices[i].y
			Vertices[i].u = v.x
			Vertices[i].v = v.y
		end
		
		if EGP:EditObject( %object, { vertices = Vertices } ) then
			EGP:InsertQueue( value %1, Context.Player, EGP._SetVertex, "SetVertex", value %2, Vertices, true )
			%data.EGP[value %1] = true
		end
	end 
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpLineStrip", "wl:n,...", "", [[
if $EGP:ValidEGP( value %1 ) and #{%...} >= 3 then //and %IsOwner( %context.Player, value %1 ) then
	local Vertices, I = { }, 0
	local Max = EGP.ConVars.MaxVertices:GetInt( )
	
	for _, Data in pairs( { %... } ) do
		local Var, Type = Data[1], Data[2]
		
		if I > Max then
			break
		elseif Type == "xv2" then
			I = I + 1
			Vertices[ I ] = { x = Var.x, y = Var.y }
		end
	end
	
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["LineStrip"], { index = value %2, vertices = Vertices }, %context.Player )
	
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], "" )

Component:AddFunction( "egpLineStrip", "wl:n,xxv2*", "", [[
if $EGP:ValidEGP( value %1 ) and #value %3 >= 3 then //and %IsOwner( %context.Player, value %1 ) then
	local Vertices, I = { }, 0
	local Max = EGP.ConVars.MaxVertices:GetInt( )
	
	for _, Data in pairs( value %3 ) do
		if I > Max then
			break
		else
			I = I + 1
			Vertices[ I ] = { x = Data.x, y = Data.y }
		end
	end
	
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["LineStrip"], { index = value %2, vertices = Vertices }, %context.Player )
	
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], "" )

/*============================================================================================================================================
	Section: Vertices
============================================================================================================================================*/
Component:AddFunction( "egpSetVertices", "wl:n,xxv2*", "", [[
if $EGP:ValidEGP( value %1 ) then 
	local %bool, _, %object = EGP:HasObject( value %1, value %2 )
	if %bool and #value %3 >= 3 then 
		local Max = EGP.ConVars.MaxVertices:GetInt( )
		
		local Vertices, I = { }, 0
		for _, Data in pairs( value %3 ) do
			if I > Max then
				break
			else
				I = I + 1
				Vertices[ I ] = { x = Data.x, y = Data.y }
			end
		end
		
		if EGP:EditObject( %object, { vertices = Vertices } ) then
			EGP:InsertQueue( value %1, Context.Player, EGP._SetVertex, "SetVertex", value %2, Vertices, true )
			%data.EGP[value %1] = true
		end
	end 
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpVertices", "wl:n", "xxv2*", [[
if $EGP:ValidEGP( value %1 ) then 
	local %bool, _, %object = EGP:HasObject( value %1, value %2 )
	if %bool then
		if %object.vertices then 
			%util = { } 
			for i, v in ipairs( %object.vertices ) do
				%util[i] = Vector2( v.x, v.y ) 
			end
		elseif %object.x and %object.y and %object.x2 and %object.y2 and %object.x3 and %object.y3 then 
			%util = { Vector2( %object.x, %object.y ), Vector2( %object.x2, %object.y2 ), Vector2( %object.x3, %object.y3 ) }
		elseif %object.x and %object.y and %object.x2 and %object.y2 then 
			%util = { Vector2( %object.x, %object.y ), Vector2( %object.x2, %object.y2 ) }
		end 
	end
end]], "(%util or {})" )

Component:AddFunction( "egpGlobalPos", "wl:n", "v", [[
if $EGP:ValidEGP( value %1 ) then 
	local %bool, _, %object = EGP:HasObject( value %1, value %2 )
	if %bool then
		local %hasvertices, %posang = EGP:GetGlobalPos( value %1, value %2 )
		if %hasvertices then 
			%util = Vector3( %posang.x, %posang.y, %posang.angle )
		end
	end 
end]], "(%util or Vector3())" )

Component:AddFunction( "egpGlobalVertices", "wl:n", "xxv2*", [[
if $EGP:ValidEGP( value %1 ) then 
	local %bool, _, %object = EGP:HasObject( value %1, value %2 )
	if %bool then
		local %hasvertices, %posang = EGP:GetGlobalPos( value %1, value %2 )
		if %hasvertices then 
			if %object.vertices then 
				%util = { } 
				for i, v in ipairs( %object.vertices ) do
					%util[i] = Vector2( v.x, v.y ) 
				end
			elseif %object.x and %object.y and %object.x2 and %object.y2 and %object.x3 and %object.y3 then 
				%util = { Vector2( %object.x, %object.y ), Vector2( %object.x2, %object.y2 ), Vector2( %object.x3, %object.y3 ) }
			elseif %object.x and %object.y and %object.x2 and %object.y2 then 
				%util = { Vector2( %object.x, %object.y ), Vector2( %object.x2, %object.y2 ) }
			end 
		end
	end 
end]], "(%util or {})" )

/*==============================================================================================
	Section: 3D Tracker
==============================================================================================*/
Component:AddFunction( "egp3DTracker", "wl:n,v", "", [[ 
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["3DTracker"], { index = value %2, target_x = value %3.x, target_x = value %3.y, target_x = value %3.z }, %context.Player )
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE ) -- Was v2 but made no sense

Component:AddFunction( "egpPos", "wl:n,v", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and EGP:EditObject( %B, { target_x = value %3.x, target_y = value %3.y, target_z = value %3.z } ) then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE ) -- Was v2 but made no sense

/*==============================================================================================
	Section: Set Functions
==============================================================================================*/
Component:AddFunction( "egpSize", "wl:n,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and EGP:EditObject( %B, { w = value %3.x, h = value %3.y } ) then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )


Component:AddFunction( "egpSize", "wl:n,n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and EGP:EditObject( %B, { size = value %3 } ) then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpPos", "wl:n,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and EGP:EditObject( %B, { x = value %3.x, y = value %3.y } ) then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

----------------------------
-- Angle
----------------------------

Component:AddFunction( "egpAngle", "wl:n,n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and EGP:EditObject( %B, { angle = value %3 } ) then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpAngle", "wl:n,v2,v2,n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and %B.x and %B.y then
		
		local %Vec, %Ang = $LocalToWorld(Vector(value %4.x,value %4.y,0), Angle(0,0,0), Vector(value %3.x,value %3.y,0), Angle(0,-value %5,0))
		local %T = { x = %Vec.x, y = %Vec.y }
		
		if %B.angle then
			%T.angle = -%Ang.yaw
		end
		
		if EGP:EditObject( %B, %T ) then
			API.EGPAction( value %1, %context, "SendObject", %B )
			%data.EGP[value %1] = true
		end
	end
end]], LEMON_NO_INLINE )


----------------------------
-- Color
----------------------------
Component:AddFunction( "egpColor", "wl:n,c", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and EGP:EditObject( %B, { r = value %3[1], g = value %3[2], b = value %3[3], a = value %3[4] } ) then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpAlpha", "wl:n,n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and EGP:EditObject( %B, { a = value %3 } ) then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

----------------------------
-- Material
----------------------------
Component:AddFunction( "egpMaterial", "wl:n,s", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and EGP:EditObject( %B, { material = value %3 } ) then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )



Component:AddFunction( "egpMaterialFromScreen", "wl:n,e", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and $IsValid( value %3 ) then
		if EGP:EditObject( %B, { material = value %3 } ) then
			API.EGPAction( value %1, %context, "SendObject", %B )
			%data.EGP[value %1] = true
		end
	end
end]], LEMON_NO_INLINE )

----------------------------
-- Fidelity (number of corners for circles and wedges)
----------------------------
Component:AddFunction( "egpFidelity", "wl:n,n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and EGP:EditObject( %B, { fidelity = math.Clamp(value %3, 3, 180) } ) then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

----------------------------
-- Parenting
----------------------------
Component:AddFunction( "egpParent", "wl:n,n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %B = EGP:SetParent( value %1, value %2, value %3 )
		
	if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

-- Entity parenting (only for 3Dtracker - does nothing for any other object)
Component:AddFunction( "egpParent", "wl:n,e", "", [[
if $IsValid( value %3 ) and $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and %B.Is3DTracker then
		if %B.parententity ~= value %3 then
			%B.parententity = value %3
			API.EGPAction( value %1, %context, "SendObject", %B )
			%data.EGP[value %1] = true
		end
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpUnParent", "wl:n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %B = EGP:UnParent( value %1, value %2 )
		
	if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpParentToCursor", "wl:n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %B = EGP:SetParent( value %1, value %2, -1 )

	if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

/*==============================================================================================
	Section: Clear / Remove
==============================================================================================*/
Component:AddFunction( "egpClear", "wl:", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	API.EGPAction( value %1, %context, "ClearScreen" )
	%data.EGP[value %1] = true
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpRemove", "wl:n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool = EGP:HasObject( value %1, value %2 )
	if %Bool then
		API.EGPAction( value %1, %context, "RemoveObject", value %2 )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

-- Doesn't work
Component:AddFunction( "egpCopy", "wl:n,n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %3 )
	if %Bool then
		local %copy = $table.Copy( %B )
		%copy.index = value %2

		local %Bool2, %Obj = EGP:CreateObject( value %1, %B.ID, %copy, %context.Player )
		if %Bool2 then
			API.EGPAction( value %1, %context, "SendObject", %Obj )
			%data.EGP[value %1] = true
		end
	end
end]], LEMON_NO_INLINE )

-- Component:AddFunction( "egpCopy", "wl:nn", "", function( self, ValueA, ValueB, ValueC ) 
    -- local value %1, tValueA = ValueA( self )
    -- local index, tValueB = ValueB( self )
    -- local fromindex, tValueC = ValueC( self )

    -- if (!CanUseEGP( self, value %1 )) then return end
    -- local bool, k, v = EGP:HasObject( value %1, fromindex )
    -- if (bool) then
        -- local copy = table.Copy( v )
        -- copy.index = index
        -- local bool2, obj = EGP:CreateObject( value %1, v.ID, copy, %context.Player )
        -- if (bool2) then EGP:DoAction( value %1, { player = %context.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,value %1) end
    -- end
-- end )

/*==============================================================================================
	Section: Screen Settings and Information
==============================================================================================*/
Component:AddFunction( "egpDrawTopLeft", "wl:b", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	API.EGPAction( value %1, %context, "MoveTopLeft", value %2 )
	%data.EGP[value %1] = true
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpResolution", "wl:v2,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %xScale = { value %2.x, value %3.x }
	local %yScale = { value %2.y, value %3.y }
	
	local %xMul = %xScale[2] - %xScale[1]
	local %yMul = %yScale[2] - %yScale[1]
	if %xMul == 0 or %yMul == 0 then error("Invalid EGP scale") end

	API.EGPAction( value %1, %context, "SetScale", %xScale, %yScale )
	%data.EGP[value %1] = true
end]], LEMON_NO_INLINE )

-- Might not be correct
Component:AddFunction( "egpScale", "wl:v2,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %xScale = { value %2.x, value %2.y }
	local %yScale = { value %3.x, value %3.y }

	local %xMul = %xScale[2] - %xScale[1]
	local %yMul = %yScale[2] - %yScale[1]
	if %xMul == 0 or %yMul == 0 then error("Invalid EGP scale") end

	API.EGPAction( value %1, %context, "SetScale", %xScale, %yScale)
	%data.EGP[value %1] = true
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpScrSize", "e", "v2", "( ($IsValid(value %1) and value %1:IsPlayer( )) and Vector2($EGP.ScrHW[value %1][1], EGP.ScrHW[value %1][2]) or Vector2(-1,-1))" )
Component:AddFunction( "egpScrH", "e", "n", "( ($IsValid(value %1) and value %1:IsPlayer( )) and $EGP.ScrHW[value %1][2] or -1)" )
Component:AddFunction( "egpScrW", "e", "n", "( ($IsValid(value %1) and value %1:IsPlayer( )) and $EGP.ScrHW[value %1][1] or -1)" )

/*==============================================================================================
	Section: Convars
==============================================================================================*/
Component:AddFunction( "egpCanSendUmsg", "", "b", "$EGP:CheckInterval( %context, true )" )
Component:AddFunction( "egpMaxUmsgPerSecond", "", "n", "$EGP.ConVars.MaxPerSec:GetInt()" )
Component:AddFunction( "egpMaxObjects", "", "n", "$EGP.ConVars.MaxObjects:GetInt()" )

Component:AddFunction( "egpNumObjects", "wl:", "n", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	%util = #value %1.RenderTable or 0
end]], "%util")

Component:AddFunction( "egpHasObject", "wl:n", "b", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	%util = EGP:HasObject( value %1, value %2 )
end]], "%util")

/*==============================================================================================
	Section: Cursor
==============================================================================================*/
Component:AddFunction( "egpCursor", "wl:e", "v2", "local %V = $EGP:EGPCursor( value %1, value %2 )", "Vector2(%V[1],%V[2])" )

/*==============================================================================================
	Section: Get Functions
==============================================================================================*/
Component:AddFunction( "egpAngle", "wl:n", "n", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = $EGP:HasObject( value %1, value %2 )
	%util = (%Bool and %B.angle) and %B.angle or -1
end]], "%util" )

Component:AddFunction( "egpFidelity", "wl:n", "n", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
	%util = (%Bool and %B.fidelity) and %B.fidelity or 0
end]], "%util" )

Component:AddFunction( "egpPos", "wl:n", "v2", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = $EGP:HasObject( value %1, value %2 )
	%util = (%Bool and Vector2(%B.x, %B.y)) and Vector2(%B.x, %B.y) or Vector2(-1,-1)
end]], "%util" )

Component:AddFunction( "egpRadius", "wl:n", "n", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = $EGP:HasObject( value %1, value %2 )
	%util = (%Bool and %B.radius) and %B.radius or -1
end]], "%util" )

Component:AddFunction( "egpSize", "wl:n", "v2", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = $EGP:HasObject( value %1, value %2 )
	%util = (%Bool and Vector2(%B.w, %B.h)) and Vector2(%B.w, %B.h) or Vector2(-1,-1)
end]], "%util" )

Component:AddFunction( "egpSizeNum", "wl:n", "n", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = $EGP:HasObject( value %1, value %2 )
	%util = (%Bool and %B.size) and %B.size or -1
end]], "%util" )

----------------------------
-- Color
----------------------------
Component:AddFunction( "egpColor", "wl:n", "c", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = $EGP:HasObject( value %1, value %2 )
	%util = (%Bool and %B.r and %B.g and %B.b and %B.a) and { %B.r, %B.g, %B.b, %B.a } or {-1, -1, -1, -1}
end]], "%util" )

Component:AddFunction( "egpAlpha", "wl:n", "n", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = $EGP:HasObject( value %1, value %2 )
	%util = (%Bool and %B.a) and %B.a or -1
end]], "%util" )

----------------------------
-- Material
----------------------------
Component:AddFunction( "egpMaterial", "wl:n", "s", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = $EGP:HasObject( value %1, value %2 )
	%util = (%Bool and %B.material) and %B.material or ""
end]], "%util" )

----------------------------
-- Parent
----------------------------
Component:AddFunction( "egpParent", "wl:n", "n", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = $EGP:HasObject( value %1, value %2 )
	%util = (%Bool and %B.parent) and %B.parent or 0
end]], "%util" )

Component:AddFunction( "egpTrackerParent", "wl:n", "e", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = $EGP:HasObject( value %1, value %2 )
	if %Bool and %B.Is3DTracker then
		%util = (%B.parententity and %B.parententity:IsValid()) and %B.parententity or nil
	end
end]], "%util" )


/* 
Still Need:

egpToWorld
egpHudToggle
*/
