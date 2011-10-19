%% This script attempts to compare the effectiveness of the PtP-C343 molecular probe and the Oxyphor R2 molecular probe.

%% Define parameters;
clear all
pO2 = [15:120];                 %mmHg
cross_section_enhancement_factor = 7.5;  %2PP is 7.5x brighter than oxphor R2

unquenched_tau_snr_2pp = 100*2^0.5;               %tau SNR at 0.6s integration time
unquenched_tau_snr_r2 = 33;               %tau SNR at 0.6s integration time
unquenched_tau_snr_ratio = unquenched_tau_snr_2pp/unquenched_tau_snr_r2; %assumes 0.6s integration time. 2pp snr / r2 snr
quench_constant_r2 = 332;   %1/(mmHg.sec)
quench_constant_2pp = 291.65;   %1/(mmHg.sec)
tau_0_r2 = tau(0);              %Unquenched lifetime for R2;
tau_0_2pp = tau_2pp(0);         %Unquenched lifetime for 2P porph (PtP-C343)

%% Compute the ratio of SNR of pO2 for PtP-C343 / SNR of pO2 for Oxyphor R2
unquenched_tau_snr_ratio = unquenched_tau_snr_ratio;
for i=1:numel(pO2)
    tau_o2_2pp = tau_2pp(pO2(i));
    tau_o2_r2 = tau(pO2(i));
    
    reduction_factor_2pp = (tau_o2_2pp/tau_0_2pp)^0.5;  %This is to account for change in SNR due to loss of signal from quenching
    reduction_factor_r2 = (tau_o2_r2/tau_0_r2)^0.5;  %This is to account for change in SNR due to loss of signal from quenching
    
    tau_o2_snr_2pp(i) = unquenched_tau_snr_2pp * reduction_factor_2pp;
    tau_o2_snr_r2(i) = unquenched_tau_snr_r2 * reduction_factor_r2;
    
    tau_o2_snr_ratio = tau_o2_snr_2pp(i)/tau_o2_snr_r2(i);

    po2_snr_ratio(i) = tau_o2_snr_ratio * (quench_constant_2pp .* tau_o2_2pp) ./ (quench_constant_r2 .* tau_o2_r2);
    po2_snr_ratio_b(i) = tau_o2_snr_ratio * ((1-(tau_o2_2pp/tau_0_2pp)) ./ (1-(tau_o2_r2/tau_0_r2)));

end
%% Plot results
figure(1)
plot(pO2, po2_snr_ratio,'r*', pO2,po2_snr_ratio_b,'go-');
xlabel('pO2 (mmHg)')
ylabel('2PP SNR / R2_SNR');
title('SNR of pO2 from 2PP relative to SNR of pO2 from R2')

figure(2)
plot(pO2, tau_o2_snr_2pp, 'r*-', pO2,tau_o2_snr_r2, 'go-');
xlabel('pO2 (mmHg)')
ylabel('tau snr');
title('SNR of lifetime vs pO2')

csvwrite('po2_snr_comparison_results.csv',[pO2' po2_snr_ratio' po2_snr_ratio_b' tau_o2_snr_r2' tau_o2_snr_2pp']);