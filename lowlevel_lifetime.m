function f_results = lowlevel_lifetime(data, hdr, a, b, tau)

Show_Fit = 0;

if(hdr.typeSize==8)
    delay = 60e-6;     %seconds;
else
    delay = 30e-6;
end

delaySamps = fix(delay * hdr.sampRate);

avgData = mean(reshape(data,hdr.sampsPerTrig, hdr.numTrigs),2);

avgData = avgData(delaySamps+1:hdr.sampsPerTrig);

time = ((0:(hdr.sampsPerTrig  -delaySamps -1)) * 1/(hdr.sampRate))';
%Calculate a,b,tau from data if not given
if(nargin~=5)
    a = mean(avgData(numel(avgData)-50:numel(avgData)));
    b = max(avgData)-a;
    tau = 100e-6;
end
f_results = fit(time,avgData, 'a + (b * exp(-x/tau))',[a, b, tau]);

if (Show_Fit)
    figure(4)
    plot(time,avgData);
    showfit(f_results);
end