clear all;
close all;

PD_C = 2;       %Column representing Photodiode data;
PMT_C = 1;      %Column representing PMT data;
thresh = 0.8;   %Rectification threshold of ref signal (usually diode sig)
t_width = 1e-3;
%fname = 'PostVivoPorphryin_timedomain.daq';
fname = 'OnePhoton_porphyrin_2khz.daq';
%fname = 'PostVivoRhodamine_timedomain.daq';

%read in data file
[data,time] = daqread(fname);
PD = data(:,PD_C);
PMT = data(:,PMT_C);
clear data;

%Run Andy's rectification code to find where each cycle actually starts.
Iref_sq = zeros(size(PD));
Iref_sq(find(PD > thresh))=1;

ind=find(diff(Iref_sq) > 0.5);
clear Iref_sq;
t_pulse = time(ind);        %Contains vector of times of start of each cycle.


dt=time(2)-time(1);
Nsamp_per=round(t_width/dt);
t=time(1:Nsamp_per);

ind = ind + round(1e-6/dt);


%Take the PD data and average it down to just two cycles
PD2=zeros(Nsamp_per+1,length(t_pulse)-1);

for ipulse=1:length(t_pulse)-2
    PD2(:,ipulse)=PD(ind(ipulse):ind(ipulse)+Nsamp_per);    
end
avgdPD = mean(PD2,2);
tnew=(0:size(PD2,1)-1)*dt;
tnew=tnew';

plot(tnew, avgdPD);
clear PD;
clear PD2;
clear PD_C;

%Take the PMT data and average it down to just two cycles
PMT2=zeros(Nsamp_per+1,length(t_pulse)-1);

for ipulse=1:length(t_pulse)-2
    PMT2(:,ipulse)=PMT(ind(ipulse):ind(ipulse)+Nsamp_per);    
end
avgdPMT = mean(PMT2,2);


plot(tnew, avgdPMT, 'o');



f_results = fit(tnew,avgdPMT, 'a + (b * exp(-x/tau))',[0.3, 0.5, 100e-6]);
% Yfit = evalfit(f_results, f_results.x);
% hold on;
% plot(f_results.x,Yfit);
% hold off;

showfit(f_results);

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