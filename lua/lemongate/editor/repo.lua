local GitPage, NodeID = 0, 1
local GitVer_Receive, GitVer_Fail
local GitLog_Receive, GitLog_Fail
local GitLog = "https://api.github.com/repos/SpaceTown-Developers/Lemon-Gate/commits?per_page=100"
local GitVer = "https://api.github.com/repos/SpaceTown-Developers/Lemon-Gate/contents/lua/ea_version.lua"

--"https://raw.github.com/SpaceTown-Developers/Lemon-Gate/master/data/ea_version.lua"

/************************************************************************************************/
LEMON.Repo = { }
local Repo = LEMON.Repo

Repo.NewestVerison = 0
Repo.CurrentVerison = tonumber( file.Read( "ea_version.lua", "LUA" ) or 0 )

function Repo.CheckVer( )
	http.Fetch( GitVer, GitVer_Receive, GitVer_Fail )
end

function Repo.OpenMenu( )
	if IsValid( Repo.Menu ) then
		Repo.Menu:Show( )
		return
	end
	
	local Frame = vgui.Create( "EA_Frame" )
	Frame:SetText( "LemonGate Repo:" )
	Frame:SetSize( 615, 500 )
	
	function Frame:Close( )
		self:Hide()
	end
	
	local Banner = Frame:Add( "EA_Button" )
	Banner:Dock( TOP )
	Banner:DockMargin( 5, 5, 5, 5 )
	Banner:SetTextCentered( true )
	Banner:SetFading( false )
	Banner:SetColor( Color( 0, 0, 255 ) )
	Banner:SetTextColor( Color( 0, 0, 0 ) )
	Banner:SetText( "Querying Repository ..." )
	Banner:SetFont( "Trebuchet20")
	
	local Version = vgui.Create( "DLabel", Banner )
	Version:SetText( "" )
	
	function Version:SetUp( Text )
		self:SetText( Text )
		self:SizeToContents( )
		
		local X = Banner:GetWide( ) - self:GetWide( ) - 5
		local Y = Banner:GetTall( ) - self:GetTall( ) - 5
		self:SetPos( X, Y )
	end
	
	Browser = Frame:Add( "DTree" )
	Browser:Dock( LEFT )
	Browser:DockMargin( 5, 5, 0, 5 )
	Browser:SetWide( 200 )
	Browser.SHA = { }
	
	Messages = Frame:Add( "DTextEntry" )
	Messages:Dock( RIGHT )
	Messages:DockMargin( 5, 5, 5, 5 )
	Messages:SetWide( 400 )
	Messages:SetMultiline( true )
	Messages:SetEnabled( false )
	
	Frame.Banner = Banner
	Frame.Version = Version
	Frame.Browser = Browser
	Frame.Messages = Messages
	
	Frame:MakePopup( )
	
	Repo.Menu = Frame
	
	Repo.CheckVer( )
end

function Repo.CloseMenu( )
	if IsValid( Repo.Menu ) then
		Repo.Menu:Remove( )
		Repo.Menu = nil
	end
end

/***********************************************************************/

