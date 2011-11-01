clear all;
%close all;

R_C = 3;         %Column represnting the rectification data;
PD_C = 2;       %Column representing Photodiode data;
PMT_C = 1;      %Column representing PMT data;
thresh = 4.5;   %Rectification threshold of ref signal (usually diode sig)
freq = 1000;
fname = 'Gold_nanoshell_100hz.daq';

%read in data file
[data,time] = daqread(fname);
R=data(:,R_C);
PD = data(:,PD_C);
PMT = data(:,PMT_C);
clear data;

%Run Andy's rectification code to find where each cycle actually starts.
Iref_sq = zeros(size(R));
Iref_sq(find(R > thresh))=1;

ind=find(diff(Iref_sq) > 0.5);
clear Iref_sq;
t_pulse = time(ind);        %Contains vector of times of start of each cycle.

%Take the PD data and average it down to just two cycles
dt=time(2)-time(1);
Nsamp_per=round((1/freq)/dt)*2;
t=time(1:Nsamp_per);

PD2=zeros(Nsamp_per+1,length(t_pulse)-1);

for ipulse=1:length(t_pulse)-2
    PD2(:,ipulse)=PD(ind(ipulse):ind(ipulse)+Nsamp_per);    
end
avgdPD = mean(PD2,2);
tnew=(0:size(PD2,1)-1)*dt;
tnew=tnew';

% figure(1);
% plot(tnew, avgdPD);
clear PD;
clear PD2;
clear PD_C;


%Take the PMT data and average it down to just two cycles
PMT2=zeros(Nsamp_per+1,length(t_pulse)-1);

for ipulse=1:length(t_pulse)-2
    PMT2(:,ipulse)=PMT(ind(ipulse):ind(ipulse)+Nsamp_per);    
end
avgdPMT = mean(PMT2,2);
% figure(2);
% plot(tnew, avgdPMT);


%fit Photo diode data first. 
   fit_fun_pd = sprintf('a+b*sin(2*pi*%i*x-phi)',freq);
   [fit_results_pd] = fit(tnew,avgdPD, fit_fun_pd,[0.7,0.5,6.0]);

   
   if(1) %turn on/off plotting PD data and fit.
       figure(3);
       hold off;
       plot(fit_results_pd.x, fit_results_pd.y, '*');
       showfit(fit_results_pd);
       title(fname);
   end


    %fit PMT data.   
%    fit_fun_pmt = sprintf('a+b*sin(2*pi*%i*x-phi)',freq);
   fit_fun_pmt = sprintf('(a+b*sin(2*pi*%i*x-phi)).^2',freq);

   
  %get guesses for some params to help fitting routine.
  %[a, b] = Find_Offset_Mag(avgdPMT,tnew,freq)
  a=0.4;        %Offset
  b=0.3;        %magnitude
  phi1 = fit_results_pd.m(3);
  [fit_results_pmt] = fit(tnew,avgdPMT,fit_fun_pmt, [a, b, phi1] );
   if(1) %turn on/off plotting pmt data and fit.
       figure(4);
       hold off;
       plot(fit_results_pmt.x, fit_results_pmt.y, '*');
       showfit(fit_results_pmt);
       title(fname);
   end   
   


figure(5)
plot(log10(avgdPD), log10(avgdPMT),'o');
fit_results_log_log = fit(log10(avgdPD),log10(avgdPMT),'m*x+b',[1,-1.7])
showfit(fit_results_log_log);

figure(6)
plot(log10(fit_results_pd.y), log10(fit_results_pmt.y),'*');
fit_results_log_log2 = fit(log10(fit_results_pd.y),log10(fit_results_pmt.y),'m*x+b',[1,-1.7])
showfit(fit_results_log_log2)

clear PMT;
clear PMT2;
clear PMT_C;

clear fname;
clear time;
clear thresh
clear t;
clear t_pulse;
clear ipulse;
clear ind;
clear R_C;
clear R;
clear Nsamp_per;
clear freq;