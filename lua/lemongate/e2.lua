/*==============================================================================================
	Expression Advanced: E2 Compataility Layer.
	Creditors: Rusketh
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

API.E2 = { E2 = { }, Lemon = { }, Same = { } }

function API.E2:RegisterE2( E2Type, LemonType, ToE2 )
	local Data = self.Lemon[ LemonType ] or { LemonType = LemonType, E2Type = E2Type}
	
	Data.ToE2 = ToE2
	
	self.E2[ E2Type ] = Data
	self.Lemon[ LemonType ] = Data
end

function API.E2:RegisterLemon( LemonType, E2Type, ToLemon )
	local Data = self.E2[ E2Type ] or { LemonType = LemonType, E2Type = E2Type }
	
	Data.ToLemon = ToLemon
	
	self.E2[ E2Type ] = Data
	self.Lemon[ LemonType ] = Data
end

function API.E2:PassThrough( Type )
	self.Same[ Type ] = true
end

function API.E2:ToE2( Context, LemonType, Object, Cache )
	
	if self.Same[ LemonType ] then
		return Object, LemonType
	end
	
	local Data = self.Lemon[ LemonType ]
	
	if !Data then
		return
	end
	
	local Type = Data.E2Type or LemonType
		
	if Data.ToE2 then
		Object = Data.ToE2( Context, Object, Cache )
	end
	
	return Object, Type
end

function API.E2:ToLemon( Context, E2Type, Object, Cache )
	
	if self.Same[ E2Type ] then
		return Object, E2Type
	end
	
	local Data = self.E2[ E2Type ]
	
	if !Data then
		return
	end
	
	local Type = Data.LemonType or E2Type
	
	if Data.ToLemon then
		Object = Data.ToLemon( Context, Object, Cache )
	end
	
	return Object, Type
end

API:CallHook( "E2Compataility", API.E2 )

/*==============================================================================================
	Basic Types:
==============================================================================================*/
API.E2:PassThrough( "n" )

API.E2:PassThrough( "s" )

API.E2:PassThrough( "e" )

API.E2:RegisterE2( "xwl", "wl" )

API.E2:RegisterLemon( "wl", "xwl" )

API.E2:RegisterE2( "n", "b", function( Context, Bool )
	return Bool and 1 or 0
end ) -- One way only!

/*==============================================================================================
	Vector Types:
==============================================================================================*/
API.E2:RegisterE2( "v", "v", function( Context, Vector )
	return { Vector.x, Vector.y, Vector.z }
end )

API.E2:RegisterLemon( "v", "v", function( Context, Vector )
	return Vector3( Vector[1], Vector[2], Vector[3] )
end )

API.E2:RegisterE2( "xv2", "v2", function( Context, Vector )
	return { Vector.x, Vector.y }
end )

API.E2:RegisterLemon( "v2", "xv2", function( Context, Vector )
	return Vector2( Vector[1], Vector[2] )
end )

API.E2:RegisterE2( "xv4", "c", function( Context, Color )
	return { Color[1], Color[2], Color[3], Color[4] }
end )

API.E2:RegisterLemon( "c", "xv4", function( Context, Vector )
	return { math.Clamp( Vector[1], 0, 255 ), math.Clamp( Vector[2], 0, 255 ), math.Clamp( Vector[3], 0, 255 ), math.Clamp( Vector[4], 0, 255 ) }
end )

/*==============================================================================================
	Ranger:
==============================================================================================*/
local RangerCompnent = API:GetComponent( "ranger" )

if RangerCompnent then
	local Meta = RangerCompnent:GetMetaTable( )
	
	API.E2:RegisterE2( "xrd", "rd", function( Context, Ranger )
		local Lemon = Meta( )
		Meta.Result = table.Copy( Ranger )
	end )

	API.E2:RegisterLemon( "rd", "xrd", function( Context, Ranger )
		Ranger = table.Copy( Ranger.Result )
		Ranger.RealStartPos = Ranger.Start 
		return Ranger.Result
	end )
end

/*==============================================================================================
	Table:
==============================================================================================*/
local TableCompnent = API:GetComponent( "table" )

if TableCompnent then
	local Meta = TableCompnent:GetMetaTable( )
	local DEFAULT = { n = { }, ntypes = { }, s = { }, stypes = { }, e = { }, etypes = { }, size = 0 }
	
	API.E2:RegisterLemon( "t", "t", function( Context, Table, Cache )
		local Cache = Cache or { }
		
		if Cache[ Table ] then
			return Cache[ Table ]
		end
		
		local Converted = Meta( )
		
		Converted.Count = Table.size
		
		for Key, Value in pairs( Table.n ) do
			Context.Perf = Context.Perf + 0.1
			
			local Value, Type = API.E2:ToLemon( Context, Table.ntypes[ Key ], Value, Cache )
			
			Converted:Set( Key, Type, Value )
		end
		
		for Key, Value in pairs( Table.s ) do
			Context.Perf = Context.Perf + 0.1
			
			local Value, Type = API.E2:ToLemon( Context, Table.stypes[ Key ], Value, Cache )
			
			Converted:Set( Key, Type, Value )
		end
		
		if Table.e then
			for Key, Value in pairs( Table.e ) do
				Context.Perf = Context.Perf + 0.1
				
				local Value, Type = API.E2:ToLemon( Context, Table.etypes[ Key ], Value, Cache )
				
				Converted:Set( Key, Type, Value )
			end
		end
		
		Cache[ Table ] = Converted
		
		return Converted
	end )

	API.E2:RegisterE2( "t", "t", function( Context, Table, Cache )
		local Cache = Cache or { }
		
		if Cache[ Table ] then
			return Cache[ Table ]
		end
		
		local Converted = table.Copy( DEFAULT )
		
		for Key, Type, Value in Table:Itorate( ) do
			Context.Perf = Context.Perf + 0.1
			Converted.size = Converted.size + 1
			
			local Value, Type = API.E2:ToE2( Context, Type, Value, Cache )
			
			if Type then
				local IType = type( Key )
				
				if IType == "number" then
					Converted.n[Key] = Value
					Converted.ntypes[Key] = Type
				elseif IType == "string" then
					Converted.s[Key] = Value
					Converted.stypes[Key] = Type
				elseif IType == "Entity" or IType == "Player" then
					Converted.e[Key] = Value
					Converted.etypes[Key] = Type
				end
			end
		end
		
		Cache[ Table ] = Converted
		
		return Converted
	end )
end
