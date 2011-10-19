%2P Modulated Fluorescence Simulation

clear
%% Define constants
numPeriods = 30;
ptsPerPeriod = 500;
numpoints = numPeriods * ptsPerPeriod;
tau = 2e-9;
freq=200;
omega = freq*2*pi;
dt = 1/(ptsPerPeriod*freq);
t = 0:dt:dt*(numpoints-1);
a=1;        %Offset of modulated light
b=1;        %Amplitued of mulated light
c=0.00;     %magnitude of noise;




%% Create Excitation signal
sig1 = a + b.*cos((omega.*t));
sig2 = sig1.^2;


figure(1)
plot(t,sig1,'r',t,sig2,'g',t,tot,'b')
legend('1f','2f','total');