%%  Process2f_filter.m 
% Process 2F data taken with daq board.  This routine assumes that 
% avg 2F has been run on the raw data and that *.asc files were created
% which contain the avearged phosphorescence waveform.  This routine 
% filters all but the 1f or 2f component of the waveform then fits the filtered
% waveform and analyzes the phase vs modulation frequency of this 2f 
% component

clear

%% Define relavent parameters
% F_samp = 30e3;           %Sampling frequency
% dt = 1 / F_samp;        %time resolution
% t_max = 1;              %Total time duration of averaged signal (s)
% F_max = F_samp / 2;     %Max frequency component that will be in the fft.
% df = 1/t_max;

freqs = [100,200,300,400,500,600,700,800,900,1000]';
%freqs = [100 200];

%% Define strings needed for input and output file names
%dir = '/Volumes/RUGGED/Data/2008_07_13/';
dir = 'c:/Data/2008_08_25/';
p_baseName = 'Porph_';
f_baseName = 'Fluor_';
suffix2 = '.txt';

%% Process each file.
for i = 1:numel(freqs)
    
    %% Read in each file
    temp = sprintf('%ihz',freqs(i));
    p_fileName = [dir, p_baseName, temp, suffix2];
    f_fileName = [dir, f_baseName, temp, suffix2];

    pData = dlmread(p_fileName);
    t = pData(:,1);
    pData = pData(:,2);
    
    fData = dlmread(f_fileName);
    fData = fData(:,2);
   
    dt = t(2) - t(1);
    fsamp = 1/dt;
    fnyquist = fsamp/2;

    %% 1F components
    wp = [freqs(i)*0.98 freqs(i)*1.02]/fnyquist;
    ws = [freqs(i)*0.3 freqs(i)*1.7]/fnyquist;
    
    [n wn]=buttord(wp,ws,4,60);
    [b a] = butter(n, wn);
    figure(1);
    freqz(b,a,500,fsamp);
    pause(0.2);
    
    pFilt = filtfilt(b,a,pData);
    fFilt = filtfilt(b,a,fData);
    
    numSampsPerCycle =fsamp/freqs(i);
    sampsInXCycles = int32(numSampsPerCycle*5);
    startSamp = int32(numel(t)/2);
    wantedIndices = startSamp:startSamp+sampsInXCycles-1;
    
    %% Fit the filtered signal to sinusoid
    fitFunc = sprintf('a*cos(%f * x + phi1)',freqs(i)*2*pi);
    f_results = ezfit(t(1:sampsInXCycles),fData(wantedIndices), fitFunc,[1,0]);
    p_results = ezfit(t(1:sampsInXCycles),pData(wantedIndices), fitFunc,[1,f_results.m(2)]);
    

    
    figure(2)
    subplot(2,1,1);
    plot(t(1:sampsInXCycles),pData(wantedIndices))
    subplot(2,1,2);
    plot(t(1:sampsInXCycles),pFilt(wantedIndices));
    rmfit;
    showfit(p_results);
    pause(0.2);
    
    figure(3)
    subplot(2,1,1);
    plot(t(1:sampsInXCycles),fData(wantedIndices))
    subplot(2,1,2);
    plot(t(1:sampsInXCycles),fFilt(wantedIndices));
    rmfit;
    showfit(f_results);
    pause(0.2);
    
    results(i).f = freqs(i);
    results(i).f_phase1f = f_results.m(2)*180/pi;
    results(i).p_phase1f = p_results.m(2)*180/pi;
    results(i).f_mag1f = abs(f_results.m(1));
    results(i).p_mag1f = abs(p_results.m(1));
    results(i).phaseDiff1f = abs(results(i).f_phase1f - results(i).p_phase1f);
    
        %2F
    wp = [freqs(i)*1.98 freqs(i)*2.02]/fnyquist;
    ws = [freqs(i)*0.6 freqs(i)*3.4]/fnyquist;
    
    [n wn]=buttord(wp,ws,4,60);
    [b a] = butter(n, wn);
    figure(1);
    freqz(b,a,500,fsamp);
    pause(0.1);
    
    pFilt = filtfilt(b,a,pData);
    fFilt = filtfilt(b,a,fData);
    
    numSampsPerCycle =fsamp/(2*freqs(i));
    sampsInXCycles = int32(numSampsPerCycle*5);
    startSamp = int32(numel(t)/2);
    wantedIndices = startSamp:startSamp+sampsInXCycles-1;
    
    %% Fit the filtered signal to sinusoid
    fitFunc = sprintf('a*cos(%f * x + phi1)',freqs(i)*2*2*pi);
    f_results = ezfit(t(1:sampsInXCycles),fData(wantedIndices), fitFunc,[1,0]);
    p_results = ezfit(t(1:sampsInXCycles),pData(wantedIndices), fitFunc,[1,f_results.m(2)]);
    

    
    figure(2)
    subplot(2,1,1);
    plot(t(1:sampsInXCycles),pData(wantedIndices))
    subplot(2,1,2);
    plot(t(1:sampsInXCycles),pFilt(wantedIndices));
    rmfit;
    showfit(p_results);
    pause(0.1);
    
    figure(3)
    subplot(2,1,1);
    plot(t(1:sampsInXCycles),fData(wantedIndices))
    subplot(2,1,2);
    plot(t(1:sampsInXCycles),fFilt(wantedIndices));
    rmfit;
    showfit(f_results);
    pause(0.1);
    
    results(i).f = freqs(i);
    results(i).f_phase2f = f_results.m(2)*180/pi;
    results(i).p_phase2f = p_results.m(2)*180/pi;
    results(i).f_mag2f = abs(f_results.m(1));
    results(i).p_mag2f = abs(p_results.m(1));
    results(i).phaseDiff2f = abs(results(i).f_phase2f - results(i).p_phase2f);
end

theorPhase1f = (atan(2.*pi.*freqs.*637e-6))*180/pi;
theorPhase2f = (atan(2.*2.*pi.*freqs.*637e-6))*180/pi;

figure(4);
subplot(2,1,1)
plot([results(:).f],[results(:).phaseDiff1f],'r*',freqs,theorPhase1f,'r')
title('1F phase shift')
xlabel('Modulation freq (Hz)')
ylabel('Phase shift (degrees)')
legend('Measured','Theoretical')

subplot(2,1,2)
plot([results(:).f],[results(:).phaseDiff2f],'g*',freqs,theorPhase2f,'g');
title('2F phase shift')
xlabel('Modulation freq (Hz)')
ylabel('Phase shift (degrees)')
legend('Measured','Theoretical')

