%Modified Andy's fit_phase routine so that I can call it from my script
%which processes an entire data set covering multiple freqs.  The main
%changes were that it only performs one fit at a time.  It doesnt
%distinguish between PD or PMT.  And the fit string can be passed in.
%This routine is intended to be used with triggd data sets.

function [f_results, varargout] = fit_phase2(Iin, tin, f, funcString, varargin)


%Take the data and average it down to just two cycles
dt=tin(2)-tin(1);
Nsamp_per=round((1/f)/dt)*2;      % -Double Cycle fitting
%Nsamp_per=round((1/f)/dt)*1;

t = (dt .* (1:Nsamp_per))';      %-Needed for double cycle fitting
%t=tin(1:Nsamp_per);

avgdData=mean(reshape(Iin,[Nsamp_per numel(Iin)/Nsamp_per]),2);

   
% Determine startinvg vals for as many params of model as possible.
phi1 = 35;        %degrees
phi2 = 35;

%find offset.
a = mean(avgdData);

%find magnitude.
[histo, bins]=hist(avgdData - a);
[maxHistVal,I] = max(histo);
maxVal = bins(I);
b = maxVal;
c = b/2;

%perform the fit.
if (nargin>4)
    f_results = fit(t,avgdData, funcString, varargin{1});
else
    f_results = fit(t,avgdData, funcString);
end

if(nargout>1)  
   varargout(1)={evalfit(f_results, f_results.x)};

end



