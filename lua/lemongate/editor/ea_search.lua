local PANEL = { }

PANEL.CaseSensative = CreateClientConVar( "lemon_editor_search_casesensative", "0", true, false ) 
PANEL.WholeWordOnly = CreateClientConVar( "lemon_editor_search_wholewordonly", "0", true, false ) 
PANEL.AllowRegex = CreateClientConVar( "lemon_editor_search_allowregex", "0", true, false ) 
PANEL.InSelection = CreateClientConVar( "lemon_editor_search_inselected", "0", true, false ) 
PANEL.Wrap = CreateClientConVar( "lemon_editor_search_wrap", "0", true, false ) 


function PANEL:Init( )

	self:SetSize( 280, 50 )
	self.Extended = false
	self.Y = -55
	
	-- Close Button:
		self.btnClose = self:Add( "EA_CloseButton" )
		self.btnClose:SetOffset( -5, 5 )
		self.btnClose.DoClick = function( )
			self:Toggle( false )
		end
	
	-- Title:
		self.Title = self:Add( "DLabel" )
		self.Title:SetPos( 5, 5 )
		self.Title:SetText( "Find in code:" )
		self.Title:SetTextColor( Color( 0, 0, 0 ) )
		self.Title:SizeToContents( )
	
	-- Menu Button:
		self.btnMenu = self:Add( "EA_ImageButton" )
		self.btnMenu:SetPos( 5, 25 )
		self.btnMenu:SetIconCentered( true )
		self.btnMenu:SetIconFading( false ) 
		self.btnMenu.Expanded = true 
		self.btnMenu:SetToolTip( "Search Query Settings." )
		self.btnMenu:SetMaterial( Material( "fugue/binocular.png" ) ) 
		self.btnMenu.DoClick = function( )
			self:OpenMenu( )
		end
		
	-- QueryBox:
		self.txtFind = self:Add( "DTextEntry" )
		self.txtFind:SetPos( 30, 25 )
		self.txtFind:SetSize( 200, 20 )
		self.txtFind:SetMultiline( false )
		
		function self.txtFind:Paint( )
			local W, H = self:GetSize( )
			derma.SkinHook( "Paint", "TextEntry", self, W, H )
			
			if self.bgCol then
				surface.SetDrawColor( self.bgCol )
				surface.DrawRect( 2, 2, W - 4, H - 4 )
			end
		end
		
		function self.txtFind.OnEnter( )
			self:FindQuery( )
		end
		
	-- Search UP:
		self.btnUp = self:Add( "EA_ImageButton" )
		self.btnUp:SetPos( 235, 25 )
		self.btnUp:SetIconCentered( true )
		self.btnUp:SetIconFading( false ) 
		self.btnUp.Expanded = true 
		self.btnUp:SetToolTip( "Find Previous." ) 
		self.btnUp:SetMaterial( Material( "fugue/arrow-090.png" ) ) 
		self.btnUp.DoClick = function( )
			self:FindQuery( true )
		end
		
-- Search Down:		
		self.btnDown = self:Add( "EA_ImageButton" )
		self.btnDown:SetPos( 255, 25 )
		self.btnDown:SetIconCentered( true )
		self.btnDown:SetIconFading( false ) 
		self.btnDown.Expanded = true 
		self.btnDown:SetToolTip( "Find Next." ) 
		self.btnDown:SetMaterial( Material( "fugue/arrow-270.png" ) )
		self.btnDown.DoClick = function( )
			self:FindQuery( false )
		end
		
end

