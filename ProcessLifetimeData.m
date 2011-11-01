function [returnStruct, varargout] = ProcessLifetimeData( varargin)
%This routine processes a whole set of non-triggered freq vs phase data.

%Added Andy's rectification code to fix the frequency mismatch between func
%generator and daq board, which led to screwed up averaging.

useInstrPMTModel=0;
if (nargin>0)
    basename = varargin{1};
    fpath = varargin{2};
    if (numel(varargin)>=3)
        useInstrPMTModel=1;
        instrStruct = varargin{3};
        
        PMTFitResults = [instrStruct.PMTFitResults];
        PhaseDiffs = [instrStruct.PhaseDiff]*pi/180;
    end
else
  %basename = 'PDA_Test_';
  basename = 'Rhodamine_';  
  basename = 'Porphyrin_'; 
  fpath= uigetdir('~/Documents/FTP Downloads/', 'Select 2Photon dir of lifetime Data Files');

end


tic;
%10 20 40 50 80 100
useableFreqs = [ 80 100 140 200 300 400 500 600 700 800 900 1000 1400 2000 2600 3000 3500 ...
                    4000 5000 6000 7000 8000 9000 10000];
         
useableFreqs = [ 10 20 30 40 50 60 70 80 90 100 120 140 160 180 200 220  ...
                    260 280 300];
                
RC = 2;         %Column representing reference data;
PC = 1;         %Column representing PMT data;
thresh = 3;   %Rectification threshold of ref signal (usually diode sig)

numFreqs = numel(useableFreqs);

for (n=1:numFreqs)
    
   %get current freq from list
   freq = useableFreqs(n);    
       
   %create file names
   tempName = [basename  int2str(freq)  'hz'];
   fname = fullfile(fpath,tempName);
   
   %read in data file
   [data,time] = daqread(fname);
   
   
   %Run Andy's rectification code to find where each cycle actually starts.
    Iref_sq = zeros(size(data(:,RC)));
    Iref_sq(find(data(:,RC)>thresh))=1;

    ind=find(diff(Iref_sq) > 0.5);
    clear Iref_sq;
    t_pulse = time(ind);        %Contains vector of times of start of each cycle.
   
   
   %fit Photo diode data first. 
   fit_fun_ref = sprintf('a+b*sin(2*pi*%i*x+phi)',freq);
   %fit_fun_pd = sprintf('(a+b*sin(2*pi*%i*x-phi)).^2',freq);
   %sprintf('(a+b*sin(2*pi*%i*x-phi)+c*sin(2*pi*%i*x-phi2))',freq,2*freq);
   [fit_results_ref, fitCurve_ref] = fit_phase2(data(:,RC),time,t_pulse,ind,freq,fit_fun_ref);
   
   
   
   if(1) %turn on/off plotting PD data and fit.
       figure(1);
       hold off;
       plot(fit_results_ref.x, fit_results_ref.y, '*');
       hold on;
       plot(fit_results_ref.x, fitCurve_ref);
       hold off;
       title(fname);
   end
   
   
    %fit PMT data.  
    %get guesses for some params to help fitting routine.
    [a, b] = Find_Offset_Mag2(data(:,PC),time,t_pulse,ind,freq);
    phi1 = fit_results_ref.m(3);
    
    %Change PMT model to include scattered signal.
   if (useInstrPMTModel)
        instrPMTFit = PMTFitResults(n);
        q = instrPMTFit.m(1);
        r = instrPMTFit.m(2);
        pp = fit_results_ref.m(3);
        ppdiff = PhaseDiffs(n);
       
       fit_fun_pmt = sprintf('(a+b*sin(2*pi*%i*x+phi)).^2 + (q+r*sin(2*pi*%i*x+(%f+%f)))',freq,freq,pp,ppdiff);
   
       [fit_results_pmt, fitCurve_pmt] = fit_phase2(data(:,PC),time,t_pulse,ind,freq,fit_fun_pmt, [a, b, phi1, q, r] );
   else
       fit_fun_pmt = sprintf('(a+b*sin(2*pi*%i*x+phi)).^2',freq);
       
       [fit_results_pmt, fitCurve_pmt] = fit_phase2(data(:,PC),time,t_pulse,ind,freq,fit_fun_pmt, [a, b, phi1] );
   end
   
  % fit_fun_pmt = sprintf('(a+b*sin(2*pi*%i*x-phi)+c*sin(2*pi*%i*x-phi2))',freq,2*freq);
   
  
  
  
   
   if(1) %turn on/off plotting pmt data and fit.
       figure(2);
       hold off;
       plot(fit_results_pmt.x, fit_results_pmt.y, '*');
       hold on;
       plot(fit_results_pmt.x, fitCurve_pmt);
       hold off;
       title(fname);
   end
   
 
   
   returnStruct(n).RefPhase = fit_results_ref.m(3)*180/pi;
   returnStruct(n).RefFitCurve=fitCurve_ref;
   returnStruct(n).RefFitResults = fit_results_ref;
   returnStruct(n).PMTPhase = fit_results_pmt.m(3);
   returnStruct(n).PMTFitCurve=fitCurve_pmt;
   returnStruct(n).PhaseDiff = (fit_results_ref.m(3)-fit_results_pmt.m(3))*180/pi;
   returnStruct(n).PMTFitResults = fit_results_pmt;
   returnStruct(n).freq = freq;
   
end

if(1)
    figure(3)
    plot([returnStruct.freq],[returnStruct.PhaseDiff], 'o');
end

clear basename;
clear numFiles;
clear temp;
clear tempName;
clear time;
clear data;
clear PDestimates;
clear PMTestimates;
clear sse1;
clear sse2;
clear fname;
%clear fpath;
clear freq;
clear n;
clear fitCurve_ref;
clear fitCurve_pmt;
clear fit_fun_ref;
clear fit_fun_pmt;
clear fit_results_ref;
clear fit_results_pmt;
clear lastfit;
clear numFreqs;
clear useableFreqs;
clear phi1;
clear a;
clear b;
clear PC;
clear RC;
clear ind;
clear t_pulse;
clear thresh;
%clear model;

time=toc

