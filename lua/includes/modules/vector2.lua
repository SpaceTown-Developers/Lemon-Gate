/*---------------------------------------------------------------------------
Vector2 class
Author: Oskar
---------------------------------------------------------------------------*/
do  
	local meta = {} 
	meta.__index = meta 
 
	function meta:__add( other ) 
		return Vector2( self.x + other.x, self.y + other.y ) 
	end 
 
	function meta:__sub( other ) 
		return Vector2( self.x - other.x, self.y - other.y ) 
	end 
 
	function meta:__mul( other ) 
		return Vector2( self.x * other.x, self.y * other.y ) 
	end 

	function meta:__div( other )
		return Vector2( self.x / other.x, self.y / other.y )
	end 
	
	function meta:__mod( other ) 
		return Vector2( self.x % other.x, self.y % other.y ) 
	end 
	
	function meta:__pow( other ) 
		return Vector2( self.x ^ other.x, self.y ^ other.y ) 
	end
 
	function meta:__unm( ) 
		return Vector2( self.x * -1, self.y * -1 ) 
	end 
 
	function meta:__len( ) -- Garry has broken this =(
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
	
	function meta:Dot( other ) 
		return self.x * other.x + self.y * other.y 
	end 

	function meta:Normalize( ) 
		local Len = self:Length( ) 
		return Vector2( self.x / Len, self.y / Len ) 
	end 

	function meta:Round( dec ) 
		return Vector2( math.Round( self.x, dec ), math.Round( self.y, dec ) ) 
	end 

	function meta:Length( ) 
		return math.sqrt( self.x * self.x + self.y * self.y ) 
	end 
	
	function meta:Cross( other )
		return setmetatable( {
			x = ( self.y * other.z ) - ( other.y * self.z ),
			y = ( self.z * other.x ) - ( other.z * self.x )
		}, meta )
	end -- RevouluPowered

	function meta:Distance( other )
		return ( self - other ):Length()
	end -- RevouluPowered
	
	function meta:Set( x, y ) 
		self.x = x 
		self.y = y 
		return self 
	end 

	function meta:Add( x, y ) 
		self.x = self.x + x 
		self.y = self.y + y 
		return self 
	end 
	
	function meta:Sub( x, y )
		self.x = self.x - x 
		self.y = self.y - y 
		return self 
	end 
	
	function meta:Clone( )
		return Vector2( self.x, self.y )
	end

	local setmetatable = setmetatable 
	local Vec2 = { Zero = setmetatable({ x = 0, y = 0 }, meta) } 
	Vec2.__index = Vec2 

	function Vec2:__call( a, b ) 
		return setmetatable({x = a or 0, y = b or 0}, meta) 
	end 

	Vector2 = { } 
	setmetatable( Vector2, Vec2 ) 
	debug.getregistry().Vector2 = meta
end 