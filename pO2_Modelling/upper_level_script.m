%This script runs the phosphorescence_modelling function and tweaks various
%parameters to see the effect on the collected signal.  The results are
%stored in a file for further analysis after the fact.
tic
checkNAEffects = 1;
checkConcentrationEffects = 1;

%% Setup default conditions for the simulation.
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
        param.x_section = 15/param.QE;       %Two photon ABSORPTION cross section of porph (GM = 1e-50 cm^4 s / photon).
        param.C = 100e-6;                   %Concentration of porphyrin. in Molarity
        param.lambda = 870e-9;              %Excitation wavelength (m);
    end

    param.K_phos_0 = 1/param.tau_0;     %Rate constant for emission of phosphorescence photons
    tau_effective = (1/param.tau_0 + param.k_quench * param.po2)^-1;
    param.lambda = 800e-9;              %Excitation wavelength (m);
    param.power = 30e-3;                 %Excitation power at focal volume (J/s)
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
    param.pulse_tau=250e-15;            %pulse duration of laser
    param.g = 0.6 /(param.f_laser *param.pulse_tau);           %from Xu and Webb paper
    param.h = 6.626e-34;                %Plancks constant (J.s).
    
    %if param.scaleAvgPower=1, will scale excitation such that param.power specifies the
    %average power, else param.power is peak.
    param.scaleAvgPower = 0;    
    
%% Open file for writing results
fid = fopen('R2_results_075mmHg.txt','w');

%% Vary excitation NA
fprintf(fid,'Variation of NA \n');

Concentration_vals = [50 100 150 200 250 300 350 400 450 500]*1e-6; %(Molar)
NA_vals = [0.25 0.35 0.45 0.55 0.65 0.75 0.85 0.95];
figure(10)
for cc = 1:numel(Concentration_vals);
    param.C = Concentration_vals(cc);
    fprintf(fid,'\nPorph Concentration: %e\n',param.C);
    fprintf(fid, ...
    'NA \t NA_Collection\t Solid_Angle\t Collected_Fraction\t Focal_Volume\t PSF\t Max_I\t Max_Generated_Sig(%%)\t Total_Generated_Sig_1_Cycle\t Total_Collected_Sig_1_Cycle\t Generated_Sig_1_Sec\t Collected_Sig_1_Sec\n');

    for n=1:numel(NA_vals)
       param.NA = NA_vals(n);
       param.NA_collection = 0.95;
       temp = phosphorescence_modelling(param);
       fprintf(fid, '%1.2f\t  %1.2f\t %1.3f\t %1.3f\t %e\t %e\t %e\t %e\t% e\t %e\t %e\t %e\n',temp.NA, temp.NA_Collection, temp.solidAngle, ...
           temp.collectedFraction, temp.fvolume, temp.PSF, temp.maxIrradiance, temp.maxGeneratedSignalPercent, temp.singleCycleGeneratedPhotons, temp.singleCycleCollectedPhotons, ...
           temp.GeneratedPhotonsPerSecond, temp.CollectedPhotonsPerSecond);

       results(cc,n).Concentration = Concentration_vals(cc);
       results(cc,n).NA = temp.NA;
       results(cc,n).NA_Collection = temp.NA_Collection;
       results(cc,n).collectedFraction = temp.collectedFraction;
       results(cc,n).solidAngle  = temp.solidAngle;
       results(cc,n).fvolume = temp.fvolume;
       results(cc,n).fvolume2 = temp.fvolume2;
       results(cc,n).PSF = temp.PSF;
       results(cc,n).maxIrradiance = temp.maxIrradiance;
       results(cc,n).maxGeneratedSignalPercent  = temp.maxGeneratedSignalPercent;
       results(cc,n).singleCycleGeneratedPhotons = temp.singleCycleGeneratedPhotons;
       results(cc,n).singleCycleCollectedPhotons = temp.singleCycleCollectedPhotons;
       results(cc,n).GeneratedPhotonsPerSecond = temp.GeneratedPhotonsPerSecond;
       results(cc,n).CollectedPhotonsPerSecond = temp.CollectedPhotonsPerSecond;

    end
    figure(10)
    plot([results(cc,:).NA],[results(cc,:).singleCycleCollectedPhotons]);
    title('# Molecules in Triplet State');
    xlabel('NA');
    ylabel('# Molecules');
    hold on
    
%     figure(11);
%     plot([results(cc,:).NA],[results(cc,:).fvolume .* 1e-15 .* Concentration_vals(cc)*6.0221415e23]);
%     hold on
    
    figure(11);
    plot([results(cc,:).NA],[results(cc,:).fvolume],[results(cc,:).NA],[results(cc,:).fvolume2]);
    title('Focal Volume vs NA');
    xlabel('NA');
    ylabel('Focal Volume (um^3)');
    hold on
   
end
figure(10); 
legend('50 uM','100 uM','150 uM','200 uM','250 uM','300 uM','350 uM','400 uM','450 uM','500 uM');
hold off;
figure(11); hold off;


%% 

fclose(fid);
toc

