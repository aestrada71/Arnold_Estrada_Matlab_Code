%Test FFT technique for finding phase.

clear
%% Define constants
numPeriods = 4;
ptsPerPeriod = 500;
numpoints = numPeriods * ptsPerPeriod;
tau = 2e-9;
freq=200;
omega = freq*2*pi;
dt = 1/(ptsPerPeriod*freq);
t = 0:dt:dt*(numpoints-1);
a=1;
b=0.3;
c=1;
d=0.01;      %magnitude of noise;

% phi1 = -90 * pi/180;
% phi2 = phi1  - (90*pi/180);
phi1 = 180;
phi2 = 180;

%% Create 2photon signal
sig1 = a*cos((omega.*t)+phi1);
sig2 = b*cos((2*omega.*t)+phi2);
noise = c + d.*rand(1,numpoints);
tot = sig1+sig2+noise;

figure(1)
plot(t,sig1,'r',t,sig2,'g',t,tot,'b')
legend('1f','2f','total');

%% Take fft and see if I can revover phase
dt = t(2) - t(1);
df = 1/(numel(t) * dt);
fmax = 1/2 * 1/dt;
fmin = -fmax;
f= (fmin: df : fmax-df)';

tot_freq = fftshift(fft(tot));
pspectrum = abs(tot_freq);
phase = (angle(tot_freq));
ind =find(phase < 0);
phase(ind) = phase(ind)+(2*pi);

figure(2)
subplot(2,1,1)
ind = find(f>=freq,100,'first') - 50;
semilogy(f(ind),pspectrum(ind))
subplot(2,1,2)
plot(f(ind),phase(ind)*180/pi,'r*')

ind1f = find(f>=freq,1,'first');
ind2f = find(f>=2*freq,1,'first');
phase_diff = (phase(ind2f) - phase(ind1f))*180/pi