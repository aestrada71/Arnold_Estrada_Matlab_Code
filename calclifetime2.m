%this script file differs from calclifetime.m in that I have implemented
%the ability to specify the delay and duration to fit.  Before averaging
%the data it throws out outlier data by averaging a small "window" of
%triggers and attempts a fit.  If the r value of the fit is below a
%threshold, it neglects the data from that window in calculating the final
%average vector which will be used for the fit.

clear all

showPlots = 0;
delay = 60e-6;              %seconds
duration = 1000e-6;          %seconds
windowSize = 10;            %number of triggs to average.
r_thresh = 0.7;

[data, hdr] = read_lifetime();


numAvgs = fix(hdr.numTrigs / windowSize);
delaySamps = fix(delay * hdr.sampRate);
durationSamps = fix(duration * hdr.sampRate);


keepIndices = [];

for i=1:numAvgs
    indices = (i-1) * windowSize * hdr.sampsPerTrig + 1:i * windowSize * hdr.sampsPerTrig;
    avgData = mean(reshape(data(indices),hdr.sampsPerTrig, windowSize),2);
    
    %Chop off data before delay time and after duration time.
    avgData = avgData((delaySamps + 1) : (durationSamps));
    
    %avgdData_Array(i,:) = avgData;
    a = mean(avgData(numel(avgData)-50:numel(avgData)));
    b = max(avgData)-a;

    time = ((0:numel(avgData)-1) * 1/hdr.sampRate)';
    f_results = fit(time,avgData, 'a + (b * exp(-x/tau))',[a, b, 100e-6]);
    
    %tau_Array(i) = f_results.m(3);
    %magnitude_Array(i) = f_results.m(2);
    %f_results_Array(i) = f_results;
    
    if (showPlots)
        figure(4);
        rmfit;
        plot(time,avgData);
        showfit(f_results);
        pause(0.1);
    end
    
    if (f_results.r > r_thresh)
        keepIndices = [keepIndices indices];
    end
    
    
end

numKeepTrigs = numel(keepIndices)/hdr.sampsPerTrig;
avgData = mean(reshape(data(keepIndices),hdr.sampsPerTrig, numKeepTrigs),2);

%Chop off data before delay time and after duration time.
avgData = avgData((delaySamps + 1) : (durationSamps));

a = mean(avgData(numel(avgData)-50:numel(avgData)));
b = max(avgData)-a;

time = ((0:numel(avgData)-1) * 1/hdr.sampRate)';
f_results = fit(time,avgData, 'a + (b * exp(-x/tau))',[a, b, 100e-6]);




figure(4);
plot(time,avgData);
showfit(f_results);


clear a;
clear b;
clear avgData;
%clear delay;
clear delaySamps;
clear duration;
clear durationSamps;
%clear f_results;
clear i
clear indices;
clear lastfit;
clear showPlots
clear numAvgs;
clear windowSize;
clear r_thresh;
clear delay;
