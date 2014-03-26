/*==============================================================================================
	Expression Advanced: Component -> Hover Text.
	Creditors: BoJaN
==============================================================================================*/

local Hovertext = {}
Hovertext.Data = {} --Stores all the hovertext tables
Hovertext.MaxRange = CreateConVar( "lemon_hovertext_maxrange", "5000" )
Hovertext.Enabled = CreateConVar( "lemon_hovertext_enabled", "1" )

local BaseFontData = {
	font = "Consolas",
	size = 15,
	weight = 100,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
}

--There's probably a better way to do this, but I'm not a Lua expert.
local function CreateFont(Name, FontData)
	local FinalData = {}
	
	for k,v in pairs(BaseFontData) do
		FinalData[k] = v
	end
	
	--Overwrite base data
	for k,v in pairs(FontData) do
		FinalData[k] = v
	end
	surface.CreateFont(Name, FinalData)
end

local function DrawText(Pos, Text, Font, Color, Alpha)
	draw.DrawText(Text, Font, Pos.x, Pos.y, Color(Color.x, Color.y, Color.z, Color.a * Alpha), 1)
end

net.Receive( "lemon_hovertext_setText", function( Bytes )
	for _, Data in pairs(net.ReadTable()) do
		local Ent = Entity(Data.EntityID)
		if IsValid(Ent) then
			Data.Entity = Ent
			Hovertext.Data[Ent] = Data
		end
	end
end)

--Strip text from the entity
net.Receive( "lemon_hovertext_removeText", function( Bytes )
	for _, Data in pairs(net.ReadTable()) do
		local Ent = Entity(Data.Entity)
		if IsValid(Ent) then
			Hovertext.Data[Ent] = nil
		end
	end
end)

hook.Add("HUDPaint", "Lemon_Hovertext_Draw", function()
	if Hovertext.Enabled:GetBool() then
		for _, Data in pairs(Hovertext.Data) do
			if table.Count(Data.Filter) == 0 || Data.Filter[LocalPlayer()] then
				local Entity = Data.Entity
				if IsValid(Entity) then 
					local Position = Entity:GetPos()
					Position.x = Position.x + Data.Offset.x
					Position.y = Position.y + Data.Offset.y
					Position.z = Position.z + Data.Offset.z
					local Scrn = Position:ToScreen()
					
					
					local Range = math.Clamp(Data.Range, 0, Hovertext.MaxRange:GetInt())
					local Dist = Position:Distance(LocalPlayer():GetShootPos())
					if(Dist < Range) then
						local Alpha =  math.Clamp(2 - (Dist / (Range/2)), 0, 1) --Fade out
						draw.DrawText(Data.Text, Data.Font, Scrn.x, Scrn.y, Color(Data.Color[1], Data.Color[2], Data.Color[3], Data.Color[4] * Alpha), 1)
					end
				else
					Hovertext.Data[Data.Entity] = nil
				end
			end
		end
	end
end)

CreateFont("hovertext_tiny", {size=10})
CreateFont("hovertext_tiny_shadow", {size=10, shadow=true})

CreateFont("hovertext_small", {size=12})
CreateFont("hovertext_small_shadow", {size=12, shadow=true})

CreateFont("hovertext_normal", {size=14})
CreateFont("hovertext_normal_shadow", {size=14, shadow=true})

CreateFont("hovertext_large", {size=16})
CreateFont("hovertext_large_shadow", {size=16, shadow=true})
print("cl_hovertext.lua Loaded")
