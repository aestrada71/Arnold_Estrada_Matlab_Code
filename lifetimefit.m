function [estimates, model] = lifetimefit(freq, xdata, ydata)
% Determine as many params of model as possible.
startPhase = 10;        %degrees
%freq = 100;

%find offset.
off = mean(ydata);


%find magnitude.
[histo, bins]=hist(ydata - off);
[maxHistVal,I] = max(histo);
maxVal = bins(I);
mag = maxVal;

start_point(1) = off;
start_point(2) = mag;
%start_point(3) = freq;
start_point(3) = startPhase;


model = @sinusoidfun;
estimates = fminsearch(model, start_point);
% expfun accepts curve parameters as inputs, and outputs sse,
% the sum of squares error for [offset + magnitude(sin(freq*2PI*x-phi)] - ydata, 
% and the FittedCurve. FMINSEARCH only needs sse, but we want to 
% plot the FittedCurve at the end.
    function [sse, FittedCurve] = sinusoidfun(params)
        offset = params(1);
        magnitude = params(2);
        
    %    frequency = params(3);  %in Hz
        frequency = freq;
    
        phase = params(3);      %in degrees
        
        FittedCurve = offset + magnitude.*sin((xdata .* 2 .* pi * frequency) - (pi * phase / 180));
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
end