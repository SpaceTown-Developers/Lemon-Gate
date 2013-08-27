/*==============================================================================================
	Expression Advanced: Phys Objects.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" )

/*==============================================================================================
	Section: Values
==============================================================================================*/

Core:AddExternal( "UnitSpeed", {
	["u/s"] = 1 / 0.75,
	["u/m"] = 60 * (1 / 0.75),
	["u/h"] = 3600 * (1 / 0.75),

	["mm/s"] = 25.4,
	["cm/s"] = 2.54,
	["dm/s"] = 0.254,
	["m/s"] = 0.0254,
	["km/s"] = 0.0000254,
	["in/s"] = 1,
	["ft/s"] = 1 / 12,
	["yd/s"] = 1 / 36,
	["mi/s"] = 1 / 63360,
	["nmi/s"] = 127 / 9260000,

	["mm/m"] = 60 * 25.4,
	["cm/m"] = 60 * 2.54,
	["dm/m"] = 60 * 0.254,
	["m/m"] = 60 * 0.0254,
	["km/m"] = 60 * 0.0000254,
	["in/m"] = 60,
	["ft/m"] = 60 / 12,
	["yd/m"] = 60 / 36,
	["mi/m"] = 60 / 63360,
	["nmi/m"] = 60 * 127 / 9260000,

	["mm/h"] = 3600 * 25.4,
	["cm/h"] = 3600 * 2.54,
	["dm/h"] = 3600 * 0.254,
	["m/h"] = 3600 * 0.0254,
	["km/h"] = 3600 * 0.0000254,
	["in/h"] = 3600,
	["ft/h"] = 3600 / 12,
	["yd/h"] = 3600 / 36,
	["mi/h"] = 3600 / 63360,
	["nmi/h"] = 3600 * 127 / 9260000,

	["mph"] = 3600 / 63360,
	["knots"] = 3600 * 127 / 9260000,
	["mach"] = 0.0254 / 295,
} )

Core:AddExternal( "UnitLength", {
	["u"] = 1 / 0.75,

	["mm"] = 25.4,
	["cm"] = 2.54,
	["dm"] = 0.254,
	["m"] = 0.0254,
	["km"] = 0.0000254,
	["in"] = 1,
	["ft"] = 1 / 12,
	["yd"] = 1 / 36,
	["mi"] = 1 / 63360,
	["nmi"] = 127 / 9260000,
} )

Core:AddExternal( "UnitWeight", {
	["g"] = 1000,
	["kg"] = 1,
	["t"] = 0.001,
	["oz"] = 1 / 0.028349523125,
	["lb"] = 1 / 0.45359237,
} )

/*==============================================================================================
	Section: Functions
==============================================================================================*/

Core:AddFunction( "toUnit", "s,n", "n", [[
	if %UnitSpeed[ value %1 ] then
		%util = (value %2 * 0.75) * %UnitSpeed[ value %1 ]
	elseif %UnitLength[ value %1 ] then
		%util =  (value %2 * 0.75) * %UnitLength[ value %1 ]
	elseif %UnitWeight[ value %1 ] then
		%util =  value %2 * %UnitWeight[ value %1 ]
	else
		%util = -1
	end
]], "%util" )

Core:AddFunction( "fromUnit", "s,n", "n", [[
	if %UnitSpeed[ value %1 ] then
		%util = (value %2 / 0.75) / %UnitSpeed[ value %1 ]
	elseif %UnitLength[ value %1 ] then
		%util =  (value %2 / 0.75) / %UnitLength[ value %1 ]
	elseif %UnitWeight[ value %1 ] then
		%util =  value %2 / %UnitWeight[ value %1 ]
	else
		%util = -1
	end
]], "%util" )

Core:AddFunction( "convertUnit", "s,s,n", "n", [[
	if %UnitSpeed[value %1] and %UnitSpeed[value %2] then
		%util = value %3 * (%UnitSpeed[value %2] / %UnitSpeed[value %1])
	elseif %UnitLength[value %1] and %UnitLength[value %2] then
		%util = value %3 * (%UnitLength[value %2] / %UnitLength[value %1])
	elseif %UnitWeight[value %1] and %UnitWeight[value %2] then
		%util = value %3 * (%UnitWeight[value %2] / %UnitWeight[value %1])
	else
		%util = -1
	end
]], "%util" )
