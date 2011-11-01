%analize asc data to look for 2f components

clear


%% Define modulation frequencies and sample rates.


allDts = [2.441e-6,2.441e-6,2.441e-6,2.441e-6,2.441e-6,...
    9.766e-7,9.766e-7,9.766e-7,9.766e-7,9.766e-7,4.882e-7,4.882e-7,4.882e-7,4.882e-7]';

allFreqs = [200,400,600,800,1000,1200,1400,1600,1800,2000,2200,2400,2600,3000]';

goodInds =[1 2 3 4 5 10 14 15];
dts = allDts();
freqs = allFreqs();

%% Get phase of ref and porph data for 1f and 2f components


dir = '~/Desktop/2008_05_13/';

for i = 1:numel(freqs)
    temp = sprintf('f%ihz.asc',freqs(i));
    fName = [dir, temp];
    temp = sprintf('p%ihz.asc',freqs(i));
    pName = [dir, temp];

    [fData t] = read_asc(dts(i), fName);
    [pData t] = read_asc(dts(i), pName);

    fSpectrum =(fftshift(fft(fData)));
    pSpectrum =(fftshift(fft(pData)));
   
    dt = t(2) - t(1);
    df = 1/(numel(t) * dt);
    fmax = 1/2 * 1/dt;
    fmin = -fmax;
    f= (fmin: df : fmax-df)';
    
    %Find the 1f and 2f components
    ind = find(f>=freqs(i),1,'first');
    ind2f = find(f>=(freqs(i)*2),1,'first');
    
%     figure(1)
%     plot(f(ind-5),fSpectrum(ind-5),'*')
%     figure(2)
%     plot(f(ind2f-5),fSpectrum(ind2f-5),'*')
    
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
    
    shift(i) = porph(i).phase - fluor(i).phase;
    shift2f(i) = porph(i).phase2f - fluor(i).phase2f;
    
    
    
%     figure(1)
%     semilogy(f(numel(f)/2:end),fSpectrum(numel(f)/2:end));
%     figure(2)
%     semilogy(f(numel(f)/2:end),pSpectrum(numel(f)/2:end));
end



figure(3)
subplot(3,1,1);
plot(freqs,shift,'r*')
subplot(3,1,2);
plot(freqs,shift2f,'g*')
subplot(3,1,3);
plot(freqs,fluor(i).phase2f-fluor(i).phase,'b*')


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