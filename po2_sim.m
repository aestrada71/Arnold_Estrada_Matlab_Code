%_________________________________________________________________________
%   Arnold Estrada
%
%   Program:    po2_sim
%   Purpose:    This program performs a simulation of modulated two photon
%               excitation of a phosphorecent dye.
%
%_________________________________________________________________________
clear all;
tic
tau = 550e-6;                %Dye lifetime
repRate = 100e6;            %Laser reprate (Hz)
modulationRate = 1e3;     %Chopper rate(Hz)
chopperDutyCycle = .5;
sampleTime = 1e-9;          %Time resolution scale        
timeDuration = 1e-3;        %seconds

totalNumSamps = uint32(round(timeDuration / sampleTime));

%setup unmodulated excitation train of pulses.
excitation = zeros(totalNumSamps,1,'single');
timeBetweenPulses = 1 / repRate;
sampsBetweenPulses = round(timeBetweenPulses / sampleTime);
pulseIndices = 1:sampsBetweenPulses:totalNumSamps;
excitation(pulseIndices) = 1;
clear pulseIndices;

%Now Modulate pulse train;
modulation = zeros(totalNumSamps,1,'single');
timeBetweenModCycles = 1/modulationRate;
sampsBetweenModCycles = round(timeBetweenModCycles / sampleTime);
modOnStartIndices = 1:sampsBetweenModCycles:totalNumSamps; %start of each mod cycle.
numSampsOn = uint32(sampsBetweenModCycles*chopperDutyCycle);
modOnIndices = 1:1:numSampsOn;
for (i=2:numel(modOnStartIndices))
    
   modOnIndices = [modOnIndices modOnStartIndices(i):1:modOnStartIndices(i)+numSampsOn];
   
end

modulation(modOnIndices) = 1;
excitation = excitation .* modulation;
clear modulation;
clear monOnIndices;
clear modOnStartIndices;


%Define pO2 Dye response
dyeResponseForm = @(v) exp(-1.*(v./tau));        %Function handle
numSampsInResponse = (3 * tau) / sampleTime;%Response defined to 3 tau.  Should be most of response
t = 1:(numSampsInResponse);
t = t*sampleTime;
response = dyeResponseForm(t);
clear t;

%Now check response to modulated excitation.
output = conv(excitation,response);
clear response;
%normalize
output = output ./ max(output);


figure(1)
timescale = sampleTime .* (1:1:numel(output));
subplot(2,1,1);
plot(timescale, output);


subplot(2,1,2);
%excitation = [excitation zeros(numel(output) - numel(excitation))];
timescale = sampleTime .* (1:1:numel(excitation));
plot(timescale, excitation);
toc