%% This script attempts to compare the effectiveness of the PtP-C343 molecular probe and the Oxyphor R2 molecular probe.

%% Define parameters;
pO2 = [10:120];                 %mmHg
cross_section_enhancement_factor = 7.5;  %2PP is 7.5x brighter than oxphor R2
tau_0_snr_r2 = 40;              %assumes a certain integration time.
tau_0_snr_2pp = tau_0_snr_r2 * (cross_section_enhancement_factor)^0.5;
quench_constant_r2 = 332;   %1/(mmHg.sec)
quench_constant_2pp = 529.2;   %1/(mmHg.sec)
tau_0_r2 = tau(0);              %Unquenched lifetime for R2;
tau_0_2pp = tau_2pp(0);         %Unquenched lifetime for 2P porph (PtP-C343)

%% Compute the ratio of SNR of pO2 for PtP-C343 / SNR of pO2 for Oxyphor R2
unquenched_tau_snr_ratio = tau_0_snr_2pp / tau_0_snr_r2;
for i=1:numel(pO2)
    tau_po2_2pp = tau_2pp(pO2(i));
    tau_po2_r2 = tau(pO2(i));
    
    tau_po2_snr_2pp = tau_0_snr_2pp * (tau_po2_2pp/tau_0_2pp);  %This is to account for change in SNR due to loss of signal from quenching
    tau_po2_snr_r2 = tau_0_snr_r2 * (tau_po2_r2/tau_0_r2);  %This is to account for change in SNR due to loss of signal from quenching
    
    tau_snr_ratio = tau_po2_snr_2pp / tau_po2_snr_r2;

    po2_snr_ratio(i) = tau_snr_ratio * (quench_constant_2pp .* tau_po2_2pp) ./ (quench_constant_r2 .* tau_po2_r2);

end
%% Plot results
figure(1)
plot(pO2, po2_snr_ratio);
xlabel('pO2 (mmHg)')
ylabel('2PP SNR / R2_SNR');
title('SNR of pO2 from 2PP relative to SNR of pO2 from R2')