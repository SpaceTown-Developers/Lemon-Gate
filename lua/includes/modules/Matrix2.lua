/*==============================================================================================
	Matrix2
==============================================================================================*/
local setmetatable = setmetatable

local Meta = { } 
Meta.__index = Meta 

/**************************************************************************************/

function Meta:Clone( )
	local Copy = {}
	
	for K, V in ipairs( self ) do
		Copy[ K ] = V
	end
	
	return setmetatable( Copy, Meta )
end

function Meta:Det( )
	return ( self[1] * self[4] - self[3] * self[2] )
end

local function Meta:Inverse( )
	local Det = ( self[1] * self[4] - self[3] * self[2] )
	
	if Det == 0 then
		return Matrix2._Zero:Clone( )
	else
		return Matrix2( self[4] / Det, -self[2] / Det, -self[3] / Det, self[1] / Det )
	end
end

/**************************************************************************************/

function Meta:__add( Other ) 
	return setmetatable( { 
		self[1] + Other[1],
		self[2] + Other[2],
		self[3] + Other[3],
		self[4] + Other[4]
	 }, Meta )
end 

function Meta:__sub( Other ) 
	return setmetatable( { 
		self[1] - Other[1],
		self[2] - Other[2],
		self[3] - Other[3],
		self[4] - Other[4]
	 }, Meta )
end 

function Meta:__mul( Other ) 
	return setmetatable( { 
		self[1] * Other[1],
		self[2] * Other[2],
		self[3] * Other[3],
		self[4] * Other[4]
	 }, Meta )
end 

function Meta:__div( Other )
	return setmetatable( { 
		self[1] / Other[1],
		self[2] / Other[2],
		self[3] / Other[3],
		self[4] / Other[4]
	 }, Meta )
end 

function Meta:__unm( ) 
	return setmetatable( { -self[1], -self[2], -self[3], -self[4] }, Meta )
end 

function Meta:__eq( Other ) 
	return  ( self[1] == Other[1] ) and
			( self[2] == Other[2] ) and
			( self[3] == Other[3] ) and
			( self[4] == Other[4] )
end 

function Meta:__tostring( ) 
	return "Matrix2: " .. self[1] .. " " .. self[2] .. " " .. self[3] .. " ".. self[4] 
end 

/**************************************************************************************/

function Meta:Power( Other ) 
	if Other == -1 then
		return self:Inverse( )
	elseif B == 0 then
		return setmetatable( { 1, 0, 0, 1 }, Meta )
	elseif B == 1 then
		return self:Clone( )
	elseif B == 2 then
		return setmetatable( {
				self[1] * self[1] + self[2] * self[3],
				self[1] * self[2] + self[2] * self[4],
				self[3] * self[1] + self[4] * self[3],
				self[3] * self[2] + self[4] * self[4] }, Meta )
	else
		return Matrix2._Zero:Clone( )
	end
end

function Meta:Row( Row )
	local C
	
	if Row < 1 then
		C = 1
	elseif Row > 2 then
		C = 2
	else
		C = Row - Row % 1
	end
	
	return Vector2( self[C * 2 - 1], self[C * 2] )
end

function Meta:Column( Colum )
	local C
	
	if Colum < 1 then
		C = 1
	elseif Colum > 2 then
		C = 2
	else
		C = Colum - Colum % 1
	end

	return Vector2( self[C], self[C + 2] )
end

function Meta:SetRow( B, C, D )
	local E
	
	if B < 1 then
		E = 2
	elseif B > 2 then
		E = 4
	else
		E = (B - B % 1) * 2
	end
	
	local F = self:Clone( )
	F[E - 1] = C
	F[E] = D
	
	return F
end

function Meta:SetColum( B, C, D )
	local E
	
	if B < 1 then
		E = 1
	elseif B > 2 then
		E = 2
	else
		E = B - B % 1
	end

	local F = self:Clone( )
	F[E] = C
	F[E + 2] = D
	
	return F
end

function Meta:SwapRows( )
	return setmetatable( { self[3], self[4], self[1], self[2] }, Meta )
end

function Meta:SwapColums( )
	return setmetatable( { self[2], self[1], self[4], self[3] }, Meta )
end

function Meta:Element( B, C )
	local D, E
	
	if B < 1 then
		D = 1
	elseif B > 2 then
		D = 2
	else
		D = B - B % 1
	end

	if C < 1 then
		E = 1
	elseif C > 2 then
		E = 2
	else
		E = C - C % 1
	end

	return self[D + (E - 1) * 2]
end)

function Meta:SetElement( B, C, D )
	local E, F
	
	if B < 1 then
		E = 1
	elseif B > 2 then
		E = 2
	else
		E = B - B % 1
	end

	if C < 1 then
		F = 1
	elseif C > 2 then
		F = 2
	else
		F = C - C % 1
	end

	local G = self:Clone( )
	G[E + (F - 1) * 2] = D
	return G
end

function Meta:SwapElements( B, C, D, E )
	local F, G, H, I

	if B < 1 then
		F = 1
	elseif B > 3 then
		F = 3
	else
		F = B - B % 1
	end

	if C < 1 then
		G = 1
	elseif C > 3 then
		G = 3
	else
		G = C - C % 1
	end

	if D < 1 then
		H = 1
	elseif D > 3 then
		H = 3
	else
		H = D - D % 1
	end

	if E < 1 then
		I = 1
	elseif E > 3 then
		I = 3
	else
		I = E - E % 1
	end

	local J = F + (G - 1) * 2
	local K = H + (I - 1) * 2
	
	local L = self:Clone( )
	L[J], L[K] = self[K], self[J]
	
	return L
end

/******************************************************************************/

function Meta:Diagonal( )
	return Vector2( self[1], self[4] )
end

function Meta:Trace( )
	return self[1] + self[4]
end

function Meta:Transpose( )
	return setmetatable( { self[1], self[3], self[2], self[4] }, Meta )
end

function Meta:Adj( )
	return setmetatable( { self[4], -self[2], -self[3], self[1] }, Meta )
end

/**************************************************************************************/

local M2 = { Zero = setmetatable( { 0, 0, 0, 0 }, Meta ) } 
M2.__index = M2 

function M2:__call( self, Other, C, D ) 
	return setmetatable( { self, Other, C, D }, Meta ) 
end 

Matrix2 = { }

setmetatable( Matrix2, M2 ) 

debug.getregistry().Matrix2 = Meta