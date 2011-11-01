f=1000

nidaq_acquire_freq('Dev1',[1],200000,1,f,'Test_Freqs');
[a,t]=daqread('Test_Freqs');

%get rid of the NANs in the data.
prevSize = size(a);
finiteInds = isfinite(a);
a = a(finiteInds);
a = reshape(a,[],prevSize(2));
finiteInds = isfinite(t);
t = t(finiteInds);
clear finiteInds;


dt=t(2)-t(1);
Nsamp_per=round((1/f)/dt)*2;
%Nsamp_per = round(Nsamp_per)*2;
t_per=t(1:Nsamp_per);

%a_avgd=mean(reshape(a(:,1),[Nsamp_per size(a,1)/Nsamp_per]),2);
%close all;
for i=0:100; 
    ind = Nsamp_per*i+1:Nsamp_per*(i+1);
    plot(1:Nsamp_per,a(1:Nsamp_per,1),1:Nsamp_per,a(ind,1));
    pause(0.01);
end;