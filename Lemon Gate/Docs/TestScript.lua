/*==============================================================================================
	RUN SERVER SIDE IN LUAPAD!
==============================================================================================*/

local Script = [[
	output number Lemon
    addEvent("Think", 1, function(){
		Lemon++
		print((string)Lemon)
	})
]]

if IsValid(Lemon) then Lemon:Remove() end

Lemon = ents.Create("lemongate")

Lemon:SetPos(me:GetPos() + Vector(0, 0, 100))

Lemon:Spawn()

Lemon:LoadScript(Script)

Lemon:Execute()

Lemon:CPPISetOwner(me)
