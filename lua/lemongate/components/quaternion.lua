/*==============================================================================================
	Expression Advanced: Component -> Core.
	Creditors: Converted by shadowscion
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Core = API:GetComponent( "core" )

require( "quaternion" )

/*==============================================================================================
	Section: Quaternion
==============================================================================================*/
local Quaternion = Core:NewClass( "q", "quaternion" )

Quaternion:UsesMetaTable( FindMetaTable( "Quaternion" ) )

-- Quaternion:Wire_Name( "QUATERNION" )

-- function Quaternion.Wire_Out( Context, Cell )
	-- local Val = Context.Memory[ Cell ] or { 0, 0, 0, 0 }
	-- return Val
-- end

-- function Quaternion.Wire_In( Context, Cell, Value )
	-- Context.Memory[ Cell ] = { Value[1], Value[2], Value[3], Value[4] }
-- end

Core:AddOperator( "default", "q", "q", "$Quaternion.Zero:Clone()" )
Core:AddOperator( "string", "q", "s", [[("<" .. tostring( value %1 ) .. ">")]] )

/*==============================================================================================
	Section: Operators
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddOperator( "+", "q,q", "q", "(value %1 + value %2)" )
Core:AddOperator( "+", "n,q", "q", "(value %1 + value %2)" )
Core:AddOperator( "+", "q,n", "q", "(value %1 + value %2)" )

Core:AddOperator( "-", "q", "q", "(-value %1)" )
Core:AddOperator( "-", "q,q", "q", "(value %1 - value %2)" )
Core:AddOperator( "-", "n,q", "q", "(value %1 - value %2)" )
Core:AddOperator( "-", "q,n", "q", "(value %1 - value %2)" )

Core:AddOperator( "*", "q,n", "q", "(value %1 * value %2)" )
Core:AddOperator( "*", "n,q", "q", "(value %1 * value %2)" )

Core:AddOperator( "/", "q,n", "q", "(value %1 / value %2)" )

Core:AddOperator( "==", "q,q", "b", "(value %1 == value %2)" )
Core:AddOperator( "!=", "q,q", "b", "(value %1 != value %2)" )

Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddOperator( "^", "n,q", "q", "(value %1 ^ value %2)" )
Core:AddOperator( "^", "q,n", "q", "(value %1 ^ value %2)" )

Core:AddOperator( "*", "q,q", "q", [[
	local %AR, %AI, %AJ, %AK = value %1.r, value %1.i, value %1.j, value %1.k
	local %BR, %BI, %BJ, %BK = value %2.r, value %2.i, value %2.j, value %2.k

	local %Quat = Quaternion(
		%AR * %BR - %AI * %BI - %AJ * %BJ - %AK * %BK,
		%AR * %BI + %AI * %BR + %AJ * %BK - %AK * %BJ,
		%AR * %BJ + %AJ * %BR + %AK * %BI - %AI * %BK,
		%AR * %BK + %AK * %BR + %AI * %BJ - %AJ * %BI
	)
]], "%Quat" )

Core:AddOperator( "*", "q,v", "q", [[
	local %AR, %AI, %AJ, %AK = value %1.r, value %1.i, value %1.j, value %1.k
	local %BI, %BJ, %BK = value %2.x, value %2.y, value %2.z

	local %Quat = Quaternion(
		-%AI * %BI - %AJ * %BJ - %AK * %BK,
		 %AR * %BI + %AJ * %BK - %AK * %BJ,
		 %AR * %BJ + %AK * %BI - %AI * %BK,
		 %AR * %BK + %AI * %BJ - %AJ * %BI
	)
]], "%Quat" )

Core:AddOperator( "*", "v,q", "q", [[
	local %AR, %AI, %AJ, %AK = value %2.r, value %2.i, value %2.j, value %2.k
	local %BI, %BJ, %BK = value %1.x, value %1.y, value %1.z

	local %Quat = Quaternion(
		-%AI * %BI - %AJ * %BJ - %AK * %BK,
		 %AR * %BI + %AJ * %BK - %AK * %BJ,
		 %AR * %BJ + %AK * %BI - %AI * %BK,
		 %AR * %BK + %AI * %BJ - %AJ * %BI
	)
]], "%Quat" )

Core:AddOperator( "/", "n,q", "q", [[
	local %AR, %AI, %AJ, %AK = value %2.r, value %2.i, value %2.j, value %2.k
	local %Div = %AR * %AR + %AI * %AI + %AJ * %AJ + %AK * %AK

	local %Quat = Quaternion(
		(value %1 / %AR) / %Div, 
		(-value %1 / %AI) / %Div, 
		(-value %1 / %AJ) / %Div, 
		(-value %1 / %AK) / %Div
	)
]], "%Quat" )

Core:AddOperator( "/", "q,q", "q", [[
	local %AR, %AI, %AJ, %AK = value %1.r, value %1.i, value %1.j, value %1.k
	local %BR, %BI, %BJ, %BK = value %2.r, value %2.i, value %2.j, value %2.k
	local %Div = %BR * %BR + %BI * %BI + %BJ * %BJ + %BK * %BK

	local %Quat = Quaternion(
		( %AR * %BR + %AI * %BI + %AJ * %BJ + %AK * %BK) / %Div,
		(-%AR * %BI + %AI * %BR - %AJ * %BK + %AK * %BJ) / %Div,
		(-%AR * %BJ + %AJ * %BR - %AK * %BI + %AI * %BK) / %Div,
		(-%AR * %BK + %AK * %BR - %AI * %BJ + %AJ * %BI) / %Div
	)
]], "%Quat" )


/*==============================================================================================
	Section: Build Quat
==============================================================================================*/
Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "quat", "", "q", "$Quaternion.Zero:Clone()" )
Core:AddFunction( "quat", "n", "q", "$Quaternion(value %1, 0, 0, 0)" )
Core:AddFunction( "quat", "n,n,n,n", "q", "$Quaternion(value %1, value %2, value %3, value %4)" )
Core:AddFunction( "quat", "v", "q", "$Quaternion(0, value %1.x, value %1.y, value %1.z)" )

