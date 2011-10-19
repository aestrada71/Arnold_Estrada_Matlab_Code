function fit_qwp_hwp()
disp('Quarter Wave Plate');
d=load('-ascii','qwp.txt');
d=sortrows(d);
C=[cosd(4*d(:,1)) sind(4*d(:,1)) ones(size(d(:,1)))];
[x,resnorm,residual]=lsqlin(C,d(:,2));
disp({'resnorm' 'residual'; resnorm residual});
figure;
plot(min(d(:,1)):0.01:max(d(:,1)),fitfunc(x,min(d(:,1)):0.01:max(d(:,1))),'r');
hold on;
plot(d(:,1),d(:,2),'k.');
xlabel('Angle (Degrees)');
ylabel('Intensity (mV)');
title('Quarter Wave Plate');
legend('Fit','Data');

disp('Half Wave Plate');
d=load('-ascii','hwp.txt');
d=sortrows(d);
C=[cosd(4*d(:,1)) sind(4*d(:,1)) ones(size(d(:,1)))];
[x,resnorm,residual]=lsqlin(C,d(:,2));
disp({'resnorm' 'residual'; resnorm residual});
figure;
plot(min(d(:,1)):0.01:max(d(:,1)),fitfunc(x,min(d(:,1)):0.01:max(d(:,1))),'r');
hold on;
plot(d(:,1),d(:,2),'k.');
xlabel('Angle (Degrees)');
ylabel('Intensity (mV)');
title('Half Wave Plate');
legend('Fit','Data');

function y=fitfunc(x,xdata)
% y=x(1)*cosd(4*xdata)+x(2)*sind(4*xdata)+x(3)*ones(size(xdata));
magnitude=sqrt(x(1)^2+x(2)^2);
phase=atand(-x(2)/x(1));
if(x(1)<0)
   phase=phase+180;
end
y=magnitude*cosd(4*xdata+phase)+x(3)*ones(size(xdata));
disp({'Magnitude' 'Phase' 'Offset'; magnitude phase x(3)});