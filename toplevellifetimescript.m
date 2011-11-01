fpath= uigetdir('~/Documents/FTP Downloads/', 'Select 2Photon dir of lifetime Data Files');

basename = 'Instr_';
%basename = 'Rhodamine_phase_';
%ProcessLifetimeTriggdData;
instr = ProcessLifetimeData(basename,fpath);

basename = 'Porph_';
%basename = 'Rhodamine_';
%ProcessLifetimeTriggdData;
porph = ProcessLifetimeData(basename,fpath,instr);



figure(5);
freqs=[instr.freq];


plot(freqs,[instr.PhaseDiff],'ro',...
        freqs, [porph.PhaseDiff],'b*',...
        freqs, [porph.PhaseDiff]-[instr.PhaseDiff],'g-');
theor2 = atan(2*pi.*freqs*200e-6)*180/pi;
hold on;
plot(freqs,theor2);