% This script fits data from the photon counting board (.sdt file) to a single
% exponential decay model and determines the lifetime as one of the fit
% parameters.

function [tau,varargout] = find_lifetime_sdt(bUseDoubleExp, fileName)

%% Define needed params
   % numSamps = 220;             %Number of samps to extract.  Should be equal to or less than number of time bins used during acq.
   numSamps = 200; 
   %StartSamp = 290;            %sdt files contain data for all channels.  This tells function where the data we are interested in starts.
    StartSamp = 290;
   %StartSamp =310; 
   goodnessOfFitThreshold = 0.90;
    Debug = 1;
    bShowFit = 1;
    bNormalize = 0;
    %tau_estimate = 670e-6;
    tau_estimate = 52e-6;

%% Get the data

    if (nargin < 2) 
        
        if ispc
            temp = 'c:\Data';
        else
            temp = '/Volumes/RUGGED/Data/';
            temp = './';
        end  
      
        [fname, fpath]= uigetfile('*.sdt','Select sdt Data File', temp);
        fname = fullfile(fpath,fname);

    else
        fname = fileName;
    end
    
    if (nargin < 1)
        bDoubleExp = 0;
    else
        bDoubleExp = bUseDoubleExp;
    end
    
  
  
    [t data] = extract_decay_sdt(numSamps, StartSamp, fname);

    %Normalize the data
    %data=data-mean(data((numSamps-3):numSamps));
    if (bNormalize)
        data = data./(max(data));
    end
    
  
%% fit  the valid data

    
    if ~bDoubleExp
        %b_estimate = min(data);
        b_estimate = mean(data(end-20:end))
        a_estimate = max(data) - b_estimate;
        
        %Single Exponential with offset
        fitFunc = sprintf('a*exp(-x/tau)+ b');
        fitResult = ezfit(t,data, fitFunc,[a_estimate, b_estimate,tau_estimate]);

        %Single Exponential -no offset-
    %     fitFunc = sprintf('a*exp(-x/tau)');
    %     fitResult = ezfit(t,data, fitFunc,[a_estimate,100e-6]);
    else
        c_estimate = min(data);
        a_estimate = max(data) - c_estimate;
        b_estimate = a_estimate / 10;
        %Multi exponential fit
        fitFunc = sprintf('a*exp(-x/tau)+ b*exp(-x/tau2)+c');
        fitResult = ezfit(t,data, fitFunc,[a_estimate,b_estimate,c_estimate,1e-6,tau_estimate]);
    end

    %Fit log to have equal weighting of all points
%     fitFunc = sprintf('log(a)-x/tau');
%     a_estimate = 0.9;
%     tau_estimate = 50e-6;
%     fitResult = ezfit(t,log(data), fitFunc,[a_estimate,tau_estimate]);
    
    if (bShowFit)
        figure(2);
        close(2);
       figure(1);
       plot(t,data);
       rmfit;
       showfit(fitResult);
       showresidual;

       
    end
    
    
    if (fitResult.r < goodnessOfFitThreshold)
        if (Debug)
            
            h = msgbox('Poor Fit!','Oops','warn','modal')
            uiwait(h);
        end
        tau = 0.0;
    else
        if bDoubleExp
            tau = fitResult.m(5);
        else
            tau = fitResult.m(3);
        end
    end
    
    
    
    varargout(1) = {fitResult};