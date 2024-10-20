previousYawError,yawIntegral=0,0
previousPitchError,pitchIntegral=0,0
CruiseALT=500
pi=math.pi
sin=math.sin
cos=math.cos
sqrt=math.sqrt
atan=math.atan
TargetData={x=0,y=0,z=0}
function calculateTrig(r)
    return cos(r),sin(r)
end
function rotX(x,r)
    cosR,sinR=calculateTrig(r)
    return {x[1],cosR*x[2]-sinR*x[3],sinR*x[2]+cosR*x[3]}
end

function rotY(x,r)
    cosR,sinR=calculateTrig(r)
    return {cosR*x[1]+sinR*x[3],x[2],-sinR*x[1]+cosR*x[3]}
end

function rotZ(x,r)
    cosR,sinR=calculateTrig(r)
    return {cosR*x[1]-sinR*x[2],sinR*x[1]+cosR*x[2],x[3]}
end
function PID(P,I,D,Setpoint,Current_value,previous_error,integral)
    error=Setpoint-Current_value
    integral=integral+error
    derivative=error-previous_error
    output_value=P*error+I*integral+D*derivative
    return output_value,error,integral
end
function onTick()
    Launch=input.getBool(1)
    TargetX=input.getNumber(1)
    TargetY=input.getNumber(2)
    TargetZ=input.getNumber(3)
    CurrentX=input.getNumber(4)
    CurrentY=input.getNumber(5)
    CurrentZ=input.getNumber(6)
    EulerX=input.getNumber(7)
    EulerY=input.getNumber(8)
    EulerZ=input.getNumber(9)
    Compass=input.getNumber(10)
    if Launch then
		Launched=true
	end
    if TargetZ==nil then
       TargetZ=0
    end 
    if Launched then
        if not(previous_input) then
            TargetData={x=TargetX,y=TargetY,z=TargetZ}
            Initial_altitude=CurrentZ
            Xdifference=TargetX-CurrentX
            Ydifference=TargetY-CurrentY
            Initial_Distance=((Xdifference^2)+(Ydifference^2))^0.5
        end
        v1={0,0,1}
        v1=rotZ(rotY(rotX(v1,EulerX),EulerY),EulerZ)
        hdg=atan(v1[1],v1[3])
        elv=atan(v1[2],sqrt(v1[1]^2+v1[3]^2))
        v2={1,0,0}
        v2=rotZ(rotY(rotX(v2,EulerX),EulerY),EulerZ)
        v3={1,0,0}
        v3=rotY(rotX(v3,elv),hdg)
        crs={v2[2]*v3[3]-v2[3]*v3[2],v2[3]*v3[1]-v2[1]*v3[3],v2[1]*v3[2]-v2[2]*v3[1]}
        sgn=(v1[1]*crs[1]+v1[2]*crs[2]+v1[3]*crs[3]>=0) and 1or-1
        crsMagnitude=sqrt(crs[1]^2+crs[2]^2+crs[3]^2)*sgn
        dot=v2[1]*v3[1]+v2[2]*v3[2]+v2[3]*v3[3]
        rol=atan(crsMagnitude,dot)
        Xdifference=(TargetData.x)-CurrentX
        Ydifference=(TargetData.y)-CurrentY
        TargetBearing=atan(Xdifference,Ydifference)*(180/pi)
        if TargetBearing<0 then
            TargetBearing=TargetBearing+360
        end
        CompassD=(Compass+1)%1*360
        YawError=((CompassD-TargetBearing)%360+540)%360-180
        Adjusted_Yaw,previousYawError,yawIntegral=PID(0.2,0.000001,0.55,0,YawError,previousYawError,yawIntegral)
        Distance=((Xdifference^2)+(Ydifference^2))^0.5
        progressRatio=1-(Distance/Initial_Distance)
        interpolatedAltitude=(1-progressRatio)^3*Initial_altitude+3*(1-progressRatio)^2*progressRatio*CruiseALT+3*(1-progressRatio)*progressRatio^2*CruiseALT+progressRatio^3*(TargetData.z)
        Adjusted_Pitch,previousPitchError,pitchIntegral=PID(0.025,0.000001,3.4,interpolatedAltitude,CurrentZ,previousPitchError,pitchIntegral)
        if EulerX<0 and EulerY>0 then
            AngleCorrection=EulerY
        else
            AngleCorrection=2*pi+EulerY
        end
        if EulerX>=0 then
            AngleCorrection=pi-EulerY
        end
        AngleCorrection=AngleCorrection*(180/pi)
        AngleCorrection=((TargetBearing-AngleCorrection)%360+540)%360-180
        if not(1.3<=elv and elv<=1.84) then
            AngleCorrection=YawError
        end
        AngleCorrection=AngleCorrection*(pi/180)
        if 1.3<=elv and elv<=1.84 then
            Adjusted_Yaw=0
            Adjusted_Pitch=-5
        else
            rol=AngleCorrection
        end
        Yaw=-Adjusted_Pitch*sin(rol)-Adjusted_Yaw*cos(rol)
        Pitch=Adjusted_Pitch*cos(rol)-Adjusted_Yaw*sin(rol)
        previous_input=true
    end
    output.setNumber(1,Yaw)
    output.setNumber(2,Pitch)
end