function [rowComparison peaks] = compareSamplesDot(X)
% Computes a matrix which compares pairs of samples (represented as rows of
% X) by multiplying the (normalized) signals in the vicinity of their peaks
% pointwise at each time (and for each channel) and adding up the results.
% A result of 1 means the signals are identical, a result of 0 means they
% are something like "uncorrelated", and a result of -1 means that one is
% the exact negative of the other.
% Inputs
%   X   The data matrix, with each row representing data taken at a given
%       time and all but the last two columns representing different
%       channels of data. The second to last column has the time of each
%       data point and the last column has flags which indicate where the
%       peaks are.
% Outputs
%   rowComp A matrix which contains the comparison data for each pair of
%           samples (rows in X), so that rowComp(i,j) = rowComp(j,i) = the
%           comparison value of row i with row j.

dataSize = size(X);
numPoints = dataSize(1);
numChannels = dataSize(2) - 2;
peaks = zeros(numPoints,numChannels,1); % To be filled with data for each peak; 

totAreas2 = zeros(1,numChannels);
baselines = zeros(1,numChannels);
lengths = zeros(1,numChannels);

peakHalfWidth = 30;
peakPts = round(peakHalfWidth/8);
fracPeakStart = 1/4;

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
        
        % Go through the data near the peak and find where the peak starts
        % and ends, then calculate the ratio of peak value to baseline and 
        % total peak area over the baseline for each channel
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
            
            peakEndInd = 0;
            % If the derivative at a given time is less than
            % fracPeakStart times the min, and continues to be less for
            % peakPts data points, we say that this is where the peak ends
            for rowInd = (endInd+1-startInd):-1:peakPts
                if Derivs(rowInd:-1:rowInd-peakPts+1,colInd) < minDerivs(colInd)*fracPeakStart*ones(peakPts,1)
                   peakEndInd = rowInd;
                   break;
                end
            end

            % Record the length of each peak
            lengths(peakNum,colInd) = peakEndInd-peakStartInd;

            % Calculate the baseline average of all the points before the
            % start of the peak
            baseline = mean(Xpeak(1:peakStartInd,colInd));
            baselines(peakNum,colInd) = baseline;
            
            % Calculate the total area of the peak above the baseline,
            % using the trapezoidal rule 
            timeIncs = Xtime(peakStartInd+1:peakEndInd) - Xtime(peakStartInd:peakEndInd-1);
            peakAreas = (0.5*(Xpeak(peakStartInd+1:peakEndInd,colInd)+Xpeak(peakStartInd:peakEndInd-1,colInd))...
                - baseline).*timeIncs;
            
            totAreas2(peakNum,colInd) = sum(peakAreas.^2);
            
            % Record the peak area data for each channel
            peaks(1:(peakEndInd-peakStartInd),colInd,peakNum) = peakAreas;
        end
        
        peakNum = peakNum+1;
    end
end

numPeaks = peakNum-1;
rowComparison = eye(numPeaks);

% Go through each pair of peaks and compare across channel responses
for thisPeakInd = 1:numPeaks-1
    for otherPeakInd = thisPeakInd+1:numPeaks
        overlap = 0;
        for chInd = 1:numChannels
            minLength = min(lengths(thisPeakInd,chInd),lengths(otherPeakInd,chInd));
            maxArea2 = max(totAreas2(thisPeakInd,chInd),totAreas2(otherPeakInd,chInd));
            overlap = overlap + sum(peaks(1:minLength,chInd,thisPeakInd).*peaks(1:minLength,chInd,otherPeakInd))/maxArea2;
        end
        rowComparison(thisPeakInd,otherPeakInd) = overlap/numChannels;
        rowComparison(otherPeakInd,thisPeakInd) = overlap/numChannels;
    end
end