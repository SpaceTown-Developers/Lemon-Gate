/*==============================================================================================
	Expression Advanced: Sound objects
	Purpose: A way of playing and manipulating sounds. 
	Author: Oskar
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API 

API.NewComponent( "Sound", true )

local type = type
local CurTime = CurTime
local CreateSound = CreateSound
local setmetatable = setmetatable

local Clamp = math.Clamp
local StrMatch = string.match
local StrGsub = string.gsub

/*==============================================================================================
	API!
==============================================================================================*/
local Sounds = { }

local function RemoveSounds(Entity)
	if Sounds[Entity] then
		for _, Sound in pairs( Sounds[Entity] ) do
			Sound:Stop()
		end
	end
end

API.AddHook("BuildContext", function(Entity)
	RemoveSounds(Entity)
	Sounds[Entity] = { } 
end)

API.AddHook("ShutDown", function(Entity)
	RemoveSounds(Entity)
	Sounds[Entity] = nil
end)

timer.Create("LemonSounds", 0.1, 0, function()
	local Time = CurTime()
	
	for Gate, Sounds in pairs( Sounds ) do 
		for _, Sound in pairs( Sounds ) do
			if Sound and Sound.Duration > 0 and Sound:IsPlaying() then
				if Time > Sound.Duration + Sound.Start then
					if Sound.Fade > 0 then
						Sound:FadeOut(Sound.Fade)
					else
						Sound:Stop()
					end
				end
			elseif !Sound.Entity or !Sound.Entity:IsValid( ) then
				Sound:Stop()
				Sound.Sound = nil
				Sounds[ Sound ] = nil
			end
		end
	end
end)

/*==============================================================================================
	Sound Object
==============================================================================================*/
local EA_Sound = { }
EA_Sound.__index = EA_Sound

function EA_Sound:ChangePitch( A, B )
	if self.Sound then
		self.Pitch = A
		return self.Sound:ChangePitch( A, B )
	end
end

function EA_Sound:ChangeVolume( A, B )
	if self.Sound then
		self.Volume = A
		return self.Sound:ChangeVolume( A, B )
	end
end

function EA_Sound:SetSoundLevel( A, B )
	if self.Sound then
		self.Level = A
		return self.Sound:SetSoundLevel( A, B )
	end
end

function EA_Sound:FadeOut( A, B )
	if self.Sound then
		return self.Sound:FadeOut( A, B )
	end
end

function EA_Sound:IsPlaying( )
	if self.Sound then
		return self.Sound:IsPlaying( )
	end
end

function EA_Sound:Play( A )
	if self.Sound then
		self.Duration = A or 0
		self.Start = CurTime( )
		return self.Sound:Play( )
	end
end

function EA_Sound:Stop( )
	if self.Sound then
		return self.Sound:Stop( )
	end
end

/*==============================================================================================
	Sound Create/Remove
==============================================================================================*/
local function StopSound( Gate, Sound ) 
	if Gate and Gate:IsValid() then
        if Sound and type( Sound ) == "table" then
            Sound:Stop()
        end 
        if Sounds[Gate] and Sounds[Gate][Sound] then
            Sounds[Gate][Sound] = nil
        end 
	end
end

local function NewSound( Path, Entity, Gate )
    if !StrMatch( Path, '["?]' ) then
		Path = StrGsub( Path:Trim(), "\\", "/" ) 
		
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
		}, EA_Sound)
		
		Sounds[Gate][Sound] = Sound
		return Sound
	end
end

/*==============================================================================================
	Class and Operators
==============================================================================================*/
E_A:SetCost( EA_COST_CHEAP )

E_A:RegisterException( "sound" )
E_A:RegisterClass( "sound", "sd", function( ) return EA_Sound end)
E_A:RegisterOperator("assign", "sd", "", E_A.AssignOperator)
E_A:RegisterOperator("variable", "sd", "sd", E_A.VariableOperator)

E_A:RegisterOperator("is", "sd", "n", function(self, Value)
	local Sound = Value(self)
	return (Sound and Sound.Sound) and 1 or 0 
end)

/*==============================================================================================
	Constructor
==============================================================================================*/
E_A:RegisterFunction("sound", "s", "sd", function( self, Value )
    return NewSound( Value( self ), self.Entity, self.Entity )
end)

E_A:RegisterFunction("sound", "sn", "sd", function( self, ValueA, ValueB )
	local A, B = ValueA( self ), ValueB( self )
	local Sound = NewSound( A, self.Entity, self.Entity )
	Sound.Duration = B
	return Sound
end)

/***********************************************************************************************/

E_A:RegisterFunction("sound", "es", "sd", function( self, ValueA, ValueB )
	local A, B = ValueA( self ), ValueB( self )
	if A and A:IsValid() then
		return NewSound( B, A, self.Entity )
	else
		self:Throw("sound", "invalid attachment entity.")
	end
end)

E_A:RegisterFunction("sound", "esn", "sd", function( self, ValueA, ValueB, ValueC )
	local A, B, C = ValueA( self ), ValueB( self ), ValueC(self)
	if A and A:IsValid() then
		local Sound = NewSound( B, A, self.Entity )
		Sound.Duration = C
		return Sound
	else
		self:Throw("sound", "invalid attachment entity.")
	end
end)

