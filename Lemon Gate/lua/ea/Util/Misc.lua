
/*---------------------------------------------------------------------------
Util functions for upload/download
---------------------------------------------------------------------------*/

local type = type 
local string_sub = string.sub 
local string_gsub = string.gsub 
local string_char = string.char 
local string_len = string.len 
local string_lower = string.lower 
local tEncode = {}
local tDecode = {}

do
	local escape = "'\"\\\n%;"
	local hex = { "0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F" }

	for i = 1, string_len( escape ) do
		local char = escape[i]
		tEncode[char] = true
	end

	for byte = 1,255 do
		local hexbyte = hex[(byte - byte%16)/16 + 1] .. hex[byte%16 + 1]
		tDecode[hexbyte] = string_char( byte )
		if tEncode[string_char( byte )] then
			tEncode[string_char( byte )] = "%" .. hexbyte
		else
			tEncode[string_char( byte )] = string_char( byte )
		end
	end
end

function eaEncode( str )
	return string_gsub( str, ".", tEncode ) 
end

function eaDecode( str )
	return string_gsub( str, "%%(..)", tDecode ) 
end

function string.chop( str, size ) // TODO: add string compression
	local data = {}
	while string_len( str ) > size do 
		data[#data+1] = string_sub( str, 1, size )
		str = string_sub( str, size + 1)
	end
	data[#data+1] = str
	return data
end

function ltype( Value )
	return string_lower( type( Value ) )
end

if CLIENT then 
	local ply
	function PrintMessage( msg )
		ply = ply or LocalPlayer()
		ply:PrintMessage( HUD_PRINTTALK, msg )
	end
end