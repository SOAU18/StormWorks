count=0
function Pulse(bool)
    if bool and not previous_input then
        previous_input=true
        return true
    elseif previous_input then
        previous_input=false
    end
    return false
end
function onTick()
    axis1=input.getNumber(1)
    axis2=input.getNumber(2)
    CurrentX=input.getNumber(7)
    CurrentY=input.getNumber(8)
    TargetX=input.getNumber(9)
    TargetY=input.getNumber(10)
    Compass=input.getNumber(17)
--船の方向のコントロール
    --Axis1が0になったら現在向いている方向を記録
    if axis1==0 and not previous_input then
        heading=Compass
        previous_input=true
    elseif  previous_input then
        previous_input=false
    end
    --オートパイロットがオンならば舵角を目的地の方向に向ける
    if autopilot then
        Xdifference=TargetX-CurrentX
        Ydifference=TargetY-CurrentY
        TargetBearing=math.atan(Xdifference,Ydifference)-(math.pi*2)
        Rudder_angle=((TargetBearing%1-Compass%1+2.5)%1-0.5)*kp
    --オートパイロットがオフでaxis1が0ならば記録した方向を向き続ける(HDG hold)
    elseif axis1==0 then
        Rudder_angle=((heading%1-Compass%1+2.5)%1-0.5)*kp
    --その他の場合はaxis1をそのまま舵に流す
    else
        Rudder_angle=axis1
    end
--スピードのコントロール
    if Axis2=1 then
        UP=true
    elseif Axis2=-1 then
        Down=true
    else
        UP=false
        Down=false
    end
    if Pulse(UP) then
        count=count+1
    elseif Pulse(Down) then
        count=count-1
    end
    output.setNumber(1,Clutch_Pressure)
    output.setNumber(2,Rudder_angle)
    output.setBool(1,Gear)
end