/*---------------------------------------------------------------------------
Vector3 class
Author: Oskar
---------------------------------------------------------------------------*/
do  
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
		return Vector3( self.x / other.x, self.y / other.y, self.z / other.z ) 
	end 
	
	function meta:__mod( other ) 
		return Vector3( self.x % other.x, self.y % other.y, self.z % other.z ) 
	end 
	
	function meta:__pow( other ) 
		return Vector3( self.x ^ other.x, self.y ^ other.y, self.z ^ other.z ) 
	end
 
	function meta:__unm( ) 
		return self * -1  
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
		return self * ( 1 / #self ) 
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
	
	function meta:Garry( )
		return Vector( self.x, self.y, self.z )
	end
	
	local setmetatable = setmetatable 
	local Vec3 = { Zero = setmetatable({ x = 0, y = 0, z = 0 },meta) } 
	Vec3.__index = Vec3 
	
	local Rad2Deg = 180 / math.pi
	
	function Vec3:Bearing( angle, vector )
		local v, a = WorldToLocal(vector:Garry( ), Angle(0,0,0), self:Garry( ), angle)
		return Rad2Deg * math.asin(v.z / v:Length( )) 
	end
	
	function Vec3:Elevation( angle, vector )
		local v, a = WorldToLocal(vector:Garry( ), Angle(0,0,0), self:Garry( ), angle)
		return Rad2Deg * -math.atan2( v.y, v.x )
	end
	
	function Vec3:Heading( angle, vector )
		local v, a = WorldToLocal(vector:Garry( ), Angle(0,0,0), self:Garry( ), angle)
		return Angle( Rad2Deg * math.asin(v.z / v:Length( )) , Rad2Deg * -math.atan2( v.y, v.x ), 0 )
	end
	
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
