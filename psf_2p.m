%_________________________________________________________________________
%   Arnold Estrada
%
%   Program:    Calculates the PSF of an averaged 2 photon image.
%   Purpose:    This program accepts xdata and ydata and fits a gaussian
%               function to the data.  It then finds the full width half
%               max points.

function [estimates, model] = psf_2p(xdata, ydata)
% Call fminsearch with a random starting point.
start_point = rand(1, 2);
model = @expfun;
estimates = fminsearch(model, start_point);
% expfun accepts curve parameters as inputs, and outputs sse,
% the sum of squares error for A * exp(-lambda * xdata) - ydata, 
% and the FittedCurve. FMINSEARCH only needs sse, but we want to 
% plot the FittedCurve at the end.
    function [sse, FittedCurve] = expfun(params)
        A = params(1);
        lambda = params(2);
        FittedCurve = A .* exp(-lambda * xdata);
        ErrorVector = FittedCurve - ydata;
        sse = sum(ErrorVector .^ 2);
    end
end
