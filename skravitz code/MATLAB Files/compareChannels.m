function chData = compareChannels(peaks)
% Takes peak data, in the form output by findPeaks.m, and finds for each 
% channel the channel with the most similar response using a non-normalized
% Euclidean distance measure. Assumes peak data has three variables (peak,
% max derivative and min derivative).
% Inputs
%   peaks   A matrix which contains the peak data for each channel and
%           peak, with rows corresponding to peaks and columns
%           corresponding to channels/types of data, in the form Ch1Peak,
%           Ch2Peak, ..., Ch1MaxDeriv, Ch2MaxDeriv, ..., Ch1MinDeriv, 
%           Ch2MaxDeriv, ...
% Outputs
%   chData  A matrix which contains the number of the channel with the most
%           similar response to each channel (column), for each peak (row)

dataSize = size(peaks);
numPeaks = dataSize(1);
numChannels = round(dataSize(2)/3);
chData = zeros(numPeaks,numChannels);

% Go through each peak and each channel, recording index of the closest
% channel to the one being considered for this peak
for peakInd=1:numPeaks
   for thisChInd=1:numChannels
       minDiff = Inf;
       closestCh = 0;
       for otherChInd=1:numChannels
         if otherChInd == thisChInd
             continue; 
         end
         % Calculate the Euclidean distance between the pairs of channels
         peakDiff = (peaks(peakInd,thisChInd) - peaks(peakInd,otherChInd))/peaks(peakInd,thisChInd);
         maxDerivDiff = (peaks(peakInd,numChannels+thisChInd) - ...
             peaks(peakInd,numChannels+otherChInd))/peaks(peakInd,numChannels+thisChInd);
         minDerivDiff = (peaks(peakInd,2*numChannels+thisChInd) - ...
             peaks(peakInd,2*numChannels+otherChInd))/peaks(peakInd,2*numChannels+thisChInd);
         totDiff = sqrt(peakDiff^2 + maxDerivDiff^2 + minDerivDiff^2);
         % If the current difference is less than the previous smallest
         % difference, record the other channel's index
         if totDiff < minDiff
            closestCh = otherChInd; 
            minDiff = totDiff;
         end
       end
       chData(peakInd,thisChInd) = closestCh;
   end
end
