%This function calculates the two-photon focal volume as described by the
%November 2003 watt webb paper in Nature Biotechnology.
function [fVolume, varargout] = focalvolume_2p(Lambda, NA)

if (nargin < 2)
    NA = 0.95;              %Index of refraction
end

if (nargin < 1)
    Lambda = 800e-9;        %wavelength in meters
end
        
N = 1.33;               


omega_z = (0.532 * Lambda)/sqrt(2) * [1/(N-sqrt(N^2 - NA^2))];

if (NA <= 0.7) 
    omega_xy = (0.320 * Lambda) / (sqrt(2) * NA);
    
else
    omega_xy = (0.325 * Lambda) / (sqrt(2) * NA^0.91);
end


fVolume = pi^(3/2) * omega_xy^2 * omega_z / 0.68;  %units of m^3;

fVolume = fVolume * 1e6/1e3;           %units of liters

varargout(1) = {omega_xy};           %meters
varargout(2) = {omega_z};