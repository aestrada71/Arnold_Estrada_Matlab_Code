function[avgData time] = avg_lifetime()

%delay = 50;         %Samples.
% numSampsPerTrig = 1000;
% numTrigs = 2000;

%[data hdr] = read_lifetime('c:\testdata.dat');
[data hdr] = read_lifetime();

avgData = mean(reshape(data,hdr.sampsPerTrig, hdr.numTrigs),2);

time = ((0:(hdr.sampsPerTrig  -1)) * 1/(hdr.sampRate))';