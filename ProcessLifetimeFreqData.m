
%basename = 'PDA_Test_';
basename = 'Instr_trigd_';

fpath= uigetdir('~/Documents', 'Select 2Photon dir of lifetime Data Files');

tic;

useableFreqs = [100,200,400,500,800,1000,2000 4000 ...
                    5000 8000 10000];

numFreqs = numel(useableFreqs);

for (n=1:numFreqs)
    
   %get current freq from list
   freq = useableFreqs(n);    
       
   %create file names
   tempName = [basename  int2str(freq)  'hz'];
   fname = fullfile(fpath,tempName);
   
   %read in data file
   [data,time] = daqread(fname);
   
   
   %This part changed for new triggered acquisitions.
    prevSize = size(data);
    finiteInds = isfinite(data);
    data = data(finiteInds);
    data = reshape(data,[],prevSize(2));
    finiteInds = isfinite(time);
    time = time(finiteInds);
   
   
   
   %fit Photo diode data first. 
   fit_fun_pd = sprintf('a+b*sin(2*pi*%i*x-phi)',freq);
   %fit_fun_pd = sprintf('(a+b*sin(2*pi*%i*x-phi)).^2',freq);
   %fit_fun_pd = sprintf('(a+b*sin(2*pi*%i*x-phi)+c*sin(2*pi*%i*x-phi2))',freq,2*freq);
   [fit_results_pd, fitCurve_pd] = fit_phase2(data(:,2),time,freq,fit_fun_pd);
   
   if(1) %turn on/off plotting PD data and fit.
       figure(1);
       hold off;
       plot(fit_results_pd.x, fit_results_pd.y, '*');
       hold on;
       plot(fit_results_pd.x, fitCurve_pd);
       hold off;
       title(fname);
   end
   
   
    %fit PMT data.   
    fit_fun_pmt = sprintf('a+b*sin(2*pi*%i*x-phi)',freq);
 %  fit_fun_pmt = sprintf('(a+b*sin(2*pi*%i*x-phi)).^2',freq);
  % fit_fun_pmt = sprintf('(a+b*sin(2*pi*%i*x-phi)+c*sin(2*pi*%i*x-phi2))',freq,2*freq);
   
  
  %get guesses for some params to help fitting routine.
  [a, b] = Find_Offset_Mag(data(:,1),time,freq)
  phi1 = fit_results_pd.m(3);
  [fit_results_pmt, fitCurve_pmt] = fit_phase2(data(:,1),time,freq,fit_fun_pmt, [a, b, phi1] );
   
   if(1) %turn on/off plotting pmt data and fit.
       figure(2);
       hold off;
       plot(fit_results_pmt.x, fit_results_pmt.y, '*');
       hold on;
       plot(fit_results_pmt.x, fitCurve_pmt);
       hold off;
       title(fname);
   end
   
 
   
   returnStruct(n).DiodePhase = fit_results_pd.m(3)*180/pi;
   returnStruct(n).DiodeFitCurve=fitCurve_pd;
   returnStruct(n).DiodeFitResults = fit_results_pd;
   returnStruct(n).PMTPhase = fit_results_pmt.m(3);
   returnStruct(n).PMTFitCurve=fitCurve_pmt;
   returnStruct(n).PhaseDiff = (fit_results_pmt.m(3)-fit_results_pd.m(3))*180/pi;
   returnStruct(n).PMTFitResults = fit_results_pmt;
   returnStruct(n).freq = freq;
   
end

if(1)
    figure(3)
    plot([returnStruct.freq],[returnStruct.PhaseDiff]);
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
clear fpath;
clear freq;
clear n;
clear fitCurve_pd;
clear fitCurve_pmt;
clear fit_fun_pd;
clear fit_fun_pmt;
clear fit_results_pd;
clear fit_results_pmt;
clear lastfit;
clear numFreqs;
clear useableFreqs;

%clear model;

time=toc

