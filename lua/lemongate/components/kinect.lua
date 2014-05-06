/*==============================================================================================
	Expression Advanced: Kinect.
	Creditors: Rusketh, Oskar94
==============================================================================================*/
AddCSLuaFile( )

/*==============================================================================================
	Client Side Stuffs!
==============================================================================================*/
if CLIENT then
						CreateClientConVar( "lemon_kinect_allow", 0, true, true )
	local Cvar_Status = CreateClientConVar( "lemon_kinect_status", 0, false, true )
	
	timer.Create( "Lemon_Kinect", 0.5, 0, function( )
		local Status = 0
		
		if motionsensor.IsAvailable( ) then
			Status = 1
			
			if motionsensor.IsActive( ) then
				Status = 2
			end
		end
		
		if Status ~= Cvar_Status:GetInt( ) then
			RunConsoleCommand( "lemon_kinect_status", Status )
		end
	end )
	
	return -- Client stuff is done!
end

/*==============================================================================================
	Server Side Stuffs!
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Component = API:NewComponent( "kinect", true )

Component:AddExternal( "HasKinect", function( Player )
	return IsValid(Player) and Player:IsPlayer( ) and (Player:GetInfoNum('lemon_kinect_status', 0) > 0) and (Player:GetInfoNum('lemon_kinect_allow', 0) > 0 )
end )

Component:AddExternal( "KinectActive", function( Player )
	return IsValid(Player) and Player:IsPlayer( ) and (Player:GetInfoNum('lemon_kinect_status', 0) == 2) and (Player:GetInfoNum('lemon_kinect_allow', 0) > 0 )
end )

/*==============================================================================================
	Section: Detection
==============================================================================================*/

Component:AddFunction( "hasKinect", "e:", "b", "%HasKinect(value %1)" )

Component:AddFunction( "kinectActive", "e:", "b", "%KinectActive(value %1)" )

Component:AddFunction( "startKinect", "e:", "", [[
if %HasKinect(value %1) and (value %1:GetInfoNum('lemon_kinect_status', 0) == 1) then
	value %1:SendLua( 'motionsensor.Start()' )
end]], LEMON_NO_INLINE )

/*==============================================================================================
	Section: Central Positions
==============================================================================================*/

Component:AddFunction( "kinectHip", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.HIP ) ) or Vector3( 0, 0, 0 ) )]] )

Component:AddFunction( "kinectSpine", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.SPINE ) ) or Vector3( 0, 0, 0 ) )]] )

Component:AddFunction( "kinectShoulder", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.SHOULDER ) ) or Vector3( 0, 0, 0 ) )]] )

Component:AddFunction( "kinectHead", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.HEAD ) ) or Vector3( 0, 0, 0 ) )]] )

/*==============================================================================================
	Section: Upper Body Left
==============================================================================================*/
Component:AddFunction( "kinectLeftShoulder", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.SHOULDER_LEFT ) ) or Vector3( 0, 0, 0 ) )]] )

Component:AddFunction( "kinectLeftElbow", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.ELBOW_LEFT ) ) or Vector3( 0, 0, 0 ) )]] )

Component:AddFunction( "kinectLeftWrist", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.WRIST_LEFT ) ) or Vector3( 0, 0, 0 ) )]] )

Component:AddFunction( "kinectLeftHand", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.HAND_LEFT ) ) or Vector3( 0, 0, 0 ) )]] )

/*==============================================================================================
	Section: Upper Body Right
==============================================================================================*/
Component:AddFunction( "kinectRightShoulder", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.SHOULDER_RIGHT ) ) or Vector3( 0, 0, 0 ) )]] )

Component:AddFunction( "kinectRightElbow", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.ELBOW_RIGHT ) ) or Vector3( 0, 0, 0 ) )]] )

Component:AddFunction( "kinectRightWrist", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.WRIST_RIGHT ) ) or Vector3( 0, 0, 0 ) )]] )

Component:AddFunction( "kinectRightHand", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.HAND_RIGHT ) ) or Vector3( 0, 0, 0 ) )]] )

/*==============================================================================================
	Section: Lower Body Left
==============================================================================================*/
Component:AddFunction( "kinectLeftHip", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.HIP_LEFT ) ) or Vector3( 0, 0, 0 ) )]] )

Component:AddFunction( "kinectLeftKnee", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.KNEE_LEFT ) ) or Vector3( 0, 0, 0 ) )]] )

Component:AddFunction( "kinectLeftAnkle", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.ANKLE_LEFT ) ) or Vector3( 0, 0, 0 ) )]] )

Component:AddFunction( "kinectLeftFoot", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.FOOT_LEFT ) ) or Vector3( 0, 0, 0 ) )]] )

/*==============================================================================================
	Section: Lower Body Right
==============================================================================================*/
Component:AddFunction( "kinectRightHip", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.HIP_RIGHT ) ) or Vector3( 0, 0, 0 ) )]] )

Component:AddFunction( "kinectRightKnee", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.KNEE_RIGHT ) ) or Vector3( 0, 0, 0 ) )]] )

Component:AddFunction( "kinectRightAnkle", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.ANKLE_RIGHT ) ) or Vector3( 0, 0, 0 ) )]] )

Component:AddFunction( "kinectRightFoot", "e:", "v",
[[( %KinectActive(value %1) and Vector3( value %1:MotionSensorPos( $SENSORBONE.FOOT_RIGHT ) ) or Vector3( 0, 0, 0 ) )]] )
