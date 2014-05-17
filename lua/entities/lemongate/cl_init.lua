if !WireLib or !LEMON then return end

include('shared.lua')
CreateClientConVar( "lemon_share_keys", 0, true, true )
CreateConVar( "lemongate_perf", "25000", {FCVAR_REPLICATED} )

ENT.RenderGroup = RENDERGROUP_OPAQUE

/*==========================================================================
	Section: OverLay
==========================================================================*/
function ENT:GetOverlayText( )
	return "LemonGate: Status Uknown\nWiremod on workshop is outdated."
end

/*==========================================================================
	Section: Editor Animation
==========================================================================*/
-- Jacked from E2

local RollDelta = 0 //math.rad( 80 )
local Emitter = ParticleEmitter( vector_origin )

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
timer.Create( "Lemon_Crash_Animation", 1, 0, function( )
	
	for _, Gate in pairs( ents.FindByClass( "lemongate" ) ) do
		if Gate:GetNWBool( "Crashed" ) then
			
			local Particle = Emitter:Add("omicron/lemongear", (Gate:GetPos( ) + Gate:GetUp( ) * 3) )
			
			if Particle then
				Particle:SetColor( 255, 0, 0 )
				Particle:SetVelocity( (Gate:GetUp( ) * 5) + Vector( 0, 0, 5 ) )

				Particle:SetDieTime( 3 )
				Particle:SetLifeTime( 0 )

				Particle:SetStartSize( 0 )
				Particle:SetEndSize( 3 )

				Particle:SetStartAlpha( 255 )
				Particle:SetEndAlpha( 0 )

				Particle:SetRollDelta( RollDelta )
			end
		end
	end
end )

/*==========================================================================
	Section: Entity Context
==========================================================================*/
