/*==============================================================================================
	Expression Advanced: EGP Library
	Purpose: Manipulating a EGP screen.
    Note: Basicaly just E2's egp ext converted over.
    Credits: Oskar, E2's Authors.
==============================================================================================*/
local EA = LemonGate

EA.API.NewComponent( "EGP", true )

EA.API.AddHook( "BuildContext", function( Gate )
    Gate.Context.EGPUpdateRequired = { }
end )

EA.API.AddHook( "TriggerOutputs", function( Gate )
	local Context = Gate.Context 
	for k,v in pairs( Context.EGPUpdateRequired ) do 
		if IsValid( k ) and v == true then 
			EGP:SendQueueItem( Context.Player )
			EGP:StartQueueTimer( Context.Player )
			Context.EGPUpdateRequired[k] = nil 
		end 
		Context.EGPUpdateRequired[k] = nil
	end 
end )

local function Update( self, EGP ) 
	self.EGPUpdateRequired[EGP] = true 
end 

local function CanUseEGP( self, this )
	return EGP:ValidEGP( this ) //and EA.IsOwner( self.Player, this )
end 


--------------------------------------------------------
-- Frames
--------------------------------------------------------
-------------
-- Save
-------------

EA:SetCost(15)

EA:RegisterFunction( "egpSaveFrame", "wl:s", "", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    if (!EGP:ValidEGP( this )) then return end
    if (!index or index == "") then return end
    local bool, frame = EGP:LoadFrame( self.Player, nil, index )
    if (bool) then
        if (!EGP:IsDifferent( this.RenderTable, frame )) then return end
    end
    EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SaveFrame", index )
    Update(self,this)
end )

EA:RegisterFunction( "egpSaveFrame", "wl:n", "", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    if (!EGP:ValidEGP( this )) then return end
    if (!index) then return end
    local bool, frame = EGP:LoadFrame( self.Player, nil, tostring(index) )
    if (bool) then
        if (!EGP:IsDifferent( this.RenderTable, frame )) then return end
    end
    EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SaveFrame", tostring(index) )
    Update(self,this)
end )

-------------
-- Load
-------------

EA:SetCost(15)

EA:RegisterFunction( "egpLoadFrame", "wl:s", "", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    if (!CanUseEGP( self, this )) then return end
    if (!index or index == "") then return end
    local bool, frame = EGP:LoadFrame( self.Player, nil, index )
    if (bool) then
        if (EGP:IsDifferent( this.RenderTable, frame )) then
            EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "LoadFrame", index )
            Update(self,this)
        end
    end
end )

EA:RegisterFunction( "egpLoadFrame", "wl:n", "", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    if (!CanUseEGP( self, this )) then return end
    if (!index) then return end
    local bool, frame = EGP:LoadFrame( self.Player, nil, tostring(index) )
    if (bool) then
        if (EGP:IsDifferent( this.RenderTable, frame )) then
            EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "LoadFrame", tostring(index) )
            Update(self,this)
        end
    end
end )

--------------------------------------------------------
-- Order
--------------------------------------------------------

EA:RegisterFunction( "egpOrder", "wl:nn", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local order, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    if (index == order) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        local bool2 = EGP:SetOrder( this, k, order )
        if (bool2) then
            EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v )
            Update(self,this)
        end
    end
end )

EA:RegisterFunction( "egpOrder", "wl:n", "n", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        return k
    end
    return 0
end )

EA:SetCost(15)

--------------------------------------------------------
-- Box
--------------------------------------------------------
EA:RegisterFunction( "egpBox", "wl:nv2v2", "", function( self, ValueA, ValueB, ValueC, ValueD ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local pos, tValueC = ValueC( self )
    local size, tValueD = ValueD( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["Box"], { index = index, w = size[1], h = size[2], x = pos[1], y = pos[2] }, self.Player )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,this) end
end )

