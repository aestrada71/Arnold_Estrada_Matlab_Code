function [offset, magnitude] = Find_Offset_Mag2(data,tin,t_pulse,ind,f);
    
    %Take the data and average it down to just two cycles

    
    
    
    %Take the data and average it down to just two cycles
    dt=tin(2)-tin(1);
    Nsamp_per=round((1/f)/dt)*2;
    t=tin(1:Nsamp_per);

    Iin2=zeros(Nsamp_per+1,length(t_pulse)-1);

    for ipulse=1:length(t_pulse)-2
        Iin2(:,ipulse)=data(ind(ipulse):ind(ipulse)+Nsamp_per);    
    end
    avgdData = mean(Iin2,2);
    
    
    [histo, bins]=hist(avgdData);
    offset = mean(bins);

    %find magnitude.
    [histo, bins]=hist(avgdData - offset);
    [maxHistVal,I] = max(bins);
    maxVal = bins(I);
    magnitude = maxVal;
end