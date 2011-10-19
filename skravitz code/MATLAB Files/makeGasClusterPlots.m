function makeGasClusterPlots(sensorData,numChannels)
% Draws a gas cluster diagram in the format of "Cluster analysis and display of 
% genome-wide expression patterns," Eisen et al. (but clustering types of 
% gasses rather than sensors) for each variable from a set of sensor data.
% Inputs
%   sensorData      A matrix of data from several sensors measuring one or
%                   multiple variables, in the format output by findPeaks.m
%                   or findPeaks2.m (i.e. columns correspond to sensors and
%                   variables, while rows correspond to gasses)
%   numChannels     The number of channels (sensors) to be compared

% Figure out how many variables are being measured
dataSize = size(sensorData);
numVars = round(dataSize(2)/numChannels);
numGasses = dataSize(1);

% Format data appropriately
gasData = zeros(numChannels,dataSize(1)*numVars);
for varInd = 1:numVars
    gasData(:,(varInd-1)*numGasses+1:varInd*numGasses) = sensorData(:,(varInd-1)*numChannels+1:varInd*numChannels)';
end

% Draw a cluster diagram for each variable
for varInd = 1:numVars
    % Collect cluster data
    clusters = computeSensorCluster(gasData,numGasses,varInd);
    
    % Draw the cluster diagram for this variable
    figure(varInd);
    clf;
    drawTree(clusters,varInd);
end


end