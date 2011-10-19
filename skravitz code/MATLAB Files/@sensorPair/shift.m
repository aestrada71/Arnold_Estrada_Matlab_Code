function s = shift(s, dist)
    if isempty(s.pos)
        return;
    end
    s.pos = s.pos + dist;
    if ~isempty(s.sensor1) 
        s.sensor1 = shift(s.sensor1,dist); 
    end
    if ~isempty(s.sensor2) 
        s.sensor2 = shift(s.sensor2,dist); 
    end

end