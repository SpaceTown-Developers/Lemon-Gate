/*============================================================================================================================================
	Expression-Advanced pastebin interface
	Autor: Oskar
============================================================================================================================================*/

/* TODO: 
	Change how the client get access to the url/error (popup?) 
	Login 
*/

local api_url = "http://pastebin.com/api/api_post.php" 
local api_login_url = "http://pastebin.com/api/api_login.php" 
local api_dev_key = "3ff038bde0c45a53dc24af9cb1dfa996" 

Pastebin = { } 
local Pastebin = Pastebin 

local function CreatePasteFail( sError ) 
	notification.AddLegacy( "Failed to upload paste!", NOTIFY_ERROR, 3 ) 
	notification.AddLegacy( "Error: " .. sError, NOTIFY_ERROR, 5 ) 
	surface.PlaySound( "buttons/button15.wav" ) 
end 

local function CreatePasteSuccess( sUrl, nLength, tHeaders, nCode ) 
	notification.AddLegacy( "Paste uploaded!", NOTIFY_GENERIC, 3 ) 
	notification.AddLegacy( "Url saved to clipboard!", NOTIFY_GENERIC, 5 ) 
	surface.PlaySound( "buttons/button15.wav" ) 
	SetClipboardText( sUrl ) 
end 

function Pastebin.CreatePaste( sCode, sName, sUser, fCallback ) 
	local params = {
		api_dev_key = api_dev_key,
		api_option = "paste", 
		api_user_key = sUser, 
		api_paste_code = isstring( sCode ) and sCode or "", 
		api_paste_name = isstring( sName ) and sName or "Untitled", 
		api_paste_private = "1", 
		api_paste_expire_date = "1D"
	}
	
	fCalback = fCallback or CreatePasteSuccess
	
	http.Post( api_url, params, fCalback, CreatePasteFail ) 
end 

/* TODO: Finish this and related functions
function Pastebin.LoginPlayer( sUsername, sPassword, fSession ) 
	local params = {
		api_dev_key = api_dev_key, 
		api_user_name = sUsername, 
		api_user_password = sPassword 
	}
	
	-- http.Post( api_login_url, params, )
end 
*/