Core:AddFunction("qi", "", "q", "$Quaternion(0, 1, 0, 0)" )
Core:AddFunction("qj", "", "q", "$Quaternion(0, 0, 1, 0)" )
Core:AddFunction("qk", "", "q", "$Quaternion(0, 0, 0, 1)" )

Core:AddFunction("qi", "n", "q", "$Quaternion(0, value %1, 0, 0)" )
Core:AddFunction("qj", "n", "q", "$Quaternion(0, 0, value %1, 0)" )
Core:AddFunction("qk", "n", "q", "$Quaternion(0, 0, 0, value %1)" )

Core:SetPerf( LEMON_PERF_EXPENSIVE)

Core:AddFunction( "quat", "a", "q", "$Quaternion.Zero:Clone():AngleToQuat(value %1)" )
Core:AddFunction( "quat", "e", "q", "$IsValid(value %1) and $Quaternion.Zero:Clone():AngleToQuat(value %1:GetAngles()) or $Quaternion.Zero:Clone()" )
Core:AddFunction( "quat", "v,v", "q", "$Quaternion.Zero:Clone():VecsToQuat(value %1, value %2)" )

/*==============================================================================================
	Section: Get Quat
==============================================================================================*/
Core:SetPerf( LEMON_PERF_CHEAP )

Core:AddFunction( "real", "q:", "n", "(value %1.r)" )
Core:AddFunction( "i", "q:", "n", "(value %1.i)" )
Core:AddFunction( "j", "q:", "n", "(value %1.j)" )
Core:AddFunction( "k", "q:", "n", "(value %1.k)" )
Core:AddFunction( "vec", "q", "v", "$Vector3( value %1.i, value %1.j, value %1.k )" )

Core:AddFunction( "qMod", "q", "q", [[
	local %A = value %1
	local %Quat = %A.r < 0 and Quaternion(-%A.r, -%A.i, -%A.j, -%A.k) or %A
]], "%Quat" )

Core:SetPerf( LEMON_PERF_NORMAL )

Core:AddFunction( "forward", "q:", "v", [[
	local %A, %B, %C, %D = value %1.r, value %1.i, value %1.j, value %1.k
	local %E, %F = %C * 2, %D * 2
]], "$Vector3( %A * %A + %B * %B - %C * %C - %D * %D, %E * %B + %F * %A, %F * %B - %E * %A )" )

