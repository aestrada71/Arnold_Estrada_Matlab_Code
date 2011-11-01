%%  Process2f_filter.m 
% Process 2F data taken with daq board.  This routine assumes that 
% avg 2F has been run on the raw data and that *.asc files were created
% which contain the avearged phosphorescence waveform.  This routine 
% filters all but the 1f or 2f component of the waveform then fits the filtered
% waveform and analyzes the phase vs modulation frequency of this 2f 
% component

% Modified from original to process saturation effects on phase vs. freq data 
% 2008/08/28 -ADE
clear
bProcess2F = 1;
bProcess1F = 1;
numCyclesToFit = 5;
tau = 637e-6;
%% Define relavent parameters
% F_samp = 30e3;           %Sampling frequency
% dt = 1 / F_samp;        %time resolution
% t_max = 1;              %Total time duration of averaged signal (s)
% F_max = F_samp / 2;     %Max frequency component that will be in the fft.
% df = 1/t_max;

freqs = [50 70 100,200,300,400,500,600,700,800,900,1000]';
%freqs = [100 200];

%% Define strings needed for input and output file names
%dir = '/Volumes/RUGGED/Data/2008_07_13/';
dir = 'c:/Data/2008_09_11/';
p_baseName = 'Porph_';
f_baseName = 'Fluor_';
suffix = '.txt';
suffix2 = '2.txt';

