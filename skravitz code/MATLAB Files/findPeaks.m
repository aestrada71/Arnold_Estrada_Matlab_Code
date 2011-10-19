function peaks = findPeaks(X)
% For each channel (column) and each peak, finds the ratio of the peak
% value to its baseline, the maximum derivative near the peak, and the
% minimum derivative near the peak.
% Inputs
%   X   The data matrix, with each row representing data taken at a given
%       time and all but the last two columns representing different
%       channels of data. The second to last column has the time of each
%       data point and the last column has flags which indicate where the
%       peaks are.
% Outputs
%   peaks   A matrix which contains the peak data for each channel and
%           peak, with rows corresponding to peaks and columns
%           corresponding to channels/types of data, in the form Ch1Peak,
%           Ch2Peak, ..., Ch1MaxDeriv, Ch2MaxDeriv, ..., Ch1MinDeriv, 
%           Ch2MaxDeriv, ...

dataSize = size(X);
numPoints = dataSize(1);
numChannels = dataSize(2) - 2;
peaks = zeros(1,3*numChannels);

peakHalfWidth = 30; % The number of data points before and after the peak 
% flag to look for the start and end of the peak
peakPts = round(peakHalfWidth/8);
fracPeakStart = 1/3;

% Go through each data point and look for a flag indicating a peak nearby,
% then use the surrounding data to calculate the relevant peak information
peakNum = 1;
for flagInd = 1:numPoints
    if X(flagInd,end) == 1
        startInd = max(flagInd-peakHalfWidth,1);
        endInd = min(flagInd+peakHalfWidth,numPoints);
        Xpeak = X(startInd:endInd,1:end-2); % Take just the sensor data near the peak
        Xtime = X(startInd:endInd,end-1); % Take just the time data near the peak
        
        % Calculate derivative data at each point (using a longer time
        % scale, i.e. 5 data points, to minimize the effects of random
        % noise)
        Derivs = zeros(size(Xpeak));
        for rowInd = 3:(endInd-startInd-1)
            Derivs(rowInd,:) = (Xpeak(rowInd+2,:) - Xpeak(rowInd-2,:))/(Xtime(rowInd+2) - Xtime(rowInd-2));
        end
        
        % Compute the max and min derivatives for each channel
        maxDerivs = max(Derivs);
        minDerivs = min(Derivs);
        
        % Go through the data near the peak and find where the peak starts,
        % then calculate the ratio of peak value to baseline for each
        % channel
        for colInd = 1:numChannels
            peakStartInd = 0;
            % If the derivative at a given time is greater than
            % fracPeakStart times the max, and continues to be greater for
            % peakPts data points, we say that this is where the peak
            % begins
            for rowInd = 1:(endInd+2-startInd-peakPts)
                if Derivs(rowInd:rowInd+peakPts-1,colInd) > maxDerivs(colInd)*fracPeakStart*ones(peakPts,1)
                   peakStartInd = rowInd;
                   break;
                end
            end

            % Calculate the baseline average of all the points before the
            % start of the peak
            baseline = mean(Xpeak(1:peakStartInd,colInd));
            peakValue = max(Xpeak(:,colInd));
            
            % Record the three points of peak data for each channel
            peaks(peakNum,colInd) = peakValue/baseline;
            peaks(peakNum,numChannels+colInd) = maxDerivs(colInd);
            peaks(peakNum,2*numChannels+colInd) = minDerivs(colInd);
        end
        
        peakNum = peakNum+1;
    end
end
