function Pulse(bool)
    local previous_input=false
    return function(bool)
        if bool and not previous_input then
            previous_input=true
            return true
        elseif not bool and previous_input then
            previous_input=false
        end
        return false 
    end
end

function Threshold(number,low,max)
    return number>=low and number<=max
end

Count=6
TargetSpeeds={-15,-12,-9,-6,-3,0,3,6,9,12,15,18,21,24,27,30,33}
Axis1_pulse=Pulse()
UP_pulse=Pulse()
Down_pulse=Pulse()

function onTick()
    Axis1=input.getNumber(1)
    Axis2=input.getNumber(2)
    CurrentX=input.getNumber(7)
    CurrentY=input.getNumber(8)
    Currentspead=input.getNumber(9)
    Compass=input.getNumber(10)
    TargetX=input.getNumber(11)
    TargetY=input.getNumber(12)
    Autopilot=input.getBool(1)

    if Axis1_pulse(Threshold(Axis1,-0.1,0.1)) then
        Heading=Compass
    end
    if Autopilot then
        Xdifference=TargetX-CurrentX
        Ydifference=TargetY-CurrentY
        TargetBearing=math.atan(Xdifference,Ydifference)/(math.pi*2)
        Rudder_angle=((TargetBearing%1-Compass%1+2.5)%1-0.5)*1
    elseif Threshold(Axis1,-0.1,0.1) then
        Rudder_angle=(Heading-Compass)*2
    else
        Rudder_angle=Axis1
    end
    if UP_pulse(Axis2==1) and Count<17 then
        Count=Count+1
    elseif Down_pulse(Axis2==-1) and Count>1 then
        Count=Count-1
    end
    TargetSpeed=TargetSpeeds[Count]
    Gear=TargetSpeed<0
    Clutch_Pressure=(math.abs(TargetSpeed)-Currentspead*1.944)*0.5
    output.setNumber(1,Clutch_Pressure)
    output.setNumber(2,Rudder_angle)
    output.setNumber(3,TargetSpeed)
    output.setBool(1,Gear)
end