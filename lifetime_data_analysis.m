%This macro was written to investigate the variability that exists in our
%lifetime raw data.  The macro investigates how the variability is affected
%by different averaging window sizes.  The macro can be used to determine
%an appropriate number of triggers that will be needed to achieve reliable
%lifetime determination.  It can also be used to look for occurence of
%acquistion of data where an RBC is in the focal volume.
clear all

showPlots = 1;
delay = 60e-6;              %seconds
duration = 1000e-6;          %seconds
no_outliers = 0;              %Throw out data where preliminary fit is bad.
windowSize = 500;            %number of triggs to average.
r_thresh = 0.7;



%[data, hdr] = read_lifetime('/Users/ADE/Desktop/LifeTime_1_2007-08-09_16_50_28.dat');
%[data, hdr] = read_lifetime('/Users/ADE/Desktop/Porph_No_Scatter_700nm.dat');
[data, hdr] = read_lifetime('/Users/ADE/Desktop/LifeTime_2_2007-08-21_19_49_38.dat');

numAvgs = fix(hdr.numTrigs / windowSize);

time = ((0:(hdr.sampsPerTrig  -1)) * 1/(hdr.sampRate))';


delaySamps = fix(delay * hdr.sampRate);
durationSamps = fix(duration * hdr.sampRate);

goodCount=0;
badCount=0;
badData=[];
goodData=[];
badIndices = [];
for i=1:numAvgs
    indices = (i-1) * windowSize * hdr.sampsPerTrig + 1:i * windowSize * hdr.sampsPerTrig;
    avgData = mean(reshape(data(indices),hdr.sampsPerTrig, windowSize),2);
    
    %Chop off data before delay time and after duration time.
    avgData = avgData((delaySamps + 1) : (durationSamps));
    
    avgdData_Array(i,:) = avgData;
    a = mean(avgData(numel(avgData)-50:numel(avgData)));
    b = max(avgData)-a;

    time = ((0:numel(avgData)-1) * 1/hdr.sampRate)';
    f_results = fit(time,avgData, 'a + (b * exp(-x/tau))',[a, b, 100e-6]);
    
    tau_Array(i) = f_results.m(3);
    magnitude_Array(i) = f_results.m(2);
    f_results_Array(i) = f_results;
    
    if (showPlots)
        figure(4);
        rmfit;
        plot(time,avgData);
        showfit(f_results);
        pause(0.1);
    end

    if (no_outliers)
        if (f_results.r > r_thresh)
            goodCount = goodCount + windowSize;
            goodData=[goodData data(indices)];
        else
            badCount = badCount + windowSize;
            badData=[badData data(indices)];

        end
    end
    
end

if (no_outliers)
    avgBadData = mean(reshape(badData,hdr.sampsPerTrig, badCount),2);
    avgGoodData = mean(reshape(goodData,hdr.sampsPerTrig, goodCount),2);

    avgBadData = avgBadData((delaySamps + 1) : (durationSamps));
    avgGoodData = avgGoodData((delaySamps + 1) : (durationSamps));

    f_BadResults = fit(time,avgBadData, 'a + (b * exp(-x/tau))',[a, b, 100e-6]);
    f_GoodResults = fit(time,avgGoodData, 'a + (b * exp(-x/tau))',[a, b, 100e-6]);
end

mean(tau_Array)
std(tau_Array)
r=[f_results_Array(:).r]';
mean(r)
std(r)

clear a;
clear b;
clear avgData;
%clear delay;
clear delaySamps;
%clear duration;
clear durationSamps;
clear f_results;
clear i
clear indices;
clear lastfit;
clear showPlots
clear numAvgs;
%clear windowSize;