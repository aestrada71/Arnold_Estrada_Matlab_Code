function o2 = po2_2pp(lifetime)         %returns units of torr

 tau_naut = 48e-6;      %seconds
quench_constant = 529.2;   %1/(torr.sec)
% 
% o2 = (1/quench_constant) .* (1./lifetime - 1/tau_naut);

% Using the non-standard conversion from lifetime to pO2 from Vinogradov.  
% pO2 = A1 * exp(-tau/t1) + A2 * exp(-tau/t2) + y0

A1 = 5686.40211;
t1 = 3.58341;
A2 = 269.12134;
t2 = 14.52748;
y0 = -9.37638;


tau = lifetime * 1e6;       %convert from seconds to microseconds.
o2 = A1 * exp(-tau/t1) + A2 * exp(-tau/t2) + y0;

%o2 = (1/quench_constant) .* (1./lifetime - 1/tau_naut);