/*==============================================================================================
	Play Function
==============================================================================================*/
E_A:RegisterFunction("play", "sd:", "", function( self, Value ) 
    local Sound = Value(self) 
    if Sound then
		Sound:Play( 0 )
	end
end)

E_A:RegisterFunction("play", "sd:n", "", function( self, ValueA, ValueB ) 
    local Sound, Duration = ValueA(self), ValueB(self)
    if Sound then
		Sound:Play( Duration )
	end
end)

E_A:RegisterFunction("isPlaying", "sd:", "n", function( self, Value ) 
    local Sound = Value(self) 
    if Sound then
		return Sound:IsPlaying( ) and 1 or 0
	end; return 0
end)

/*==============================================================================================
	Stop Function
==============================================================================================*/
E_A:RegisterFunction("stop", "sd:", "", function( self, Value ) 
    local Sound = Value(self) 
    if Sound and Sound:IsPlaying( ) then
		Sound:Stop( )
	end
end)

E_A:RegisterFunction("restart", "sd:", "", function( self, Value ) 
    local Sound = Value(self) 
    if Sound then
		if Sound:IsPlaying( ) then Sound:Stop( ) end
		Sound:Play( )
	end
end)

/*==============================================================================================
	Fade
==============================================================================================*/
E_A:RegisterFunction("fade", "sd:n", "", function( self, ValueA, ValueB ) 
    local Sound, Fade = ValueA(self), ValueB(self)
    if Sound then
		Fade = Clamp( Fade, 0, 1 )
		Sound:FadeOut( Fade )
		Sound.Fade = 0
	end
end)

E_A:RegisterFunction("fade", "sd:nn", "", function( self, ValueA, ValueB, ValueC ) 
    local Sound, Duration, Fade = ValueA(self), ValueB(self)
    if Sound then
		Sound.Duration = (CurTime( ) - Sound.Start) + Duration
		Sound.Fade = Clamp( Fade, 0, 1 )
	end
end)

/*==============================================================================================
	Duration
==============================================================================================*/
E_A:RegisterFunction("duration", "sd:", "n", function( self, Value ) 
    local Sound = Value(self)
    if Sound then
		local Duration = Sound.Duration
		if Duration == 0 then return 0 end
		return Duration
	end; return 0
end)

E_A:RegisterFunction("duration", "sd:n", "", function( self, ValueA, ValueB ) 
    local Sound, Duration = ValueA(self), ValueB(self)
    if Sound then
		Sound.Duration = (CurTime( ) - Sound.Start) + Duration
	end
end)

/*==============================================================================================
	Volume
==============================================================================================*/
E_A:RegisterFunction("volume", "sd:", "n", function( self, Value ) 
    local Sound = Value(self)
    if Sound then
		return Sound.Volume
	end; return 0
end)

E_A:RegisterFunction("volume", "sd:n", "", function( self, ValueA, ValueB ) 
    local Sound, Volume = ValueA(self), ValueB(self)
	if Sound then
		Volume = Clamp( Volume, 0, 1 )
		Sound:ChangeVolume( Volume, 0 )
	end
end)

/*==============================================================================================
	Pitch
==============================================================================================*/
E_A:RegisterFunction("pitch", "sd:", "n", function( self, Value ) 
    local Sound = Value(self)
    if Sound then
		return Sound.Pitch
	end; return 0
end)

E_A:RegisterFunction("pitch", "sd:n", "", function( self, ValueA, ValueB ) 
    local Sound, Pitch = ValueA(self), ValueB(self)
	if Sound then
		Pitch = Clamp( Pitch, 0, 255 )
		Sound:ChangePitch( Pitch, 0 )
	end
end)

/*==============================================================================================
	Pitch
==============================================================================================*/
E_A:RegisterFunction("level", "sd:", "n", function( self, Value ) 
    local Sound = Value(self)
    if Sound then
		return Sound.Level
	end; return 0
end)

E_A:RegisterFunction("level", "sd:n", "", function( self, ValueA, ValueB ) 
    local Sound, Level = ValueA(self), ValueB(self)
	if Sound then
		Level = Clamp( Level, 20, 180 )
		Sound:SetSoundLevel( Level, 0 )
	end
end)

/*==============================================================================================
	Sound & Entity
==============================================================================================*/
E_A:RegisterFunction("path", "sd:", "s", function( self, Value ) 
    local Sound = Value(self)
    if Sound then
		return Sound.Path
	end; return ""
end)

E_A:RegisterFunction("entity", "sd:", "e", function( self, Value ) 
    local Sound = Value(self)
    if Sound then
		return Sound.Entity
	end; return Entity(-1)
end)

E_A:RegisterFunction("sounds", "", "t", function(self)
	return E_A.NewResultTable(Sounds[self.Entity] or { }, "sd")
end)

/*==============================================================================================
	Casting
==============================================================================================*/
E_A:RegisterOperator("cast", "ssd", "s", function(self, Value)
	local Sound = Value(self)
	if Sound and Sound.Sound then
		return "Sound(" .. Sound.Path .. ")"
	else
		return "Sound(Void)"
	end
end)

E_A:RegisterFunction("toString", "v:", "sd", function(self, Value)
	local Sound = Value(self)
	if Sound and Sound.Sound then
		return "Sound(" .. Sound.Path .. ")"
	else
		return "Sound(Void)"
	end
end)