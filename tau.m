function lifetime = tau(pO2)         %returns units of seconds

% This works for Oxyphor R2


tau_naut = 676e-6;      %seconds
quench_constant = 332;   %1/(torr.sec)

%o2 = (1/quench_constant) .* (1./lifetime - 1/tau_naut);

lifetime = 1./((1./tau_naut) + quench_constant.*pO2);