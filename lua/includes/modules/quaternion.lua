/*---------------------------------------------------------------------------
Quaternion class
Author: Converted by shadowscion
---------------------------------------------------------------------------*/
do  
	local meta = {} 
	meta.__index = meta 
	
	/*==============================================================================================
	Section: Helper
	==============================================================================================*/
	local deg2rad = math.pi / 180
	local rad2deg = 180 / math.pi
	local sqrt = math.sqrt
	local acos = math.acos
	local abs = math.abs
	local cos = math.cos
	local sin = math.sin
	local exp = math.exp
	local log = math.log
	local clamp = math.Clamp

	local function QuatMul( A, B )
		local AR, AI, AJ, AK = A.r, A.i, A.j, A.k
		local BR, BI, BJ, BK = B.r, B.i, B.j, B.k

		local Quat = Quaternion(
			AR * BR - AI * BI - AJ * BJ - AK * BK,
			AR * BI + AI * BR + AJ * BK - AK * BJ,
			AR * BJ + AJ * BR + AK * BI - AI * BK,
			AR * BK + AK * BR + AI * BJ - AJ * BI
		)
		return Quat
	end

	local function QuatPow( r, i, j, k )
		local square = sqrt( i*i + j*j + k*k )
		local sine = square != 0 and { i * sin(square) / square, j * sin(square) / square, k * sin(square) / square } or { 0, 0, 0 }
		local ret = exp(r)

		return Quaternion( ret*cos(square), ret*sine[1], ret*sine[2], ret*sine[3] )
	end

	local function QuatLog( other )
		local r, i, j, k = other.r, other.i, other.j, other.k
		local square = sqrt( r*r + i*i + j*j + k*k )
		if square == 0 then return Quaternion(-1e+100, 0, 0, 0) end

		local A = { r/square, i/square, j/square, k/square }
		local B = acos(A[1])
		local C = sqrt(A[2]*A[2] + A[3]*A[3] + A[4]*A[4])

		return abs(C) > 0 and Quaternion(log(square), B*A[2]/C, B*A[3]/C, B*A[4]/C) or Quaternion(log(square), 0, 0, 0)
	end

	/*==============================================================================================
	Section: Meta
	==============================================================================================*/
	function meta:__add( other )
		if type( self ) == "number" then
			return Quaternion( self + other.r, other.i, other.j, other.k )
		elseif type( other ) == "number" then
			return Quaternion( other + self.r, self.i, self.j, self.k )
		else
			return Quaternion( self.r + other.r, self.i + other.i, self.j + other.j, self.k + other.k )
		end
	end

	function meta:__sub( other )
		if type( self ) == "number" then
			return Quaternion( self - other.r, -other.i, -other.j, -other.k )
		elseif type( other ) == "number" then
			return Quaternion( self.r - other, self.i, self.j, self.k )
		else
			return Quaternion( self.r - other.r, self.i - other.i, self.j - other.j, self.k - other.k )
		end
	end

	function meta:__mul( other )
		if type( self ) == "number" then
			return Quaternion( other.r * self, other.i * self, other.j * self, other.k * self )
		elseif type( other ) == "number" then
			return Quaternion( self.r * other, self.i * other, self.j * other, self.k * other )
		end
	end

	function meta:__div( other )
		if type( other ) == "number" then
			return Quaternion( self.r / other, self.i / other, self.j / other, self.k / other )
		end
	end

	function meta:__unm( )
		return Quaternion( self.r * -1, self.i * -1, self.j * -1, self.k * -1 )
	end 
	
	function meta:__pow( other )
		if type( self ) == "number" then
			local power = log(self)
			return self == 0 and Quaternion(0, 0, 0, 0) or QuatPow( power * other.r, power * other.i, power * other.j, power * other.k )
		else
			local power = QuatLog( self )
			return QuatPow( power.r * other, power.i * other, power.j * other, power.k * other )
		end
	end

	function meta:__eq( other ) 
		return self.r == other.r and self.i == other.i and self.j == other.j and self.k == other.k
	end

	function meta:Exp( )
		return QuatPow( self.r, self.i, self.j, self.k )
	end
	
	function meta:Log( )
		return QuatLog( self )
	end

	function meta:SlerpQuat( A, B , C )
		local Dot = A.r*B.r + A.i*B.i + A.j*B.j + A.k*B.k
		local Len = Dot < 0 and Quaternion(-B.r, -B.i, -B.j, -B.k) or B

		local Square = A.r*A.r + A.i*A.i + A.j*A.j + A.k*A.k
		if Square == 0 then return Quaternion(0, 0, 0, 0) end

		local Inverse = Quaternion(A.r / Square, -A.i / Square, -A.j / Square, -A.k / Square)
		local Log = QuatLog(QuatMul(Inverse, Len))

		return QuatMul(A, QuatPow(Log.r*C, Log.i*C, Log.j*C, Log.k*C))
	end

	function meta:RotateQuat( A, B )
		if type( B ) == "number" then
			local Ang = B * deg2rad * 0.5
			local Axis = A:Garry()
			Axis:Normalize()

			return Quaternion( cos(Ang), Axis.x * sin(Ang), Axis.y * sin(Ang), Axis.z * sin(Ang) )
		else
			local Axis = A:Garry()
			local Squared = Axis.x * Axis.x + Axis.y * Axis.y + Axis.z * Axis.z
			if Squared == 0 then return Quaternion(0, 0, 0, 0) end

			local Length = sqrt(Squared)
			local Ang = ((Length + 180) % 360 - 180) * deg2rad * 0.5
			local Sine = sin(Ang) / Length

			return Quaternion( cos(Ang), Axis.x * Sine, Axis.y * Sine, Axis.z * Sine )
		end
	end

	function meta:AngleToQuat( A )
		local P = A.p * deg2rad * 0.5
		local Y = A.y * deg2rad * 0.5
		local R = A.r * deg2rad * 0.5

		local QP = Quaternion(cos(P), 0, sin(P), 0)
		local QY = Quaternion(cos(Y), 0, 0, sin(Y))
		local QR = Quaternion(cos(R), sin(R), 0, 0)

		return QuatMul(QY, QuatMul(QP, QR))
	end

	function meta:QuatToAngle()
		local Square = sqrt( self.r*self.r + self.i*self.i + self.j*self.j + self.k*self.k )
		if Square == 0 then return Angle(0, 0, 0) end
		local QR, QI, QJ, QK = self.r / Square, self.i / Square, self.j / Square, self.k / Square

		local X = Vector(QR*QR + QI*QI - QJ*QJ - QK*QK, 2*QJ*QI + 2*QK*QR, 2*QK*QI - 2*QJ*QR)
		local Y = Vector(2*QI*QJ - 2*QK*QR, QR*QR - QI*QI + QJ*QJ - QK*QK, 2*QI*QR + 2*QJ*QK)

		local Ang = X:Angle()
		if Ang.p > 180 then Ang.p = Ang.p - 360 end
		if Ang.y > 180 then Ang.y = Ang.y - 360 end

		local Yaw = Vector(0, 1, 0)
		Yaw:Rotate(Angle(0, Ang.y, 0))

		local Roll = acos(clamp(Y:Dot(Yaw), -1, 1)) * rad2deg
		local Dot = QI*QR + QJ*QK
		if Dot < 0 then Roll = -Roll end

		return Angle(Ang.p, Ang.y, Roll)
	end

	function meta:VecsToQuat( A, B )
		local X, Z = A:Garry(), B:Garry()
		local Y = Z:Cross(X):GetNormalized()

		local Ang = X:Angle()
		if Ang.p > 180 then Ang.p = Ang.p - 360 end
		if Ang.y > 180 then Ang.y = Ang.y - 360 end

		local Yaw = Vector(0, 1, 0)
		Yaw:Rotate( Angle(0, Ang.y, 0) )

		local Roll = acos(clamp(Y:Dot(Yaw), -1, 1)) * rad2deg
		if Y.z < 0 then Roll = -Roll end

		return self:AngleToQuat( Angle(Ang.p, Ang.y, Roll) )
	end

	function meta:__call( r, i, j, k ) 
		return self.r + (r or 0), self.i + (i or 0), self.j + (j or 0), self.k + (k or 0) 
	end 
 
	function meta:__tostring( ) 
		return "Quaternion<" .. self.r .. ", " .. self.i .. ", " .. self.j .. ", " .. self.k .. ">"
	end 

	function meta:Clone( )
		return Quaternion( self.r, self.i, self.j, self.k )
	end

	local setmetatable = setmetatable 
	local Quat = { Zero = setmetatable({ r = 0, i = 0, j = 0, k = 0 }, meta) } 
	Quat.__index = Quat 

	function Quat:__call( a, b, c, d ) 
		return setmetatable({ r = a or 0, i = b or 0, j = c or 0, k = d or 0 }, meta) 
	end 

	Quaternion = { } 
	setmetatable( Quaternion, Quat ) 
	debug.getregistry().Quaternion = meta
end 
