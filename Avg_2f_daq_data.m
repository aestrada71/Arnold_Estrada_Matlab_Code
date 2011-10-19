%% Avg_2f_daq_data.m
% Takes the raw daq data and averages it down to 50 cycles and writes the
% results to a file.  The file is meant to mimic the .asc files we get from the
% tcspc board.  the script file used to process freq domain data from tcspc board
% can then be called to pick out the 1F component and
% 2F component and analyze the phase shift vs modulation frequency.

function avg_2f_daq_data()




%% Define needed parameters.

numCyclesToAvg = 50;        %to match what processing script wants to see
suffix2 = '.asc';           %suffix of output file name
suffix1 = '.dat';           %suffix of input file name
trigCol = 2;                %Column number of data where function generator trigger is.
dataCol = 1;
diagnostics = 1;

[str,maxsize,endian] = computer;

%% Read raw files, avearage and write out.
if ispc
    fpath = uigetdir('c:\Data');
else
    fpath = uigetdir('/Volumes/RUGGED/Data/');
end

fpath2 = fpath;

if ispc
    fpath = strcat(fpath,'\*.dat');
else
    fpath = strcat(fpath,'/*.dat');
end
tempStruct = dir(fpath);
fpath = fpath2;

numFiles = size(tempStruct,1);


%process data files sequentially
for i = 1:numFiles
    
    tempName = fullfile(fpath,tempStruct(i).name);

   
    [data, t] = daqread(tempName);
    dt = t(2);
    f_samp = 1/dt;
    

    
    %Find cycle ref points.
    startIndices = find(diff(data(:,trigCol)) > 2.505);
    sampsPerCycle = diff(startIndices);
    meanSampsPerCycle = mean(sampsPerCycle);
    freq = round(1/(meanSampsPerCycle * dt));
    
    if diagnostics
        ss=sprintf('%s',tempName)
        dt
        plot(sampsPerCycle);
        pause(0.1);
    end
    
    %there are sometimes outliers in the list of samps per cycle.  Clean
    %this up by replacing outliers with meanSampsPerCycle
    badIndices = find((sampsPerCycle > 1.4*meanSampsPerCycle) |(sampsPerCycle < 0.6*meanSampsPerCycle));
    sampsPerCycle(badIndices) = meanSampsPerCycle;
    
    if diagnostics
        plot(sampsPerCycle);
        pause(0.1);
    end
   

    %Find proper starting point and average every numCyclesToAvg cycles
    numSampsInChunk = round(meanSampsPerCycle*numCyclesToAvg);
    numChunksToAvg = floor(numel(startIndices)/numCyclesToAvg);
    chunkStartIndices = startIndices(1:numCyclesToAvg:numChunksToAvg*numCyclesToAvg);
    
     
    avg = zeros(numSampsInChunk,1);
    
    for ii = 1:numChunksToAvg
        ind = chunkStartIndices(ii):numSampsInChunk+chunkStartIndices(ii)-1;
        avg = avg + data(ind,dataCol)/numChunksToAvg; 
        
%         if diagnostics
%             plot(avg);
%             pause(0.1);
%         end
       
    end
   % avg = avg / numChunksToAvg;
    

    
    outputFileName = regexprep(tempName,suffix1,suffix2);
    dlmwrite(outputFileName,avg);
     
    
end