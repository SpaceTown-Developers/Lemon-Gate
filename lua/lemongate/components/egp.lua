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
	print( "ACTION:", ... )
	
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
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["TextLayout"], { index = value %2, text = value %3, w = value %4.x, h = value %4.y, x = value %5.x, y = value %5.y }, %context.Player )
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
		
	if %Bool and EGP:EditObject( %B, { valign = math.Clamp(value %2, 0, 2), halign = math.Clamp(value %4, 0, 2) } ) then
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
            if V:lower() == value %3:lower( )) then
                FontID = K
                break
            end
        end
		
		if EGP:EditObject( V, { fontid = FontID } ) then
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
            if V:lower() == value %3:lower( )) then
                FontID = K
                break
            end
        end
		
		if EGP:EditObject( V, { fontid = FontID, size = value %4 } ) then
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
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["Triangle"], { index = value %2, x = value %3.x, y = value %3.y, x2 = value %4.x, y2 = value %4.y, x3 = value %4.x, y3 = value %4.y }, %context.Player )
    if %Bool then
		API.EGPAction( value %1, %context, "SendObject", %Obj )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpTriangleOutline", "wl:n,v2,v2,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %Obj = EGP:CreateObject( value %1, EGP.Objects.Names["TriangleOutline"], { index = value %2, x = value %3.x, y = value %3.y, x2 = value %4.x, y2 = value %4.y, x3 = value %4.x, y3 = value %4.y }, %context.Player )
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
		
	if %Bool and EGP:EditObject( v, { target_x = value %3.x, target_y = value %3.y, target_z = value %3.z } ) then
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
		
	if %Bool and EGP:EditObject( v, { w = value %3.x, h = value %3.y } ) then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )


Component:AddFunction( "egpSize", "wl:n,n", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and EGP:EditObject( v, { size = value %3 } ) then
		API.EGPAction( value %1, %context, "SendObject", %B )
		%data.EGP[value %1] = true
	end
end]], LEMON_NO_INLINE )