/*---------------------------------------------------------------------------
Open Menu
---------------------------------------------------------------------------*/
function PANEL:OpenMenu( )
	if ValidPanel( self.Menu ) then
		self.Menu:Remove( )
	end
	
	self.Menu = vgui.Create( "PanelList" )
	self.Menu:SetPos( gui.MouseX( ) - 5, gui.MouseY( ) - 5 )
	
	local Close = self.Menu:Add( "EA_CloseButton" )
	Close:SetOffset( -5, 5 )
	Close.DoClick = function( )
		self.Menu:Remove( )
	end
		
	local CaseSensative = vgui.Create( "DCheckBoxLabel" )
	CaseSensative:SetText( "Match case" )
	CaseSensative:SetConVar( "lemon_editor_search_casesensative" )
	self.Menu:AddItem( CaseSensative )
	
	local WholeWordOnly = vgui.Create( "DCheckBoxLabel" )
	WholeWordOnly:SetText( "Match whole word" )
	WholeWordOnly:SetConVar( "lemon_editor_search_wholewordonly" )
	self.Menu:AddItem( WholeWordOnly )
	
	local InSelection = vgui.Create( "DCheckBoxLabel" )
	InSelection:SetText( "Find in selection" )
	InSelection:SetConVar( "lemon_editor_search_inselected" )
	self.Menu:AddItem( InSelection )
	
	local AllowRegex = vgui.Create( "DCheckBoxLabel" )
	AllowRegex:SetText( "Use search patterns" )
	AllowRegex:SetConVar( "lemon_editor_search_allowregex" )
	self.Menu:AddItem( AllowRegex )
	
	local Wrap = vgui.Create( "DCheckBoxLabel" )
	Wrap:SetText( "Wrap around" )
	Wrap:SetConVar( "lemon_editor_search_wrap" )
	self.Menu:AddItem( Wrap )
	
	function self.Menu:OnCursorExited( )
		self:Remove( )
	end
	
	self.Menu:SetSize( 150, 100 )
	self.Menu:MakePopup( )
end
/*---------------------------------------------------------------------------
Controls
---------------------------------------------------------------------------*/

function PANEL:Toggle( Bool )
	self.Extended = Bool or !self.Extended
	
	if Bool then
		self.txtFind:RequestFocus( )
		self.txtFind:SetCaretPos( self:GetValue( ):len( ) )
	else
		self.txtFind:KillFocus( )
	end
end

function PANEL:GetValue( )
	return self.txtFind:GetValue( )
end

function PANEL:Think( )
	local Dest = self.Extended and 5 or -55
	self.Y = self.Y + math.Clamp( Dest - self.Y, -2, 2 )
	self:SetPos( self:GetPos( ), self.Y )
end


/*---------------------------------------------------------------------------
Util
---------------------------------------------------------------------------*/
function PANEL:ValidQuery( )
	local Value = self:GetValue( )
	
	if self.Extended and Value then
		
		if !self.AllowRegex:GetBool( ) then
			Value = string.gsub( Value, "[%-%^%$%(%)%%%.%[%]%*%+%?]", "%%%1" )
		end
		
		return Value
	end
end

function PANEL:FunctionKey( )
	if self.Extended then
		self.txtFind:RequestFocus( )
	elseif self:GetParent( ):HasSelection( ) then
		local Selected = self:GetParent( ):GetSelection( )
		self.txtFind:SetText( Selected:split( "\n" )[1] or "" )
		self:Toggle( true )
	else
		self:Toggle( true )
	end
end


local table_concat = table.concat
local string_sub = string.sub

function PANEL:GetArea( start, stop )
	local Editor = self:GetParent( )
	
	if start.x == stop.x then 
		if Editor.Insert and start.y == stop.y then 
			selection[2].y = selection[2].y + 1 
			
			return string_sub( Editor.Rows[start.x], start.y, start.y )
		else 
			return string_sub( Editor.Rows[start.x], start.y, stop.y - 1 )
		end 
	else
		local text = string_sub( Editor.Rows[start.x], start.y )

		for i = start.x + 1, stop.x - 1 do
			text = text .. "\n" .. Editor.Rows[i]
		end

		return text .. "\n" .. string_sub( Editor.Rows[stop.x], 1, stop.y - 1 )
	end
end

/*---------------------------------------------------------------------------
Find
---------------------------------------------------------------------------*/

function PANEL:FindQuery( Up )
	if self:GetValue( ) == "" then
		self.txtFind.bgCol = nil
	elseif self:DoFind( Up, Looped ) then
		self.txtFind.bgCol = Color( 0, 255, 128, 100 )
	else
		self.txtFind.bgCol = Color( 255, 0, 128, 100 )
	end
end

