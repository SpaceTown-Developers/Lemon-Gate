/*==============================================================================================
	Expression Advanced: Console.
	Purpose: Console.
	Note: Mostly just a conversion of E2's console Ext!
	Creditors: Rusketh
==============================================================================================*/
local E_A = LemonGate
E_A.API.NewComponent( "console", true )

local function ConCommand( self, Command )
	local Player = self.Player
	
	if Player and Player:IsValid( ) then
		if Player:GetInfoNum( "wire_expression2_concmd", 0 ) == 0 then
			return false
		end
		
		local WhiteList = string.Trim( Player:GetInfo( "wire_expression2_concmd_whitelist" ) or "" )
		
		if WhiteList ~= "" then 
			for Cmd in Command:gmatch( "[^;]+" ) do
				local Cmd = Cmd:match( "[^%s]+" )
				
				for Element in WhiteList:gmatch( "[^,]+" ) do
					if Cmd == Element then
						return true 
					end
				end
			end
			return false 
		end
		return true 
	end
	
	return false
end

/*==============================================================================================
	Section: functions
==============================================================================================*/
E_A:SetCost( EA_COST_ABNORMAL )

E_A:RegisterFunction( "concmd", "s", "n",
	function( self, Value )
		local Command = Value( self )
		
		if !ConCommand( self, Command ) then
			return 0
		else
			self.Player:ConCommand( Command:gsub( "%%", "%%%%" ) )
			return 1
		end
	end )

E_A:RegisterFunction( "convar", "s", "s",
	function( self, Value )
		local Command = Value( self )
		
		if !ConCommand( self, Command ) then
			return ""
		else
			return self.Player:GetInfo( Command ) or ""
		end
	end )
	
E_A:RegisterFunction( "convar", "s", "n",
	function( self, Value )
		local Command = Value( self )
		
		if !ConCommand( self, Command ) then
			return 0
		else
			return self.Player:GetInfoNum( Command, 0 ) or 0
		end
	end )