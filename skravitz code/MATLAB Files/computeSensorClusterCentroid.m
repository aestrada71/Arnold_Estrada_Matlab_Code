function clusters = computeSensorClusterCentroid(sensorData,numChannels,varInd)
% Recursively creates a clustering of sensors in pairs according to their
% similarity scores (as calculated by clusterSimilarity.m); see "Cluster 
% analysis and display of genome-wide expression patterns," Eisen et al.
% for information on the algorithm and examples of its visualization. Uses
% the centroid linkage method, as discussed in the paper (called the
% average linkage method there), which can lead to badly-formed
% dendrograms.
% Inputs
%   sensorData      A matrix of data from several sensors measuring one or
%                   multiple variables, in the format output by findPeaks.m
%                   or findPeaks2.m (i.e. columns correspond to sensors and
%                   variables, while rows correspond to data points)
%   numChannels     The number of channels (sensors) to be compared
%   varInd          The index of the variable to be used for the purposes
%                   of comparing sensors

% Collect only the data for the relevant variable
dataStartCol = (varInd-1)*numChannels + 1;
data = sensorData(:,dataStartCol:(dataStartCol+numChannels-1));
numDataPoints = size(data,1);

% Initialize clusters to an empty array of sensorPair objects
clusters = cell(1,numChannels);
for chInd = 1:numChannels
    clusters{chInd} = sensorPair(chInd,data(:,chInd));
end

% Pair up sensors/clusters with the highest similarity coefficient
% recursively, recalculating the similarity matrix using the average data
% for each pair at each step, until only a single cluster (containing all
% subpairs) remains
nextPairInd = numChannels+1;
nextXPos = 0;
totalLength = 1;
sensorDist = totalLength/(numChannels-1);
while length(clusters) > 1
    % Compute the similarity matrix
    simMatrix = clusterSimilarity(data);
    
    % Find the pair of sensors/clusters with the highest similarity
    % coefficient
    maxSimilarity = max(max(simMatrix));
    maxSimIndices = find(simMatrix == maxSimilarity);
    [s1MatInd s2MatInd] = ind2sub(size(simMatrix),maxSimIndices(2));
    
    % Create a pair linking the two (with index equal to the next integer
    % not currently being used as an index), using the average data 
    % weighted by the number of sensors in each of the two. Assign
    % each a position, if not already assigned, and give the new pair a
    % position halfway between the two in x, with a y position that scales
    % with the difference score (1-simCoeff).
    s1 = clusters{s1MatInd};
    s2 = clusters{s2MatInd};
    pairData = (get(s1,'Data')*get(s1,'NumSensors')+get(s2,'Data')*get(s2,'NumSensors'))...
        /(get(s1,'NumSensors')+get(s2,'NumSensors'));
    if length(get(s1,'Pos')) < 2
        s1 = set(s1,'Pos',[nextXPos; 0]);
        clusters{s1MatInd} = s1;
        nextXPos = nextXPos + sensorDist;
    end
    if length(get(s2,'Pos')) < 2
        s2 = set(s2,'Pos',[nextXPos; 0]);
        clusters{s2MatInd} = s2;
        nextXPos = nextXPos + sensorDist;
    end
    pairPos = [mean([get(s1,'XPos') get(s2,'XPos')]); 1-maxSimilarity];
    pair = sensorPair(nextPairInd,pairData,clusters{s1MatInd},clusters{s2MatInd},maxSimilarity,pairPos);
    
    % Update clusters and data to incorporate the new pair, while removing
    % the individual sensors/clusters that make up the pair
    oldClusters = clusters;
    clusters = cell(1,length(oldClusters)-1);
    clusters{1} = pair;
    oldData = data;
    data = zeros(numDataPoints,length(oldClusters)-1);
    data(:,1) = pairData;
    clusterInd = 2;
    for oldClusterInd = 1:length(oldClusters)
        if (oldClusterInd == s1MatInd) || (oldClusterInd == s2MatInd)
            continue;
        end
        
        clusters{clusterInd} = oldClusters{oldClusterInd};
        data(:,clusterInd) = oldData(:,oldClusterInd);
        clusterInd = clusterInd + 1;
    end
    
    nextPairInd = nextPairInd+1;
end

% Turn the array of clusters (now with only one element) into a single
% sensorPair containing as subpairs all the other sensors/clusters
clusters = clusters{1};

end