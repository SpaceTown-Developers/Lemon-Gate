local GitVer_Receive, GitVer_Fail
local GitLog_Receive, GitLog_Fail
local CurVer, NewVer, GitPage, NodeID = tonumber( file.Read( "ea_version.lua", "LUA" ) ), 0, 1
local GitLog = "https://api.github.com/repos/SpaceTown-Developers/Lemon-Gate/commits?per_page=100"
local GitVer = "https://raw.github.com/SpaceTown-Developers/Lemon-Gate/master/data/ea_version.lua"

local RepoFrame

function LEMON.Editor.OpenRepo( )
	if IsValid( RepoFrame ) then
		RepoFrame:Remove( )
		RepoFrame = nil
	end
	
	local Frame = vgui.Create( "EA_Frame" )
	Frame:SetText( "LemonGate Repo:" )
	Frame:SetSize( 615, 500 )

	local Banner = Frame:Add( "EA_Button" )
	Banner:Dock( TOP )
	Banner:DockMargin( 5, 5, 5, 5 )
	Banner:SetTextCentered( true )
	Banner:SetFading( false )
	Banner:SetColor( Color( 0, 0, 255 ) )
	Banner:SetTextColor( Color( 0, 0, 0 ) )
	Banner:SetText( "Checking ..." )
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
	
	function Banner:DoClick( )
		Version:SetText( "" )
		self:SetText( "Updating ..." )
		self:SetColor( Color( 0, 0, 255, 255 ) )
		http.Fetch( GitVer, GitVer_Receive, GitVer_Fail )
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
	
	RepoFrame = Frame
	
	http.Fetch( GitVer, GitVer_Receive, GitVer_Fail )
end

/***********************************************************************/

function GitVer_Receive( Contents )
	NewVer = tonumber( string.match( Contents , "^[^0-9]*([0-9]+)" ) )
	
	if IsValid( RepoFrame ) then
		local Frame = RepoFrame
		
		if NewVer == CurVer then
			Frame.Banner:SetColor( Color( 0, 255, 0, 255 ) )
			Frame.Banner:SetText( "Lemongate is up to date." )
			Frame.Version:SetUp( "Version: " .. CurVer )
			
		elseif NewVer > CurVer then
			Frame.Banner:SetColor( Color( 255, 0, 0, 255 ) )
			Frame.Banner:SetText( "Lemongate is out dated." )
			Frame.Version:SetUp( Format("Version: %s (you) / %s (repo)", CurVer, NewVer ) )
		else
			Frame.Banner:SetColor( Color( 255, 0, 0, 255 ) )
			Frame.Banner:SetText( "Lemongate succeeds repo." )
			Frame.Version:SetUp( Format("Version: %s (you) / %s (repo)", CurVer, NewVer ) )
		end
	end
	
	NodeID, GitPage = NewVer + 1, 1
	http.Fetch( GitLog, GitLog_Receive, GitLog_Fail )
end

function GitVer_Fail(  )
	if IsValid( RepoFrame ) then
		local Frame = RepoFrame
		
		Frame.Banner:SetColor( Color( 255, 0, 0, 255 ) )
		Frame.Banner:SetText( "Failed to query repo." )
		Frame.Version:SetUp( "Version: " .. CurVer )
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
	if IsValid( RepoFrame ) then
		coroutine.resume( coroutine.create( Process ), RepoFrame, Contents )
	end
end

function GitLog_Fail( )
	if IsValid( RepoFrame ) then
		RepoFrame.Messages:SetText( "Failed to query commits of repo." )
	end
end

 