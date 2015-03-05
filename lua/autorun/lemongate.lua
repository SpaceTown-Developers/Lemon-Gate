AddCSLuaFile()
if SERVER then return end

local Frame = vgui.Create("DFrame")
Frame:SetTitle("LemonGate - Dear Server Owner!")
Frame:SetSize(550, 300)

local Text = [[
	Hi, This message comes directly from Rusketh, the creator of LemonGate.
	I hope you have enjoyed using my addon, how ever its time for an upgrade,
	I have been on a few of the servers still using lemongate over the past few weeks
	to inform you that lemongate is now depricated and no longer a working addon.

	Expression advanced 2 is the new vershion of LemonGate, it uses a new workshop
	and a new github repository. Lemongate contains several abusable exploits and
	is a unfortunatly a majour cause of some server lagg, this is all fixed in the new
	and improved ExpAdv2.

	ExpAdv2 also contains a bulk of new functionality and features and I have proivded some buttons below
	that will link you to more information. If you do not wish to upgrade then please remove the lemongate addon
	and the .gma file if you are on workshop, this irritating popup will then vanish with it.

	Thank you for reading this message and I hope you do choose to upgrade :D
]]

local Label = vgui.Create("DLabel", Frame)
Label:Dock(FILL)
Label:SetText(Text)

local Bar = vgui.Create("DPanel", Frame)
Bar:SetSize(550, 44)
Bar:Dock(BOTTOM)
Bar.Paint = function() end

local Links = vgui.Create("DPanel", Bar)
Links:SetSize(550, 22)

WireThread = vgui.Create("DButton", Links)
WireThread:Dock(LEFT)
WireThread:SetText("View Wire Mod Thread")
WireThread:SetWidth(150)
WireThread.DoClick = function() gui.OpenURL("http://www.wiremod.com/forum/wiremod-addons-coding/33630-expression-advanced-two.html") end

GitHub = vgui.Create("DButton", Links)
GitHub:Dock(FILL)
GitHub:SetText("Visit On GitHub")
GitHub:SetWidth(150)
GitHub.DoClick = function() gui.OpenURL("http://github.com/Rusketh/ExpAdv2") end

WorkShop = vgui.Create("DButton", Links)
WorkShop:Dock(RIGHT)
WorkShop:SetText("Go to Workshop Addon")
WorkShop:SetWidth(150)
WorkShop.DoClick = function() gui.OpenURL("http://steamcommunity.com/sharedfiles/filedetails/?id=323792126") end

local PS = vgui.Create("DLabel", Bar)
PS:SetPos(0,22)
PS:SetSize(550, 22)
PS:SetText("P.S: I am a brony and to =Pony RP= you insult me, and all the bronys on our dev team, for trying to help!")

Frame:MakePopup()
Frame:Center()