function GitVer_Receive( JSon )
	local Contents = util.JSONToTable( JSon )
	local File = util.Base64Decode( Contents.content )
	
	Repo.NewestVerison = tonumber( File ) or 0
	NodeID, GitPage = Repo.NewestVerison + 1, 1
	
	if IsValid( Repo.Menu ) then
		if Repo.NewestVerison == Repo.CurrentVerison then
			Repo.Menu.Banner:SetColor( Color( 0, 255, 0, 255 ) )
			Repo.Menu.Banner:SetText( "Lemongate is up to date." )
			Repo.Menu.Version:SetUp( "Version: " .. Repo.CurrentVerison )
		elseif Repo.NewestVerison == 0 then
			Repo.Menu.Banner:SetColor( Color( 255, 0, 0, 255 ) )
			Repo.Menu.Banner:SetText( "Failed to query repository." )
			Repo.Menu.Version:SetUp( "Version: " .. Repo.CurrentVerison )	
		elseif Repo.NewestVerison > Repo.CurrentVerison then
			Repo.Menu.Banner:SetColor( Color( 255, 0, 0, 255 ) )
			Repo.Menu.Banner:SetText( "Lemongate is out dated." )
			Repo.Menu.Version:SetUp( Format("Version: %s (you) / %s (repo)", Repo.CurrentVerison, Repo.NewestVerison ) )
		elseif Repo.NewestVerison < Repo.CurrentVerison then
			Repo.Menu.Banner:SetColor( Color( 255, 0, 0, 255 ) )
			Repo.Menu.Banner:SetText( "Lemongate succeeds repo." )
			Repo.Menu.Version:SetUp( Format("Version: %s (you) / %s (repo)", Repo.CurrentVerison, Repo.NewestVerison ) )
		end
		
		Repo.Menu.Banner = nil
		
		http.Fetch( GitLog, GitLog_Receive, GitLog_Fail )
	end
end

function GitVer_Fail(  )
	if IsValid( Repo.Menu ) then
		Repo.Menu.Banner:SetColor( Color( 255, 0, 0, 255 ) )
		Repo.Menu.Banner:SetText( "Failed to query repository." )
		Repo.Menu.Version:SetUp( "Click to retry." )
		
		Repo.Menu.Banner = Repo.CheckVer( )
	end
end

/***********************************************************************/


local function Process( Frame, Contents )
	local Browser, Messages = Frame.Browser, Frame.Messages
	
	Messages:SetText( "Generating data." )
	
	local Commits = util.JSONToTable( Contents )
	
	for I = 1, #Commits do
		local Commit = Commits[ I ].commit
		local SHA = Commits[ I ].sha
		
		if !Browser.SHA[ SHA ] then
			
			NodeID = NodeID - 1
			local Author = Commit.committer.name -- Woot, I figured out patterns!
			local Date = string.gsub( Commit.committer.date , "^([0-9]+)-([0-9]+)-([0-9]+)(.+)", "%3 / %2 / %1" )
			local Time = string.gsub( string.gsub( Commit.committer.date , "(.+)T([0-9]+):([0-9]+):([0-9]+)(.+)", "%2:%3:%4" ) , "0([0-9])", "%1" )
			
			local Node = Browser:AddNode( Format( "##%s - %s", NodeID, Date ) )
			
			Node:SetToolTip( Format( "%s\n%s\n%s", Author, Time, Date ) )
			
			function Node:DoClick( )
				local Msg = Format( "Commit: %s - (#%s)\n\n", SHA, NodeID )
					  Msg = Format( "%sAuthor: %s\nTime: %s\nDate: %s\n\n", Msg, Author, Time, Date )
					  Msg = Msg .. Commit.message
					  
				Messages:SetText( Msg )
				
			end
			
			Browser.SHA[ SHA ] = Node
		end
		
		if I == 1 then
			Browser.SHA[ SHA ]:DoClick( )
		end
	end
	
	if IsValid( Browser.Older ) then
		Browser.Older:Remove( )
	end
	
	GitPage = GitPage + 1
	
	-- Browser.Older = Browser:AddNode( "Show older." )
	
	-- function Browser.Older:DoClick( )
		-- print( "Loading Page:", GitPage )
		-- http.Fetch( Format( "%s&page=%s", GitLog, GitPage ), GitLog_Receive, GitLog_Fail )
	-- end -- This part of the API doesnt work.
end
	
function GitLog_Receive( Contents )
	if IsValid( Repo.Menu ) then
		coroutine.resume( coroutine.create( Process ), Repo.Menu, Contents )
	end
end

function GitLog_Fail( )
	if IsValid( Repo.Menu ) then
		Repo.Menu.Messages:SetText( "Failed to query commits of repo." )
	end
end

Repo.CheckVer( )

/************************************************************************************************************/

-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
-- licensed under the terms of the LGPL2

-- character table string
local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

function util.Base64Decode( data )
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end