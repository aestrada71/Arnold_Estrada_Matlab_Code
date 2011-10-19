function [results] = phosphorescence_modelling(param)

% This script models the phosphoerescence signal when using a two-photon
% excitation source. It takes into account focal volume and saturation of
% oxygen probe.

verbose = 1;

%% Initialize Parameters.
if (nargin < 1)
    param.po2 = 75;                    %mmHg
    param.frequencyDomain = 0;
    param.r2 = 0;
    
    if param.r2
        param.tau_0 = 676e-6;                %Unquenched lifetime (seconds)
        param.k_quench = 332;               %Oxyphor R2, from publication(mmHg^-1 * s^-1)
        param.QE = 0.1;                     %estimated ! Look this up.
        param.x_section = 15 * 0.05/param.QE;       %Two photon ABSORPTION cross section of porph (GM = 1e-50 cm^4 s / photon).
        param.C = 400e-6;                   %Concentration of porphyrin. in Molarity
        param.lambda = 800e-9;              %Excitation wavelength (m);
    else
        param.tau_0 = 52e-6;                %measured Unquenched lifetime (seconds)
        param.k_quench = 529.2;               %PtP-C343, from publication(mmHg^-1 * s^-1)
        param.QE = 0.1;                     %estimated ! Look this up.
        param.x_section = 100/param.QE;       %Two photon ABSORPTION cross section of porph (GM = 1e-50 cm^4 s / photon).
        param.C = 60e-6;                   %Concentration of porphyrin. in Molarity
        param.lambda = 870e-9;              %Excitation wavelength (m);
    end

    param.K_phos_0 = 1/param.tau_0;     %Rate constant for emission of phosphorescence photons
    tau_effective = (1/param.tau_0 + param.k_quench * param.po2)^-1;
    param.power = 100e-3;                 %Excitation power at focal volume (J/s)
    param.NA = 0.95;                       %Numerical aperture of objective
    param.index = 1.33;                     %Index of refraction of imaging medium
    param.NA_collection = 0.95;          %Added this so I can check effect of NA on collection and make it diff from excitation NA
    param.V_exc = 1e-12;                    %Excitation volume (Liters)
    param.modulation_freq = 1/(6.5*tau_effective);        %Hz
    %param.modulation_freq = 0.2e3;
    param.period = 1/param.modulation_freq;     %period of excitation profile
    param.timeDomainOnTime = 0.1 * tau_effective;
    %param.timeDomainOnTime = 5e-6;
    param.tspan = [0 4*param.period];            %
    param.dt = param.tspan(2)/2000;                    %dt for fdtd
    param.N_0 = 0;                      %Initial value.
    param.f_laser = 76e6;               %rep rate of the laser
    param.pulse_tau=220e-15;            %pulse duration of laser
    param.g = 0.6 /(param.f_laser *param.pulse_tau);           %from Xu and Webb paper
    param.h = 6.626e-34;                %Plancks constant (J.s).
    
    %if param.scaleAvgPower=1, will scale excitation such that param.power specifies the
    %average power, else param.power is peak.
    param.scaleAvgPower = 1; 
end
%% Define excitation profile.
numcycles = floor(param.tspan(2) / param.period);
if numcycles < 1 
    t = param.tspan(1):param.dt:param.tspan(2);
else
    t = param.tspan(1):param.dt:param.tspan(1)+(numcycles*param.period); %make a whole number of cycles
end

%%preallocate memory for excitation to improve efficiency
I = ones(length(t),1);

%setup excitation for modeling time domain phosphorescence
if(param.frequencyDomain)
    %Define excitation signal for modeling frequency domain phosphorescence
    I = 0.5.*sin(2*pi/param.period .* t) + 0.5;
    
else
    counter=1;
    for n=1:numcycles
        for nn = 1:floor(param.period/param.dt)
            if (nn*param.dt <= param.timeDomainOnTime) 
                I(counter) = 1;
            else
                I(counter) = 0;
            end
            counter = counter +1;
        end
    end
end

%% Scale power such that get the correct average power as specified by
% param.power
twoCycleDuration = (param.period*2);
nTwoCycle = floor(twoCycleDuration / param.dt);  %Added this for modeling durations less than 2 cycles
if nTwoCycle > numel(t)
    nTwoCycle = numel(t);
end
if (param.scaleAvgPower)
    meanValOfExcitation = trapz(t(1:nTwoCycle),I(1:nTwoCycle))/twoCycleDuration;
    meanScaledPower = param.power/meanValOfExcitation;
else
    meanScaledPower = param.power;
end

avgPower = trapz(t(1:nTwoCycle),meanScaledPower.*I(1:nTwoCycle))/twoCycleDuration;
%plot(t,I);

%% Convert intensity to incidence fluence rate (photons per sec per cm^2)
[fvolume, omega_xy,omega_d] = focalvolume_2p(param.lambda, param.NA);
fvolume2 = 70*(param.lambda^3 * param.index/(8*pi^3*param.NA^4));  %m^3

