/*==============================================================================================
	Expression Advanced: Tool.
	Purpose: Oh look a shiny new tool.
	Creditors: Rusketh
==============================================================================================*/
if !WireLib or !LEMON then return end

local LEMON, CITRIS = LEMON, TOOL

/*==============================================================================================
	Basic Tool:
==============================================================================================*/
CITRIS.Category				= "Wire - Control"
CITRIS.Name					= "Chip - Expression Advanced"
CITRIS.Command 				= nil
CITRIS.ConfigName 			= nil
CITRIS.Tab					= "Wire"
CITRIS.ClientConVar.Model 	= "models/mandrac/wire/e3.mdl"

cleanup.Register( "lemongates" )

/*==============================================================================================
	LAnguage
==============================================================================================*/
if CLIENT then
	language.Add( "Tool.lemongate.name", "Expression Advanced" )
	language.Add( "Tool.lemongate.desc", "Spawns an Expression Advanced chip." )
	language.Add( "Tool.lemongate.help", "For every walk of life there is a LemonGate." )
	language.Add( "Tool.lemongate.0", "Create/Update Expression, Secondary: Open Expression in Editor, Reload: Reload Expression." )
	
	language.Add("sboxlimit_lemongates", "You've run out of lemons!")
	language.Add("Undone_lemongate", "You made a lemon go boom!")
	language.Add("Cleanup_lemongate", "You made a lemon go boom!" )
	language.Add("Cleaned_lemongates", "You blew up all the lemons!" )
	
else
	CreateConVar( "sbox_maxlemongates", 20)
end

/*==============================================================================================
	Util
==============================================================================================*/
function CITRIS:GetModel( )
	local model = self:GetClientInfo( "Model" )
	if model and model ~= "" then return Model( model ) end
	
	return "models/mandrac/wire/e3.mdl"
end

function CITRIS:IsLemonGate(Entity)
	return Entity and Entity:IsValid() and Entity:GetClass() == "lemongate"
end

function CITRIS:CanInteract( Entity )
	return LEMON.API.Util.IsFriend(Entity.Player, self:GetOwner())
end

/*==============================================================================================
	Ghost
==============================================================================================*/
function CITRIS:Think( )

	if !IsValid( self.GhostEntity ) or self.GhostEntity:GetModel( ) != self:GetClientInfo( "model" ) then
		self:MakeGhostEntity( self:GetClientInfo( "model" ), Vector(0,0,0), Angle(0,0,0) )
	else
	
		local Trace = util.TraceLine( util.GetPlayerTrace( self:GetOwner( ) ) )
		
		if Trace.Hit then
			
			if IsValid( Trace.Entity ) and ( self:IsLemonGate( Trace.Entity ) or Trace.Entity:IsPlayer( ) ) then
				return self.GhostEntity:SetNoDraw( true )
			end
			
			local Ang = Trace.HitNormal:Angle( )
			Ang.pitch = Ang.pitch + 90
			
			self.GhostEntity:SetPos( Trace.HitPos - Trace.HitNormal * self.GhostEntity:OBBMins( ).z )
			self.GhostEntity:SetAngles( Ang )
			
			self.GhostEntity:SetNoDraw( false )
		end
	end
end
	
/*==============================================================================================
	Entity Creation Helper
==============================================================================================*/
if SERVER then
	function LEMON.MakeLemonGate(Player, Pos, Ang, Model, Script)
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
				
				return Entity
			end
		end
	end
	
	local MakeLemonGate = LEMON.MakeLemonGate

	duplicator.RegisterEntityClass("lemongate", MakeLemonGate, "Pos", "Ang", "Model", "Script")

/*==============================================================================================
	Tool Clicks
==============================================================================================*/
	function CITRIS:Reload( Trace )
		local Entity = Trace.Entity
		if self:IsLemonGate(Entity) then
			if self:CanInteract(Entity) then
				Entity:Reset( )
				return true -- Reload the Script!
			end
		end
		
		return false
	end
	
	function CITRIS:RightClick( Trace )
		local Entity, Player = Trace.Entity, self:GetOwner( )
		
		if self:IsLemonGate( Entity ) then
			if self:CanInteract( Entity ) then
				LEMON.Downloader.Send_Script( Player, Entity:GetScript( ), Entity )
				return true -- Send the player the Script!
			end
			
			return false
		end
		
		Player:SendLua( "LEMON.Editor.Open( )" )
		
		return false
	end
	
	function CITRIS:LeftClick( Trace )
		local Entity, Player = Trace.Entity, self:GetOwner()
		
		if self:IsLemonGate(Entity) then -- Check if a gate exists!
			if self:CanInteract(Entity) then
				LEMON.RequestUpload(Entity, Player)
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
			Entity:SetPos( Trace.HitPos - Trace.HitNormal * Entity:OBBMins().z )
			
			local WeldTo, Constraint = Trace.Entity
			
			if WeldTo and !WeldTo:IsWorld() then
				Constraint = constraint.Weld( Entity, WeldTo, 0, Trace.PhysicsBone, false, false, true ) 
			end
			
			undo.Create("lemongate")
				undo.AddEntity( Entity )
				undo.SetPlayer( Player )
				undo.AddEntity( Constraint )
			undo.Finish()
			
			Player:AddCleanup( "lemongates", Entity )
			
			LEMON.RequestUpload(Entity, Player)
			
			return true
		end
		
		return false
	end