Component:AddFunction( "egpPos", "wl:n,v2", "", [[
if $EGP:ValidEGP( value %1 ) then //and %IsOwner( %context.Player, value %1 ) then
	local %Bool, %A, %B = EGP:HasObject( value %1, value %2 )
		
	if %Bool and EGP:EditObject( v, { x = value %3.x, y = value %3.y } ) then
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


/*

-- Returns the entity a tracker is parented to
Component:AddFunction( "egpTrackerParent", "wl:n", "e", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( value %1, index )
    if bool and v.Is3DTracker then
        return (v.parententity and v.parententity:IsValid()) and v.parententity or nil
    end
end )

Component:AddFunction( "egpParentToCursor", "wl:n", "", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    if (!CanUseEGP( self, value %1 )) then return end
    local bool, v = EGP:SetParent( value %1, index, -1 )
    if (bool) then EGP:DoAction( value %1, { player = %context.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,value %1) end
end )

Component:AddFunction( "egpUnParent", "wl:n", "", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    if (!CanUseEGP( self, value %1 )) then return end
    local bool, v = EGP:UnParent( value %1, index )
    if (bool) then EGP:DoAction( value %1, { player = %context.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,value %1) end
end )

Component:AddFunction( "egpParent", "wl:n", "n", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( value %1, index )
    if (bool) then
        if (v.parent) then
            return v.parent
        end
    end
    return 0
end )

--------------------------------------------------------
-- Clear & Remove
--------------------------------------------------------
Component:AddFunction( "egpClear", "wl:", "", function( self, ValueA ) 
    local value %1, tValueA = ValueA( self )

    if (!CanUseEGP( self, value %1 )) then return end
    if (EGP:ValidEGP( value %1 )) then
        EGP:DoAction( value %1, { player = %context.Player, entity = self.Entity, prf = 0 }, "ClearScreen" )
        Update(self,value %1)
    end
end )

Component:AddFunction( "egpRemove", "wl:n", "", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    if (!CanUseEGP( self, value %1 )) then return end
    local bool, k, v = EGP:HasObject( value %1, index )
    if (bool) then
        EGP:DoAction( value %1, { player = %context.Player, entity = self.Entity, prf = 0 }, "RemoveObject", index )
        Update(self,value %1)
    end
end )

--------------------------------------------------------
-- Get functions
--------------------------------------------------------

EA:SetCost(EA_COST_CHEAP)

Component:AddFunction( "egpPos", "wl:n", "v2", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( value %1, index )
    if (bool) then
        if (v.x and v.y) then
            return {v.x, v.y}
        end
    end
    return {-1,-1}
end )

EA:SetCost(EA_COST_CHEAP)

Component:AddFunction( "egpSize", "wl:n", "v2", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( value %1, index )
    if (bool) then
        if (v.w and v.h) then
            return {v.w, v.h}
        end
    end
    return {-1,-1}
end )

Component:AddFunction( "egpSizeNum", "wl:n", "n", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( value %1, index )
    if (bool) then
        if (v.size) then
            return v.size
        end
    end
    return -1
end )

Component:AddFunction( "egpColor", "wl:n", "c", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( value %1, index )
    if (bool) then
        if (v.r and v.g and v.b and v.a) then
            return {v.r,v.g,v.b,v.a}
        end
    end
    return {-1,-1,-1,-1}
end )

Component:AddFunction( "egpAlpha", "wl:n", "n", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( value %1, index )
    if (bool) then
        if (v.a) then
            return v.a
        end
    end
    return -1
end )

Component:AddFunction( "egpAngle", "wl:n", "n", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( value %1, index )
    if (bool) then
        if (v.angle) then
            return v.angle
        end
    end
    return -1
end )

Component:AddFunction( "egpMaterial", "wl:n", "s", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( value %1, index )
    if (bool) then
        if (v.material) then
            return v.material
        end
    end
    return ""
end )

Component:AddFunction( "egpRadius", "wl:n", "n", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( value %1, index )
    if (bool) then
        if (v.radius) then
            return v.radius
        end
    end
    return -1
end )


--------------------------------------------------------
-- Additional Functions
--------------------------------------------------------

EA:SetCost(1.5)

Component:AddFunction( "egpCopy", "wl:nn", "", function( self, ValueA, ValueB, ValueC ) 
    local value %1, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local fromindex, tValueC = ValueC( self )

    if (!CanUseEGP( self, value %1 )) then return end
    local bool, k, v = EGP:HasObject( value %1, fromindex )
    if (bool) then
        local copy = table.Copy( v )
        copy.index = index
        local bool2, obj = EGP:CreateObject( value %1, v.ID, copy, %context.Player )
        if (bool2) then EGP:DoAction( value %1, { player = %context.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,value %1) end
    end
end )

EA:SetCost(2)

Component:AddFunction( "egpCursor", "wl:e", "v2", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local ply, tValueB = ValueB( self )

    return EGP:EGPCursor( value %1, ply )
end )

EA:SetCost(EA_COST_NORMAL)

Component:AddFunction( "egpScrSize", "e", "v2", function( self, ValueA ) 
    local ply, tValueA = ValueA( self )

    if (!ply or !ply:IsValid() or !ply:IsPlayer() or !EGP.ScrHW[ply]) then return {-1,-1} end
    return EGP.ScrHW[ply]
end )

Component:AddFunction( "egpScrW", "e", "n", function( self, ValueA ) 
    local ply, tValueA = ValueA( self )

    if (!ply or !ply:IsValid() or !ply:IsPlayer() or !EGP.ScrHW[ply]) then return -1 end
    return EGP.ScrHW[ply][1]
end )

Component:AddFunction( "egpScrH", "e", "n", function( self, ValueA ) 
    local ply, tValueA = ValueA( self )

    if (!ply or !ply:IsValid() or !ply:IsPlayer() or !EGP.ScrHW[ply]) then return -1 end
    return EGP.ScrHW[ply][2]
end )

EA:SetCost(1.5)

Component:AddFunction( "egpHasObject", "wl:n", "n", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, _, _ = EGP:HasObject( value %1, index )
    return bool and 1 or 0
end )

EA:SetCost(EA_COST_NORMAL)

local function errorcheck( x, y )
    local xMul = x[2]-x[1]
    local yMul = y[2]-y[1]
    if (xMul == 0 or yMul == 0) then error("Invalid EGP scale") end
end

Component:AddFunction( "egpScale", "wl:v2v2", "", function( self, ValueA, ValueB, ValueC ) 
    local value %1, tValueA = ValueA( self )
    local xScale, tValueB = ValueB( self )
    local yScale, tValueC = ValueC( self )

    if (!CanUseEGP( self, value %1 )) then return end
    errorcheck(xScale,yScale)
    EGP:DoAction( value %1, { player = %context.Player, entity = self.Entity, prf = 0 }, "SetScale", xScale, yScale )
end )

Component:AddFunction( "egpResolution", "wl:v2v2", "", function( self, ValueA, ValueB, ValueC ) 
    local value %1, tValueA = ValueA( self )
    local topleft, tValueB = ValueB( self )
    local bottomright, tValueC = ValueC( self )

    if (!CanUseEGP( self, value %1 )) then return end
    local xScale = { topleft[1], bottomright[1] }
    local yScale = { topleft[2], bottomright[2] }
    errorcheck(xScale,yScale)
    EGP:DoAction( value %1, { player = %context.Player, entity = self.Entity, prf = 0 }, "SetScale", xScale, yScale )
end )

Component:AddFunction( "egpDrawTopLeft", "wl:n", "", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local onoff, tValueB = ValueB( self )

    if (!CanUseEGP( self, value %1 )) then return end
    local bool = true
    if (onoff == 0) then bool = false end
    EGP:DoAction( value %1, { player = %context.Player, entity = self.Entity, prf = 0 }, "MoveTopLeft", bool )
end )

-- value %1 code has some wtf strange things
local function ScalePoint( value %1, x, y )
    local xMin = value %1.xScale[1]
    local xMax = value %1.xScale[2]
    local yMin = value %1.yScale[1]
    local yMax = value %1.yScale[2]

    x = ((x - xMin) * 512) / (xMax - xMin) - xMax
    y = ((y - yMin) * 512) / (yMax - yMin) - yMax

    return x,y
end


EA:SetCost(2)
Component:AddFunction( "egpToWorld", "wl:v2", "v", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local pos, tValueB = ValueB( self )

    if not EGP:ValidEGP( value %1 ) then return Vector(0,0,0) end

    local class = value %1:GetClass()
    if class == "gmod_wire_egp_emitter" then
        local x,y = pos[1]*0.25,pos[2]*0.25 -- 0.25 because the scale of the 3D2D is 0.25.
        if value %1.Scaling then
            x,y = ScalePoint(value %1,x,y)
        end
        return value %1:LocalToWorld( Vector(-64,0,135) + Vector(x,0,-y) )
    elseif class == "gmod_wire_egp" then
        local monitor = WireGPU_Monitors[value %1:GetModel()]
        if not monitor then return Vector(0,0,0) end

        local x,y = pos[1],pos[2]

        if value %1.Scaling then
            x,y = ScalePoint( value %1, x, y )
        else
            x,y = x-256,y-256
        end

        x = x * monitor.RS / monitor.RatioX
        y = y * monitor.RS

        local vec = Vector(x, -y, 0)
        vec:Rotate(monitor.rot)
        return value %1:LocalToWorld(vec+monitor.offset)
    end

    return Vector(0,0,0)
end )

local antispam = {}
EA:SetCost(EA_COST_ABNORMAL)
Component:AddFunction( "egpHudToggle", "wl:", "", function( self, ValueA ) 
    local value %1, tValueA = ValueA( self )

    if not EGP:ValidEGP( value %1 ) then return end
    if antispam[%context.Player] and antispam[%context.Player] > CurTime() then return end
    antispam[%context.Player] = CurTime() + 0.1
    umsg.Start( "EGP_HUD_Use", %context.Player ) umsg.Entity( value %1 ) umsg.End()
end )

--------------------------------------------------------
-- Useful functions
--------------------------------------------------------

-----------------------------
-- ConVars
-----------------------------

EA:SetCost(EA_COST_NORMAL)

Component:AddFunction( "egpNumObjects", "wl:", "n", function( self, ValueA ) 
    local value %1, tValueA = ValueA( self )

    if (!EGP:ValidEGP( value %1 )) then return -1 end
    return #value %1.RenderTable
end )

Component:AddFunction( "egpMaxObjects", "", "n", function( self ) 

    return EGP.ConVars.MaxObjects:GetInt()
end )

Component:AddFunction( "egpMaxUmsgPerSecond", "", "n", function( self )

    return EGP.ConVars.MaxPerSec:GetInt()
end )

EA:SetCost(EA_COST_CHEAP)

Component:AddFunction( "egpCanSendUmsg", "", "n", function( self )

    return (EGP:CheckInterval( %context.Player, true ) and 1 or 0)
end )

-----------------------------
-- Queue system
-----------------------------

Component:AddFunction( "egpClearQueue", "", "n", function( self )

    if (EGP.Queue[%context.Player]) then
        EGP.Queue[%context.Player] = {}
        EGP:StopQueueTimer( %context.Player )
        return 1
    end
    return 0
end )

EA:SetCost(EA_COST_NORMAL)

-- Returns the amount of items in your queue
Component:AddFunction( "egpQueue", "", "n", function( self )

    if (EGP.Queue[%context.Player]) then
        return #EGP.Queue[%context.Player]
    end
    return 0
end )

-- Choose whether or not to make value %1 E2 run when the queue has finished sending all items for <value %1>
Component:AddFunction( "egpRunOnQueue", "wl:n", "", function( self, ValueA, ValueB ) 
    local value %1, tValueA = ValueA( self )
    local yesno, tValueB = ValueB( self )

    if (!EGP:ValidEGP( value %1 )) then return end
    local bool = false
    if (yesno != 0) then bool = true end
    self.data.EGP.RunOnEGP[value %1] = bool
end )

-- Returns 1 if the current execution was caused by the EGP queue system OR if the EGP queue system finished in the current execution
Component:AddFunction( "egpQueueClk", "", "n", function( self )

    if (EGP.RunByEGPQueue) then
        return 1
    end
    return 0
end )

-- Returns 1 if the current execution was caused by the EGP queue system regarding the entity <screen> OR if the EGP queue system finished in the current execution
Component:AddFunction( "egpQueueClk", "wl", "n", function( self, ValueA ) 
    local screen, tValueA = ValueA( self )

    if (EGP.RunByEGPQueue and EGP.RunByEGPQueue_Ent == screen) then
        return 1
    end
    return 0
end )

-- Returns 1 if the current execution was caused by the EGP queue system regarding the entity <screen> OR if the EGP queue system finished in the current execution
Component:AddFunction( "egpQueueClk", "e", "n", function( self, ValueA ) 
    local screen, tValueA = ValueA( self )

    if (EGP.RunByEGPQueue and EGP.RunByEGPQueue_Ent == screen) then
        return 1
    end
    return 0
end )

-- Returns the screen which the queue finished sending items for
Component:AddFunction( "egpQueueScreen", "", "e", function( self )

    if (EGP.RunByEGPQueue) then
        return EGP.RunByEGPQueue_Ent
    end
end )

-- Same as above, except returns wirelink
Component:AddFunction( "egpQueueScreenWirelink", "", "wl", function( self )

    if (EGP.RunByEGPQueue) then
        return EGP.RunByEGPQueue_Ent
    end
end )

-- Returns the player which ordered the current items to be sent (value %1 is usually yourself, but if you're sharing pp with someone it might be them. Good way to check if someone is fucking with your screens)
Component:AddFunction( "egpQueuePlayer", "", "e", function( self )

    if (EGP.RunByEGPQueue) then
        return EGP.RunByEGPQueue_ply
    end
end )

-- Returns 1 if the current execution was caused by the EGP queue system and the player <ply> was the player whom ordered the item to be sent (value %1 is usually yourself, but if you're sharing pp with someone it might be them.)
Component:AddFunction( "egpQueueClkPly", "e", "n", function( self, ValueA ) 
    local ply, tValueA = ValueA( self )

    if (EGP.RunByEGPQueue and EGP.RunByEGPQueue_ply == ply) then
        return 1
    end
    return 0
end )

*/