Core:AddFunction( "right", "q:", "v", [[
	local %A, %B, %C, %D = value %1.r, value %1.i, value %1.j, value %1.k
	local %E, %F, %G = %B * 2, %C * 2, %D * 2
]], "$Vector3( %G * %A - %E * %C, %B * %B - %A * %A + %D * %D - %C * %C, -%E * %A - %F * %D )" )

Core:AddFunction( "up", "q:", "v", [[
	local %A, %B, %C, %D = value %1.r, value %1.i, value %1.j, value %1.k
	local %E, %F = %B * 2, %C * 2
]], "$Vector3( %F * %A + %E * %D, %F * %D - %E * %A, %A * %A - %B * %B - %C * %C + %D * %D )" )

Core:AddFunction( "abs", "q", "n", [[
	local %A = value %1
	local %Quat = math.sqrt(%A.r * %A.r + %A.i * %A.i + %A.j * %A.j + %A.k * %A.k)
]], "%Quat" )

Core:AddFunction( "inv", "q", "q", [[
	local %A = value %1
	local %Div = %A.r * %A.r + %A.i * %A.i + %A.j * %A.j + %A.k * %A.k
	local %Quat = %Div == 0 and Quaternion(0, 0, 0, 0) or Quaternion(%A.r / %Div, -%A.i / %Div, -%A.j / %Div, -%A.k / %Div)
]], "%Quat" )

Core:AddFunction( "conj", "q", "q", "$Quaternion(value %1.r, -value %1.i, -value %1.j, -value %1.k)" )
Core:AddFunction( "exp", "q", "q", "(value %1:Exp())" )
Core:AddFunction( "log", "q", "q", "(value %1:Log())" )

Core:SetPerf( LEMON_PERF_ABNORMAL )

Core:AddFunction( "qRotation", "v,n", "q", "$Quaternion.Zero:Clone():RotateQuat(value %1, value %2)" )
Core:AddFunction( "qRotation", "v", "q", "$Quaternion.Zero:Clone():RotateQuat(value %1)" )
Core:AddFunction( "toAngle", "q:", "a", "(value %1:QuatToAngle())" )
Core:AddFunction( "slerp", "q,q,n", "q", "$Quaternion.Zero:Clone():SlerpQuat(value %1, value %2, value %3)" )

Core:AddFunction( "rotationAngle", "q", "n", [[
	local %Ret = 0
	local %Square = value %1.r * value %1.r + value %1.i * value %1.i + value %1.j * value %1.j + value %1.k * value %1.k
	if %Square then
		local %Root = math.sqrt(%Square)

		%Ret = 2 * math.acos(math.Clamp(value %1.r / %Root, -1, 1)) * (180 / math.pi)
		if %Ret > 180 then %Ret = %Ret - 360 end
	end
]], "%Ret" )

Core:AddFunction( "rotationAxis", "q", "v", [[
	local %Ret = Vector3(0, 0, 1)
	local %Square = value %1.i * value %1.i + value %1.j * value %1.j + value %1.k * value %1.k
	if %Square then
		local %Root = math.sqrt(%Square)

		%Ret = Vector3( value %1.i / %Root, value %1.j / %Root, value %1.k / %Root )
	end
]], "%Ret" )

Core:AddFunction( "rotationVector", "q", "v", [[
	local %Ret = Vector3(0, 0, 0)
	local %Square = value %1.r * value %1.r + value %1.i * value %1.i + value %1.j * value %1.j + value %1.k * value %1.k
	local %Max = math.max( value %1.i * value %1.i + value %1.j * value %1.j + value %1.k * value %1.k )
	if %Square and %Max then
		local %Acos = 2 * math.acos(math.Clamp(value %1.r / math.sqrt(%Square), -1, 1)) * (180 / math.pi)
		if %Acos > 180 then %Acos = %Acos - 360 end
		%Acos = %Acos / math.sqrt(%Max)

		%Ret = Vector3( value %1.i * %Acos, value %1.j * %Acos, value %1.k * %Acos )
	end
]], "%Ret" )