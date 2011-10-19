% This script fits data from the photon counting board to to a single
% exponential decay model and determines the lifetime as one of the fit
% parameters.

function [tau,varargout] = find_lifetime_pc(dt, filename)

    shiftOverTime = 2e-9;                %time until we get to "valid" data. (s)
    goodnessOfFitThreshold = 0.92;
    verbose = 1;
    bShowFit = 1;

    if (nargin ~= 2)   
        [fname, fpath]= uigetfile('*.asc','Select asc Data File', '/Volumes/RUGGED/Data/');
        fname = fullfile(fpath,fname);

    else
        fname = fileName;
    end
  
  
%% grab valid data
    [data t] = read_asc(dt,fname);
    minIndex = find(t >= shiftOverTime,1);
    t = t(minIndex:end) - t(minIndex);
    data = data(minIndex:end);
  
%% fit  the valid data
    b_estimate = min(data);
    a_estimate = max(data) - b_estimate;
    
    fitFunc = sprintf('a*exp(-x/tau)+ b');
    fitResult = ezfit(t,data, fitFunc,[a_estimate, b_estimate,100e-9]);

    %fitFunc = sprintf('a*exp(-x/tau)');
    %fitResult = ezfit(t,data, fitFunc,[a_estimate,100e-6]);
    
    if (bShowFit)
       figure(1);
       plot(t,data);
       rmfit;
       showfit(fitResult);
    end
    
    
    if (fitResult.r < goodnessOfFitThreshold)
        if (verbose)
            h = msgbox('Poor Fit!','Oops','warn','modal')
        end
        tau = 0.0;
    else
        tau = fitResult.m(3);
    end
    
    
    
    varargout(1) = {fitResult};