/*============================================================================================================================================
	Expression-Advanced TextEditor
	Author: Oskar
	Credits: Andreas "Syranide" Svensson for making the E2 editor
============================================================================================================================================*/

local math_max 				= math.max 
local math_min 				= math.min 
local math_floor 			= math.floor 
local math_ceil 			= math.ceil 

local string_find 			= string.find
local string_rep 			= string.rep
local string_sub 			= string.sub
local string_gsub 			= string.gsub
local string_Explode 		= string.Explode
local string_len 			= string.len

local table_remove 			= table.remove 
local table_insert 			= table.insert 
local table_concat 			= table.concat

local surface_SetFont 		= surface.SetFont
local surface_DrawRect 		= surface.DrawRect
local surface_DrawText 		= surface.DrawText
local surface_GetTextSize 	= surface.GetTextSize
local surface_SetDrawColor 	= surface.SetDrawColor
local surface_SetTextColor 	= surface.SetTextColor
local surface_SetTextPos 	= surface.SetTextPos

local draw_SimpleText 		= draw.SimpleText
local draw_WordBox 			= draw.WordBox

local input_IsKeyDown 		= input.IsKeyDown
local input_IsMouseDown 	= input.IsMouseDown

surface.CreateFont( "Fixedsys", Size, 400, false, false, "Fixedsys" )

local PANEL = { }

-- AccessorFunc( PANEL, "m_Text", "Text", FORCE_STRING )

function PANEL:Init( )
	self:SetCursor("beam")

	self.Rows = {""}

	self.Undo = {}
	self.Redo = {}
	self.PaintRows = {}
	self.Chunks = {}

	self.Blink = RealTime()
	self.LineNumberWidth = 2

	self.TextEntry = vgui.Create("TextEntry", self)
	self.TextEntry:SetMultiline(true)
	self.TextEntry:SetSize(0,0)

	self.TextEntry.OnLoseFocus = function() self:_OnLoseFocus() end
	self.TextEntry.OnTextChanged = function() self:_OnTextChanged() end
	self.TextEntry.OnKeyCodeTyped = function(_, code) self:_OnKeyCodeTyped(code) end 

	self.Caret = Vector2(1, 1)
	self.Start = Vector2(1, 1)
	self.Scroll = Vector2(1, 1)
	self.Size = Vector2(1, 1)

	self.ScrollBar = vgui.Create("DVScrollBar", self)
	self.ScrollBar:SetUp(1,1)

	surface_SetFont("Fixedsys")
	self.FontWidth, self.FontHeight = surface_GetTextSize(" ")
end

function PANEL:RequestFocus( )
	self.TextEntry:RequestFocus()
end

function PANEL:OnGetFocus( )
	self.TextEntry:RequestFocus()
end

/*---------------------------------------------------------------------------
Cursor functions
---------------------------------------------------------------------------*/

function PANEL:CursorToCaret( )
	local x, y = self:CursorPos()

	x = x - (self.LineNumberWidth + 10)
	if x < 0 then x = 0 end
	if y < 0 then y = 0 end

	local line = math_floor(y / self.FontHeight)
	local char = math_floor(x / self.FontWidth+0.5)

	line = line + self.Scroll.x
	char = char + self.Scroll.y

	if line > #self.Rows then line = #self.Rows end
	local length = #self.Rows[line]
	if char > length + 1 then char = length + 1 end

	return Vector2( line, char )
end

function PANEL:SetCaret( caret )
	self.Caret = self:CopyPosition(caret)
	self.Start = self:CopyPosition(caret)
	self:ScrollCaret()
end

function PANEL:CopyPosition( caret )
	return Vector2( caret( ) )
end

function PANEL:MovePosition( caret, offset )
	local caret = Vector2( caret.x, caret.y )

	if offset > 0 then
		while true do
			local length = #(self.Rows[caret.x]) - caret.y + 2
			if offset < length then
				caret.y = caret.y + offset
				break
			elseif caret.x == #self.Rows then
				caret.y = caret.y + length - 1
				break
			else
				offset = offset - length
				caret.x = caret.x + 1
				caret.y = 1
			end
		end
	elseif offset < 0 then
		offset = -offset

		while true do
			if offset < caret.y then
				caret.y = caret.y - offset
				break
			elseif caret.x == 1 then
				caret.y = 1
				break
			else
				offset = offset - caret.y
				caret.x = caret.x - 1
				caret.y = #(self.Rows[caret.x]) + 1
			end
		end
	end

	return caret
