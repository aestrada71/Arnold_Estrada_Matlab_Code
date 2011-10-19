
tau=100e-6;
a=1; b=a;
f=100:200:10000;

phase1=zeros(size(f));
phase21=zeros(size(f));
phase22=zeros(size(f));

M1=zeros(size(f));
M21=zeros(size(f));
M22=zeros(size(f));

r1=zeros(size(f));
r21=zeros(size(f));
r22=zeros(size(f));

for iif=1:length(f)
    % generate simulated data
    [Iref,I1,I2,t]=generate_freq_data(tau, f(iif), a, b);
    % now fit the data
    ind=find(t>= max(t)/2);
    t=t(ind);
    Iref=Iref(ind);
    I1=I1(ind);
    I2=I2(ind);
    fit_fun1 = sprintf('a+b*sin(2*pi*%i*x-phi)',f(iif));
    fit_fun2 = sprintf('(a+b*sin(2*pi*%i*x-phi)).^2',f(iif));
    
    f_ref = fit(t,Iref,fit_fun1);
    f_1 = fit(t, I1, fit_fun1);
    f_22 = fit(t, I2, fit_fun2);
    f_21 = fit(t, I2, fit_fun1);
    
    phase1(iif)=(f_1.m(3) - f_ref.m(3));
    phase21(iif)=(f_21.m(3) - f_ref.m(3));
    phase22(iif)=(f_22.m(3) - f_ref.m(3));
    
    M1(iif)=(f_1.m(2)/f_1.m(1))/(f_ref.m(2)/f_ref.m(1));
    M21(iif)=(f_21.m(2)/f_21.m(1))/(f_ref.m(2)/f_ref.m(1));
    M22(iif)=(f_22.m(2)/f_22.m(1))/(f_ref.m(2)/f_ref.m(1));
    
    r1(iif)=f_1.r;
    r21(iif)=f_21.r;
    r22(iif)=f_22.r;
end


