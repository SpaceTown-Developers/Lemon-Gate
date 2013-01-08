/*==============================================================================================
	Expression Advanced: Sound objects
	Purpose: A way of playing and manipulating sounds. 
	Author: Oskar
==============================================================================================*/
local E_A = LemonGate

E_A.API.NewComponent( "Sound", true )

E_A.Sounds = {}
local Sounds = E_A.Sounds

local function RemoveSounds(Entity)
	for snd, ent in pairs( Sounds[Entity] ) do 
		if type(snd) ~= "CSoundPatch" then continue end // GM13 <3 
		snd:Stop() 
	end 
	Sounds[Entity] = {}
end

E_A.API.AddHook("GateCreate", function(Entity)
	Sounds[Entity] = {}
end)

E_A.API.AddHook("GateRemove", RemoveSounds)
E_A.API.AddHook("BuildContext", RemoveSounds)

/*==============================================================================================
	Class
==============================================================================================*/
E_A:SetCost( EA_COST_CHEAP )

E_A:RegisterException( "sound" )
E_A:RegisterClass( "sound", "sd")
E_A:RegisterOperator("assign", "sd", "", E_A.AssignOperator)
E_A:RegisterOperator("variable", "sd", "sd", E_A.VariableOperator)

/*==============================================================================================
	Operators
==============================================================================================*/
E_A:RegisterOperator("is", "sd", "n", function(self, Value)
	local V = Value(self)
	return type(V) == "CSoundPatch" and 1 or 0 
end )

local function StopSound( ent, gate, snd ) 
	if type(snd) ~= "CSoundPatch" or !IsValid( gate ) then return end 
    if Sounds[gate] and Sounds[gate][snd] then Sounds[gate][snd] = nil end 
	snd:Stop()
end 

local maxSounds = 10 // Temp!!! 
local function crE_AteSound( path, ent, gate )
    if table.Count( Sounds[gate] ) >= maxSounds then return end 
    if string.match( path, '["?]' ) then return end 
    path = string.gsub( path:Trim(), "\\", "/" ) 
    local snd = CrE_AteSound( ent, path ) 
	ent:CallOnRemove( "StopE_ASound", StopSound, gate, snd ) 
	if ent != gate then gate:CallOnRemove( "StopE_ASound", StopSound, gate, snd ) end 
    Sounds[gate][ent] = snd
    return snd     
end 

E_A:RegisterFunction("sound", "es", "sd", function( self, Value, ValueB )
    local ent = Value( self )
    local snd = ValueB( self )
    if !IsValid( ent ) then self:Throw( "sound", "Invalid entity" ) end 
    return crE_AteSound( snd, ent, self.Entity )
end )

E_A:RegisterFunction("sound", "s", "sd", function( self, Value )
    local snd = Value( self )
    return crE_AteSound( snd, self.Entity, self.Entity )
end )

E_A:RegisterFunction("play", "sd:", "", function( self, Value ) 
    local snd = Value(self) 
    if type(snd) ~= "CSoundPatch" then return end 
    snd:Play() 
end )

E_A:RegisterFunction("play", "sd:nn", "", function( self, Value, ValueB, ValueC ) 
    local snd = Value(self) 
    if type(snd) ~= "CSoundPatch" then return end 
    local volume = ValueB(self) 
    local pitch = ValueC(self) 
    snd:PlayEx( math.Clamp( volume, 0, 1 ), math.Clamp( pitch, 0, 255 ) ) 
end )

E_A:RegisterFunction("volume", "sd:n", "", function( self, Value, ValueB ) 
    local snd = Value(self) 
    if type(snd) ~= "CSoundPatch" then return end 
    local volume = ValueB(self) 
    snd:ChangeVolume( math.Clamp( volume, 0, 1 ), 0 )
end )

E_A:RegisterFunction("volume", "sd:nn", "", function( self, Value, ValueB, ValueC ) 
    local snd = Value(self) 
    if type(snd) ~= "CSoundPatch" then return end 
    local volume = ValueB(self) 
	local fadetime = ValueC(self)
    snd:ChangeVolume( math.Clamp( volume, 0, 1 ), fadetime )
end )

E_A:RegisterFunction("pitch", "sd:n", "", function( self, Value, ValueB ) 
    local snd = Value(self) 
    if type(snd) ~= "CSoundPatch" then return end 
    local pitch = ValueB(self) 
    snd:ChangePitch( math.Clamp( pitch, 0, 255 ), 0 ) 
end )

E_A:RegisterFunction("pitch", "sd:nn", "", function( self, Value, ValueB, ValueC ) 
    local snd = Value(self) 
    if type(snd) ~= "CSoundPatch" then return end 
    local pitch = ValueB(self) 
	local fadetime = ValueC(self)
    snd:ChangePitch( math.Clamp( pitch, 0, 255 ), fadetime ) 
end )

E_A:RegisterFunction("soundLevel", "sd:n", "", function( self, Value, ValueB ) 
	local snd = Value(self)
    if type(snd) ~= "CSoundPatch" then return end 
	local level = ValueB(self)
	snd:SetSoundLevel( math.Clamp( level, 20, 180 ) )
end )

E_A:RegisterFunction("isPlaying", "sd:", "n", function( self, Value ) 
    local snd = Value(self) 
    if type(snd) ~= "CSoundPatch" then return 0 end 
    return snd:IsPlaying() and 1 or 0 
end ) 

E_A:RegisterFunction("stop", "sd:n", "", function( self, Value, ValueB ) 
    local snd = Value(self)
    if type(snd) ~= "CSoundPatch" then return end 
	local duration = ValueB(self)
    snd:FadeOut( duration ) 
end )

E_A:RegisterFunction("stop", "sd:", "", function( self, Value ) 
    local snd = Value(self)
    if type(snd) ~= "CSoundPatch" then return end 
    snd:Stop() 
end )

E_A:RegisterFunction("restart", "sd:", "", function( self, Value ) 
    local snd = Value(self)
    if type(snd) ~= "CSoundPatch" then return end 
    snd:Stop() 
	snd:Play() 
end )

E_A:RegisterFunction("remove", "sd:", "", function( self, Value ) 
    local snd = Value(self)
    if type(snd) ~= "CSoundPatch" then return end 
    snd:Stop()
    Sounds[self.Entity][snd] = nil 
end )
