/*==============================================================================================
	Expression Advanced: Compiler -> Lua Debuger.
	Purpose: The Compiler part of the compiler.
	Author: Oskar94
==============================================================================================*/
local LEMON = LEMON

local API = LEMON.API

local Compiler = LEMON.Compiler

/*==============================================================================================
	Lua Syntax Formatter.
==============================================================================================*/
local type = type 
local pairs = pairs 

local string_match = string.match 
local string_rep = string.rep 
local string_sub = string.sub 
local string_gsub = string.gsub 

function Compiler:LUA_ValidLines( Rows )
	local Out = { }
	local MultilineComment
	local Row, Char = 1, 0
	
	while Row <= #Rows do
		local Tabs = #Rows[Row] - #string_match( Rows[Row], "^%s*(.*)$" ) 
		Rows[Row] = string_match( Rows[Row], "^%s*(.*)$" ) 
		local Line = Rows[Row]
		while Char < #Line do
			Char = Char + 1
			local Text = Line[Char]
			local sType = type( MultilineComment )
			
			if sType == "number" then -- End comment or string (]])
				if string_match( string_sub( Line, 1, Char ), "%]" .. string_rep( "=", MultilineComment ) .. "%]$" ) then
					Out[Row] = { 1, Char }
					MultilineComment = nil
				else
					Out[Row] = Out[Row] or false
				end
			elseif sType == "string" then -- End string
				local String = MultilineComment
				if Text == String and Line[Char-1] ~= "\\" then
					Out[Row][2] = Char
					MultilineComment = nil
				else
					Out[Row] = Out[Row] 
				end
			elseif sType == "boolean" and MultilineComment then -- End comment (*/)
				if Text == "/" and Line[Char-1] == "*" then
					Out[Row] = { 1, Char }
					MultilineComment = nil
				else
					Out[Row] = Out[Row] or false
				end
			elseif string_match( Line, "^%[=*%[", Char ) then -- Multiline string ([[)
				MultilineComment = #string_match( Line, "^%[(=*)%[", Char )
				Out[Row] = { Char, #Line + 1 }
			elseif string_match( Line, "^[\"']", Char ) then -- Normal string (" or ')
				MultilineComment = string_match( Line, "^([\"'])", Char )
				Out[Row] = { Char, #Line + 1 }
			elseif string_match( Line, "^%-%-%[=*%[", Char ) then -- Multiline comment (--[[)
				MultilineComment = #string_match( Line, "^%-%-%[(=*)%[", Char )
				Out[Row] = { Char, #Line + 1 }
			elseif string_match( Line, "^%-%-", Char ) then -- Singleline comment (--)
				if Char == 1 then 
					Out[Row] = false 
				else 
					Out[Row] = { Char, #Line + 1 }
				end 
				break
			elseif Text == "/" then -- Test fore comments
				if Line[Char+1] == "/" then -- Singleline comment (//)
					if Char == 1 then 
						Out[Row] = false 
					else 
						Out[Row] = { Char, #Line + 1 } 
					end 
					break
				elseif Line[Char+1] == "*" then -- Multiline comment (/*)
					MultilineComment = true
					Out[Row] = { Char, #Line + 1 }
				else
					Rows[Row] = string_match( Rows[Row], "^%s*(.*)$" )
				end
			end
		end
		
		if not Out[Row] and Out[Row] ~= false then
			Out[Row] = true
		end
		
		if Out[Row] == false then 
			Rows[Row] = string_rep( "\t", Tabs ) .. Rows[Row] 
		end 
		
		Char = 0
		Row = Row + 1
	end
	
	return Out
end

local Indent = {
	["do"] = "%s",
	["then"] = "%s",
	["else"] = "%s", 
	["repeat"] = "%s",
	["{"] = true,
	["%sfunction[%s%(]"] = true,
}

local Undent = {
	["end"] = "[^%w]",
	["until"] = "%s",
	["else"] = "%s",
	["elseif"] = "%s",
	["}"] = "%s*",
}

function Compiler:LUA_Format( Code )
	local newcode = { }
	local lines = string.Explode( "\n", Code )
	local data = self:LUA_ValidLines( lines )
	local indent = 0
	local line = 1
	local newline = false
	
	local i = 0
	local outline = 1
	while i < #lines do 
		i = i + 1 
		local line = lines[i]
		local matchline = " " .. line .. " "
		local lindent = indent
		
		if data[i] == true then -- Normal row 
			if line == "" then 
				if not newline then 
					newcode[outline] = string_rep( "\t", lindent ) 
					outline = outline + 1
					newline = true 
				end 
			else
				-- Increase indenting 
				for k, v in pairs( Indent ) do
					if v == true then
						if string_match( matchline, k ) then
							local _, n = string_gsub( matchline, k, "" )
							indent = indent + n
						end 
					elseif string_match( matchline, v .. k .. v ) then 
						local _, n = string_gsub( matchline, v .. k .. v, "" )
						indent = indent + n
					end 
				end
				
				-- Decrease indenting
				for k, v in pairs( Undent ) do
					local n
					if v == true then
						if string_match( matchline, k ) then
							_, n = string_gsub( matchline, k, "" )
							indent = indent - n
						end 
					elseif string_match( matchline, v .. k .. v ) then 
						_, n = string_gsub( matchline, v .. k .. v, "" )
						indent = indent - n
					end 
					
					if k == "else" or k == "elseif" then 
						_, n = string_gsub( matchline, v .. k .. v, "" )
						lindent = lindent - n
					end 
					
					local shouldBack = k == "end" or k == "else" or k == "elseif"
					
					if shouldBack and newline and n and n > 0 then 
						outline = outline - 1 
					end 
				end
				
				indent = indent < 0 and 0 or indent
				lindent = indent < lindent and indent or lindent
				newcode[outline] = string_rep( "\t", lindent ) .. line
				outline = outline + 1
				newline = false
			end 
		elseif data[i] == false then -- Inside multiline comment or multiline string
			-- Do nothing
			newcode[outline] = line
			outline = outline + 1
			newline = false 
		else -- A string or comment starts or ends on this line
			local start, stop = data[i][1], data[i][2]
			local limited = ""
			
			-- Remove the string or comment from the indent matching
			if start > 1 then
				if stop < #line then
					limited = string_sub( line, 1, start - 1 ) .. string_sub( line, stop + 1, -1 )
				else
					limited = string_sub( line, 0, start - 1 )
				end
			else
				if stop < #line then
					limited = string_sub( line, stop, -1 )
				end
			end
			matchline = " " .. limited .. " "
			
			-- Decrease Indenting
			for k, v in pairs( Indent ) do
				if v == true then
					if string_match( matchline, k ) then
						local _, n = string_gsub( matchline, k, "" )
						indent = indent + n
					end 
				elseif string_match( matchline, v .. k .. v ) then 
					local _, n = string_gsub( matchline, v .. k .. v, "" )
					indent = indent + n
				end 
			end
			
			
			-- Decrease indenting
			for k, v in pairs( Undent ) do
				local n
				if v == true then
					if string_match( matchline, k ) then
						_, n = string_gsub( matchline, k, "" )
						indent = indent - n
					end 
				elseif string_match( matchline, v .. k .. v ) then 
					_, n = string_gsub( matchline, v .. k .. v, "" )
					indent = indent - n
				end 
				
				if k == "else" or k == "elseif" then 
					_, n = string_gsub( matchline, v .. k .. v, "" )
					lindent = lindent - n
				end 
				
				local shouldBack = k == "end" or k == "else" or k == "elseif"
				
				if shouldBack and newline and n and n > 0 then 
					outline = outline - 1 
				end 
			end
			
			indent = indent < 0 and 0 or indent
			lindent = indent < lindent and indent or lindent
			newcode[outline] = string_rep( "\t", lindent ) .. line
			outline = outline + 1
			newline = false 
		end
	end
	
	return table.concat( newcode, "\n" )
end