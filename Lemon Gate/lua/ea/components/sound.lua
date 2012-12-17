/*==============================================================================================
	Expression Advanced: Sound objects
	Purpose: A way of playing and manipulating sounds. 
	Author: Oskar
==============================================================================================*/
local EA = LemonGate

EA.API.NewComponent( "Sound", true )

EA.Sounds = {}
local Sounds = EA.Sounds

EA:RegisterClass( "sound", "sd" )

EA.API.AddHook("GateCreate", function(Entity)
	Sounds[Entity] = {}
end)

EA.API.AddHook("GateRemove", function(Entity)
    for snd, ent in pairs( Sounds[Entity] ) do snd:Stop() end 
	Sounds[Entity] = nil
end)

EA.API.AddHook("BuildContext", function(Entity)
    for snd, ent in pairs( Sounds[Entity] ) do snd:Stop() end 
	Sounds[Entity] = {}
end)

EA:SetCost( EA_COST_CHEAP ) 

EA:RegisterOperator("assign", "sd", "", function(self, ValueOp, Memory)
	self.Memory[Memory] = ValueOp(self) 
	self.Click[Memory] = true 
end )

EA:RegisterOperator("variabel", "sd", "sd", function(self, Memory)
	return self.Memory[Memory] 
end )

EA:RegisterOperator("is", "sd", "n", function(self, Value)
	local V = Value(self)
	return type(V) == "CSoundPatch" and 1 or 0 
end )

local function StopSound( ent, gate, snd ) 
	snd:Stop()
	Sounds[gate][snd] = nil 
end 

local maxSounds = 10 // Temp!!! 
local function createSound( path, ent, gate )
    if table.Count( Sounds[gate] ) >= maxSounds then return end 
    if string.match( path, '["?]' ) then return end 
    path = string.gsub( path:Trim(), "\\", "/" ) 
    local snd = CreateSound( ent, path ) 
	if ent ~= gate then ent:CallOnRemove( "StopEASound", StopSound, gate, snd ) end 
    Sounds[gate][ent] = snd
    return snd     
end 

EA:RegisterFunction("createSound", "es", "sd", function( self, ValueA, ValueB )
    local ent = ValuesA( self )
    local snd = ValuesB( self )
    return createSound( snd, ent, self.Entity )
end )

EA:RegisterFunction("createSound", "s", "sd", function( self, Value )
    local snd = Value( self )
    return createSound( snd, self.Entity, self.Entity )
end )

EA:RegisterFunction("play", "sd:", "", function( self, Value ) 
    local snd = Value(self) 
    if type(snd) ~= "CSoundPatch" then return end 
    snd:Play() 
end )

EA:RegisterFunction("play", "sd:nn", "", function( self, ValueA, ValueB, ValueC ) 
    local snd = ValueA(self) 
    if type(snd) ~= "CSoundPatch" then return end 
    local volume = ValueB(self) 
    local pitch = ValueC(self) 
    snd:PlayEx( math.Clamp( volume, 0, 1 ), math.Clamp( pitch, 0, 255 ) ) 
end )

EA:RegisterFunction("changeVolume", "sd:n", "", function( self, ValueA, ValueB ) 
    local snd = ValueA(self) 
    if type(snd) ~= "CSoundPatch" then return end 
    local volume = ValueB(self) 
    snd:ChangeVolume( math.Clamp( volume, 0, 1 ), 0 )
end )

EA:RegisterFunction("changeVolume", "sd:nn", "", function( self, ValueA, ValueB, ValueC ) 
    local snd = ValueA(self) 
    if type(snd) ~= "CSoundPatch" then return end 
    local volume = ValueB(self) 
	local fadetime = ValueC(self)
    snd:ChangeVolume( math.Clamp( volume, 0, 1 ), fadetime )
end )

EA:RegisterFunction("changePitch", "sd:n", "", function( self, ValueA, ValueB ) 
    local snd = ValueA(self) 
    if type(snd) ~= "CSoundPatch" then return end 
    local pitch = ValueB(self) 
    snd:ChangePitch( math.Clamp( pitch, 0, 255 ), 0 ) 
end )

EA:RegisterFunction("changePitch", "sd:nn", "", function( self, ValueA, ValueB, ValueC ) 
    local snd = ValueA(self) 
    if type(snd) ~= "CSoundPatch" then return end 
    local pitch = ValueB(self) 
	local fadetime = ValueC(self)
    snd:ChangePitch( math.Clamp( pitch, 0, 255 ), fadetime ) 
end )

EA:RegisterFunction("changeSoundLevel", "sd:n", "", function( self, ValueA, ValueB ) 
	local snd = ValueA(self)
    if type(snd) ~= "CSoundPatch" then return end 
	local level = ValueB(self)
	snd:SetSoundLevel( math.Clamp( level, 20, 180 ) )
end )

EA:RegisterFunction("isPlaying", "sd:", "n", function( self, Value ) 
    local snd = Value(self) 
    if type(snd) ~= "CSoundPatch" then return 0 end 
    return snd:IsPlaying() and 1 or 0 
end ) 

EA:RegisterFunction("stop", "sd:n", "", function( self, ValueA, ValueB ) 
    local snd = ValueA(self)
    if type(snd) ~= "CSoundPatch" then return end 
	local duration = ValueB(self)
    snd:FadeOut( duration ) 
end )

EA:RegisterFunction("stop", "sd:", "", function( self, Value ) 
    local snd = Value(self)
    if type(snd) ~= "CSoundPatch" then return end 
    snd:Stop() 
end )

EA:RegisterFunction("remove", "sd:", "", function( self, Value ) 
    local snd = Value(self)
    if type(snd) ~= "CSoundPatch" then return end 
    snd:Stop()
    Sounds[self.Entity][snd] = nil 
end )
