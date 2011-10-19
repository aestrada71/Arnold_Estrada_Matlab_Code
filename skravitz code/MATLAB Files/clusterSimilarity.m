function similarityMatrix = clusterSimilarity(data)
% Computes the similarity of pairs of channels as a matrix, using only data
% from a single variable/measure. The expression for the similarity
% coefficient is found in "Cluster analysis and display of genome-wide
% expression patterns," Eisen et al. and is the standard correlation
% coefficient.
% Inputs
%   data                A matrix which contains data for each channel and
%                       peak, with rows corresponding to peaks and columns
%                       corresponding to channels
% Outputs
%   similarityMatrix    A symmetric matrix with entry i,j corresponding to
%                       the similarity coefficient of the i,j pair of
%                       channels (and diagonal entries equal to 0)

dataSize = size(data);
numDataPoints = dataSize(1);
numChannels = dataSize(2);

% Initialize the similarity matrix
similarityMatrix = zeros(numChannels);

% For each pair of channels, compute the similarity coefficient, using the
% mean and standard deviation of each channel of data
for xChInd=1:numChannels-1
    stdX = std(data(:,xChInd),1);
    meanX = mean(data(:,xChInd));
    for yChInd=xChInd+1:numChannels
        stdY = std(data(:,yChInd),1);
        meanY = mean(data(:,yChInd));
        
        simXY = sum((data(:,xChInd)-meanX).*(data(:,yChInd)-meanY))/((numDataPoints)*stdX*stdY);
        similarityMatrix(xChInd,yChInd) = simXY;
        similarityMatrix(yChInd,xChInd) = simXY;
    end
end
end