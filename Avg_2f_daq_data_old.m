%% Avg_2f_daq_data.m
% Takes the 30 secs of data and averaages it down to 1 sec and writes the
% results to a file.  process2f_2.m should then be called to pick out the 
% 2F component and analyze the phase shift vs modulation frequency.



%% Define needed parameters.

clear

%% Define relavent parameters
freqs = [50 70 100,200,300,400,500,600,700,800,900,1000]';
%freqs = [700];
t_avg_max = 1;


%% Read files, avearage and write out.
%dir = '/Volumes/RUGGED/Data/2008_07_13/';
dir = 'c:/Data/2008_09_11/';
baseName = 'Fluor_';
%baseName = 'Fluor_';
suffix = '.dat';
suffix2 = '.txt';

for i = 1:numel(freqs)
    temp = sprintf('%ihz',freqs(i));
    fileName = [dir, baseName, temp, suffix];

   
    [data, t] = daqread(fileName);
    dt = t(2);
    f_samp = 1/dt;
    
    %Find modulation signal reference point.
    numSampsPerCycle = (1/(freqs(i) * dt));
    totNumCycles = floor(numel(t) / numSampsPerCycle);
    
    
    %Find first sample with trigger edge.  This is cycle ref point.
    edgeIndex = find(diff(data(:,1)) > 1.5);
    edgeIndex = int32(edgeIndex(1:freqs(i):numel(edgeIndex)));

    
    avg = zeros(int32(f_samp),1);
    for ii = 1:29
    %   ind = ((ii-1)*int32(f_samp) + 1 + edgeIndex(ii)): (ii*int32(f_samp) + edgeIndex(ii));
        ind = edgeIndex(ii):edgeIndex(ii)+f_samp-1;
        avg =  avg + data(ind',2);


       plot(data(ind(1):ind(1)+5*numSampsPerCycle,2));
       tempString = sprintf(' :second %i data',ii);
       titleString = [fileName, tempString];
       title(titleString);
       pause(0.1);
    end
    avg = avg / 29;
    
    plot(avg(1:5*numSampsPerCycle))
    titleString = [fileName, ': Avg of 30 sec'];
    title(titleString);
    
    pause(0.1);
    
    outputFileName = [dir, baseName, temp, suffix2]
    dlmwrite(outputFileName, [t(1:int32(f_samp)) avg]);
    
    
end