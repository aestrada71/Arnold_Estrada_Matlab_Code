%Simulation of modulated femptosecond pulse train and one photon absorb.

dt=0.1e-9;
t=100e-6:dt:110e-6; % time axis
f_mod=500; % modulation freq
t_laser=0:1/76e6:max(t); % laser pulse times

Imod=0.5*sin(2*pi*f_mod*t)+0.5;
laser_pulses=pulstran(t, t_laser, 'rectpuls', dt); % generate laser pulse train
Pl_mod=Imod.*laser_pulses;

% Pl_mod2=zeros(size(t));
% for i=1:length(t_laser)-1
%     if(mod(i,200)==0); disp(i);drawnow;end
%     ind=find(t>=t_laser(i) & t<t_laser(i+1)); 
%     Pl_mod2(ind(1))=Pl_mod(i);
% end

tau=550e-6; % lifetime
h=exp(-t/tau); % fluorescence decay signal

sig=conv(h,Pl_mod);
sig=sig(1:length(t));
plot(t,sig/(2*mean(sig)),t,Imod/(2*mean(Imod)))
title(sprintf('f=%i kHz, tau=%.1f us',f_mod*1e-3, tau*1e6))

