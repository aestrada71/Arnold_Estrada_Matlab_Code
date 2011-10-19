function [MOutIn1 MOutIn1Norm] = mutualInfo(peakData)
% Computes the mutual information and normalized mutual information between
% each type of input gas and each channel/variable combination (column of
% peakData). This can then be used to determine rules for picking out which
% gasses are present according to the sensor response profile. For example,
% if MOutIn1Norm(i,j)=1, then the presence the ith gas can be determined
% solely by examining the jth variable response. Note that for this to be
% accurate, the output intervals must be chosen appropriately (big enough
% to differentiate between samples, but not small enough that every sample
% falls into a different range). The number of data points must also be
% large, since the rules are determined statistically (e.g. a rule that
% seems to be valid for four data points may end up being just coincidence
% when examined over a larger data set).
% Inputs
%   peakData    Peak data in the format output by findPeaks.m or
%               findPeaks2.m
% Outputs
%   MOutIn1     A matrix which gives the mutual information between gas i
%               and variable j at index (i,j).
%   MOutIn1Norm MOutIn1 normalized to the total amount of information
%               available; a value of 1 implies that all information
%               contained in the presence of the gas is available to the
%               variable/channel.


peakSize = size(peakData);
numPeaks = peakSize(1);
numVars = peakSize(2);
numInts = 9;

% outputIntervals = [3 3 3 4 0.1 0.3 0.5 0.3 -0.3 -0.7 -1.1 -0.7 2 5 8 5;...
%      5 5 5 6 0.2 0.4 0.7 0.4 -0.2 -0.6 -0.9 -0.5 3 6 10 6;...
%      7 7 7 8 0.3 0.5 0.9 0.5 -0.1 -0.5 -0.7 -0.3 4 7 12 7;...
%      9 9 9 10 0.4 0.6 1.1 0.6 -0.0 -0.4 -0.5 -0.1 5 8 14 8];

outputIntervals = zeros(numInts-1,numVars); % Number of demarcating points is numInts-1

% Center the demarcating points for each variable at the mean, with the
% lowest at two sigma below the mean, and the highest at two sigma above it
for varInd=1:numVars
    varMean = mean(peakData(:,varInd));
    varStdDev = std(peakData(:,varInd));
    outputIntervals(:,varInd) = (varMean-2*varStdDev):4*varStdDev/(numInts-2):(varMean+2*varStdDev);
end
 
pOut = zeros(numInts,numVars);
 
for varInd=1:numVars
   for peakInd=1:numPeaks
       output = peakData(peakInd,varInd);
       index = getProbInd(output,outputIntervals(:,varInd));
       pOut(index,varInd) = pOut(index,varInd) + 1/numPeaks;
   end
end
 
HOut = zeros(1,numVars);
for varInd=1:numVars
    pNon0 = nonzeros(pOut(:,varInd));
    HOut(varInd) = HOut(varInd) - sum(pNon0.*log2(pNon0));
end

% Says that the first and fifth sample contain the first gas, the second
% and sixth contain the second gas, etc.; uses only binary data and assumes
% four different gasses, according to the data in SampleData.xls
inputs = [1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1; 1 0 0 0; 0 1 0 0; 0 0 1 0; 0 0 0 1];
inputIntervals = [0.5 0.5 0.5 0.5];
numInputs = 4;
pIn = zeros(2,numInputs);
for inputInd=1:numInputs
    for peakInd=1:numPeaks
       index = getProbInd(inputs(peakInd,inputInd),inputIntervals(inputInd));
       pIn(index,inputInd) = pIn(index,inputInd) + 1/numPeaks;
    end
end

HIn = zeros(1,numInputs);
for varInd=1:numInputs
    pNon0 = nonzeros(pIn(:,varInd));
    HIn(varInd) = - sum(pNon0.*log2(pNon0));
end
 
HOutIn1 = zeros(numInputs,numVars);
for outputInd=1:numVars
    for inputInd=1:numInputs
        pOutIn = zeros(2,numInts);
        for peakInd=1:numPeaks
            probInd1 = getProbInd(inputs(peakInd,inputInd),inputIntervals(inputInd));
            probInd2 = getProbInd(peakData(peakInd,outputInd),outputIntervals(:,outputInd));
            pOutIn(probInd1,probInd2) = pOutIn(probInd1,probInd2) + 1/numPeaks;
        end
        pOutInNon0 = nonzeros(pOutIn);
        HOutIn1(inputInd,outputInd) = - sum(pOutInNon0.*log2(pOutInNon0));
    end
end
 
MOutIn1 = zeros(numInputs,numVars);
MOutIn1Norm = zeros(numInputs,numVars);
for outputInd=1:numVars
    for inputInd=1:numInputs
        MOutIn1(inputInd,outputInd) = HOut(outputInd) + HIn(inputInd) - HOutIn1(inputInd,outputInd);
        MOutIn1Norm(inputInd,outputInd) = MOutIn1(inputInd,outputInd)/HIn(inputInd);
    end
end

%  numPairs = factorial(numVars)/(factorial(2)*factorial(numVars-2));
%  HOutIn2 = zeros(numInputs,numPairs);
%  for outputInd=1:numPairs
%      for inputInd=1:numInputs
%          pOutIn2 = zeros(2,numInts);
%          for peakInd=1:numPeaks
%              probInd1 = getProbInd(inputs(peakInd,inputInd),inputIntervals(inputInd));
%              probInd2 = getProbInd(peakData(peakInd,outputInd),outputIntervals(:,outputInd));
%              pOutIn(probInd1,probInd2) = pOutIn(probInd1,probInd2) + 1/numPeaks;
%          end
%          pOutInNon0 = nonzeros(pOutIn);
%          HOutIn1(inputInd,outputInd) = - sum(pOutInNon0.*log2(pOutInNon0));
%      end
%  end