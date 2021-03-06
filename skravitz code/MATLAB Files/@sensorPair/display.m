function display(s)
% Function to display the sensorPair data; if a single node, display only
% the index. Otherwise, display the indices of each sub-sensorPair as well
% as their similarity coefficient.
if isa(s.sensor1,'sensorPair') && isa(s.sensor2,'sensorPair')
    text = sprintf('Sensor 1 Index: %i\nSensor 2 Index: %i\nSimilarity: %g',...
        s.sensor1.index,s.sensor2.index,s.simCoeff);
    disp(text)
    
else
    text = sprintf('Index: %i',s.index);
    disp(text)
end

end