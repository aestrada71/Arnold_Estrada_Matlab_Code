function sampleData = compareSamples(peaks)
% Takes peak data, in the form output by findPeaks.m, and finds for each 
% sample (peak) the index of the other sample with the most similar 
% response.
% Inputs
%   peaks   A matrix which contains the peak data for each channel and
%           peak, with rows corresponding to peaks and columns
%           corresponding to channels/types of data, in the form Ch1Peak,
%           Ch2Peak, ..., Ch1MaxDeriv, Ch2MaxDeriv, ..., Ch1MinDeriv, 
%           Ch2MaxDeriv, ...
% Outputs
%   sampleData  A matrix which contains the index of the sample with the 
%               most similar response to each sample (row)

dataSize = size(peaks);
numPeaks = dataSize(1);
numCols = dataSize(2);
sampleData = zeros(numPeaks,1);

for thisPeakInd=1:numPeaks
   minDiff = Inf;
   closestPeak = 0;
   for otherPeakInd=1:numPeaks
     if otherPeakInd == thisPeakInd
         continue; 
     end
     diff = 0;    
     for colInd=1:numCols
         
         diff = diff + ((peaks(thisPeakInd,colInd) - peaks(otherPeakInd,colInd))...
             /peaks(thisPeakInd,colInd))^2;
     end
     if diff < minDiff
        closestPeak = otherPeakInd; 
        minDiff = diff;
     end
   end
   sampleData(thisPeakInd) = closestPeak;
end
