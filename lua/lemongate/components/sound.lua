/*==============================================================================================
	Expression Advanced: Component -> Core.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Component = API:NewComponent( "sound", true )

/*==============================================================================================
	API!
==============================================================================================*/
local Sounds = { }

function Component:RemoveSounds( Entity )
	if Sounds[Entity] then
		for _, Sound in pairs( Sounds[Entity] ) do
			Sound:Stop()
		end
	end
end

function Component:Create( Gate )
	Sounds[ Gate ] = { }
end

function Component:BuildContext( Gate )
	self:RemoveSounds( Gate )
end

function Component:Remove( Gate )
	self:RemoveSounds( Gate )
end

function Component:ShutDown( Gate )
	self:RemoveSounds( Gate )
end

timer.Create("LemonSounds", 0.1, 0, function( )
	local Time = CurTime()

	for Gate, Sounds in pairs( Sounds ) do 
		for _, Sound in pairs( Sounds ) do
			if Sound and Sound.Duration > 0 and Sound:IsPlaying( ) then
				if Time > Sound.Duration + Sound.Start then
					if Sound.Fade > 0 then
						Sound:FadeOut( Sound.Fade )
					else
						Sound:Stop( )
					end
				end
				
			elseif !Sound.Entity or !Sound.Entity:IsValid( ) then
				Sound:Stop( )
				Sound.Sound = nil
				Sounds[ Sound ] = nil
			end
		end
	end
end)

/*==============================================================================================
	Sound Object
==============================================================================================*/
local Sound = { }
Sound.__index = Sound

setmetatable( Sound, Sound )

function Sound.__call( _, Path, Entity, Gate )
    if !string.match( Path, '["?]' ) then
		Path = string.gsub( Path:Trim( ), "\\", "/" ) 

		local Sound = setmetatable({
			Sound = CreateSound( Entity, Path ),
			Entity = Entity or Gate,
			Volume = 1,
			Level = 80,
			Pitch = 100,
			Fade = 0,
			Start = 0,
			Path = Path,
			Duration = 0,
		}, Sound)

		Sounds[Gate][Sound] = Sound
		return Sound
	end
end

function Sound:Destroy( Context )	
	if IsValid( Context.Entity ) then
		Sounds[ Context.Entity ][ self ] = nil
	end; self:Stop()
end

function Sound.__tostring( Sound )
	return "sound( " .. ( Sound.Path or "" ) .. " ) "
end

/*============================================================================================*/

function Sound:ChangePitch( A, B )
	if self.Sound then
		self.Pitch = A
		return self.Sound:ChangePitch( A, B )
	end
end

function Sound:ChangeVolume( A, B )
	if self.Sound then
		self.Volume = A
		return self.Sound:ChangeVolume( A, B )
	end
end

function Sound:SetSoundLevel( A, B )
	if self.Sound then
		self.Level = A
		return self.Sound:SetSoundLevel( A, B )
	end
end

function Sound:FadeOut( A, B )
	if self.Sound then
		return self.Sound:FadeOut( A, B )
	end
end

function Sound:IsPlaying( )
	if self.Sound then
		return self.Sound:IsPlaying( )
	end
end

function Sound:Play( A )
	if self.Sound then
		self.Duration = A or 0
		self.Start = CurTime( )
		return self.Sound:Play( )
	end
end

function Sound:Stop( )
	if self.Sound then
		return self.Sound:Stop( )
	end
end

Component:AddExternal( "Sound", Sound )

function Sound.GetAll( Gate )
	return Sounds[ Gate ]
end

/*==============================================================================================
	Class and Operators
==============================================================================================*/
local Sound = Component:NewClass( "sd", "sound" )

Component:AddOperator( "is", "sd", "b", "local %Sound = value%1", "(%Sound and %Sound.Sound)" )

Component:AddOperator( "string", "sd", "s", "local %Sound = value%1", [["Sound(" .. ( %Sound and (%Sound.Path or "") or "") .. ")"]] )

/*==============================================================================================
	Creator Functions
==============================================================================================*/
Component:AddFunction( "sound", "s", "sd", "%Sound( value %1, %context.Entity, %context.Entity )" )

Component:AddFunction( "sound", "s,n", "sd", [[
local %SD = %Sound( value %1, %context.Entity, %context.Entity )
%SD.Duration = value %2
]], "%SD" )

