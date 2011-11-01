%This routine processes a whole set of triggered freq vs phase data.


%basename = 'PDA_Test_';
%basename = 'Instr_trigd_';
%basename = 'Porphyrin_trigd_';

%fpath= uigetdir('~/Documents', 'Select 2Photon dir of lifetime Data Files');

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
   
   
   %-----This part changed for new triggered acquisitions.-----
   %get rid of the NANs in the data.
    prevSize = size(data);
    finiteInds = isfinite(data);
    data = data(finiteInds);
    data = reshape(data,[],prevSize(2));
    finiteInds = isfinite(time);
    time = time(finiteInds);
   
   
   
   %fit ref data first. 
   fit_fun_ref = sprintf('a+b*sin(2*pi*%i*x-phi)',freq);
   %fit_fun_pd = sprintf('(a+b*sin(2*pi*%i*x-phi)).^2',freq);
   %fit_fun_pd = sprintf('(a+b*sin(2*pi*%i*x-phi)+c*sin(2*pi*%i*x-phi2))',freq,2*freq);
   [fit_results_ref, fitCurve_ref] = fit_phase_triggd(data(:,2),time,freq,fit_fun_ref);
   
   if(1) %turn on/off plotting ref data and fit.
       figure(1);
       hold off;
       plot(fit_results_ref.x, fit_results_ref.y, '*');
       hold on;
       plot(fit_results_ref.x, fitCurve_ref);
       hold off;
       title(fname);
   end
   
   
    %fit PMT data.   
   % fit_fun_pmt = sprintf('a+b*sin(2*pi*%i*x-phi)',freq);
   fit_fun_pmt = sprintf('(a+b*sin(2*pi*%i*x-phi)).^2',freq);
  % fit_fun_pmt = sprintf('(a+b*sin(2*pi*%i*x-phi)+c*sin(2*pi*%i*x-phi2))',freq,2*freq);
   
  
  %get guesses for some params to help fitting routine.
  [a, b] = Find_Offset_Mag(data(:,1),time,freq)
  phi1 = fit_results_ref.m(3);
  [fit_results_pmt, fitCurve_pmt] = fit_phase_triggd(data(:,1),time,freq,fit_fun_pmt, [a, b, phi1] );
   
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
   returnStruct(n).PhaseDiff = (fit_results_pmt.m(3)-fit_results_ref.m(3))*180/pi;
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
clear a;
clear b;
clear finiteInds;
clear phi1;
clear prevSize;

%clear model;

time=toc

