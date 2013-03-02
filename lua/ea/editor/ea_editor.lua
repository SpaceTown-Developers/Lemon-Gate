/*=============================================================================
	Expression-Advanced TextEditor
	Author: Oskar
	Credits: Andreas "Syranide" Svensson for making the E2 editor
=============================================================================*/

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
local string_gmatch 		= string.gmatch

local table_remove 			= table.remove 
local table_insert 			= table.insert 
local table_concat 			= table.concat
local table_Count 			= table.Count 
local table_KeysFromValue 	= table.KeysFromValue 

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

local PANEL = { }

function PANEL:Init( )
	self:SetCursor( "beam" )
	
	self.Rows = { "" }
	
	self.Undo = { }
	self.Redo = { }
	self.PaintRows = { }
	self.Chunks = { }
	self.FoldButtons = { }
	self.FoldData = { } 
	self.FoldedRows = { } 
	self.Insert = false 
	
	self.Blink = RealTime( )
	self.BookmarkWidth = 16
	self.LineNumberWidth = 2
	self.FoldingWidth = 16 
	self.CaretRow = 0 
	
	self.TextEntry = self:Add( "TextEntry" ) 
	self.TextEntry:SetMultiline( true )
	self.TextEntry:SetSize( 0, 0 )
	
	self.TextEntry.m_bDisableTabbing = true // OH GOD YES!!!!! NO MORE HACKS!!!
	self.TextEntry.OnTextChanged = function( ) self:_OnTextChanged( ) end
	self.TextEntry.OnKeyCodeTyped = function( _, code ) self:_OnKeyCodeTyped( code ) end 
	
	self.Caret = Vector2( 1, 1 )
	self.Start = Vector2( 1, 1 )
	self.Scroll = Vector2( 1, 1 )
	self.Size = Vector2( 1, 1 )
	
	self.ScrollBar = self:Add( "DVScrollBar" )
	self.ScrollBar:SetUp( 1, 1 ) 
	
	surface_SetFont( "Fixedsys" )
	self.FontWidth, self.FontHeight = surface_GetTextSize( " " )
end

function PANEL:RequestFocus( )
	self.TextEntry:RequestFocus( )
end

function PANEL:OnGetFocus( )
	self.TextEntry:RequestFocus( )
end

/*---------------------------------------------------------------------------
Cursor functions
---------------------------------------------------------------------------*/

local function GetFoldingOffset( self, Row ) do return 0 end 
	local offset = 0 
	local pos = 1
	
	while pos < Row or self.FoldedRows[pos] do 
		if self.FoldedRows[pos] then 
			offset = offset + 1 
			Row = Row + 1
		end 
		pos = pos + 1
	end 
	
	return offset 
end 

function PANEL:CursorToCaret( ) 
	local x, y = self:CursorPos( ) 

	x = x - ( self.BookmarkWidth + self.LineNumberWidth + self.FoldingWidth ) 
	if x < 0 then x = 0 end 
	if y < 0 then y = 0 end 

	local line = math_floor( y / self.FontHeight ) 
	line = line + GetFoldingOffset( self, line + self.Scroll.x ) 
	local char = math_floor( x / self.FontWidth + 0.5 ) 

	line = line + self.Scroll.x 
	char = char + self.Scroll.y 

	if line > #self.Rows then line = #self.Rows end 
	local length = #self.Rows[line] 
	if char > length + 1 then char = length + 1 end 

	return Vector2( line, char ) 
end

function PANEL:SetCaret( caret )
	self.Caret = self:CopyPosition( caret )
	self.Start = self:CopyPosition( caret )
	self:ScrollCaret( )
end

function PANEL:CopyPosition( caret )
	return Vector2( caret( ) )
end

function PANEL:MovePosition( caret, offset )
	local caret = self:CopyPosition( caret ) 

	if offset > 0 then
		while true do
			local length = #self.Rows[caret.x] - caret.y + 2
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
				caret.y = #self.Rows[caret.x] + 1
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

	self.ScrollBar:SetScroll( self.Scroll.x - 1 )
end

/*---------------------------------------------------------------------------
Selection stuff
---------------------------------------------------------------------------*/

function PANEL:HasSelection( )
	return self.Caret != self.Start
end

function PANEL:Selection( )
	return { Vector2( self.Caret( ) ), Vector2( self.Start( ) ) }
end

function PANEL:GetSelection( )
	return self:GetArea( self:Selection( ) )
end

function PANEL:SetSelection( text )
	self:SetCaret( self:SetArea( self:Selection( ), text ) )
end

function PANEL:MakeSelection( selection )
	local start, stop = selection[1], selection[2]

	if start.x < stop.x or ( start.x == stop.x and start.y < stop.y ) then
		return start, stop
	else
		return stop, start
	end