end

function PANEL:ScrollCaret( )
	if self.Caret.x - self.Scroll.x < 1 then
		self.Scroll.x = self.Caret.x - 1
		if self.Scroll.x < 1 then self.Scroll.x = 1 end
	end

	if self.Caret.x - self.Scroll.x > self.Size.x - 1 then
		self.Scroll.x = self.Caret.x - self.Size.x + 1
		if self.Scroll.x < 1 then self.Scroll.x = 1 end
	end

	if self.Caret.y - self.Scroll.y < 4 then
		self.Scroll.y = self.Caret.y - 4
		if self.Scroll.y < 1 then self.Scroll.y = 1 end
	end

	if self.Caret.y - 1 - self.Scroll.y > self.Size.y - 4 then
		self.Scroll.y = self.Caret.y - 1 - self.Size.y + 4
		if self.Scroll.y < 1 then self.Scroll.y = 1 end
	end

	self.ScrollBar:SetScroll(self.Scroll.x - 1)
end

/*---------------------------------------------------------------------------
Selection stuff
---------------------------------------------------------------------------*/

function PANEL:HasSelection( )
	return self.Caret != self.Start
end

function PANEL:Selection( )
	return { Vector2(self.Caret()), Vector2(self.Start()) }
end

function PANEL:GetSelection( )
	return self:GetArea(self:Selection())
end

function PANEL:SetSelection( text )
	self:SetCaret(self:SetArea(self:Selection(), text))
end

function PANEL:MakeSelection( selection )
	local start, stop = selection[1], selection[2]

	if start.x < stop.x or (start.x == stop.x and start.y < stop.y) then
		return start, stop
	else
		return stop, start
	end
end

function PANEL:GetArea( selection )
	local start, stop = self:MakeSelection(selection)

	if start.x == stop.x then
		return string_sub(self.Rows[start.x], start.y, stop.y - 1)
	else
		local text = string_sub(self.Rows[start.x], start.y)

		for i=start.x+1,stop.x-1 do
			text = text .. "\n" .. self.Rows[i]
		end

		return text .. "\n" .. string_sub(self.Rows[stop.x], 1, stop.y - 1)
	end
end

