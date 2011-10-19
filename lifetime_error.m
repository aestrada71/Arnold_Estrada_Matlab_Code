%lifetime_error2
%
%Written by Arnold Estrada
%10/28/2007
%Last Updated: 10/28/2007
%
%This routine calculates the standard error of our lifetime data by using
%the bootstrap method.
%Processes one .dat file from a Two-Photon Lifetime Acquisition
    %General Algorithm:
    %1. blank out one row of data.
    %2. Use the rest of the data to determine the lifetime
    %3. Store the value of that lifetime.
    %4. Do the above for all rows.
    %5. The standard deviation (with a scale factor) of the lifetime vals
    %is the standard error
    %6. Return a struct with fit data and discarded data log

function [error] = lifetime_error2(fileName);

if (nargin < 1)   
    [fname, fpath]= uigetfile('*.dat','Name of lifetime file to read', 'c:\Data\','MultiSelect','off');
    fname=strcat(fpath,fname);
else
    fname = fileName
end

tic
%Set delay time
[data, hdr] = read_lifetime(fname);
bs_hdr = hdr;
n = hdr.numTrigs;
sampsPerTrig = hdr.sampsPerTrig;



%Try using the statstoolbox boot strap routine.  

aa=reshape(data,hdr.sampsPerTrig, hdr.numTrigs);
aa=aa';

if(hdr.typeSize==8)
    delay = 60e-6;     %seconds;
else
    delay = 30e-6;
end
delaySamps = fix(delay * hdr.sampRate);
aa = aa(:,delaySamps+1:end);
%define the statistic function as a function handle
fhandle = @FindTau;
    function tau = FindTau(data1)
        avgData = mean(data1,1)';
        time = ((0:(hdr.sampsPerTrig  -delaySamps -1)) * 1/(hdr.sampRate))';
        
        a0 = mean(avgData(numel(avgData)-50:numel(avgData)));
        b0 = max(avgData)-a0;
        tau0 = 100e-6;
        
        f_results = fit(time,avgData, 'a + (b * exp(-x/tau))',[a0, b0, tau0]);
        tau = f_results.m(3);
    end
[bootStats bootSamps] = bootstrp(300,fhandle,aa);
error = std(bootStats);

toc
end