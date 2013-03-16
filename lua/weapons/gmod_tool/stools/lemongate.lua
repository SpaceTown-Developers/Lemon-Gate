/*==============================================================================================
	Expression Advanced: Tool.
	Purpose: Oh look a shiny new tool.
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
local Lemon = TOOL

-- Tool Stuffs!
Lemon.Category		= "Wire - Control"
Lemon.Name			= "Chip - Expression Advanced"
Lemon.Command 		= nil
Lemon.ConfigName 	= nil
Lemon.Tab			= "Wire"

-- Convars
Lemon.ClientConVar.Model = "models/mandrac/wire/e3.mdl"

function Lemon:GetModel()
	local model = self:GetClientInfo("Model")
	if model and model ~= "" then return Model(model) end
	
	return "models/mandrac/wire/e3.mdl"
end

function Lemon:IsLemonGate(Entity)
	return Entity and Entity:IsValid() and Entity:GetClass() == "lemongate"
end
	
/*==============================================================================================
	SERVER
==============================================================================================*/
if SERVER then
	CreateConVar('sbox_maxlemongates', 20)
	
	function E_A.MakeLemonGate(Player, Pos, Ang, Model, Script)
		if Player:CheckLimit("lemongates") then
			local Entity = ents.Create("lemongate")
            
			if Entity and Entity:IsValid() then 
				Entity:SetModel(Model)
				Entity:SetAngles(Ang)
				Entity:SetPos(Pos)
				Entity:Spawn()
				
				
				Entity:SetNWEntity( "player", Player )
				Entity:SetPlayer(Player)
				Entity.Player = Player
				
				if Script and Script != "" then
					Entity:LoadScript( Script )
					Entity:Execute()
				end
				
				Player:AddCount("lemongates", Entity)
				Player:AddCleanup("lemongates", Entity)
				
				return Entity
			end
		end
	end; local MakeLemonGate = E_A.MakeLemonGate

	duplicator.RegisterEntityClass("lemongate", MakeLemonGate, "Pos", "Ang", "Model", "Script")
	
	/****************************************************************************************************/
	
	function Lemon:CanInteract( Entity )
		return E_A.IsFriend(Entity.Player, self:GetOwner())
	end
	
	function Lemon:Reload( Trace )
		local Entity = Trace.Entity
		if self:IsLemonGate(Entity) then
			if self:CanInteract(Entity) then
				Entity:Restart( )
				return true -- Reload the Script!
			end
		end
		
		return false
	end
	
	function Lemon:RightClick( Trace )
		local Entity, Player = Trace.Entity, self:GetOwner( )
		
		if self:IsLemonGate( Entity ) then
			if self:CanInteract( Entity ) then
				E_A.Downloader.Send_Script( Player, Entity:GetScript( ), Entity )
				return true -- Send the player the Script!
			end
			
			return false
		end
		
		Player:SendLua( "LemonGate.Editor.Open( )" )
		
		return false
	end
	
	function Lemon:LeftClick( Trace )
		local Entity, Player = Trace.Entity, self:GetOwner()
		
		if self:IsLemonGate(Entity) then -- Check if a gate exists!
			if self:CanInteract(Entity) then
				E_A.RequestUpload(Entity, Player)
				return true
			end
			
			return false
		end
		
		if Entity and Entity:IsValid() and Entity:IsPlayer() then
			return false
		end
		
		local Model = self:GetModel()
		local Pos = Trace.HitPos
		local Ang = Trace.HitNormal:Angle()
		Ang.pitch = Ang.pitch + 90
		
		Entity = MakeLemonGate(Player, Pos, Ang, Model, nil)
		
		if Entity and Entity:IsValid() then
			Entity:SetPos(Trace.HitPos - Trace.HitNormal * Entity:OBBMins().z)
			
			
			local WeldTo, Constraint = Trace.Entity
			if WeldTo and !WeldTo:IsWorld() then
				Constraint = constraint.Weld( Entity, WeldTo, 0, Trace.PhysicsBone, false, false, true ) 
			end
			
			undo.Create("lemongate")
				undo.AddEntity( Entity )
				undo.SetPlayer( Player )
				undo.AddEntity( Constraint )
			undo.Finish()
			
			E_A.RequestUpload(Entity, Player)
			
			return true
		end
		
		return false
	end
end

