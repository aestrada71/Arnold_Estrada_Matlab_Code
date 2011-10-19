function similarityMatrix = clusterSimilarityEuc(data)
% Computes the similarity of pairs of channels as a matrix, using only data
% from a single variable/measure. The similarity coefficient is calculated
% using the Euclidean distance between points (with different variables
% normalized to have zero mean and a standard deviation of 1).
% Inputs
%   data                A matrix which contains data for each channel and
%                       peak, with rows corresponding to peaks and columns
%                       corresponding to channels
% Outputs
%   similarityMatrix    A symmetric matrix with entry i,j corresponding to
%                       the similarity coefficient of the i,j pair of
%                       channels (and diagonal entries equal to 0)

dataSize = size(data);
numChannels = dataSize(2);

% Initialize the similarity matrix
similarityMatrix = zeros(numChannels);

% Normalize the data from each column to have zero mean and unit std
data = normalizeData2(data);

% For each pair of channels, compute the similarity coefficient, using the
% Euclidean distance between points
for xChInd=1:numChannels-1
    for yChInd=xChInd+1:numChannels
        simXY = 1-sqrt(sum((data(:,xChInd)-data(:,yChInd)).^2));
        similarityMatrix(xChInd,yChInd) = simXY;
        similarityMatrix(yChInd,xChInd) = simXY;
    end
end
end