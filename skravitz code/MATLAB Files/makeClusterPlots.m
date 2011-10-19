function makeClusterPlots(sensorData,numChannels)
% Draws a cluster diagram in the format of "Cluster analysis and display of 
% genome-wide expression patterns," Eisen et al. for each variable from a
% set of sensor data.
% Inputs
%   sensorData      A matrix of data from several sensors measuring one or
%                   multiple variables, in the format output by findPeaks.m
%                   or findPeaks2.m (i.e. columns correspond to sensors and
%                   variables, while rows correspond to data points)
%   numChannels     The number of channels (sensors) to be compared

% Figure out how many variables are being measured
dataSize = size(sensorData);
numVars = round(dataSize(2)/numChannels);

% Draw a cluster diagram for each variable
for varInd = 1:numVars
    % Collect cluster data
    clusters = computeSensorCluster(sensorData,numChannels,varInd);
    
    % Draw the cluster diagram for this variable
    figure(varInd);
    clf;
    drawTree(clusters,varInd);
end


end