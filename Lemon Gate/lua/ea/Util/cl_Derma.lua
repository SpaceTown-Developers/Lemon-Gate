
do // Vector2 Metadata 
	local meta = {} 
	meta.__index = meta 
 
	function meta:__add( other ) 
		return Vector2( self.x + other.x, self.y + other.x ) 
	end 
 
	function meta:__sub( other ) 
		return Vector2( self.x - other.x, self.y - other.x ) 
	end 
 
	function meta:__mul( other ) 
		return Vector2( self.x * other, self.y * other ) 
	end 

	function meta:__div( other ) 
		return Vector2( self.x / other, self.y / other ) 
	end 

	//__mod 
	//__pow 
 
	function meta:__unm( ) 
		return self * -1  
	end 
 
	function meta:__len( ) 
		return math.sqrt( self.x * self.x + self.y * self.y ) 
	end 
 
	function meta:__eq( other ) 
		return self.x == other.x and self.y == other.y 
	end 
 
	function meta:__lt( other ) 
		return self.x < other.x and self.y < other.y 
	end 
 
	function meta:__le( other ) 
		return self.x <= other.x and self.y <= other.y 
	end 
 
	function meta:__call( x, y ) 
		return self.x + (x or 0), self.y + (y or 0) 
	end 
 
	function meta:__tostring( ) 
		return "Vector2: " .. self.x .. " " .. self.y 
	end 
 
	function meta:Set( x, y ) 
		self.x = x 
		self.y = y 
	end 

	function meta:Add( x, y ) 
		self.x = self.x + x 
		self.y = self.y + y 
	end 

	local setmetatable = setmetatable 
	local Vec2 = { Zero = { x = 0, y = 0 } } 
	Vec2.__index = Vec2 
 
	function Vec2:Dot( other ) 
		return self.x * other.x + self.y * other.y 
	end 

	function Vec2:Normalize( ) 
		return self * ( 1 / #self ) 
	end 

	function Vec2:Round( dec ) 
		return Vector2( math.Round( self.x, dec ), math.Round( self.y, dec ), math.Round( self.z, dec ) ) 
	end 

	function Vec2:Length( ) 
		return math.sqrt( self.x * self.x + self.y * self.y ) 
	end 

	function Vec2:__call( a, b ) 
		return setmetatable({x = a or 0, y = b or 0}, meta) 
	end 

	Vector2 = {} 
	setmetatable( Vector2, Vec2 ) 
end 
 
do // Material util funcs
	local Materials = {} 
	local Mats = {}
	local function loadMaterial( mat ) 
		local matType = ltype( mat ) 
		if matType == "string" then 
			local data = Material( mat ) 
			if data:IsError() then return false, "Invalid material" end 
			Materials[mat] = data 
			Mats[data] = data 
			return true, mat
		elseif matType == "material" then 
			if mat:IsError() then return false, "Invalid material" end 
			local name = mat:GetName() 
			Materials[name] = mat 
			Mats[mat] = mat 
			return true, mat
		end 
		return false, string.format( "Invalid argument #1 (%s) expected got (%s)", "string/material", matType ) 
	end 
 
	function eaLoadMaterial( mat ) 
		PCallError( loadMaterial, mat ) 
	end 
 
	function eaMaterial( mat ) 
		if Materials[mat] then return Materials[mat] end 
		if Mats[mat] then return Mats[mat] end 
		local ok, err = loadMaterial( mat ) 
		if ok then return Materials[mat] end 
		error( err, 2 ) 
	end 

	function eaDumpMaterials( )
		PrintTable( Materials )
		PrintTable( Mats )
	end
end 
 
do // Custom color schemes for the editor 
	local Scheme = {} 
	local current = "blue" 
 
	Scheme.blue = { 
		Color(16,45,225), 
		Color(56,69,155), 
		Color(3,21,128), 
		Color(41,68,232), 
		Color(61,85,232), 
		Color(255,255,255),
		Color(0,0,0),
	} 
 
	Scheme.green = { 
		Color(59,218,0), 
		Color(74,163,41), 
		Color(38,142,0), 
		Color(107,236,59), 
		Color(142,236,106), 
		Color(255,255,255),
		Color(0,0,0),
	} 
 
	Scheme.red = { 
		Color(255,13,0), 
		Color(131,67,64), 
		Color(81,4,0), 
		Color(255,92,83), 
		Color(255,155,150), 
		Color(255,255,255),
		Color(0,0,0),
	} 
 
	function setScheme( name ) 
		local tp = ltype( name ) 
		if tp == "string" then 
			name = string.lower( name ) 
			if Scheme[name] then 
				current = name 
				return true 
			end 
			return false 
		elseif tp == "table" then 
			if #name ~= 5 then return false end 
			for i = 1,5 do 
				if ltype(name[i]) ~= "table" or !name[i].r or !name[i].g or !name[i].b or !name[i].a then return false end 
			end 
			current = "custom" 
			Scheme.custom = name 
			return true 
		end 
	end 
 
	function getSchemeColor( idx ) 
		return Scheme[current][idx] 
	end 
end 