function PANEL:SetArea( selection, text ) 
	local start, stop = self:MakeSelection(selection)

	local buffer = self:GetArea(selection)
	-- print( buffer )

	if start != stop then
		// clear selection
		self.Rows[start.x] = string_sub(self.Rows[start.x], 1, start.y - 1) .. string_sub(self.Rows[stop.x], stop.y)
		self.PaintRows[start.x] = false

		for i=start.x+1,stop.x do
			table_remove(self.Rows, start.x + 1)
			table_remove(self.PaintRows, start.x + 1)
			self.PaintRows = {}
		end

		if self.Rows[#self.Rows] != "" then
			self.Rows[#self.Rows + 1] = ""
			self.PaintRows[#self.Rows + 1] = false
		end
	end

	if !text or text == "" then
		self.ScrollBar:SetUp(self.Size.x, #self.Rows + (math_floor(self:GetTall() / self.FontHeight) - 2))
		self.PaintRows = {}
		self:OnTextChanged()
		return start
	end

	// insert text
	local rows = string_Explode("\n", text)

	local remainder = string_sub(self.Rows[start.x], start.y)
	self.Rows[start.x] = string_sub(self.Rows[start.x], 1, start.y - 1) .. rows[1]
	self.PaintRows[start.x] = false

	for i=2,#rows do
		table_insert(self.Rows, start.x + i - 1, rows[i])
		table_insert(self.PaintRows, start.x + i - 1, false)
		self.PaintRows = {}
	end

	local stop = Vector2(  start.x + #rows - 1, #(self.Rows[start.x + #rows - 1]) + 1 )

	self.Rows[stop.x] = self.Rows[stop.x] .. remainder
	self.PaintRows[stop.x] = false


	if self.Rows[#self.Rows] != "" then
		self.Rows[#self.Rows + 1] = ""
		self.PaintRows[#self.Rows + 1] = false
		self.PaintRows = {}
	end

	self.ScrollBar:SetUp(self.Size.x, #self.Rows + (math_floor(self:GetTall() / self.FontHeight) - 2) )

	self.PaintRows = {}

	self:OnTextChanged()

	return stop
end

function PANEL:SelectAll( )
	self.Caret = Vector2(#self.Rows, #(self.Rows[#self.Rows]) + 1)
	self.Start = Vector2(1, 1)
	self:ScrollCaret()
end

function PANEL:wordLeft( caret )
	local row = self.Rows[caret.x] or ""
	if caret.y == 1 then
		if caret.x == 1 then return caret end
		caret = Vector2( caret.x-1, #self.Rows[caret.x-1] )
		row = self.Rows[caret.x]
	end
	local pos = row:sub(1,caret.y-1):match("[^%w@]()[%w@]+[^%w@]*$")
	caret.y = pos or 1
	return caret
end

function PANEL:wordRight( caret )
	local row = self.Rows[caret.x] or ""
	if caret.y > #row then
		if caret.x == #self.Rows then return caret end
		caret = Vector2( caret.x + 1, 1 )
		row = self.Rows[caret.x]
		if row:sub(1,1) ~= " " then return caret end
	end
	local pos = row:match("[^%w@]()[%w@]",caret.y)
	caret.y = pos or (#row+1)
	return caret
end

/*---------------------------------------------------------------------------
TextEditor hooks
---------------------------------------------------------------------------*/

function PANEL:_OnKeyCodeTyped( code )
	self.Blink = RealTime()

	local alt = input_IsKeyDown(KEY_LALT) or input_IsKeyDown(KEY_RALT)
	if alt then return end

	local shift = input_IsKeyDown(KEY_LSHIFT) or input_IsKeyDown(KEY_RSHIFT)
	local control = input_IsKeyDown(KEY_LCONTROL) or input_IsKeyDown(KEY_RCONTROL)

	-- allow ctrl-ins and shift-del (shift-ins, like ctrl-v, is handled by vgui)
	if not shift and control and code == KEY_INSERT then
		shift,control,code = true,false,KEY_C
	elseif shift and not control and code == KEY_DELETE then
		shift,control,code = false,true,KEY_X
	end

	if control then
		if code == KEY_A then
			self:SelectAll()
		elseif code == KEY_X then
			if self:HasSelection() then
				local clipboard = self:GetSelection()
				clipboard = string_gsub(clipboard, "\n", "\r\n")
				SetClipboardText(clipboard)
				self:SetSelection()
			end
		elseif code == KEY_C then
			if self:HasSelection() then
				local clipboard = self:GetSelection()
				clipboard = string_gsub(clipboard, "\n", "\r\n")
				SetClipboardText(clipboard)
			end
		elseif code == KEY_Q then
			self:Close()
			-- self:GetParent():Close()
		elseif code == KEY_UP then
			self.Scroll.x = self.Scroll.x - 1
			if self.Scroll.x < 1 then self.Scroll.x = 1 end
			self.ScrollBar:SetScroll(self.Scroll.x -1)
		elseif code == KEY_DOWN then
			self.Scroll.x = self.Scroll.x + 1
			self.ScrollBar:SetScroll(self.Scroll.x -1)
		elseif code == KEY_LEFT then
			if self:HasSelection() and not shift then
				self.Start = self:CopyPosition(self.Caret)
			else
				self.Caret = self:wordLeft(self.Caret)
			end

			self:ScrollCaret()

			if not shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_RIGHT then
			if self:HasSelection() and !shift then
				self.Start = self:CopyPosition(self.Caret)
			else
				self.Caret = self:wordRight(self.Caret)
			end

			self:ScrollCaret()

			if !shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_HOME then
			self.Caret = Vector2( 1, 1 )

			self:ScrollCaret()

			if !shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_END then
			self.Caret = Vector2( #self.Rows, 1 )

			self:ScrollCaret()

			if !shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_D then
			-- Save current selection
			local old_start = self:CopyPosition( self.Start )
			local old_end = self:CopyPosition( self.Caret )
			local old_scroll = self:CopyPosition( self.Scroll )

			local str = self:GetSelection()
			if (str != "") then -- If you have a selection
				self:SetSelection( str:rep(2) ) -- Repeat it
			else -- If you don't
				-- Select the current line
				self.Start = Vector2( self.Start.x, 1 )
				self.Caret = Vector2( self.Start.x, #self.Rows[self.Start.x]+1 )
				-- Get the text
				local str = self:GetSelection()
				-- Repeat it
				self:SetSelection( str .. "\n" .. str )
			end

			-- Restore selection
			self.Caret = old_end
			self.Start = old_start
			self.Scroll = old_scroll
			self:ScrollCaret()
		end
	else
		if code == KEY_ENTER then
			self:SetSelection("\n")
		elseif code == KEY_UP then
			if self.Caret.x > 1 then
				self.Caret.x = self.Caret.x - 1

				local length = #(self.Rows[self.Caret.x])
				if self.Caret.y > length + 1 then
					self.Caret.y = length + 1
				end
			end

			self:ScrollCaret()
			if !shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_DOWN then
			if self.Caret.x < #self.Rows then
				self.Caret.x = self.Caret.x + 1

				local length = #(self.Rows[self.Caret.x])
				if self.Caret.y > length + 1 then
					self.Caret.y = length + 1
				end
			end

			self:ScrollCaret()
			if !shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_LEFT then
			self.Caret = self:MovePosition(self.Caret, -1)
			self:ScrollCaret()
			if !shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_RIGHT then
			self.Caret = self:MovePosition(self.Caret, 1)
			self:ScrollCaret()
			if !shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_BACKSPACE then
			if self:HasSelection() then
				self:SetSelection()
			else
				local buffer = self:GetArea({self.Caret, Vector2(self.Caret.x, 1)})
				if self.Caret.y % 4 == 1 and #(buffer) > 0 and string_rep(" ", #(buffer)) == buffer then
					self:SetCaret(self:SetArea({self.Caret, self:MovePosition(self.Caret, -4)}))
				else
					self:SetCaret(self:SetArea({self.Caret, self:MovePosition(self.Caret, -1)}))
				end
			end
		elseif code == KEY_DELETE then
			if self:HasSelection() then
				self:SetSelection()
			else
				local buffer = self:GetArea({Vector2(self.Caret.x, self.Caret.y + 4), Vector2(self.Caret.x, 1)})
				if self.Caret.y % 4 == 1 and string_rep(" ", #(buffer)) == buffer and #(self.Rows[self.Caret.x]) >= self.Caret.y + 4 - 1 then
					self:SetCaret(self:SetArea({self.Caret, self:MovePosition(self.Caret, 4)}))
				else
					self:SetCaret(self:SetArea({self.Caret, self:MovePosition(self.Caret, 1)}))
				end
			end
		elseif code == KEY_PAGEUP then --
			self.Caret.x = math_max( self.Caret.x - math_ceil(self.Size.x / 2), 1 )
			self.Caret.y = math_min( self.Caret.y, #self.Rows[self.Caret.x] + 1 )

			self.Scroll.x = math_max( self.Scroll.x - math_ceil(self.Size.x / 2), 1 )

			self:ScrollCaret()

			if !shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_PAGEDOWN then
			self.Caret.x = math_min( self.Caret.x + math_ceil(self.Size.x / 2), #self.Rows )
			self.Caret.y = self.Caret.x == #self.Rows and 1 or math_min( self.Caret.y, #self.Rows[self.Caret.x] + 1 )

			self.Scroll.x = self.Scroll.x + math_ceil(self.Size.x / 2)

			self:ScrollCaret()

			if !shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_HOME then
			local row = self.Rows[self.Caret.x]
			local first_char = string_find( row, "%S" ) or string_len( row ) + 1
			self.Caret.y = self.Caret.y == first_char and 1 or first_char

			self:ScrollCaret()

			if !shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		elseif code == KEY_END then
			self.Caret.y = #self.Rows[self.Caret.x] + 1

			self:ScrollCaret()

			if !shift then
				self.Start = self:CopyPosition(self.Caret)
			end
		end --
	end

	if code == KEY_TAB and ( !shift or !control ) then 
		if self:HasSelection() then //TODO
		else 
			self:SetSelection( string_rep( " ", (self.Caret.y) % 4 + 1 ) )
		end
		self.TabFocus = true 
	end
end

function PANEL:_OnTextChanged( )
	local ctrlv = false
	local text = self.TextEntry:GetValue()
	self.TextEntry:SetText("")

	if (input_IsKeyDown(KEY_LCONTROL) or input_IsKeyDown(KEY_RCONTROL)) and not (input_IsKeyDown(KEY_LALT) or input_IsKeyDown(KEY_RALT)) then
		-- ctrl+[shift+]key
		if input_IsKeyDown(KEY_V) then
			-- ctrl+[shift+]V
			ctrlv = true
		else
			-- ctrl+[shift+]key with key ~= V
			return
		end
	end

	if text == "" then return end
	if not ctrlv then
		if text == "\n" then return end
	end

	self:SetSelection(text)
	self:ScrollCaret() 
end

function PANEL:_OnLoseFocus( )
	if self.TabFocus then
		self:RequestFocus()
		self.TabFocus = nil
	end
end

/*---------------------------------------------------------------------------
Mouse stuff
---------------------------------------------------------------------------*/

function PANEL:OnMousePressed( code )
	if code == MOUSE_LEFT then 
		self.LastClick = CurTime()
		self:RequestFocus()
		self.Blink = RealTime()
		self.MouseDown = true

		self.Caret = self:CursorToCaret( )
		if !input_IsKeyDown(KEY_LSHIFT) and !input_IsKeyDown(KEY_RSHIFT) then
			self.Start = self:CopyPosition( self.Caret )
		end
	end
end

function PANEL:OnMouseReleased( code )
	if !self.MouseDown then return end

	if code == MOUSE_LEFT then
		self.MouseDown = nil
		self.Caret = self:CursorToCaret()
	end
end

function PANEL:OnMouseWheeled( delta ) 
	self.Scroll:Add( - 4 * delta, 0 )
	if(self.Scroll.x < 1) then self.Scroll.x = 1 end
	if(self.Scroll.x > #self.Rows) then self.Scroll.x = #self.Rows end
	self.ScrollBar:SetScroll(self.Scroll.x - 1)
end

/*---------------------------------------------------------------------------
Paint stuff
---------------------------------------------------------------------------*/

function PANEL:Paint( )
	local w, h = self:GetSize()
	self.LineNumberWidth = self.FontWidth * string_len(tostring(math_min(self.Scroll.x, #self.Rows - self.Size.x + 1) + self.Size.x - 1))
	
	if !input_IsMouseDown(MOUSE_LEFT) then
		self:OnMouseReleased(MOUSE_LEFT)
	end

	if !self.PaintRows then
		self.PaintRows = {}
	end

	if self.MouseDown then
		self.Caret = self:CursorToCaret()
	end
	
	self.Scroll.x = math_floor(self.ScrollBar:GetScroll() + 1)

	surface_SetDrawColor(160,160,160,255)
	surface_DrawRect(0-10,0-10,self:GetWide()+20,self:GetTall()+20)
	
	self:DrawText( w, h )

	self:PaintTextOverlay()

	local str = "Length: " .. #self:GetCode() .. " Lines: " .. #self.Rows .. " Line: " .. self.Caret.x .. " Column: " .. self.Caret.y
	if (self:HasSelection()) then str = str .. " Selection: " .. #self:GetSelection() end
	surface_SetFont( "Default" )
	local w,h = surface_GetTextSize( str )
	local _w, _h = self:GetSize()
	draw_WordBox( 4, _w - w - 10 - ( self.ScrollBar.Enabled and 16 or 0 ), _h - h - 10, str, "Default", Color( 0,0,0,100 ), Color( 255,255,255,255 ) )
end

function PANEL:PaintTextOverlay( )
	if self.TextEntry:HasFocus() and self.Caret.y - self.Scroll.y >= 0 then
		local width, height = self.FontWidth, self.FontHeight

		if (RealTime() - self.Blink) % 0.8 < 0.4 then
			surface_SetDrawColor(240, 240, 240, 255)
			surface_DrawRect((self.Caret.y - self.Scroll.y) * width + self.LineNumberWidth + 10, (self.Caret.x - self.Scroll.x) * height, 1, height)
		end
	end
end

C_white = Color( 255, 255, 255 )
C_black = Color( 0, 0, 0 )
C_red = Color( 255, 0, 0 )

function PANEL:DrawText( w, h )
	surface_SetFont( "Fixedsys" )

	surface_SetDrawColor(0, 0,0, 255)
	surface_DrawRect(0, 0, self.LineNumberWidth + 9, self:GetTall())

	surface_SetDrawColor(32, 32, 32, 255)
	surface_DrawRect(self.LineNumberWidth + 9, 0, self:GetWide() - (self.LineNumberWidth + 9), self:GetTall())

	for i = self.Scroll.x, self.Scroll.x + self.Size.x + 1 do
		self:PaintRow(i)
	end
end

function PANEL:PaintRow( Row )
	if Row > #self.Rows then return end
	
	if Row == self.Caret.x and self.TextEntry:HasFocus() then
		surface_SetDrawColor(48, 48, 48, 255)
		surface_DrawRect(self.LineNumberWidth + 9, (Row - self.Scroll.x) * self.FontHeight, self:GetWide() - (self.LineNumberWidth + 9) , self.FontHeight)
	end

	if self:HasSelection() then 
		local start, stop = self:MakeSelection(self:Selection())
		local line, char = start.x, start.y
		local endline, endchar = stop.x, stop.y

		char = char - self.Scroll.y
		endchar = endchar - self.Scroll.y
		
		if char < 0 then char = 0 end
		if endchar < 0 then endchar = 0 end

		local length = self.Rows[Row]:len() - self.Scroll.y + 1

		surface_SetDrawColor(0, 0, 160, 255)
		if Row == line and line == endline then 
			surface_DrawRect( 
				char * self.FontWidth + self.LineNumberWidth + 9, 
				(Row - self.Scroll.x) * self.FontHeight, 
				self.FontWidth * (endchar - char), 
				self.FontHeight 
			)
		elseif Row == line then 
			surface_DrawRect( 
				char * self.FontWidth + self.LineNumberWidth + 9, 
				(Row - self.Scroll.x) * self.FontHeight, 
				self.FontWidth * math_min(self.Size.y - char, length - char + 1), 
				self.FontHeight 
			)
		elseif Row == endline then 
			surface_DrawRect( 
				self.LineNumberWidth + 9, 
				(Row - self.Scroll.x) * self.FontHeight, 
				self.FontWidth * endchar, 
				self.FontHeight 
			) 
		elseif Row > line and Row < endline then 
			length = math_max(math_min( length, self.Size.y ), -1 )
			surface_DrawRect(
				self.LineNumberWidth + 9, 
				(Row - self.Scroll.x) * self.FontHeight, 
				self.FontWidth * (length + 1), 
				self.FontHeight 
			)
		end
	end

	draw_SimpleText(tostring(Row), "Fixedsys", self.LineNumberWidth + 3, self.FontHeight * (Row - self.Scroll.x),  C_white, TEXT_ALIGN_RIGHT)

	local offset = math_max( self.Scroll.y, 1 )

	surface_SetTextColor( C_white )
	surface_SetTextPos( self.LineNumberWidth + 10, (Row - self.Scroll.x) * self.FontHeight )
	surface_DrawText( self.Rows[Row]:sub( offset, offset + self.Size.y+1 ) )
end

/*---------------------------------------------------------------------------
Text setters/getters
---------------------------------------------------------------------------*/

function PANEL:SetCode( Text )
	self.ScrollBar:SetScroll(0)

	self.Rows = string_Explode("\n", Text)
	if self.Rows[#self.Rows] != "" then
		self.Rows[#self.Rows + 1] = ""
	end

	self.Caret = Vector2(1, 1)
	self.Start = Vector2(1, 1)
	self.Scroll = Vector2(1, 1)
	self.Undo = {}
	self.Redo = {}

	self.ScrollBar:SetUp(self.Size.x, #self.Rows + (math_floor(self:GetTall() / self.FontHeight) - 2) )
end

function PANEL:GetCode( )
	return string_gsub( table_concat( self.Rows, "\n" ), "\r", "" )
end

function PANEL:OnTextChanged( )
end

/*---------------------------------------------------------------------------
PerformLayout
---------------------------------------------------------------------------*/

function PANEL:PerformLayout( )
	self.ScrollBar:SetSize(16, self:GetTall())
	self.ScrollBar:SetPos(self:GetWide() - self.ScrollBar:GetWide(), 0)

	self.Size.x = math_floor(self:GetTall() / self.FontHeight) - 1
	self.Size.y = math_floor((self:GetWide() - (self.LineNumberWidth + 10) - self.ScrollBar:GetWide()) / self.FontWidth) - 1

	self.ScrollBar:SetUp(self.Size.x, #self.Rows + (math_floor(self:GetTall() / self.FontHeight) - 2))
end

vgui.Register( "EA_Editor", PANEL, "EditablePanel" )