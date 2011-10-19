function clusters = computeSensorCluster(sensorData,numChannels,varInd)
% Recursively creates a clustering of sensors in pairs according to their
% similarity scores (as calculated by clusterSimilarityEuc.m); see "Cluster 
% analysis and display of genome-wide expression patterns," Eisen et al.
% for information on the algorithm and examples of its visualization. Uses
% average linkage clustering rather than centroid linkage clustering to
% avoid problems of badly-formed dendrograms.
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

% Pair up sensors/clusters according to the average of the similarity 
% coefficients computed by taking one sub-sensor (lowest level) from each
% cluster (average linking method).
nextPairInd = numChannels+1;
nextXPos = 0;
totalLength = 1;
sensorDist = totalLength/(numChannels-1);

% Compute similarity matrix
simMatrix = clusterSimilarityEuc(data);
while length(clusters) > 1
    % Go through each pair of clusters and compute their similarity score
    % by averaging the similarity scores of each pair of lowest level
    % sensors (one taken from each cluster)
    maxSimilarity = -Inf;
    s1MatInd = 0;
    s2MatInd = 0;
    for s1Ind = 1:length(clusters)-1
        sensorList1 = getSubSensors(clusters{s1Ind});
        for s2Ind = s1Ind+1:length(clusters)
            sensorList2 = getSubSensors(clusters{s2Ind});
            similarity = 0;
            for subInd1=1:length(sensorList1)
                for subInd2=1:length(sensorList2)
                    similarity = similarity+simMatrix(sensorList1(subInd1),sensorList2(subInd2));
                end
            end
            similarity = similarity/(length(sensorList1)*length(sensorList2));
            if similarity > maxSimilarity
                maxSimilarity = similarity;
                s1MatInd = s1Ind;
                s2MatInd = s2Ind;
            end
        end
    end
    
    % Create a pair linking the two (with index equal to the next integer
    % not currently being used as an index), using the average data 
    % weighted by the number of sensors in each of the two. Note that this
    % average data is not used in the average linking method.
    s1TempInd = s1MatInd;
    s1MatInd = min(s1MatInd,s2MatInd);
    s2MatInd = max(s1TempInd,s2MatInd);
    s1 = clusters{s1MatInd};
    s2 = clusters{s2MatInd};
    pairData = (get(s1,'Data')*get(s1,'NumSensors')+get(s2,'Data')*get(s2,'NumSensors'))...
        /(get(s1,'NumSensors')+get(s2,'NumSensors'));
    
    % At each step, put left half of new cluster at nextXPos 
    % if position not set and trade position in list of clusters with the 
    % position of the first unplaced sensor (at index nextPairInd-numChannels) 
    % (otherwise keep stationary) and right half at position after (if not set, put at
    % sensorDist after rightmost of left half, otherwise move entire
    % cluster by position of leftmost of right half minus rightmost of left
    % half plus sensorDist), then shift all clusters between left half and
    % right half to the right by sensorDist times the number of sensors in
    % the right half (unless position not yet set) and change the indices
    % of the list of clusters to reflect this
    s1SetPos = length(get(s1,'Pos')) > 1;
    s2SetPos = length(get(s2,'Pos')) > 1;  
    
    % Set s1 position if need be, and reorder the clusters variable
    % accordingly
    if ~s1SetPos
        s1 = set(s1,'Pos',[nextXPos; 0]);
        % If s1 is to the right (in the clusters variable) of a sensor w/ 
        % unset position then switch the two (so that an unset cluster will 
        % never precede a set one).
        if s1MatInd > nextPairInd - numChannels 
            clusters{s1MatInd} = clusters{nextPairInd-numChannels};
            clusters{nextPairInd-numChannels} = s1;
            tempData = data(s1MatInd);
            data(s1MatInd) = data(nextPairInd-numChannels);
            data(nextPairInd-numChannels) = tempData;
            s1MatInd = nextPairInd-numChannels;
        else
            clusters{s1MatInd} = s1;
        end
        nextXPos = nextXPos + sensorDist;
    end

    % Set s2 position and reorder the clusters variable accordingly
    posLists1 = getPosList(s1,[]);
    posAfters1 = max(posLists1(1,:)) + sensorDist;
    if ~s2SetPos
        s2 = set(s2,'Pos',[posAfters1; 0]);
        clusters{s2MatInd} = s2;
        nextXPos = nextXPos + sensorDist;
    else
        posLists2 = getPosList(s2,[]);
        posMins2 = min(posLists2(1,:));
        s2 = shift(s2,[-(posMins2-posAfters1); 0]);
        clusters{s2MatInd} = s2;
    end
    if s2MatInd-s1MatInd > 1 % Shift intermediate sensors in matrix
        temp = cell(1,s2MatInd-s1MatInd-1);
        tempData = data(s1MatInd+1:s2MatInd-1);
        data(s1MatInd+1) = data(s2MatInd);
        data(s1MatInd+2:s2MatInd) = tempData;
        for matInd=s1MatInd+1:s2MatInd-1
            temp{matInd-s1MatInd} = clusters{matInd};
        end
        clusters{s1MatInd+1} = clusters{s2MatInd};
        posShift = get(s2,'NumSensors')*sensorDist;
        for matInd=1:length(temp)
            temp{matInd} = shift(temp{matInd},[posShift; 0]);
        end
        for matInd=s1MatInd+2:s2MatInd
            clusters{matInd} = temp{matInd-s1MatInd-1};
        end
        s2MatInd = s1MatInd+1;
    end
    minInd = s1MatInd;

    % Assign each pair a position, if not already assigned, and give the 
    % new pair a position halfway between the two in x, with a y position 
    % that scales with the difference score (1-simCoeff).
    pairPos = [mean([get(s1,'XPos') get(s2,'XPos')]); 1-maxSimilarity];
    pair = sensorPair(nextPairInd,pairData,clusters{s1MatInd},clusters{s2MatInd},maxSimilarity,pairPos);
    
    % Update clusters and data to incorporate the new pair, while removing
    % the individual sensors/clusters that make up the pair

    oldClusters = clusters;
    clusters = cell(1,length(oldClusters)-1);
    clusters{minInd} = pair;
    oldData = data;
    data = zeros(numDataPoints,length(oldClusters)-1);
    data(:,minInd) = pairData;

    for oldClusterInd = 1:length(oldClusters)
        if (oldClusterInd == s1MatInd) || (oldClusterInd == s2MatInd) 
            continue;
        end

        if oldClusterInd > s2MatInd
            clusterInd = oldClusterInd - 1;
        else
            clusterInd = oldClusterInd;
        end
        clusters{clusterInd} = oldClusters{oldClusterInd};
        data(:,clusterInd) = oldData(:,oldClusterInd);
    end
    
    nextPairInd = nextPairInd+1;
    
end

% Turn the array of clusters (now with only one element) into a single
% sensorPair containing as subpairs all the other sensors/clusters
clusters = clusters{1};

end