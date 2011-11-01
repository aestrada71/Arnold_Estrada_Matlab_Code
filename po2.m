function o2 = po2(lifetime)         %returns units of torr

tau_naut = 676e-6;      %seconds
quench_constant = 332;   %1/(torr.sec)

o2 = (1/quench_constant) .* (1./lifetime - 1/tau_naut);