/*==============================================================================================
	CLIENT
==============================================================================================*/
if CLIENT then

	language.Add( "Tool.lemongate.name", "Expression Advanced" )
	language.Add( "Tool.lemongate.desc", "Spawns an Expression Advanced chip." )
	language.Add( "Tool.lemongate.0", "Create/Update Expression, Secondary: Open Expression in Editor, Reload: Reload Expression." )
	
	language.Add("sboxlimit_lemongates", "You've run out of lemons!")
	language.Add("Undone_lemongate", "You made a lemon go boom!")
	language.Add("Cleanup_lemongate", "You made a lemon go boom!" )
	language.Add("Cleaned_lemongates", "You blew up all the lemons!" )
	
	local Ninty = Angle(90,0,0)
	local Wooo = Color(255, 255, 255, 200)
	
	function Lemon:Think()
		local Ghost = self.GhostEntity
		local Trace = self:GetOwner():GetEyeTrace()
		local Entity = Trace.Entity
		
		if !Ghost or !Ghost:IsValid() then
			self.GhostEntity = ents.CreateClientProp(self:GetModel())
            self.GhostEntity:SetRenderMode( RENDERMODE_TRANSALPHA )
			self.GhostEntity:SetColor(Wooo)
		elseif Ghost:GetModel() != self:GetModel() then
			Ghost:SetModel( self:GetModel() )
		elseif Entity and Entity:IsValid() and ( Entity:IsPlayer() or Entity:IsNPC() or Entity:GetClass() == "lemongate" ) then
			return Ghost:SetNoDraw( true )
		else
			Ghost:SetNoDraw( false )
			Ghost:SetPos(Trace.HitPos - Trace.HitNormal * Ghost:OBBMins().z)
			Ghost:SetAngles(Trace.HitNormal:Angle() + Ninty)
		end
	end

	function Lemon.BuildCPanel( Panel )
		local W, H = Panel:GetSize()
		local Editor = E_A.Editor.GetInstance()
		
		-- Todo: Model Select & Friend write!
		-- Add a Wiki Link?
		
        
        local FileBrowser = vgui.Create( "DTree", Panel ) 
        FileBrowser:SetSize( W, 500 )
        FileBrowser:DockMargin( 5, 5, 5, 0 ) 
        FileBrowser:Dock( TOP ) 
        
        FileBrowser.Paint = function( _, w, h )
            surface.SetDrawColor( 100, 100, 100, 255 )
            surface.DrawRect( 0, 0, w, h )
            
            surface.SetDrawColor( 75, 75, 75 )
            surface.SetMaterial( Material( "vgui/gradient-u" ) )
            surface.DrawTexturedRect( 0, 0, w, h )
            return true 
        end 
        
        FileBrowser.DoClick = function( _, Node ) 
            local Dir = Node:GetFileName() or ""
            
            if !string.EndsWith( Dir, ".txt" ) then return end 
            
            if Node.LastClick and CurTime() - Node.LastClick < 0.5 then 
                E_A.Editor.Open( ) 
                Editor:LoadFile( Dir )
                Node.LastClick = 0
                return true 
            end 
            
            Node.LastClick = CurTime() 
        end 
        
        
        local LemonNode = vgui.Create( "EA_FileNode" )
        FileBrowser.RootNode:InsertNode( LemonNode )
        LemonNode:SetText( "Lemongate" ) 
        LemonNode:MakeFolder( "lemongate", "DATA", true )  
        LemonNode:SetExpanded( true ) 
        
        
        local BrowserRefresh = vgui.Create( "EA_Button", Panel )
        BrowserRefresh:SetWide( W )
        BrowserRefresh:SetTall( 25 )
        BrowserRefresh:DockMargin( 5, 0, 5, 0 ) 
        BrowserRefresh:Dock( TOP ) 
        BrowserRefresh:SetText( "Update" ) 
        BrowserRefresh:SetTextCentered( true ) 
        BrowserRefresh.DoClick = function( ) 
            LemonNode.ChildNodes:Remove()
            LemonNode.ChildNodes = nil
            LemonNode:CreateChildNodes()
            LemonNode:SetNeedsPopulating( true )
            LemonNode:PopulateChildrenAndSelf( true )
        end
        
        
        // TODO: Use the same as for the editor!
		-- local FileBrowser = vgui.Create("wire_expression2_browser" , Panel)
		-- FileBrowser.OpenOnSingleClick = Editor
		-- Panel:AddPanel(FileBrowser)
		
		-- FileBrowser:Setup("LemonGate")
		-- FileBrowser:SetSize(W, 300)
		-- FileBrowser:DockMargin(5, 5, 5, 5)
		-- FileBrowser:DockPadding(5, 5, 5, 5)
		-- FileBrowser:Dock( TOP )
		
		-- function FileBrowser:OnFileOpen(filepath, newtab)
			-- Editor:Open(filepath, nil, newtab)
		-- end

		-- local OpenEditor = Panel:Button("Open Editor")
		local OpenEditor = vgui.Create( "EA_Button", Panel )
        OpenEditor:SetTall( 25 )
        OpenEditor:DockMargin( 5, 0, 5, 0 ) 
        OpenEditor:Dock( TOP ) 
        OpenEditor:SetText( "Open Editor" ) 
        OpenEditor:SetTextCentered( true ) 
		OpenEditor.DoClick = function(button)
			E_A.Editor.Open()
		end

		-- local NewExpression = Panel:Button("New Expression")
		local NewExpression = vgui.Create( "EA_Button", Panel )
        NewExpression:SetTall( 25 )
        NewExpression:DockMargin( 5, 0, 5, 0 ) 
        NewExpression:Dock( TOP ) 
        NewExpression:SetText( "New Expression" ) 
        NewExpression:SetTextCentered( true ) 
		NewExpression.DoClick = function(button)
			E_A.Editor.Open( nil, true )
		end
	end
end