function PANEL:DoFind( Up, Looped )
	local Looped = Looped or 0
	if Looped >= 2 then return false end
	
	local Editor = self:GetParent( )
	local CaretMax = Vector2( #Editor.Rows, #Editor.Rows[ #Editor.Rows ] )
	
	
	local Start = Editor.Start
	local End = CaretMax
	
	if self.InSelection:GetBool( ) then
		End = Editor.Caret
	end
	
	
	local Query = self:GetValue( )
	local Temp = Editor:GetCode( )
	
	if !self.CaseSensative:GetBool( ) then
		Query = Query:lower( )
		Temp = Temp:lower( )
	end
	
	
	local TempStart, TempStop = Temp:find( Query, 1, !self.AllowRegex:GetBool( ) )
	
	if !TempStart or !TempStop then
		return false
	end
	
	
	if !Up then
		-- Down:
		
		local Text = self:GetArea( Start, End )
		
		if !self.CaseSensative:GetBool( ) then
			Text = Text:lower( )
		end
		
		local Offset = 2
		for Loop = 1, 100 do
			local Start, Stop = Text:find( Query, Offset, !self.AllowRegex:GetBool( ) )
			
			if Start and Stop then
				
				if self.WholeWordOnly:GetBool( ) then
					local NewStart = Editor:MovePosition( Editor.Start, Start )
					NewStart = Vector2( NewStart.x, NewStart.y - 1 )
								
					local NewStop = Editor:MovePosition( Editor.Start, Stop )
					NewStop = Vector2( NewStop.x, NewStop.y - 1 )
					
					local WordStart = Editor:wordStart( Vector2( NewStart.x, NewStart.y + 1 ) )
					local WordEnd = Editor:wordEnd( Vector2( NewStart.x, NewStart.y + 1 ) )
							
					if NewStart == WordStart and WordEnd == ( NewStop + Vector2( 0, 1 ) ) then
						Editor:HighlightFoundWord( nil, NewStart, NewStop )
						return true
					else
						Offset = Start + 1
					end
				else
					Editor:HighlightFoundWord( nil, Start - 1, Stop - 1 )
					return true
				end
			
			else
				break
			end
		end
		
		if self.Wrap:GetBool( ) and !self.CaseSensative:GetBool( ) then
			Editor:SetCaret( Vector2( 1, 1 ) )
			return self:DoFind( Up, Looped + 1 )
		end
				
	else
		--Up:
		
		if !self.InSelection:GetBool( ) then
			End = Start
			Start = Vector2( 1, 1 )
		end
		
		
		local Text = self:GetArea( Start, End )
		
		if !self.CaseSensative:GetBool( ) then
			Text = Text:lower( )
		end
		
		local Found
		
		local Offset = 2
		for Loop = 1, 100 do
			local Start, Stop = Text:find( Query, Offset, !self.AllowRegex:GetBool( ) )
			
			if Start and Stop then
				
				if self.WholeWordOnly then
					local NewStart = Editor:MovePosition( Vector2( 1, 1 ), Start )
					NewStart = Vector2( NewStart.x, NewStart.y - 1 )
								
					local NewStop = Editor:MovePosition( Vector2( 1, 1 ), Stop )
					NewStop = Vector2( NewStop.x, NewStop.y - 1 )
					
					local WordStart = Editor:wordStart( Vector2( NewStart.x, NewStart.y + 1 ) )
					local WordEnd = Editor:wordEnd( Vector2( NewStart.x, NewStart.y + 1 ) )
							
					if NewStart == WordStart and WordEnd == ( NewStop + Vector2( 0, 1 ) ) then
						Found = { NewStart, NewStop }
						
						if NewStop.x == Editor.Start.x and NewStop.y >= Editor.Start.y then
							break
						elseif NewStop.x > Editor.Start.x then
							break
						end
					else
						Offset = Start + 1
					end
				else
					Found = { Start - 1, Stop - 1 }
					
					local NewStop = Editor:MovePosition( Vector2( 1, 1 ), Stop )
					
					if NewStop.x == Editor.Start.x and NewStop.y >= Editor.Start.y then
						break
					elseif NewStop.x > Editor.Start.x then
						break
					end
				end
				
				Offset = Start + 1
				
			else
				break
			end
		end
		
		if Found then
			Editor:HighlightFoundWord( Vector2( 1, 1 ), Found[1], Found[2] )
			return true
		end
		
		if self.Wrap:GetBool( ) and !self.CaseSensative:GetBool( ) then
			Editor:SetCaret( CaretMax )
			return self:DoFind( Up, Looped + 1 )
		end
		
	end
	
	return false
end

vgui.Register( "EA_Search", PANEL, "DPanel" )