%2P Modulated Fluorescence Simulation

clear all
%% Define constants
numPeriods = 7;
ptsPerPeriod = 500;
numpoints = numPeriods * ptsPerPeriod;
tau = 500e-6;
freq=200;
omega = freq*2*pi;
dt = 1/(ptsPerPeriod*freq);
t = 0:dt:dt*(numpoints-1);
a=1;        %Offset of modulated light
b=1;        %Amplitued of mulated light
c=1;
d=0.00;     %magnitude of noise;




%% Create Excitation signal
sig1 = a + b.*cos((omega.*t));
sig2 = sig1.^2;


% figure(1)
% plot(t,sig1,'r',t,sig2,'g');
% legend('Excitation','Excitation^2');
% xlabel('Time (s)');

%% Create Impulse resopnse
impResp = c.*exp(-t./tau);
% figure(2)
% plot(t,impResp);


%%  Perform the convolution to get system response
response = conv(sig2,impResp);
%figure(2)
t2 = 0:dt:dt*(2*numpoints-2);
%plot(t,sig2,t,response(1:numpoints));

%%  Create system response based on my analytical solution.
temp1 = -tau*(8 + 32*omega^2*tau^2 + 12*omega^4*tau^4);
temp2 = (1+omega^2*tau^2)*(1+4*omega^2*tau^2);
const = temp1/temp2;
clear temp1 temp2;
A= 3 * tau;
B= 4*tau/[1+omega^2*tau^2]^0.5;
C = tau/[1+4*omega^2*tau^2]^0.5;
phi1 = atan(-omega*tau);
phi2 = atan(-omega*2*tau);

analyticResponse = a^2 * [const.*exp(-t/tau) + A + B.*cos(omega.*t+phi1)+C.*cos(2.*omega.*t+phi2)];
%figure(3)
%plot(t,analyticResponse);

%%  Compare numeric calc and analytic calc of system response
figure(2)
plot(t,response(1:numpoints)/max(response),'g',t,analyticResponse/max(analyticResponse), ...
    t,sig1/max(sig1),'r');
legend('Numeric','Analytic','Excitation')
fig2Title = sprintf('Normalized System Response. Tau = %i, Freq = %f',tau,freq');
title(fig2Title)

%%  Look at the 1f and 2f components vs frequency
f = 10:10:2000;
omegas = 2.*pi.*f;

Mag1f = 4.*tau./[1+omegas.^2*tau^2].^0.5;
Mag2f = tau./[1+4.*omegas.^2*tau^2].^0.5;

figure(3)
plot(f,Mag1f,'r',f,Mag2f,'g');
legend('1f','2f')
xlabel('Modulation Frequency (Hz)');
title('Transfer function (Magnitude)');

% figure(4)
% plot(f,Mag1f./Mag2f);

phi1s = (atan(omegas*tau)).*180./pi;
phi2s = (atan(omegas*2*tau)).*180./pi;
figure(4)
plot(f,phi1s,'r',f,phi2s,'g');
legend('1f','2f')
xlabel('Modulation Frequency (Hz)');
ylabel('Phase Shift (degrees)');
title('Transfer function (Phase)');