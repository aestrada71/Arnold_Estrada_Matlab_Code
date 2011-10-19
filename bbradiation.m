h = 6.626e-34;       %J s
c = 2.9979e8;       %m/s
k = 1.3807e-23;     %J/K;
dt = 5.86e-7;       %time bin of photon counting board (s)
collectionTime = 120;%sec
aomRepRate = 300;   %Hz
%efficiency;
%solidAng = 
volume = 20*10*10*1e-9;      % mm3 to m3
T1 = 291.75;         %K
T2 = 292.25;         %K


I_planck = @(lambda,T) (2.*h.*c^2./lambda.^5).*(1./(exp(h*c./(lambda.*k.*T))-1));

lambda = (680:720).*1e-9;
nu = c./lambda;

temp = I_planck(lambda,T1);
I1 = temp./(h.*nu);  %photon/s m2 sr m
I1 = I1 * volume * dt * collectionTime * aomRepRate;                     %photon/ sr
%sig1 = trapz(lambda,I1)
sig1 = trapz(I1);
temp = I_planck(lambda,T2);
I2 = temp./(h.*nu);
I2 = I2 * volume *dt * collectionTime * aomRepRate;                     %photon/ sr
%sig2 = trapz(lambda,I2)
sig2 = trapz(I2);
percentDiff = (sig2-sig1)/sig1
figure(1)
semilogy(lambda*1e9, I1,lambda*1e9,I2);
figure(2)
plot(lambda*1e9, (I2-I1)./I1)