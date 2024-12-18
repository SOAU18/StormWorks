Count=1
kp=0.1
TargetSpeeds={}
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
--船の方向のコントロール
    --Axis1が0になったら現在向いている方向を記録
    if Axis1_pulse(Threshold(Axis1,-0.1,0.1)) then
        Heading=Compass
    end
    --オートパイロットがオンならば舵角を目的地の方向に向ける
    if Autopilot then
        Xdifference=TargetX-CurrentX
        Ydifference=TargetY-CurrentY
        TargetBearing=math.atan(Xdifference,Ydifference)-(math.pi*2)
        Rudder_angle=((TargetBearing%1-Compass%1+2.5)%1-0.5)*kp
    --オートパイロットがオフでaxis1が0ならば記録した方向を向き続ける(HDG hold)
    elseif Threshold(Axis1,-0.1,0.1) then
        Rudder_angle=((Heading%1-Compass%1+2.5)%1-0.5)*kp
    --その他の場合はaxis1をそのまま舵に流す
    else
        Rudder_angle=Axis1
    end
--スピードのコントロール
    if UP_pulse(Axis2==1) and Count<Max_Value then
        Count=Count+1
    elseif Down_pulse(Axis2==-1) and Count>1 then
        Count=Count-1
    end
    TargetSpeed=TargetSpeeds[Count]
    if TargetSpeed<0 then
        Gear=true
    end
    Clutch_Pressure=math.abs((TargetSpeed-Currentspead)*kp)
    output.setNumber(1,Clutch_Pressure)
    output.setNumber(2,Rudder_angle)
    output.setBool(1,Gear)
end