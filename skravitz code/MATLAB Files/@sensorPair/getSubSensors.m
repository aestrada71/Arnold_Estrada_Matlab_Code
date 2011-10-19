function sensorList = getSubSensors(s)

sensorList = [];

if get(s,'NumSensors') == 1
    sensorList = get(s,'Index');
    return;
end

s1 = get(s,'Sensor1');
s2 = get(s,'Sensor2');

if isa(s1,'sensorPair')
    sensorList = [sensorList getSubSensors(s1)];  
end
if isa(s2,'sensorPair')
    sensorList = [sensorList getSubSensors(s2)];  
end

end