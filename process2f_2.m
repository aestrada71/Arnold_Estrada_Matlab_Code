%%  Process2f_2.m 
% Process 2F data taken with daq board.  This routine assumes that 
% avg 2F has been run on the raw data and that *.asc files were created
% which contain the avearged phosphorescence waveform.  This routine 
% takes the fft and  pulls out the 2f component of the waveform then analyzes
% the phase vs modulation frequency of this 2f component

clear

%% Define relavent parameters
% F_samp = 30e3;           %Sampling frequency
% dt = 1 / F_samp;        %time resolution
% t_max = 1;              %Total time duration of averaged signal (s)
% F_max = F_samp / 2;     %Max frequency component that will be in the fft.
% df = 1/t_max;

freqs = [100,200,300,400,500,600,700,800,900,1000]';
%freqs = [100 200];

%% Read files in, and process
%dir = '/Volumes/RUGGED/Data/2008_07_13/';
dir = 'c:/Data/2008_08_25/';
p_baseName = 'Porph_';
f_baseName = 'Fluor_';
suffix2 = '2.txt';

for i = 1:numel(freqs)
    temp = sprintf('%ihz',freqs(i));
    p_fileName = [dir, p_baseName, temp, suffix2];
    f_fileName = [dir, f_baseName, temp, suffix2];

    pData = dlmread(p_fileName);
    t = pData(:,1);
    pData = pData(:,2);
    
    fData = dlmread(f_fileName);
    fData = fData(:,2);
    
%     dt = t(2) - t(1);
%     f_samp = 1/dt;
%     f_max = f_samp / 2;
%     df = 1/max(t);
    
    fSpectrum =(fftshift(fft(fData)));
    pSpectrum =(fftshift(fft(pData)));
   
    dt = t(2) - t(1);
    df = 1/(numel(t) * dt);
    fmax = 1/2 * 1/dt;
    fmin = -fmax;
    f= (fmin: df : fmax-df)';
    
    %Find the 1f and 2f components
    ind = find(f>=freqs(i),1,'first')-1;
    ind2f = find(f>=(freqs(i)*2),1,'first')-1;
    
%     figure(1)
%     subplot(2,1,1)
%     plotInd = numel(f)/2:numel(f)/2+1500;
%     plot(f(plotInd),abs(fSpectrum(plotInd)));
%     subplot(2,1,2)
%     plot(f(plotInd),unwrap(angle(fSpectrum(plotInd)))*180/pi,'*')
    
    fluor(i).f = f(ind);
    fluor(i).f2 = f(ind2f);
    fluor(i).mag = abs(fSpectrum(ind));
    temp = angle(fSpectrum(ind));
    if (temp < 0)
        temp = temp + 2*pi;
    end
    fluor(i).phase = temp*180/pi;
    fluor(i).mag2f = abs(fSpectrum(ind2f));
    temp = angle(fSpectrum(ind2f));
    if (temp < 0)
        temp = temp + 2*pi;
    end
    fluor(i).phase2f = temp*180/pi;

    porph(i).f = f(ind);
    porph(i).f2 = f(ind2f);
    porph(i).mag = abs(pSpectrum(ind));
    temp = angle(pSpectrum(ind));
    if (temp < 0)
        temp = temp + 2*pi;
    end
    porph(i).phase = temp*180/pi;
    porph(i).mag2f = abs(pSpectrum(ind2f));
    temp = angle(pSpectrum(ind2f));
    if (temp < 0)
        temp = temp + 2*pi;
    end
    porph(i).phase2f = temp*180/pi;
    
    shift(i) = -porph(i).phase + fluor(i).phase;
    shift2f(i) = -porph(i).phase2f + fluor(i).phase2f;
    
    
    
%     figure(1)
%     semilogy(f(numel(f)/2:end),fSpectrum(numel(f)/2:end));
%     figure(2)
%     semilogy(f(numel(f)/2:end),pSpectrum(numel(f)/2:end));
end

theorPhase1f = (atan(2.*pi.*freqs.*637e-6))*180/pi;
theorPhase2f = (atan(2.*2.*pi.*freqs.*637e-6))*180/pi;
figure(4)
subplot(2,1,1);
plot(freqs,shift,'r*',freqs,theorPhase1f,'r')
title('1F phase shift')
xlabel('Modulation freq (Hz)')
ylabel('Phase shift (degrees)')
legend('Measured','Theoretical')

subplot(2,1,2);
plot(freqs,shift2f,'g*',freqs,theorPhase2f,'g')
title('2F phase shift')
xlabel('Modulation freq (Hz)')
ylabel('Phase shift (degrees)')
legend('Measured','Theoretical')
% subplot(3,1,3);
% plot(freqs,fluor(i).phase2f-fluor(i).phase,'b*')


%% 
% [data t] = read_asc(dt(i), fName);
% figure(1)
% plot(t,data)
% 
% %pspectrum = fftshift(abs(fft(data)));
% pspectrum = fftshift(abs(fft(data)));
% spectrum = fft(data);
% 
% dt = t(2) - t(1);
% df = 1/(numel(t) * dt);
% %df=100;
% fmax = 1/2 * 1/dt;
% fmin = -fmax;
% f= ((fmin + df): df : fmax)';
% 
% figure(2)
% %plot(f(numel(f)/2:end),pspectrum(numel(f)/2:end))
% semilogy(f(2048:2148) ,pspectrum(2048:2148))
% 
% figure(3);
% plot(t,ifft(spectrum));
    
%end