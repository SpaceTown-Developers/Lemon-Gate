include('shared.lua')

ENT.RenderGroup = RENDERGROUP_OPAQUE

/*==========================================================================
	Section: Editor Animation
==========================================================================*/
-- Jacked from E2

local RollDelta = math.rad( 80 )
local Emitter = ParticleEmitter( vector_origin )

timer.Create( "Lemon_Editor_Animation", 1, 0, function( )
	RollDelta = -RollDelta
	
	for _, Ply in pairs( player.GetAll( ) ) do
		if Ply:GetNWBool( "Lemon_Editor", false ) and !Ply == LocalPlayer( ) then
			local BoneIndx = Ply:LookupBone("ValveBiped.Bip01_Head1") or Ply:LookupBone("ValveBiped.HC_Head_Bone") or 0
			local BonePos, BoneAng = Ply:GetBonePosition( BoneIndx )
			
			for I = 1, math.random( 0, 5 ) do
				local Particle = Emitter:Add("omicron/lemongear", BonePos + Vector(0, 0, 10) )
			
				if Particle then
					Particle:SetColor( 255, 244,79 )
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