--------------------------------------------------------
-- BoxOutline
--------------------------------------------------------
EA:RegisterFunction( "egpBoxOutline", "wl:nv2v2", "", function( self, ValueA, ValueB, ValueC, ValueD ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local pos, tValueC = ValueC( self )
    local size, tValueD = ValueD( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["BoxOutline"], { index = index, w = size[1], h = size[2], x = pos[1], y = pos[2] }, self.Player )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,this) end
end )

--------------------------------------------------------
-- RoundedBox
--------------------------------------------------------
EA:RegisterFunction( "egpRoundedBox", "wl:nv2v2", "", function( self, ValueA, ValueB, ValueC, ValueD ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local pos, tValueC = ValueC( self )
    local size, tValueD = ValueD( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["RoundedBox"], { index = index, w = size[1], h = size[2], x = pos[1], y = pos[2] }, self.Player )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,this) end
end )

EA:RegisterFunction( "egpRadius", "wl:nn", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local radius, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (EGP:EditObject( v, { radius = radius } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )

--------------------------------------------------------
-- RoundedBoxOutline
--------------------------------------------------------
EA:RegisterFunction( "egpRoundedBoxOutline", "wl:nv2v2", "", function( self, ValueA, ValueB, ValueC, ValueD ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local pos, tValueC = ValueC( self )
    local size, tValueD = ValueD( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["RoundedBoxOutline"], { index = index, w = size[1], h = size[2], x = pos[1], y = pos[2] }, self.Player )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,this) end
end )

--------------------------------------------------------
-- Text
--------------------------------------------------------
EA:RegisterFunction( "egpText", "wl:nsv2", "", function( self, ValueA, ValueB, ValueC, ValueD ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local text, tValueC = ValueC( self )
    local pos, tValueD = ValueD( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["Text"], { index = index, text = text, x = pos[1], y = pos[2] }, self.Player )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,this) end
end )

EA:RegisterFunction( "egpTextLayout", "wl:nsv2v2", "", function( self, ValueA, ValueB, ValueC, ValueD, ValueE ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local text, tValueC = ValueC( self )
    local pos, tValueD = ValueD( self )
    local size, tValueE = ValueE( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["TextLayout"], { index = index, text = text, x = pos[1], y = pos[2], w = size[1], h = size[2] }, self.Player )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,this) end
end )

EA:SetCost(10)

----------------------------
-- Set Text
----------------------------
EA:RegisterFunction( "egpSetText", "wl:ns", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local text, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (EGP:EditObject( v, { text = text } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )

----------------------------
-- Alignment
----------------------------
EA:RegisterFunction( "egpAlign", "wl:nn", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local halign, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (EGP:EditObject( v, { halign = math.Clamp(halign,0,2) } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )

EA:RegisterFunction( "egpAlign", "wl:nnn", "", function( self, ValueA, ValueB, ValueC, ValueD ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local halign, tValueC = ValueC( self )
    local valign, tValueD = ValueD( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (EGP:EditObject( v, { valign = math.Clamp(valign,0,2), halign = math.Clamp(halign,0,2) } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )

----------------------------
-- Font
----------------------------
EA:RegisterFunction( "egpFont", "wl:ns", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local font, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        local fontid = 0
        for k,v in ipairs( EGP.ValidFonts ) do
            if (v:lower() == font:lower()) then
                fontid = k
                break
            end
        end
        if (EGP:EditObject( v, { fontid = fontid } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )

EA:RegisterFunction( "egpFont", "wl:nsn", "", function( self, ValueA, ValueB, ValueC, ValueD ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local font, tValueC = ValueC( self )
    local size, tValueD = ValueD( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        local fontid = 0
        for k,v in ipairs( EGP.ValidFonts ) do
            if (v:lower() == font:lower()) then
                fontid = k
                break
            end
        end
        if (EGP:EditObject( v, { fontid = fontid, size = size } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )

EA:SetCost(15)

--------------------------------------------------------
-- Line
--------------------------------------------------------
EA:RegisterFunction( "egpLine", "wl:nv2v2", "", function( self, ValueA, ValueB, ValueC, ValueD ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local pos1, tValueC = ValueC( self )
    local pos2, tValueD = ValueD( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["Line"], { index = index, x = pos1[1], y = pos1[2], x2 = pos2[1], y2 = pos2[2] }, self.Player )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,this) end
end )

--------------------------------------------------------
-- Circle
--------------------------------------------------------
EA:RegisterFunction( "egpCircle", "wl:nv2v2", "", function( self, ValueA, ValueB, ValueC, ValueD ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local pos, tValueC = ValueC( self )
    local size, tValueD = ValueD( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["Circle"], { index = index, x = pos[1], y = pos[2], w = size[1], h = size[2] }, self.Player )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,this) end
end )

--------------------------------------------------------
-- Circle Outline
--------------------------------------------------------
EA:RegisterFunction( "egpCircleOutline", "wl:nv2v2", "", function( self, ValueA, ValueB, ValueC, ValueD ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local pos, tValueC = ValueC( self )
    local size, tValueD = ValueD( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["CircleOutline"], { index = index, x = pos[1], y = pos[2], w = size[1], h = size[2] }, self.Player )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,this) end
end )

--------------------------------------------------------
-- Triangle
--------------------------------------------------------
EA:RegisterFunction( "egpTriangle", "wl:nv2v2v2", "", function( self, ValueA, ValueB, ValueC, ValueD, ValueE ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local vert1, tValueC = ValueC( self )
    local vert2, tValueD = ValueD( self )
    local vert3, tValueE = ValueE( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["Triangle"], { index = index, x = vert1[1], y = vert1[2], x2 = vert2[1], y2 = vert2[2], x3 = vert3[1], y3 = vert3[2] }, self.Player )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,this) end
end )

--------------------------------------------------------
-- Triangle Outline
--------------------------------------------------------
EA:RegisterFunction( "egpTriangleOutline", "wl:nv2v2v2", "", function( self, ValueA, ValueB, ValueC, ValueD, ValueE ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local vert1, tValueC = ValueC( self )
    local vert2, tValueD = ValueD( self )
    local vert3, tValueE = ValueE( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["TriangleOutline"], { index = index, x = vert1[1], y = vert1[2], x2 = vert2[1], y2 = vert2[2], x3 = vert3[1], y3 = vert3[2] }, self.Player )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,this) end
end )

--------------------------------------------------------
-- Wedge
--------------------------------------------------------
EA:RegisterFunction( "egpWedge", "wl:nv2v2", "", function( self, ValueA, ValueB, ValueC, ValueD ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local pos, tValueC = ValueC( self )
    local size, tValueD = ValueD( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["Wedge"], { index = index, x = pos[1], y = pos[2], w = size[1], h = size[2] }, self.Player )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,this) end
end )

--------------------------------------------------------
-- Wedge Outline
--------------------------------------------------------
EA:RegisterFunction( "egpWedgeOutline", "wl:nv2v2", "", function( self, ValueA, ValueB, ValueC, ValueD ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local pos, tValueC = ValueC( self )
    local size, tValueD = ValueD( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["WedgeOutline"], { index = index, x = pos[1], y = pos[2], w = size[1], h = size[2] }, self.Player )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,this) end
end )

--------------------------------------------------------
-- 3DHolder
--------------------------------------------------------
EA:RegisterFunction( "egp3DTracker", "wl:nv2", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local pos, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, obj = EGP:CreateObject( this, EGP.Objects.Names["3DTracker"], { index = index, target_x = pos[1], target_y = pos[2], target_z = pos[3] }, self.Player )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,this) end
end )

EA:SetCost(10)

EA:RegisterFunction( "egpPos", "wl:nv2", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local pos, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (EGP:EditObject( v, { target_x = pos[1], target_y = pos[2], target_z = pos[3] } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )

--------------------------------------------------------
-- Set functions
--------------------------------------------------------

EA:SetCost(10)

----------------------------
-- Size
----------------------------
EA:RegisterFunction( "egpSize", "wl:nv2", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local size, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (EGP:EditObject( v, { w = size[1], h = size[2] } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )

EA:RegisterFunction( "egpSize", "wl:nn", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local size, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (EGP:EditObject( v, { size = size } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )

----------------------------
-- Position
----------------------------
EA:RegisterFunction( "egpPos", "wl:nv2", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local pos, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (EGP:EditObject( v, { x = pos[1], y = pos[2] } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )

----------------------------
-- Angle
----------------------------

EA:RegisterFunction( "egpAngle", "wl:nn", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local angle, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (EGP:EditObject( v, { angle = angle } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )

-------------
-- Position & Angle
-------------

EA:RegisterFunction( "egpAngle", "wl:nv2v2n", "", function( self, ValueA, ValueB, ValueC, ValueD, ValueE ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local worldpos, tValueC = ValueC( self )
    local axispos, tValueD = ValueD( self )
    local angle, tValueE = ValueE( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (v.x and v.y) then

            local vec, ang = LocalToWorld(Vector(axispos[1],axispos[2],0), Angle(0,0,0), Vector(worldpos[1],worldpos[2],0), Angle(0,-angle,0))

            local x = vec.x
            local y = vec.y

            angle = -ang.yaw

            local t = { x = x, y = y }
            if (v.angle) then t.angle = angle end

            if (EGP:EditObject( v, t )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
        end
    end
end )

----------------------------
-- Color
----------------------------
EA:RegisterFunction( "egpColor", "wl:nc", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local color, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (EGP:EditObject( v, { r = color[1], g = color[2], b = color[3], a = color[4] } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )

EA:RegisterFunction( "egpAlpha", "wl:nn", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local a, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (EGP:EditObject( v, { a = a } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )


----------------------------
-- Material
----------------------------
EA:RegisterFunction( "egpMaterial", "wl:ns", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local material, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (EGP:EditObject( v, { material = material } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )

EA:RegisterFunction( "egpMaterialFromScreen", "wl:ne", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local gpu, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool and gpu and gpu:IsValid()) then
        if (EGP:EditObject( v, { material = gpu } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )

----------------------------
-- Fidelity (number of corners for circles and wedges)
----------------------------
EA:RegisterFunction( "egpFidelity", "wl:nn", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local fidelity, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (EGP:EditObject( v, { fidelity = math.Clamp(fidelity,3,180) } )) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
    end
end )

EA:RegisterFunction( "egpFidelity", "wl:n", "n", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (v.fidelity) then
            return v.fidelity
        end
    end
    return 0
end )

----------------------------
-- Parenting
----------------------------
EA:RegisterFunction( "egpParent", "wl:nn", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local parentindex, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, v = EGP:SetParent( this, index, parentindex )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
end )

-- Entity parenting (only for 3Dtracker - does nothing for any other object)
EA:RegisterFunction( "egpParent", "wl:ne", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local parent, tValueC = ValueC( self )

    if not parent or not parent:IsValid() then return end
    if (!CanUseEGP( self, this )) then return end

    local bool, k, v = EGP:HasObject( this, index )
    if bool and v.Is3DTracker then
        if v.parententity == parent then return end -- Already parented to that
        v.parententity = parent

        EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v )
        Update(self,this)
    end
end )

-- Returns the entity a tracker is parented to
EA:RegisterFunction( "egpTrackerParent", "wl:n", "e", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( this, index )
    if bool and v.Is3DTracker then
        return (v.parententity and v.parententity:IsValid()) and v.parententity or nil
    end
end )

EA:RegisterFunction( "egpParentToCursor", "wl:n", "", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, v = EGP:SetParent( this, index, -1 )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
end )

EA:RegisterFunction( "egpUnParent", "wl:n", "", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, v = EGP:UnParent( this, index )
    if (bool) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", v ) Update(self,this) end
end )

EA:RegisterFunction( "egpParent", "wl:n", "n", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( this, index )
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
EA:RegisterFunction( "egpClear", "wl:", "", function( self, ValueA ) 
    local this, tValueA = ValueA( self )

    if (!CanUseEGP( self, this )) then return end
    if (EGP:ValidEGP( this )) then
        EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "ClearScreen" )
        Update(self,this)
    end
end )

EA:RegisterFunction( "egpRemove", "wl:n", "", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "RemoveObject", index )
        Update(self,this)
    end
end )

--------------------------------------------------------
-- Get functions
--------------------------------------------------------

EA:SetCost(5)

EA:RegisterFunction( "egpPos", "wl:n", "v2", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (v.x and v.y) then
            return {v.x, v.y}
        end
    end
    return {-1,-1}
end )

EA:SetCost(5)

EA:RegisterFunction( "egpSize", "wl:n", "v2", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (v.w and v.h) then
            return {v.w, v.h}
        end
    end
    return {-1,-1}
end )

EA:RegisterFunction( "egpSizeNum", "wl:n", "n", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (v.size) then
            return v.size
        end
    end
    return -1
end )

EA:RegisterFunction( "egpColor", "wl:n", "c", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (v.r and v.g and v.b and v.a) then
            return {v.r,v.g,v.b,v.a}
        end
    end
    return {-1,-1,-1,-1}
end )

EA:RegisterFunction( "egpAlpha", "wl:n", "n", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (v.a) then
            return v.a
        end
    end
    return -1
end )

EA:RegisterFunction( "egpAngle", "wl:n", "n", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (v.angle) then
            return v.angle
        end
    end
    return -1
end )

EA:RegisterFunction( "egpMaterial", "wl:n", "s", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( this, index )
    if (bool) then
        if (v.material) then
            return v.material
        end
    end
    return ""
end )

EA:RegisterFunction( "egpRadius", "wl:n", "n", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, k, v = EGP:HasObject( this, index )
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

EA:SetCost(15)

EA:RegisterFunction( "egpCopy", "wl:nn", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )
    local fromindex, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local bool, k, v = EGP:HasObject( this, fromindex )
    if (bool) then
        local copy = table.Copy( v )
        copy.index = index
        local bool2, obj = EGP:CreateObject( this, v.ID, copy, self.Player )
        if (bool2) then EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SendObject", obj ) Update(self,this) end
    end
end )

EA:SetCost(20)

EA:RegisterFunction( "egpCursor", "wl:e", "v2", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local ply, tValueB = ValueB( self )

    return EGP:EGPCursor( this, ply )
end )

EA:SetCost(10)

EA:RegisterFunction( "egpScrSize", "ne", "v2", function( self, ValueA ) 
    local ply, tValueA = ValueA( self )

    if (!ply or !ply:IsValid() or !ply:IsPlayer() or !EGP.ScrHW[ply]) then return {-1,-1} end
    return EGP.ScrHW[ply]
end )

EA:RegisterFunction( "egpScrW", "ne", "n", function( self, ValueA ) 
    local ply, tValueA = ValueA( self )

    if (!ply or !ply:IsValid() or !ply:IsPlayer() or !EGP.ScrHW[ply]) then return -1 end
    return EGP.ScrHW[ply][1]
end )

EA:RegisterFunction( "egpScrH", "ne", "n", function( self, ValueA ) 
    local ply, tValueA = ValueA( self )

    if (!ply or !ply:IsValid() or !ply:IsPlayer() or !EGP.ScrHW[ply]) then return -1 end
    return EGP.ScrHW[ply][2]
end )

EA:SetCost(15)

EA:RegisterFunction( "egpHasObject", "wl:n", "n", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local index, tValueB = ValueB( self )

    local bool, _, _ = EGP:HasObject( this, index )
    return bool and 1 or 0
end )

EA:SetCost(10)

local function errorcheck( x, y )
    local xMul = x[2]-x[1]
    local yMul = y[2]-y[1]
    if (xMul == 0 or yMul == 0) then error("Invalid EGP scale") end
end

EA:RegisterFunction( "egpScale", "wl:v2v2", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local xScale, tValueB = ValueB( self )
    local yScale, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    errorcheck(xScale,yScale)
    EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SetScale", xScale, yScale )
end )

EA:RegisterFunction( "egpResolution", "wl:v2v2", "", function( self, ValueA, ValueB, ValueC ) 
    local this, tValueA = ValueA( self )
    local topleft, tValueB = ValueB( self )
    local bottomright, tValueC = ValueC( self )

    if (!CanUseEGP( self, this )) then return end
    local xScale = { topleft[1], bottomright[1] }
    local yScale = { topleft[2], bottomright[2] }
    errorcheck(xScale,yScale)
    EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "SetScale", xScale, yScale )
end )

EA:RegisterFunction( "egpDrawTopLeft", "wl:n", "", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local onoff, tValueB = ValueB( self )

    if (!CanUseEGP( self, this )) then return end
    local bool = true
    if (onoff == 0) then bool = false end
    EGP:DoAction( this, { player = self.Player, entity = self.Entity, prf = 0 }, "MoveTopLeft", bool )
end )

-- this code has some wtf strange things
local function ScalePoint( this, x, y )
    local xMin = this.xScale[1]
    local xMax = this.xScale[2]
    local yMin = this.yScale[1]
    local yMax = this.yScale[2]

    x = ((x - xMin) * 512) / (xMax - xMin) - xMax
    y = ((y - yMin) * 512) / (yMax - yMin) - yMax

    return x,y
end


EA:SetCost(20)
EA:RegisterFunction( "egpToWorld", "wl:v2", "v", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local pos, tValueB = ValueB( self )

    if not EGP:ValidEGP( this ) then return Vector(0,0,0) end

    local class = this:GetClass()
    if class == "gmod_wire_egp_emitter" then
        local x,y = pos[1]*0.25,pos[2]*0.25 -- 0.25 because the scale of the 3D2D is 0.25.
        if this.Scaling then
            x,y = ScalePoint(this,x,y)
        end
        return this:LocalToWorld( Vector(-64,0,135) + Vector(x,0,-y) )
    elseif class == "gmod_wire_egp" then
        local monitor = WireGPU_Monitors[this:GetModel()]
        if not monitor then return Vector(0,0,0) end

        local x,y = pos[1],pos[2]

        if this.Scaling then
            x,y = ScalePoint( this, x, y )
        else
            x,y = x-256,y-256
        end

        x = x * monitor.RS / monitor.RatioX
        y = y * monitor.RS

        local vec = Vector(x, -y, 0)
        vec:Rotate(monitor.rot)
        return this:LocalToWorld(vec+monitor.offset)
    end

    return Vector(0,0,0)
end )

local antispam = {}
EA:SetCost(25)
EA:RegisterFunction( "egpHudToggle", "wl:", "", function( self, ValueA ) 
    local this, tValueA = ValueA( self )

    if not EGP:ValidEGP( this ) then return end
    if antispam[self.Player] and antispam[self.Player] > CurTime() then return end
    antispam[self.Player] = CurTime() + 0.1
    umsg.Start( "EGP_HUD_Use", self.Player ) umsg.Entity( this ) umsg.End()
end )

--------------------------------------------------------
-- Useful functions
--------------------------------------------------------

-----------------------------
-- ConVars
-----------------------------

EA:SetCost(10)

EA:RegisterFunction( "egpNumObjects", "wl:", "n", function( self, ValueA ) 
    local this, tValueA = ValueA( self )

    if (!EGP:ValidEGP( this )) then return -1 end
    return #this.RenderTable
end )

EA:RegisterFunction( "egpMaxObjects", "", "n", function( self ) 

    return EGP.ConVars.MaxObjects:GetInt()
end )

EA:RegisterFunction( "egpMaxUmsgPerSecond", "", "n", function( self )

    return EGP.ConVars.MaxPerSec:GetInt()
end )

EA:SetCost(5)

EA:RegisterFunction( "egpCanSendUmsg", "", "n", function( self )

    return (EGP:CheckInterval( self.Player, true ) and 1 or 0)
end )

-----------------------------
-- Queue system
-----------------------------

EA:RegisterFunction( "egpClearQueue", "", "n", function( self )

    if (EGP.Queue[self.Player]) then
        EGP.Queue[self.Player] = {}
        EGP:StopQueueTimer( self.Player )
        return 1
    end
    return 0
end )

EA:SetCost(10)

-- Returns the amount of items in your queue
EA:RegisterFunction( "egpQueue", "", "n", function( self )

    if (EGP.Queue[self.Player]) then
        return #EGP.Queue[self.Player]
    end
    return 0
end )

-- Choose whether or not to make this E2 run when the queue has finished sending all items for <this>
EA:RegisterFunction( "egpRunOnQueue", "wl:n", "", function( self, ValueA, ValueB ) 
    local this, tValueA = ValueA( self )
    local yesno, tValueB = ValueB( self )

    if (!EGP:ValidEGP( this )) then return end
    local bool = false
    if (yesno != 0) then bool = true end
    self.data.EGP.RunOnEGP[this] = bool
end )

-- Returns 1 if the current execution was caused by the EGP queue system OR if the EGP queue system finished in the current execution
EA:RegisterFunction( "egpQueueClk", "", "n", function( self )

    if (EGP.RunByEGPQueue) then
        return 1
    end
    return 0
end )

-- Returns 1 if the current execution was caused by the EGP queue system regarding the entity <screen> OR if the EGP queue system finished in the current execution
EA:RegisterFunction( "egpQueueClk", "wl", "n", function( self, ValueA ) 
    local screen, tValueA = ValueA( self )

    if (EGP.RunByEGPQueue and EGP.RunByEGPQueue_Ent == screen) then
        return 1
    end
    return 0
end )

-- Returns 1 if the current execution was caused by the EGP queue system regarding the entity <screen> OR if the EGP queue system finished in the current execution
EA:RegisterFunction( "egpQueueClk", "e", "n", function( self, ValueA ) 
    local screen, tValueA = ValueA( self )

    if (EGP.RunByEGPQueue and EGP.RunByEGPQueue_Ent == screen) then
        return 1
    end
    return 0
end )

-- Returns the screen which the queue finished sending items for
EA:RegisterFunction( "egpQueueScreen", "", "e", function( self )

    if (EGP.RunByEGPQueue) then
        return EGP.RunByEGPQueue_Ent
    end
end )

-- Same as above, except returns wirelink
EA:RegisterFunction( "egpQueueScreenWirelink", "", "wl", function( self )

    if (EGP.RunByEGPQueue) then
        return EGP.RunByEGPQueue_Ent
    end
end )

-- Returns the player which ordered the current items to be sent (This is usually yourself, but if you're sharing pp with someone it might be them. Good way to check if someone is fucking with your screens)
EA:RegisterFunction( "egpQueuePlayer", "", "e", function( self )

    if (EGP.RunByEGPQueue) then
        return EGP.RunByEGPQueue_ply
    end
end )

-- Returns 1 if the current execution was caused by the EGP queue system and the player <ply> was the player whom ordered the item to be sent (This is usually yourself, but if you're sharing pp with someone it might be them.)
EA:RegisterFunction( "egpQueueClkPly", "e", "n", function( self, ValueA ) 
    local ply, tValueA = ValueA( self )

    if (EGP.RunByEGPQueue and EGP.RunByEGPQueue_ply == ply) then
        return 1
    end
    return 0
end )


