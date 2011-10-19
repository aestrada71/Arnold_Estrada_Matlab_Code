function s = set(s, propName, val)
switch propName
    case 'Pos'
        s.pos = val;
    otherwise
        error([propName,' is not a valid sensorPair property or cannot be set.']);
end
end