/*==============================================================================================
	Expression Advanced: Component -> Hover Text.
	Creditors: BoJaN
==============================================================================================*/
local LEMON, API, Util = LEMON, LEMON.API, LEMON.API.Util

local Component = API:NewComponent( "hovertext", true )

local Hovertext = {}
Hovertext.Data = {} --Stores all the hovertext tables
Hovertext.MaxRange = CreateConVar( "lemon_hovertext_maxrange", "5000" )
Hovertext.Protected = false

util.AddNetworkString("lemon_hovertext_setText")
util.AddNetworkString("lemon_hovertext_removeText")

function printTable(Table, Indent)
	if not Indent then Indent = 0 end
	
	for k,v in pairs(Table) do
		print(string.rep(" ", Indent), k, " = ", v)
		if type(v) == "table" then
			printTable(v, Indent+1)
		end
	end
end

function SendData(Data)
	net.Start( "lemon_hovertext_setText" )
		net.WriteTable(Data)
	net.Broadcast()
end

--Sets entity text
function Component.SetText(Context, Entity, Text, Font, Color, Offset, Range)
	if Hovertext.Protected && not Util.IsFriend(Util.GetOwner(Entity), Context.Player) then return end
	
	local Data = Hovertext.Data[Entity:EntIndex()]
	if Data then
		if Text then Data.Text = Text end
		if Font then Data.Font = Font end
		if Color then Data.Color = Color end
		if Offset then Data.Offset = Offset end
		if Range then Data.Range = math.Clamp(Range, 0, Hovertext.MaxRange:GetInt()) end
	else		
		Data =
		{
			Entity = Entity,
			EntityID = Entity:EntIndex(),
			Text = Text,
			Font = Font,
			Color = Color,
			Offset = Offset,
			Range = Range,
			Filter = {}
		}
	end
	
	if not Data.Text then Data.Text = "" end
	if not Data.Font then Data.Font = "hovertext_normal" end
	if not Data.Color then Data.Color = {255,255,0,255} end
	if not Data.Color[4] then Data.Color[4] = 255 end
	if not Data.Offset then Data.Offset = Vector(0,0,0) end
	if not Data.Range then Data.Range = math.Min(1000, Hovertext.MaxRange:GetInt()) end
	if not Data.Filter then Data.Filter = {} end
	
	Hovertext.Data[Data.Entity] = Data
	SendData({Data})
end

--Removes entity text
function Component.RemoveText(Context, Entity)
	if Hovertext.Protected && not Util.IsFriend(Util.GetOwner(Entity), Context.Player) then return end
	
	local Data = {
			Entity = Entity:EntIndex(),
		}
	Hovertext.Data[Data.Entity] = nil
	SendData({Data})
end

function Component.SetFilter(Context, Entity, Filter)
	if Hovertext.Protected && not Util.IsFriend(Util.GetOwner(Entity), Context.Player) then return end
	local Data = Hovertext.Data[Entity]
	if Data then
		local FTbl = {}
		for k,v in pairs(Filter.Data) do
			FTbl[v] = v
		end
		
		Data.Filter = FTbl
		SendData({Data})
	end
end

--Changes just the font
function Component.SetFont(Context, Entity, Font)
	if Hovertext.Protected && not Util.IsFriend(Util.GetOwner(Entity), Context.Player) then return end
	
	local Data = Hovertext.Data[Entity]
	if Data then
		Data.Font = Font
		SendData({Data})
	end
end

--Changes just the color
function Component.SetColor(Context, Entity, Color)
	if Hovertext.Protected && not Util.IsFriend(Util.GetOwner(Entity), Context.Player) then return end
	
	local Data = Hovertext.Data[Entity]
	if Data then
		Data.Color = Color
		if not Data.Color[4] then Data.Color[4] = 255 end
		
		SendData({Data})
	end
end

--Changes just the offset
function Component.SetOffset(Context, Entity, Offset)
	if Hovertext.Protected && not Util.IsFriend(Util.GetOwner(Entity), Context.Player) then return end
	
	local Data = Hovertext.Data[Entity]
	if Data then
		Data.Offset = Offset
		SendData({Data})
	end
end

--Changes just the range
function Component.SetRange(Context, Entity, Range)
	if Hovertext.Protected && not Util.IsFriend(Util.GetOwner(Entity), Context.Player) then return end
	
	local Data = Hovertext.Data[Entity]
	if Data then
		Data.Range = Range
		SendData({Data})
	end
end

function Component.GetHovertextFonts()
	return {"hovertext_tiny",
	"hovertext_tiny_shadow",
	"hovertext_small",
	"hovertext_small_shadow",
	"hovertext_normal",
	"hovertext_normal_shadow",
	"hovertext_large",
	"hovertext_large_shadow"
	}
end