%% Process each file.
for i = 1:numel(freqs)
    if (bProcess1F==1)
        %% Read in each file
        temp = sprintf('%ihz',freqs(i));
        p_fileName = [dir, p_baseName, temp, suffix];
        f_fileName = [dir, f_baseName, temp, suffix]; 

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
        tempString = sprintf(' %i Hz',freqs(i));
        title(['1F Filter:' tempString])
        pause(0.2);

        %Perform filtering
        pFilt = filtfilt(b,a,pData);
        fFilt = filtfilt(b,a,fData);

        numSampsPerCycle =fsamp/freqs(i);
        sampsInXCycles = int32(numSampsPerCycle*numCyclesToFit);
        startSamp = int32(numel(t)/2);      %Grab data from middle
        wantedIndices = startSamp:startSamp+sampsInXCycles-1;

        %% Fit the filtered signal to sinusoid (or fit raw data if filtering causes phase shift)
        fitFunc = sprintf('a*cos(%f * x + phi1)',freqs(i)*2*pi);
        f_results = ezfit(t(1:sampsInXCycles),fData(wantedIndices), fitFunc,[1,0]);
        p_results = ezfit(t(1:sampsInXCycles),pData(wantedIndices), fitFunc,[1,f_results.m(2)]);

        figure(2)
        subplot(2,1,1);
        plot(t(1:sampsInXCycles),pData(wantedIndices))
        title(['1F Porph data' tempString ' (Raw)']) 
        pause(0.2)

        subplot(2,1,2);
        plot(t(1:sampsInXCycles),pFilt(wantedIndices));
        rmfit;
        showfit(p_results);     %Overlays fit waveform
        title(['1F Porph data' tempString ' (Filtered)'])

        figure(3)
        subplot(2,1,1);
        plot(t(1:sampsInXCycles),fData(wantedIndices))
        title(['1F Fluor data' tempString ' (Raw)']) 
        
        subplot(2,1,2);
        plot(t(1:sampsInXCycles),fFilt(wantedIndices));
        rmfit;
        showfit(f_results);     %Overlays fit waveform
        title(['1F Fluor data' tempString ' (Filtered)'])
        pause(0.2);
        
        %Store results in struct for further analysis from command line
        results(i).f = freqs(i);
        results(i).f_phase1f = f_results.m(2)*180/pi;
        results(i).p_phase1f = p_results.m(2)*180/pi;
        results(i).f_mag1f = abs(f_results.m(1));
        results(i).p_mag1f = abs(p_results.m(1));
        results(i).phaseDiff1f = abs(results(i).f_phase1f - results(i).p_phase1f);

    end
   
    %2F
    if (bProcess2F==1)
        
        wp = [freqs(i)*1.98 freqs(i)*2.02]/fnyquist;
        ws = [freqs(i)*0.6 freqs(i)*3.4]/fnyquist;

        [n wn]=buttord(wp,ws,4,60);
        [b a] = butter(n, wn);
        figure(5);
        freqz(b,a,500,fsamp);
        tempString = sprintf(' %i Hz',freqs(i));
        title(['2F Filter:' tempString])
        pause(0.1);

        pFilt = filtfilt(b,a,pData);
        fFilt = filtfilt(b,a,fData);

        numSampsPerCycle =fsamp/(2*freqs(i));
        sampsInXCycles = int32(numSampsPerCycle*numCyclesToFit);
        startSamp = int32(numel(t)/2);  %Grab data from middle
        wantedIndices = startSamp:startSamp+sampsInXCycles-1;

        %% Fit the filtered signal to sinusoid (or fit raw data if
        %% filtering causes phase shift)
        fitFunc = sprintf('a*cos(%f * x + phi1)',freqs(i)*2*2*pi);
        f_results = ezfit(t(1:sampsInXCycles),fData(wantedIndices), fitFunc,[1,0]);
        p_results = ezfit(t(1:sampsInXCycles),pData(wantedIndices), fitFunc,[1,f_results.m(2)]);


        figure(6)
        subplot(2,1,1);
        plot(t(1:sampsInXCycles),pData(wantedIndices))
        title(['2F Porph data' tempString ' (Raw)'])
        
        subplot(2,1,2);
        plot(t(1:sampsInXCycles),pFilt(wantedIndices),'b');
        rmfit;
        showfit(p_results);
        title(['2F Porph data' tempString ' (Filtered)'])
        pause(0.1);

        figure(7)
        subplot(2,1,1);
        plot(t(1:sampsInXCycles),fData(wantedIndices))
        title(['2F Fluor data' tempString ' (Raw)'])
        
        subplot(2,1,2);
        plot(t(1:sampsInXCycles),fFilt(wantedIndices));
        rmfit;
        showfit(f_results);
        title(['2F Fluor data' tempString ' (Filtered)'])
        pause(0.1);

        %Store results in struct for further analysis from command line
       results(i).f = freqs(i);
       results(i).f_phase2f = f_results.m(2)*180/pi;
       results(i).p_phase2f = p_results.m(2)*180/pi;
       results(i).f_mag2f = abs(f_results.m(1));
       results(i).p_mag2f = abs(p_results.m(1));
       results(i).phaseDiff2f = abs(results(i).f_phase2f - results(i).p_phase2f);
       
       %temp code
       f_results.m(2)*180/pi
       p_results.m(2)*180/pi
       
       if ((f_results.m(1)*p_results.m(1)) < 0)
           results(i).phaseDiff2f = 180-results(i).phaseDiff2f
       end
    end

end

if (bProcess1F==1)     
    %Plot Overall 1F results
    theorPhase1f = (atan(2.*pi.*freqs.*tau))*180/pi;
    figure(4);
    plot(freqs,abs([results(:).phaseDiff1f]),'r*',freqs,theorPhase1f,'r')
    title('1F phase shift')
    xlabel('Modulation freq (Hz)')
    ylabel('Phase shift (degrees)')
    legend('Measured','Theoretical')
end

if (bProcess2F==1)
    %Plot Overall 2F results
    theorPhase2f = (atan(2.*2.*pi.*freqs.*tau))*180/pi;
    figure(8);
    plot([results(:).f],[results(:).phaseDiff2f],'g*',freqs,theorPhase2f,'g');
    title('2F phase shift')
    xlabel('Modulation freq (Hz)')
    ylabel('Phase shift (degrees)')
    legend('Measured','Theoretical')
end
