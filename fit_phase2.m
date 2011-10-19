%Modified Andy's fit_phase routine so that I can call it from my script
%which processes an entire data set covering multiple freqs.  The main
%changes were that it only performs one fit at a time.  It doesnt
%distinguish between PD or PMT.  And the fit string can be passed in.

%The function averages many cycles by folding the vector of data into a
%matrix of data, where each col is one cycle.  It then averages the matrix
%along the cols dimension.  It then calls the fit routine on the resultant
%average vector which represents an average cycle (double cycle).

%Added Andy's rectification code to fix the frequency mismatch between func
%generator and daq board, which led to screwed up averaging.

function [f_results, varargout] = fit_phase2(Iin, tin, t_pulse, ind,f, funcString, varargin)


%Take the data and average it down to just two cycles
dt=tin(2)-tin(1);
Nsamp_per=round((1/f)/dt)*2;
t=tin(1:Nsamp_per);

Iin2=zeros(Nsamp_per+1,length(t_pulse)-1);

for ipulse=1:length(t_pulse)-2
    Iin2(:,ipulse)=Iin(ind(ipulse):ind(ipulse)+Nsamp_per);    
end
avgdData = mean(Iin2,2);
tnew=(0:size(Iin2,1)-1)*dt;
tnew=tnew';
%avgdData=mean(reshape(Iin,[Nsamp_per numel(Iin)/Nsamp_per]),2);

   
% Determine startinvg vals for as many params of model as possible.
phi1 = .8;        %radians
phi2 = .8;

%find offset.
a = mean(avgdData);

%find magnitude.
[histo, bins]=hist(avgdData - a);
% [maxHistVal,I] = max(histo);
% maxVal = bins(I);
% b = maxVal;
% c = b/2;
b = max(bins);

%perform the fit.
if (nargin>6)
    f_results = fit(tnew,avgdData, funcString, varargin{1});
else
    f_results = fit(tnew,avgdData, funcString, [a,b,phi1]);
end

if(nargout>1)  
   varargout(1)={evalfit(f_results, f_results.x)};

end