hook.Add( "PlayerInitialSpawn", "Lemon_Holograms", function( Player )
	net.Start("lemon_hovertext_setText")
	net.WriteTable(Hovertext.Data)
	net.Send(Player)
end)

Component:AddExternal( "HoverText", Component )
Component:AddExternal( "HoverTextDefaultFont", "hovertext_normal_shadow" )

Component:SetPerf( LEMON_PERF_NORMAL )
Component:AddFunction("setText", "e:s", "", "%HoverText.SetText(%context, value %1, value %2)", LEMON_PREPARE_ONLY, 0, "e:setText(Text)" )
Component:AddFunction("setText", "e:s,s", "", "%HoverText.SetText(%context, value %1, value %2, value %3)", LEMON_PREPARE_ONLY, 0, "e:setText(Text, Font)" )
Component:AddFunction("setText", "e:s,s,c", "", "%HoverText.SetText(%context, value %1, value %2, value %3, value %4)", LEMON_PREPARE_ONLY, 0, "e:setText(Text, Font, Color)" )
Component:AddFunction("setText", "e:s,s,c,v", "", "%HoverText.SetText(%context, value %1, value %2, value %3, value %4, value %5)", LEMON_PREPARE_ONLY, 0, "e:setText(Text, Font, Color, Offset)" )
Component:AddFunction("setText", "e:s,s,c,v,n", "", "%HoverText.SetText(%context, value %1, value %2, value %3, value %4, value %5, value %6)", LEMON_PREPARE_ONLY, 0, "e:setText(Text, Font, Color, Offset, Range)" )

Component:AddFunction("setText", "e:s,c", "", "%HoverText.SetText(%context, value %1, value %2, %HoverTextDefaultFont, value %3)", LEMON_PREPARE_ONLY, 0, "e:setText(Text, Color)" )
Component:AddFunction("setText", "e:s,c,v", "", "%HoverText.SetText(%context, value %1, value %2, %HoverTextDefaultFont, value %3, value %4)", LEMON_PREPARE_ONLY, 0, "e:setText(Text, Color, Offset)" )
Component:AddFunction("setText", "e:s,c,v,n", "", "%HoverText.SetText(%context, value %1, value %2, %HoverTextDefaultFont, value %3, value %4, value %5)", LEMON_PREPARE_ONLY, 0, "e:setText(Text, Color, Offset, Range)" )

Component:AddFunction("setTextFont", "e:s", "", "%HoverText.SetFont(%context, value %1, value %2)", LEMON_PREPARE_ONLY, 0, "e:setTextFont(Font)" )
Component:AddFunction("setTextColor", "e:c", "", "%HoverText.SetColor(%context, value %1, value %2)", LEMON_PREPARE_ONLY, 0, "e:setTextColor(Color)" )
Component:AddFunction("setTextOffset", "e:v", "", "%HoverText.SetOffset(%context, value %1, value %2)", LEMON_PREPARE_ONLY, 0, "e:setTextOffset(Offset)" )
Component:AddFunction("setTextRange", "e:n", "", "%HoverText.SetRange(%context, value %1, value %2)", LEMON_PREPARE_ONLY, 0, "e:setTextRange(Range)" )
Component:AddFunction("setTextFilter", "e:t", "", "%HoverText.SetFilter(%context, value %1, value %2)", LEMON_PREPARE_ONLY, 0, "e:setTextRange(Filter)" )

Component:AddFunction("removeText", "e:", "", "%HoverText.RemoveText(%context, value %1)", LEMON_PREPARE_ONLY, 0, "e:removeText()" )

Component:AddFunction( "hovertextFonts", "", "t", "%Table.Results(%HoverText.GetHovertextFonts(), \"s\")" )
--Component:AddFunction("hovertextFonts", "", "t", LEMON_INLINE_ONLY, "{HOVERTEXT_SMALL,HOVERTEXT_SMALL_SHADOW,HOVERTEXT_NORMAL,HOVERTEXT_NORMAL_SHADOW,HOVERTEXT_LARGE,HOVERTEXT_LARGE_SHADOW}", 0, "hovertextFonts()" )

Component:AddConstant( "HOVERTEXT_TINY", "s", "hovertext_tiny" )
Component:AddConstant( "HOVERTEXT_TINY", "s", "hovertext_tiny_shadow" )

Component:AddConstant( "HOVERTEXT_SMALL", "s", "hovertext_small" )
Component:AddConstant( "HOVERTEXT_SMALL_SHADOW", "s", "hovertext_small_shadow" )
Component:AddConstant( "HOVERTEXT_NORMAL", "s", "hovertext_normal" )
Component:AddConstant( "HOVERTEXT_NORMAL_SHADOW", "s", "hovertext_normal_shadow" )
Component:AddConstant( "HOVERTEXT_LARGE", "s", "hovertext_large" )
Component:AddConstant( "HOVERTEXT_LARGE_SHADOW", "s", "hovertext_large_shadow" )