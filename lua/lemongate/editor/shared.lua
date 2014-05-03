/*============================================================================================================================================
	Server Side; TODO: Move this to serverside file!
============================================================================================================================================*/
if SERVER then
	local LEMON = LEMON

	LEMON.SharedSessions = { }
	local SharedSessions = LEMON.SharedSessions

	util.AddNetworkString( "lemon.shared.new" )
	util.AddNetworkString( "lemon.shared.removed" )
	util.AddNetworkString( "lemon.shared.invite" )
	util.AddNetworkString( "lemon.shared.joined" )
	util.AddNetworkString( "lemon.shared.left" )
	util.AddNetworkString( "lemon.shared.kicked" )

	local function GetSession( ID )
		return SharedSessions[ tonumber( ID ) ]
	end

	local function NewSession( Host, Name )
		local Session = { ID = #SharedSessions + 1 }
		
		if !Name or Name == "" then Name = nil end
		Session.Name = Name or ("Shared " .. Session.ID)

		Session.Host = Host
		Session.HostID = Host:UniqueID( )

		Session.Users = { [Host] = Host }
		Session.Invitees = { }

		SharedSessions[ Session.ID ] = Session

		net.Start( "lemon.shared.new" )
			net.WriteUInt( Session.ID, 16 )
			net.WriteString( Session.Name )
		net.Send( Host ) -- TODO: Make this add a shared tab for user.
	end

	concommand.Add( "lemon_editor_host", function( Player, Cmd, Args )
		NewSession( Player, Args[1] )
	end ) -- Create the new session.

	local function DeleteSession( Player, ID )
		local Session = GetSession( ID )
		if !Session or Session.Host ~= Player then return end

		SharedSessions[ Session.ID ] = nil

		for _, SendTo in pairs( Session.Users ) do
			net.Start( "lemon.shared.removed" )
				net.WriteUInt( Session.ID, 16 )
			net.Send( SendTo )
		end
	end

	local function InviteToSession( Player, ID, Invitee )
		local Session = GetSession( ID )
		if !Session or Session.Host ~= Player then return end

		if Session.Users[ Invitee ] then
			return -- Player already in session.
		elseif Session.Invitees[ Invitee ] then
			return -- Player already invited.
		else
			Session.Invitees[ Invitee ] = Invitee

			net.Start( "lemon.shared.invite" )
				net.WriteUInt( Session.ID, 16 )
				net.WriteString( Session.Name )
				net.WriteString( Session.Host:UniqueID( ) )
			net.Send( Invitee )
		end
	end

	concommand.Add( "lemon_editor_invite", function( Player, Cmd, Args )
		local Invitee = player.GetByUniqueID( Args[2] )
		if !IsValid( Invitee ) then return end

		InviteToSession( Player, Args[1], Invitee )
	end ) -- Invite a user to this session.

	local function JoinSession( Player, ID )
		local Session = GetSession( ID )
		if !Session or !Session.Invitees[ Player ] then return end

		for _, SendTo in pairs( Session.Users ) do
			net.Start( "lemon.shared.joined" )
				net.WriteUInt( Session.ID, 16 )
				net.WriteString( Player:UniqueID( ) )
			net.Send( SendTo )
		end

		Session.Users[ Player ] = Player
	end

	concommand.Add( "lemon_editor_join", function( Player, Cmd, Args )
		JoinSession( Player, Args[1] )
	end ) -- Add a user to this session.

	local function LeaveSession( Player, ID )
		local Session = GetSession( ID )
		if !Session or !Session.Users[ Player ] then return end

		if Session.Host == Player then
			return DeleteSession( Player, Session.ID )
		end

		for _, SendTo in pairs( Session.Users ) do
			net.Start( "lemon.shared.left" )
				net.WriteUInt( Session.ID, 16 )
				net.WriteString( Player:UniqueID( ) )
			net.Send( SendTo )
		end

		Session.Users[ Player ] = nil
	end

	concommand.Add( "lemon_editor_leave", function( Player, Cmd, Args )
		LeaveSession( Player, Args[1] )
	end ) -- Remove a user from this session.

	local function KickFromSession( Player, ID, Victim )
		local Session = GetSession( ID )
		if !Session or Session.Host ~= Player then return end

		if !Session.Users[ Player ] then return end

		LeaveSession( Victim, ID )

		net.Start( "lemon.shared.kicked" )
			net.WriteUInt( Session.ID, 16 )
		net.Send( Victim )
	end

	concommand.Add( "lemon_editor_kick", function( Player, Cmd, Args )
		local Victim = player.GetByUniqueID( Args[2] )
		if !IsValid( Victim ) then return end

		KickFromSession( Player, Args[1], Victim )
	end ) -- kick a user from this session.

	hook.Add( "PlayerDisconect", "Lemon.Shared.Editor", function( Player )
		for _, Session in pairs( SharedSessions ) do
			if Session.Host == Player then
				DeleteSession( Player, Session.ID )
			end
		end
	end )

	util.AddNetworkString( "lemon_editor_delta" )
	
	local function TransmitSessionDelta( Len, Player )
		local Session = GetSession( net.ReadUInt( 16 ) )
		local Delta = net.ReadTable( )

		if !Session or !Session.Users[ Player ] then return end

		for _, SendTo in pairs( Session.Users ) do
			if SendTo == Player then continue end

			net.Start( "lemon_editor_delta" )
				net.WriteUInt( Session.ID, 16 )
				net.WriteTable( Delta )
			net.Send( SendTo )
		end
	end
	
	net.Receive( "lemon_editor_delta", TransmitSessionDelta )

	util.AddNetworkString( "lemon_editor_cursor" )
	
	local function TransmitSessionCursor( Len, Player )
		local Session = GetSession( net.ReadUInt( 16 ) )
		local Cursor = net.ReadTable( )

		if !Session or !Session.Users[ Player ] then return end

		for _, SendTo in pairs( Session.Users ) do
			if SendTo == Player then continue end

			net.Start( "lemon_editor_cursor" )
				net.WriteUInt( Session.ID, 16 )
				net.WriteTable( Cursor )
			net.Send( SendTo )
		end
	end

	net.Receive( "lemon_editor_cursor", TransmitSessionCursor )

	util.AddNetworkString( "lemon_editor_relay" )

	local function RetransmitSession( Len, Player )
		local Session = GetSession( net.ReadUInt( 16 ) )
		local SendTo = player.GetByUniqueID( net.ReadString( ) )
		local Rows = net.ReadTable( )
		local Cursors = net.ReadTable( )

		if !Session or !Session.Host == Player then return end
		if !IsValid( SendTo ) or !Session.Users[ SendTo ] then return end

		net.Start( "lemon_editor_relay" )
			net.WriteTable( Session )
			net.WriteTable( Rows )
			net.WriteTable( Cursors )
		net.Send( SendTo )
	end

	net.Receive( "lemon_editor_relay", RetransmitSession )

	return -- END OF IF SERVER!
end

/*============================================================================================================================================
	Shared Tabs, Lets learn together =D
============================================================================================================================================*/
local LEMON = LEMON

local Editor = LEMON.Editor

Editor.SharedSessions = { }

local SharedSessions = Editor.SharedSessions

local function GetSession( ID )
	return SharedSessions[ tonumber( ID ) ]
end

/*============================================================================================================================================
	Editor Modifications!
============================================================================================================================================*/

function AddSharedTab( Session, Name )
	Editor.Create( ) 
	Editor.Open( "", true ) 
	
	local Tab = Editor.Instance.TabHolder:GetActiveTab( ) 
	local Panel = Tab:GetPanel( )

	Tab:SetText( Name ) 
	
	Tab.Image:SetImage( "fugue/globe-network.png" )

	Session.Editor = Panel
	Panel.SharedSession = Session

	Panel.OldOnTextChanged = Panel.OnTextChanged
	function Panel:OnTextChanged( selection, text ) 
		if self.DontUpdate then return end

		net.Start( "lemon_editor_delta" ) 
			net.WriteUInt( Session.ID, 16 )
			net.WriteTable( { { selection[1]( ) }, { selection[2]( ) }, text }  ) 
		net.SendToServer( ) 
	end
	
	function Panel:OnTabClose( ... )
		RunConsoleCommand( "lemon_editor_leave", Session.ID )
	end

	function Panel:MakeNonShared( )
		Tab.Image:SetImage( "fugue/script.png" )

		self.SharedSession = nil
		self.DontUpdate = nil
		
		self.OnTextChanged = Editor.OldOnTextChanged
		self.CloseTab = Editor.OldCloseTab

		self.SyncedCursors = { }
		self.MakeNonShared = nil
	end

	return Panel, Tab
end

function SyncCursors( )
	for _, Session in pairs( SharedSessions ) do
		local Editor = Session.Editor
		if !IsValid( Editor ) then continue end

		local ShouldSendCursor = false
		
		if !Editor.LastSyncedCaret or !Editor.LastSyncedStart then
			Editor.LastSyncedCaret = Editor:CopyPosition( Editor.Caret )
			Editor.LastSyncedStart = Editor:CopyPosition( Editor.Start )
			
			ShouldSendCursor = true
		elseif Editor.LastSyncedCaret ~= Editor.Caret or Editor.LastSyncedStart ~= Editor.Start then
			Editor.LastSyncedCaret = Editor:CopyPosition( Editor.Caret )
			Editor.LastSyncedStart = Editor:CopyPosition( Editor.Start )
			
			ShouldSendCursor = true
		end

		if ShouldSendCursor then
			net.Start( "lemon_editor_cursor" )
				net.WriteUInt( Session.ID, 16 )
				net.WriteTable( { {Editor.LastSyncedCaret( )}, {Editor.LastSyncedStart( )}, LocalPlayer( ):UniqueID() } )
			net.SendToServer( )
		end
	end
end

timer.Create( "lemon_cursor_update", 0.1, 0, SyncCursors )

local function fix( GlobalTab, selection, text )
	start, stop = GlobalTab:MakeSelection( selection )
	
	local cstart, cstop = GlobalTab:MakeSelection( GlobalTab:Selection() )
	local ctext = GlobalTab:GetArea( selection )
	
	--print("fixing")
	--print( "start, stop: ", start, stop )
	--print( "cstart, cstop: ", cstart, cstop )
	
	if stop.x < cstart.x or (stop.x == cstart.x and stop.y < cstart.y) then -- other people editing above your cursor; move cursor so that it stays at the same relative place
		local _, linenum = string.gsub( text, "\n", "" )
		local _, linenum2 = string.gsub( ctext, "\n", "" )
		local lineoffset = (linenum2 - linenum)
		
		--print("erased lines above cursor, moving cursor up " .. lineoffset .. " lines")
		GlobalTab.Start.x = GlobalTab.Start.x - lineoffset
		GlobalTab.Caret.x = GlobalTab.Caret.x - lineoffset
		
		if stop.x == cstart.x then
			local charoffset = #ctext - #text
			--print("erased chars in front of cursor, moving cursor up " .. charoffset .. " chars")
			GlobalTab.Start.y = GlobalTab.Start.y - charoffset
			GlobalTab.Caret.y = GlobalTab.Caret.y - charoffset
		end
	elseif (start.x == cstart.x and start.y <= cstart.y) and (stop.x == cstop.x and stop.y >= cstop.y) or
			(start.x < cstart.x and stop.x > cstop.x) then -- other people editing around your cursor; there's nothing we can do - reset cursor position
		--print("erased lines around cursor, moving cursor to line " .. start.x)
		GlobalTab:SetCaret( Vector2( start.x, start.y ) )
	elseif stop.x <= cstop.x and stop.y <= cstop.y then -- other people editing inside your selection
		

		local temp_start, temp_stop = GlobalTab:MakeSelection( { GlobalTab.Caret, GlobalTab.Start } )

		if stop.x == temp_stop.x then
			--print("edited inside your selection, moving end pos up " .. #text .. " chars")
			temp_stop.y = temp_stop.y + (#text - #ctext)
		end

		local _, linenum = string.gsub( text, "\n", "" )
		local _, linenum2 = string.gsub( ctext, "\n", "" )
		local lineoffset = (linenum2 - linenum)

		if lineoffset ~= 0 and stop.x ~= temp_stop.x then
			--print("erased lines inside cursor, moving end pos up " .. lineoffset .. " lines")
			temp_stop.x = temp_stop.x - lineoffset
		end 
	end
end

net.Receive( "lemon_editor_delta", function( )
	local Session = GetSession( net.ReadUInt( 16 ) )
	if !Session or !IsValid( Session.Editor ) then return end

	local t = net.ReadTable()
	local start, stop, text = t[1], t[2], t[3] or ""
	local selection = { Vector2( start[1], start[2] ), Vector2( stop[1], stop[2] ) }

	fix( Session.Editor, selection, text ) -- fix loads of special cases that occur here

	Session.Editor.DontUpdate = true
	Session.Editor:SetArea( selection, text )
	Session.Editor.DontUpdate = nil
end )

net.Receive( "lemon_editor_cursor", function()
	local Session = GetSession( net.ReadUInt( 16 ) )
	if !Session or !IsValid( Session.Editor ) then return end

	local t = net.ReadTable()
	local start, stop, plyid = t[1], t[2], t[3]
	Session.Editor:UpdateSyncedCursor( plyid, {Vector2(start[1],start[2]),Vector2(stop[1],stop[2])} )
end )

/*============================================================================================================================================
	Subscriptions
============================================================================================================================================*/
local function NewSession( ID, Host, Name )
	local Session = { ID = ID }

	Session.Name = Name

	Session.Host = Host
	Session.HostID = Host:UniqueID( )

	Session.Users = { [Host] = Host }

	SharedSessions[ Session.ID ] = Session

	return Session
end

net.Receive( "lemon.shared.new", function( )
	local Session = NewSession( net.ReadUInt( 16 ), LocalPlayer( ), net.ReadString( ) )
	local Panel, Tab = AddSharedTab( Session, Session.Name )
end )

net.Receive( "lemon_editor_relay", function( )
	local Session = net.ReadTable( )
	local Panel, Tab = AddSharedTab( Session, Session.Name )
	
	Panel.Rows = net.ReadTable( )
	Panel.SyncedCursors = net.ReadTable( )

	SharedSessions[ Session.ID ] = Session
end )

net.Receive( "lemon.shared.removed", function( )
	local Session = GetSession( net.ReadUInt( 16 ) )
	if !Session then return end

	SharedSessions[ Session.ID ] = nil

	local Editor = Session.Editor
	if !IsValid( Editor ) then return end

	Editor:MakeNonShared( )
end )

net.Receive( "lemon.shared.joined", function( )
	local Session = GetSession( net.ReadUInt( 16 ) )
	local UID = net.ReadString( )

	local Player = player.GetByUniqueID( UID )
	if !Session or !IsValid( Player ) then return end

	Session.Users[ Player ] = Player

	-- TODO: Add player to shared Menu.

	if !Session.Host == LocalPlayer( ) then return end

	net.Start( "lemon_editor_relay" )
		net.WriteUInt( Session.ID, 16 )
		net.WriteString( UID )
		net.WriteTable( Session.Editor.Rows )
		net.WriteTable( Session.Editor.SyncedCursors )
	net.SendToServer( )
end )

net.Receive( "lemon.shared.left", function( )
	local Session = GetSession( net.ReadUInt( 16 ) )
	local UID = net.ReadString( )
	local Player = player.GetByUniqueID( UID )
	if !Session or !IsValid( Player ) then return end

	Session.Users[ Player ] = nil

	local Editor = Session.Editor
	if !IsValid( Editor ) then return end

	Editor:RemoveSyncedCursor(UID)
end )

net.Receive( "lemon.shared.invite", function( )
	local ID = net.ReadUInt( 16 )
	local Name = net.ReadString( )
	local Host = player.GetByUniqueID( net.ReadString( ) )
	
	if !IsValid( Host ) then return end

	Editor.GetInstance( ):AddSharedInvite( ID, Host, Name )
end )

net.Receive( "lemon.shared.kicked", function( )
	local Session = GetSession( net.ReadUInt( 16 ) )
	if !Session then return end
	
	SharedSessions[ Session.ID ] = nil

	local Editor = Session.Editor
	if !IsValid( Editor ) then return end

	Editor:MakeNonShared( )
end )