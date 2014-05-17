if !WireLib or !LEMON then return end

include('shared.lua')

ENT.RenderGroup = RENDERGROUP_OPAQUE

/*==========================================================================
	Section: Editor Animation
==========================================================================*/
-- Jacked from E2

local RollDelta = 0 //math.rad( 80 )
local Emitter = ParticleEmitter( vector_origin )

ENT.NextSpark = CurTime()
ENT.NextSmoke = CurTime()

timer.Create( "Lemon_Editor_Animation", 1, 0, function( )
	//RollDelta = -RollDelta
	
	for _, Ply in pairs( player.GetAll( ) ) do
		if Ply:GetNWBool( "Lemon_Editor", false ) and Ply ~= LocalPlayer( ) then
			local BoneIndx = Ply:LookupBone("ValveBiped.Bip01_Head1") or Ply:LookupBone("ValveBiped.HC_Head_Bone") or 0
			local BonePos, BoneAng = Ply:GetBonePosition( BoneIndx )
			
			for I = 1, math.random( 0, 2 ) do
				local Particle = Emitter:Add("omicron/lemongear", BonePos + Vector(0, 0, 10) )
			
				if Particle then
					Particle:SetColor( 255, 255, 255 )
					Particle:SetVelocity( Vector( math.random(-8, 8), math.random(-8, 8), math.random(5, 15) ) )

					Particle:SetDieTime( 3 )
					Particle:SetLifeTime( 0 )

					Particle:SetStartSize( math.random(1, 3) )
					Particle:SetEndSize( math.random(2, 10) )

					Particle:SetStartAlpha( 255 )
					Particle:SetEndAlpha( 0 )

					Particle:SetRollDelta( RollDelta )
				end
			end
		end
	end
end )

/*==========================================================================
	Section: Crash Animation
==========================================================================*/
function ENT:GetSpinner( )
	if self:GetModel( ) ~= "models/lemongate/lemongate.mdl" then return end
	return self:LookupAttachment("fan_attch")

	--self:LocalToWorld( Vector( -2.873848, 2.881156, 0.910345 ) )
end

function ENT:Think( )
	local Status = self:GetStatus( )
	local Spinner = self:GetSpinner( )
	
	if self.EffectStatus ~= Status then
		self.EffectStatus = nil
		self:StopParticles( )
		
		if self:GetStatus() == 1 then -- 90%+
			self:Spark( Spinner )
			self.EffectStatus =  1
		elseif self:GetStatus() == 2 then -- Exceeded quota.
			self.EffectStatus = 2
			ParticleEffectAttach( "fire_verysmall_01", PATTACH_POINT_FOLLOW, self, Spinner )
		end
	end
	
	self:NextThink(CurTime() + 0.5)
	return true
end

function ENT:Spark( Spinner )
	local Pos = self:GetAttachment( Spinner ).Pos

	if(self.NextSpark < CurTime()) then
		local fx_dat = EffectData()
		fx_dat:SetMagnitude(math.random(0.1,0.3))
		fx_dat:SetScale(math.random(0.5,1.5))
		fx_dat:SetRadius(2)
		fx_dat:SetOrigin(Pos)
		util.Effect("sparks",fx_dat)
		self.NextSpark = CurTime() + math.Rand(0.2,1)
	end
end

function ENT:Draw()
	self.BaseClass.Draw( self )

	local Spinner = self:GetSpinner()
	if !Spinner then return end

	local Pos = self:GetAttachment( Spinner ).Pos

	local dist = LocalPlayer():GetPos():Distance(self:GetPos())
	if(self:GetStatus() == 3 && dist < 350) then
		local Fade = (350 - dist) / 350
		local R = math.Clamp(math.abs(math.sin(CurTime()*2))*255,200,255)
		render.SetMaterial(Material("sprites/glow04_noz"))
		render.DrawSprite(Pos, 17.5, 10, Color(R,10,10,255 * Fade))
		render.DrawSprite(Pos, 12.5, 15, Color(R,10,10,255 * Fade))
	end
end
