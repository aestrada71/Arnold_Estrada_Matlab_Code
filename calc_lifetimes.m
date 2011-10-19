function [lifetime_array, varargout] = calc_lifetimes(fileName)

     if (nargin < 1)   
        [fname, fpath]= uigetfile('*.dat','Name of lifetime files to read', 'c:\Data\','MultiSelect','on');
        

     else
        fname = fileName;
     end
     
    showPlots = 1;
    delay = 60e-6;     %seconds;

    
    numFiles = size(fname,2);
    
    for (n=1:numFiles)
        tempName = fullfile(fpath,fname{n});
        [data, hdr] = read_lifetime(tempName);

        delaySamps = fix(delay * hdr.sampRate);

        avgData = mean(reshape(data,hdr.sampsPerTrig, hdr.numTrigs),2);

        avgData = avgData(delaySamps+1:hdr.sampsPerTrig);

        time = ((0:(hdr.sampsPerTrig  -delaySamps -1)) * 1/(hdr.sampRate))';


        a = mean(avgData(numel(avgData)-50:numel(avgData)));
        b = max(avgData)-a;

        f_result = fit(time,avgData, 'a + (b * exp(-x/tau))',[a, b, 100e-6]);
        lifetime_array(n) = f_result.m(3);
        f_result_array(n) = f_result;
        if (showPlots)
            figure(4);
            plot(time,avgData);
            showfit(f_result);
        end
    end
    varargout = {f_result_array};