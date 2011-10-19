function posList = getPosList(s,prevPosList)

posList = prevPosList;
if get(s,'XPos') >= 0
    posList = [posList get(s,'Pos')];
end
s1 = get(s,'Sensor1');
s2 = get(s,'Sensor2');
if isa(s1,'sensorPair')
    posList = getPosList(s1,posList);
end
if isa(s2,'sensorPair')
    posList = getPosList(s2,posList);
end
end