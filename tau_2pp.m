function lifetime = tau_2pp(pO2)         %returns units of seconds

% This works for Oxyphor R2

approxLifetime = 0;         %If set, returns lifetime assuming the stern-volmer approximation

tau_naut = 48e-6;      %seconds
tau_naut = 39.367e-6

if approxLifetime==0
    %tau_naut = 48e-6;      %Original Values from Vinogradov (s)
    %quench_constant = 529;   %Original Values from Vinogradov (1/(torr.sec))
    
    tau_naut = 39.367e-6;      %This value comes from best linear fit to calibration curve (seconds)
    quench_constant = 291.65;   %Value comes from best linear fit to calibration curve (1/(torr.sec))
    %o2 = (1/quench_constant) .* (1./lifetime - 1/tau_naut);
    lifetime = 1./((1./tau_naut) + quench_constant.*pO2);
else

    % use root finding approach.
    fHandle = @(tau)pO2 - po2_2pp(tau);


    [temp fval exitflag]= fzero(fHandle,tau_naut);

    if exitflag == 1
        lifetime = temp;
    else
        lifetime = -1;
    end
end