end

/*==============================================================================================
	CLIENT
==============================================================================================*/
if CLIENT then
	
	list.Set( "LemonGateModels", "models/bull/gates/processor.mdl", {} )
	list.Set( "LemonGateModels", "models/shadowscion/lemongate/gate.mdl", { } )
	list.Set( "LemonGateModels", "models/mandrac/wire/e3.mdl", {} )
	
	function CITRIS.BuildCPanel( CPanel )
		
		CPanel:AddControl( "Header", { Text = "#tool.lemongate.name", Description = "#tool.lemongate.help" }  )
		CPanel:AddControl( "PropSelect", { Label = "Pick your lemon:", ConVar = "lemongate_model", Models = list.Get( "LemonGateModels" ), Height = 1 } )
		
		/*******************************************************************/
		
		local FileBrowser = vgui.Create( "DTree", CPanel )
		FileBrowser.DoClick = function( _, Node ) 
			local Dir = Node:GetFileName() or ""
			
			if !string.EndsWith( Dir, ".txt" ) then return end 
			
			if Node.LastClick and CurTime() - Node.LastClick < 0.5 then 
				LEMON.Editor.Open( ) 
				LEMON.Editor.GetInstance( ):LoadFile( Dir )
				Node.LastClick = 0
				return true 
			end 
			
			Node.LastClick = CurTime() 
		end 

		local LemonNode = vgui.Create( "DTree_Node" )
		FileBrowser.RootNode:InsertNode( LemonNode )
		LemonNode:SetText( "LemonGate" ) 
		LemonNode:MakeFolder( "lemongate", "DATA", true )  
		LemonNode:SetExpanded( true ) 

		FileBrowser:SetSize( CPanel:GetWide( ), 300 )
		CPanel:AddItem( FileBrowser )

		/*******************************************************************/

		local BrowserRefresh = vgui.Create( "DButton" )
		BrowserRefresh:SetText( "Update" )
		BrowserRefresh.DoClick = function( ) 
			LemonNode.ChildNodes:Remove()
			LemonNode.ChildNodes = nil
			LemonNode:CreateChildNodes()
			LemonNode:SetNeedsPopulating( true )
			LemonNode:PopulateChildrenAndSelf( true )
		end

		local OpenEditor = vgui.Create( "DButton" )
		OpenEditor:SetText( "Open Editor" )
		OpenEditor.DoClick = function(button)
			LEMON.Editor.Open()
		end

		local NewExpression = vgui.Create( "DButton" )
		NewExpression:SetText( "New Expression" )
		NewExpression.DoClick = function(button)
			LEMON.Editor.Open( nil, true )
		end

		CPanel:AddItem( BrowserRefresh )
		CPanel:AddItem( OpenEditor )
		CPanel:AddItem( NewExpression )
	end 
	
/*==============================================================================================
	The Screen
==============================================================================================*/
	local Font = {
		font = "Arial",
		size = 40,
		weight = 1000,
		antialias = true,
		additive = false,
	}
	
	surface.CreateFont( "Lemon_Tool_Font", Font )
	
	Font.size = 26
	surface.CreateFont( "Lemon_Tool_Font_Small", Font )
	
	Font.size = 20
	surface.CreateFont( "Lemon_Tool_Font_Binary", Font )
	
/*============================================================================================*/
	local Binary = "01001100011001010110110101101111011011100010000001000111011000010111010001100101"
	
	timer.Create( "Lemon_Tool_Binary", 0.25, 0, function( )
		Binary = Binary:sub( 2 ) .. Binary[1]
	end ) 
	
/*============================================================================================*/	
	local Cog = surface.GetTextureID( "expression 2/cog" )
	local Yellow = Color( 255, 244, 79 )
	local Yellowish = Color( 255, 255, 150, 150 )
	
	function CITRIS:DrawToolScreen( Width, Height )
		cam.Start2D( )
		
		-- Background
			surface.SetDrawColor( 32, 32, 32, 255 )
			surface.DrawRect( 0, 0, Width, Height )
		
		-- Title
			draw.SimpleText( "Lemon Gate", "Lemon_Tool_Font", Width / 2, 10, Yellow, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Expression Advanced", "Lemon_Tool_Font_Small", Width / 2, 47, Yellowish, TEXT_ALIGN_CENTER )
		
		-- Seperator
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.DrawRect( 0, 85, Width, 3 )
			
		-- Cog
			surface.SetTexture( Cog )
			surface.SetDrawColor( 255, 244, 79, 750 * FrameTime( ) )
			surface.DrawTexturedRectRotated( 80, 175, 150, 150, RealTime( ) * 10)
		
		-- Binary
			local Col = Color( 255, 255, 200, 650 * FrameTime( ) )
			
			for I = 1, 6 do
				local Text = Binary:sub( I * 6, (I * 6) + 6 )
				draw.SimpleText( Text, "Lemon_Tool_Font_Binary", Width - 20, 78 + ( I * 22 ), Col, TEXT_ALIGN_RIGHT )
			end
			
		cam.End2D()
	end

end
