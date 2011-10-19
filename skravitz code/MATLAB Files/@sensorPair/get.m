function val = get(s, propName)
switch propName
    case 'Index'
        val = s.index;
    case 'Data'
        val = s.data;
    case 'Sensor1'
        val = s.sensor1;
    case 'Sensor2'
        val = s.sensor2;
    case 'SimCoeff'
        val = s.simCoeff;
    case 'Pos'
        val = s.pos;
    case 'XPos'
        pos = s.pos;
        val = pos(1);
    case 'YPos'
        pos = s.pos;
        val = pos(2);
    case 'NumSensors'
        val = s.numSensors;
    otherwise
        error([propName,' is not a valid sensorPair property.']);
end
end