%This macro was written to investigate the effect of the amplifier's
%bandwidth on the porphyrin lifetime measurement.


r = 500;
c = 1e-8;
amp_tau = r*c;             %rc time constant (seconds)
numPoints = 20000;
f_max = 2e6;            %Max freq to consider (Hz)
f_min = -f_max;
f_inc = (f_max - f_min)/numPoints;
f = f_min+f_inc:f_inc:f_max;
omega = 2.*pi.*f;

t_min = 0;
t_inc = 1/(2*f_max);
t_max = (numPoints-1)*t_inc;
time = t_min:t_inc:t_max;


%Define porph signal in time domain
porph_tau = 550e-6;     %seconds
porph_t = 1*exp(-time/porph_tau);
figure(1);
hold off;
plot(time,porph_t);
%Calc fft of porph signal.
porph_f = fftshift(fft(porph_t));
figure(2);
plot(abs(porph_f));

%Define low pass filter response in freq domain.
response_f = 1./(1+amp_tau.*i*omega);
figure(2);
%hold on
plot(abs(response_f));

%multiply response and porph signal in freq domain.
output_f = response_f.*porph_f;

%calc output in time domain
output_t = ifft(fftshift(output_f));
figure(1)
hold on
plot(time,porph_t,time,real(output_t),'g*');
