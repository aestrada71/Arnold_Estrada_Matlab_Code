f2=165; % assume 160mm tube lens 
m=2; % magnification of 3
d3=95; %assume 95mm distance between objective and tube lens

%f1=f2/m;
f1=50
d2=f1+f2;
d1 = f1*f1/f2 + f1 - d3*(f1/f2)^2;

sprintf('d1 = %.2f mm\nd2 = %.2f mm\nd3 = %.2f mm',d1,d2,d3)
sprintf('f1 = %.2f mm\nf2 = %.2f',f1,f2)









