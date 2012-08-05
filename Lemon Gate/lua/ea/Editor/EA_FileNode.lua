/*============================================================================================================================================
	Expression-Advanced Derma
==============================================================================================================================================
	Name: EA_FileNode
	Author: Oskar 
============================================================================================================================================*/

local PANEL = {} 

function PANEL:Init()
	self.Expander:Remove()

	self.Expander = vgui.Create( "EA_Button", self )
	self.Expander:SetText( "+" )
	self.Expander:SetVisible( false )

	function self.Expander:Paint()
		local w, h = self:GetSize() 
		local txt = self:GetText()

		surface.SetDrawColor(255,255,255,255)
		if txt == "+" then surface.SetMaterial( eaMaterial( "fugue/plus-circle" ) ) 
		elseif txt == "-" then surface.SetMaterial( eaMaterial( "fugue/minus-circle" ) ) 
		else surface.SetMaterial( eaMaterial( "fugue/question-circle" ) ) 
		end
		surface.DrawTexturedRect(0,0,w,h)
		return true
	end
end

function PANEL:AddNode( strName )
	self:CreateChildNodes()

	local pNode = vgui.Create( "EA_FileNode", self )
		pNode:SetText( strName )
		pNode:SetParentNode( self )
		pNode:SetRoot( self:GetRoot() )

	self.ChildNodes:AddItem( pNode )
	self:InvalidateLayout()

	return pNode
end

vgui.Register( "EA_FileNode", PANEL, "DTree_Node" ) 