Component:AddFunction( "sound", "e,s", "sd", [[
local %Entity, %SD = value %1
if $IsValid( %Entity ) then
	%SD = %Sound( value %2, %Entity, %context.Entity )
else
	%context:Throw( %trace, "sound", "Invalid attachment entity" )
end
]], "%SD" )

Component:AddFunction( "sound", "e,s,n", "sd", [[
local %Entity, %SD = value %1
if $IsValid( %Entity ) then
	%SD = %Sound( value %2, %Entity, %context.Entity )
	%SD.Duration = value %3
else
	%context:Throw( %trace, "sound", "Invalid attachment entity" )
end
]], "%SD" )

/*==============================================================================================
	Play Function
==============================================================================================*/
Component:AddFunction( "play", "sd:", "", [[
local %SD = value %1
if %SD then %SD:Play( 0 ) end]], "" )

Component:AddFunction( "play", "sd:n", "", [[
local %SD = value %1
if %SD then %SD:Play( value %2 ) end]], "" )

Component:AddFunction( "isPlaying", "sd:", "b", [[
local %SD, %Val = value %1, false
if %SD then %Val = %SD:IsPlaying( ) end]], "%Val" )

/*==============================================================================================
	Stop Function
==============================================================================================*/
Component:AddFunction( "stop", "sd:", "", [[
local %SD = value %1
if %SD and %SD:IsPlaying( ) then %SD:Stop( 0 ) end]], "" )

Component:AddFunction( "restart", "sd:", "", [[
local %SD = value %1
if %SD then
	if %SD:IsPlaying( ) then %SD:Stop( 0 ) end
	%SD:Play( )
end]], "" )

/*==============================================================================================
	Fade
==============================================================================================*/
Component:AddFunction( "fade", "sd:n", "", [[
local %SD = value %1
if %SD then
	%Fade = math.Clamp( value %2, 0, 1 )
	%SD:FadeOut( %Fade )
	%SD.Fade = 0
end]], "" )

Component:AddFunction( "fade", "sd:n,n", "", [[
local %SD = value %1
if %SD then
	%SD.Duration = ($CurTime( ) - %SD.Start) + value %3
	%SD.Fade = math.Clamp( value %2, 0, 1 )
end]], "" )

/*==============================================================================================
	Duration
==============================================================================================*/
Component:AddFunction( "duration", "sd:", "n", "local %SD = value %1", "(%SD ~= null and %SD.Duration or 0)" )

Component:AddFunction( "duration", "sd:n", "", [[
local %SD = value %1
if %SD then
	%SD.Duration = ($CurTime( ) - %SD.Start) + value %2
end]], "" )

/*==============================================================================================
	Volume
==============================================================================================*/
Component:AddFunction( "volume", "sd:", "n", "local %SD = value %1", "(%SD ~= null and %SD.Volume or 0)" )

Component:AddFunction( "volume", "sd:n", "", [[
local %SD = value %1
if %SD then
	%SD:ChangeVolume( math.Clamp( value %2, 0, 2 ), 0 )
end]], "" )

/*==============================================================================================
	Pitch
==============================================================================================*/
Component:AddFunction( "pitch", "sd:", "n", "local %SD = value %1", "(%SD ~= null and %SD.Pitch or 0)" )

Component:AddFunction( "pitch", "sd:n", "", [[
local %SD = value %1
if %SD then
	Sound:ChangePitch( math.Clamp( value %2, 0, 255 ), 0 )
end]], "" )

/*==============================================================================================
	Level
==============================================================================================*/
Component:AddFunction( "level", "sd:", "n", "local %SD = value %1", "(%SD ~= null and %SD.Level or 0)" )

Component:AddFunction( "level", "sd:n", "", [[
local %SD = value %1
if %SD then
	Sound:SetSoundLevel( math.Clamp( value %2, 20, 180 ), 0 )
end]], "" )

/*==============================================================================================
	Sound & Entity
==============================================================================================*/
Component:AddFunction( "path", "sd:", "s", "local %SD = value %1", "(%SD ~= null and %SD.Path or \"\")" )

Component:AddFunction( "entity", "sd:", "s", "local %SD = value %1", "(%SD ~= null and %SD.Entity or %NULL_ENTITY)" )

Component:AddFunction( "sounds", "", "t", "%Table.Results( %Sound.GetAll( %context.Entity ), \"s\" )" )