function rowComparisonMat = vectorCompare(peaks, numChannels, numVars)
% Computes the similarity matrix between samples (peaks) using a dot
% product method, as in "A robust and low-complexity gas recognition
% technique for on-chip tin-oxide gas sensor array", Flitti et al. Because
% multiple variables are available, the matrix is simply the sum of that
% computed using each independent variable; in the future, a weighted sum
% may be a better solution.
% Inputs
%   peaks            Peak data in the format output by findPeaks.m or
%                    findPeaks2.m
%   numChannels      The number of sensor channels present in the data
%   numVars          The number of variables measured
% Outputs
%   rowComparisonMat The similarity matrix for each pair of rows. The
%                    similarity score of rows i and j is
%                    rowComparisonMat(i,j).

numPeaks = size(peaks,1);
rowComparisonMat = zeros(numPeaks);
for varInd = 1:numVars
    data = peaks(:,1+(varInd-1)*numChannels:varInd*numChannels);
    dataSize = size(data);
    numRows = dataSize(1);
    % Normalize each row (peak) of data
    for rowInd=1:numRows
        data(rowInd,:) = data(rowInd,:)/norm(data(rowInd,:));   
    end

    % Compute matrix which contains the similarity scores of each pair of
    % rows using a dot product method
    rowComparison = zeros(numRows);
    for rowInd=1:numRows-1
        for otherRowInd=rowInd+1:numRows
            dist = dot(data(rowInd,:),data(otherRowInd,:));
            rowComparison(rowInd,otherRowInd) = 1-dist;
            rowComparison(otherRowInd,rowInd) = 1-dist;
        end
    end
    rowComparisonMat = rowComparisonMat + rowComparison;
end