%assume all phosphorescence comes from focal volume;
param.focal_area = pi * (omega_d/2)^2 * (100)^2;  %area in cm^2

%Convert to incidence fluence rate.
meanScaledFluenceRate = meanScaledPower / param.focal_area; %J /(cm^2 * s)

%convert from joules to #photons.
nu = 299792458 / param.lambda;
meanScaledFluenceRate = meanScaledFluenceRate / (param.h*nu);  % photons / (cm^2 * s)
I = I * meanScaledFluenceRate;
figure(1)
subplot(3,1,1)
plot(t,I);
title('Irradiance at Focal Volume')
xlabel('Time (s)');
ylabel('Photons/(s.cm^2)');

%% Perform numeric integration of ODE defining phosphorescence given
%  Incidence fluence rate

% preallocate memory for solution to increase efficiency
N = param.N_0 * ones(length(t),1) * fvolume;  %Num triplet state molecules in focal volume (L)
N_s0 = (param.C * 6.0221415e23) * ones(length(t),1) * fvolume;  %Num ground state molecules in focal volume (L)

%Implement Euler's method
for i =1:length(t)-2
   
  % N_s0(i) = N_s0(1)- N(i);  %N_s0(1) = initial num of molecules in solution in focal volume
   if N_s0(i) < 0
       N_s0(i)=0;
   end
   if N(i) > N_s0(1)
       N(i) = N_s0(1);
   end
   %Current change in number of excited state molecules in focal volume
   excitationRate(i) = (0.5 * param.g * param.x_section * 1e-50 * I(i)^2 * N_s0(i));
   relaxationRate(i) = (param.K_phos_0 * N(i)) +(param.k_quench * N(i) * param.po2);
   dN_dt = -relaxationRate(i) + excitationRate(i);
   %Next number of excited state
   N(i+1) = N(i) + (dN_dt * param.dt);
   %Next number of  ground state molecules in focal volume
   N_s0(i+1) = N_s0(1)-N(i+1); %N_s0(1) = initial num of molecules in solution in focal volume
end

%% Factor in effect of NA on collection of generated phosphorescence.

%first calculate the solid angle from NA of collection objective.
halfAngle = asin(param.NA_collection / param.index);  %in radians
solidAngle = 2*halfAngle * (1-cos(2*halfAngle));
collectedFraction = solidAngle / (4*pi);

%singleCycleGeneratedPhotons = trapz(t(1:nTwoCycle),N(1:nTwoCycle))/2;
singleCycleGeneratedPhotons = trapz(N(1:nTwoCycle))/2;
singleCycleCollectedPhotons = singleCycleGeneratedPhotons * collectedFraction;


%% Display results
%Convert focal volume from L to um^3 because its easier to interpret.
fvolume = fvolume / 1000 * (1e6)^3;
fvolume2 = fvolume2  * (1e6)^3;

ss=sprintf('NA: %3.3f,  Focal Volume: %4e (um^3), Focal Volume2: %4e (um^3), AvgPower = %e (W), Max Irradiance: %e (Ph/(cm^2*s))',param.NA,fvolume,fvolume2,avgPower,max(I))
ss2 = sprintf('1 Cycle Generated Signal: %e, 1 Cycle Collected Signal: %e', singleCycleGeneratedPhotons, singleCycleCollectedPhotons)

if (verbose)
    figure(1)
    
    subplot(3,1,2)
    plot(t,N);
    title('# Molecules in Focal Volume in Triplet State');
    ylabel('# of Molecules');
    xlabel('time (s)');
    
    subplot(3,1,3)
    plot(t,(100 .* N ./ N_s0(1)));
    title('% Molecules in Focal Volume in Triplet State');
    ylabel('% of Molecules');
    xlabel('time (s)');
    ylim([0 100]);

%     subplot(3,1,3)
%     plot(t(1:numel(N)-1),diff(N));
%     title('Excitation Rate - Relaxation Rate');
%     ylabel('dN/dt');
%     xlabel('time (s)');
end

%% Store Results in structure to pass back
results.NA = param.NA;
results.NA_Collection = param.NA_collection;
results.solidAngle = solidAngle;  %Radians
results.collectedFraction = collectedFraction;
results.fvolume = fvolume;
results.fvolume2 = fvolume2;
results.PSF = omega_xy;
results.AvgPower = avgPower;
results.maxIrradiance = max(I);
results.meanScaledFluenceRate = meanScaledFluenceRate; %photons / (cm^2 * s)
results.maxGeneratedSignal = max(N);
results.maxGeneratedSignalPercent = results.maxGeneratedSignal / N_s0(1);
results.singleCycleGeneratedPhotons = singleCycleGeneratedPhotons;
results.GeneratedPhotonsPerSecond = singleCycleGeneratedPhotons * param.modulation_freq;
results.singleCycleCollectedPhotons = singleCycleCollectedPhotons;
results.CollectedPhotonsPerSecond = singleCycleCollectedPhotons * param.modulation_freq;






