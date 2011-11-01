function o2 = po2(lifetime)         %returns units of torr

tau_naut = 53.28e-6;      %seconds
quench_constant = 529;   %1/(torr.sec)

o2 = (1/quench_constant) .* (1./lifetime - 1/tau_naut);