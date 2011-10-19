function [offset, magnitude] = Find_Offset_Mag(data,tin,f);
    
    %Take the data and average it down to just two cycles
    dt=tin(2)-tin(1);
    
    Nsamp_per=round((1/f)/dt)*2;
    t=tin(1:Nsamp_per);

    avgdData=mean(reshape(data,[Nsamp_per numel(data)/Nsamp_per]),2);
    
    
    [histo, bins]=hist(avgdData);
    offset = mean(bins);

    %find magnitude.
    [histo, bins]=hist(avgdData - offset);
    [maxHistVal,I] = max(bins);
    maxVal = bins(I);
    magnitude = maxVal;
end