end

function PANEL:GetArea( selection )
	local start, stop = self:MakeSelection( selection )

	if start.x == stop.x then 
		if self.Insert and start.y == stop.y then 
			MsgN( ":D" )
			MsgN( "'" .. string_sub( self.Rows[start.x], start.y, start.y ) .. "'" )
			print( selection[1] )
			print( selection[2] )
			
			selection[2].y = selection[2].y + 1 
			
			return string_sub( self.Rows[start.x], start.y, start.y )
		else 
			return string_sub( self.Rows[start.x], start.y, stop.y - 1 )
		end 
	else
		local text = string_sub( self.Rows[start.x], start.y )

		for i = start.x + 1, stop.x - 1 do
			text = text .. "\n" .. self.Rows[i]
		end

		return text .. "\n" .. string_sub( self.Rows[stop.x], 1, stop.y - 1 )
	end
end

function PANEL:SetArea( selection, text, isundo, isredo, before, after ) 
	local buffer = self:GetArea( selection )
	local start, stop = self:MakeSelection( selection )
		
	if start != stop then
		// clear selection
		self.Rows[start.x] = string_sub( self.Rows[start.x], 1, start.y - 1 ) .. string_sub( self.Rows[stop.x], stop.y )
		
		for i = start.x + 1, stop.x do
			table_remove( self.Rows, start.x + 1 )
		end
	end
	
	if !text or text == "" then
		self.ScrollBar:SetUp( self.Size.x, #self.Rows + ( math_floor( self:GetTall( ) / self.FontHeight ) - 2 ) - table_Count( table_KeysFromValue( self.FoldedRows, true ) ))
		self.PaintRows = { }
		self:OnTextChanged( )
		
		if isredo then
			self.Undo[#self.Undo + 1] = { { self:CopyPosition( start ), self:CopyPosition( start ) }, 
				buffer, after, before }
			return before
		elseif isundo then
			self.Redo[#self.Redo + 1] = { { self:CopyPosition( start ), self:CopyPosition( start ) }, 
				buffer, after, before }
			return before
		else
			self.Redo = { }
			self.Undo[#self.Undo + 1] = { { self:CopyPosition( start ), self:CopyPosition( start ) }, 
				buffer, self:CopyPosition( selection[1] ), self:CopyPosition( start ) }
			return start
		end
	end
	
	// insert text
	local rows = string_Explode( "\n", text )
	
	local remainder = string_sub( self.Rows[start.x], start.y )
	self.Rows[start.x] = string_sub( self.Rows[start.x], 1, start.y - 1 ) .. rows[1]
	
	for i = 2, #rows do
		table_insert( self.Rows, start.x + i - 1, rows[i] )
	end
	
	local stop = Vector2( start.x + #rows - 1, #( self.Rows[start.x + #rows - 1] ) + 1 )
	
	self.Rows[stop.x] = self.Rows[stop.x] .. remainder
	
	self.ScrollBar:SetUp( self.Size.x, #self.Rows + ( math_floor( self:GetTall( ) / self.FontHeight ) - 2 ) - table_Count( table_KeysFromValue( self.FoldedRows, true ) ))
	self.PaintRows = { }
	self:OnTextChanged( )
	
	if isredo then
		self.Undo[#self.Undo + 1] = { { self:CopyPosition( start ), self:CopyPosition( stop ) }, 
			buffer, after, before }
		return before
	elseif isundo then
		self.Redo[#self.Redo + 1] = { { self:CopyPosition( start ), self:CopyPosition( stop ) }, 
			buffer, after, before }
		return before
	else
		self.Redo = { }
		self.Undo[#self.Undo + 1] = { { self:CopyPosition( start ), self:CopyPosition( stop ) }, 
			buffer, self:CopyPosition( selection[1] ), self:CopyPosition( stop ) }
		return stop
	end
end

function PANEL:SelectAll( )
	self.Caret = Vector2( #self.Rows, #self.Rows[#self.Rows] + 1 )
	self.Start = Vector2( 1, 1 )
	self:ScrollCaret( )
end

function PANEL:CanUndo( )
	return #self.Undo > 0 
end

function PANEL:DoUndo( )
	if #self.Undo > 0 then
		local undo = self.Undo[#self.Undo]
		self.Undo[#self.Undo] = nil

		self:SetCaret( self:SetArea( undo[1], undo[2], true, false, undo[3], undo[4] ) ) 
	end
end

function PANEL:CanRedo( )
	return #self.Redo > 0 
end

function PANEL:DoRedo( )
	if #self.Redo > 0 then
		local redo = self.Redo[#self.Redo]
		self.Redo[#self.Redo] = nil

		self:SetCaret( self:SetArea( redo[1], redo[2], false, true, redo[3], redo[4] ) ) 
	end
end

function PANEL:wordLeft( caret )
	local row = self.Rows[caret.x] or ""
	if caret.y == 1 then
		if caret.x == 1 then return caret end
		caret = Vector2( caret.x-1, #self.Rows[caret.x-1] )
		row = self.Rows[caret.x]
	end
	local pos = row:sub( 1, caret.y - 1 ):match( "[^%w@]()[%w@]+[^%w@]*$" )
	caret.y = pos or 1
	return caret
end

function PANEL:wordRight( caret )
	local row = self.Rows[caret.x] or ""
	if caret.y > #row then
		if caret.x == #self.Rows then return caret end
		caret = Vector2( caret.x + 1, 1 )
		row = self.Rows[caret.x]
		if row:sub( 1, 1 ) ~= " " then return caret end
	end
	local pos = row:match( "[^%w@]()[%w@]", caret.y )
	caret.y = pos or ( #row + 1 )
	return caret
end

function PANEL:wordStart( caret, getword )
	local line = self.Rows[caret.x] 
	
	for startpos, endpos in string_gmatch( line, "()[a-zA-Z0-9_]+()" ) do 
		if startpos <= caret.y and endpos >= caret.y then 
			return Vector2( caret.x, startpos )
		end 
	end 
	
	return Vector2( caret.x, 1 )
end

function PANEL:wordEnd( caret, getword )
	local line = self.Rows[caret.x] 
	
	for startpos, endpos in string_gmatch( line, "()[a-zA-Z0-9_]+()" ) do 
		if startpos <= caret.y and endpos >= caret.y then 
			return Vector2( caret.x, endpos )
		end 
	end 
	
	return Vector2( caret.x, caret.y - 1 )
end

/*---------------------------------------------------------------------------
TextEntry hooks
---------------------------------------------------------------------------*/

function PANEL:_OnKeyCodeTyped( code ) 
	self.Blink = RealTime( )

	local alt = input_IsKeyDown( KEY_LALT ) or input_IsKeyDown( KEY_RALT )
	if alt then return end

	local shift = input_IsKeyDown( KEY_LSHIFT ) or input_IsKeyDown( KEY_RSHIFT )
	local control = input_IsKeyDown( KEY_LCONTROL ) or input_IsKeyDown( KEY_RCONTROL )

	-- allow ctrl-ins and shift-del ( shift-ins, like ctrl-v, is handled by vgui )
	if not shift and control and code == KEY_INSERT then
		shift, control, code = true, false, KEY_C
	elseif shift and not control and code == KEY_DELETE then
		shift, control, code = false, true, KEY_X
	end

	if control then
		if code == KEY_A then
			self:SelectAll( ) 
		elseif code == KEY_Z then
			self:DoUndo( )
		elseif code == KEY_Y then
			self:DoRedo( )
		elseif code == KEY_X then
			if self:HasSelection( ) then
				local clipboard = self:GetSelection( )
				clipboard = string_gsub( clipboard, "\n", "\r\n" )
				SetClipboardText( clipboard )
				self:SetSelection( )
			end
		elseif code == KEY_C then
			if self:HasSelection( ) then
				local clipboard = self:GetSelection( )
				clipboard = string_gsub( clipboard, "\n", "\r\n" )
				SetClipboardText( clipboard )
			end
		elseif code == KEY_Q then
			self:GetParent( ):GetParent( ):Close( )
		elseif code == KEY_T then
			self:GetParent( ):GetParent( ):NewTab( )
		elseif code == KEY_W then
			self:GetParent( ):GetParent( ):CloseTab( )
		elseif code == KEY_S then // Save
			if shift then // ctrl+shift+s
				self:GetParent( ):GetParent( ):SaveFile( nil, true )
			else // ctrl+s
				self:GetParent( ):GetParent( ):SaveFile( )
			end 
		elseif code == KEY_UP then
			self.Scroll.x = self.Scroll.x - 1
			if self.Scroll.x < 1 then self.Scroll.x = 1 end
			self.ScrollBar:SetScroll( self.Scroll.x -1 )
		elseif code == KEY_DOWN then
			self.Scroll.x = self.Scroll.x + 1
			self.ScrollBar:SetScroll( self.Scroll.x -1 )
		elseif code == KEY_LEFT then
			if self:HasSelection( ) and not shift then
				self.Start = self:CopyPosition( self.Caret )
			else
				self.Caret = self:wordLeft( self.Caret )
			end

			self:ScrollCaret( )

			if not shift then
				self.Start = self:CopyPosition( self.Caret )
			end
		elseif code == KEY_RIGHT then
			if self:HasSelection( ) and !shift then
				self.Start = self:CopyPosition( self.Caret )
			else
				self.Caret = self:wordRight( self.Caret )
			end

			self:ScrollCaret( )

			if !shift then
				self.Start = self:CopyPosition( self.Caret )
			end
		elseif code == KEY_HOME then
			self.Caret = Vector2( 1, 1 )

			self:ScrollCaret( )

			if !shift then
				self.Start = self:CopyPosition( self.Caret )
			end
		elseif code == KEY_END then
			self.Caret = Vector2( #self.Rows, 1 )

			self:ScrollCaret( )

			if !shift then
				self.Start = self:CopyPosition( self.Caret )
			end
		elseif code == KEY_D then
			-- Save current selection
			local old_start = self:CopyPosition( self.Start )
			local old_end = self:CopyPosition( self.Caret )
			local old_scroll = self:CopyPosition( self.Scroll )

			local str = self:GetSelection( )
			if ( str != "" ) then -- If you have a selection
				self:SetSelection( str:rep( 2 ) ) -- Repeat it
			else -- If you don't
				-- Select the current line
				self.Start = Vector2( self.Start.x, 1 )
				self.Caret = Vector2( self.Start.x, #self.Rows[self.Start.x]+1 )
				-- Get the text
				local str = self:GetSelection( )
				-- Repeat it
				self:SetSelection( str .. "\n" .. str )
			end

			-- Restore selection
			self.Caret = old_end
			self.Start = old_start
			self.Scroll = old_scroll
			self:ScrollCaret( )
		elseif code == KEY_SPACE then 
			self:GetParent( ):GetParent( ):DoValidate( true ) 
		end
	else
		if code == KEY_ENTER then
			self:SetSelection( "\n" )
		elseif code == KEY_INSERT then 
			self.Insert = !self.Insert
		elseif code == KEY_UP then
			if self.Caret.x > 1 then
				self.Caret.x = self.Caret.x - 1

				local length = #( self.Rows[self.Caret.x] )
				if self.Caret.y > length + 1 then
					self.Caret.y = length + 1
				end
			end

			self:ScrollCaret( )
			if !shift then
				self.Start = self:CopyPosition( self.Caret )
			end
		elseif code == KEY_DOWN then
			if self.Caret.x < #self.Rows then
				self.Caret.x = self.Caret.x + 1

				local length = #( self.Rows[self.Caret.x] )
				if self.Caret.y > length + 1 then
					self.Caret.y = length + 1
				end
			end

			self:ScrollCaret( )
			if !shift then
				self.Start = self:CopyPosition( self.Caret )
			end
		elseif code == KEY_LEFT then
			self.Caret = self:MovePosition( self.Caret, -1 )
			self:ScrollCaret( )
			if !shift then
				self.Start = self:CopyPosition( self.Caret )
			end
		elseif code == KEY_RIGHT then
			self.Caret = self:MovePosition( self.Caret, 1 )
			self:ScrollCaret( )
			if !shift then
				self.Start = self:CopyPosition( self.Caret )
			end
		elseif code == KEY_BACKSPACE then
			if self:HasSelection( ) then
				self:SetSelection( )
			else
				local buffer = self:GetArea( { self.Caret, Vector2( self.Caret.x, 1 ) } )
				if self.Caret.y % 4 == 1 and #( buffer ) > 0 and string_rep( " ", #( buffer ) ) == buffer then
					self:SetCaret( self:SetArea( { self.Caret, self:MovePosition( self.Caret, -4 ) } ) )
				else
					self:SetCaret( self:SetArea( { self.Caret, self:MovePosition( self.Caret, -1 ) } ) )
				end
			end
		elseif code == KEY_DELETE then
			if self:HasSelection( ) then
				self:SetSelection( )
			else
				local buffer = self:GetArea( { Vector2( self.Caret.x, self.Caret.y + 4 ), Vector2( self.Caret.x, 1 ) } )
				if self.Caret.y % 4 == 1 and string_rep( " ", #( buffer ) ) == buffer and #( self.Rows[self.Caret.x] ) >= self.Caret.y + 4 - 1 then
					self:SetCaret( self:SetArea( { self.Caret, self:MovePosition( self.Caret, 4 ) } ) )
				else
					self:SetCaret( self:SetArea( { self.Caret, self:MovePosition( self.Caret, 1 ) } ) )
				end
			end
		elseif code == KEY_PAGEUP then --
			self.Caret.x = math_max( self.Caret.x - math_ceil( self.Size.x / 2 ), 1 )
			self.Caret.y = math_min( self.Caret.y, #self.Rows[self.Caret.x] + 1 )

			self.Scroll.x = math_max( self.Scroll.x - math_ceil( self.Size.x / 2 ), 1 )

			self:ScrollCaret( )

			if !shift then
				self.Start = self:CopyPosition( self.Caret )
			end
		elseif code == KEY_PAGEDOWN then
			self.Caret.x = math_min( self.Caret.x + math_ceil( self.Size.x / 2 ), #self.Rows )
			self.Caret.y = self.Caret.x == #self.Rows and 1 or math_min( self.Caret.y, #self.Rows[self.Caret.x] + 1 )

			self.Scroll.x = self.Scroll.x + math_ceil( self.Size.x / 2 )

			self:ScrollCaret( )

			if !shift then
				self.Start = self:CopyPosition( self.Caret )
			end
		elseif code == KEY_HOME then
			local row = self.Rows[self.Caret.x]
			local first_char = string_find( row, "%S" ) or string_len( row ) + 1
			self.Caret.y = self.Caret.y == first_char and 1 or first_char

			self:ScrollCaret( )

			if !shift then
				self.Start = self:CopyPosition( self.Caret )
			end
		elseif code == KEY_END then
			self.Caret.y = #self.Rows[self.Caret.x] + 1

			self:ScrollCaret( )

			if !shift then
				self.Start = self:CopyPosition( self.Caret )
			end
		elseif code == KEY_F2 then // F-Keys is broken atm! D: 
			print( ":D" ) 
		end 
	end

	if code == KEY_TAB and ( !shift or !control ) then 
		if self:HasSelection( ) then //TODO
		else 
			self:SetSelection( string_rep( " ", ( self.Caret.y + 2 ) % 4 + 1 ) )
		end
	end
	
end

function PANEL:_OnTextChanged( ) 
	local ctrlv = false
	local text = self.TextEntry:GetValue( )
	self.TextEntry:SetText( "" )

	if ( input_IsKeyDown( KEY_LCONTROL ) or input_IsKeyDown( KEY_RCONTROL ) ) and not ( input_IsKeyDown( KEY_LALT ) or input_IsKeyDown( KEY_RALT ) ) then
		-- ctrl+[shift+]key
		if input_IsKeyDown( KEY_V ) then
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

	self:SetSelection( text )
	self:ScrollCaret( ) 
end

/*---------------------------------------------------------------------------
Mouse stuff
---------------------------------------------------------------------------*/

function PANEL:OnMousePressed( code )
	if self.MouseDown then return end 
	
	if code == MOUSE_LEFT then 
		local cursor = self:CursorToCaret( ) 
		if self.LastClick and CurTime( ) - self.LastClick < 0.6 and ( self.Caret == cursor or self.LastCursor == cursor ) then 
			if self.temp then // TODO Triple click!
				self.temp = nil 
				
				self.Start = Vector2( cursor.x, 1 )
				self.Caret = Vector2( cursor.x, #self.Rows[cursor.x] + 1 )
			else 
				self.temp = true 
				
				self.Start = self:wordStart( cursor )
				self.Caret = self:wordEnd( cursor )
			end 
			
			self.LastClick = CurTime( )
			self.LastCursor = cursor
			self:RequestFocus( )
			self.Blink = RealTime( )
			return 
		end 
		
		self.temp = nil 
		self.LastClick = CurTime( )
		self.LastCursor = cursor
		self:RequestFocus( )
		self.Blink = RealTime( )
		self.MouseDown = MOUSE_LEFT 
		
		self.Caret = self:CursorToCaret( )
		if !input_IsKeyDown( KEY_LSHIFT ) and !input_IsKeyDown( KEY_RSHIFT ) then
			self.Start = self:CopyPosition( self.Caret )
		end
	elseif code == MOUSE_RIGHT then 
		self.MouseDown = MOUSE_RIGHT 
		
		self:MouseCapture( true ) 
	end
end

function PANEL:OnMouseReleased( code )
	if code == MOUSE_LEFT and self.MouseDown == code then
		self.MouseDown = nil
		self.Caret = self:CursorToCaret( )
	elseif code == MOUSE_RIGHT and self.MouseDown == code then 
		self.MouseDown = nil
		self:MouseCapture( false )
		
		if vgui.GetHoveredPanel( ) == self then 
			local Menu = DermaMenu( )
			
			if self:HasSelection() then 
				Menu:AddOption( "Copy", function( ) 
					local clipboard = self:GetSelection( ) 
					clipboard = string_gsub( clipboard, "\n", "\r\n" ) 
					SetClipboardText( clipboard ) 
				end ) 
				
				Menu:AddOption( "Cut", function( ) 
					local clipboard = self:GetSelection( ) 
					clipboard = string_gsub( clipboard, "\n", "\r\n" ) 
					SetClipboardText( clipboard ) 
					self:SetSelection( ) 
				end ) 
			end 
			
			-- Menu:AddOption( "Paste", function( ) 
			-- end ) 
			
			Menu:AddSpacer( ) 
			
			Menu:AddOption( "Select All", function( ) 
				self:SelectAll( ) 
			end )
			
			Menu:Open( )
		end 
	end
end

function PANEL:OnMouseWheeled( delta ) 
	self.Scroll:Add( - 4 * delta, 0 )
	if self.Scroll.x < 1 then self.Scroll.x = 1 end
	if self.Scroll.x > #self.Rows then self.Scroll.x = #self.Rows end
	self.ScrollBar:SetScroll( self.Scroll.x - 1 )
end

/*---------------------------------------------------------------------------
Paint stuff
---------------------------------------------------------------------------*/

local function ParseIndents( Rows, exit ) 
	local foldData = { }
	local level = 0
	for line = 1, #Rows do
		if line == exit then break end 
		local text = Rows[line] 
		foldData[line] = 0 //level 
		for nStart, sType, nEnd in string.gmatch( text, "()([{}])()") do 
			level = level + ( sType == "{" and 1 or -1 ) 
		end 
	end
	return foldData 
end 

function PANEL:Paint( w, h )
	self.LineNumberWidth = 6 + self.FontWidth * string_len( tostring( math_min( self.Scroll.x, #self.Rows - self.Size.x + 1 ) + self.Size.x - 1 ) )
	
	if !input_IsMouseDown( MOUSE_LEFT ) and self.MouseDown == MOUSE_LEFT then
		self:OnMouseReleased( MOUSE_LEFT )
	end
	
	-- if !self.PaintRows then
	-- 	self.PaintRows = { }
	-- end 
	self.PaintRows = self.PaintRows or { } 
	
	if self.MouseDown and self.MouseDown == MOUSE_LEFT then
		self.Caret = self:CursorToCaret( )
	end
	
	local offset = table_Count( table_KeysFromValue( self.FoldedRows, true ) )
	
	local n = #self.Rows + ( math_floor( self:GetTall( ) / self.FontHeight ) - 2 ) - offset
	
	// Disabled
	if self.CanvasSize ~= n and false then 
		self.ScrollBar:SetUp( self.Size.x, n ) 
		-- self.ScrollBar:InvalidateLayout( true ) 
		self.CanvasSize = n 
	end 
	
	self.Scroll.x = math_floor( self.ScrollBar:GetScroll( ) + 1 )
	
	self:DrawText( w, h )
	
	self:PaintTextOverlay( )
	
	/*local str = "Length: " .. #self:GetCode( ) .. " Lines: " .. #self.Rows .. " Row: " .. self.Caret.x .. " Col: " .. self.Caret.y
	if ( self:HasSelection( ) ) then str = str .. " Sel: " .. #self:GetSelection( ) end
	surface_SetFont( "Trebuchet18" )
	local w,h = surface_GetTextSize( str )
	local _w, _h = self:GetSize( )
	draw_WordBox( 4, _w - w - 10 - ( self.ScrollBar.Enabled and 16 or 0 ), _h - h - 10, str, "Trebuchet18", Color( 0,0,0,100 ), Color( 255,255,255,255 ) )*/
end

function PANEL:PaintTextOverlay( )
	if self.TextEntry:HasFocus( ) and self.Caret.y - self.Scroll.y >= 0 then
		local width, height = self.FontWidth, self.FontHeight

		if ( RealTime( ) - self.Blink ) % 0.8 < 0.4 then
			surface_SetDrawColor( 240, 240, 240, 255 )
			if self.Insert then 
				surface_DrawRect( ( self.Caret.y - self.Scroll.y ) * width + self.BookmarkWidth + self.LineNumberWidth + self.FoldingWidth, ( self.CaretRow + 1 ) * height, width, 1 )
			else 
				surface_DrawRect( ( self.Caret.y - self.Scroll.y ) * width + self.BookmarkWidth + self.LineNumberWidth + self.FoldingWidth, self.CaretRow * height, 1, height )
			end 
		end
	end
end

C_white = Color( 255, 255, 255 )
C_gray = Color( 160, 160, 160 )
-- C_black = Color( 0, 0, 0 )
-- C_red = Color( 255, 0, 0 )

function PANEL:DrawText( w, h )
	surface_SetFont( "Fixedsys" )
	
	surface_SetDrawColor( 0, 0, 0, 255 )
	surface_DrawRect( 0, 0, self.BookmarkWidth, self:GetTall( ) )
	surface_DrawRect( self.BookmarkWidth, 0, self.LineNumberWidth, self:GetTall( ) )
	
	-- surface_SetDrawColor( 64, 64, 64, 255 )
	surface_DrawRect( self.BookmarkWidth + self.LineNumberWidth, 0, self.FoldingWidth, self:GetTall( ) )
	
	surface_SetDrawColor( 32, 32, 32, 255 )
	surface_DrawRect( self.BookmarkWidth + self.LineNumberWidth + self.FoldingWidth, 0, self:GetWide( ) - ( self.BookmarkWidth + self.LineNumberWidth + self.FoldingWidth ), self:GetTall( ) )
	
	self.FoldData = ParseIndents( self.Rows )
	
	for i = 1, #self.Rows do
		if self.FoldButtons[i] and ValidPanel( self.FoldButtons[i] ) then 
			self.FoldButtons[i]:SetVisible( false )
		end 
	end
	
	local line = self.Scroll.x - 1 
	line = line + GetFoldingOffset( self, line + self.Scroll.x - 1 ) 
	
	while self.FoldedRows[line+1] do 
		line = line + 1 
	end 
	
	local painted = 0
	local hideLevel = 0
	while painted < self.Size.x + 1 do 
		line = line + 1
		if hideLevel == 0 then 
			if self.FoldButtons[line] then 
				local btn = self.FoldButtons[line] 
				if !btn.Expanded then 
					hideLevel = self.FoldData[line + 1] 
				end 
			end 
			self:PaintRowUnderlay( line, painted )
			self:PaintRow( line, painted )
			painted = painted + 1
			self.FoldedRows[line] = false 
		elseif !self.FoldData[line] or self.FoldData[line] < hideLevel then 
			hideLevel = 0 
			line = line - 1
			self.FoldedRows[line] = true 
		else 
			self.FoldedRows[line] = true 
		end 
	end 
	
	-- for i = self.Scroll.x, self.Scroll.x + self.Size.x + 1 do
	-- 	self:PaintRow( i )
	-- end
end

function PANEL:PaintRowUnderlay( Row, LinePos )
	if Row > #self.Rows then return end
	
	if Row == self.Caret.x and self.TextEntry:HasFocus( ) then
		surface_SetDrawColor( 48, 48, 48, 255 )
		surface_DrawRect( self.BookmarkWidth + self.LineNumberWidth + self.FoldingWidth, ( LinePos ) * self.FontHeight, self:GetWide( ) - ( self.BookmarkWidth + self.LineNumberWidth + self.FoldingWidth ) , self.FontHeight )
		self.CaretRow = LinePos 
	end
	
	if self:HasSelection( ) then 
		local start, stop = self:MakeSelection( self:Selection( ) )
		local line, char = start.x, start.y 
		local endline, endchar = stop.x, stop.y 
		
		char = char - self.Scroll.y
		endchar = endchar - self.Scroll.y
		
		if char < 0 then char = 0 end
		if endchar < 0 then endchar = 0 end
		
		local length = self.Rows[Row]:len( ) - self.Scroll.y + 1
		
		surface_SetDrawColor( 0, 0, 160, 255 )
		if Row == line and line == endline then 
			surface_DrawRect( 
				char * self.FontWidth + self.BookmarkWidth + self.LineNumberWidth + self.FoldingWidth, 
				( LinePos ) * self.FontHeight, 
				self.FontWidth * ( endchar - char ), 
				self.FontHeight 
			 )
		elseif Row == line then 
			surface_DrawRect( 
				char * self.FontWidth + self.BookmarkWidth + self.LineNumberWidth + self.FoldingWidth, 
				( LinePos ) * self.FontHeight, 
				self.FontWidth * math_min( self.Size.y - char + 2, length - char + 1 ), 
				self.FontHeight 
			 )
		elseif Row == endline then 
			surface_DrawRect( 
				self.BookmarkWidth + self.LineNumberWidth + self.FoldingWidth, 
				( LinePos ) * self.FontHeight, 
				self.FontWidth * endchar,  
				self.FontHeight 
			 ) 
		elseif Row > line and Row < endline then 
			surface_DrawRect( 
				self.BookmarkWidth + self.LineNumberWidth + self.FoldingWidth, 
				( LinePos ) * self.FontHeight, 
				self.FontWidth * math_min( self.Size.y + 2, length + 1 ),  
				self.FontHeight 
			 )
		end
	end
end 

function PANEL:PaintRow( Row, LinePos )
	if Row > #self.Rows then return end
	
	if Row < #self.Rows and self.FoldData[Row] < self.FoldData[Row+1] then 
		if !self.FoldButtons[Row] or !ValidPanel( self.FoldButtons[Row] ) then 
			local btn = self:Add( "EA_ImageButton" ) 
			btn:SetPos( self.BookmarkWidth + self.LineNumberWidth, ( LinePos ) * self.FontHeight ) 
			btn:SetIconCentered( true )
			btn:SetIconFading( false ) 
			btn.Expanded = true 
			btn:SetMaterial( Material( "oskar/minus.png" ) ) 
			
			local paint = btn.Paint 
			btn.Paint = function( _, w, h ) 
				surface.SetDrawColor = function() 
					surface_SetDrawColor( 150, 150, 150, 255 )
					if btn.Hovered then surface_SetDrawColor( 200, 200, 200, 255 ) end 
				end 
				paint( btn, w, h )
				surface.SetDrawColor = surface_SetDrawColor
			end 
			
			btn.DoClick = function( )
				if btn.Expanded then 
					btn:SetMaterial( Material( "oskar/plus.png" ) )
					btn.Expanded = false 
				else 
					btn:SetMaterial( Material( "oskar/minus.png" ) )
					btn.Expanded = true 
				end 
			end
			
			self.FoldButtons[Row] = btn 
		else 
			self.FoldButtons[Row]:SetVisible( true )
			self.FoldButtons[Row]:SetPos( self.BookmarkWidth + self.LineNumberWidth, ( LinePos ) * self.FontHeight ) 
		end 
	end 
	
	draw_SimpleText( tostring( Row ), "Fixedsys", self.BookmarkWidth + self.LineNumberWidth - 3, self.FontHeight * ( LinePos ), C_gray, TEXT_ALIGN_RIGHT ) 
	
	local offset = math_max( self.Scroll.y, 1 )
	
	if !self.PaintRows[Row] then 
		self.PaintRows[Row] = self:SyntaxColorLine( Row )
	end
	
	local offset = -self.Scroll.y + 1
	for i, cell in ipairs( self.PaintRows[Row] ) do
		if offset < 0 then
			if cell[1]:len( ) > -offset then
				line = cell[1]:sub( 1 - offset )
				offset = line:len( )
				draw_SimpleText( line .. " ", "Fixedsys", self.BookmarkWidth + self.LineNumberWidth + self.FoldingWidth, ( LinePos ) * self.FontHeight, cell[2] )
			else
				offset = offset + cell[1]:len( )
			end
		else
			draw_SimpleText( cell[1] .. " ", "Fixedsys", offset * self.FontWidth + self.BookmarkWidth + self.LineNumberWidth + self.FoldingWidth, ( LinePos ) * self.FontHeight, cell[2] )
			offset = offset + cell[1]:len( )
		end
	end
end

function PANEL:SyntaxColorLine( Row ) 
	return { { self.Rows[Row], C_white } }
end

/*---------------------------------------------------------------------------
Text setters / getters
---------------------------------------------------------------------------*/

function PANEL:SetCode( Text ) 
	self.ScrollBar:SetScroll( 0 ) 
	
	self.Rows = string_Explode( "\n", Text ) 
	
	self.Caret = Vector2( 1, 1 ) 
	self.Start = Vector2( 1, 1 ) 
	self.Scroll = Vector2( 1, 1 ) 
	self.Undo = { } 
	self.Redo = { } 
	self.PaintRows = { } 

	self.ScrollBar:SetUp( self.Size.x, #self.Rows + ( math_floor( self:GetTall( ) / self.FontHeight ) - 2 ) - table_Count( table_KeysFromValue( self.FoldedRows, true ) )) 
end 

function PANEL:GetCode( )
	local code = string_gsub( table_concat( self.Rows, "\n" ), "\r", "" )
	return code
end

function PANEL:OnTextChanged( )
end

/*---------------------------------------------------------------------------
PerformLayout
---------------------------------------------------------------------------*/

function PANEL:PerformLayout( )
	self.ScrollBar:SetSize( 16, self:GetTall( ) )
	self.ScrollBar:SetPos( self:GetWide( ) - self.ScrollBar:GetWide( ), 0 )

	self.Size.x = math_floor( self:GetTall( ) / self.FontHeight ) - 1
	self.Size.y = math_floor( ( self:GetWide( ) - ( self.BookmarkWidth + self.LineNumberWidth + self.FoldingWidth ) - self.ScrollBar:GetWide( ) ) / self.FontWidth ) - 1

	self.ScrollBar:SetUp( self.Size.x, #self.Rows + ( math_floor( self:GetTall( ) / self.FontHeight ) - 2 ) ) 
end

vgui.Register( "EA_Editor", PANEL, "EditablePanel" )