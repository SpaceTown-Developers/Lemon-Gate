/*---------------------------------------------------------------------------
Vector3 class
Author: Oskar
---------------------------------------------------------------------------*/
do  
	
	/*
		if type( self ) == "number" then
			self = {x = other, y = other, z = other}
		elseif type( other ) == "number" then
			other = {x = other, y = other, z = other}
		end
	*/
	
	local meta = {} 
	meta.__index = meta 
	
	function meta:__add( other )
		return Vector3( self.x + other.x, self.y + other.y, self.z + other.z ) 
	end 
 
	function meta:__sub( other ) 
		return Vector3( self.x - other.x, self.y - other.y, self.z - other.z ) 
	end 
 
	function meta:__mul( other ) 
		return Vector3( self.x * other.x, self.y * other.y, self.z * other.z ) 
	end 

	function meta:__div( other )
		if self.x == 0 or other.x == 0 or self.y == 0 or other.y == 0 or self.z == 0 or other.z == 0 then 
			return Vector3( 0, 0, 0 )
		else
			return Vector3( self.x / other.x, self.y / other.y, self.z / other.z )
		end
	end 
	
	function meta:__mod( other ) 
		return Vector3( self.x % other.x, self.y % other.y, self.z % other.z ) 
	end 
	
	function meta:__pow( other ) 
		return Vector3( self.x ^ other.x, self.y ^ other.y, self.z ^ other.z ) 
	end
 
	function meta:__unm( )
		return Vector3( self.x * -1, self.y * -1, self.z * -1 )  
	end 
 
	function meta:__len( ) -- Garry has broken this =(
		return math.sqrt( self.x * self.x + self.y * self.y + self.z * self.z ) 
	end 
 
	function meta:__eq( other ) 
		return self.x == other.x and self.y == other.y and self.z == other.z 
	end 
 
	function meta:__lt( other ) 
		return self.x < other.x and self.y < other.y and self.z < other.z 
	end 
 
	function meta:__le( other ) 
		return self.x <= other.x and self.y <= other.y and self.z <= other.z 
	end 
 
	function meta:__call( x, y, z ) 
		return self.x + (x or 0), self.y + (y or 0), self.z + (z or 0) 
	end 
 
	function meta:__tostring( ) 
		return "Vector3: " .. self.x .. " " .. self.y .. " " .. self.z
	end 
 
	function meta:Set( x, y, z ) 
		self.x = x 
		self.y = y 
		self.z = z 
		return self 
	end 

	function meta:Add( x, y, z ) 
		self.x = self.x + x 
		self.y = self.y + y 
		self.z = self.z + z 
		return self 
	end 
	
	function meta:Sub( x, y, z )
		self.x = self.x - x 
		self.y = self.y - y 
		self.z = self.z - z 
		return self 
	end 
	
	function meta:Clone( )
		return Vector3( self.x, self.y, self.z )
	end
	
	function meta:Dot( other ) 
		return self.x * other.x + self.y * other.y + self.z * other.z 
	end 

	function meta:Normalize( )
		local Len = self:Length( ) 
		return Vector3( self.x / Len, self.y / Len, self.z / Len )
	end 

	function meta:Round( dec ) 
		return Vector3( math.Round( self.x, dec ), math.Round( self.y, dec ), math.Round( self.z, dec ) ) 
	end 

	function meta:Length( ) 
		return math.sqrt( self.x * self.x + self.y * self.y + self.z * self.z ) 
	end 
	
	function meta:RawLength( ) 
		return self.x * self.x + self.y * self.y + self.z * self.z
	end 
	
	function meta:Cross( other )
		return Vector3( ( self.y * other.z ) - ( other.y * self.z ), ( self.z * other.x ) - ( other.z * self.x ), ( self.x * other.y ) - ( other.x * self.y ) )
	end -- RevouluPowered

	function meta:Distance( other )
		return ( self - other ):Length()
	end -- RevouluPowered
	
	function meta:RawDistance( other )
		return ( self - other ):RawLength()
	end -- RevouluPowered
	
	function meta:Angle( )
		return Vector( self.x, self.y, self.z ):Angle( )
	end
	
	function meta:Garry( )
		return Vector( self.x, self.y, self.z )
	end
	
	local Huge = math.huge
	
	function meta:IsNotHuge( )
		return ( -Huge < self.x and self.x < Huge and -Huge < self.y and self.y < Huge and -Huge < self.z and self.z < Huge )
	end
	
	local Rad2Deg = 180 / math.pi
	
	function meta:Bearing( angle, vector )
		local v, a = WorldToLocal(vector:Garry( ), Angle(0,0,0), self:Garry( ), angle)
		return Rad2Deg * -math.atan2( v.y, v.x )
	end
	
	function meta:Elevation( angle, vector )
		local v, a = WorldToLocal(vector:Garry( ), Angle(0,0,0), self:Garry( ), angle)
		return Rad2Deg * math.asin(v.z / v:Length( )) 
	end
	
	function meta:Heading( angle, vector )
		local v, a = WorldToLocal(vector:Garry( ), Angle(0,0,0), self:Garry( ), angle)
		return Angle( Rad2Deg * math.asin(v.z / v:Length( )) , Rad2Deg * -math.atan2( v.y, v.x ), 0 )
	end
	
	local setmetatable = setmetatable 
	local Vec3 = { Zero = setmetatable({ x = 0, y = 0, z = 0 },meta) } 
	Vec3.__index = Vec3 
	
	function Vec3:__call( a, b, c ) 
		if type( a ) == "Vector" then
			a, b, c = a.x, a.y, a.z
		end
		
		return setmetatable( {x = a or 0, y = b or 0, z = c or 0}, meta)
	end 

	Vector3 = {} 
	setmetatable( Vector3, Vec3 ) 
	debug.getregistry().Vector3 = meta
end 
